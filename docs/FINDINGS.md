# Findings

## Rootless Podman resources (2026-09-15)

This machine delegates `cpu memory pids`, but not `cpuset`, to the user cgroup.
`podman --cpuset-cpus` fails before the container starts. Use `taskset` inside the
container and verify `nproc` (2 for the validation build). Podman places workers in
a separate libpod scope, so the outer `systemd-run` memory limit alone is insufficient.
Set container limits too and read `memory.max`, `memory.high`, `memory.swap.max`
inside it: validation measured 6442450944, 5368709120, 0 respectively.

## makepkg and Nerd Fonts (2026-09-15)

`makepkg --packagelist` lists a potential config-saver-debug archive even when
no debug file was emitted. Filter debug companions when collecting repository products.
Nerd Fonts renames the installed families to AtkynsonNext and AtkynsonMono: checking
fontconfig for “Atkinson” falsely reports missing fonts.
