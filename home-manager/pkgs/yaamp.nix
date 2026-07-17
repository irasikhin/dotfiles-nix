{
  lib,
  appimageTools,
  fetchurl,
  runCommand,
  unzip,
}:

let
  pname = "yaamp";
  version = "0.0.7";

  zip = fetchurl {
    url = "https://github.com/umnik1/yaamp/releases/download/v${version}/yaamp-linux.zip";
    hash = "sha256-+Aq6NW2MSoYxMmLbZyD3nURJqYdAaWoeoI7OqpR90gI=";
  };

  src =
    runCommand "Yaamp-${version}.AppImage"
      {
        nativeBuildInputs = [ unzip ];
      }
      ''
        unzip -j ${zip} "Yaamp-${version}.AppImage" -d .
        mv "Yaamp-${version}.AppImage" $out
      '';

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [ libxshmfence ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${pname}.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=AppRun" "Exec=${pname}"
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/2x2/apps/${pname}.png \
      $out/share/icons/hicolor/2048x2048/apps/${pname}.png
  '';

  meta = {
    description = "Winamp-style audio player with Yandex Music integration";
    homepage = "https://github.com/umnik1/yaamp";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "yaamp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
