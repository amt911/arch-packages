# Technology ownership — what each part uses

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

## Technology ownership — what each part uses

This is the operative technology map for **`AGENTS.md`** — the one guide Codex and Claude Code both
follow (Claude Code through the `CLAUDE.md` import); it does not prescribe different technologies
per agent. The application-framework examples retained later from the template are not technology
choices for this project. Do not introduce them unless a new approved design changes the scope.

### Root pipeline and publication

| Component | Technologies to use | Purpose / artifact | State |
| --- | --- | --- | --- |
| `scripts/build-aur-makedeps.sh` | Bash, Git over HTTPS, makepkg, sudo, pacman | Read `aur-makedeps.txt`, clone AUR build dependencies, build as `builder`, install only inside the build container | Implemented |
| `scripts/build-packages.sh` | Bash, makepkg, pacman dependency resolution, namcap, standard filesystem tools | Build every pinned packaging recipe unsigned; collect `.pkg.tar.zst`; namcap findings advisory | Implemented, Task 3 |
| `scripts/make-repo.sh` | Bash, GnuPG, repo-add, symbolic links | Detached signatures, `.db.tar.zst` / `.files.tar.zst`, `.db.sig` / `.files.sig` aliases, armored public key | Implemented, Task 4 |
| `scripts/make-index.sh` | Bash, bsdtar, awk, sed, stat, HTML5 and plain CSS | Extract `.PKGINFO`, escape metadata, render package table and setup instructions into `public/index.html` | Implemented, Task 5 |
| `scripts/check-packages.sh` | Bash, git, pacman query | Enforce the packages/ invariants before anything expensive runs; advisory AUR-makedep warnings | Implemented |
| `scripts/add-package.sh`, `scripts/update-package.sh` | Bash, git submodules, optional `gh` | Alta and pin moves in one command, validated and rolled back on failure | Implemented |
| Landing page | Static HTML/CSS, system fonts, CSS custom properties and `prefers-color-scheme` | Responsive document with light/dark styles, served directly by Pages; no JavaScript build or browser application runtime in the plan | Implemented, Task 5 |
| `.github/workflows/repo.yml` | GitHub Actions YAML, `archlinux:base-devel`, `check-packages.sh` plus the four pipeline scripts, official Pages actions | Full build/sign/upload/deploy; same container on hosted or self-hosted runner | Implemented, Task 6 |
| `.github/dependabot.yml` | Dependabot YAML, `github-actions` and `gitsubmodule` ecosystems | Weekly action-version and packaging-pointer update PRs | Implemented, Task 6 |
| Local build verification | Rootless Podman, disposable Arch container, systemd memory cgroups | Execute the actual pipeline without modifying host packages; return artifacts via `.build-out/` | Recipe approved; local build verified |
| Local static verification | Bash syntax checks, ShellCheck; actionlint for workflow YAML | Check the actual shell/YAML surface; no root hooks installed | ShellCheck and actionlint verified |
| Client installation | pacman, pacman-key, GnuPG trust, HTTPS download via curl | Trust dedicated public key, require package/database signatures, install/update `[amt911]` packages | Documented contract; live service pending |
| Self-hosted runner | GitHub Actions runner, dedicated Linux user, systemd service, job-container support | Move build execution to the mini-PC using `BUILD_RUNNER`; preserve isolated Arch build environment | Implemented, Task 9 |
| Documentation | Markdown, approved spec/plan/handoff, paired Claude/Codex guides | Record contracts, decisions, operating steps and verification evidence | Present; operational guides in Tasks 7–9 present |

The intended root has no NestJS, Next.js, React, Prisma, PostgreSQL, Redis, pnpm, Turborepo,
Tailwind, shadcn, mail transport or application storage service. GitHub Pages stores and serves
the generated static repository. Those inherited template examples do not create dependencies.

### `packages/config-saver`

Use its existing Python application packaging, verified against `packages/config-saver/PKGBUILD`:

- **Runtime dependencies:** `python`, `python-pydantic`, `python-colorama`, `python-tqdm`,
  `python-yaml` (PyYAML), and `python-rich`. They cover the Python runtime, structured validation,
  terminal presentation/progress and YAML configuration. Exact versions follow Arch dependencies;
  the recipe does not pin library major versions.
- **Build dependencies:** `python-build`, `python-installer`, `python-wheel`, and `git`.
  The recipe downloads the application release tarball, checks its SHA-256, builds a wheel with
  `python -m build --wheel`, and installs it into the package tree with `python -m installer`.
- **Optional encryption:** `age` or `gnupg`, invoked by the application when configured. Neither
  is a mandatory runtime dependency for ordinary backup/restore.
- **Integration:** packaged YAML examples, systemd system/user service and timer units, plus the
  shell `config-saver.install` upgrade scriptlet. Examples live under `/usr/share/config-saver/`;
  system policy uses `/etc/config-saver/configs`, and personal configuration uses the user's
  config directory. Tests must not alter the user's real backups, configuration or active timers.
- **Existing packaging CI:** Bash parse check, advisory ShellCheck and Semgrep, namcap, and an
  advisory makepkg preparation step. Despite the job name, it uses `makepkg --nobuild`; the checked-in
  workflow does **not** demonstrate a complete build/install smoke test. The root's planned real
  package build and installation checks must supply that evidence.

### `packages/dasik`

Use its existing Python application packaging, verified against `packages/dasik/PKGBUILD`:

- **Runtime dependencies:** `python`, `python-pydantic`, and `python-colorama`; declarative system
  configuration is JSON. Do not infer an application web framework from the generic template.
- **Build dependencies:** `git`, `python-build`, `python-installer`, `python-wheel`, and
  `python-setuptools`. Fetch the upstream Git tag selected by `pkgver`; build the wheel with
  `python -m build --wheel --no-isolation`, then install with `python -m installer`. This uses
  packaged build dependencies rather than a build-created environment downloading from PyPI.
- **Optional system tools by operation:** `arch-install-scripts` for pacstrap/arch-chroot/genfstab;
  `gptfdisk` for partitioning; `dosfstools` for FAT; `e2fsprogs` for ext4; `btrfs-progs` for Btrfs;
  `cryptsetup` for LUKS; `sudo` for unprivileged AUR/Git package builds. They are not all required
  to parse a configuration or run `dasik check`. Never exercise disk-changing operations on the host.
- **Validation:** the PKGBUILD's `check()` runs Python `compileall`, not the upstream unit suite.
  Existing packaging CI performs actual makepkg, advisory namcap, `pacman -U`, `dasik --version`,
  `dasik --help`, `python -m dasik --help`, and checks its shipped `install-simple.json` example.
- **Distribution:** examples and reference docs are packaged under `/usr/share`; tagged packaging
  releases publish archives via `gh` for `iso-bootstrap.sh`. This root additionally plans pacman
  repository distribution; it does not replace that upstream release mechanism.

### `packages/ttf-atkinson-hyperlegible-next-nerd-git`

- **Source:** Google Fonts' `atkinson-hyperlegible-next` Git repository, following HEAD;
  Git computes `pkgver()` from revision count and short commit ID.
- **Build:** Bash PKGBUILD + makepkg, AUR `font-patcher`, FontForge, and GNU find/xargs/nproc.
  The recipe invokes `/usr/share/font-patcher/font-patcher` through FontForge to patch each TTF,
  using `--complete --careful --makegroups 5 --metrics TYPO`. The declared `makedepends` lists
  `font-patcher`; Git and the other invoked tools are build-environment requirements, not extra
  dependencies claimed to be declared by the recipe.
- **Output:** patched regular-family `.ttf` files in `/usr/share/fonts/TTF`, OFL license in the
  package license directory, wrapped as an architecture-independent pacman archive.
- **Verification:** real font build, package metadata/files/license inspection, and installed-font
  discovery with fontconfig in a disposable test environment. Fontconfig is a verification tool,
  not a newly declared runtime dependency. No application entry point exists for a font package.
- **Concurrency:** the recipe currently uses `xargs -P $(nproc)`; enforce the memory ceiling and
  effective worker cap described above. Patching tools are build-only and are not published.

### `packages/ttf-atkinson-hyperlegible-next-nerd-mono-git`

- **Source:** Google Fonts' separate `atkinson-hyperlegible-next-mono` Git repository, following
  HEAD, with its own revision-derived `pkgver()` and independent packaging submodule pin.
- **Build tools and flags:** the same Bash/makepkg, Git, AUR font-patcher, FontForge and
  find/xargs/nproc pipeline and patcher options as the regular family above.
- **Output:** patched monospaced-family TTF files under `/usr/share/fonts/TTF`, its own OFL license
  directory and its own `any` pacman archive; keep it a distinct product.
- **Verification and resource policy:** independently build and inspect this archive, verify the
  installed mono fonts in a disposable environment, and apply the same memory/worker limits.

Package dependency lists describe the checked-in recipes, not an audit of all upstream Python
internals or transitive AUR dependencies. Update this map whenever an authorized dependency,
script or architecture change lands, and keep planned components marked until verified.

Current pins: `config-saver` = `f900443773b241896b3ffc72198f14fbf62880a6`;
`dasik` = `fdcc7a7c80829f02f7846a434cf073b976ce1882`;
`envycontrol` = `8f4cae97b8a68c4222e5553298ad3eeea26c4fe0`;
regular font = `f625aa331e3433fb882006a1eb43d8bca5b971aa`;
mono font = `2bb3859f7ff49e13989dcb596128d890d47432a5`.
Use `git submodule status` to verify rather than treating this snapshot as a future constraint.
