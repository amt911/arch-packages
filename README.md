# [amt911] · paquetes para Arch Linux

Repositorio pacman personal firmado, construido en un contenedor Arch y servido por
GitHub Pages. Los PKGBUILDs permanecen en sus repositorios y se fijan aquí con submódulos.

| Paquete | Función |
| --- | --- |
| `config-saver` | Copia y restauración de configuración |
| `dasik` | Configuración declarativa de sistemas |
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
original y actualiza aquí el puntero al commit revisado. Para añadir otro paquete:

```bash
git submodule add https://github.com/amt911/REPOSITORIO.git packages/NOMBRE_DEL_PAQUETE
```

El directorio debe coincidir con `pkgname`. Añade a `aur-makedeps.txt` sus dependencias
de construcción exclusivas de AUR, si existen. Revisa y confirma el cambio; el usuario
lo integra y sube. El workflow descubre los paquetes sin editar el YAML.

Hay rebuild diario a las 04:00 UTC y ejecución manual. Solo se publica la versión
actual; `font-patcher` se instala para construir y no se publica.

- [Uso y resolución de problemas](docs/usage.md)
- [Firma, secretos y rotación](docs/signing.md)
- [Runner en la mini-PC](docs/self-hosted-runner.md)
- [Construcción y verificación local](docs/build.md)
- [Plan y verificaciones](docs/superpowers/plans/2026-09-15-arch-repo.md)
