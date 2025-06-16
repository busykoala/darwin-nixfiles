# Makefile for Nix management with flakes

.PHONY: help rebuild update clean format

# Default target
help:
	@echo "Usage:"
	@echo "  make help          - Display this help message"
	@echo "  make rebuild       - Rebuild and switch to the new configuration"
	@echo "  make update        - Update flake inputs and rebuild"
	@echo "  make clean         - Clean up old packages and configurations"
	@echo "  make format        - Format the Nix files using nixpkgs-fmt"
	@echo "  make kill-tmux     - Kill the tmux session named 'main'"

rebuild:
	@echo "🔄 Rebuilding system configuration..."
	sudo nix run nix-darwin --experimental-features 'flakes nix-command' -- switch --flake .#busykoala

update:
	@echo "⬆️  Updating flake inputs..."
	nix flake update
	$(MAKE) rebuild
	$(MAKE) clean

clean:
	@echo "🧹 Running garbage collection..."
	@echo "   User-level GC:"
	-nix-collect-garbage --delete-older-than 7d || echo "⚠️  Some paths could not be removed (e.g. due to SIP)"
	@echo "   System-level GC (sudo):"
	-sudo nix-collect-garbage --delete-older-than 7d || echo "⚠️  Some protected system paths could not be removed"
	@echo "   Homebrew cleanup:"
	./scripts/brew_clean.sh || echo "⚠️  brew_clean.sh failed or is missing"

format:
	@echo "🧽 Formatting Nix sources..."
	nix config check
	nix fmt .
	statix check .
	deadnix .

kill-tmux:
	@echo "🛑 Killing tmux session..."
	tmux kill-session -t main
