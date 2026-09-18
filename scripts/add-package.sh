#!/usr/bin/env bash
#
# Adds a package to the repository in one command.
#
# The packaging repository stays the source of truth (see AGENTS.md, "Module
# strategy"): this only pins it here as a submodule. Doing it by hand means
# four steps — submodule add, the ignore=untracked setting, a validation nobody
# runs, and staging the gitlink — and skipping the third is invisible until a
# build produces an archive nobody expected.
#
#   scripts/add-package.sh envycontrol
#   scripts/add-package.sh envycontrol https://github.com/amt911/envycontrol-aur.git
#   scripts/add-package.sh envycontrol --create --from-aur   # also creates the GitHub repo
#
# --create pushes to the NEW packaging repository it creates. It never pushes
# this one; committing the pin stays your call.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# Packaging repositories are named <pkgname>-aur under this account.
GITHUB_OWNER=${GITHUB_OWNER:-amt911}
AUR_BASE=${AUR_BASE:-https://aur.archlinux.org}

usage() {
    cat >&2 <<'USAGE'
usage: scripts/add-package.sh <pkgname> [git-url] [--create] [--from-aur] [--yes]

  <pkgname>    directory under packages/; must equal the recipe's pkgname
  [git-url]    packaging repository (default: https://github.com/<owner>/<pkgname>-aur.git)
  --create     create the packaging repository on GitHub first (needs gh)
  --from-aur   seed that new repository from the AUR recipe of the same name
  --yes        do not prompt before creating and pushing the packaging repository
USAGE
    exit 2
}

pkgname=""
url=""
create=0
from_aur=0
assume_yes=0
for arg in "$@"; do
    case $arg in
        --create)   create=1 ;;
        --from-aur) from_aur=1 ;;
        --yes|-y)   assume_yes=1 ;;
        -h|--help)  usage ;;
        -*)         echo "error: unknown option: $arg" >&2; usage ;;
        *)
            if [[ -z $pkgname ]]; then pkgname=$arg
            elif [[ -z $url ]]; then url=$arg
            else echo "error: unexpected argument: $arg" >&2; usage
            fi
            ;;
    esac
done
[[ -n $pkgname ]] || usage
# pacman's own pkgname charset, minus a leading dash or dot.
if [[ ! $pkgname =~ ^[a-z0-9][a-z0-9@._+-]*$ ]]; then
    echo "error: invalid pkgname: $pkgname" >&2
    exit 1
fi
(( from_aur )) && (( ! create )) && { echo "error: --from-aur only applies with --create" >&2; exit 1; }
url=${url:-https://github.com/$GITHUB_OWNER/$pkgname-aur.git}

path=packages/$pkgname
if [[ -e $REPO_ROOT/$path ]]; then
    echo "error: $path already exists — use scripts/update-package.sh to move its pin" >&2
    exit 1
fi

confirm() {   # confirm <prompt>
    (( assume_yes )) && return 0
    local reply
    read -r -p "$1 [y/N] " reply
    [[ $reply == [yY] ]]
}

if (( create )); then
    command -v gh >/dev/null || { echo "error: --create needs the gh CLI" >&2; exit 1; }
    repo=$GITHUB_OWNER/$pkgname-aur
    confirm "Create $repo on GitHub and push an initial recipe to it?" || exit 1

    seed=$(mktemp -d)
    trap 'rm -rf -- "$seed"' EXIT
    if (( from_aur )); then
        echo "==> seeding from $AUR_BASE/$pkgname.git"
        git clone --depth 1 "$AUR_BASE/$pkgname.git" "$seed/repo"
        # The AUR history belongs to the AUR package; this is a fresh fork
        # point, so it starts with one commit that says where it came from.
        rm -rf "$seed/repo/.git"
    else
        mkdir -p "$seed/repo"
        cat >"$seed/repo/PKGBUILD" <<'TEMPLATE'
# Maintainer:
pkgname=
pkgver=
pkgrel=1
pkgdesc=""
arch=('any')
url=""
license=('MIT')
depends=()
makedepends=()
source=()
sha256sums=()

package() {
    :
}
TEMPLATE
    fi
    ( cd "$seed/repo"
      git init -q -b main .
      git add -A
      git commit -q -m "Initial packaging recipe for $pkgname" )
    # Public on purpose: the workflow checks submodules out with no token of
    # its own, so a private packaging repository would break every CI build.
    gh repo create "$repo" --public --source "$seed/repo" --push
    trap - EXIT
    rm -rf -- "$seed"
fi

cd "$REPO_ROOT"
echo "==> adding $path from $url"
git submodule add -- "$url" "$path"
# Font recipes leave patched TTFs behind after a local build; every existing
# package carries this setting, so keep it uniform.
git config -f .gitmodules "submodule.$path.ignore" untracked

rollback() {
    echo "==> rolling back $path" >&2
    git submodule deinit -f -- "$path" >/dev/null 2>&1 || true
    # `git rm --cached` refuses a gitlink whose work tree is already gone, so
    # the index entry is dropped with reset, which has no such precondition.
    git reset -q HEAD -- "$path" >/dev/null 2>&1 || true
    rm -rf -- "$path" ".git/modules/$path"
    git config -f .gitmodules --remove-section "submodule.$path" 2>/dev/null || true
    # Staging the pruned file is what clears `git submodule add`'s index entry;
    # `git checkout -- .gitmodules` would restore it FROM that index instead.
    git add -- .gitmodules 2>/dev/null || true
}

if ! ./scripts/check-packages.sh; then
    rollback
    echo "error: $pkgname did not pass scripts/check-packages.sh; nothing was added" >&2
    exit 1
fi

git add -- .gitmodules "$path"
pin=$(git -C "$path" rev-parse --short HEAD)

cat <<SUMMARY

==> staged $path at $pin
    Review and commit:
      git diff --cached --submodule=log
      git commit -m "packages/$pkgname: add at $pin"
SUMMARY
