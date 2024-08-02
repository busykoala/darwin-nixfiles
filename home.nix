{ config, pkgs, ... }:

{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  
  imports = [
    ./aliases.nix
  ];

  home.packages = with pkgs; [
    curl
    delta
    eza
    fd
    file
    fzf
    gcc
    gimp
    gnumake
    go
    gopls
    jq
    k9s
    keepassxc
    kubectl
    kubernetes-helm
    nodejs
    openssl
    opentofu
    poetry
    ripgrep
    thefuck
    tmux
    tree
    unzip
    wget
    whois
    yarn
    zip
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;

  programs = {
    zsh = import ./tools/zsh.nix;
    neovim = import ./tools/neovim.nix { inherit pkgs; };
  };

}
