# Instalar desde [amt911]

Repositorio para Arch Linux x86_64. Los cuatro paquetes son `any`, pero se sirven
bajo `x86_64/`. Requiere un primer despliegue correcto; crear los ficheros del proyecto
no publica el servicio.

## Confiar en la clave

Descarga la clave pública y compara su huella completa con la comunicada por el
administrador por un canal de confianza antes de firmarla localmente:

```bash
curl --fail --location --remote-name https://amt911.github.io/arch-packages/amt911.gpg
gpg --show-keys --with-fingerprint amt911.gpg
SIGNING_FINGERPRINT='HUELLA_VERIFICADA'
sudo pacman-key --add amt911.gpg
sudo pacman-key --lsign-key "$SIGNING_FINGERPRINT"
```

`--lsign-key` establece la confianza local. Omitirlo produce
`signature from … is unknown trust`.

## Configurar pacman

Añade a `/etc/pacman.conf`, **antes de `[core]`**:

```ini
[amt911]
SigLevel = Required
Server = https://amt911.github.io/arch-packages/$arch
```

Escribe `$arch` literalmente: lo sustituye pacman. La posición da prioridad a este
repositorio cuando coincide el nombre de un paquete. Se exigen firmas tanto para
los paquetes como para la base de datos.

```bash
sudo pacman -Syu
pacman -Sl amt911
sudo pacman -S dasik
```

Puedes instalar de la misma forma `config-saver`,
`ttf-atkinson-hyperlegible-next-nerd-git` y
`ttf-atkinson-hyperlegible-next-nerd-mono-git`.

## Si ya estaban instalados desde AUR o con makepkg

`pacman -S NOMBRE` instala la versión del repositorio con el mismo nombre.
`pacman -Qm` lista los paquetes que siguen siendo externos a los repos configurados.
Los siguientes cambios de versión llegarán mediante `pacman -Syu`.

## Problemas habituales

| Síntoma | Comprobación y solución |
| --- | --- |
| `signature is unknown trust` | Comprueba la huella y ejecuta `pacman-key --lsign-key` para esa clave. |
| 404 en `amt911.db` | Comprueba que Pages y el primer workflow hayan publicado correctamente. |
| `invalid or corrupted database` | Comprueba disponibilidad y firmas; tras un despliegue correcto reintenta con `sudo pacman -Syyu`. No desactives la firma para ocultar el error. |
| No aparece una nueva versión de las fuentes | El rebuild diario solo cambia la versión si ha cambiado el HEAD de upstream. |

Para cambiar de clave, consulta [firma y rotación](signing.md).
