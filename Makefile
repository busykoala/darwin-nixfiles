# Makefile for Nix management with flakes

.PHONY: help rebuild update clean deep-clean format check littlesnitch-rules kill-tmux

HOSTS := Matthiass-MacBook-Air matthiass-macbook-pro
LITTLESNITCH_NIX_RULES ?= /etc/profiles/per-user/$(USER)/bin/littlesnitch-nix-rules
LITTLESNITCH_CLI ?= /Applications/Little Snitch.app/Contents/Components/littlesnitch

# Default target
help:
	@echo "Usage:"
	@echo "  make help          - Display this help message"
	@echo "  make rebuild       - Rebuild and switch to the new configuration"
	@echo "  make update        - Update flake inputs and rebuild"
	@echo "  make clean         - Run normal Nix garbage collection"
	@echo "  make deep-clean    - Run aggressive cleanup of stubborn store paths"
	@echo "  make format        - Format the Nix files using nixpkgs-fmt"
	@echo "  make check         - Run flake, formatting, statix, deadnix, and dry-run build checks"
	@echo "  make littlesnitch-rules - Repair Little Snitch rules for current Nix paths"
	@echo "  make kill-tmux     - Kill the tmux session named 'main'"

rebuild:
	@echo "🔄 Rebuilding system configuration..."
	@sudo -H darwin-rebuild switch --flake .#$(shell hostname -s)
	@$(MAKE) --no-print-directory littlesnitch-rules

littlesnitch-rules:
	@if [ -x "$(LITTLESNITCH_NIX_RULES)" ] && [ -x "$(LITTLESNITCH_CLI)" ]; then \
		echo "Repairing Little Snitch rules for active Nix paths..."; \
		sudo env PATH="/etc/profiles/per-user/$(USER)/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
			"$(LITTLESNITCH_NIX_RULES)" --apply --unresolved --littlesnitch-cli "$(LITTLESNITCH_CLI)"; \
	else \
		echo "Little Snitch rule repair skipped; script or CLI not installed."; \
	fi

update:
	@echo "⬆️  Updating flake inputs..."
	@nix flake update
	@if [ -x /opt/homebrew/bin/brew ]; then \
		echo "🍺 Updating Homebrew..."; \
		/opt/homebrew/bin/brew update; \
	fi
	@$(MAKE) --no-print-directory rebuild

clean:
	@echo "🧹 Running garbage collection..."
	nix-collect-garbage --delete-older-than 7d
	sudo -H nix-collect-garbage --delete-older-than 7d

deep-clean:
	@echo "🧨 Running deep cleanup..."
	@if [ "$$REALLY_DEEP_CLEAN" != "1" ]; then \
		echo "Refusing deep cleanup without REALLY_DEEP_CLEAN=1."; \
		exit 1; \
	fi
	@tmp_user_log=$$(mktemp /tmp/nix-gc-user.XXXXXX.log); \
	tmp_system_log=$$(mktemp /tmp/nix-gc-system.XXXXXX.log); \
	trap 'rm -f "$$tmp_user_log" "$$tmp_system_log"' EXIT; \
	echo "   User-level GC:"; \
	nix-collect-garbage --delete-older-than 7d 2>&1 | tee "$$tmp_user_log" | grep -v 'error: chmod' || true; \
	echo "   System-level GC (sudo):"; \
	sudo -H nix-collect-garbage --delete-older-than 7d 2>&1 | tee "$$tmp_system_log" | grep -v 'error: chmod' || true; \
	echo "   Removing SIP-protected leftover store paths..."; \
	grep -hq 'error: chmod "/nix/store/' "$$tmp_user_log" "$$tmp_system_log" 2>/dev/null && \
		grep -h 'error: chmod "/nix/store/' "$$tmp_user_log" "$$tmp_system_log" 2>/dev/null \
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
