{ stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-cosmos";
  version = "1.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plymouth/themes/cosmos
    cp cosmos.plymouth cosmos.script background.png \
      $out/share/plymouth/themes/cosmos/
    runHook postInstall
  '';

  meta.description = "Plymouth theme with JWST Cosmic Cliffs background";
}
