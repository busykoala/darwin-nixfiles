{ pkgs
, ...
}: {
  imports = [
    ./modules/aliases.nix
    (import ./modules/packages.nix { inherit pkgs; })

    ./modules/programs/kitty.nix
    ./modules/programs/direnv.nix
    ./modules/programs/git.nix
    ./modules/programs/gpg.nix
    ./modules/programs/neovim.nix
    ./modules/programs/ssh.nix
    ./modules/programs/tmux.nix
    ./modules/programs/yazi.nix
    ./modules/programs/zoxide.nix
    ./modules/programs/zsh.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "25.05";
    file = { };
    sessionVariables = { };
  };

  programs.home-manager.enable = true;
}
