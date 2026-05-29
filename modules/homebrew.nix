{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "uninstall";
      extraEnv = {
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
      };
    };

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
