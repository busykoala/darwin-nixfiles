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

STORE_RE = re.compile(r"^/nix/store/[0-9a-z]{32}-([^/]+)(/.*)?$")
VERSION_RE = re.compile(r"^(?P<name>.+?)-[0-9][A-Za-z0-9._+~-]*$")
SHA_RE = re.compile(r"^[0-9a-fA-F]{64}$")
EXEC_RE = re.compile(r"^\s*exec\s+(.+)$")
SHA_ID_PREFIX = "identifier.SHA256/"
RULE_FIELDS = ("process", "via")
HELP_KEYS = {"process": "processPath", "via": "viaProcessPath"}
HELP_FIELDS = {v: k for k, v in HELP_KEYS.items()}
LITTLESNITCH_CLI = Path(
    "/Applications/Little Snitch.app/Contents/Components/littlesnitch"
)


@dataclass(frozen=True)
class StorePath:
    store_name: str
    package: str
    suffix: str

    @property
    def suffix_key(self) -> str:
        return suffix_key(self.suffix)

    @property
    def basename_key(self) -> str:
        return f"{self.package}:{Path(self.suffix).name}"


@dataclass(frozen=True)
class Candidate:
    path: str
    package: str
    suffix_key: str
    basename_key: str


@dataclass(frozen=True)
class Resolver:
    exact: dict[tuple[str, str], str]
    basename: dict[str, str]
    suffix: dict[str, str]

    def resolve(self, old_path: str) -> str | None:
        parsed = parse_store_path(old_path)
        if parsed is None:
            return None
        return (
            self.exact.get((parsed.package, parsed.suffix_key))
            or self.basename.get(parsed.basename_key)
            or self.suffix.get(parsed.suffix_key)
        )


def user_name() -> str | None:
    return os.environ.get("SUDO_USER") or os.environ.get("USER")


def home_dir() -> Path:
    sudo_user = os.environ.get("SUDO_USER")
    if sudo_user and (Path("/Users") / sudo_user).exists():
        return Path("/Users") / sudo_user
    return Path.home()


def parse_store_path(path: str) -> StorePath | None:
    match = STORE_RE.match(path)
    if match is None:
        return None
    store_name = match.group(1)
    package_match = VERSION_RE.match(store_name)
    package = package_match.group("name") if package_match else store_name
    return StorePath(store_name, package, match.group(2) or "")


def suffix_key(suffix: str) -> str:
    parts = [part for part in suffix.split("/") if part]
    app_indices = [index for index, part in enumerate(parts) if part.endswith(".app")]
    if app_indices:
        return "/".join(parts[app_indices[-1] :])
    if len(parts) >= 2 and parts[-2] in {"bin", "sbin"}:
        return "/".join(parts[-2:])
    return "/".join(parts[-4:])


def unique_existing(paths: list[Path]) -> list[Path]:
    seen: set[Path] = set()
    result: list[Path] = []
    for path in paths:
        if path.exists() and path not in seen:
            seen.add(path)
            result.append(path)
    return result


def profile_roots() -> list[Path]:
    roots = [home_dir() / ".nix-profile", Path("/run/current-system/sw")]
    if user := user_name():
        roots.append(Path("/etc/profiles/per-user") / user)
    roots.extend(Path(path) for path in os.environ.get("NIX_PROFILES", "").split())
    return unique_existing(roots)


def find_executable(name: str, fallbacks: tuple[str, ...] = ()) -> str | None:
    if found := shutil.which(name):
        return found
    return next((path for path in fallbacks if os.access(path, os.X_OK)), None)


def closure_roots(roots: list[Path]) -> list[Path]:
    nix_store = find_executable(
        "nix-store",
        (
            "/run/current-system/sw/bin/nix-store",
            "/nix/var/nix/profiles/default/bin/nix-store",
        ),
    )
    if nix_store is None:
        return []

    paths: list[Path] = []
    for root in roots:
        try:
            result = subprocess.run(
                [nix_store, "-qR", str(root)],
                check=False,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
            )
        except OSError:
            continue
        if result.returncode == 0:
            paths.extend(
                Path(line)
                for line in result.stdout.splitlines()
                if line.startswith("/nix/store/")
            )
    return unique_existing(paths)


def resolved_store_path(path: Path) -> str | None:
    try:
        value = str(path.resolve(strict=True))
    except OSError:
        return None
    return value if value.startswith("/nix/store/") else None


def wrapper_target(path: Path) -> str | None:
    try:
        with path.open("rb") as handle:
            if not handle.readline().startswith(b"#!"):
                return None
            lines = [
                line.decode("utf-8", errors="ignore") for line in handle.readlines(4096)
            ]
    except OSError:
        return None

    for line in lines[:8]:
        match = EXEC_RE.match(line)
        if match is None:
            continue
        try:
            words = shlex.split(match.group(1))
        except ValueError:
            continue
        if words and words[0].startswith("/nix/store/") and Path(words[0]).exists():
            return words[0]
    return None


def canonical_executable(path: Path) -> str:
    return wrapper_target(path) or str(path)


def app_executables(app: Path) -> list[Path]:
    result: list[Path] = []
    macos = app / "Contents" / "MacOS"
    if macos.is_dir():
        result.extend(child for child in macos.iterdir() if child.is_file())
    frameworks = app / "Contents" / "Frameworks"
    if frameworks.is_dir():
        result.extend(
            path
            for path in frameworks.rglob("*.app/Contents/MacOS/*")
            if path.is_file()
        )
    return result


def current_app_path(old_suffix: str) -> Path | None:
    parts = [part for part in old_suffix.split("/") if part]
    app_indices = [index for index, part in enumerate(parts) if part.endswith(".app")]
    if not app_indices:
        return None

    app_parts = parts[app_indices[0] :]
    direct = Path("/Applications").joinpath(*app_parts)
    if direct.exists():
        return direct

    try:
        version_index = app_parts.index("Versions")
    except ValueError:
        return None
    if version_index + 2 > len(app_parts):
        return None

    versions_dir = Path("/Applications").joinpath(*app_parts[: version_index + 1])
    trailing = app_parts[version_index + 2 :]
    try:
        matches = {
            candidate.joinpath(*trailing).resolve()
            for candidate in versions_dir.iterdir()
            if candidate.joinpath(*trailing).exists()
        }
    except OSError:
        return None
    return next(iter(matches)) if len(matches) == 1 else None


def discover_candidates(old_paths: set[str]) -> list[Candidate]:
    roots = profile_roots()
    closures = closure_roots(roots)
    paths: dict[str, str] = {}
    manual: list[Candidate] = []

    def add(path: Path) -> None:
        paths[str(path)] = canonical_executable(path)

    def add_app_tree(root: Path, resolve_symlinks: bool) -> None:
        applications = root / "Applications"
        if not applications.is_dir():
            return
        for app in applications.rglob("*.app"):
            for executable in app_executables(app):
                if resolve_symlinks:
                    if resolved := resolved_store_path(executable):
                        add(Path(resolved))
                else:
                    add(executable)

    for root in roots:
        for subdir in ("bin", "sbin"):
            directory = root / subdir
            if directory.is_dir():
                for child in directory.iterdir():
                    if resolved := resolved_store_path(child):
                        add(Path(resolved))
        add_app_tree(root, resolve_symlinks=True)

    for closure in closures:
        for subdir in ("bin", "sbin"):
            directory = closure / subdir
            if directory.is_dir():
                for child in directory.iterdir():
                    if child.is_file():
                        add(child)
        add_app_tree(closure, resolve_symlinks=False)

    for old_path in old_paths:
        old = parse_store_path(old_path)
        if old is None:
            continue
        if app_path := current_app_path(old.suffix):
            manual.append(
                Candidate(str(app_path), old.package, old.suffix_key, old.basename_key)
            )
        for closure in closures:
            current = parse_store_path(str(closure))
            if current is None or current.package != old.package:
                continue
            replacement = closure / old.suffix.lstrip("/")
            if replacement.exists():
                add(replacement)

    result: list[Candidate] = []
    for source, canonical in sorted(paths.items()):
        parsed = parse_store_path(source)
        if parsed is not None:
            result.append(
                Candidate(
                    canonical, parsed.package, parsed.suffix_key, parsed.basename_key
                )
            )
    return result + manual


def resolver_from(candidates: list[Candidate]) -> Resolver:
    exact: dict[tuple[str, str], list[str]] = defaultdict(list)
    basename: dict[str, list[str]] = defaultdict(list)
    suffix: dict[str, list[str]] = defaultdict(list)
    for candidate in candidates:
        exact[(candidate.package, candidate.suffix_key)].append(candidate.path)
        basename[candidate.basename_key].append(candidate.path)
        suffix[candidate.suffix_key].append(candidate.path)

    def unique(groups: dict[Any, list[str]]) -> dict[Any, str]:
        return {
            key: next(iter(values))
            for key, values in ((k, set(v)) for k, v in groups.items())
            if len(values) == 1
        }

    return Resolver(unique(exact), unique(basename), unique(suffix))


def sha_from_identifier(value: str) -> str | None:
    if not value.startswith(SHA_ID_PREFIX):
        return None
    digest = value.removeprefix(SHA_ID_PREFIX)
    return digest.lower() if SHA_RE.fullmatch(digest) else None


def sha256_file(path: str) -> str | None:
    try:
        with Path(path).open("rb") as handle:
            hasher = hashlib.sha256()
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                hasher.update(chunk)
    except OSError:
        return None
    return hasher.hexdigest()


def help_refs(rule: dict[str, Any]) -> dict[str, str]:
    text = rule.get("factoryHelpText")
    if not isinstance(text, str):
        return {}

    result: dict[str, str] = {}
    for line in text.splitlines():
        key, sep, value = line.partition(": ")
        if sep and (field := HELP_FIELDS.get(key)):
            result[field] = value
    return result


def rewrite_help_text(text: str, replacements: dict[str, str]) -> str:
    for field, replacement in replacements.items():
        key = HELP_KEYS[field]
        text = re.sub(
            rf"^{re.escape(key)}: .*$",
            f"{key}: {replacement}",
            text,
            flags=re.MULTILINE,
        )
    return text


def path_for_sha(model: dict[str, Any], digest: str) -> str | None:
    last_seen = model.get("lastSeenExecutableByCodeIdentifier")
    if isinstance(last_seen, dict):
        for key in (
            f"{SHA_ID_PREFIX}{digest}",
            f"{SHA_ID_PREFIX}{digest.upper()}",
            f"SHA256/{digest}",
            f"SHA256/{digest.upper()}",
            digest,
        ):
            value = last_seen.get(key)
            if isinstance(value, str) and value.startswith("/nix/store/"):
                return value

    requirements = model.get("codeRequirements")
    if isinstance(requirements, dict):
        for path, requirement in requirements.items():
            if not isinstance(path, str) or not path.startswith("/nix/store/"):
                continue
            if (
                isinstance(requirement, dict)
                and str(requirement.get("codeIdentifier", "")).lower() == digest
            ):
                return path
    return None


def referenced_nix_path(model: dict[str, Any], value: str) -> str | None:
    if value.startswith("/nix/store/"):
        return value
    digest = sha_from_identifier(value)
    return path_for_sha(model, digest) if digest else None


def collect_referenced_paths(model: dict[str, Any]) -> set[str]:
    paths: set[str] = set()
    for rule in model.get("rules", []):
        if not isinstance(rule, dict):
            continue
        refs = help_refs(rule)
        for field in RULE_FIELDS:
            for value in (rule.get(field), refs.get(field)):
                if isinstance(value, str) and (
                    path := referenced_nix_path(model, value)
                ):
                    paths.add(path)
    return paths


def file_hash_requirement(path: str) -> dict[str, str] | None:
    digest = sha256_file(path)
    return {"codeIdentifier": digest, "type": "fileHash"} if digest else None


def code_identifier_key(requirement: dict[str, Any]) -> str | None:
    kind = requirement.get("type")
    code_id = requirement.get("codeIdentifier")
    if not isinstance(kind, str) or not isinstance(code_id, str):
        return None
    if kind == "fileHash":
        return f"SHA256/{code_id}"
    if kind == "trustedAnchor" and isinstance(requirement.get("authorIdentifier"), str):
        return f"{requirement['authorIdentifier']}/{code_id}"
    return None


def add_code_requirement(model: dict[str, Any], path: str) -> bool:
    requirement = file_hash_requirement(path)
    if requirement is None:
        return False

    requirements = model.setdefault("codeRequirements", {})
    if not isinstance(requirements, dict):
        return False
    requirements[path] = requirement

    last_seen = model.setdefault("lastSeenExecutableByCodeIdentifier", {})
    if isinstance(last_seen, dict) and (identifier := code_identifier_key(requirement)):
        last_seen[identifier] = path
        if identifier.startswith("SHA256/"):
            last_seen[f"{SHA_ID_PREFIX}{identifier.removeprefix('SHA256/')}"] = path
    return True


def needs_code_requirement(model: dict[str, Any], path: str) -> bool:
    if not path.startswith("/nix/store/") or not Path(path).exists():
        return False
    requirements = model.get("codeRequirements")
    if not isinstance(requirements, dict):
        return True
    existing = requirements.get(path)
    return not isinstance(existing, dict) or existing.get("type") == "none"


def prune_empty_code_requirements(model: dict[str, Any], referenced: set[str]) -> int:
    requirements = model.get("codeRequirements")
    if not isinstance(requirements, dict):
        return 0
    stale = [
        path
        for path, requirement in requirements.items()
        if isinstance(path, str)
        and path.startswith("/nix/store/")
        and path not in referenced
        and isinstance(requirement, dict)
        and requirement.get("type") == "none"
    ]
    for path in stale:
        del requirements[path]
    return len(stale)


def contains(value: Any, wanted: Any) -> bool:
    if value == wanted:
        return True
    if isinstance(value, dict):
        return any(contains(child, wanted) for child in value.values())
    if isinstance(value, list):
        return any(contains(child, wanted) for child in value)
    return False


def drop_reason(rule: dict[str, Any]) -> str | None:
    if contains(rule, "expiredTemporary"):
        return "expired_temporary_pruned"
    if rule.get("action") == "suggestion" and rule.get("approved") is False:
        text = "\n".join(
            value
            for field in (*RULE_FIELDS, "factoryHelpText")
            if isinstance((value := rule.get(field)), str)
        )
        if (
            "systems.determinate.determinate-nixd" in text
            or "cf.install.determinate.systems" in text
        ):
            return "unapproved_determinate_suggestions_pruned"
    return None


def replacement_for(
    model: dict[str, Any], value: str, resolver: Resolver
) -> tuple[str | None, str | None]:
    if value.startswith("/nix/store/"):
        replacement = resolver.resolve(value)
        return (
            (replacement, "path_replacements")
            if replacement and replacement != value
            else (None, None)
        )

    if sha_from_identifier(value) is None:
        return None, None
    old_path = referenced_nix_path(model, value)
    replacement = resolver.resolve(old_path) if old_path else None
    return (replacement, "sha_identifier_replacements") if replacement else (None, None)


def rewrite_rule(
    model: dict[str, Any], rule: dict[str, Any], resolver: Resolver
) -> tuple[dict[str, Any], Counter[str], set[str]]:
    updated = dict(rule)
    stats: Counter[str] = Counter()
    paths: set[str] = set()
    refs = help_refs(rule)
    help_updates: dict[str, str] = {}

    for field in RULE_FIELDS:
        value = updated.get(field)
        if not isinstance(value, str):
            continue

        replacement, stat = replacement_for(model, value, resolver)
        if replacement is None and sha_from_identifier(value) is not None:
            help_value = refs.get(field)
            if isinstance(help_value, str) and (
                old_path := referenced_nix_path(model, help_value)
            ):
                replacement = resolver.resolve(old_path)
                stat = "sha_identifier_replacements" if replacement else None

        if replacement and stat:
            updated[field] = replacement
            help_updates[field] = replacement
            paths.add(replacement)
            stats[stat] += 1

    if help_updates and isinstance(updated.get("factoryHelpText"), str):
        updated["factoryHelpText"] = rewrite_help_text(
            updated["factoryHelpText"], help_updates
        )
    return updated, stats, paths


def rule_paths(rule: dict[str, Any]) -> set[str]:
    return {
        value
        for field in RULE_FIELDS
        if isinstance((value := rule.get(field)), str)
        and value.startswith("/nix/store/")
    }


def unresolved_ref(
    model: dict[str, Any], rule: dict[str, Any], field: str, resolver: Resolver
) -> str | None:
    value = rule.get(field)
    if not isinstance(value, str):
        return None
    old_path = referenced_nix_path(model, value)
    if old_path is None or Path(old_path).exists() or resolver.resolve(old_path):
        return None
    return old_path if value.startswith("/nix/store/") else f"{value} -> {old_path}"


def repair_model(
    model: dict[str, Any],
) -> tuple[dict[str, Any], Counter[str], list[str]]:
    old_paths = collect_referenced_paths(model)
    candidates = discover_candidates(old_paths)
    resolver = resolver_from(candidates)

    repaired = dict(model)
    if isinstance(model.get("codeRequirements"), dict):
        repaired["codeRequirements"] = dict(model["codeRequirements"])
    if isinstance(model.get("lastSeenExecutableByCodeIdentifier"), dict):
        repaired["lastSeenExecutableByCodeIdentifier"] = dict(
            model["lastSeenExecutableByCodeIdentifier"]
        )

    stats: Counter[str] = Counter(candidates=len(candidates))
    unresolved: set[str] = set()
    repaired_rules: list[Any] = []
    referenced: set[str] = set()

    for rule in model.get("rules", []):
        if not isinstance(rule, dict):
            repaired_rules.append(rule)
            continue
        if reason := drop_reason(rule):
            stats[reason] += 1
            continue

        updated, rule_stats, rewritten_paths = rewrite_rule(model, rule, resolver)
        stats.update(rule_stats)
        referenced.update(rule_paths(updated))
        referenced.update(rewritten_paths)

        changed_fields = {
            field for field in RULE_FIELDS if updated.get(field) != rule.get(field)
        }
        for field in RULE_FIELDS:
            if field not in changed_fields and (
                missing := unresolved_ref(model, rule, field, resolver)
            ):
                unresolved.add(missing)
        repaired_rules.append(updated)

    repaired["rules"] = repaired_rules
    stats["stale_code_requirements_pruned"] = prune_empty_code_requirements(
        repaired, referenced
    )
    for path in sorted(referenced):
        if needs_code_requirement(repaired, path) and add_code_requirement(
            repaired, path
        ):
            stats["code_requirements"] += 1
    stats["rules"] = len(repaired_rules)
    return repaired, stats, sorted(unresolved)


def littlesnitch_command(cli: Path) -> str:
    if cli.exists() and os.access(cli, os.X_OK):
        return str(cli)
    raise SystemExit(f"littlesnitch command not found at {cli}")


def load_model(path: Path | None, cli: Path) -> dict[str, Any]:
    if path is not None:
        with path.open() as handle:
            return json.load(handle)
    result = subprocess.run(
        [littlesnitch_command(cli), "export-model"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return json.loads(result.stdout)


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


def default_output() -> Path:
    return (
        home_dir()
        / "Library"
        / "Application Support"
        / "LittleSnitchNixRules"
        / "repaired-model.json"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Rewrite Little Snitch Nix rules to active package paths."
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
        help="Apply even if stale references could not be mapped.",
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
        help="Print stale paths or SHA identifiers that could not be mapped.",
    )
    return parser.parse_args()


def print_stats(stats: Counter[str], unresolved: list[str], output: Path) -> None:
    labels = [
        ("rules", "rules"),
        ("candidate executables", "candidates"),
        ("path replacements", "path_replacements"),
        ("SHA256 identifier replacements", "sha_identifier_replacements"),
        ("code requirements updated", "code_requirements"),
        ("stale code requirements pruned", "stale_code_requirements_pruned"),
        ("expired temporary rules pruned", "expired_temporary_pruned"),
        (
            "unapproved Determinate suggestions pruned",
            "unapproved_determinate_suggestions_pruned",
        ),
    ]
    for label, key in labels:
        print(f"{label}: {stats[key]}")
    print(f"unresolved stale references: {len(unresolved)}")
    print(f"repaired model: {output}")


def main() -> int:
    args = parse_args()
    model = load_model(args.input, args.littlesnitch_cli)
    repaired, stats, unresolved = repair_model(model)
    output = args.output or default_output()
    write_model(output, repaired)
    print_stats(stats, unresolved, output)

    if args.unresolved:
        for item in unresolved:
            print(item)

    if not args.apply:
        return 0
    if unresolved and not args.allow_unresolved:
        print(
            "refusing to apply with unresolved stale references; pass --allow-unresolved to override"
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
