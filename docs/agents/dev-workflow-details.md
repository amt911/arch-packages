# Dev workflow — adding a package and the script environment contract

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

## Adding a package and updating a pointer (only when requested)

```bash
./scripts/add-package.sh <pkgname> [git-url]   # default URL: amt911/<pkgname>-aur
./scripts/update-package.sh <pkgname> [ref]    # ref defaults to the packaging repo's HEAD
./scripts/check-packages.sh                    # the same validation both of them run
```

Both scripts stage the Gitlink and stop there: review with `git diff --cached --submodule=log`
and commit yourself. `add-package.sh` rolls the whole addition back when validation fails, so a
rejected package leaves no half-written `.gitmodules` section. `--create` (with optional
`--from-aur`) creates the packaging repository on GitHub and pushes the seed recipe to it —
that is a push to the NEW repository only; the never-push rule for this repository is unchanged,
and it needs the user's authorization like any other outward-facing action.

Do not hand-roll `git submodule add` or `git submodule update --remote`: the first skips the
`ignore = untracked` setting and the directory-equals-`pkgname` check, the second silently
follows a branch instead of pinning a reviewed revision. Publishing the upstream revision is a
separate user action. The pipeline discovers `packages/*/PKGBUILD`; never edit the workflow per
package. Full flow and edge cases: `docs/packages.md`.

## Script environment contract

| Variable | Default / meaning | State |
| --- | --- | --- |
| `MANIFEST` | Root `aur-makedeps.txt`; absent file is a successful no-op | Implemented |
| `BUILD_USER` | `builder`; makepkg runs unprivileged | Implemented |
| `PUBLIC` | Root `public/`; shared pipeline output root | Implemented |
| `OUT` | `$PUBLIC/x86_64`; optional override for build-packages only | Implemented, ruling F1 |
| `REPO_NAME` | `amt911`; database basename and public-key filename | Implemented |
| `SIGN_KEY` | Fingerprint; unset permits unsigned local debugging only | Implemented |
| `GPG_PASSPHRASE` | Signing passphrase, passed by file descriptor, never command-line value | Implemented |
| `SITE_URL` | `https://amt911.github.io/arch-packages`; configured Pages URL in CI | Implemented |
| `BUILD_RUNNER` | GitHub repository variable; fallback `ubuntu-latest` | Implemented |

`PUBLIC="$PWD/.build-out"` makes Tasks 4 and 5 consume Task 3's returned artifacts. Keep them
between tasks. Local signing validation uses a temporary isolated keyring/test key, never the
user's production identity. An unsigned debug repository must never be deployed.
