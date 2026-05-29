#!/usr/bin/env python3
"""Repair Little Snitch rules that point at obsolete Nix store paths."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


STORE_PATH_RE = re.compile(r"^/nix/store/[0-9a-z]{32}-([^/]+)(/.*)?$")
VERSION_RE = re.compile(r"^(?P<name>.+?)-[0-9][A-Za-z0-9._+~-]*$")
HELP_REPLACEMENTS = {
    "process": "processPath",
    "via": "viaProcessPath",
}
HELP_PATH_REPLACEMENTS = {value: key for key, value in HELP_REPLACEMENTS.items()}
EXEC_WRAPPER_RE = re.compile(r"^\s*exec\s+(.+)$")
LITTLESNITCH_CLI = Path(
    "/Applications/Little Snitch.app/Contents/Components/littlesnitch"
)
SHA256_IDENTIFIER_PREFIX = "identifier.SHA256/"


def target_user() -> str | None:
    return os.environ.get("SUDO_USER") or os.environ.get("USER")


def target_home() -> Path:
    sudo_user = os.environ.get("SUDO_USER")
    if sudo_user and (Path("/Users") / sudo_user).exists():
        return Path("/Users") / sudo_user
    return Path.home()


@dataclass(frozen=True)
class Candidate:
    path: str
    package_key: str
    suffix_key: str
    basename_key: str


def store_parts(path: str) -> tuple[str, str, str] | None:
    match = STORE_PATH_RE.match(path)
    if match is None:
        return None

    store_name = match.group(1)
    suffix = match.group(2) or ""
    package = VERSION_RE.match(store_name)
    package_key = package.group("name") if package else store_name
    return store_name, package_key, suffix


def suffix_key(suffix: str) -> str:
    parts = [part for part in suffix.split("/") if part]
    if "Contents" in parts:
        content_index = parts.index("Contents")
        if content_index > 0 and parts[content_index - 1].endswith(".app"):
            return "/".join(parts[content_index - 1 :])
        if ".app" in "/".join(parts):
            app_indices = [i for i, part in enumerate(parts) if part.endswith(".app")]
            return "/".join(parts[app_indices[-1] :])

    if len(parts) >= 2 and parts[-2] in {"bin", "sbin"}:
        return "/".join(parts[-2:])

    return "/".join(parts[-4:])


def basename_key(path: str) -> str:
    parts = store_parts(path)
    if parts is None:
        return ""
    return f"{parts[1]}:{Path(path).name}"


def sha256_identifier(value: str) -> str | None:
    if not value.startswith(SHA256_IDENTIFIER_PREFIX):
        return None

    digest = value.removeprefix(SHA256_IDENTIFIER_PREFIX)
    return digest.lower() if re.fullmatch(r"[0-9a-fA-F]{64}", digest) else None


def path_identifier(path: str) -> str | None:
    digest = sha256_file(path)
    return f"{SHA256_IDENTIFIER_PREFIX}{digest}" if digest is not None else None


def sha256_file(path: str) -> str | None:
    try:
        with Path(path).open("rb") as handle:
            hasher = hashlib.sha256()
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                hasher.update(chunk)
    except OSError:
        return None
    return hasher.hexdigest()


def wrapper_exec_target(path: Path) -> str | None:
    try:
        with path.open("rb") as handle:
            first_line = handle.readline()
            if not first_line.startswith(b"#!"):
                return None
            lines = [
                line.decode("utf-8", errors="ignore") for line in handle.readlines(4096)
            ]
    except OSError:
        return None

    for line in lines[:8]:
        match = EXEC_WRAPPER_RE.match(line)
        if match is None:
            continue
        try:
            words = shlex.split(match.group(1))
        except ValueError:
            continue
        if not words:
            continue
        target = words[0]
        if target.startswith("/nix/store/") and Path(target).exists():
            return target
    return None


def canonical_executable(path: Path) -> str:
    target = wrapper_exec_target(path)
    return target if target is not None else str(path)


def profile_roots() -> list[Path]:
    roots: list[Path] = []
    user = target_user()
    home = target_home()
    roots.extend(
        [
            home / ".nix-profile",
            Path("/run/current-system/sw"),
        ]
    )
    if user:
        roots.append(Path("/etc/profiles/per-user") / user)

    for profile in os.environ.get("NIX_PROFILES", "").split():
        roots.append(Path(profile))

    seen: set[Path] = set()
    result: list[Path] = []
    for root in roots:
        if root in seen or not root.exists():
            continue
        seen.add(root)
        result.append(root)
    return result


def closure_roots(roots: list[Path]) -> list[Path]:
    nix_store = shutil.which("nix-store")
    if nix_store is None:
        return []

    paths: list[Path] = []
    for root in roots:
        try:
            completed = subprocess.run(
                [nix_store, "-qR", str(root)],
                check=False,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
            )
        except OSError:
            continue
        if completed.returncode != 0:
            continue
        for line in completed.stdout.splitlines():
            if line.startswith("/nix/store/"):
                paths.append(Path(line))

    seen: set[Path] = set()
    result: list[Path] = []
    for path in paths:
        if path in seen or not path.exists():
            continue
        seen.add(path)
        result.append(path)
    return result


def resolve_existing(path: Path) -> str | None:
    try:
        resolved = path.resolve(strict=True)
    except OSError:
        return None
    value = str(resolved)
    return value if value.startswith("/nix/store/") else None


def executable_paths_in_app(app: Path) -> list[Path]:
    executables: list[Path] = []
    macos = app / "Contents" / "MacOS"
    if macos.is_dir():
        for child in macos.iterdir():
            if child.is_file():
                executables.append(child)

    frameworks = app / "Contents" / "Frameworks"
    if frameworks.is_dir():
        for helper in frameworks.rglob("*.app/Contents/MacOS/*"):
            if helper.is_file():
                executables.append(helper)
    return executables


def application_replacement(suffix: str) -> Path | None:
    parts = [part for part in suffix.split("/") if part]
    app_indices = [index for index, part in enumerate(parts) if part.endswith(".app")]
    if not app_indices:
        return None

    app_parts = parts[app_indices[0] :]
    replacement = Path("/Applications").joinpath(*app_parts)
    if replacement.exists():
        return replacement

    try:
        versions_index = app_parts.index("Versions")
    except ValueError:
        return None
    if versions_index + 2 > len(app_parts):
        return None

    versions_dir = Path("/Applications").joinpath(*app_parts[: versions_index + 1])
    suffix_parts = app_parts[versions_index + 2 :]
    try:
        replacements = {
            candidate.joinpath(*suffix_parts).resolve()
            for candidate in versions_dir.iterdir()
            if candidate.joinpath(*suffix_parts).exists()
        }
    except OSError:
        return None
    return next(iter(replacements)) if len(replacements) == 1 else None


def discover_candidates(extra_paths: set[str]) -> list[Candidate]:
    paths: set[str] = set()
    mapped_paths: dict[str, str] = {}
    manual_candidates: list[Candidate] = []
    roots = profile_roots()
    closures = closure_roots(roots)

    def add_path(path: Path) -> None:
        source = str(path)
        paths.add(source)
        mapped_paths[source] = canonical_executable(path)

    for root in roots:
        for subdir in ("bin", "sbin"):
            directory = root / subdir
            if directory.is_dir():
                for child in directory.iterdir():
                    resolved = resolve_existing(child)
                    if resolved:
                        add_path(Path(resolved))

        applications = root / "Applications"
        if applications.is_dir():
            for app in applications.rglob("*.app"):
                for executable in executable_paths_in_app(app):
                    resolved = resolve_existing(executable)
                    if resolved:
                        add_path(Path(resolved))

    for store_root in closures:
        for subdir in ("bin", "sbin"):
            directory = store_root / subdir
            if directory.is_dir():
                for child in directory.iterdir():
                    if child.is_file():
                        add_path(child)

        applications = store_root / "Applications"
        if applications.is_dir():
            for app in applications.rglob("*.app"):
                for executable in executable_paths_in_app(app):
                    add_path(executable)

    for old_path in extra_paths:
        parts = store_parts(old_path)
        if parts is None:
            continue
        _, package_key, suffix = parts
        app_replacement = application_replacement(suffix)
        if app_replacement is not None:
            manual_candidates.append(
                Candidate(
                    path=str(app_replacement),
                    package_key=package_key,
                    suffix_key=suffix_key(suffix),
                    basename_key=basename_key(old_path),
                )
            )

        for match in closures:
            match_parts = store_parts(str(match))
            if match_parts is None or match_parts[1] != package_key:
                continue
            replacement = match / suffix.lstrip("/")
            if replacement.exists():
                add_path(replacement)

    candidates = []
    for path in sorted(paths):
        parts = store_parts(path)
        if parts is None:
            continue
        _, package_key, suffix = parts
        candidates.append(
            Candidate(
                path=mapped_paths.get(path, path),
                package_key=package_key,
                suffix_key=suffix_key(suffix),
                basename_key=basename_key(path),
            )
        )
    return candidates + manual_candidates


def replacement_indexes(
    candidates: list[Candidate],
) -> tuple[dict[tuple[str, str], str], dict[str, str], dict[str, str]]:
    exact: dict[tuple[str, str], list[Candidate]] = defaultdict(list)
    basename: dict[str, list[Candidate]] = defaultdict(list)
    suffix: dict[str, list[Candidate]] = defaultdict(list)

    for candidate in candidates:
        exact[(candidate.package_key, candidate.suffix_key)].append(candidate)
        basename[candidate.basename_key].append(candidate)
        suffix[candidate.suffix_key].append(candidate)

    def preferred(values: list[Candidate]) -> str | None:
        unique = {item.path for item in values}
        if len(unique) != 1:
            return None
        candidate = values[0]
        return candidate.path

    exact_index = {
        key: replacement
        for key, values in exact.items()
        if (replacement := preferred(values)) is not None
    }
    basename_index = {
        key: replacement
        for key, values in basename.items()
        if (replacement := preferred(values)) is not None
    }
    suffix_index = {
        key: replacement
        for key, values in suffix.items()
        if (replacement := preferred(values)) is not None
    }
    return exact_index, basename_index, suffix_index


def collect_nix_paths(value: Any, paths: set[str]) -> None:
    if isinstance(value, dict):
        for child in value.values():
            collect_nix_paths(child, paths)
    elif isinstance(value, list):
        for child in value:
            collect_nix_paths(child, paths)
    elif isinstance(value, str) and value.startswith("/nix/store/"):
        paths.add(value)


def rule_help_paths(rule: dict[str, Any]) -> dict[str, str]:
    help_text = rule.get("factoryHelpText")
    if not isinstance(help_text, str):
        return {}

    paths: dict[str, str] = {}
    for line in help_text.splitlines():
        key, separator, value = line.partition(": ")
        if not separator:
            continue
        rule_key = HELP_PATH_REPLACEMENTS.get(key)
        if rule_key is not None and value.startswith("/nix/store/"):
            paths[rule_key] = value
    return paths


def code_identifier_last_seen_path(model: dict[str, Any], digest: str) -> str | None:
    last_seen = model.get("lastSeenExecutableByCodeIdentifier")
    if not isinstance(last_seen, dict):
        return None

    for key in (
        f"{SHA256_IDENTIFIER_PREFIX}{digest}",
        f"{SHA256_IDENTIFIER_PREFIX}{digest.upper()}",
        f"SHA256/{digest}",
        f"SHA256/{digest.upper()}",
        digest,
    ):
        value = last_seen.get(key)
        if isinstance(value, str) and value.startswith("/nix/store/"):
            return value
    return None


def code_requirement_path(model: dict[str, Any], digest: str) -> str | None:
    code_requirements = model.get("codeRequirements")
    if not isinstance(code_requirements, dict):
        return None

    for path, requirement in code_requirements.items():
        if not isinstance(path, str) or not isinstance(requirement, dict):
            continue
        if path.startswith("/nix/store/") and requirement.get("type") == "fileHash":
            code_identifier = requirement.get("codeIdentifier")
            if isinstance(code_identifier, str) and code_identifier.lower() == digest:
                return path
    return None


def identifier_path(model: dict[str, Any], value: str) -> str | None:
    digest = sha256_identifier(value)
    if digest is None:
        return None

    return code_identifier_last_seen_path(model, digest) or code_requirement_path(
        model, digest
    )


def collect_rule_reference_paths(model: dict[str, Any]) -> set[str]:
    paths: set[str] = set()
    collect_nix_paths(model.get("rules", []), paths)
    for rule in model.get("rules", []):
        if not isinstance(rule, dict):
            continue
        for key in ("process", "via"):
            value = rule.get(key)
            if not isinstance(value, str):
                continue
            path = identifier_path(model, value)
            if path is not None:
                paths.add(path)
        paths.update(rule_help_paths(rule).values())
    return paths


def rewrite_help_text(text: str, replacements: dict[str, str]) -> str:
    for rule_key, help_key in HELP_REPLACEMENTS.items():
        old = replacements.get(rule_key)
        if old is None:
            continue
        pattern = re.compile(rf"^{re.escape(help_key)}: .*$", re.MULTILINE)
        text = pattern.sub(f"{help_key}: {old}", text)
    return text


def path_replacement(
    value: str,
    exact_index: dict[tuple[str, str], str],
    basename_index: dict[str, str],
    suffix_index: dict[str, str],
) -> str | None:
    parts = store_parts(value)
    if parts is None:
        return None
    _, package_key, suffix = parts
    replacement = exact_index.get((package_key, suffix_key(suffix)))
    if replacement is None:
        replacement = basename_index.get(basename_key(value))
    if replacement is None:
        replacement = suffix_index.get(suffix_key(suffix))
    return replacement


def rewrite_rule(
    model: dict[str, Any],
    rule: dict[str, Any],
    exact_index: dict[tuple[str, str], str],
    basename_index: dict[str, str],
    suffix_index: dict[str, str],
) -> tuple[dict[str, Any], dict[str, str], dict[str, str]]:
    updated = dict(rule)
    replacements: dict[str, str] = {}
    identifier_replacements: dict[str, str] = {}
    help_paths = rule_help_paths(rule)

    for key in ("process", "via"):
        value = updated.get(key)
        if not isinstance(value, str):
            continue

        replacement = path_replacement(value, exact_index, basename_index, suffix_index)
        if replacement is not None and replacement != value:
            updated[key] = replacement
            replacements[key] = replacement
            continue

        old_path = identifier_path(model, value) or help_paths.get(key)
        if old_path is None:
            continue
        replacement = path_replacement(
            old_path, exact_index, basename_index, suffix_index
        )
        if replacement is None:
            continue
        replacement_identifier = path_identifier(replacement)
        if replacement_identifier is not None:
            updated[key] = replacement
            replacements[key] = replacement
            identifier_replacements[key] = replacement_identifier

    if replacements and isinstance(updated.get("factoryHelpText"), str):
        updated["factoryHelpText"] = rewrite_help_text(
            updated["factoryHelpText"], replacements
        )

    return updated, replacements, identifier_replacements


def file_hash_requirement(path: str) -> dict[str, str] | None:
    digest = sha256_file(path)
    if digest is None:
        return None

    return {
        "codeIdentifier": digest,
        "type": "fileHash",
    }


def code_identifier_key(requirement: dict[str, Any]) -> str | None:
    requirement_type = requirement.get("type")
    code_identifier = requirement.get("codeIdentifier")
    if not isinstance(requirement_type, str) or not isinstance(code_identifier, str):
        return None

    if requirement_type == "fileHash":
        return f"SHA256/{code_identifier}"
    if requirement_type == "trustedAnchor":
        author_identifier = requirement.get("authorIdentifier")
        if isinstance(author_identifier, str):
            return f"{author_identifier}/{code_identifier}"
    return None


def add_code_requirement(model: dict[str, Any], path: str) -> bool:
    requirement = file_hash_requirement(path)
    if requirement is None:
        return False

    code_requirements = model.setdefault("codeRequirements", {})
    if not isinstance(code_requirements, dict):
        return False
    code_requirements[path] = requirement

    identifier = code_identifier_key(requirement)
    last_seen = model.setdefault("lastSeenExecutableByCodeIdentifier", {})
    if identifier is not None and isinstance(last_seen, dict):
        last_seen[identifier] = path
        if identifier.startswith("SHA256/"):
            digest = identifier.removeprefix("SHA256/")
            last_seen[f"{SHA256_IDENTIFIER_PREFIX}{digest}"] = path

    return True


def nix_rule_paths(rule: dict[str, Any]) -> set[str]:
    paths: set[str] = set()
    for key in ("process", "via"):
        value = rule.get(key)
        if isinstance(value, str) and value.startswith("/nix/store/"):
            paths.add(value)
    return paths


def needs_code_requirement(model: dict[str, Any], path: str) -> bool:
    if not Path(path).exists():
        return False

    code_requirements = model.get("codeRequirements")
    if not isinstance(code_requirements, dict):
        return True

    requirement = code_requirements.get(path)
    return not isinstance(requirement, dict) or requirement.get("type") == "none"


def is_expired_temporary_rule(rule: dict[str, Any]) -> bool:
    def contains_expired_temporary(value: Any) -> bool:
        if value == "expiredTemporary":
            return True
        if isinstance(value, dict):
            return any(contains_expired_temporary(child) for child in value.values())
        if isinstance(value, list):
            return any(contains_expired_temporary(child) for child in value)
        return False

    return contains_expired_temporary(rule)


def unresolved_rule_reference(
    model: dict[str, Any],
    rule: dict[str, Any],
    key: str,
    value: str,
) -> str | None:
    if value.startswith("/nix/store/"):
        parts = store_parts(value)
        if parts is not None and not Path(value).exists():
            return value
        return None

    path = identifier_path(model, value) or rule_help_paths(rule).get(key)
    if path is None:
        return None
    parts = store_parts(path)
    if parts is not None and not Path(path).exists():
        return f"{value} -> {path}"
    return None


def repair_model(
    model: dict[str, Any],
) -> tuple[dict[str, Any], Counter[str], list[str]]:
    old_paths = collect_rule_reference_paths(model)
    candidates = discover_candidates(old_paths)
    exact_index, basename_index, suffix_index = replacement_indexes(candidates)

    stats: Counter[str] = Counter()
    unresolved: set[str] = set()
    rewritten_rules = []
    rule_paths: set[str] = set()
    for rule in model.get("rules", []):
        if not isinstance(rule, dict):
            rewritten_rules.append(rule)
            continue
        if is_expired_temporary_rule(rule):
            stats["expired_temporary_pruned"] += 1
            continue

        updated, replacements, identifier_replacements = rewrite_rule(
            model, rule, exact_index, basename_index, suffix_index
        )
        stats["path_replacements"] += len(replacements)
        stats["identifier_replacements"] += len(identifier_replacements)
        rule_paths.update(nix_rule_paths(updated))
        rule_paths.update(replacements.values())
        for key in ("process", "via"):
            value = rule.get(key)
            if not isinstance(value, str) or key in replacements:
                continue
            unresolved_reference = unresolved_rule_reference(model, rule, key, value)
            if unresolved_reference is not None:
                unresolved.add(unresolved_reference)
        rewritten_rules.append(updated)

    repaired = dict(model)
    repaired["rules"] = rewritten_rules
    if isinstance(model.get("codeRequirements"), dict):
        repaired["codeRequirements"] = dict(model["codeRequirements"])
    if isinstance(model.get("lastSeenExecutableByCodeIdentifier"), dict):
        repaired["lastSeenExecutableByCodeIdentifier"] = dict(
            model["lastSeenExecutableByCodeIdentifier"]
        )
    for path in sorted(rule_paths):
        if needs_code_requirement(repaired, path) and add_code_requirement(
            repaired, path
        ):
            stats["code_requirements"] += 1
    stats["rules"] = len(rewritten_rules)
    stats["candidates"] = len(candidates)
    return repaired, stats, sorted(unresolved)


def littlesnitch_command(cli: Path) -> str:
    if cli.exists() and os.access(cli, os.X_OK):
        return str(cli)
    raise SystemExit(f"littlesnitch command not found at {cli}")


def load_model(path: Path | None, cli: Path) -> dict[str, Any]:
    if path is not None:
        with path.open() as handle:
            return json.load(handle)

    completed = subprocess.run(
        [littlesnitch_command(cli), "export-model"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return json.loads(completed.stdout)


def write_model(path: Path, model: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as handle:
        json.dump(model, handle, indent=2, sort_keys=True)
        handle.write("\n")


def restore_model(path: Path, cli: Path) -> None:
    subprocess.run(
        [
            littlesnitch_command(cli),
            "restore-model",
            "--preserve-terminal-access",
            str(path),
        ],
        check=True,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Rewrite Little Snitch Nix store rules to the active Nix package paths.",
    )
    parser.add_argument(
        "--input",
        type=Path,
        help="Read a model export instead of running littlesnitch export-model.",
    )
    parser.add_argument(
        "--output", type=Path, help="Write the repaired model to this path."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Restore the repaired model with littlesnitch restore-model.",
    )
    parser.add_argument(
        "--allow-unresolved",
        action="store_true",
        help="Apply even if stale Nix paths or identifiers could not be mapped.",
    )
    parser.add_argument(
        "--littlesnitch-cli",
        type=Path,
        default=LITTLESNITCH_CLI,
        help=f"Little Snitch CLI path. Defaults to {LITTLESNITCH_CLI}.",
    )
    parser.add_argument(
        "--unresolved",
        action="store_true",
        help="Print stale Nix paths that could not be mapped.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    model = load_model(args.input, args.littlesnitch_cli)
    repaired, stats, unresolved = repair_model(model)

    output = args.output
    if output is None:
        output = (
            target_home()
            / "Library"
            / "Application Support"
            / "LittleSnitchNixRules"
            / "repaired-model.json"
        )

    write_model(output, repaired)

    print(f"rules: {stats['rules']}")
    print(f"candidate executables: {stats['candidates']}")
    print(f"path replacements: {stats['path_replacements']}")
    print(f"identifier replacements: {stats['identifier_replacements']}")
    print(f"code requirements updated: {stats['code_requirements']}")
    print(f"expired temporary rules pruned: {stats['expired_temporary_pruned']}")
    print(f"unresolved stale paths: {len(unresolved)}")
    print(f"repaired model: {output}")

    if args.unresolved and unresolved:
        for path in unresolved:
            print(path)

    if args.apply:
        if unresolved and not args.allow_unresolved:
            print(
                "refusing to apply with unresolved stale paths; "
                "pass --allow-unresolved to override"
            )
            return 1
        backup = (
            output.parent
            / "backups"
            / f"model-{datetime.now(timezone.utc):%Y%m%dT%H%M%SZ}.json"
        )
        write_model(backup, model)
        print(f"original model backup: {backup}")
        restore_model(output, args.littlesnitch_cli)
        print("restored repaired Little Snitch model")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
