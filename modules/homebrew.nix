{
  homebrew = {
    enable = true;

    onActivation.cleanup = "uninstall";

    masApps = { };

    casks = [
      "android-platform-tools"
      "brave-browser"
      "libreoffice"
      "raycast"
      "shottr"
    ];
  };
}
