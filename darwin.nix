{ pkgs, ... }: 

{

  imports = [
    ./modules/homebrew.nix
  ];

  environment.systemPackages = [ ];

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  programs.zsh.enable = true;

  system = {
    stateVersion = 4;

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

  security.pam.enableSudoTouchIdAuth = true;

  users.users.speedy = {
    name = "speedy";
    home = "/Users/speedy";
  };
}
