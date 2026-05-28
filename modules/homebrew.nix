{
  homebrew = {
    enable = true;

    onActivation.cleanup = "check";

    masApps = { };

    casks = [
      "android-platform-tools"
      "libreoffice"
      "raycast"
      "shottr"
    ];
  };
}
