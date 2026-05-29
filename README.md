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
the flake outputs.

To switch explicitly:

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
