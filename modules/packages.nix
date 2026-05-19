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

  # ---------------------------------------------------------------------------
  # Core CLI / shell productivity
  # ---------------------------------------------------------------------------
  cliTools = with pkgs; [
    bat
    curl
    delta
    dua
    dust
    eza
    fd
    file
    fzf
    gnumake
    htop
    inetutils
    jq
    mtr
    ripgrep
    skim
    tmux
    tree
    unzip
    watch
    wget
    xh
    yq
    zip
  ];

  # ---------------------------------------------------------------------------
  # Editors, browsers, desktop apps, fonts
  # ---------------------------------------------------------------------------
  desktopApps = with pkgs; [
    brave
    drawio
    firefox
    gimp
    maccy
    slack

    nerd-fonts.fira-code
  ];

  # ---------------------------------------------------------------------------
  # Development runtimes and language tooling
  # ---------------------------------------------------------------------------
  devTools = with pkgs; [
    codex
    gcc
    go
    gopls
    nodejs
    opencode
    pnpm
    poetry
    uv
    yarn
  ];

  # ---------------------------------------------------------------------------
  # Cloud, Kubernetes, IaC, DevOps
  # ---------------------------------------------------------------------------
  cloudAndDevOps = with pkgs; [
    aliyun-cli
    aws-sam-cli
    awscli2
    dive
    k0sctl
    k9s
    kube-score
    kubectl
    kubernetes-helm
    opentofu
    rclone
    tflint

    # Kubernetes / supply-chain hardening
    cosign
    kube-bench
    kubescape
    slsa-verifier
    stern
  ];

  # ---------------------------------------------------------------------------
  # Existing security / forensic / network tooling
  # ---------------------------------------------------------------------------
  existingSecurityTools = with pkgs; [
    binwalk
    git-crypt
    gnupg
    john
    netdiscover
    nikto
    nmap
    openssl
    sqlmap
    subfinder
    tcpdump
    whois
    wireshark
  ];

  # ---------------------------------------------------------------------------
  # Web app DAST / OWASP-style security testing
  # ---------------------------------------------------------------------------
  webAppSecurityTools = with pkgs; [
    # Template-based vulnerability and misconfiguration scanning
    nuclei
    nuclei-templates

    # Crawling, content discovery, fuzzing, wordlists
    arjun
    ffuf
    feroxbuster
    gobuster
    katana
    seclists

    # HTTP probing, TLS, WAF, headers, fingerprinting
    dnsx
    httpx
    naabu
    sslscan
    testssl
    wafw00f

    # XSS / parameter-focused testing
    dalfox

    # API / protocol / proxy helpers
    grpcurl
    jwt-cli
    mitmproxy
    websocat
  ];

  # ---------------------------------------------------------------------------
  # Linux-only or currently problematic on arm64 Darwin
  # ---------------------------------------------------------------------------
  linuxOnlySecurityTools = lib.optionals stdenv.isLinux (with pkgs; [
    # ZAP is not available for arm64-apple-darwin in your current nixpkgs.
    zap

    # Wapiti currently fails its test suite while building on your Darwin setup.
    wapiti
  ]);

  # ---------------------------------------------------------------------------
  # SAST, dependency scanning, secrets, SBOM, containers, IaC scanning
  # ---------------------------------------------------------------------------
  appSecAndSupplyChainTools = with pkgs; [
    checkov
    deadnix
    detect-secrets
    gitleaks
    grype
    osv-scanner
    semgrep
    statix
    syft
    trivy
    trufflehog
  ];

  # ---------------------------------------------------------------------------
  # Media, OCR, binary/data processing
  # ---------------------------------------------------------------------------
  mediaAndDataTools = with pkgs; [
    ffmpeg
    imagemagick
    libsndfile
    tesseract
  ];

  # ---------------------------------------------------------------------------
  # Packages intentionally pulled from unstable
  # ---------------------------------------------------------------------------
  unstablePackages = [
    # Use azure-cli exclusively from the unstable channel
    pkgsUnstable.azure-cli
  ];

  allPackages =
    cliTools
    ++ desktopApps
    ++ devTools
    ++ cloudAndDevOps
    ++ existingSecurityTools
    ++ webAppSecurityTools
    ++ linuxOnlySecurityTools
    ++ appSecAndSupplyChainTools
    ++ mediaAndDataTools
    ++ unstablePackages;
in
{
  home.packages = onlyAvailableOnHost allPackages;
}
