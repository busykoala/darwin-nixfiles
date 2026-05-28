{ sshIdentityFile ? "~/.ssh/id_rsa", ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentityFile = sshIdentityFile;
        UseKeychain = "yes";
      };

      rootServer = {
        HostName = "194.13.82.8";
        User = "root";
        ProxyJump = "cockpitServer";
      };

      cockpitServer = {
        HostName = "194.13.80.17";
        User = "root";
      };

      mega-server = {
        HostName = "83.150.16.45";
        User = "zords";
        IdentitiesOnly = true;
      };

      blizzard = {
        HostName = "192.168.50.162";
        User = "zords";
        ProxyJump = "mega-server";
        IdentitiesOnly = true;
      };

      turtle = {
        HostName = "192.168.50.188";
        User = "zords";
        ProxyJump = "mega-server";
        IdentitiesOnly = true;
      };

      seniornett-node-00 = {
        HostName = "37.156.46.226";
        User = "ubuntu";
        IdentitiesOnly = true;
      };
    };
  };
}
