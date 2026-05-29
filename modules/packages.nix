{ pkgs, pkgsUnstable, ... }:

let
  inherit (pkgs) lib stdenv;

  # Keep the config portable across Darwin/Linux.
  # This prevents packages with incompatible meta.platforms from breaking evaluation.
  # It does not protect against packages that claim support but fail during build.
  onlyAvailableOnHost = packages:
    builtins.filter
      (pkg: lib.meta.availableOn stdenv.hostPlatform pkg)
      packages;

  littlesnitchNixRules = pkgs.writeShellApplication {
    name = "littlesnitch-nix-rules";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec ${pkgs.python3}/bin/python3 ${../scripts/littlesnitch-nix-rules.py} "$@"
    '';
  };

  coreTools = with pkgs; [
    bat # Cat with syntax highlighting
    curl # HTTP client
    eza # Modern ls
    fd # Fast file finder
    fzf # Fuzzy finder
    jq # JSON processor
    ripgrep # Fast text search
    tree # Directory tree viewer
    unzip # Zip extraction
    watch # Repeated command runner
    wget # HTTP downloader
    whois # Whois lookup
    xh # Friendly HTTP client
    yq # YAML processor
    zip # Zip archiver
  ];

  cloudTools = with pkgs; [
    aws-sam-cli # AWS SAM app tooling
    awscli2 # AWS CLI
    pkgsUnstable.azure-cli # Azure CLI from unstable
    pkgsUnstable.codex # OpenAI coding agent
    opentofu # Terraform-compatible IaC
    rclone # Cloud file sync
  ];

  developerTools = with pkgs; [
    deadnix # Dead Nix code finder
    delta # Git diff viewer
    dive # Container image explorer
    dua # Disk usage analyzer
    dust # Disk usage viewer
    ffmpeg # Media conversion
    file # File type detection
    gcc # C/C++ compiler
    git-crypt # Git file encryption
    gnumake # GNU Make
    gnupg # GPG tools
    go # Go toolchain
    htop # Process viewer
    imagemagick # Image processing
    inetutils # Network utilities
    jwt-cli # JWT decoder
    libsndfile # Audio file library
    littlesnitchNixRules # Repair Little Snitch rules after Nix store path changes
    nodejs # Node.js runtime
    openssl # TLS and crypto toolkit
    pnpm # JavaScript package manager
    poetry # Python package manager
    skim # Fuzzy finder
    starship # Cross-shell prompt
    statix # Nix linter
    tcpdump # Packet capture
    tesseract # OCR engine
    tmux # Terminal multiplexer
    uv # Python package manager
    yarn # JavaScript package manager
  ];

  kubernetesTools = with pkgs; [
    k0sctl # k0s cluster manager
    k9s # Kubernetes TUI
    kube-bench # Kubernetes CIS checks
    kube-score # Kubernetes manifest checks
    kubectl # Kubernetes CLI
    kubernetes-helm # Helm package manager
    kubescape # Kubernetes security scanner
    stern # Kubernetes log tailer
  ];

  securityTools = with pkgs; [
    binwalk # Firmware analysis
    dnsx # DNS toolkit
    httpx # HTTP probing
    mtr # Network route diagnostics
    naabu # Port scanner
    netdiscover # Network discovery
    nmap # Network scanner
    subfinder # Subdomain discovery
    trivy # Vulnerability and misconfig scanner
    wireshark # Packet analyzer
  ];

  desktopTools = with pkgs; [
    drawio # Diagram editor
    gimp # Image editor
    maccy # Clipboard manager
    nerd-fonts.fira-code # Fira Code Nerd Font
  ];

  packages =
    onlyAvailableOnHost (
      coreTools
      ++ cloudTools
      ++ developerTools
      ++ kubernetesTools
      ++ securityTools
      ++ desktopTools
    );
in
{
  home.packages = packages;
}
