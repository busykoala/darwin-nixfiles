# Darwin Nixfiles

## Install nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Install brew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

brew is used to install GUI apps that are not available via nix packags.

## Setup

```bash
git clone git@github.com:busykoala/darwin-nixfiles.git ~/nixfiles
cd ~/nixfiles
cp local.nix.example local.nix
make [ help | rebuild | update | clean | format ]
```

`local.nix` is machine-local and gitignored. Use it for per-host values such as username and SSH `IdentityFile` while keeping all shared config in git.

## Services

### DNS

There is a `dnscrypt-proxy` running with Quad9 DoH.
To use it put `127.0.0.1` and `::1` to the MacOS DNS configuration.

### LanguageTool

A LanguageTool service is configured at `http://localhost:8081` to be used in e.g.
the browser extension.
