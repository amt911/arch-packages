# Verified facts

- Pipeline: four standalone scripts; package builds are unsigned as `builder`, then
  `make-repo.sh` signs with explicit loopback GPG and a passphrase file descriptor.
- `PUBLIC` selects the shared output tree. `OUT` overrides only the package builder.
- Local verification uses a read-only checkout mount and disposable container copy.
  Rootless container UID 0 maps returned artifacts back to the invoking user.
- 2026-09-15 build produced config-saver 3.4.0-1, dasik 0.17.0-1, regular font
  r17.7925f50-1 and mono font r20.154d503-1. Both font versions are computed at build time.
- Package/database signatures verified with a disposable test identity, never a personal key.
- Public deployment and the self-hosted runner remain unverified. See HANDOFF.md.
