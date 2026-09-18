#!/usr/bin/env bash
#
# Validates the packages/ tree before anything expensive runs.
#
# build-packages.sh only checks that a PKGBUILD exists. The failures this
# catches are the silent ones: a directory whose name does not match its
# pkgname (the built archive then no longer corresponds to the directory the
# pipeline reports), a recipe for an architecture this repository does not
# serve, or a submodule that was added without being pinned.
#
# Hard failures exit non-zero. Advisory findings (namcap's convention here)
# are printed and do not fail the run.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MANIFEST=${MANIFEST:-$REPO_ROOT/aur-makedeps.txt}
# The published repository serves x86_64/ only; 'any' packages land there too.
SERVED_ARCHES=(any x86_64)

errors=0
warnings=0

fail() { printf 'error: %s\n' "$*" >&2; errors=$((errors + 1)); }
warn() { printf 'warning: %s\n' "$*" >&2; warnings=$((warnings + 1)); }

# The PKGBUILD is Bash, so sourcing it is the only parse that agrees with
# makepkg on arrays, quoting and line continuations. It runs in a subshell of
# its own: a stray top-level assignment cannot leak into this script's state.
# makepkg sources the very same file in the same job, so this adds no exposure
# the pipeline did not already have.
read_recipe() {   # read_recipe <dir>  =>  pkgname<TAB>arch...<TAB>|<TAB>makedepends...
    (
        set +euo pipefail
        # shellcheck disable=SC1091  # path is a runtime argument, not a literal
        source "$1/PKGBUILD" >/dev/null 2>&1
        printf '%s\t' "${pkgname[*]-}" "${arch[*]-}" '|'
        printf '%s\t' "${makedepends[@]-}"
        printf '\n'
    )
}

aur_manifest=()
if [[ -f $MANIFEST ]]; then
    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%%#*}
        line=${line//[[:space:]]/}
        [[ -n $line ]] && aur_manifest+=("$line")
    done <"$MANIFEST"
fi

in_manifest() {
    local dep=$1 known
    for known in ${aur_manifest[@]+"${aur_manifest[@]}"}; do
        [[ $known == "$dep" ]] && return 0
    done
    return 1
}

shopt -s nullglob
recipes=("$REPO_ROOT"/packages/*/)
if (( ${#recipes[@]} == 0 )); then
    echo "error: packages/ is empty — run: git submodule update --init --recursive" >&2
    exit 1
fi

for pkgdir in "${recipes[@]}"; do
    dir=$(basename "${pkgdir%/}")
    printf '==> %s\n' "$dir"

    if [[ ! -f ${pkgdir}PKGBUILD ]]; then
        fail "$dir: no PKGBUILD — submodule not initialised (git submodule update --init '$pkgdir')"
        continue
    fi

    # Every package directory is a submodule by design: the packaging repo
    # stays the source of truth and this repository only pins it.
    if ! git -C "$REPO_ROOT" config -f .gitmodules --get "submodule.$dir.path" >/dev/null 2>&1 &&
       ! git -C "$REPO_ROOT" config -f .gitmodules --get "submodule.packages/$dir.path" >/dev/null 2>&1; then
        fail "$dir: not registered in .gitmodules — add it with scripts/add-package.sh"
    fi

    IFS=$'\t' read -r -a fields <<<"$(read_recipe "${pkgdir%/}")"
    name=${fields[0]-}
    arches=${fields[1]-}

    if [[ -z $name ]]; then
        fail "$dir: PKGBUILD declares no pkgname"
    elif [[ $name == *' '* ]]; then
        fail "$dir: split packages are not supported by this pipeline (pkgname='$name')"
    elif [[ $name != "$dir" ]]; then
        fail "$dir: directory name must equal pkgname ('$name'); the built archive would not match the directory"
    fi

    served=0
    for a in $arches; do
        for s in "${SERVED_ARCHES[@]}"; do
            [[ $a == "$s" ]] && served=1
        done
    done
    if (( ! served )); then
        fail "$dir: arch=($arches) is not served by this repository (expected one of: ${SERVED_ARCHES[*]})"
    fi

    # makedepends resolvable in the official repositories need nothing;
    # anything else has to be bootstrapped from the AUR before the build.
    seen_separator=0
    for field in "${fields[@]}"; do
        if (( ! seen_separator )); then
            [[ $field == '|' ]] && seen_separator=1
            continue
        fi
        dep=${field%%[<>=]*}
        [[ -n $dep ]] || continue
        in_manifest "$dep" && continue
        if command -v pacman >/dev/null && pacman -Si -- "$dep" &>/dev/null; then
            continue
        fi
        warn "$dir: makedepend '$dep' is neither in the official repositories nor in ${MANIFEST##*/}"
    done
done

printf '\n==> %d package(s), %d error(s), %d warning(s)\n' "${#recipes[@]}" "$errors" "$warnings"
(( errors == 0 ))
