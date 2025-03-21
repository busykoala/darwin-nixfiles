{ pkgs }:

{
  home.packages = with pkgs; [
    aws-sam-cli
    awscli2
    azure-cli
    curl
    delta
    dive
    drawio
    eza
    fd
    file
    fzf
    gcc
    gimp
    gnumake
    gnupg
    go
    gopls
    # jetbrains.datagrip
    # jetbrains.goland
    # jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    # jetbrains.rust-rover
    jetbrains.webstorm
    jq
    k9s
    kubectl
    kubernetes-helm
    nodejs
    openssl
    opentofu
    poetry
    ripgrep
    spotify
    tflint
    # thefuck
    tmux
    tree
    unzip
    watch
    wget
    whois
    yarn
    zip
  ];
}
