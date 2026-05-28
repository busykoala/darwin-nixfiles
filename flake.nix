{
  description = "Darwin configuration (stable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Additional unstable channel for selected packages such as azure-cli
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, darwin, ... }:
    let
      allowedUnfreePackages = [
        "brave"
        "codex"
        "drawio"
        "maccy"
      ];

      allowListedUnfree = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) allowedUnfreePackages;

      # Unstable package set, used only for selected packages (e.g. azure-cli)
      pkgsUnstable = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config = {
          allowUnfreePredicate = allowListedUnfree;
        };
      };

      # Shared darwin system builder — call with per-host values.
      mkDarwinConfig = { userName, sshIdentityFile }: darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit allowedUnfreePackages pkgsUnstable userName sshIdentityFile;
        };
        modules = [
          ./darwin.nix
          {
            # Determinate Nix manages the Nix installation and daemon.
            # Keep nix-darwin from writing nix.conf or managing nix services.
            nix.enable = false;
          }
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
      hosts = {
        Matthiass-MacBook-Air = {
          userName = "busykoala";
          sshIdentityFile = "~/.ssh/id_ed25519";
        };

        matthiass-macbook-pro = {
          userName = "speedy";
          sshIdentityFile = "~/.ssh/id_rsa";
        };
      };
    in
    {
      darwinConfigurations = builtins.mapAttrs (_: mkDarwinConfig) hosts;

      formatter.aarch64-darwin =
        nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
