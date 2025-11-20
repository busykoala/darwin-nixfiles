{
  description = "Darwin configuration (stable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, darwin, ... }: {
    darwinConfigurations = {
      busykoala = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
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
            };
          }
        ];
      };
    };

    formatter.aarch64-darwin =
      nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
