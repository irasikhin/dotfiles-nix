{
  config,
  lib,
  pkgs,
  ...
}:

# Chromium/Electron apps (Cherry Studio, Google Chrome, Brave) and Firefox/Floorp
# do not read the system OpenSSL bundle that nixos/modules/internal-ca.nix
# maintains: they verify against per-user NSS databases. Import the same internal
# CA into those databases so the same endpoints are trusted there.
let
  cert = "/etc/ssl/extra/internal-ca.pem";
  nickname = "internal-ca";
  certutil = "${pkgs.nssTools}/bin/certutil";
  home = config.home.homeDirectory;
in
{
  # Electron's Node side (main-process requests) uses Node's own root store
  # instead of Chromium's, so point it at the CA too.
  home.sessionVariables.NODE_EXTRA_CA_CERTS = cert;

  home.activation.internalCaNssdb = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -r ${cert} ]; then
      # Chromium's shared user database; create it if Chrome never ran.
      if [ ! -f ${home}/.pki/nssdb/cert9.db ]; then
        mkdir -p ${home}/.pki/nssdb
        ${certutil} -N --empty-password -d sql:${home}/.pki/nssdb
      fi
      for db in ${home}/.pki/nssdb \
                ${home}/.floorp/*/ \
                ${home}/.mozilla/firefox/*/; do
        [ -f "$db/cert9.db" ] || continue
        ${certutil} -D -n ${nickname} -d "sql:$db" >/dev/null 2>&1 || true
        ${certutil} -A -n ${nickname} -t "C,," -i ${cert} -d "sql:$db" >/dev/null ||
          echo "internal-ca: could not update $db (browser running?)" >&2
      done
    fi
  '';
}
