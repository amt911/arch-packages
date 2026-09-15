# Handoff — [amt911] Arch repository

Updated 2026-09-15 after the user explicitly authorized continuing implementation.
This replaces the earlier stop after Task 2. Work stays on `feat/arch-repo`.
**Never push or merge. Stop before Task 11.**

## Current state

Tasks 1–10 are implemented. Tasks 3–10 were completed locally from baseline `7ac4aa1`;
no permitted Sonnet model was available, so implementation and review ran locally.
The two previously untracked agent guides were preserved and updated for the real stack.
See Git history for the continuation commits; no production deployment has happened.

| Task | Result |
| --- | --- |
| 1–2 | Existing four pinned submodules and AUR bootstrap retained. Bootstrap cleanup and final-line parsing improved. |
| 3 | `build-packages.sh`: real four-package build, explicit unsigned mode, required recipes, output-path guard, current product archives only. |
| 4 | `make-repo.sh`: explicit loopback signatures, rebuilt databases, signature aliases, public-key export. |
| 5 | `make-index.sh`: metadata table, safe links, downloads, light/dark CSS and pacman instructions. |
| 6 | Workflow and Dependabot implemented; actionlint clean; no PR trigger. |
| 7–9 | Spanish signing, usage and self-hosted runner guides, plus README and local verification recipe. |
| 10 | CLAUDE.md and AGENTS.md updated together. Operational sections checked for parity. |
| 11 | **Not executed. User-owned production setup and publication remain pending.** |

## Evidence

Actual local builds in disposable `archlinux:base-devel` containers produced:

| Package | Version |
| --- | --- |
| config-saver | 3.4.0-1 |
| dasik | 0.17.0-1 |
| ttf-atkinson-hyperlegible-next-nerd-git | r17.7925f50-1 |
| ttf-atkinson-hyperlegible-next-nerd-mono-git | r20.154d503-1 |

- Final builder successfully rebuilt all four. Artifacts returned as user-owned files;
  the host checkout and submodule pins remain unchanged.
- Required memory ceiling verified inside the worker container: memory.max 6442450944,
  memory.high 5368709120, memory.swap.max 0; `nproc` reported 2.
- Disposable isolated GPG identity: all four packages and both databases verify.
  No personal/production keyring inspected or used; test keyring removed afterward.
- Pages-style tar dereferencing makes database and signature aliases regular files.
- Fresh Arch container: local repository with `SigLevel = Required`, four products installed,
  both CLI version/help commands and `python -m dasik --help` succeed.
- Fontconfig discovers AtkynsonNext and AtkynsonMono Nerd Font; `pacman -Qk` reports
  zero missing files for all four packages. Tampered package rejected for PGP signature failure.
- ShellCheck, Bash parsing, actionlint, workflow trigger/order checks, documentation links,
  shell examples and pacman snippet parity pass. Empty-input and unsafe-output guards exercised.
- Index checked against actual archives and adversarial metadata: HTML escaped, unsafe URL
  scheme omitted, description containing ` = ` preserved, local download links resolve.
- Markdownlint: clean with MD013, MD032 and MD060 disabled for inherited long prose/tables
  and list spacing. These are accepted formatting differences; default invocation is not clean.

Local detailed logs and verification scripts remain under the ignored
`.superpowers/sdd/2026-09-15-arch-repo/`. Artifacts and test-signed index are under
`.build-out/`; **these use a throwaway key and must not be deployed**.
[docs/build.md](../build.md) contains the reusable build recipe for a fresh clone.

## Rulings and review findings

Earlier F0–F3 still apply: scratch ignored, shared PUBLIC contract with OUT override,
read-only source mount with returned artifacts, and keeping results between validation stages.
Additional implementation refinements:

- Rootless Podman workers use a separate cgroup; bound the container as well as the wrapper.
  This host lacks cpuset delegation, so use taskset instead of `--cpuset-cpus`.
- `makepkg --packagelist` can announce an absent debug archive. Exclude debug companions;
  only collect declared current product outputs, not a glob of stale package versions.
- Missing recipes fail the build rather than silently producing a partial repository.
- Workflow imports exactly one dedicated primary key after builds, requires both secrets,
  uses a temporary root keyring and removes it after signing. Checkout credentials are not retained.
- Signing documentation identifies the dedicated key explicitly instead of choosing the first
  secret key in the user's keyring. Production key creation remains the user's task.
- Docker is the documented supported runner backend. Podman is verified for local builds;
  no claim that podman-docker alone makes GitHub job containers compatible.
- Font family lookup uses the patched names, AtkynsonNext / AtkynsonMono.
- AUR bootstrap trap and missing-final-newline findings fixed. Possible debug archives from
  AUR remain container-only; this real font-patcher build emitted no debug companion.
- Namcap remains advisory: first and final build finding counts match (config-saver 24,
  dasik 91, each font recipe 2). Python-internal imports dominate; font recipes lack URL
  metadata and explicit Git makedepends. Upstream packaging changes are separate work.

No independent subagent review ran due to the project's model restriction.
Graphify generated a local graph of explicit file references only, not a full semantic
analysis. No browser rendering check was run; HTML structure and links were checked.
The production GitHub Actions environment and self-hosted runner still need their real runs.

## What only the user does next

1. Follow [docs/signing.md](../signing.md): generate a dedicated production identity and load
   `GPG_PRIVATE_KEY` and `GPG_PASSPHRASE`.
2. Set **Settings → Pages → Build and deployment → Source → GitHub Actions**.
3. Review, merge and push the branch yourself. No agent has done either operation.
4. Authorize Task 11 verification after publication. Follow [docs/usage.md](../usage.md)
   on a target Arch machine, checking the production key fingerprint independently.

Do not run the old plan's `git push origin main` as an agent instruction.
Do not install packages or modify pacman configuration on the daily workstation to test.

## Recovery documents

1. This handoff.
2. `.superpowers/sdd/2026-09-15-arch-repo/progress.md`, if present (ignored local ledger).
3. [Approved spec](specs/2026-09-15-arch-repo-design.md).
4. [Implementation plan](plans/2026-09-15-arch-repo.md), interpreted with the refinements above.
