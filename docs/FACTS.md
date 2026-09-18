# Verified facts

- Pipeline: four standalone scripts (`build-aur-makedeps`, `build-packages`, `make-repo`,
  `make-index`), plus three maintenance ones (`check-packages`, `add-package`,
  `update-package`). Package builds are unsigned as `builder`, then
  `make-repo.sh` signs with explicit loopback GPG and a passphrase file descriptor.
- `PUBLIC` selects the shared output tree. `OUT` overrides only the package builder.
- Local verification uses a read-only checkout mount and disposable container copy.
  Rootless container UID 0 maps returned artifacts back to the invoking user.
- 2026-09-15 build produced config-saver 3.4.0-1, dasik 0.17.0-1, regular font
  r17.7925f50-1 and mono font r20.154d503-1. Both font versions are computed at build time.
- Package/database signatures verified with a disposable test identity, never a personal key.
- `check-packages.sh` hard-fails on: uninitialised submodule, directory != `pkgname`,
  unregistered in `.gitmodules`, split package, unserved `arch`. Verified 2026-09-18 by
  breaking each case in a throwaway tree; AUR-makedep findings are warnings only.
- `add-package.sh` rolls back with `git reset HEAD -- <path>`: `git rm --cached` refuses a
  gitlink whose work tree is already gone, and `git checkout -- .gitmodules` restores the file
  from the index `git submodule add` just wrote. Verified 2026-09-18.
- `.gitmodules` section names are the path (`submodule.packages/<pkgname>`), not the bare
  pkgname; `git submodule add --name <pkgname>` would break that convention.
- envycontrol 3.6.0-1 built and installed in a disposable container 2026-09-18:
  `envycontrol --version/--help` correct, `pacman -Qk` 25 files 0 missing. namcap warnings
  are the usual uninstalled-python-module advisories.
- Packaging repos must stay public: the workflow checks submodules out with no token.
- Public deployment and the self-hosted runner remain unverified. See HANDOFF.md.
