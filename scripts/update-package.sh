#!/usr/bin/env bash
#
# Moves one package's pin to a chosen packaging revision.
#
# This is the three-command dance from AGENTS.md ("Updating a package pointer")
# with the parts that are easy to get wrong made explicit: it never runs
# `git submodule update --remote` (which silently follows a branch), it refuses
# a revision that does not exist instead of leaving the submodule detached at
# the old one, and it re-runs the package checks before staging the gitlink.
#
#   scripts/update-package.sh dasik            # default branch tip
#   scripts/update-package.sh dasik 0.19.0     # tag, branch or SHA
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if (( $# < 1 || $# > 2 )); then
    echo "usage: scripts/update-package.sh <pkgname> [tag|branch|sha]" >&2
    exit 2
fi
pkgname=$1
ref=${2-}
path=packages/$pkgname

cd "$REPO_ROOT"
if [[ ! -f $path/PKGBUILD ]]; then
    echo "error: $path has no PKGBUILD — not a package, or submodule not initialised" >&2
    exit 1
fi

before=$(git -C "$path" rev-parse HEAD)
echo "==> fetching $pkgname"
git -C "$path" fetch --tags --prune origin

if [[ -z $ref ]]; then
    # The packaging repository's own default branch, not an assumption of 'main'.
    ref=$(git -C "$path" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) ||
        ref=origin/HEAD
    echo "==> no revision given: using $ref"
fi

target=$(git -C "$path" rev-parse --verify --quiet "${ref}^{commit}") || {
    echo "error: $pkgname has no revision '$ref'" >&2
    exit 1
}

git -C "$path" checkout --quiet --detach "$target"
echo "==> $pkgname: ${before:0:7} -> ${target:0:7}"

if ! ./scripts/check-packages.sh; then
    git -C "$path" checkout --quiet --detach "$before"
    echo "error: $ref did not pass scripts/check-packages.sh; pin left at ${before:0:7}" >&2
    exit 1
fi

if [[ $before == "$target" ]]; then
    echo "==> already pinned there; nothing staged"
    exit 0
fi

git add -- "$path"
version=$(sed -n 's/^pkgver=//p' "$path/PKGBUILD" | head -1)

cat <<SUMMARY

==> staged $path at ${target:0:7}${version:+ (pkgver=$version)}
    Review and commit:
      git diff --cached --submodule=log
      git commit -m "packages/$pkgname: ${version:-${target:0:7}}"
SUMMARY
