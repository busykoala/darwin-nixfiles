{
  description = "Darwin configuration (stable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Additional unstable channel for selected packages such as azure-cli
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, darwin, ... }:
    let
      # Unstable package set, used only for selected packages (e.g. azure-cli)
      pkgsUnstable = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
    in {
      darwinConfigurations = {
        busykoala = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          # Expose pkgsUnstable to all nix-darwin modules
          specialArgs = { inherit pkgsUnstable; };
          modules = [
            # your main darwin configuration
            ./darwin.nix

            # disable nix-darwin's Nix installation management
            {
              nix.enable = false;
            }

            # home-manager integration
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.speedy = import ./home.nix;
                # Make pkgsUnstable visible to home.nix and its modules
                extraSpecialArgs = { inherit pkgsUnstable; };
              };
            }
          ];
        };
      };

      formatter.aarch64-darwin =
        nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
