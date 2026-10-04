# Repository structure (Git submodules)

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

## Repository structure (Git submodules)

| Path | Responsibility | Baseline state |
| --- | --- | --- |
| `.gitmodules` + `packages/` | Package submodules, one directory per `pkgname` | Implemented, Task 1; `envycontrol` added later |
| `.gitignore` | Reference material, build products and scratch exclusions | Implemented |
| `aur-makedeps.txt` | Newline-separated AUR build dependencies, `#` comments | Implemented, Task 2 |
| `scripts/build-aur-makedeps.sh` | Root orchestrator, unprivileged AUR makepkg, container install | Implemented, Task 2 |
| `scripts/build-packages.sh` | Build all PKGBUILDs unsigned; namcap advisory; collect archives | Implemented, Task 3 |
| `scripts/make-repo.sh` | Sign archives, repo-add, sign databases, export public key | Implemented, Task 4 |
| `scripts/make-index.sh` | Escaped HTML from package `.PKGINFO`, versions/sizes/links/setup | Implemented, Task 5 |
| `scripts/check-packages.sh` | Validate `packages/`: submodule registered, dir == `pkgname`, served arch, AUR makedeps | Implemented; workflow pre-flight |
| `scripts/add-package.sh` | One-command alta: submodule, `ignore = untracked`, validation, staged Gitlink, rollback | Implemented |
| `scripts/update-package.sh` | Move one pin to a reviewed tag/branch/SHA, re-validate, stage the Gitlink | Implemented |
| `.github/workflows/repo.yml` | Container, triggers, pre-flight check, four pipeline scripts and Pages deployment | Implemented, Task 6 |
| `.github/dependabot.yml` | Weekly Actions and submodule updates | Implemented, Task 6 |
| `docs/packages.md` | Packaging-repo map, alta, pin moves, checks, removal | Implemented |
| `docs/signing.md` | User key creation, secrets, loss/rotation, export cleanup | Implemented, Task 7 |
| `docs/usage.md` + `README.md` | Client setup, package installation, add/update packages | Implemented, Task 8 |
| `docs/self-hosted-runner.md` | Mini-PC runner setup and security | Implemented, Task 9 |
| `AGENTS.md` + `CLAUDE.md` | Canonical agent guide for Codex and Claude Code; `CLAUDE.md` only imports it (`@AGENTS.md`) | Updated for Tasks 3–10; unified into one canonical guide (`docs/agents-md-ui-solid`) |
| `docs/superpowers/` | Approved spec, plan and committed handoff | Present |
| `.superpowers/` | Local SDD recovery ledger and scratch | Ignored; may be absent in another clone |
| `.build-out/` | Local container results consumed by Tasks 4–5 | Ignored, generated on demand |
| `public/` | Complete generated repository and landing page | Ignored, locally verified; production deployment pending |
| `resources/` + `claude-md/` | Local ArchWiki / canonical template references | Ignored; consult, never version here |
