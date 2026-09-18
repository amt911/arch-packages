# Paquetes: alta, actualización y comprobaciones

Cada paquete vive en su propio repositorio de packaging y aquí solo se fija el commit
(un submódulo). El repositorio de packaging es la fuente de verdad del PKGBUILD;
este repositorio agrega, firma y publica.

## Qué es cada repositorio

Dos repositorios distintos por producto, y confundirlos es fácil: la aplicación no
lleva PKGBUILD. `amt911/dasik` es el programa; `amt911/dasik-aur` es la receta.

| Directorio (`= pkgname`) | Repositorio de packaging | Upstream que empaqueta |
| --- | --- | --- |
| `config-saver` | `amt911/config-saver-aur` | `amt911/config-saver` (tarball de release) |
| `dasik` | `amt911/dasik-aur` | `amt911/dasik` (tag) |
| `envycontrol` | `amt911/envycontrol-aur` | `amt911/envycontrol` (fork propio, tag) |
| `ttf-atkinson-hyperlegible-next-nerd-git` | `amt911/ttf-atkinson-hyperlegible-nerd` | Google Fonts, HEAD |
| `ttf-atkinson-hyperlegible-next-nerd-mono-git` | `amt911/ttf-atkinson-hyperlegible-mono-nerd` | Google Fonts, HEAD |

El nombre del directorio **debe** ser igual a `pkgname`. El repositorio de packaging
puede llamarse de otra forma; el directorio no.

## Añadir un paquete

Con el repositorio de packaging ya publicado:

```bash
./scripts/add-package.sh envycontrol
git commit -m "packages/envycontrol: add at $(git -C packages/envycontrol rev-parse --short HEAD)"
```

Sin repositorio de packaging todavía, el script lo crea y lo siembra:

```bash
./scripts/add-package.sh NOMBRE --create             # plantilla vacía de PKGBUILD
./scripts/add-package.sh NOMBRE --create --from-aur  # partiendo de la receta de AUR
```

`--create` publica el repositorio nuevo en GitHub y le hace push. Es **público** a
propósito: el workflow clona los submódulos sin credenciales, así que uno privado
rompería cada build. Nunca hace push de este repositorio.

Por defecto la URL es `https://github.com/amt911/<pkgname>-aur.git`; pásala como
segundo argumento para cualquier otra. El script fija el pin, aplica
`ignore = untracked`, ejecuta las comprobaciones y deja el gitlink preparado. Si algo
falla, deshace el alta entera: no quedan directorios ni secciones a medias.

Si el paquete necesita dependencias de construcción que solo están en AUR, añádelas a
`aur-makedeps.txt` en el mismo commit; `check-packages.sh` avisa de las que falten.

## Mover el pin a otra revisión

```bash
./scripts/update-package.sh dasik 0.19.0   # tag, rama o SHA
./scripts/update-package.sh dasik          # rama por defecto del repo de packaging
```

Trae los cambios, comprueba que la revisión existe, la fija y vuelve a validar. Si la
revisión no pasa las comprobaciones, deja el pin como estaba. Nunca usa
`git submodule update --remote`, que seguiría una rama en silencio.

## Comprobaciones

```bash
./scripts/check-packages.sh
```

Falla (código distinto de cero) si un submódulo no está inicializado, no está
registrado en `.gitmodules`, el directorio no coincide con `pkgname`, la receta es de
paquete dividido, o `arch` no incluye ninguna de las que se sirven (`any`, `x86_64`).
Avisa, sin fallar, de `makedepends` que no estén ni en los repositorios oficiales ni en
`aur-makedeps.txt`.

Se ejecuta en el workflow antes del bootstrap de AUR: un desajuste cuesta segundos ahí
en vez de un build de fuentes entero.

## Quitar un paquete

```bash
git submodule deinit -f -- packages/NOMBRE
git rm -f -- packages/NOMBRE
rm -rf .git/modules/packages/NOMBRE
```

La siguiente publicación regenera `public/` desde cero, así que el paquete desaparece
del repositorio pacman sin más pasos.
