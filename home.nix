{
  imports = [
    ./modules/aliases.nix
    ./modules/packages.nix
    ./modules/programs
  ];

  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "25.05";
    file = { };
    sessionVariables = { };
  };

  programs.home-manager.enable = true;
}
