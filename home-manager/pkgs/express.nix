{ appimageTools, fetchurl }:

let
  pname = "express-corporate";
  version = "3.65.52";

  src = fetchurl {
    url = "https://updates.express.ms/desktop/corporate/eXpress_Corporate-${version}.AppImage";
    hash = "sha256-2DLQ8d/qthQH6WaC2ltzUdfz2J3XvfZ3qeedoNf7A8Y=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/express_corporate.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=AppRun" "Exec=${pname}"
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';
}
