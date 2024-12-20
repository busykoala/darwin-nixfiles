# Makefile for Nix management with flakes

.PHONY: help rebuild update clean

# Default target
help:
	@echo "Usage:"
	@echo "  make help    - Display this help message"
	@echo "  make rebuild - Rebuild and switch to the new configuration"
	@echo "  make update  - Update flake inputs and rebuild"
	@echo "  make clean   - Clean up old packages and configurations"

# Rebuild and switch
rebuild:
	nix run nix-darwin --experimental-features 'flakes nix-command' -- switch --flake .

# Update flake inputs and rebuild
update:
	nix flake update
	$(MAKE) rebuild

# Clean up old packages and configurations
clean:
	nix-collect-garbage
	./scripts/brew_clean.sh
