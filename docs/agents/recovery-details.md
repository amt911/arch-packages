# Recovery details — preserve when resuming the approved plan

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

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
