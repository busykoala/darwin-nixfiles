{ config, pkgs, ... }:

{
  home.stateVersion = "23.05"; # Please read the comment before changing.

  imports = [
    ./modules/aliases.nix
    (import ./modules/packages.nix { inherit pkgs; })
  ];

  home.file = {
    # Add any file-specific configuration here if needed
  };

  home.sessionVariables = {
    # Add any session variables you want to set here
  };

  programs.home-manager.enable = true;

  programs = {
    alacritty = import ./modules/programs/alacritty.nix;
    git = import ./modules/programs/git.nix;
    neovim = import ./modules/programs/neovim.nix { inherit pkgs; };
    tmux = import ./modules/programs/tmux.nix;
    zsh = import ./modules/programs/zsh.nix;
    direnv = import ./modules/programs/direnv.nix;
  };
}
