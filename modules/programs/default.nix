{ sshIdentityFile, ... }:
{
  imports = [
    ./kitty.nix
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./neovim.nix
    (import ./ssh.nix { inherit sshIdentityFile; })
    ./tmux.nix
    ./yazi.nix
    ./zoxide.nix
    ./zsh.nix
    ./wireguard.nix
  ];
}
