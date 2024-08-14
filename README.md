# Darwin Nixfiles

## Install nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Setup

```bash
git clone git@github.com:busykoala/darwin-nixfiles.git ~/nixfiles
cd ~/nixfiles
nix run nix-darwin --experimental-features 'flakes nix-command' -- switch --flake .
```

## Direnv issue

```bash
sudo -i nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
sudo -i nix-channel --update nixpkgs
```
