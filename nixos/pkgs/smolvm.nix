{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  e2fsprogs,
  gnutar,
  gzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smolvm";
  version = "1.5.2";

  src = fetchurl {
    url = "https://github.com/smol-machines/smolvm/releases/download/v${finalAttrs.version}/smolvm-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-eZ2/o6zXdAR6SItNpN8uP5ovG1LpCqq9mT9Y4uJ73jQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontAutoPatchelf = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/smolvm
    cp -r lib agent-rootfs smolvm-bin $out/libexec/smolvm/
    chmod +x $out/libexec/smolvm/smolvm-bin

    makeWrapper $out/libexec/smolvm/smolvm-bin $out/bin/smolvm \
      --set SMOLVM_LIB_DIR $out/libexec/smolvm/lib \
      --set SMOLVM_AGENT_ROOTFS $out/libexec/smolvm/agent-rootfs \
      --prefix LD_LIBRARY_PATH : $out/libexec/smolvm/lib \
      --prefix PATH : ${
        lib.makeBinPath [
          e2fsprogs
          gnutar
          gzip
        ]
      }

    runHook postInstall
  '';

  postFixup = ''
    autoPatchelf $out/libexec/smolvm/smolvm-bin $out/libexec/smolvm/lib
  '';

  meta = {
    description = "Portable, lightweight, self-contained microVMs from OCI images";
    homepage = "https://github.com/smol-machines/smolvm";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "smolvm";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
