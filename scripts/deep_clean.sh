#!/usr/bin/env bash
set -euo pipefail

if [[ "${REALLY_DEEP_CLEAN:-}" != "1" ]]; then
  echo "Refusing destructive cleanup without REALLY_DEEP_CLEAN=1."
  echo "This script deletes Docker resources and broad cache/log paths."
  exit 1
fi

echo "🧹 Running macOS Deep Clean..."

### Nix ###
echo "👉 Nix garbage collection..."
nix-collect-garbage --delete-older-than 3d || true
sudo nix-collect-garbage --delete-older-than 3d || true
echo "👉 Optimizing nix store..."
nix-store --optimise || true

### Homebrew ###
echo "👉 Cleaning Homebrew caches..."
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
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Prune all buildx builders by trying both contexts
docker buildx ls --format '{{.Name}}' | while read -r name; do
  docker --context=default buildx prune -a -f --builder "$name" 2>/dev/null || true
  docker --context=desktop-linux buildx prune -a -f --builder "$name" 2>/dev/null || true
done || true

docker system prune -a --volumes -f || true

### System/User caches (optional light wipe) ###
echo "👉 Cleaning miscellaneous user caches..."
rm -rf ~/Library/Caches/{Homebrew,kitty,helm,composer,wandb,pypoetry,JetBrains,Google,pnpm,node-gyp,com.spotify.client,go,go-build,pip,pip-audit,Yarn,typescript} || true

### Logs ###
echo "👉 Trimming system logs..."
sudo rm -rf /private/var/log/* || true

echo "✅ Deep clean complete!"
