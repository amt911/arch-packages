# Firma de [amt911]

La clave de producción la genera y administra el usuario. Usa una identidad dedicada
al repositorio, separada de tu clave personal o de Git; así puedes rotarla por separado.

## Crear la clave

```bash
gpg --full-generate-key
```

Selecciona RSA y RSA, 4096 bits, sin caducidad (`0`). Identidad:
`amt911 Arch Repository`, correo `a.merlo.truji10@gmail.com`, comentario
`package signing`. Protege la clave con una contraseña fuerte.

Lista **solo esa identidad** y copia la huella completa de su clave primaria:

```bash
gpg --list-secret-keys --keyid-format=long --with-fingerprint 'amt911 Arch Repository'
```

No selecciones automáticamente la primera clave del llavero: podría ser tu clave personal.
En los comandos siguientes sustituye el valor de `SIGNING_FINGERPRINT` por la huella elegida.

## Cargar los secretos

Ejecuta desde una terminal privada, sin trazado de shell (`set -x`):

```bash
SIGNING_FINGERPRINT='HUELLA_COMPLETA_DE_LA_CLAVE_DEDICADA'
umask 077
SIGNING_EXPORT=$(mktemp)
gpg --armor --export-secret-keys "$SIGNING_FINGERPRINT" > "$SIGNING_EXPORT"
gh secret set GPG_PRIVATE_KEY --repo amt911/arch-packages < "$SIGNING_EXPORT"
gh secret set GPG_PASSPHRASE --repo amt911/arch-packages
shred -u "$SIGNING_EXPORT"
unset SIGNING_EXPORT
```

El segundo `gh secret set` pide la contraseña de forma interactiva.
Si un paso falla, elimina igualmente el fichero temporal cuando termines.

> Nunca subas la clave privada al repositorio ni la pegues en una incidencia.
> `.gitignore` no protege frente a `git add -f`. Elimina la exportación temporal;
> `shred` no garantiza borrar copias en SSD, snapshots o sistemas copy-on-write.

## Copia y revocación

Guarda una exportación privada en un medio desconectado y protegido, junto con
su contraseña en un lugar seguro. Crea también un certificado de revocación:

```bash
gpg --armor --export-secret-keys "$SIGNING_FINGERPRINT" > /ruta/medio-offline/amt911-private.asc
gpg --output /ruta/medio-offline/amt911-revoke.asc --gen-revoke "$SIGNING_FINGERPRINT"
```

Perder la clave obliga a confiar manualmente en otra en todas las máquinas.
La clave no caduca para evitar esa intervención periódica; sigue siendo necesario
custodiarla y revocarla si se compromete.

## Rotación

Genera otra identidad dedicada y sustituye ambos secretos. Publica de nuevo mediante
el workflow. Comunica la nueva huella por un canal de confianza y, en cada cliente,
descarga la nueva clave, comprueba la huella y ejecuta:

```bash
OLD_FINGERPRINT='HUELLA_ANTIGUA'
NEW_FINGERPRINT='HUELLA_NUEVA'
sudo pacman-key --delete "$OLD_FINGERPRINT"
sudo pacman-key --add amt911.gpg
sudo pacman-key --lsign-key "$NEW_FINGERPRINT"
sudo pacman -Syu
```

Si hubo compromiso, revoca la clave antigua y distribuye la revocación.

## Primer despliegue

El usuario selecciona **Settings → Pages → Build and deployment → Source → GitHub Actions**.
Después de integrar y subir los cambios, ejecuta el workflow `repo`. Comprueba:

```bash
curl -I https://amt911.github.io/arch-packages/x86_64/amt911.db.sig
```

Debe devolver `200`. Esto comprueba disponibilidad; la verificación criptográfica
la hace pacman con `SigLevel = Required`. Sigue [la guía de uso](usage.md).
