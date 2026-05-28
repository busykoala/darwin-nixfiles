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
make [ help | rebuild | update | clean | format | check ]
```

This repository intentionally contains exactly two nix-darwin hosts:

- `Matthiass-MacBook-Air` for the `busykoala` user
- `matthiass-macbook-pro` for the `speedy` user

`make rebuild` switches the configuration matching `hostname -s`. To build a
specific host manually, run:

```bash
sudo -H nix run nix-darwin --no-warn-dirty --experimental-features 'flakes nix-command' -- switch --flake .#Matthiass-MacBook-Air
sudo -H nix run nix-darwin --no-warn-dirty --experimental-features 'flakes nix-command' -- switch --flake .#matthiass-macbook-pro
```

Run `make check` before pushing changes.

## Services

### LanguageTool

A LanguageTool service is configured at `http://localhost:8081` to be used in e.g.
the browser extension.
