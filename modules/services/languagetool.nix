{ pkgs, ... }:
{
  home-manager.users.speedy = { ... }: {
    home.packages = [ pkgs.languagetool ];
  };

  launchd.user.agents.languagetool = {
    serviceConfig = {
      Label = "org.nix-darwin.languagetool";
      ProgramArguments = [
        "${pkgs.languagetool}/bin/languagetool-server"
        "--port"
        "8081"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/languagetool.log";
      StandardErrorPath = "/tmp/languagetool.err";
    };
  };
}
