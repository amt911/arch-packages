# Packages — baseline versions and sources

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

## Packages (`packages/`)

All declare `arch=('any')`; the planned repository serves them under `x86_64/`.
`scripts/check-packages.sh` enforces the directory-equals-`pkgname` rule and the served
architectures; `scripts/add-package.sh` and `scripts/update-package.sh` own alta and pin moves.
Versions are committed PKGBUILD values at the baseline, not freshly built versions.

| Directory / pkgname | Upstream packaging repository under `amt911/` | Version | Source |
| --- | --- | --- | --- |
| `config-saver` | `config-saver-aur` | `3.4.0-1` | Release tag tarball |
| `dasik` | `dasik-aur` | `0.19.0-1` | Git source pinned to tag; `check()` runs compileall |
| `envycontrol` | `envycontrol-aur` | `3.6.0-1` | Git source pinned to tag of the personal fork |
| `ttf-atkinson-hyperlegible-next-nerd-git` | `ttf-atkinson-hyperlegible-nerd` | `r17.7925f50-1` | Google Fonts upstream HEAD; AUR `font-patcher` |
| `ttf-atkinson-hyperlegible-next-nerd-mono-git` | `ttf-atkinson-hyperlegible-mono-nerd` | `r20.154d503-1` | Google Fonts upstream HEAD; AUR `font-patcher` |
