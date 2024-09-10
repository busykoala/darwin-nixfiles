{ config, pkgs, ... }:

{
  imports = [
    ./modules/aliases.nix
    (import ./modules/packages.nix { inherit pkgs; })
  ];

  home.stateVersion = "23.05";
  home.file = {};
  home.sessionVariables = {};

  programs = {
    home-manager.enable = true;
    alacritty = import ./modules/programs/alacritty.nix;
    git = import ./modules/programs/git.nix;
    neovim = import ./modules/programs/neovim.nix { inherit pkgs; };
    tmux = import ./modules/programs/tmux.nix;
    zsh = import ./modules/programs/zsh.nix;
    direnv = import ./modules/programs/direnv.nix;
    ssh = import ./modules/programs/ssh.nix;
    gpg = import ./modules/programs/gpg.nix;
  };
}
