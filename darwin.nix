{ pkgs, userName, ... }: {
  imports = [
    ./modules/homebrew.nix
    ./modules/services
  ];

  environment = {
    systemPackages = [
      pkgs.pam-reattach
    ];

    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
        auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
        auth       sufficient     pam_tid.so
    '';
  };

  ids.gids.nixbld = 350;

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

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${userName} = {
    name = userName;
    home = "/Users/${userName}";
  };
}
