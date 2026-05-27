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
    aliyun-cli               # Alibaba Cloud CLI
    arjun                    # HTTP parameter discovery
    aws-sam-cli              # AWS SAM app tooling
    awscli2                  # AWS CLI
    pkgsUnstable.azure-cli   # Azure CLI from unstable
    bat                      # Cat with syntax highlighting
    binwalk                  # Firmware analysis
    brave                    # Browser
    checkov                  # IaC security scanner
    codex                    # OpenAI coding agent
    cosign                   # Container signing
    curl                     # HTTP client
    dalfox                   # XSS scanner
    deadnix                  # Dead Nix code finder
    delta                    # Git diff viewer
    detect-secrets           # Secret baseline scanner
    dive                     # Container image explorer
    dnsx                     # DNS toolkit
    drawio                   # Diagram editor
    dua                      # Disk usage analyzer
    dust                     # Disk usage viewer
    eza                      # Modern ls
    fd                       # Fast file finder
    feroxbuster              # Web content discovery
    ffmpeg                   # Media conversion
    ffuf                     # Web fuzzer
    file                     # File type detection
    firefox                  # Browser
    fzf                      # Fuzzy finder
    gcc                      # C/C++ compiler
    gimp                     # Image editor
    git-crypt                # Git file encryption
    gitleaks                 # Secret scanner
    gnumake                  # GNU Make
    gnupg                    # GPG tools
    go                       # Go toolchain
    gobuster                 # Web/DNS discovery
    gopls                    # Go language server
    grpcurl                  # gRPC client
    grype                    # Vulnerability scanner
    htop                     # Process viewer
    httpx                    # HTTP probing
    imagemagick              # Image processing
    inetutils                # Network utilities
    john                     # Password auditing
    jq                       # JSON processor
    jwt-cli                  # JWT decoder
    k0sctl                   # k0s cluster manager
    k9s                      # Kubernetes TUI
    katana                   # Web crawler
    kube-bench               # Kubernetes CIS checks
    kube-score               # Kubernetes manifest checks
    kubectl                  # Kubernetes CLI
    kubernetes-helm          # Helm package manager
    kubescape                # Kubernetes security scanner
    libsndfile               # Audio file library
    maccy                    # Clipboard manager
    mitmproxy                # Intercepting proxy
    mtr                      # Network route diagnostics
    naabu                    # Port scanner
    nerd-fonts.fira-code     # Fira Code Nerd Font
    netdiscover              # Network discovery
    nikto                    # Web server scanner
    nmap                     # Network scanner
    nodejs                   # Node.js runtime
    nuclei                   # Template vulnerability scanner
    nuclei-templates         # Nuclei scan templates
    opencode                 # Terminal coding agent
    openssl                  # TLS and crypto toolkit
    opentofu                 # Terraform-compatible IaC
    osv-scanner              # Dependency vulnerability scanner
    pnpm                     # JavaScript package manager
    poetry                   # Python package manager
    rclone                   # Cloud file sync
    ripgrep                  # Fast text search
    seclists                 # Security wordlists
    semgrep                  # Static analysis scanner
    skim                     # Fuzzy finder
    slack                    # Team chat
    slsa-verifier            # SLSA provenance verifier
    sqlmap                   # SQL injection scanner
    sslscan                  # TLS scanner
    statix                   # Nix linter
    stern                    # Kubernetes log tailer
    subfinder                # Subdomain discovery
    syft                     # SBOM generator
    tcpdump                  # Packet capture
    tesseract                # OCR engine
    testssl                  # TLS configuration tester
    tflint                   # Terraform linter
    tmux                     # Terminal multiplexer
    tree                     # Directory tree viewer
    trivy                    # Vulnerability and misconfig scanner
    trufflehog               # Secret scanner
    unzip                    # Zip extraction
    uv                       # Python package manager
    wafw00f                  # WAF detector
    watch                    # Repeated command runner
    websocat                 # WebSocket client
    wget                     # HTTP downloader
    whois                    # Whois lookup
    wireshark                # Packet analyzer
    xh                       # Friendly HTTP client
    yarn                     # JavaScript package manager
    yq                       # YAML processor
    zip                      # Zip archiver
  ]
  ++ lib.optionals stdenv.isLinux [
    wapiti                   # Web app vulnerability scanner
    zap                      # OWASP ZAP proxy scanner
  ];
in
{
  home.packages = onlyAvailableOnHost packages;
}
