{ pkgs, ... }: {
  imports = [
    ./modules/homebrew.nix
  ];

  environment = {
    systemPackages = [
      pkgs.pam-reattach
    ];

    # https://write.rog.gr/writing/using-touchid-with-tmux/
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
    primaryUser = "speedy";

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

  users.users.speedy = {
    name = "speedy";
    home = "/Users/speedy";
  };
}
