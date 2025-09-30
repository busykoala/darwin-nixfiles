#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Running macOS Deep Clean..."

### Nix ###
echo "👉 Nix garbage collection..."
nix-collect-garbage --delete-older-than 3d || true
sudo nix-collect-garbage --delete-older-than 3d || true
echo "👉 Optimizing nix store..."
nix-store --optimise || true

### Homebrew ###
echo "👉 Homebrew cleanup..."
/opt/homebrew/bin/brew cleanup -s || true
/opt/homebrew/bin/brew autoremove || true

### Python & ML caches ###
echo "👉 Removing Python-related caches..."
rm -rf ~/.cache/{pip,pypoetry,uv,huggingface} || true
rm -rf ~/Library/Caches/{pypoetry} || true

### GitHub Copilot ###
echo "👉 Removing GitHub Copilot cache..."
rm -rf ~/.cache/github-copilot || true

### JetBrains IDE caches ###
echo "👉 Removing JetBrains caches..."
rm -rf ~/Library/Caches/JetBrains || true

### Browser & tooling caches ###
echo "👉 Removing Google/Chrome cache..."
rm -rf ~/Library/Caches/Google || true
echo "👉 Removing pnpm, node-gyp, spotify caches..."
rm -rf ~/Library/Caches/{pnpm,node-gyp,com.spotify.client} || true

### Docker ###
echo "👉 Cleaning Docker images, containers, and volumes..."
docker system prune -a --volumes -f || true

### System/User caches (optional light wipe) ###
echo "👉 Cleaning miscellaneous user caches..."
rm -rf ~/Library/Caches/{Homebrew,kitty,helm,composer,wandb,pypoetry,JetBrains,Google,pnpm,node-gyp,com.spotify.client} || true

### Logs ###
echo "👉 Trimming system logs..."
sudo rm -rf /private/var/log/* || true

echo "✅ Deep clean complete!"
