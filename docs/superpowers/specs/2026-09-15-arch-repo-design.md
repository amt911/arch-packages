# Design — `[amt911]`: repositorio pacman personal sobre GitHub Pages

- **Fecha**: 2026-09-15
- **Repo**: `amt911/arch-packages` (público, ya existe)
- **Estado**: aprobado para implementación

---

## 1. Problema

Cuatro paquetes propios viven cada uno en su repo de GitHub. Instalarlos en una máquina
nueva significa clonar cuatro repos y `makepkg -si` cuatro veces, y actualizarlos significa
repetirlo a mano — fuera del ciclo normal de `pacman -Syu`. Las dos fuentes son paquetes
`-git`: siguen el HEAD de upstream, así que se quedan obsoletas en silencio.

**Objetivo**: un repositorio pacman propio, firmado, servido por HTTPS, de modo que los
cuatro paquetes se instalen y se actualicen con el resto del sistema.

### Paquetes en alcance

| Directorio de submódulo | `pkgname` | Versión hoy | Fuente | Notas |
| --- | --- | --- | --- | --- |
| `packages/config-saver` | `config-saver` | 3.4.0-1 | tarball del tag | `arch=('any')` |
| `packages/dasik` | `dasik` | 0.17.0-1 | `git+…#tag=$pkgver` | `arch=('any')`, tiene `check()` |
| `packages/ttf-atkinson-hyperlegible-next-nerd-git` | `ttf-atkinson-hyperlegible-next-nerd-git` | `r17.7925f50-1` | `git+…` HEAD | `arch=('any')`, **makedep del AUR** |
| `packages/ttf-atkinson-hyperlegible-next-nerd-mono-git` | `ttf-atkinson-hyperlegible-next-nerd-mono-git` | `r20.154d503-1` | `git+…` HEAD | `arch=('any')`, **makedep del AUR** |

Los cuatro son `arch=('any')`. Se publican igualmente bajo `x86_64/`: pacman sustituye
`$arch` en `Server` por la arquitectura del host, y un paquete `any` instalado desde ese
directorio es correcto. Es la disposición que documenta la ArchWiki para un repo de una
sola arquitectura.

### Fuera de alcance

- Arquitecturas distintas de `x86_64` (`aarch64` para una Raspberry, etc.).
- Publicar en el AUR de verdad. Los repos se llaman `*-aur` pero ninguno tiene remote a
  `aur.archlinux.org`; hoy son repos de GitHub.
- Compilación incremental (reconstruir solo el paquete tocado). Ver §9.

---

## 2. Decisiones y sus porqués

### 2.1 Los PKGBUILD entran como submódulos, no como copias

El requisito fue *"reproducible, pero sin editar los PKGBUILD en dos sitios"*. Eso descarta
copiarlos (dos copias derivan) y descarta clonarlos en build-time desde una rama móvil (no
reproducible). Un submódulo fija un SHA exacto — reproducible — y el PKGBUILD se sigue
editando en su repo de origen, que sigue siendo la fuente de verdad.

No se archivan los repos de origen: `dasik-aur` publica releases de GitHub que consume su
`iso-bootstrap.sh`, y `config-saver-aur` tiene su propio CI con smoke test. Este repo los
agrega, no los reemplaza.

**Coste aceptado**: publicar una versión nueva son dos pasos —
`git -C packages/<pkg> fetch && git -C packages/<pkg> checkout <tag>`, luego commit del
puntero aquí. Es explícito y auditable: el log de `arch-packages` dice exactamente qué SHA
de cada PKGBUILD produjo cada build.

**URLs en HTTPS, no SSH.** `.gitmodules` usa `https://github.com/amt911/…` para que el
runner clone con el `GITHUB_TOKEN` por defecto (los cuatro repos son públicos, verificado).
Para empujar por SSH en local basta un `insteadOf` en la config de git del usuario; no se
toca `.gitmodules`.

**`ignore = untracked` en los dos submódulos de fuentes.** `ttf-atkinson-hyperlegible-nerd`
y `ttf-atkinson-hyperlegible-mono-nerd` no tienen `.gitignore`, así que sus `pkg/`, `src/`
y `*.pkg.tar.zst` locales harían que `git status` marque el submódulo como sucio en cada
build local. `ignore = untracked` silencia solo eso; un cambio real del PKGBUILD se sigue
viendo.

### 2.2 `font-patcher` se compila del AUR en CI y no se publica

`font-patcher` **no está en los repos oficiales** (`pacman -Si font-patcher` → *package not
found*; está instalado localmente desde el AUR). Es `makedepends` de los dos paquetes de
fuentes, y `makepkg --syncdeps` no resuelve el AUR. Sin esto, la mitad de los paquetes no
compila. Es el fallo que un workflow genérico tiene garantizado.

Mecanismo: un fichero `aur-makedeps.txt` en la raíz, una línea por paquete del AUR
(comentarios con `#`). Antes de construir nada, CI clona
`https://aur.archlinux.org/<nombre>.git`, lo compila como `builder` y lo instala con
`pacman -U`. **No se copia a `public/`**: es una dependencia de construcción, no un paquete
que `[amt911]` ofrezca. Mantener un paquete ajeno en el repo propio es trabajo recurrente
que nadie pidió.

Un único fichero global en vez de uno por paquete: todo se construye en un solo job sobre
un contenedor de usar y tirar, así que la granularidad por paquete no compra nada y sí
añade un mecanismo que explicar.

Se descarta instalar `paru`/`yay`: compilar un helper en Rust en cada run cuesta minutos
para resolver una única dependencia conocida.

### 2.3 Firma desde el primer día

`SigLevel = Optional` obliga a volver a tocar `/etc/pacman.conf` en todas las máquinas el
día que se firme. Se firma ya.

- Clave GPG **dedicada** a este repo, generada por el usuario (§7); no se reutiliza su
  clave personal de git.
- Secrets de GitHub: `GPG_PRIVATE_KEY` (bloque ASCII-armored) y `GPG_PASSPHRASE`.
- CI importa la clave, construye con `makepkg --sign` y sella la base de datos con
  `repo-add --sign`. Se publican los `.sig` junto a los paquetes.
- La clave pública armored se publica como `amt911.gpg` en la raíz de Pages, para que cada
  máquina haga `pacman-key --add` + `pacman-key --lsign-key`.
- `pacman.conf` usa `SigLevel = Required` (paquetes **y** base de datos firmados).

**Importación con `gpg` directamente**, no con una action de terceros: es la clave que
firma todo lo que se instala en las máquinas del usuario, y son cuatro líneas de shell.
Menos superficie de suministro.

### 2.4 Rebuild diario

Los dos paquetes de fuentes son `-git` con `pkgver()` sobre `git rev-list --count HEAD`:
su versión cambia cada vez que googlefonts empuja un commit. Sin cron, el repo se congela
en el `pkgver` del último push manual y el punto entero del repo (actualizar con el
sistema) se pierde para ellos.

Cron diario a las 04:00 UTC, más `workflow_dispatch`. El coste de minutos deja de importar
en cuanto el runner sea la mini-PC (§2.5) — que es precisamente por qué se pidió.

Nota honesta: un rebuild diario sube `pkgrel`/`pkgver` solo cuando upstream cambió, porque
`pkgver()` es determinista respecto al HEAD. Si upstream no se movió, `repo-add` reescribe
la misma versión y `pacman -Syu` no ofrece nada. No hay churn para el usuario.

### 2.5 `runs-on` por variable de repo, build siempre en contenedor Arch

```yaml
runs-on: ${{ vars.BUILD_RUNNER || 'ubuntu-latest' }}
container: archlinux:base-devel
```

- La **variable de repo** `BUILD_RUNNER` permite pasar de GitHub-hosted a la mini-PC
  cambiando un valor en Settings, sin editar ni re-revisar el YAML. Y permite volver
  atrás igual de rápido si la mini-PC está apagada.
- El **contenedor se mantiene también en self-hosted**: el build es idéntico en los dos
  sitios, y el host de la mini-PC no acumula `makedepends` (`fontforge`, `python-build`,
  toolchains) con cada run. Un runner self-hosted no se limpia solo entre jobs; el
  contenedor sí.

Se descarta `docker run … -v "$PWD:/workspace"` dentro de `ubuntu-latest` (lo que proponía
el plan de partida): `container:` a nivel de job hace lo mismo sin docker anidado, sin
montajes manuales y sin `chown` del workspace. Es además el patrón que ya usa
`dasik-aur/.github/workflows/build.yml`, así que los dos repos se leen igual.

### 2.6 Los symlinks de `repo-add` se dejan como están

`repo-add` crea `amt911.db → amt911.db.tar.zst` y `amt911.files → amt911.files.tar.zst`,
que es la disposición que documenta la ArchWiki. **No hay que sustituirlos por copias**:
`actions/upload-pages-artifact` empaqueta con `tar --dereference --hard-dereference`, así
que el artefacto ya contiene ficheros reales. Un paso manual de `rm`+`cp` aquí es ruido que
hay que explicar en cada revisión futura.

### 2.7 Versiones de actions

Verificadas contra la API de GitHub el 2026-09-15:
`actions/checkout@v7`, `actions/configure-pages@v6`, `actions/upload-pages-artifact@v5`,
`actions/deploy-pages@v5`. Se fijan por tag mayor; Dependabot (`.github/dependabot.yml`,
ecosistema `github-actions`) las mantiene frescas.

---

## 3. Estructura del repo

```text
arch-packages/
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       └── repo.yml
├── packages/                    # submódulos, un directorio por paquete
│   ├── config-saver/
│   ├── dasik/
│   ├── ttf-atkinson-hyperlegible-next-nerd-git/
│   └── ttf-atkinson-hyperlegible-next-nerd-mono-git/
├── scripts/
│   ├── build-aur-makedeps.sh    # bootstrap de aur-makedeps.txt
│   ├── build-packages.sh        # makepkg + namcap por paquete
│   └── make-index.sh            # index.html desde la db
├── docs/
│   ├── usage.md                 # añadir [amt911] a una máquina
│   ├── signing.md               # generar la clave y cargar los secrets
│   ├── self-hosted-runner.md    # runner en la mini-PC
│   └── superpowers/specs/
├── aur-makedeps.txt
├── .gitmodules
├── .gitignore
├── CLAUDE.md
└── README.md
```

La lógica vive en `scripts/*.sh` y no incrustada en el YAML: así se puede ejecutar el
mismo build en local (`./scripts/build-packages.sh`) para depurar sin empujar un commit, y
`shellcheck` puede revisarla.

### Salida publicada

```text
public/
├── index.html
├── amt911.gpg                       # clave pública armored
└── x86_64/
    ├── amt911.db -> amt911.db.tar.zst
    ├── amt911.db.tar.zst
    ├── amt911.db.tar.zst.sig
    ├── amt911.files -> amt911.files.tar.zst
    ├── amt911.files.tar.zst
    ├── amt911.files.tar.zst.sig
    ├── config-saver-3.4.0-1-any.pkg.tar.zst
    ├── config-saver-3.4.0-1-any.pkg.tar.zst.sig
    └── …
```

`public/` se regenera de cero en cada run y no se versiona. Consecuencia deliberada: el
repositorio publicado contiene **solo** la versión actual de cada paquete, sin acumular
históricos que engorden el sitio (límite de 1 GB de Pages). Quien necesite una versión
vieja la tiene en el release/tag del repo de origen.

---

## 4. Flujo del workflow

```text
push a packages/** · cron diario 04:00 UTC · workflow_dispatch
        │
        ▼
runs-on: ${{ vars.BUILD_RUNNER || 'ubuntu-latest' }}
container: archlinux:base-devel
        │
        ├─ pacman -Syu --needed git namcap  (base-devel ya está en la imagen)
        ├─ useradd builder + NOPASSWD para /usr/bin/pacman  (makepkg rechaza root)
        ├─ checkout@v7 (submodules: recursive)
        ├─ importar GPG_PRIVATE_KEY / GPG_PASSPHRASE
        ├─ scripts/build-aur-makedeps.sh     → font-patcher instalado, no publicado
        ├─ scripts/build-packages.sh
        │     por cada packages/*/PKGBUILD:
        │       makepkg --syncdeps --noconfirm --cleanbuild --clean --sign
        │       namcap PKGBUILD *.pkg.tar.zst      (advisory, no bloquea)
        │       cp *.pkg.tar.zst{,.sig} → public/x86_64/
        ├─ repo-add --sign public/x86_64/amt911.db.tar.zst …*.pkg.tar.zst
        ├─ scripts/make-index.sh             → public/index.html
        ├─ gpg --armor --export              → public/amt911.gpg
        ├─ configure-pages@v6
        ├─ upload-pages-artifact@v5 (path: public)   ← deshace los symlinks
        └─ deploy-pages@v5
```

### Modos de fallo y qué hace cada uno

| Fallo | Comportamiento | Por qué |
| --- | --- | --- |
| Un `makepkg` falla | **El job entero falla, no se despliega nada** | Un despliegue parcial deja `[amt911]` sin un paquete que antes tenía; `pacman -Syu` lo vería como eliminado. Mejor que el repo publicado se quede en la última versión buena. |
| `namcap` avisa | Se registra, no bloquea | `namcap` detecta olores de empaquetado, no errores de build. Igual que en `dasik-aur`. |
| Cero PKGBUILD encontrados | Falla explícitamente | Un submódulo sin inicializar produciría un repo vacío en silencio. |
| Cero paquetes generados | Falla explícitamente | Misma razón. |
| Falta un secret de GPG | Falla en el paso de importación | Se prefiere fallar a publicar sin firmar, porque las máquinas tienen `SigLevel = Required` y un repo sin firmar rompe `pacman -Syu` de forma confusa. |

`concurrency: group: pages, cancel-in-progress: false` — dos despliegues simultáneos a
Pages se pisan; encolarlos es correcto y cancelar no, porque cada run produce el repo
completo.

Permisos: `contents: read`, `pages: write`, `id-token: write`.

---

## 5. Seguridad del runner self-hosted

> **Esto importa.** El repo es público. Un runner self-hosted en un repo público permite
> que cualquiera abra un pull request desde un fork y ejecute código arbitrario en la
> mini-PC, con la red doméstica detrás. GitHub lo documenta como *no recomendado*.

Mitigaciones, todas obligatorias y todas en `docs/self-hosted-runner.md`:

1. **El workflow no se dispara nunca en `pull_request`.** Solo `push` a `main`, `schedule`
   y `workflow_dispatch`. Un fork no puede empujar a `main`.
2. **Settings → Actions → General → Fork pull request workflows from outside
   collaborators → *Require approval for all external contributors***.
3. **Usuario de sistema dedicado** (`github-runner`), sin `sudo`, con su `$HOME` propio.
   El build real ocurre dentro del contenedor, no como ese usuario.
4. **El runner se registra a nivel de repo**, no de organización ni de cuenta, para que su
   token no alcance otros repos.
5. Servicio systemd con `Restart=on-failure`; nada de ejecutarlo en una `tmux` olvidada.

---

## 6. Consumo desde una máquina Arch (`docs/usage.md`)

```bash
# 1. Confiar en la clave (una sola vez por máquina)
curl -O https://amt911.github.io/arch-packages/amt911.gpg
sudo pacman-key --add amt911.gpg
sudo pacman-key --lsign-key <KEY_ID>

# 2. /etc/pacman.conf — antes de [core], para que tenga precedencia
[amt911]
SigLevel = Required
Server = https://amt911.github.io/arch-packages/$arch

# 3. Sincronizar
sudo pacman -Syu
pacman -Sl amt911
sudo pacman -S dasik
```

`$arch` lo sustituye pacman; no se escribe `x86_64` a mano.

---

## 7. Generación de la clave (`docs/signing.md`)

La ejecuta el usuario; la guía la deja escrita paso a paso. Cubre: `gpg --full-generate-key`
con una identidad dedicada al repo, exportar la privada armored, cargarla como secret con
`gh secret set GPG_PRIVATE_KEY < fichero`, cargar `GPG_PASSPHRASE`, obtener el key-id
largo, y qué hacer si la clave se pierde o hay que rotarla (regenerar, re-firmar, y
`pacman-key --lsign-key` de nuevo en cada máquina).

La guía incluye explícitamente **no subir la clave privada al repo** y borrar el fichero
exportado después de cargar el secret.

---

## 8. Adaptación de `CLAUDE.md`

Se parte de la plantilla genérica de `claude-md`. **Se conserva verbatim** la gobernanza:
bloque de superpowers, los tres modos (ligero / normal / desatendido), y la sección de
Git & GitHub.

Se sustituye el preset de monorepo pnpm por el stack real, y se documenta *por qué* no
aplican los gates heredados — igual que hace el `CLAUDE.md` del propio repo `claude-md`
con su gate de mutation testing, para que no se vuelva a discutir cada trimestre:

| Regla de la plantilla | Aquí |
| --- | --- |
| TDD obligatorio | **No aplica**: no hay código de aplicación. El equivalente es que `makepkg` construya limpio y `namcap` no empeore. |
| Cobertura ≥ 80% | **No aplica**: no hay suite. |
| E2E Playwright | **Se reemplaza** por el smoke test de instalación: `pacman -U` del paquete construido y ejecutar su entry point (lo que ya hace `dasik-aur`). |
| Mutation gate 60% | **No aplica**, misma razón que en `claude-md`. |
| Trabajos pesados en cgroup | **Sí aplica** en local: patchear fuentes con `fontforge` sobre `$(nproc)` procesos es exactamente el fan-out que la regla existe para contener. |

Secciones nuevas específicas del repo: cómo actualizar el puntero de un submódulo, por qué
`aur-makedeps.txt` existe, que `public/` es generado y nunca se commitea, y que los
`.pkg.tar.zst` no entran en git.

## 8.1 `.gitignore`

```gitignore
# Material de referencia, no fuente (216 MB de volcado de la ArchWiki)
resources/
# Copia de trabajo de otro repo propio
claude-md/

# makepkg
packages/*/src/
packages/*/pkg/
packages/**/*.pkg.tar.*
packages/**/*.src.tar.*
*.sig

# Repositorio generado por CI
public/
```

---

## 9. Trabajo futuro, deliberadamente fuera de este spec

- **Builds incrementales**: detectar qué submódulo cambió y reconstruir solo ese. Requiere
  persistir los `.pkg.tar.zst` anteriores (rama `gh-pages` o caché de Actions) en vez de
  regenerar `public/` de cero, que es un cambio de arquitectura, no una optimización. Con
  cuatro paquetes no compensa.
- **`repository_dispatch`** desde los cuatro repos de origen, para que un tag allí dispare
  el rebuild aquí sin tocar el puntero del submódulo a mano.
- **`aarch64`** si alguna vez hay una Raspberry: segundo directorio bajo `public/`, misma
  `Server` line gracias a `$arch`.
- **Publicar de verdad en el AUR** los paquetes que tengan sentido para terceros.
