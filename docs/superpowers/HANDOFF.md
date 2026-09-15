# Handoff — `[amt911]` Arch repository

**Written 2026-09-15. Paste the prompt at the bottom into a fresh Claude Code session
started in `/home/andres/repos/arch-packages`.**

---

## Where the work stands

Branch **`feat/arch-repo`** (not `main`, not pushed). Six commits:

| Commit | What |
| --- | --- |
| `54c0a5f` | Design spec |
| `3132671` | Implementation plan |
| `8201f50` | `.gitignore` for `.superpowers/` and `.build-out/` |
| `b18e950` | Plan fixes from the pre-flight conflict scan |
| `02ed44f` | **Task 1** — the four submodules |
| `86377fe` | **Task 2** — `aur-makedeps.txt` + `scripts/build-aur-makedeps.sh` |

**Tasks 1 and 2 are done and reviewed clean. Tasks 3–11 are not started.**

Working tree is clean. Nothing has been pushed; nothing has been merged.

## The three documents that matter

1. **Spec** — `docs/superpowers/specs/2026-09-15-arch-repo-design.md`. The binding
   authority. Every decision and its reasoning.
2. **Plan** — `docs/superpowers/plans/2026-09-15-arch-repo.md`. Eleven tasks, each with
   the complete file contents to write and real verification commands.
3. **Ledger** — `.superpowers/sdd/2026-09-15-arch-repo/progress.md`. Git-ignored. Holds
   the pre-flight conflict table, every ruling made so far, and the per-task completion
   lines. **Read this before anything else** — it is the recovery map.

## What the thing is

`amt911/arch-packages` becomes a signed pacman repository on GitHub Pages serving four
personal packages, so `pacman -Syu` updates them with the rest of the system.

- PKGBUILDs stay in their own repos and enter here as **submodules** pinned to a SHA —
  reproducible, and no second copy to keep in sync.
- CI runs in `container: archlinux:base-devel`, bootstraps the one AUR-only build
  dependency (`font-patcher`, needed by both font packages and absent from the official
  repos), builds every submodule, signs everything with a dedicated GPG key, and deploys.
- `runs-on: ${{ vars.BUILD_RUNNER || 'ubuntu-latest' }}` so the build moves to the user's
  mini-PC by setting a repo variable, with no workflow edit.

## Rulings made so far

Each was a real conflict found before execution, decided rather than escalated. All four
are already applied to the plan and committed, so a fresh implementer inherits them.

| # | Conflict | Ruling | Cost if wrong |
| --- | --- | --- | --- |
| F0 | `.superpowers/` was not git-ignored | Added it, plus `.build-out/` | None; both are scratch |
| F1 | `build-packages.sh` took `OUT` while the other two scripts took `PUBLIC` — one pipeline, two knobs | Unified on `PUBLIC`, kept `OUT=${OUT:-$PUBLIC/x86_64}` as an override | A caller who sets only `OUT` still works |
| F2 | Task 3's only real run happens inside a container on a copy, leaving nothing on the host for Tasks 4–5 — and Task 3's own Step 5 asserted exactly that | The container now returns `public/` through a writable `.build-out/` mount, `chown 0:0` so rootless podman maps it back to the invoking user | Only the local verification path; CI never uses podman |
| F3 | Task 4 Step 6 deleted `/tmp/fakerepo`, which Task 5 Step 3 then read | Both now work against `.build-out/`; Step 6 keeps it | Local verification only |

## Deferred minor findings (Task 2)

Not fixed, by the skill's rules — minors never enter the fix loop. The final whole-branch
review must triage them:

- The `trap` registers after `chmod 755`, not immediately after `mktemp -d`; leaks a temp
  dir only if `chmod` fails.
- `while read` drops a final line with no trailing newline if `aur-makedeps.txt` is
  hand-edited badly. Not live today.
- `pacman -U "$workdir/$pkg"/*.pkg.tar.*` would also install a `*-debug*` artifact if the
  AUR PKGBUILD emits one. `font-patcher`'s PKGBUILD lives outside this repo; unverified.

## Constraints that bind whoever continues

- **At most ONE subagent at a time. Never a model above Sonnet.** The user's standing rule.
- Commit message bodies end with:
  `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`
- **Never push, never merge.** The user does both.
- `resources/` (216 MB ArchWiki dump) and `claude-md/` are git-ignored reference material.

## Two things only the user can do

Task 11 is blocked until both happen, and no agent should attempt either:

1. **Generate the GPG signing key** and load `GPG_PRIVATE_KEY` + `GPG_PASSPHRASE` as repo
   secrets. Task 7 writes the guide (`docs/signing.md`); the user runs the commands.
2. **Settings → Pages → Build and deployment → Source → GitHub Actions.**

## Heads-up on Task 3

It is the first task that builds for real: a full `podman` run that patches every TTF with
`fontforge` across `$(nproc)` processes. The plan wraps it in a memory cgroup
(`systemd-run --user --scope -p MemoryHigh=5G -p MemoryMax=6G -p MemorySwapMax=0`). That
is not decoration — an unbounded fan-out has taken this machine down before. Expect the
run to take a while.

---

## Prompt to paste into the fresh session

> Continue executing `docs/superpowers/plans/2026-09-15-arch-repo.md` in
> `/home/andres/repos/arch-packages`, on branch `feat/arch-repo`.
>
> Read `docs/superpowers/HANDOFF.md` first, then the ledger at
> `.superpowers/sdd/2026-09-15-arch-repo/progress.md`, then the spec at
> `docs/superpowers/specs/2026-09-15-arch-repo-design.md`.
>
> Tasks 1 and 2 are complete and reviewed clean — do not re-dispatch them. Resume at
> **Task 3**, using the `superpowers:subagent-driven-development` skill: one implementer
> subagent per task, a task review after each, then the broad final review.
>
> Hard constraints: **one subagent at a time, never a model above Sonnet**. Never push,
> never merge. End every commit body with
> `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`.
>
> The skill's helper scripts live in
> `/home/andres/.claude/plugins/cache/claude-plugins-official/superpowers/6.3.0/skills/subagent-driven-development/scripts/`
> — use `task-brief`, `review-package` and `sdd-workspace` rather than pasting plan text
> into dispatch prompts.
>
> Stop before Task 11: it needs the user to create the GPG secrets and switch Pages to
> the GitHub Actions source.
