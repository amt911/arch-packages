# arch-packages — Claude Guide

`amt911/arch-packages` aggregates four personal Arch Linux packages into the planned signed
`[amt911]` pacman repository on GitHub Pages, so Andrés can install and update them with pacman.
This repository owns packaging orchestration; the application sources and PKGBUILDs have their
own repositories.

## Project authority, applicability and current stop

Adapted from `claude-md/docs/starter-kit/CLAUDE.template.md`, the single canonical English
template. Its section order, governance, explanations and examples are retained; the six
pnpm-monorepo preset sections are replaced with this project's stack. Local applicability notes
and the rules below specialize inherited governance; they take precedence over generic examples.
The companion `AGENTS.md` carries the same project policy for Codex. Keep both synchronized.

**Current user scope (2026-09-15): continue the approved implementation through Task 10.**
The user explicitly resumed the plan after the documentation-only stop. Tasks 3–10 now
have implementation files; verification status is recorded in the handoff and ledger.
Stop before Task 11: production key/secrets, Pages setup, push and merge belong to the user.

Read recovery context in this order:

1. `docs/superpowers/HANDOFF.md` — the handoff (uppercase filename).
2. `.superpowers/sdd/2026-09-15-arch-repo/progress.md` — recovery ledger, if present; ignored local
   scratch, not guaranteed in a fresh clone. If absent, use the committed handoff and inspect Git.
3. `docs/superpowers/specs/2026-09-15-arch-repo-design.md` — approved design and decision rationale.
4. `docs/superpowers/plans/2026-09-15-arch-repo.md` — eleven tasks, contracts and verification.
   Apply its recorded refinements and ledger rulings; do not silently revert to superseded examples.

**Implementation baseline, 2026-09-15:** branch `feat/arch-repo`, continuation started
from `7ac4aa1`. Tasks 1–2 were already complete. The scripts, workflow and operational
guides for Tasks 3–10 now exist. See the current handoff for verification evidence and
remaining limitations. No push, merge or production deployment has been performed.

### Project overrides to inherited governance

- **At most ONE subagent total at a time**, including reviewers. The handoff and ledger override
  the template's parallel-review exception. **Never a model above Sonnet**; never Opus for
  delegation. If an allowed model cannot be established on the current platform, work locally;
  do not invent a cross-provider equivalence. Work locally when no permitted Sonnet model is available.
- **Never push, never merge.** The handoff's project-specific prohibition applies in every mode,
  including unattended mode; its explicit restriction overrides the template's push exception.
  The user handles both. Local commits are allowed.
- The handoff requires Claude-authored commit bodies to end with
  `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`.
  Preserve that historical attribution rule for Claude work. Codex must not claim Claude authored
  its work or fabricate a model identity.
- **Only the user generates the dedicated production GPG key, loads `GPG_PRIVATE_KEY` and
  `GPG_PASSPHRASE`, and selects Settings → Pages → Build and deployment → Source → GitHub Actions.**
  Task 11 remains blocked until that setup and the user's continuation instruction. Do not inspect,
  print, export, or use the user's personal signing key to work around it.
- The root is packaging/infrastructure, not a pnpm application. Inherited web, mobile, ORM,
  transport and language-specific examples explain governance; they do not install those stacks
  or assert those paths/tools exist. Read the applicability table in Tests and quality first.
- `docs/ENDPOINT_PERMISSIONS.md`, `PRODUCT.md`, `DESIGN.md`,
  `design-system.md`, `user-stories.md` and `scripts/verify/verify-pr.sh` do not
  currently exist at the root. Read optional memory files when present. Create them only when
  relevant to authorized work.
- The approved spec and plan supply the current backlog and acceptance criteria. The kit's
  design-system and user-story templates do not authorize inventing a second backlog or visual
  identity. No API exists, so the endpoint-permissions template is currently inapplicable.
- Graphify, when used, must target source and project documentation,
  excluding ignored `resources/` (the approximately 216 MB ArchWiki dump), `claude-md/`, generated
  artifacts and scratch. Its examples below are skill notation, not proof a shell command exists.
  Do not install additional host tooling to satisfy inherited examples.

## Start here

- **Run `/graphify` before each session.** The persistent graph at `graphify-out/graph.json`
  summarizes architecture, dependencies and cross-cutting concepts without re-reading the repo.
- **Before touching UI:** use the `impeccable` skill. If the project has no design context yet
  (`PRODUCT.md` / `DESIGN.md` at the root), **run `$impeccable teach` first** — it explores the code
  and **interviews you** about the project's direction (register, users, personality, visual
  direction) and writes `PRODUCT.md` + `DESIGN.md`; never hand-author it. Also read `design-system.md`
  (palette/type/components) and `user-stories.md` before defining a slice.
- **Read `docs/FINDINGS.md` before debugging or touching the build** — non-obvious gotchas.
  **Convention:** when you discover something non-obvious that cost time and isn't deducible from the
  code, add a short entry to `docs/FINDINGS.md`.
- **`docs/FACTS.md` is the working-memory file, not a second FINDINGS** — verified facts about this
  repo that every fresh agent would otherwise rediscover (real selectors, which fakes exist, what a
  helper accepts). Read it when you start, append to it when you finish. See
  [Agent orchestration](#agent-orchestration--parallel-where-its-free-batched-where-its-yours).
- **`docs/ENDPOINT_PERMISSIONS.md`** is the authoritative endpoint-permissions reference. Keep it
  current in the same change that adds or modifies endpoints.

## ⚡ graphify — use every session

```text
/graphify            # first run (builds graph from scratch)
/graphify --update   # incremental update (only re-extracts changed files)
/graphify query "architecture question"    # architecture questions instead of opening multiple files
/graphify explain "symbol"      # locate a concept or symbol
/graphify path "A" "B"          # dependency path between two modules
```

Outputs in `graphify-out/`: `graph.json` (source of truth), `GRAPH_REPORT.md` (god nodes,
communities, surprising connections), `graph.html` (interactive view).

Run `/graphify --update` at end of session if you touched docs or images (code changes rebuild via
hook if installed).

## ⚡ superpowers — use whenever applicable

Always prefer **superpowers** skills over ad-hoc approaches. If there's even a small chance a skill
applies to the task, invoke it via the `Skill` tool before acting (including before clarifying
questions).

- **Process skills first** — `brainstorming` before creative/feature work, `systematic-debugging`
  before fixing bugs, `test-driven-development` before writing implementation.
- **Then implementation skills** — domain-specific skills guide execution.
- **Verify before claiming done** — `verification-before-completion` / `requesting-code-review`
  before merging.

Flow: `brainstorming → spec (you approve) → writing-plans → plan (you approve) →
subagent-driven-development → finishing-a-development-branch`. **Nothing is implemented without an
approved spec.**

User instructions always take precedence over skills; skills override default behavior. **Skills
refine *how* the work is done; they never override the rules in this file. When a skill and this
`CLAUDE.md` conflict, this file wins.**

### Mode switch

- **"lite mode"** — fully disables superpowers: no skill is invoked, not even the applicability
  check, until **"normal mode"** is said.
- **"normal mode"** (default) — standard superpowers behavior, plus: when delegating coding work,
  dispatch at most 1 agent at a time, and never use a model above Sonnet (no Opus). The cap counts
  **implementation** agents: a read-only review agent runs alongside one, and should — see
  [Agent orchestration](#agent-orchestration--parallel-where-its-free-batched-where-its-yours).
- **"modo desatendido"** (unattended mode) — the user is away and delegates autonomy: work without
  waiting for confirmations and make reasonable decisions yourself instead of asking. In this mode you
  MAY **`git push` the feature branches you create** and **open PRs via `gh`** on your own, so the
  work is ready for review when the user returns. The hard limits still hold and are NOT lifted:
  **never merge anything** (no `git merge`, no fast-forward integration, no `gh pr merge`), **never
  push to `main`** or any protected/default branch directly, and **never** `git push --force` /
  `--force-with-lease`. Deliver everything as pushed branches + PRs for the user to merge. Reverts to
  defaults on **"normal mode"**.

Confirm the switch briefly when it happens.

---

## 🧠 Heavy jobs run inside a memory cgroup (MANDATORY)

**No exceptions:** any long or parallel job started here — the full test suite, coverage, mutation
testing, a production build, Playwright, a `turbo`/workspace fan-out, anything that spawns workers —
runs under a kernel-enforced memory ceiling:

```bash
systemd-run --user --scope --quiet -p MemoryHigh=5G -p MemoryMax=6G -p MemorySwapMax=0 -- COMMAND
```

**6 GB is the standing ceiling on this machine** (raised from 4 GB by the user on 2026-08-11); don't
exceed it without being told to. `MemoryHigh` throttles and reclaims, `MemoryMax` is the hard stop,
`MemorySwapMax=0` keeps the job from thrashing swap instead of respecting either. Verify it is
actually in force rather than assuming:
`systemctl --user show SCOPE_UNIT -p MemoryMax -p MemoryHigh -p MemoryCurrent`.

**Cap the tool too — but never *instead* of the cgroup.** Pass the tool's own concurrency limit
(`--concurrency`, `--maxWorkers`, `workers`, `--parallel`) so the job isn't throttled to a crawl by
the ceiling. A tool's default concurrency is not a budget, and an estimate of per-worker RSS is not a
ceiling. Only the cgroup is.

**Check that the ceiling reaches the process that does the work.** A job wrapped in the scope can
hand the real work to a **daemon or worker pool that lives outside it** — a build daemon reconnected
from a previous run, a container engine, a language server, a test runner attaching to workers that
were already up. The wrapper still reports the limit as applied, over a process that isn't doing
anything. The tell is `MemoryCurrent` sitting near zero while the machine swaps. Confirm against the
**worker's** cgroup, not the scope's: `cat /proc/WORKER_PID/cgroup`. If the worker is outside,
either kill the daemon so the job starts its own inside the scope, or configure the daemon's own
limit — a wrapper that reports success over an idle process is worse than no wrapper, because it
buys confidence and delivers nothing.

**Why this is a rule and not advice:** a mutation-testing run on this 24-core box sized its worker
pool from the core count and spawned **23 workers at ~2.3 GB each** — ~50 GB of demand on 31 GB of
RAM. It took the whole machine down hard enough that the user had to power-cycle it; `systemd-oomd`
did not save it. The run before that was wasted too: with the machine starving, **139 of the first
142 mutants "timed out"**, and a timeout is scored as *killed*, so the result came out inflated by
starvation and meant nothing. A job that OOMs the box doesn't merely fail — it also hands you
numbers you'd trust by mistake.

## Module strategy (source of truth — don't deviate)

1. **PKGBUILDs are Git submodules, never copies.** Each `packages/` directory matches its
   `pkgname`; its upstream packaging repository remains the source of truth. Edit/release there
   in a separately authorized task, then update the pointer here; never silently commit inside
   a submodule as if it belonged to the root repository.
2. **Pins identify packaging revisions.** Gitlinks fix exact SHAs. They do not freeze the mutable
   source HEAD consumed by the two `-git` font packages, nor the rolling container/AUR inputs.
   Their `pkgver()` derives the commit count and short SHA at build time.
3. **HTTPS submodule URLs** remain in `.gitmodules`; a local SSH `insteadOf` preference belongs
   in user Git configuration. All four entries currently use `ignore = untracked` (the spec
   highlighted the fonts, but the actual implementation applies it to all four).
4. **Keep upstream repositories alive.** `dasik-aur` releases feed `iso-bootstrap.sh`;
   `config-saver-aur` has its own packaging CI (preparation/static checks, not a full install smoke
   in the checked-in workflow). This root aggregates, it does not replace them.
5. **Standalone Bash scripts own the pipeline**, not inline workflow logic or a new shared library.
   The plan deliberately uses four short scripts; `make-repo.sh` owns signing and database assembly.
6. **AUR build dependencies are not products.** `aur-makedeps.txt` currently lists `font-patcher`.
   `makepkg --syncdeps` resolves official repositories only. Bootstrap the listed AUR packages
   in the disposable build container, then build the four products. Do not publish `font-patcher`
   or introduce `paru`/`yay` just to resolve it.

---

## Stack

Versions below are the approved plan's baseline, not a claim of installed or latest versions.

| Technology | Baseline | Role / state |
| --- | --- | --- |
| Bash | 5 | Standalone scripts; AUR bootstrap implemented |
| pacman / makepkg / repo-add | 7.1 in plan | Build and repository assembly implemented; see handoff for validation |
| GnuPG | 2.4 in plan | Dedicated signing identity; production setup belongs to user |
| namcap | Arch package | Advisory PKGBUILD/package diagnostics in the root build |
| ShellCheck | Available validation tool | Root scripts must be clean; justify individual suppressions |
| Git submodules | Four pinned Gitlinks | Implemented; own packaging repos remain authoritative |
| Arch Linux container | `archlinux:base-devel` | Container build environment on hosted/self-hosted runners |
| Podman + systemd cgroups | Local validation | Disposable build/install tests; mandatory memory ceiling |
| GitHub Actions + Pages | Implemented Task 6 | Build/sign/deploy `public/`; workflow exists; deployment pending |
| Dependabot | Implemented Task 6 | Weekly `github-actions` and `gitsubmodule` updates |
| Static HTML | Implemented Task 5 | Package index from `.PKGINFO`; no frontend runtime |

### Packages (`packages/`)

All four declare `arch=('any')`; the planned repository serves them under `x86_64/`.
Versions are committed PKGBUILD values at the baseline, not freshly built versions.

| Directory / pkgname | Upstream packaging repository under `amt911/` | Version | Source |
| --- | --- | --- | --- |
| `config-saver` | `config-saver-aur` | `3.4.0-1` | Release tag tarball |
| `dasik` | `dasik-aur` | `0.17.0-1` | Git source pinned to tag; `check()` runs compileall |
| `ttf-atkinson-hyperlegible-next-nerd-git` | `ttf-atkinson-hyperlegible-nerd` | `r17.7925f50-1` | Google Fonts upstream HEAD; AUR `font-patcher` |
| `ttf-atkinson-hyperlegible-next-nerd-mono-git` | `ttf-atkinson-hyperlegible-mono-nerd` | `r20.154d503-1` | Google Fonts upstream HEAD; AUR `font-patcher` |

### Technology ownership — what each part uses

This is the operative technology map for **both CLAUDE.md and AGENTS.md**. The two guides
instruct different agents working on the same stack; they do not prescribe different technologies.
The application-framework examples retained later from the template are not technology choices
for this project. Do not introduce them unless a new approved design changes the scope.

#### Root pipeline and publication

| Component | Technologies to use | Purpose / artifact | State |
| --- | --- | --- | --- |
| `scripts/build-aur-makedeps.sh` | Bash, Git over HTTPS, makepkg, sudo, pacman | Read `aur-makedeps.txt`, clone AUR build dependencies, build as `builder`, install only inside the build container | Implemented |
| `scripts/build-packages.sh` | Bash, makepkg, pacman dependency resolution, namcap, standard filesystem tools | Build all four pinned packaging recipes unsigned; collect `.pkg.tar.zst`; namcap findings advisory | Implemented, Task 3 |
| `scripts/make-repo.sh` | Bash, GnuPG, repo-add, symbolic links | Detached signatures, `.db.tar.zst` / `.files.tar.zst`, `.db.sig` / `.files.sig` aliases, armored public key | Implemented, Task 4 |
| `scripts/make-index.sh` | Bash, bsdtar, awk, sed, stat, HTML5 and plain CSS | Extract `.PKGINFO`, escape metadata, render package table and setup instructions into `public/index.html` | Implemented, Task 5 |
| Landing page | Static HTML/CSS, system fonts, CSS custom properties and `prefers-color-scheme` | Responsive document with light/dark styles, served directly by Pages; no JavaScript build or browser application runtime in the plan | Implemented, Task 5 |
| `.github/workflows/repo.yml` | GitHub Actions YAML, `archlinux:base-devel`, the four shell scripts, official Pages actions | Full build/sign/upload/deploy; same container on hosted or self-hosted runner | Implemented, Task 6 |
| `.github/dependabot.yml` | Dependabot YAML, `github-actions` and `gitsubmodule` ecosystems | Weekly action-version and packaging-pointer update PRs | Implemented, Task 6 |
| Local build verification | Rootless Podman, disposable Arch container, systemd memory cgroups | Execute the actual pipeline without modifying host packages; return artifacts via `.build-out/` | Recipe approved; local build verified |
| Local static verification | Bash syntax checks, ShellCheck; actionlint for workflow YAML | Check the actual shell/YAML surface; no root hooks installed | ShellCheck and actionlint verified |
| Client installation | pacman, pacman-key, GnuPG trust, HTTPS download via curl | Trust dedicated public key, require package/database signatures, install/update `[amt911]` packages | Documented contract; live service pending |
| Self-hosted runner | GitHub Actions runner, dedicated Linux user, systemd service, job-container support | Move build execution to the mini-PC using `BUILD_RUNNER`; preserve isolated Arch build environment | Implemented, Task 9 |
| Documentation | Markdown, approved spec/plan/handoff, paired Claude/Codex guides | Record contracts, decisions, operating steps and verification evidence | Present; operational guides in Tasks 7–9 present |

The intended root has no NestJS, Next.js, React, Prisma, PostgreSQL, Redis, pnpm, Turborepo,
Tailwind, shadcn, mail transport or application storage service. GitHub Pages stores and serves
the generated static repository. Those inherited template examples do not create dependencies.

#### `packages/config-saver`

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

#### `packages/dasik`

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

#### `packages/ttf-atkinson-hyperlegible-next-nerd-git`

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

#### `packages/ttf-atkinson-hyperlegible-next-nerd-mono-git`

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
`dasik` = `3273f3d38ce540013ba12e1b3e38738dcb56b1a4`;
regular font = `f625aa331e3433fb882006a1eb43d8bca5b971aa`;
mono font = `2bb3859f7ff49e13989dcb596128d890d47432a5`.
Use `git submodule status` to verify rather than treating this snapshot as a future constraint.

---

## Repository structure (Git submodules)

| Path | Responsibility | Baseline state |
| --- | --- | --- |
| `.gitmodules` + `packages/` | Four package submodules | Implemented, Task 1 |
| `.gitignore` | Reference material, build products and scratch exclusions | Implemented |
| `aur-makedeps.txt` | Newline-separated AUR build dependencies, `#` comments | Implemented, Task 2 |
| `scripts/build-aur-makedeps.sh` | Root orchestrator, unprivileged AUR makepkg, container install | Implemented, Task 2 |
| `scripts/build-packages.sh` | Build all PKGBUILDs unsigned; namcap advisory; collect archives | Implemented, Task 3 |
| `scripts/make-repo.sh` | Sign archives, repo-add, sign databases, export public key | Implemented, Task 4 |
| `scripts/make-index.sh` | Escaped HTML from package `.PKGINFO`, versions/sizes/links/setup | Implemented, Task 5 |
| `.github/workflows/repo.yml` | Container, triggers, four scripts and Pages deployment | Implemented, Task 6 |
| `.github/dependabot.yml` | Weekly Actions and submodule updates | Implemented, Task 6 |
| `docs/signing.md` | User key creation, secrets, loss/rotation, export cleanup | Implemented, Task 7 |
| `docs/usage.md` + `README.md` | Client setup, package installation, add/update packages | Implemented, Task 8 |
| `docs/self-hosted-runner.md` | Mini-PC runner setup and security | Implemented, Task 9 |
| `CLAUDE.md` + `AGENTS.md` | Equivalent project guides for Claude and Codex | Updated for Tasks 3–10 |
| `docs/superpowers/` | Approved spec, plan and committed handoff | Present |
| `.superpowers/` | Local SDD recovery ledger and scratch | Ignored; may be absent in another clone |
| `.build-out/` | Local container results consumed by Tasks 4–5 | Ignored, generated on demand |
| `public/` | Complete generated repository and landing page | Ignored, locally verified; production deployment pending |
| `resources/` + `claude-md/` | Local ArchWiki / canonical template references | Ignored; consult, never version here |

### Generated output contract

```text
public/
├── index.html
├── amt911.gpg                      # armored PUBLIC key only
└── x86_64/
    ├── amt911.db -> amt911.db.tar.zst
    ├── amt911.db.tar.zst            # with detached signature
    ├── amt911.files -> amt911.files.tar.zst
    ├── amt911.files.tar.zst         # with detached signature
    ├── *.pkg.tar.zst               # four products, current versions only
    └── *.sig                      # package/database signatures and applicable aliases
```

Regenerate `public/` from scratch, keep only current versions, and never commit it or package
archives. Retain repo-add symlinks: Pages upload dereferences them; do not add an `rm`/`cp` rewrite.

---

## Tests and quality

> **Project applicability — this table controls the inherited examples below.** The original
> test-policy detail is retained to preserve the template; web/mobile commands are reference
> examples, not installed tooling or additional scope for this packaging repository.

| Template rule | Here and why |
| --- | --- |
| TDD required for application logic | Exempt for the current packaging-only root per approved spec §8; equivalent evidence is clean makepkg, namcap no worse, and relevant shell/container checks. This does not waive upstream application tests. |
| Coverage ≥80%, critical ≥90% | Not applicable: no root application test suite. Do not invent a coverage score. |
| Blocking Playwright E2E | Replaced by disposable Arch install smoke: `pacman -U` actual archives and exercise entry points; inspect installed fonts/fontconfig for font packages, which have no CLI. |
| Native Android / Maestro | Not applicable: no Android/iOS application or emulator flow. Preserved below as generic template reference only. |
| Mutation ≥60% | Exempt for packaging infrastructure without a test suite/core application domain. Bash is executable; the exemption is not a claim that scripts cannot contain bugs. Reassess if scripts gain a suite/application logic. |
| Property-based tests, Zod/Pydantic, strict TS, Knip, npm audit | Tool-specific examples do not apply to the root. Validate shell inputs/artifacts, use ShellCheck, review actual upstream/AUR sources and dependency changes. |
| Full real-environment verification | Applies: disposable container/VM, signatures, metadata, installability and CLI/font smoke. Never host package installation for a test. |
| Memory cgroup + tool concurrency limit | Applies to all heavy local jobs, especially FontForge fan-out. |
| Existing tests and failure evidence | Never skip/delete tests to get green; report actual command output and unverified stages. |

The Run before declaring done / What to test per folder tables below describe the inherited web
example. The authoritative project checks and paths are in **Dev workflow**. No corresponding
`apps/`, `lib/`, `components/` or `hooks/` folders exist in this root.

- **Backend:** Jest + supertest — unit `*.spec.ts` colocated with source; e2e separate.
- **Frontend / shared:** Vitest + Testing Library + jsdom — `*.test.tsx` colocated.
- **Browser E2E: Playwright — mandatory**, not "when there are navigation flows". See
  [E2E (Playwright) — mandatory](#e2e-playwright--mandatory) below.
- **Coverage gate: 80%** (statements/branches/functions/lines) in `api`, `web` and `shared`.
  Critical logic ≥90%. Don't lower the gate — exclude infra with justification (Prisma client,
  migrations, `seed.ts`, `main.ts`, `*.module.ts`, `prisma.service.ts`, shadcn-generated). Before PR:
  `pnpm pr-check` (= `pnpm lint` + `pnpm test:cov`).
- **Mutation gate: 60% minimum** over the core-logic scope, blocking on push and reported in CI. A
  coverage gate is blind to a test with no asserts; this one is not. See
  [Mutation gate — the 60% floor](#mutation-gate--the-60-floor-and-it-only-goes-up).

### E2E (Playwright) — mandatory

**Why this is a hard rule.** Unit tests pass while the product is broken: the component renders, the
type-check is green, and then a real click hits an endpoint that doesn't exist, sends the wrong
payload shape, or returns 500. Mocked fetches hide exactly that class of bug, because the mock
encodes what the author *assumed* the API does. Only driving the running app against the real API
proves the feature works.

- **Every user flow needs a spec** — create / edit / delete, navigation, forms, filters, auth-gated
  screens. A slice with UI is not done until its flow has a Playwright spec.
- **Against the running app and the REAL API.** Boot the stack from Playwright's `webServer` (or a
  compose target) and hit real endpoints against a **disposable test database** — never the dev DB.
  **Do not stub the network layer in E2E**; that's what the unit/integration layer is for.
- **The minimum assert is not "the button exists".** A flow is verified when: the request actually
  goes out, it answers 2xx, the UI reflects the change, and **the change survives a reload**
  (i.e. it was persisted, not just optimistic local state).
- **Fail loudly on noise.** Wire `page.on('console')` and `page.on('response')` so the spec fails on
  console errors and on unexpected 4xx/5xx — those are the API mismatches this layer exists to catch.
- **Accessible locators only** — `getByRole`, `getByLabel`, `getByText`; never brittle CSS/XPath.
  This doubles as the semantics layer the agentic PR verification depends on (see
  [Agentic PR verification](#agentic-pr-verification-mandatory-on-every-pr)).
- **Blocking on push.** `pnpm test:e2e` runs in the pre-push hook; a red E2E means no push.
- **A UI bug fix gets a failing E2E first**, then the fix — same rule as unit regressions.
- **Non-web surfaces generalize.** Native Android (Jetpack Compose) → **Maestro**, which has the same
  mandatory status Playwright has here — see
  [Native Android (Jetpack Compose) — Maestro](#native-android-jetpack-compose--maestro) below;
  desktop shell → Playwright's `_electron`; API-only services → a `pytest` + `httpx` (or supertest)
  smoke that exercises the real HTTP surface. The rule is "drive the real thing", not "use Playwright".

### Native Android (Jetpack Compose) — Maestro

**Maestro is the E2E engine for native Android, exactly as Playwright is for the web** — same status,
same rule: a slice with a Compose screen is not done until its journey has a committed flow that runs
green against the real APK on an emulator. It is also the **discovery** tool: how you find out what
the running app actually exposes, instead of guessing selectors from the source.

Flows are YAML under `.maestro/`, one file per user journey (optional workspace `config.yaml` at the
root):

```yaml
# .maestro/example-flow.yaml
appId: com.example.app
name: Example journey (not applicable to this repo)
tags:
  - smoke
---
- launchApp:
    clearState: true
- tapOn:
    id: "example_add_item"       # Modifier.testTag — needs the opt-in below
- inputText: "example text"
- tapOn: "Example visible label"     # visible text also works
- assertVisible:
    text: ".*example.*"        # selectors accept regex
- extendedWaitUntil:
    visible: "Example screen title"
    timeout: 10000
```

```bash
maestro list-devices                          # what is actually connected
maestro start-device --platform=android --device-model=pixel_6 --device-os=android-33
maestro test .maestro/                        # a directory works; whole suite
maestro test .maestro/example-flow.yaml -c          # --continuous: re-runs on save while you iterate
maestro test .maestro/ --include-tags=smoke --format=JUNIT --test-output-dir=build/maestro
maestro check-syntax .maestro/example-flow.yaml     # exits 1 on an invalid command — a usable hard gate
maestro record --local .maestro/example-flow.yaml   # video, for a bug report or a PR comment
```

**The Compose gotcha that costs an afternoon.** `Modifier.testTag("x")` is **invisible to Maestro by
default**: Compose keeps test tags in its own semantics tree, while Maestro reads the Android view
hierarchy through UiAutomator. Until you opt in, only `text` and `contentDescription` are matchable —
so flows silently fall back to user-visible strings and break on the first copy edit or in the other
locale. Turn tags into resource ids once, on a root composable:

```kotlin
@OptIn(ExperimentalComposeUiApi::class)
Box(Modifier.semantics { testTagsAsResourceId = true }) { ExampleAppNavHost() }
```

Then `tapOn: { id: "example_add_item" }` resolves.

#### Discovery — ask the running app, don't guess

```bash
maestro hierarchy             # full view hierarchy of the connected device
maestro hierarchy --compact   # CSV: element_num,depth,attributes,parent_num — greppable
maestro mcp                   # MCP server over STDIO: device + automation as tools for an agent
```

`maestro hierarchy` is the ground truth about what is reachable: **if a control isn't in that tree, no
flow can tap it and no screen reader can announce it** — that is an accessibility bug before it is a
test problem. Run it before writing a flow and after adding a screen. `maestro mcp` exposes the same
capabilities to an LLM agent over MCP, which is what the agentic PR pass should drive instead of
screenshot coordinates.

> `maestro studio` was removed in Maestro 2.x — use `hierarchy` and `mcp`. Check `maestro --help`
> before trusting a command you remember; the CLI moves.

The rules mirror the Playwright ones:

- **Against the real APK on an emulator**, never a mocked backend. Boot one with `maestro start-device`
  if `maestro list-devices` shows nothing; `--device` picks the target when several are attached.
- **`clearState: true`** at the top makes a flow independent — and it **wipes that app's data on the
  device**, so flows belong on a dedicated emulator, never on a daily phone.
- **Prefer `id` over `text`** once `testTagsAsResourceId` is on. Text selectors are copy- and
  locale-dependent; if the app ships two locales, a text-only flow is a flow that passes in one of them.
- **A UI bug fix gets a failing flow first**, then the fix.
- **`maestro check-syntax` in the pre-commit hook** — it exits non-zero on an invalid command, so a
  typo'd `tapOnn` never reaches CI. `--format=JUNIT --test-output-dir=…` is what CI consumes.
- **`--headless` is web-only.** It does nothing for an Android run; don't reach for it when a flow hangs.

### Run before declaring done

| Change touches               | Run before claiming success                                          |
| ---------------------------- | -------------------------------------------------------------------- |
| backend service/controller   | `pnpm --filter @example/api test` (+ `pnpm test:e2e` if cross-module) |
| frontend component/hook/util | `pnpm --filter @example/web test`                                    |
| **any user-facing flow** (new screen, form, button wired to an endpoint) | `pnpm test:e2e` — **required**, unit tests do not prove the flow works |
| something ambiguous or large | `pnpm test:all`                                                      |

### What to test per folder

| Folder | What | Status |
| --- | --- | --- |
| `lib/` | Pure utilities, hooks — deterministic, minimal mocks | Pending |
| `components/` | Logic-bearing components: forms, dialogs, toggles. Mount + `user-event`. Exclude UI primitives | Pending |
| `hooks/` | Custom hooks via `renderHook`. Mock timers/fetch only when unavoidable | Pending |
| `src/*` services / `app/api/` | Call the exported handler/service directly; check status codes, validation, error paths | Pending |

### TDD — required for new logic

For new code in `services/`, `lib/`, `hooks/`, non-primitive `components/`, shared schemas and form logic:

1. **Red** — write a failing test that describes the behavior.
2. **Green** — implement the minimum to pass.
3. **Refactor** — clean up under green tests.

Exceptions (TDD not required): pure visual/style changes (CSS, layout, copy); UI primitives (tested
indirectly by consumers); spikes/exploration — but add tests before merging.

### Hard rules (no exceptions)

- **Never claim done without showing test output.** "Type-check passes" is not "it works".
- **New endpoint / DTO / hook / schema → needs a test.** No exceptions.
- **A bug fix needs a failing regression test first**, then the fix (see `systematic-debugging`).
- **Never delete, `.skip` or `.only` a test to get green.** Fix the code or the test on purpose.
- **No feature with UI is done without a green E2E against the real API.** Driving the running app
  is the proof — **Playwright** on web, a **Maestro flow on a real emulator** for a Compose screen;
  type-check, unit tests and a screenshot are not. If the flow has no spec, the flow is not finished.
- **Never mock the API to make an E2E pass.** A mocked E2E proves the mock works, not the product.
- **Don't lower the 80% gate to ship** — exclude untestable modules in config with a written reason.
- **Test over mock** — exercise real code with minimal stubs; don't mock entire modules.

### Operative conventions

- **Global setup file** — define `matchMedia`, `ResizeObserver`, `IntersectionObserver`,
  `localStorage` stubs once. Don't redefine per test.
- **Split by aspect** when a test file exceeds ~300 LoC: `.flow.test.ts`, `.errors.test.ts`,
  `.branches.test.ts`.
- **Exclude with justification** in config, never silently. Example:

  ```js
  // JSDOM cannot simulate layout/animation timing — cover via E2E
  exclude: ['src/hooks/use-grid-reflow.ts']
  ```

## Quality beyond coverage

> **Packaging scope:** use the applicability table above. The tools and numeric gates below
> remain the canonical reference for a future applicable application scope; none is installed or
> measured here. Real build/install/signature checks and ShellCheck provide the current evidence.

**Coverage measures how much code runs, not whether it's correct.** This is especially treacherous
with AI: it tends to write the test *and* the code in one move, so if it misread the requirement, both
encode the same mistake and the test passes happily. 80% coverage with weak asserts is a false sense
of security. These gates attack that blind spot.

- **Mutation testing** *(highest priority — and the one gate with a hard number, see below)* —
  **Stryker** (JS/TS), **PITest** (Kotlin/JVM), **mutmut** / **cosmic-ray** (Python),
  **cargo-mutants** (Rust) inject deliberate bugs (`>` → `>=`, drop a line, flip a boolean) and check
  some test fails. A surviving mutant means the code is *covered but not verified*. **Concrete recipe
  that works:** scope `mutate` to a **pure compute function extracted out of the service**
  (mocked-ORM tests can't kill query-shape mutants), pick the runner per package (jest-runner vs
  vitest-runner), and set `thresholds: { high: 90, low: 80, break: 60 }` — `break` is the gate and 60
  is the floor. This is the direct antidote to AI's misleading coverage.
- **Property-based testing** *(highest priority)* — **fast-check** (JS/TS), **Hypothesis** (Python).
  Define invariants ("deserialize(serialize(x)) == x", "final price is never negative") and let the
  framework generate hundreds of cases, including the weird boundaries nobody thinks of. Catches logic
  errors that hand-picked examples miss.
- **Runtime boundary validation** — **Zod** (TS), **Pydantic** (Python) to validate everything
  crossing a boundary: API responses, forms, DB data. AI trusts types that don't hold at runtime; this
  turns those assumptions into explicit errors instead of silent failures.
- **Strict types + static analysis** — TypeScript in real `strict` mode (**including
  `noUncheckedIndexedAccess`**), type-aware ESLint, and a SAST (**Semgrep** or **CodeQL**). SAST
  matters because AI introduces vulnerabilities easily (injection, hardcoded secrets) that no
  functional test catches.
- **E2E / smoke tests** *(mandatory, not a nice-to-have)* — **Playwright** (web), **Maestro**
  (native Android/iOS — YAML flows plus `maestro hierarchy`/`maestro mcp` for discovery). Verify what
  unit tests can't: that the app *actually boots* and the full flow
  works. Code routinely passes every unit test while the app won't start or the frontend assumes an
  API contract the backend doesn't honor. This is the single highest-yield gate against
  "implemented but broken on first click" — see the hard rules in
  [E2E (Playwright) — mandatory](#e2e-playwright--mandatory).
- **Dependency auditing** — AI invents non-existent packages ("slopsquatting") and pulls vulnerable
  versions. Use `npm ci` with a frozen lockfile, `npm audit` / Dependabot / Snyk in CI, and verify
  every new dependency actually exists and is the one you think it is.
- **Dead-code elimination** — **Knip** (JS/TS) finds unused files, exports, types and dependencies
  across the workspace (monorepo-aware; auto-detects Next/Vite and `pnpm` workspaces). Drop a
  `knip.json` at the repo root (zero-config to start: `{ "$schema": "https://unpkg.com/knip@5/schema.json" }`)
  and run `pnpm dlx knip` — or add a `"knip"` script once you want it in the loop. Pruning dead code
  shrinks the surface every session (and the AI) has to reason about and keeps `package.json` honest,
  complementing the dependency audit above. AI-written code accretes orphaned helpers and unused
  exports fast, so run it periodically on web projects.

**Process rule (worth more than any tool): don't let the AI define the acceptance criteria.** You
write or review the important test cases yourself — at least the key asserts and the requirement's
edge cases — and have the AI implement against them. That breaks the loop where the same
misunderstanding lives in both the test and the code. Mutation testing is the automated backstop for
this, but the judgment about *what the system should do* stays yours.

Priority by immediate payoff: **mutation + property-based testing first** (they hit the current blind
spot), then **runtime validation and a couple of E2E smoke tests**.

### Mutation gate — the 60% floor, and it only goes up

Coverage answers *"did any test run this line?"*. Mutation answers *"would any test have noticed if
the line were wrong?"*. A test with no assert scores 100% coverage, which is why this gate is the one
with a hard number attached.

- **Floor: 60%**, measured over the **core-logic scope** — `the application core (no applicable root scope today)` — not the whole tree. Repositories, DAOs, framework glue and view code dilute the score
  into noise: a mutant inside a mocked query is not a bug anyone can write a test against. Scope
  narrow, gate hard; scope wide, gate meaningless.
- **The threshold is a ratchet.** Set it to today's real score rounded down, never under 60, and
  raise it in the same PR that raises the score. **Lowering it to make a push go through is exactly
  what the gate exists to prevent** — a score that dropped means a test stopped verifying something.
- **Not at 60 yet?** Ship the gate **advisory** (it reports, it never fails) with the current score
  and the date written next to it, and owe a PR that reaches 60 before the next feature. Advisory is
  a waypoint, not a resting place.
- **Doesn't apply to this repo?** Write that here, with the reason (no executable code; packaging-only;
  byte-matching decompilation; generated sources). An unwritten exemption gets re-litigated every few
  months; a written one does not.
- **It does not mean chasing 100%.** Equivalent mutants exist (inlined stdlib, generated glue,
  coroutine/async branches) and are annotated and left alone, not tested into submission.

Read the report before quoting a number: **SURVIVED and NO_COVERAGE mean opposite things** and the
headline percentage mixes them. A survivor is code that runs while nothing asserts on the result — a
real hole. NO_COVERAGE is code the mutation runner never reached, which is often a runner limitation
(Robolectric under PITest, for one) rather than a missing test. Split them before quoting.

The fix for a survivor is almost always the same: **assert the concrete expected value, written out
by hand**. A test that recomputes the expectation with the same expression the code uses moves with
the mutation and agrees with it — 100% line and branch coverage, zero verification.

| Stack | Tool | Gate command |
| --- | --- | --- |
| JS/TS | **Stryker** | `pnpm test:mutation` (`stryker run`, `thresholds.break: 60`) |
| Kotlin / JVM | **PITest** | `./gradlew pitestDebug -Ppitest.threshold=60` |
| Python | **mutmut** (or **cosmic-ray**) | `mutmut run` + a score check on `mutmut results` |
| Rust | **cargo-mutants** | `cargo mutants --in-place --error-percent 40` |

**A mutation run is a heavy job** — it forks one JVM/worker per core and sizes nothing for you. Run it
inside the memory cgroup and cap the worker count: see
[Heavy jobs run inside a memory cgroup](#-heavy-jobs-run-inside-a-memory-cgroup-mandatory).

---

## Real-environment verification — what no in-process test can prove

> **Here:** drive actual Arch artifacts in a disposable container/VM. The approved plan contains
> the commands for Tasks 3–5 and 11; a standalone acceptance script has not been implemented.
> Treat its filename below as a future convention, not an existing runnable file. Do not create
> or claim that packaging validation ran that upstream suite.

Some properties are invisible to the entire in-process suite no matter how many tests you add,
because the test runtime never restarts a process, never talks to a real server, never runs out of
disk, and never lets the scheduler cancel anything. **jsdom is not a browser, a mocked ORM is not a
database, a fake clock is not time, and an in-memory DB is not the one the user has on disk.**
Those properties need a script that drives the **real artifact on real hardware** — a real browser,
an emulator, a VM, a container, the target machine — and asserts on what is externally observable:
log lines, exit codes, HTTP responses, rows in the database, files on disk.

**Write that script, commit it, and name it here.** It must run by hand with no arguments, print a
per-phase `PASS`/`FAIL`, and exit non-zero on the first failure:
`scripts/verify-repo-in-container.sh (proposed, not implemented)` (flags: `--no-install`, `--keep-state` (illustrative, not implemented)).

**The run happens on real hardware or an emulator — never on a stand-in for the thing under test,**
and never on the user's daily device/workstation when the check writes state. Boot the emulator /
disposable VM / throwaway container; that is the target.

### The names, so you can ask for them by name

| Name | What it means |
| --- | --- |
| **E2E / on-device acceptance test** | Drives the real build against the real backend and asserts on observable behaviour — log lines, HTTP status, rows in the DB, files written — never on internals. The phases of the script above. |
| **Contract test** | Checks that the **client's assumptions about the server's responses** actually hold. These are exactly the assumptions no type system on the client side can see: a filter that is a strict `>` and not `>=`, a timestamp column stored with microseconds, a field the docs call optional and the server always sends. |
| **Mutation testing** (on real hardware: by hand) | Revert the fix, re-run the check, confirm it goes red, restore. Stryker / PITest / mutmut automate this for in-process code; against a device or a machine you do it manually. **A check that has never failed has not been tested.** |
| **State-invariant test** | Asserts a relationship **between two stores** that no single unit test owns — e.g. a delta watermark must never outlive the database it describes. Each store is individually correct; the pair is what breaks. |
| **Test pollution / isolation leak** | A test writing to *production* state — the installed app's storage, the dev database, the user's config directory, the real keystore. It passes, and quietly destroys data on the next run. |

### Rules that came out of real bugs, not theory

- **Prove every new check can fail before you trust it green.** Revert the fix, watch the check go
  red, restore it. This applies to unit tests written after the fact *and* to real-environment
  checks. A green you have never seen turn red is not evidence.
- **Never assert on a count you cannot predict.** A check that fails "above five rows" reports PASS
  against a deliberately broken build whenever the data happens to cluster differently — how many
  rows a bad cursor drags back depends on the dataset, not on the bug. Assert the **invariant**
  (the watermark carries milliseconds; the response is empty; the ids match), never a symptom whose
  magnitude varies with the data.
- **A watermark, cache marker or cursor must die with the data it describes.** Clearing one without
  the other is silent, permanent data loss — no crash, no log, no failing test.
- **Anything that touches machine-global state must restore it.** Device storage, the user's config
  dir, the real database, the system keystore, installed packages: save it, and restore it in the
  teardown that runs even when the test fails.
- **Run the real-environment suite the way that actually works on this machine**, not the way the
  docs say. When the canonical task hangs, deadlocks or needs a display this box doesn't have, write
  the command that works into `docs/FINDINGS.md` and use it:

  ```bash
  # No alternative command measured yet; record verified workarounds in docs/FINDINGS.md.
  ```

---

## Debugging — keep the loop from running away

What a bug costs is not the fix. It is the number of times you go around
`build → deploy → reach the state → observe` before you know what to fix, multiplied by what one
lap costs. Everything below attacks one of those two factors. **Each rule carries the number it
came from** — a real 15 h session — because a rule with no measured cost behind it gets deleted in
the first cleanup. Where this project hasn't measured its own, the number is marked
`<!-- pendiente de medir -->` until someone does.

### The loop is the cost

- **Measure before you ablate.** Ablation costs one lap per hypothesis and answers yes/no.
  Instrumentation costs one lap total and answers *what is actually happening*. **Measured: 28
  ablations over 1 h 42 min ruled things out and moved nothing; a single batch of probes, 13 min,
  changed the question and the bug fell on the next round.** The rule that batch produced: **if a
  pipeline completes every phase with non-empty output, the output exists** — stop asking "why
  doesn't it appear" and start asking "where does it appear". They are different questions and the
  second one is cheap.
  Pipeline here: AUR bootstrap → package build → signing/repo-add → index → Pages → pacman.
- **Budget the lap, then attack the dominant term.** Time the four phases once and write the real
  numbers into the table below; one of them dominates and the other three are noise. In the measured
  case "reach the state" was 60 s × 30 reproductions — half an hour of pure waiting — and it died to
  a shortcut nobody had bothered to write. **If a bug needs more than three reproductions, write the
  shortcut before the fourth**: a deep link, a dev-only route, an environment snapshot, a seeded
  fixture. Commit it as `scripts/repro-repo.sh (create only for a reproduced bug)` and name it in the `docs/FINDINGS.md` entry, so
  the next person pays zero.

  | Lap phase | Command here | Measured |
  | --- | --- | --- |
  | build | Plan Task 3 Step 4, disposable Arch build | Measured in local build; see handoff |
  | deploy / install | Disposable `pacman -U`; live Pages only in Task 11 | Not measured |
  | reach the state | CLI help/check or font discovery inside test container | Not measured |
  | observe | Exit status, `.PKGINFO`, signature checks, installed files | Not measured |

### A finding is not a reproduction

- **Whoever reviewed read the code; they did not run it.** Reproduce a review finding yourself
  before sending anyone to fix it, and **if the implementer says they can't reproduce it, believe
  the implementer over the reviewer** — one of them has the thing running. **Measured: 1 h 25 min
  spent chasing a bug that did not exist.** This is the same reason the agentic PR pass is advisory
  and never vetoes on its own (see
  [Agentic PR verification](#agentic-pr-verification-mandatory-on-every-pr)), and the reason
  `receiving-code-review` asks for verification rather than agreement.
- **A test that refuses to go red is data, not a failure.** The fourth failed attempt to pin down
  that non-existent bug is precisely what uncovered the real one, pointing the opposite way.
  Reporting "I cannot make this fail" is a result and it gets reported; covering it with a green
  test throws away the only signal the round produced.
- **Before demanding a red, ask whether the mechanism can produce one.** If another layer of the
  framework masks the effect, no amount of insisting will turn the test red, and the time goes into
  the test instead of into the bug. **Measured: over 1 h on two reds that were structurally
  impossible.** Establish that the failure is observable at that layer first; if it isn't, move the
  assertion to the layer where it is — that is what
  [Real-environment verification](#real-environment-verification--what-no-in-process-test-can-prove)
  is for.

### Tests that cannot fail

The [mutation gate](#mutation-gate--the-60-floor-and-it-only-goes-up) already names the worst case —
an expectation recomputed with the same expression the code uses, which moves with the mutation and
agrees with it. It is not the only one. **Enumerate for this stack the assertions that are inert by
construction**, because none of them show up as a failure, a warning, or a coverage drop:

| Inert by | Looks like | Applies here |
| --- | --- | --- |
| masked exit status | `\|\| true`, advisory namcap treated as proof, or a later successful command hides failure | Yes: assert required stage exit codes directly; namcap is explicitly advisory |
| asynchronous shell work never waited for | Child fails after the parent reports success | Possible in shell/FontForge orchestration; collect child status |
| permissive stand-ins | Mocked makepkg/pacman/GPG always succeeds | Such stubs cannot replace real container acceptance |
| expectation computed like the code | Expected package list comes from the same faulty glob | Compare against the explicit four expected product names and independent metadata |

No root suite has been run with deliberately broken assertions yet; that measurement is pending.
JS snapshots and coroutine-runtime assertions are not part of this shell stack.

**Every assertion is watched failing once**, and expected values are written out by hand. This is
the same rule [Real-environment verification](#real-environment-verification--what-no-in-process-test-can-prove)
states for on-device checks — it applies to in-process tests with no exception.

### The environment is a claim until it is measured

- **Verify the limit reaches the process doing the work** — see the check in
  [Heavy jobs run inside a memory cgroup](#-heavy-jobs-run-inside-a-memory-cgroup-mandatory). A
  wrapper that reports success over an idle process is worse than no wrapper: it buys confidence
  and delivers nothing.
- **Environment claims get measured or they don't get made.** "That heap sounds low" produced a
  recommendation that was simply wrong. Measuring it — three runs per setting, GC pause totals, real
  peaks, not one run each — gave a **0.4% difference, below the run-to-run variance**. **No
  performance tuning lands without a before/after over more than one run**, and a difference smaller
  than the spread between runs is not a difference.

### Locate the rule before you pick a side

- **A rule that lives in one layer and isn't shared by the others fails in the wrong place.** The
  symptom surfaces where the assumption breaks, not where it is written, which is why the fix keeps
  landing in the innocent layer. Find which layer owns the rule first, then decide which side gives.
  The **contract test** row in
  [Real-environment verification](#the-names-so-you-can-ask-for-them-by-name) is how you pin one
  down once you know it exists.
- **Replacing a component can remove capabilities in silence.** When you swap one API for another,
  enumerate what the old one did that the new one does not, and say it out loud in the PR — nothing
  will fail to compile. **An optional parameter that defaults to off is a capability that only
  exists if the caller remembers it**, which over a few months means it does not exist.

---

## Dev workflow (Bash scripts and disposable Arch containers)

Read-only baseline and cheap checks from the root:

```bash
git status --short
git submodule status
bash -n scripts/build-aur-makedeps.sh
shellcheck scripts/*.sh
```

A fresh clone needs `git submodule update --init --recursive` before a build. Do not run
`git submodule update --remote` as a build step: that changes the pinned packaging input.

### Updating a package pointer (only when requested)

For example, after `dasik-aur` has published the desired packaging revision:

```bash
git -C packages/dasik fetch origin
git -C packages/dasik checkout --detach origin/main
git diff --submodule=log -- packages/dasik
```

Select the intended fetched tag or SHA instead of `origin/main` when updating to a release;
review the revision before committing the root Gitlink. Publishing the upstream revision is a
separate user action. Add a new package with `git submodule add` using its HTTPS repository URL
and a `packages/` directory equal to `pkgname`; review its pin and AUR dependencies. The planned
pipeline discovers `packages/*/PKGBUILD`; never edit the workflow per package.

### Full local build

The current tested recipe is in [docs/build.md](docs/build.md), superseding the plan's
original uncapped fan-out. It keeps the checkout read-only and copies only scripts,
packages and the manifest into the container. Returned artifacts are under `.build-out/`.
The local host lacks cpuset delegation; use taskset and explicit container memory limits
as documented there. The systemd wrapper alone does not constrain Podman's separate scope.

### Script environment contract

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

### Verification commands and required evidence

| Change | Required verification |
| --- | --- |
| Guide only | Template comparison, policy parity, links, placeholder and whitespace checks |
| Root shell scripts | `bash -n`, `shellcheck scripts/*.sh`, relevant error paths and real container run |
| Package build | Four product archives, correct `.PKGINFO`, clean makepkg, namcap no worse |
| Signing / repo assembly | Verify package and database signatures, tar contents, public key, empty-input failure |
| HTML index | Actual package metadata, escaped output, valid links and matching pacman setup snippet |
| Workflow (once present) | `actionlint` or container equivalent below; verify step order and failure behavior |
| Installation | Disposable Arch environment: `pacman -U` + CLI smoke; font files/fontconfig discovery |
| Live deployment | Task 11 only after user setup/authorization; HTTPS artifacts, signature trust, pacman listing/install |

Workflow check after Task 6 (container launch also follows memory policy):

```bash
systemd-run --user --scope --quiet -p MemoryHigh=5G -p MemoryMax=6G -p MemorySwapMax=0 --   podman run --rm -v "$PWD:/repo:ro" -w /repo rhysd/actionlint:latest
```

Local build and isolated signing checks were run during continuation; see the handoff for
installation evidence and exact limitations. Production deployment remains unverified.

## Containers & deploy (Arch Linux on GitHub Pages)

**Implemented, not deployed.** GitHub Actions uses a job-level `archlinux:base-devel` container,
with `runs-on: ${{ vars.BUILD_RUNNER || 'ubuntu-latest' }}`. Keep that container on self-hosted
hardware too; changing the repository variable moves runners without editing the workflow.
CI does not nest Podman/Docker invocations; Podman is for local verification.

Pipeline: install tooling → recursive checkout → create builder → AUR bootstrap → unsigned
package build → import dedicated root signing key → sign/assemble with `make-repo.sh` → remove private keyring →
configure Pages → generate index → upload `public/` → deploy Pages.

**Signing refinement over the spec's original example:** makepkg runs unsigned as `builder`.
The private key never enters builder's keyring; root signs afterward with explicit loopback
pinentry and passphrase file descriptor. The fourth script `make-repo.sh` also keeps repo-add
out of YAML. Do not restore the older `makepkg --sign` example from the spec/handoff.

The root workflow must fail if a package build fails, no PKGBUILDs exist, no archives are produced,
or signing cannot complete. Do not publish a partial or unsigned repository; retain the last
successful deployment. `namcap` remains advisory. Configure Pages before index generation so
`steps.pages.outputs.base_url` exists instead of silently falling back to a stale URL.

### Client contract (planned public service)

Public base URL: `https://amt911.github.io/arch-packages`.
The user downloads `amt911.gpg`, imports it with `pacman-key --add`, and locally signs its verified
fingerprint with `pacman-key --lsign-key`; import alone leaves unknown trust. Never invent a
fingerprint. The user adds this before `[core]` in `/etc/pacman.conf`:

```ini
[amt911]
SigLevel = Required
Server = https://amt911.github.io/arch-packages/$arch
```

Pacman substitutes `$arch`; retain it literally. Packages and database require signatures.
Then the user runs `sudo pacman -Syu`, `pacman -Sl amt911`, and installs products such as
`sudo pacman -S dasik`. These are instructions for later authorized setup, not commands to run
on the daily workstation as a test. Guides and generated page must show the same snippet.

### Self-hosted runner safeguards (binding design)

- Public repository: never execute fork pull requests on the mini-PC. No `pull_request` trigger
  in the deployment workflow; pushes only to `main`, daily schedule and manual dispatch.
- Require approval for all external contributors in Actions settings.
- Dedicated `github-runner` system user, its own home, no sudo; actual build inside the container.
- Register the runner at repository scope, not organization/account scope.
- Managed systemd service with `Restart=on-failure`, not an abandoned tmux session.
- Production signing secrets and Pages-source changes belong to the user. The signing guide
  covers dedicated identity, armored export, secret upload, deletion of exported private material,
  key loss/rotation, re-signing and renewed client trust. Never commit the private key.

## CI & git hooks

**The root CI workflow is implemented; no Git hooks are installed.** Submodule CI belongs to the
respective upstream packaging repositories; it is not proof that this root pipeline ran.
No pnpm, Husky, lint-staged, commitlint, coverage or mutation command is wired here.

Task 6 implements `.github/workflows/repo.yml` with:

- Pushes to `main` affecting `packages/**`, `aur-makedeps.txt`, `scripts/**` or the workflow itself;
  `schedule: '0 4 * * *'` (04:00 UTC daily) and `workflow_dispatch`. Never `pull_request`.
- Daily full rebuilds update the `-git` fonts when their upstream HEAD changes. If it does not,
  deterministic `pkgver()` stays the same and pacman sees no new version. No artificial churn.
- `permissions`: `contents: read`, `pages: write`, `id-token: write`.
- `concurrency`: group `pages`, `cancel-in-progress: false`; serialize complete deployments.
- Approved action baseline from 2026-09-15: `actions/checkout@v7`,
  `actions/configure-pages@v6`, `actions/upload-pages-artifact@v5`, `actions/deploy-pages@v5`.
  These are plan pins, not newly checked latest versions. Dependabot maintains major tags.
- Weekly Dependabot ecosystems **both** `github-actions` and `gitsubmodule`.
- Full builds intentionally run in CI because producing signed packages is the workflow's
  purpose; the template's lean web CI preset does not apply. ShellCheck is a required development
  check, namcap advisory; do not claim either has a root CI gate before inspecting the actual YAML.

Out of current scope: incremental builds/artifact caches, `repository_dispatch` from upstream
repos, `aarch64` and actual AUR publication. Incremental builds require preserving earlier
archives and change the approved regenerate-from-scratch architecture. The `*-aur` repositories
currently refer to GitHub packaging repos, not proof of publication to `aur.archlinux.org`.

---

## Agentic PR verification (MANDATORY on every PR)

> **Project engine:** packaging/build/install/signature smoke in a disposable Arch environment
> replaces the web/mobile engines below. Inspect metadata, public-key/database signatures,
> published paths and pacman behavior; deterministic checks remain authoritative and exploratory
> findings advisory. No root `scripts/verify/verify-pr.sh` or MCP verification config exists yet.
> Preserve the report/manual-test-plan requirements, but do not claim a pass without running it.
> Posting comments requires the authorization of the active session/platform; this guide-writing
> task authorizes no external message. The handoff's never-push/never-merge rule still applies.

**Every PR MUST be verified end-to-end before merge, and the verdict MUST be posted as a PR comment**
(`gh pr comment`). Running the pass and posting the verdict is **not optional**. Once a PR exists, a
headless agent **drives the running app end-to-end** and posts the verdict, then **waits for you to
close/merge**. Its job is to catch what diffs and unit tests miss: missing buttons, unimplemented
content, dead flows, screens that don't match the spec. The verdict is informational for gating (it
never merges anything) — but producing it on every PR is required.

- **Local & headless.** Runs on your machine via `claude -p` (headless/print mode), posts with
  `gh pr comment`. No CI minutes, no repo secrets. Fits an unattended loop.
- **Two surfaces, two engines** (one orchestrator picks by which paths the PR touched):
  - **Web** → **Playwright MCP** (headless Chromium) against `localhost`.
  - **Native mobile (Compose / SwiftUI)** → **`maestro mcp`** — Maestro's own MCP server, which
    exposes the same device and automation commands the committed flows use, so whatever the agent
    discovers can be written straight back as a `.maestro/` flow. It navigates the native
    **accessibility tree** over `adb` rather than screenshot coordinates. Run it against an
    **emulator or a dedicated test device**, and pair it with `maestro hierarchy` to see what is
    actually reachable. Alternatives if it is unavailable: **mobile-mcp**, or **appium-mcp**
    (UiAutomator2 / XCUITest drivers). iOS analog via the XCUITest driver.
  - **Any other runnable surface** generalizes the same way — Playwright covers any web app;
    Python / API smoke via `pytest` + `httpx`.
- **Reliability key = semantics.** Agentic navigation is only as reliable as the accessibility layer:
  good ARIA roles on web, `Modifier.testTag(...)` / `contentDescription` / `Modifier.semantics { }` on
  Compose. Without labels the agent falls back to fragile screenshot coordinates. **Audit that the
  flows you verify are labeled** before relying on this.
- **Two layers.** Deterministic tests (Playwright specs on web, Maestro flows + Espresso/Compose on
  mobile) are the
  **hard merge gate** — they already ran and passed pre-push, so the PR arrives with its flows
  proven. The agentic pass is **advisory**: it explores the new surface, **writes the regression
  specs that are missing** (a flow the agent had to discover by hand is a flow with no spec — that's
  a finding, report it), and leaves a readable verdict. Because the agent is
  non-deterministic, it **never vetoes a merge on its own** — its value is coverage and a legible
  report, not gatekeeping.
- **Cases come from the spec.** Draw the scenarios from the spec's `## Cases` / `## Casuísticas` block;
  tag them `[web]` / `[mobile]` when one spec covers both surfaces.
- **Trigger.** It's the **last step of the superpowers pipeline, right after a PR exists**:
  - **"modo desatendido"** — the agent pushes the branch, opens the PR, and fires verification itself.
  - **"normal mode"** — you open the PR; the agent then runs the local `verify-pr.sh` and posts the
    verdict (**mandatory before merge**, not merely on request — running the script + `gh pr comment`
    needs no push, so this respects the never-push default). Runnable by hand anytime.
- **Hard limits** (these do not relax in any mode): the verdict **awaits your close** and the agent
  **never merges** — see **Git & GitHub**. Point it at a **dedicated emulator / test device, never your
  daily phone**. Scope `--allowedTools` to exactly what the run needs; `--dangerously-skip-permissions`
  only in a controlled local env, never as a habit. Confirm flag names with `claude -p --help`.

Pasteable orchestrator (`scripts/verify/verify-pr.sh`) + `.mcp/*.json` configs: see
`claude-md/docs/PROMPT_TEMPLATES_WEB.md` (local ignored reference) §9.

---

## Agent orchestration — parallel where it's free, batched where it's yours

> **Project override:** one subagent total, including reviews; no parallel-review exception here.
> Preserve the scheduling rationale below as template context, but perform implementation and
> review sequentially. Exclusive resources are the writable package checkout, build output
> (`public/` or `.build-out/`), build container pacman database, and signing keyring; only one
> writer owns each. The FontForge build also shares the machine's mandatory memory budget.
> Root `docs/FACTS.md` is not created yet. Use the ledger/handoff now; if created in later work,
> every fact records verification method and date, never plans or assumed measurements.

Delegating work to agents moves the bottleneck from typing to **scheduling**: what waits on what,
what each agent has to rediscover, and which decisions quietly stop being yours. Same convention as
[Debugging](#debugging--keep-the-loop-from-running-away) — every rule carries the number it came
from, out of the same measured 15 h session.

- **Review is not on the critical path.** Reviewing task N and starting task N+1 are independent
  whenever they touch different files. Serialized, review is **10-15% of the wall clock** and blocks
  everything queued behind it; run in parallel it costs nothing at all. **On receiving an
  implementation report, dispatch its review and the next implementation in the same turn.**
  This is the one sanctioned exception to *"at most 1 agent at a time"* in
  [normal mode](#mode-switch): the cap is one **implementation** agent. A review agent reads and
  reports — it writes nothing, so it cannot race the implementer.
  Project values: one subagent total; exclusive resources and sequential review are specified above.
- **Keep one shared facts file.** Every fresh agent rediscovers the same things: the real selector,
  which fake already exists, what that helper actually accepts. Keep `docs/FACTS.md` in the
  workspace, have each agent append to it when it finishes, and hand it to the next one in its
  dispatch. What belongs there: **facts verified against the repo or the device**, never opinions or
  plans. It is not `docs/FINDINGS.md` and does not replace it — FINDINGS holds the durable gotcha
  that is *not* deducible from the code, FACTS holds what is perfectly deducible and merely
  expensive to rediscover, and FACTS is allowed to go stale and die with the branch.
- **Plans carry contracts, not literal code.** The agent **trusts** the code you put in the plan; if
  you never compiled it, you have written an error wearing authority. **Measured: 4 wrong code
  blocks, 15-40 min of detour each.** Write exact names, exact signatures, and "mirror the shape of
  `the existing implementation`" — claims the agent can verify against the repo — and reserve literal code for what you have
  actually run. This is what `writing-plans` produces; keep it that way when you edit the plan by
  hand.
- **Batch the discretionary decisions.** The work that shows up along the way — a capability being
  quietly dropped, a missing script, an adjacent bug — added up to **5-6 h of 15**. Every one was
  justified on its own; deciding them as they appear is what takes them away from you. Accumulate
  them and ask **once per batch, with the estimated cost of each**. In **"modo desatendido"** there
  is nobody to ask, so the batch goes into the PR body as a list with its costs — the decision is
  still yours, it just moves to review time.
- **What never gets cut.** With the numbers on the table: review was **1.5 h of 15**, and it found a
  `create()` silently discarding fields, a 404 caused by SQL deduplication, a silent merge that
  corrupted data, a delete-and-recreate with no transaction, and several inert assertions. **Cutting
  review does not give time back; it defers it to production.** If something has to be cut, cut
  reproduction (write the shortcut — see
  [Budget the lap](#the-loop-is-the-cost)) and cut serialization (dispatch the review in parallel).
  Never verification.

### Day one — the numbers that fill the blanks

Three measurements, taken once at the start of a project, turn every `project-specific value` above into something
enforceable. None of them takes more than an afternoon.

1. **The lap** — time `build → deploy → reach the state → observe` once, on a real bug if there is
   one, and write the seconds into the table in
   [The loop is the cost](#the-loop-is-the-cost). Whichever phase dominates is the one that gets a
   shortcut script; the rest are noise and stay unoptimized.
2. **The exclusive resource** — name the thing only one agent can hold at a time (emulator, dev
   database, dev-server port, a physical device) and write it into the orchestration note above.
   Everything else parallelizes; this is the one that corrupts a run when two agents touch it.
3. **The inert assertions** — break one assertion on purpose and run the suite. Anything still green
   is inert. Then walk the table in [Tests that cannot fail](#tests-that-cannot-fail), delete the
   rows this stack cannot produce, and name the mechanism for the ones it can.

Record all three in this file, not in a session — the point is that the next session inherits them.

---

## Reuse first — search before you write

> **Here:** search `scripts/`, `aur-makedeps.txt`, `.gitmodules`, the approved plan and each
> package's existing PKGBUILD before adding orchestration. There is no `packages/shared`, UI
> directory or `package.json` in this root; references below are the inherited web example.
> Keep the approved four standalone scripts; do not create a shared library for incidental
> similarity. The usage snippet/page duplication is deliberate and checked for parity.

The default failure mode of an agent (and of a tired human) is to write the thing that already
exists: a second `formatPrice`, a fourth bespoke modal, a `Button` that is 90% the one in the design
system with one colour hardcoded. Nothing breaks — that is what makes it expensive. The copy drifts,
the fix lands in one of them, and the design system stops describing the product.

- **Search before writing. Every time.** Before creating a component, hook, helper, type, DTO,
  fixture or script, look for it by name *and* by behaviour (`grep -ri "format.*price"`, read
  `packages/shared`, `the shared UI directory (web example only)`, the design system doc). "I didn't know it existed"
  is a search you didn't run, not an excuse.
- **Extend or parameterize — don't clone.** If something is 80% right, add the prop/parameter/variant
  to it. A copy with three lines changed is two things to maintain and one of them will be forgotten.
- **Rule of three.** Two occurrences can wait. At the third, extract in the same change, not "later":
  the component into the shared UI layer, the logic into `packages/shared`.
- **Reuse across the boundary, not through it.** `web` must not import from `api` (or the reverse) to
  reuse a function. If both sides need it, it moves to `packages/shared`; if it can't move, it wasn't
  shareable.
- **Don't reuse coincidences.** Two things that look alike today but answer to different owners (an
  invoice line and a cart line) are not one thing — coupling them under one abstraction costs more
  than the duplicate. Reuse what shares a *reason to change*, not a shape.
- **Extraction includes the deletion.** Migrate the call sites and remove the old copies in the same
  PR. An abstraction that lands *next to* the copies it was meant to replace made things worse.
- **A deliberate duplicate is one sentence in the PR.** Say why the shared version didn't fit. The
  rule is not "never duplicate", it is "never duplicate by accident".

Dependencies count as existing code: before hand-rolling a date parser, a slug helper or a retry
loop, check whether something already in `package.json` does it — but **don't add a dependency** to
avoid writing ten lines (see *Working rules*).

---

## Working rules

- **Heavy or parallel jobs run inside a memory cgroup** — never launch a suite, build or
  fan-out on a bare estimate; wrap it in
  `systemd-run --user --scope -p MemoryHigh=5G -p MemoryMax=6G -p MemorySwapMax=0 -- COMMAND`
  and cap the tool's own concurrency too.
- **Use superpowers skills whenever they apply** — invoke via `Skill` before acting; process skills
  before implementation skills.
- **Don't install packages without asking** — the stack is intentional. Exception: obvious test devDeps.
- **Reuse before you write** — search for the existing component/helper/type before creating one,
  extend it instead of cloning it, and extract at the third copy (shared UI in
  `the shared UI directory (web example only)`, shared logic and contracts in `packages/shared`). A deliberate duplicate
  is a sentence in the PR, not a default. See
  [Reuse first — search before you write](#reuse-first--search-before-you-write).
- **TDD by default** for new logic. Don't merge logic without tests.
- **Every user-facing flow ships with a Playwright E2E** that drives the running app against the real
  API. Unit tests green ≠ it works — the recurring failure mode is a feature that renders fine and
  then breaks on the first real click (missing endpoint, wrong payload, 500). Blocking on pre-push.
- **Instrument before you ablate, and budget the lap** — a pipeline that completes with non-empty
  output produced output; ask *where* it went, not why it's missing. More than three reproductions of
  a bug means you owe a shortcut script before the fourth. See
  [Debugging](#debugging--keep-the-loop-from-running-away).
- **A review finding is not a reproduction** — reproduce it before dispatching a fix, and believe the
  person who has it running over the person who read the diff. "I can't make it fail" is a reportable
  result, never something a green test papers over.
- **Dispatch the review of task N with the implementation of N+1** — review is read-only, so it is
  free in parallel and 10-15% of the wall clock in series. Discretionary decisions found along the
  way get batched and priced, not taken on your behalf. See
  [Agent orchestration](#agent-orchestration--parallel-where-its-free-batched-where-its-yours).
- **Don't lower the coverage gate** — exclude with justification instead.
- **No `any`** — `unknown` + type guards or domain types.
- **No hardcoded enum strings** — use the enums from `packages/shared`.
- **DB entities in `schema.prisma`** — single source. Migrations via `pnpm db:migrate` (don't hand-edit SQL).
- **DTOs/enums/Zod schemas in `packages/shared`** — never duplicate (except Prisma enums, sanctioned and
  guarded by an enum-parity test). Recompile `shared` after editing it, or api/web/seed import stale code.
- **Cache/heavy compute in services**, never in controllers or the frontend.
- **Email & storage via their transport/driver** — never provider-coupled; the API serves signed URLs,
  not binaries.
- **Keep this file's Stack/Architecture section current** — when you ship something previously marked
  "planned", update the Stack tables and module list in the same change. A stale `CLAUDE.md` misleads
  the next session.
- **UI work → design context first, then `impeccable` + superpowers** — for any UI/frontend change,
  invoke the `impeccable` skill (and its sub-skills: `shape`, `polish`, `critique`, etc.). First, if
  the project has no design context yet (`PRODUCT.md` / `DESIGN.md` at the root), run the impeccable
  `teach` flow (`$impeccable teach`) — it explores the codebase and then interviews you about the
  project's direction and writes `PRODUCT.md` (strategic) + `DESIGN.md` (visual) (auto-migrating a
  legacy `.impeccable.md` to `PRODUCT.md`). **Never hand-author the design context — `teach` gets it
  from you, not from the AI guessing.** Don't hand-roll UI without impeccable + superpowers.
- **Commits in English**, Conventional Commits. Scope = module/folder.
- **Project packaging rules** — preserve submodule ownership, never commit `public/`, `.build-out/`,
  `.pkg.tar.zst` or signatures; keep `aur-makedeps.txt` build-only; local references stay ignored.
  Add products through submodules, never workflow edits per package. See Module strategy and
  Project authority for the binding overrides to the inherited web examples above.

## Git & GitHub

- **Commits and branches OK** — create commits and new branches whenever it makes sense, without asking first.
- **Never push** *(default)* — no `git push` under any circumstance, and absolutely never
  `git push --force` / `--force-with-lease`. Leave pushing to the user. **Exception:** when
  **"modo desatendido"** is active, you may push the feature branches you create (never `main`/protected
  branches, never force) so PRs are ready for review.
- **Never merge — no permission** — you do NOT have permission to merge anything into any branch, nor to
  merge any pull request. No `git merge`, no fast-forward integration, no `gh pr merge`. This holds in
  every mode, **including "modo desatendido"**. Leave every merge (branches and PRs alike) to the user.
- **GitHub via `gh`** — if the `gh` CLI is available, you may open pull requests, issues, and similar
  (comments, labels, etc.). These don't require pushing on your part beyond what `gh` itself does for an
  already-pushed branch.
- **Branches:** `feat/name`, `fix/description`, `chore/task`.
- **Every PR must include a manual test plan** — when opening a PR, add a **How to test manually**
  section describing the exact steps to exercise the change by hand. For a web page/UI, list the concrete
  routes/URLs to visit (e.g. `/dashboard/settings`), what to click or input, and the expected result.
  Include any setup (seed data, env vars, feature flags, login/role) and, where relevant, edge cases and
  error states to check.

## Recovery details — preserve when resuming the approved plan

The implementation continuation stops before Task 11's user-owned setup.
Read the current handoff and ledger before repeating any completed verification.
The ledger records the user's choice of an in-place feature branch instead of a worktree.

### Accepted cross-task rulings

| Ruling | Decision and reason |
| --- | --- |
| F0 | Ignore `.superpowers/` and `.build-out/`; both are scratch. |
| F1 | Use `PUBLIC` throughout the pipeline; retain `OUT=${OUT:-$PUBLIC/x86_64}` in the package builder as a compatibility override. |
| F2 | Task 3 returns `public/.` through the writable `.build-out/` mount, restoring UID/GID `0:0` inside rootless Podman; host checkout stays read-only and no root `public/` is created. |
| F3 | Tasks 4–5 share `.build-out/`; do not delete a temporary repository before the next task consumes it. |

### Task 2 findings resolved or triaged during continuation

- Cleanup trap now registers immediately after mktemp.
- Manifest reader now accepts a final line without a trailing newline.
- The AUR install glob can include debug artifacts. The real font-patcher build emitted
  no debug companion. Such artifacts remain container-only; no AUR outputs are published.

### Reference kit and memory conventions

The local kit README identifies `CLAUDE.template.md` as canonical; its own `CLAUDE.md` describes
the template-maintenance repository, not this package repository. Do not use that shorter file
as the project template. `PROMPT_TEMPLATES_WEB.md` contains reusable task prompts, not additional
authorized tasks; do not execute its rollout, branch propagation, bootstrap or deployment prompts.

- `FACTS.template.md`: verified, expensive-to-rediscover facts, one-line entries grouped by area,
  verification method/date; may expire with the branch. Not plans or the only copy of decisions.
- `FINDINGS.template.md`: recurring non-obvious gotchas that cost time and cannot be inferred
  from code; symptom, cause, workaround, why non-obvious, discovery date/area, newest first.
- `ENDPOINT_PERMISSIONS.template.md`: authoritative route/access/guard/rejection-test table if
  an API is ever added. Current public static artifacts are not an authenticated application API.
- `USER-STORIES.template.md`: roles, epics, concrete acceptance criteria, exclusions and priority;
  the approved packaging spec/plan already owns that scope here.
- `DESIGN-SYSTEM.template.md`: visual concept, audience, palette/tokens, typography, spacing,
  components/states, responsive layout, motion and accessibility; relevant only when actual UI
  work is authorized. Use the inherited design-context interview flow then, not guessed branding.

The template's 15-hour debugging statistics and memory incident are inherited rationale, not
measurements made on this repository. Local lap timings and deliberate-failure checks remain
unmeasured; the exclusive resources are identified above. Do not invent numbers to fill a table.
