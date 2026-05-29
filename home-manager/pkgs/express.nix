{ appimageTools, src }:

let
  pname = "express-corporate";
  # Version follows whatever the express-appimage flake input resolves to;
  # bump it with `nix flake update express-appimage`. The label is cosmetic.
  version = "latest";

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
