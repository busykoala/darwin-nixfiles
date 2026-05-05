{ pkgs, lib, config, ... }:

let
  seniornettDir = "${config.home.homeDirectory}/seniornett-wg";

  serverPublicKey = "L/JKPvDe5t7HgKvukyX0jwI1rHuS8NXnQbzeWp+liQ4=";
  serverEndpoint = "37.156.46.226:51820";

  clientName = "seniornett-client-001";
  clientAddress = "10.44.1.1/32";
  allowedIPs = "10.44.0.0/16";

  seniornett-wg-generate-client = pkgs.writeShellApplication {
    name = "seniornett-wg-generate-client";

    runtimeInputs = with pkgs; [
      wireguard-tools
      coreutils
    ];

    text = ''
      set -euo pipefail

      seniornett_dir="${seniornettDir}"
      client_name="${clientName}"

      mkdir -p "$seniornett_dir"
      chmod 700 "$seniornett_dir"

      key_file="$seniornett_dir/$client_name.key"
      pub_file="$seniornett_dir/$client_name.pub"
      conf_file="$seniornett_dir/$client_name.conf"

      if [ -f "$key_file" ]; then
        echo "Key already exists: $key_file"
        echo "Not overwriting."
        echo
        echo "Existing public key:"
        cat "$pub_file"
        echo
        echo "Existing config:"
        echo "  $conf_file"
        exit 0
      fi

      wg genkey | tee "$key_file" | wg pubkey > "$pub_file"
      chmod 600 "$key_file"

      client_private_key="$(cat "$key_file")"

      cat > "$conf_file" <<EOF
[Interface]
PrivateKey = $client_private_key
Address = ${clientAddress}
DNS = 9.9.9.9

[Peer]
PublicKey = ${serverPublicKey}
Endpoint = ${serverEndpoint}
AllowedIPs = ${allowedIPs}
PersistentKeepalive = 25
EOF

      chmod 600 "$conf_file"

      echo
      echo "Generated:"
      echo "  $key_file"
      echo "  $pub_file"
      echo "  $conf_file"
      echo
      echo "Client public key:"
      cat "$pub_file"
      echo
      echo "Add it on the server with:"
      echo "  sudo wg set wg0 peer $(cat "$pub_file") allowed-ips ${clientAddress}"
      echo "  sudo wg-quick save wg0"
    '';
  };
in
{
  home.packages = with pkgs; [
    wireguard-tools
    qrencode
    seniornett-wg-generate-client
  ];

  home.file.".config/wireguard/${clientName}.template.conf".text = ''
    [Interface]
    PrivateKey = <CLIENT_PRIVATE_KEY>
    Address = ${clientAddress}
    DNS = 9.9.9.9

    [Peer]
    PublicKey = ${serverPublicKey}
    Endpoint = ${serverEndpoint}
    AllowedIPs = ${allowedIPs}
    PersistentKeepalive = 25
  '';

  home.shellAliases = {
    wg-seniornett-dir = "cd ${seniornettDir}";
    wg-seniornett-show-pub = "cat ${seniornettDir}/${clientName}.pub";
    wg-seniornett-qr = "qrencode -t ansiutf8 < ${seniornettDir}/${clientName}.conf";
  };

  home.activation.createSeniorNettWireGuardDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${seniornettDir}"
    chmod 700 "${seniornettDir}"
  '';
}
