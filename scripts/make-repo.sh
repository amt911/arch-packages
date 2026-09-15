#!/usr/bin/env bash
#
# Signs the built packages, assembles the pacman database, signs it, and
# exports the public key next to the repository.
#
# Signing is explicit rather than delegated to `makepkg --sign` or
# `repo-add --sign`: every gpg call below passes --pinentry-mode loopback and
# reads the passphrase from a file descriptor, so nothing depends on gpg-agent
# holding a cached passphrase from an earlier call, and the passphrase never
# reaches the process table.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_NAME=${REPO_NAME:-amt911}
PUBLIC=${PUBLIC:-$REPO_ROOT/public}
OUT=$PUBLIC/x86_64
if [[ ! $REPO_NAME =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
    echo "error: invalid repository name" >&2
    exit 1
fi
# Unset => unsigned repository. Local debugging only; CI always sets both.
SIGN_KEY=${SIGN_KEY:-}
GPG_PASSPHRASE=${GPG_PASSPHRASE:-}

shopt -s nullglob
packages=("$OUT"/*.pkg.tar.zst)
if (( ${#packages[@]} == 0 )); then
    echo "error: no packages in $OUT — run scripts/build-packages.sh first" >&2
    exit 1
fi

gpg_sign() {   # gpg_sign <file>  =>  <file>.sig
    gpg --batch --yes --detach-sign --no-armor \
        --pinentry-mode loopback --passphrase-fd 3 \
        --local-user "$SIGN_KEY" --output "$1.sig" "$1" 3<<<"$GPG_PASSPHRASE"
}

if [[ -n $SIGN_KEY ]]; then
    for pkg in "${packages[@]}"; do
        echo "==> signing ${pkg##*/}"
        gpg_sign "$pkg"
    done
else
    echo "==> SIGN_KEY unset: building an UNSIGNED repository (debug only)"
    rm -f -- "$PUBLIC/$REPO_NAME.gpg"
    for pkg in "${packages[@]}"; do rm -f -- "$pkg.sig"; done
fi

# repo-add appends; the database is rebuilt from scratch so a removed package
# actually disappears instead of lingering as an unresolvable entry.
rm -f "$OUT/$REPO_NAME".db* "$OUT/$REPO_NAME".files*
repo-add "$OUT/$REPO_NAME.db.tar.zst" "${packages[@]}"

if [[ -n $SIGN_KEY ]]; then
    for db in "$OUT/$REPO_NAME.db.tar.zst" "$OUT/$REPO_NAME.files.tar.zst"; do
        echo "==> signing ${db##*/}"
        gpg_sign "$db"
    done

    # pacman fetches <repo>.db.sig, not <repo>.db.tar.zst.sig. repo-add makes
    # exactly this kind of symlink for the databases themselves; mirror it for
    # the signatures. actions/upload-pages-artifact tars with --dereference, so
    # all four land on Pages as real files.
    ln -sf "$REPO_NAME.db.tar.zst.sig"    "$OUT/$REPO_NAME.db.sig"
    ln -sf "$REPO_NAME.files.tar.zst.sig" "$OUT/$REPO_NAME.files.sig"

    # Served so a new machine can `pacman-key --add` it. Public half only.
    gpg --armor --export "$SIGN_KEY" > "$PUBLIC/$REPO_NAME.gpg"
    echo "==> exported public key to $PUBLIC/$REPO_NAME.gpg"
fi

echo "==> repository ready in $OUT"
