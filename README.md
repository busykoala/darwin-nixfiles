# Darwin Nixfiles

## Install nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Install brew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

brew is used to install GUI apps that are not available via nix packages.

## Setup

This repository contains nix-darwin configurations for two hosts:

- `Matthiass-MacBook-Air`
- `matthiass-macbook-pro`

Clone the repository to the expected path:

```bash
git clone git@github.com:busykoala/darwin-nixfiles.git ~/nixfiles
cd ~/nixfiles
```

Check the configuration:

```bash
make check
```

Apply the configuration for the current host:

```bash
make rebuild
```

`make rebuild` uses `hostname -s`, so the macOS short hostname must match one of
the flake outputs. Prefer this target for normal rebuilds because it also runs
post-rebuild maintenance such as Little Snitch Nix rule repair.

To switch explicitly without post-rebuild maintenance:

```bash
sudo -H darwin-rebuild switch --flake .#Matthiass-MacBook-Air
sudo -H darwin-rebuild switch --flake .#matthiass-macbook-pro
```

For the first bootstrap before `darwin-rebuild` is available:

```bash
sudo -H nix run .#darwin-rebuild -- switch --flake .#Matthiass-MacBook-Air
sudo -H nix run .#darwin-rebuild -- switch --flake .#matthiass-macbook-pro
```

## Services

### LanguageTool

A LanguageTool service is configured at `http://localhost:8081` to be used in e.g.
the browser extension.

## Little Snitch and Nix

Nix rebuilds change `/nix/store/...` paths, so Little Snitch rules that point at
Nix executables can become stale even when the application is conceptually the
same. This configuration installs `littlesnitch-nix-rules`, which repairs the
current Little Snitch model by remapping Nix store paths to the active Nix
profile closure.

The nix-darwin activation step runs the repair after a successful switch when
Little Snitch is installed. `make littlesnitch-rules` runs the same repair
manually.

Preview a repaired model:

```bash
sudo littlesnitch-nix-rules --unresolved
```

Apply the repaired model:

```bash
sudo littlesnitch-nix-rules --apply
```

`--apply` refuses to restore the model when stale Nix paths or SHA256
identifiers cannot be mapped to active executables. Use `--allow-unresolved`
only when you have reviewed the unresolved entries and intentionally want to
keep them.

The tool rewrites stale `/nix/store/...` process paths to current executable
paths, resolves simple Nix launcher scripts such as Brave's `bin/brave` to the
signed app executable, and ensures current Nix rule paths have Little Snitch
file-hash code requirements. File-hash rules stored as
`identifier.SHA256/<hash>` are remapped to the active matching executable path
and get a current SHA256 code requirement, including rules whose exported help
text records the original Nix store path.
