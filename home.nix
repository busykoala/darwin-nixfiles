{ pkgs
, ...
}: {
  imports = [
    ./modules/aliases.nix
    (import ./modules/packages.nix { inherit pkgs; })
  ];

  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "25.05";
    file = { };
    sessionVariables = { };
  };

  programs = {
    home-manager.enable = true;
    alacritty = import ./modules/programs/alacritty.nix { inherit pkgs; };
    kitty = import ./modules/programs/kitty.nix { inherit pkgs; };
    git = import ./modules/programs/git.nix;
    neovim = import ./modules/programs/neovim.nix { inherit pkgs; };
    tmux = import ./modules/programs/tmux.nix;
    zsh = import ./modules/programs/zsh.nix;
    direnv = import ./modules/programs/direnv.nix;
    ssh = import ./modules/programs/ssh.nix;
    gpg = import ./modules/programs/gpg.nix;
  };
}
