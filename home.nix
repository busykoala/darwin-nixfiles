{ pkgs
, pkgsUnstable
, sshIdentityFile
, ...
}: {
  imports = [
    ./modules/aliases.nix
    (import ./modules/packages.nix { inherit pkgs pkgsUnstable; })

    (import ./modules/programs { inherit sshIdentityFile; })
  ];

  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "25.05";
    file = { };
    sessionVariables = { };
  };

  programs.home-manager.enable = true;
}
