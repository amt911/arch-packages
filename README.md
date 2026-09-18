# [amt911] · paquetes para Arch Linux

Repositorio pacman personal firmado, construido en un contenedor Arch y servido por
GitHub Pages. Los PKGBUILDs permanecen en sus repositorios y se fijan aquí con submódulos.

| Paquete | Función |
| --- | --- |
| `config-saver` | Copia y restauración de configuración |
| `dasik` | Configuración declarativa de sistemas |
| `envycontrol` | Cambio de modo gráfico en portátiles Nvidia Optimus (fork propio) |
| `ttf-atkinson-hyperlegible-next-nerd-git` | Fuente Atkinson Hyperlegible Next con Nerd Fonts |
| `ttf-atkinson-hyperlegible-next-nerd-mono-git` | Variante monoespaciada con Nerd Fonts |

## Instalar

Primero [confía en la clave y configura pacman](docs/usage.md). Después:

```bash
sudo pacman -Syu
pacman -Sl amt911
sudo pacman -S dasik
```

URL prevista: <https://amt911.github.io/arch-packages/>. El primer despliegue requiere
[crear los secretos de firma y activar Pages](docs/signing.md); no está verificado aún.

## Mantener los paquetes

Clona con `git clone --recurse-submodules`. Modifica cada PKGBUILD en su repositorio
de packaging y mueve aquí el puntero al commit revisado:

```bash
./scripts/add-package.sh NOMBRE          # alta: submódulo, pin, validación y gitlink
./scripts/update-package.sh NOMBRE TAG   # mover el pin a otra revisión
./scripts/check-packages.sh              # validar el árbol packages/
```

`add-package.sh --create` también crea el repositorio de packaging en GitHub cuando
todavía no existe. Revisa y confirma el cambio; el usuario lo integra y sube. El
workflow descubre los paquetes sin editar el YAML. Detalles y casos de borde en
[docs/packages.md](docs/packages.md).

Hay rebuild diario a las 04:00 UTC y ejecución manual. Solo se publica la versión
actual; `font-patcher` se instala para construir y no se publica.

- [Alta y mantenimiento de paquetes](docs/packages.md)
- [Uso y resolución de problemas](docs/usage.md)
- [Firma, secretos y rotación](docs/signing.md)
- [Runner en la mini-PC](docs/self-hosted-runner.md)
- [Construcción y verificación local](docs/build.md)
- [Plan y verificaciones](docs/superpowers/plans/2026-09-15-arch-repo.md)
