{ pkgs, userName, allowedUnfreePackages, ... }:

let
  littlesnitchCli = "/Applications/Little Snitch.app/Contents/Components/littlesnitch";
in
{
  imports = [
    ./modules/homebrew.nix
    ./modules/services
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

    activationScripts.littlesnitchNixRules.text = ''
      littlesnitch_cli=${pkgs.lib.escapeShellArg littlesnitchCli}
      if [ -x "$littlesnitch_cli" ]; then
        echo "repairing Little Snitch rules for active Nix paths..."
        env \
          HOME=${pkgs.lib.escapeShellArg "/Users/${userName}"} \
          USER=${pkgs.lib.escapeShellArg userName} \
          SUDO_USER=${pkgs.lib.escapeShellArg userName} \
          PATH="/etc/profiles/per-user/${userName}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
          ${pkgs.python3}/bin/python3 ${./scripts/littlesnitch-nix-rules.py} \
            --apply \
            --unresolved \
            --littlesnitch-cli "$littlesnitch_cli"
      else
        echo "Little Snitch rule repair skipped; CLI not installed."
      fi
    '';
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
