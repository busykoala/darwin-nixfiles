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

      # Shared darwin system builder — call with per-host values.
      mkDarwinConfig = { userName, sshIdentityFile }: darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit pkgsUnstable userName sshIdentityFile;
        };
        modules = [
          ./darwin.nix
          { nix.enable = false; }
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "before-home-manager";
              users.${userName} = import ./home.nix;
              extraSpecialArgs = {
                inherit pkgsUnstable sshIdentityFile;
              };
            };
          }
        ];
      };
    in
    {
      darwinConfigurations = let
        speedyMachine = mkDarwinConfig {
          userName = "speedy";
          sshIdentityFile = "~/.ssh/id_rsa";
        };
      in {
        # busykoala device (Air)
        Matthiass-MacBook-Air = mkDarwinConfig {
          userName = "busykoala";
          sshIdentityFile = "~/.ssh/id_ed25519";
        };

        # speedy device (Pro)
        speedy-machine = speedyMachine;
        "matthiass-macbook-pro" = speedyMachine;
      };

      formatter.aarch64-darwin =
        nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
