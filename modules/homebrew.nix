{
  homebrew = {
    enable = true;

    onActivation.cleanup = "uninstall";

    masApps = { };

    casks = [
      "android-platform-tools"
      "libreoffice"
      "raycast"
      "shottr"
    ];
  };
}
