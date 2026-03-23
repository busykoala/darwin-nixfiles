{ pkgs, ... }:
let
  dnscryptConfig = pkgs.writeText "dnscrypt-proxy.toml" ''
    listen_addresses = ["127.0.0.1:53", "[::1]:53"]

    ipv4_servers = true
    ipv6_servers = true

    dnscrypt_servers = false
    doh_servers = true
    odoh_servers = false

    require_dnssec = true
    require_nolog = true
    require_nofilter = false

    server_names = [
      "doh-ip4-port443-filter-pri",
      "doh-ip4-port443-filter-alt2",
      "doh-ip6-port443-filter-pri",
      "doh-ip6-port443-filter-alt"
    ]

    bootstrap_resolvers = [
      "9.9.9.9:53",
      "149.112.112.112:53",
      "[2620:fe::fe]:53",
      "[2620:fe::9]:53"
    ]

    ignore_system_dns = true
    netprobe_timeout = 60

    [sources.quad9]
    urls = ["https://raw.githubusercontent.com/Quad9DNS/dnscrypt-settings/main/dnscrypt/quad9-resolvers-doh.md"]
    cache_file = "quad9-resolvers-doh.md"
    minisign_key = "RWTp2E4t64BrL651lEiDLNon+DqzPG4jhZ97pfdNkcq1VDdocLKvl5FW"
    refresh_delay = 72
    prefix = ""
  '';
in
{
  environment.systemPackages = [
    pkgs.dnscrypt-proxy
  ];

  launchd.daemons.dnscrypt-proxy = {
    serviceConfig = {
      Label = "org.nix-darwin.dnscrypt-proxy";
      ProgramArguments = [
        "${pkgs.dnscrypt-proxy}/bin/dnscrypt-proxy"
        "-config"
        "${dnscryptConfig}"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/dnscrypt-proxy.log";
      StandardErrorPath = "/var/log/dnscrypt-proxy.log";
    };
  };
}
