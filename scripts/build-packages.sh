#!/usr/bin/env bash
#
# Builds every PKGBUILD under packages/ into public/x86_64/.
#
# Deliberately does NOT sign: the private key never enters the unprivileged
# build user's keyring. scripts/make-repo.sh signs afterwards, as root, with
# explicit loopback flags — see the comment there.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BUILD_USER=${BUILD_USER:-builder}
# PUBLIC is the one knob for the whole pipeline: make-repo.sh and make-index.sh
# read the same variable, so redirecting the output tree takes one export rather
# than one per script.
PUBLIC=${PUBLIC:-$REPO_ROOT/public}
OUT=${OUT:-$PUBLIC/x86_64}

if [[ $EUID -ne 0 ]]; then
    echo "error: must run as root; makepkg is dropped to '$BUILD_USER'" >&2
    exit 1
fi

if ! id -u "$BUILD_USER" &>/dev/null; then
    echo "error: build user '$BUILD_USER' does not exist" >&2
    exit 1
fi

# Reject output paths that could erase the checkout or its parents.
OUT=$(realpath -m -- "$OUT")
if [[ $OUT == / || $REPO_ROOT == "$OUT" || $REPO_ROOT == "$OUT/"* || $OUT == "$REPO_ROOT/packages" || $OUT == "$REPO_ROOT/packages/"* ]]; then
    echo "error: unsafe output directory: $OUT" >&2
    exit 1
fi
shopt -s nullglob
recipes=("$REPO_ROOT"/packages/*/)
if (( ${#recipes[@]} == 0 )); then
    echo "error: no PKGBUILD under packages/ — are the submodules initialised?" >&2
    exit 1
fi
for pkgdir in "${recipes[@]}"; do
    if [[ ! -f ${pkgdir}PKGBUILD ]]; then
        echo "error: missing PKGBUILD in $pkgdir — initialise every submodule" >&2
        exit 1
    fi
done

# The published repository holds the current version of each package and
# nothing else, so the output tree is rebuilt from scratch every run.
rm -rf "$OUT"
install -d -m 755 "$OUT"

built=0
for pkgdir in "${recipes[@]}"; do
    [[ -f ${pkgdir}PKGBUILD ]] || continue
    built=$((built + 1))
    printf '\n==> building %s\n' "$(basename "${pkgdir%/}")"

    chown -R "$BUILD_USER:$BUILD_USER" "$pkgdir"

    # --cleanbuild re-extracts the sources, which is what makes a -git package's
    # pkgver() see today's upstream HEAD instead of a stale checkout.
    # --clean drops src/ and pkg/ afterwards so the submodule tree stays clean.
    ( cd "$pkgdir" && sudo -u "$BUILD_USER" \
        makepkg --syncdeps --noconfirm --cleanbuild --clean --force --nosign )

    # Ask makepkg for this build's outputs, excluding stale archives from older runs.
    package_list=$(cd "$pkgdir" && sudo -u "$BUILD_USER" makepkg --packagelist)
    artifacts=()
    while IFS= read -r artifact; do
        # makepkg lists a potential debug archive even when it emitted none.
        # Debug companions are build byproducts, not repository products.
        [[ ${artifact##*/} == *-debug-* ]] && continue
        if [[ ! -f $artifact || $artifact != *.pkg.tar.zst ]]; then
            echo "error: expected a .pkg.tar.zst build artifact: $artifact" >&2
            exit 1
        fi
        artifacts+=("$artifact")
    done <<<"$package_list"
    if (( ${#artifacts[@]} == 0 )); then
        echo "error: no product archive produced in $pkgdir" >&2
        exit 1
    fi

    # Advisory only: namcap reports packaging smells, not build failures.
    if command -v namcap >/dev/null; then
        namcap "${pkgdir}PKGBUILD" "${artifacts[@]}" || true
    fi

    mv -v -- "${artifacts[@]}" "$OUT/"
done

if (( built == 0 )); then
    echo "error: no PKGBUILD under packages/ — are the submodules initialised?" >&2
    exit 1
fi

shopt -s nullglob
packages=("$OUT"/*.pkg.tar.zst)
if (( ${#packages[@]} == 0 )); then
    echo "error: built $built PKGBUILD(s) but no package landed in $OUT" >&2
    exit 1
fi

printf '\n==> %d package(s) in %s\n' "${#packages[@]}" "$OUT"
printf '    %s\n' "${packages[@]##*/}"
