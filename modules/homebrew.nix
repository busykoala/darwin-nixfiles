{ config, lib, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "none";
      extraEnv = {
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
      };
    };

    masApps = { };

    brews = [
      "widelands"
    ];

    casks = [
      "android-platform-tools"
      "brave-browser"
      "libreoffice"
      "raycast"
      "shottr"
    ];
  };

  # The formula provides a binary but no app bundle for Finder or Raycast.
  system.activationScripts.widelandsLauncher.text = ''
    if [ -x ${lib.escapeShellArg "${config.homebrew.prefix}/bin/widelands"} ]; then
      echo "setting up Widelands app launcher..."
      widelands_app=/Applications/Widelands.app
      /usr/bin/install -d "$widelands_app/Contents/MacOS" "$widelands_app/Contents/Resources"
      /bin/cat > "$widelands_app/Contents/Info.plist" <<'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>Widelands</string>
      <key>CFBundleDisplayName</key><string>Widelands</string>
      <key>CFBundleIdentifier</key><string>org.busykoala.nixfiles.widelands-launcher</string>
      <key>CFBundleExecutable</key><string>widelands</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleVersion</key><string>1</string>
      <key>CFBundleIconFile</key><string>widelands.icns</string>
    </dict>
    </plist>
    PLIST
      /bin/cat > "$widelands_app/Contents/MacOS/widelands" <<'LAUNCHER'
    #!/bin/sh
    exec ${lib.escapeShellArg "${config.homebrew.prefix}/bin/widelands"} "$@"
    LAUNCHER
      /bin/chmod 644 "$widelands_app/Contents/Info.plist"
      /bin/chmod 755 "$widelands_app/Contents/MacOS/widelands"
      widelands_icon=${lib.escapeShellArg "${config.homebrew.prefix}/opt/widelands/share/widelands/data/images/logos/widelands.icns"}
      if [ -f "$widelands_icon" ]; then
        /usr/bin/install -m 644 "$widelands_icon" "$widelands_app/Contents/Resources/widelands.icns"
      fi
    fi
  '';

  system.activationScripts.postActivation.text =
    lib.mkAfter config.system.activationScripts.widelandsLauncher.text;
}
