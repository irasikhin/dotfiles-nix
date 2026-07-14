{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libcap_ng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "microsandbox";
  version = "0.6.6";

  src = fetchurl {
    url = "https://github.com/superradcompany/microsandbox/releases/download/v${finalAttrs.version}/microsandbox-linux-x86_64.tar.gz";
    hash = "sha256-Vyz4yX5HlfMqdIEPJ7VUURFwhnnbwUbtpGk2pZYOe+0=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libcap_ng
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 msb $out/bin/msb
    install -Dm755 libkrunfw.so.5.5.0 $out/lib/libkrunfw.so.5.5.0
    ln -s libkrunfw.so.5.5.0 $out/lib/libkrunfw.so.5
    ln -s libkrunfw.so.5 $out/lib/libkrunfw.so

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/msb \
      --set-default MSB_LIBKRUNFW_PATH $out/lib/libkrunfw.so.5.5.0
    ln -s msb $out/bin/microsandbox
  '';

  meta = {
    description = "Self-hosted microVM runtime for running untrusted workloads";
    homepage = "https://github.com/superradcompany/microsandbox";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "msb";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
