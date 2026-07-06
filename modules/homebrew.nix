{
  homebrew = {
    enable = true;

    onActivation = {
      # nix-darwin 26.05 adda04f emits Homebrew 6's --force-cleanup for
      # cleanup = "uninstall", but current Homebrew Bundle still expects
      # --cleanup.
      cleanup = "none";
      extraFlags = [ "--cleanup" ];
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
