# Runner en la mini-PC

## Seguridad primero

Este repositorio es público. Un runner self-hosted ejecuta código con acceso al
host y potencialmente a la red doméstica. Usa una máquina o VM dedicada y aislada.

1. [El workflow](../.github/workflows/repo.yml) no admite `pull_request` ni
   `pull_request_target`: solo push a `main`, cron y ejecución manual. No añadas
   triggers de PR que permitan ejecutar código de forks en este runner.
2. En **Settings → Actions → General**, configura la aprobación de workflows de
   forks en **Require approval for all external contributors**, cuando esté disponible.
   Esta aprobación no convierte en seguro el código externo.
3. Usuario dedicado `github-runner`, con su propio directorio personal y sin sudo.
4. Registra el runner solo para `amt911/arch-packages`, no a nivel de organización.
5. Ejecútalo mediante systemd, con `Restart=on-failure`.

## Contenedores y recursos

GitHub requiere Linux y Docker para jobs con `container:`. Docker es la opción
soportada en esta guía. Acceder a un socket Docker rootful equivale a poder controlar
el host: un usuario sin sudo no elimina ese privilegio. Por eso se requiere aislamiento
y no se recomienda compartir esta máquina con datos personales.

Podman local sirve para verificar los paquetes, pero `podman-docker` o activar un
socket no garantizan compatibilidad con todas las operaciones del runner. No se ha
validado aquí como reemplazo del Docker que invoca GitHub Actions.

Instala Docker mediante la documentación de tu sistema y configura su acceso para
el usuario dedicado. El job limita el contenedor a 6 GB sin swap, reserva 5 GB y dos CPU;
`taskset` limita además los procesos que detecta `nproc` en las recetas de fuentes.
No aumentes esos límites sin revisar los recursos de la máquina.

## Instalar y registrar

Como administrador:

```bash
sudo useradd -m -s /bin/bash github-runner
sudo -iu github-runner
mkdir -p actions-runner
cd actions-runner
```

En **Settings → Actions → Runners → New self-hosted runner**, selecciona Linux x64.
Ejecuta los comandos de descarga y comprobación SHA-256 que muestra GitHub para
la versión vigente. No ejecutes el runner como root.

Registra con el token temporal mostrado allí:

```bash
./config.sh --url https://github.com/amt911/arch-packages --labels self-hosted
```

Introduce el token cuando lo solicite y acepta el directorio de trabajo. El token no
se guarda en este repositorio.

## Servicio systemd

Sal de la sesión de `github-runner`. Desde una cuenta administradora:

```bash
exit
cd /home/github-runner/actions-runner
sudo ./svc.sh install github-runner
sudo ./svc.sh start
sudo ./svc.sh status
```

La instalación del servicio la hace el administrador; no concedas sudo al usuario
del runner. Obtén el nombre exacto de la unidad de la salida de `svc.sh status`:

```bash
RUNNER_UNIT='NOMBRE_EXACTO.service'
sudo systemctl edit "$RUNNER_UNIT"
```

Introduce:

```ini
[Service]
Restart=on-failure
RestartSec=5s
MemoryHigh=5G
MemoryMax=6G
MemorySwapMax=0
```

Después:

```bash
sudo systemctl daemon-reload
sudo systemctl restart "$RUNNER_UNIT"
sudo systemctl show "$RUNNER_UNIT" -p Restart -p MemoryHigh -p MemoryMax
```

El servicio puede delegar el trabajo a Docker fuera de su cgroup: los límites del
contenedor en el workflow son imprescindibles. Comprueba también el cgroup del proceso
real de construcción y sus valores `memory.max` y `memory.swap.max`.

## Activar y volver atrás

En **Settings → Secrets and variables → Actions → Variables → New repository variable**,
crea `BUILD_RUNNER` con valor `self-hosted`. Es una única etiqueta, no una lista JSON.
El YAML usa `vars.BUILD_RUNNER || 'ubuntu-latest'`.

Ejecuta manualmente `repo` y comprueba en los primeros mensajes el nombre del runner.
Para volver al servicio hospedado, elimina `BUILD_RUNNER`; la próxima ejecución usará
`ubuntu-latest`. Una ejecución ya encolada puede necesitar cancelarse y volver a lanzarse.

Referencias: [requisitos de jobs en contenedores](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container)
y [servicio del runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service).
