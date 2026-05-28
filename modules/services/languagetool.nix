{ pkgs, userName, ... }:
{
  home-manager.users.${userName} = _: {
    home.packages = [ pkgs.languagetool ];
  };

  launchd.user.agents.languagetool = {
    serviceConfig = {
      Label = "org.nix-darwin.languagetool";
      ProgramArguments = [
        "${pkgs.languagetool}/bin/languagetool-server"
        "--host"
        "127.0.0.1"
        "--port"
        "8081"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${userName}/Library/Logs/languagetool.log";
      StandardErrorPath = "/Users/${userName}/Library/Logs/languagetool.err";
    };
  };
}
