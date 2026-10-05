{ config, lib, ... }:

# Trust an extra internal CA on top of the Mozilla roots.
#
# The certificate is a public X.509 blob, but it names private infrastructure,
# so it is stored sops-encrypted (secrets/secrets.yaml) instead of being
# committed in the clear. That rules out security.pki.certificateFiles: it
# only takes paths that exist at build time, while the secret is decrypted at
# activation. So the bundle is rebuilt at every activation and installed where
# programs look for the system trust store by default.
let
  mozillaBundle = config.security.pki.caBundle;
  internalCa = config.sops.secrets.internal_ca_pem.path;

  # Paths NixOS itself populates for openssl/curl/git/python and the
  # old-NixOS / Fedora compatibility locations.
  systemBundles = [
    "/etc/ssl/certs/ca-certificates.crt"
    "/etc/ssl/certs/ca-bundle.crt"
    "/etc/pki/tls/certs/ca-bundle.crt"
  ];
in
{
  system.activationScripts.internal-ca = lib.stringAfter [ "etc" "setupSecrets" ] ''
    if [ -r ${internalCa} ]; then
      install -d -m 0755 /etc/ssl/extra
      cat ${mozillaBundle} ${internalCa} > /etc/ssl/extra/ca-bundle.crt
      # Single-cert copy, handy for imports (firefox, keytool).
      install -m 0644 ${internalCa} /etc/ssl/extra/internal-ca.pem
      for bundle in ${lib.concatStringsSep " " systemBundles}; do
        install -d -m 0755 "$(dirname "$bundle")"
        rm -f "$bundle"
        install -m 0644 /etc/ssl/extra/ca-bundle.crt "$bundle"
      done
    else
      echo "internal-ca: ${internalCa} unavailable, leaving trust store as is" >&2
    fi
  '';
}
