# Verificación local

Ejecuta desde la raíz del checkout con los submódulos inicializados. No instala
paquetes en el host. Requiere Podman rootless, systemd de usuario y ShellCheck.

```bash
for script in scripts/*.sh; do bash -n "$script" || exit; done
shellcheck scripts/*.sh
mkdir -p .build-out
first_cpu=$(awk '/Cpus_allowed_list/ {split($2,a,/[,-]/); print a[1]}' /proc/self/status)
systemd-run --user --scope --unit=arch-packages-build \
  -p MemoryHigh=5G -p MemoryMax=6G -p MemorySwapMax=0 -- \
  podman run --rm --memory=6g --memory-swap=6g \
    --cgroup-conf memory.high=5368709120 \
    -v "$PWD:/src:ro" -v "$PWD/.build-out:/out" \
    archlinux:base-devel taskset -c "$first_cpu,$((first_cpu + 1))" \
    bash -euo pipefail -c '
      cat /proc/self/cgroup
      cat /sys/fs/cgroup/memory.max /sys/fs/cgroup/memory.high /sys/fs/cgroup/memory.swap.max
      nproc
      pacman -Syu --noconfirm --needed git namcap
      useradd -m builder
      printf "builder ALL=(ALL) NOPASSWD: /usr/bin/pacman\n" > /etc/sudoers.d/builder
      chmod 440 /etc/sudoers.d/builder
      mkdir /w
      cp -a /src/scripts /src/packages /src/aur-makedeps.txt /w/
      cd /w
      ./scripts/build-aur-makedeps.sh
      ./scripts/build-packages.sh
      cp -a public/. /out/
      chown -R 0:0 /out
    '
```

Los valores iniciales deben ser `6442450944`, `5368709120`, `0` y como máximo dos CPU.
Desde otra terminal puedes consultar el wrapper:

```bash
systemctl --user show arch-packages-build.scope -p MemoryHigh -p MemoryMax -p MemoryCurrent
```

Podman puede ejecutar el contenedor en otro cgroup. Comprueba los límites dentro del
contenedor, no solo los del wrapper. [Detalles del host](FINDINGS.md).

Deben salir cuatro archivos `.pkg.tar.zst` en `.build-out/x86_64/`, propiedad del usuario.
Antes de repetir una publicación local, usa un directorio de salida limpio para no
mezclar versiones antiguas. No publiques `.build-out/`: es material de prueba.

La [tarea 4 del plan](superpowers/plans/2026-09-15-arch-repo.md) describe la verificación
con una identidad GPG desechable en un `GNUPGHOME` aislado. Nunca uses la clave personal.
`PUBLIC="$PWD/.build-out"` selecciona los resultados para `make-repo.sh` y `make-index.sh`.

Para revisar el workflow:

```bash
systemd-run --user --scope -p MemoryHigh=5G -p MemoryMax=6G -p MemorySwapMax=0 -- \
  podman run --rm --memory=512m --memory-swap=512m -e GOMAXPROCS=2 \
    -v "$PWD:/repo:ro" -w /repo docker.io/rhysd/actionlint:latest
```

## Evidencia de aceptación, 2026-09-15

- Build completo: cuatro productos, incluidos los dos paquetes de fuentes.
- Firmas GPG: cuatro archivos y ambas bases de datos verificadas con una clave de prueba.
- Archivo Pages: `.db`, `.files` y sus firmas convertidas en archivos regulares al empaquetar.
- Instalación en un contenedor nuevo desde el repo local con `SigLevel = Required`.
- `config-saver --version/--help`, `dasik --version/--help` y `python -m dasik --help`: correctos.
- Fontconfig: familias **AtkynsonNext Nerd Font** y **AtkynsonMono Nerd Font** detectadas.
- `pacman -Qk`: cero archivos ausentes en los cuatro paquetes.
- Copia alterada de un paquete: pacman la rechaza por firma PGP inválida.

Los avisos de namcap son orientativos e incluyen metadatos ausentes en los PKGBUILDs
de las fuentes e importaciones Python internas. Los repos upstream conservan su propiedad;
esta validación no sustituye sus suites ni prueba operaciones de disco o copias reales.
El despliegue en Pages y el runner de la mini-PC todavía requieren validación en su entorno.
