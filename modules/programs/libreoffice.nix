{ lib, pkgs, ... }:
let
  libreofficeManual = pkgs.stdenvNoCC.mkDerivation {
    pname = "libreoffice-manual";
    version = "26.2.1";

    src = pkgs.fetchurl {
      url = "https://mirrors.middlendian.com/tdf/libreoffice/stable/26.2.1/mac/aarch64/LibreOffice_26.2.1_MacOS_aarch64.dmg";
      hash = "sha256-aBTSXbHWT/4PYX1bWrYm3b0vAXsUuTe4HV1D0VUeo4Q=";
    };

    nativeBuildInputs = [ pkgs.undmg pkgs.makeWrapper ];

    unpackPhase = ''
      runHook preUnpack
      undmg "$src"
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications" "$out/bin"
      cp -R "LibreOffice.app" "$out/Applications/"
      makeWrapper "$out/Applications/LibreOffice.app/Contents/MacOS/soffice" "$out/bin/libreoffice"
      runHook postInstall
    '';

    meta = {
      description = "LibreOffice from upstream macOS aarch64 DMG";
      platforms = [ "aarch64-darwin" ];
    };
  };
in {
  home.packages = [
    libreofficeManual
  ];
}
