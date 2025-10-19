{
  programs.ssh = {
    enable = true;

    extraConfig = ''
      Host *
        UseKeychain         yes
        AddKeysToAgent      yes
        IdentityFile        ~/.ssh/id_rsa

      Host                    rootServer
        Hostname            194.13.82.8
        User                root
        ProxyJump           cockpitServer

      Host                    cockpitServer
        Hostname            194.13.80.17
        User                root

      Host                    mega-server
        HostName            83.150.16.45
        User                zords
        IdentitiesOnly      yes

      Host                    blizzard
        HostName            192.168.50.162
        User                zords
        ProxyJump           mega-server
        IdentitiesOnly      yes

      Host                    turtle
        HostName            192.168.50.188
        User                zords
        ProxyJump           mega-server
        IdentitiesOnly      yes
    '';
  };
}
