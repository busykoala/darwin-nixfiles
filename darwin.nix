{ pkgs, ... }: 

{
  environment.systemPackages = [
  ];

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  programs.zsh.enable = true;

  system.stateVersion = 4;

  users.users.speedy = {
    name = "speedy";
    home = "/Users/speedy";
  };
}
