# CI & git hooks

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

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
