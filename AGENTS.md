# arch-packages — Agent Guide

`amt911/arch-packages` aggregates five personal Arch Linux packages into the planned signed
`[amt911]` pacman repository on GitHub Pages, so Andrés can install and update them with pacman.
This repository owns packaging orchestration; the application sources and PKGBUILDs have their
own repositories.

## Project authority, applicability and current stop

Adapted from `claude-md/docs/starter-kit/AGENTS.template.md`, the single canonical English
template. Its section order, governance, explanations and examples are retained; the six
pnpm-monorepo preset sections are replaced with this project's stack. Local applicability notes
and the rules below specialize inherited governance; they take precedence over generic examples.
This file is the **one** instruction file for every coding agent in this repo; `CLAUDE.md` only
imports it (`@AGENTS.md`) for Claude Code — see
[Agent compatibility](docs/agents/agent-compatibility.md#agent-compatibility--codex-and-claude-code).

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
  [Agent orchestration](docs/agents/agent-orchestration.md#agent-orchestration--parallel-where-its-free-batched-where-its-yours).
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
`AGENTS.md` conflict, this file wins.**

### Mode switch

- **"lite mode"** — fully disables superpowers: no skill is invoked, not even the applicability
  check, until **"normal mode"** is said.
- **"normal mode"** (default) — standard superpowers behavior, plus: when delegating coding work,
  dispatch at most 1 agent at a time, and never use a model above Sonnet (no Opus). The cap counts
  **implementation** agents: a read-only review agent runs alongside one, and should — see
  [Agent orchestration](docs/agents/agent-orchestration.md#agent-orchestration--parallel-where-its-free-batched-where-its-yours).
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

## Rules by topic — what always binds, and where the detail lives

This file fits in the 32 KiB Codex reads by default (`wc -c AGENTS.md` ≤ 32768; when it grows, move
detail to `docs/agents/`, never raise the limit). The detail of each topic was moved verbatim to
`docs/agents/` on 2026-10-04. **The lines below bind even if you never open the document; open it
before working on that topic.** *Project overrides* above win over these documents.

- **Technology ownership** → [docs/agents/technology-ownership.md](docs/agents/technology-ownership.md).
  What the root pipeline and each submodule use; submodules stay their upstream's.
- **Packages (versions, sources)** → [docs/agents/package-versions.md](docs/agents/package-versions.md).
  Baseline table; directory == `pkgname`, enforced by `scripts/check-packages.sh`.
- **Repository structure** → [docs/agents/repository-structure.md](docs/agents/repository-structure.md).
  File-by-file map of the root.
- **Dev workflow details** → [docs/agents/dev-workflow-details.md](docs/agents/dev-workflow-details.md).
  Add or move a package only when requested, through `add-package.sh` / `update-package.sh`; script
  environment contract.
- **Containers & deploy** → [docs/agents/deploy.md](docs/agents/deploy.md). Job-level
  `archlinux:base-devel` container; makepkg unsigned as `builder`, root signs afterwards; never
  publish a partial or unsigned repository.
- **CI & git hooks** → [docs/agents/ci-and-hooks.md](docs/agents/ci-and-hooks.md). No Git hooks;
  never `pull_request`; do not claim a root gate before reading the YAML.
- **Inherited test examples and hard rules (Playwright, Maestro)** →
  [docs/agents/inherited-tests.md](docs/agents/inherited-tests.md). Reference only; the applicability
  table in *Tests and quality* decides. Never claim done without showing command output; never delete
  or skip a test to get green.
- **Quality beyond coverage** →
  [docs/agents/quality-beyond-coverage.md](docs/agents/quality-beyond-coverage.md). Reference for a
  future scope; here ShellCheck plus real build/install/signature checks are the evidence.
- **Real-environment verification** →
  [docs/agents/real-environment-verification.md](docs/agents/real-environment-verification.md). Real
  artifacts in a disposable container or VM, never the host; a check never seen failing is unproven.
- **Debugging** → [docs/agents/debugging.md](docs/agents/debugging.md), before chasing a bug. Measure
  before ablating; a finding is not a reproduction.
- **Agentic PR verification (mandatory)** → [docs/agents/pr-verification.md](docs/agents/pr-verification.md).
  Packaging/install/signature smoke in a disposable Arch environment; the verdict is posted only when
  the session authorizes it; it never merges.
- **Agent orchestration** → [docs/agents/agent-orchestration.md](docs/agents/agent-orchestration.md).
  One subagent at a time (overrides win); shared `docs/FACTS.md`; review is never cut.
- **Reuse first** → [docs/agents/reuse-first.md](docs/agents/reuse-first.md). Search before writing;
  extract at the third copy.
- **Design principles (SOLID)** → [docs/agents/design-principles.md](docs/agents/design-principles.md).
  No abstraction without a second implementation, an IO boundary or a test seam.
- **Recovery details** → [docs/agents/recovery-details.md](docs/agents/recovery-details.md), before
  resuming the approved plan. Rulings F0–F3, Task 2 findings, reference-kit notes.
- **Codex and Claude Code** → [docs/agents/agent-compatibility.md](docs/agents/agent-compatibility.md).
  Rules are edited in `AGENTS.md` (or its `docs/agents/` document), never in `CLAUDE.md`.

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
   in user Git configuration. Every entry uses `ignore = untracked` (the spec highlighted
   the fonts; the implementation applies it to all of them, and `add-package.sh` keeps it so).
4. **Keep upstream repositories alive.** `dasik-aur` releases feed `iso-bootstrap.sh`;
   `config-saver-aur` has its own packaging CI (preparation/static checks, not a full install smoke
   in the checked-in workflow). This root aggregates, it does not replace them.
5. **Standalone Bash scripts own the pipeline**, not inline workflow logic or a new shared library.
   The plan deliberately uses four short pipeline scripts; `make-repo.sh` owns signing and database
   assembly. Three maintenance scripts sit beside them and never run as part of a publish:
   `add-package.sh`, `update-package.sh` and `check-packages.sh` (the last one is the exception —
   the workflow runs it as a pre-flight check). See `docs/packages.md`.
6. **AUR build dependencies are not products.** `aur-makedeps.txt` currently lists `font-patcher`.
   `makepkg --syncdeps` resolves official repositories only. Bootstrap the listed AUR packages
   in the disposable build container, then build the products. Do not publish `font-patcher`
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
| Git submodules | Five pinned Gitlinks | Implemented; own packaging repos remain authoritative |
| Arch Linux container | `archlinux:base-devel` | Container build environment on hosted/self-hosted runners |
| Podman + systemd cgroups | Local validation | Disposable build/install tests; mandatory memory ceiling |
| GitHub Actions + Pages | Implemented Task 6 | Build/sign/deploy `public/`; workflow exists; deployment pending |
| Dependabot | Implemented Task 6 | Weekly `github-actions` and `gitsubmodule` updates |
| Static HTML | Implemented Task 5 | Package index from `.PKGINFO`; no frontend runtime |

## Generated output contract

```text
public/
├── index.html
├── amt911.gpg                      # armored PUBLIC key only
└── x86_64/
    ├── amt911.db -> amt911.db.tar.zst
    ├── amt911.db.tar.zst            # with detached signature
    ├── amt911.files -> amt911.files.tar.zst
    ├── amt911.files.tar.zst         # with detached signature
    ├── *.pkg.tar.zst               # one per package, current versions only
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
| Native Android / Maestro | Not applicable: no Android/iOS application or emulator flow. Preserved in [docs/agents/inherited-tests.md](docs/agents/inherited-tests.md) as generic template reference only. |
| Mutation ≥60% | Exempt for packaging infrastructure without a test suite/core application domain. Bash is executable; the exemption is not a claim that scripts cannot contain bugs. Reassess if scripts gain a suite/application logic. |
| Property-based tests, Zod/Pydantic, strict TS, Knip, npm audit | Tool-specific examples do not apply to the root. Validate shell inputs/artifacts, use ShellCheck, review actual upstream/AUR sources and dependency changes. |
| Full real-environment verification | Applies: disposable container/VM, signatures, metadata, installability and CLI/font smoke. Never host package installation for a test. |
| Memory cgroup + tool concurrency limit | Applies to all heavy local jobs, especially FontForge fan-out. |
| Existing tests and failure evidence | Never skip/delete tests to get green; report actual command output and unverified stages. |

The Run before declaring done / What to test per folder tables in [docs/agents/inherited-tests.md](docs/agents/inherited-tests.md) describe the inherited web
example. The authoritative project checks and paths are in **Dev workflow**. No corresponding
`apps/`, `lib/`, `components/` or `hooks/` folders exist in this root.

- **Backend:** Jest + supertest — unit `*.spec.ts` colocated with source; e2e separate.
- **Frontend / shared:** Vitest + Testing Library + jsdom — `*.test.tsx` colocated.
- **Browser E2E: Playwright — mandatory**, not "when there are navigation flows". See
  [E2E (Playwright) — mandatory](docs/agents/inherited-tests.md#e2e-playwright--mandatory).
- **Coverage gate: 80%** (statements/branches/functions/lines) in `api`, `web` and `shared`.
  Critical logic ≥90%. Don't lower the gate — exclude infra with justification (Prisma client,
  migrations, `seed.ts`, `main.ts`, `*.module.ts`, `prisma.service.ts`, shadcn-generated). Before PR:
  `pnpm pr-check` (= `pnpm lint` + `pnpm test:cov`).
- **Mutation gate: 60% minimum** over the core-logic scope, blocking on push and reported in CI. A
  coverage gate is blind to a test with no asserts; this one is not. See
  [Mutation gate — the 60% floor](docs/agents/quality-beyond-coverage.md#mutation-gate--the-60-floor-and-it-only-goes-up).

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

## Full local build

The current tested recipe is in [docs/build.md](docs/build.md), superseding the plan's
original uncapped fan-out. It keeps the checkout read-only and copies only scripts,
packages and the manifest into the container. Returned artifacts are under `.build-out/`.
The local host lacks cpuset delegation; use taskset and explicit container memory limits
as documented there. The systemd wrapper alone does not constrain Podman's separate scope.

## Verification commands and required evidence

| Change | Required verification |
| --- | --- |
| Guide only | Template comparison, policy parity, links, placeholder and whitespace checks |
| Root shell scripts | `bash -n`, `shellcheck scripts/*.sh`, relevant error paths and real container run |
| Package build | One product archive per package, correct `.PKGINFO`, clean makepkg, namcap no worse |
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
  [Reuse first — search before you write](docs/agents/reuse-first.md#reuse-first--search-before-you-write).
- **SOLID where it pays, not by rote** — split by reason to change, extend through named functions
  or a case/dispatch table instead of a growing `if` chain, keep interfaces and function arguments
  narrow, and push IO (filesystem, subprocess/network calls, package managers) behind small
  functions a dry-run flag can skip. No abstraction without a second implementation, an IO
  boundary or a test seam. See
  [Design principles](docs/agents/design-principles.md#design-principles--solid-applied-with-judgement).
- **TDD by default** for new logic. Don't merge logic without tests.
- **Every user-facing flow ships with a Playwright E2E** that drives the running app against the real
  API. Unit tests green ≠ it works — the recurring failure mode is a feature that renders fine and
  then breaks on the first real click (missing endpoint, wrong payload, 500). Blocking on pre-push.
- **Instrument before you ablate, and budget the lap** — a pipeline that completes with non-empty
  output produced output; ask *where* it went, not why it's missing. More than three reproductions of
  a bug means you owe a shortcut script before the fourth. See
  [Debugging](docs/agents/debugging.md#debugging--keep-the-loop-from-running-away).
- **A review finding is not a reproduction** — reproduce it before dispatching a fix, and believe the
  person who has it running over the person who read the diff. "I can't make it fail" is a reportable
  result, never something a green test papers over.
- **Dispatch the review of task N with the implementation of N+1** — review is read-only, so it is
  free in parallel and 10-15% of the wall clock in series. Discretionary decisions found along the
  way get batched and priced, not taken on your behalf. See
  [Agent orchestration](docs/agents/agent-orchestration.md#agent-orchestration--parallel-where-its-free-batched-where-its-yours).
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
  "planned", update the Stack tables and module list in the same change. A stale `AGENTS.md` misleads
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

