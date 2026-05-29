# Update the pinned eXpress Corporate AppImage to the latest release.
# Resolves the version from express.ms, fetches the store hash, and rewrites
# home-manager/pkgs/express.nix. Run `nh home switch .` afterwards to apply.
update-express:
    #!/usr/bin/env bash
    set -euo pipefail
    file="home-manager/pkgs/express.nix"
    url=$(curl -sSI --max-redirs 0 https://express.ms/download/appimage-corporate \
        | grep -i '^location:' | tr -d '\r' | awk '{print $2}')
    [ -n "$url" ] || { echo "could not resolve download URL" >&2; exit 1; }
    fname=$(basename "$url")
    version=$(printf '%s' "$fname" | sed -E 's/^eXpress_Corporate-(.+)\.AppImage$/\1/')
    cur=$(grep -oP 'version = "\K[^"]+' "$file")
    echo "current: $cur   latest: $version"
    if [ "$version" = "$cur" ]; then echo "already up to date"; exit 0; fi
    hash=$(nix store prefetch-file --json --name "$fname" "$url" | jq -r .hash)
    sed -i -E "s|version = \"[^\"]+\"|version = \"$version\"|" "$file"
    sed -i -E "s|hash = \"[^\"]+\"|hash = \"$hash\"|" "$file"
    git add "$file"
    echo "updated $cur -> $version"
    echo "hash: $hash"
    echo "now run: nh home switch ."
