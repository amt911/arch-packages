#!/usr/bin/env bash
#
# Builds and installs the AUR packages listed in aur-makedeps.txt.
#
# These are build dependencies of our own packages, not products of this repo:
# they are installed into the throwaway build container and never copied into
# public/. Keeping someone else's package in [amt911] would be recurring
# maintenance nobody asked for.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MANIFEST=${MANIFEST:-$REPO_ROOT/aur-makedeps.txt}
BUILD_USER=${BUILD_USER:-builder}

if [[ $EUID -ne 0 ]]; then
    echo "error: must run as root; makepkg is dropped to '$BUILD_USER'" >&2
    exit 1
fi

if [[ ! -f $MANIFEST ]]; then
    echo "==> no $MANIFEST, nothing to bootstrap"
    exit 0
fi

workdir=$(mktemp -d)
# The build user has to be able to traverse into it.
chmod 755 "$workdir"
trap 'rm -rf "$workdir"' EXIT

while IFS= read -r line; do
    pkg=${line%%#*}                 # strip comments
    pkg=${pkg//[[:space:]]/}        # strip all whitespace
    [[ -n $pkg ]] || continue

    if pacman -Qq "$pkg" &>/dev/null; then
        echo "==> $pkg already installed, skipping"
        continue
    fi

    echo "==> building AUR build-dependency: $pkg"
    git clone --depth 1 "https://aur.archlinux.org/${pkg}.git" "$workdir/$pkg"
    chown -R "$BUILD_USER:$BUILD_USER" "$workdir/$pkg"
    ( cd "$workdir/$pkg" && sudo -u "$BUILD_USER" makepkg --syncdeps --noconfirm --clean )
    pacman -U --noconfirm "$workdir/$pkg"/*.pkg.tar.*
done < "$MANIFEST"

echo "==> AUR build-dependencies ready"
