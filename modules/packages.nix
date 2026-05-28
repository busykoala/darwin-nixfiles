{ pkgs, pkgsUnstable }:

let
  inherit (pkgs) lib stdenv;

  # Keep the config portable across Darwin/Linux.
  # This prevents packages with incompatible meta.platforms from breaking evaluation.
  # It does not protect against packages that claim support but fail during build.
  onlyAvailableOnHost = packages:
    builtins.filter
      (pkg: lib.meta.availableOn stdenv.hostPlatform pkg)
      packages;

  packages = with pkgs; [
    aws-sam-cli # AWS SAM app tooling
    awscli2 # AWS CLI
    pkgsUnstable.azure-cli # Azure CLI from unstable
    bat # Cat with syntax highlighting
    binwalk # Firmware analysis
    brave # Browser
    pkgsUnstable.codex # OpenAI coding agent
    curl # HTTP client
    deadnix # Dead Nix code finder
    delta # Git diff viewer
    dive # Container image explorer
    dnsx # DNS toolkit
    drawio # Diagram editor
    dua # Disk usage analyzer
    dust # Disk usage viewer
    eza # Modern ls
    fd # Fast file finder
    ffmpeg # Media conversion
    file # File type detection
    fzf # Fuzzy finder
    gcc # C/C++ compiler
    gimp # Image editor
    git-crypt # Git file encryption
    gnumake # GNU Make
    gnupg # GPG tools
    go # Go toolchain
    htop # Process viewer
    httpx # HTTP probing
    imagemagick # Image processing
    inetutils # Network utilities
    jq # JSON processor
    jwt-cli # JWT decoder
    k0sctl # k0s cluster manager
    k9s # Kubernetes TUI
    kube-bench # Kubernetes CIS checks
    kube-score # Kubernetes manifest checks
    kubectl # Kubernetes CLI
    kubernetes-helm # Helm package manager
    kubescape # Kubernetes security scanner
    libsndfile # Audio file library
    maccy # Clipboard manager
    mtr # Network route diagnostics
    naabu # Port scanner
    nerd-fonts.fira-code # Fira Code Nerd Font
    netdiscover # Network discovery
    nmap # Network scanner
    nodejs # Node.js runtime
    openssl # TLS and crypto toolkit
    opentofu # Terraform-compatible IaC
    pnpm # JavaScript package manager
    poetry # Python package manager
    rclone # Cloud file sync
    ripgrep # Fast text search
    skim # Fuzzy finder
    starship # Cross-shell prompt
    statix # Nix linter
    stern # Kubernetes log tailer
    subfinder # Subdomain discovery
    tcpdump # Packet capture
    tesseract # OCR engine
    tmux # Terminal multiplexer
    tree # Directory tree viewer
    trivy # Vulnerability and misconfig scanner
    unzip # Zip extraction
    uv # Python package manager
    watch # Repeated command runner
    wget # HTTP downloader
    whois # Whois lookup
    wireshark # Packet analyzer
    xh # Friendly HTTP client
    yarn # JavaScript package manager
    yq # YAML processor
    zip # Zip archiver
  ];
in
{
  home.packages = onlyAvailableOnHost packages;
}
