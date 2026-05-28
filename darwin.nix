{ pkgs, userName, ... }:
let
  allowedUnfreePackages = [
    "brave"
    "codex"
    "drawio"
    "maccy"
    "terraform"
  ];
in
{
  imports = [
    ./modules/homebrew.nix
    ./modules/services
  ];

  environment.systemPackages = [
    pkgs.pam-reattach
  ];

  ids.gids.nixbld = 350;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) allowedUnfreePackages;
    };
  };

  programs.zsh.enable = true;

  system = {
    stateVersion = 4;
    primaryUser = userName;

    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        persistent-apps = [ ];
        show-recents = false;
      };
      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        "com.apple.swipescrolldirection" = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  users.users.${userName} = {
    name = userName;
    home = "/Users/${userName}";
  };
}
