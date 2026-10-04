# Containers & deploy (Arch Linux on GitHub Pages)

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

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
pinentry and passphrase file descriptor. The pipeline's fourth script `make-repo.sh` also keeps repo-add
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
