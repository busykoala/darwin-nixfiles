# Makefile for Nix management with flakes

.PHONY: help rebuild update clean format check

HOSTS := Matthiass-MacBook-Air matthiass-macbook-pro

# Default target
help:
	@echo "Usage:"
	@echo "  make help          - Display this help message"
	@echo "  make rebuild       - Rebuild and switch to the new configuration"
	@echo "  make update        - Update flake inputs and rebuild"
	@echo "  make clean         - Clean up old packages and configurations"
	@echo "  make format        - Format the Nix files using nixpkgs-fmt"
	@echo "  make check         - Run flake, formatting, statix, deadnix, and dry-run build checks"
	@echo "  make kill-tmux     - Kill the tmux session named 'main'"

rebuild:
	@echo "🔄 Rebuilding system configuration..."
	@sudo -H nix run nix-darwin --no-warn-dirty --experimental-features 'flakes nix-command' -- switch --flake .#$(shell hostname -s)

update:
	@echo "⬆️  Updating flake inputs..."
	@nix flake update
	@$(MAKE) --no-print-directory rebuild
	@$(MAKE) --no-print-directory clean

clean:
	@echo "🧹 Running garbage collection..."
	@echo "   User-level GC:"
	@nix-collect-garbage --delete-older-than 7d 2>&1 \
		| tee /tmp/nix-gc-user.log \
		| grep -v 'error: chmod' || true
	@echo "   System-level GC (sudo):"
	@sudo -H nix-collect-garbage --delete-older-than 7d 2>&1 \
		| tee /tmp/nix-gc-system.log \
		| grep -v 'error: chmod' || true
	@grep -hq 'error: chmod "/nix/store/' /tmp/nix-gc-user.log /tmp/nix-gc-system.log 2>/dev/null && \
		echo "   Removing SIP-protected leftover store paths..." && \
		grep -h 'error: chmod "/nix/store/' /tmp/nix-gc-user.log /tmp/nix-gc-system.log 2>/dev/null \
		| sed 's|.*error: chmod "/nix/store/\([^/]*\)/.*|\1|' \
		| sort -u \
		| while read -r pkg; do \
			path="/nix/store/$$pkg"; \
			if [ -d "$$path" ]; then \
				echo "   Force-removing $$path"; \
				sudo chflags -R noschg,nouchg "$$path" 2>/dev/null; \
				sudo rm -rf "$$path"; \
			fi; \
		done || true
	@rm -f /tmp/nix-gc-user.log /tmp/nix-gc-system.log
format:
	@echo "🧽 Formatting Nix sources..."
	nix config check
	nix fmt .
	nix run nixpkgs#statix -- check .
	nix run nixpkgs#deadnix -- .

check:
	nix flake check --show-trace --keep-going
	nix run nixpkgs#nixpkgs-fmt -- --check .
	nix run nixpkgs#statix -- check .
	nix run nixpkgs#deadnix -- --fail .
	@for host in $(HOSTS); do \
		nix build .#darwinConfigurations.$$host.system --dry-run; \
	done

kill-tmux:
	@echo "🛑 Killing tmux session..."
	tmux kill-session -t main
