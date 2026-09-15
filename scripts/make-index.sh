#!/usr/bin/env bash
#
# Renders public/index.html from the packages that were actually built, so the
# page cannot drift from what is published.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_NAME=${REPO_NAME:-amt911}
PUBLIC=${PUBLIC:-$REPO_ROOT/public}
OUT=$PUBLIC/x86_64
SITE_URL=${SITE_URL:-https://amt911.github.io/arch-packages}
SIGN_KEY=${SIGN_KEY:-}
if [[ ! $REPO_NAME =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ || ! $SITE_URL =~ ^https?://[a-zA-Z0-9./:_~-]+$ ]]; then
    echo "error: invalid repository name or site URL" >&2
    exit 1
fi
SITE_URL=${SITE_URL%/}
if [[ -n $SIGN_KEY && ! $SIGN_KEY =~ ^[A-Fa-f0-9]{40}$ ]]; then
    echo "error: SIGN_KEY must be a full fingerprint" >&2
    exit 1
fi

shopt -s nullglob
packages=("$OUT"/*.pkg.tar.zst)
if (( ${#packages[@]} == 0 )); then
    echo "error: no packages in $OUT" >&2
    exit 1
fi

esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'; }

rows=""
for pkg in "${packages[@]}"; do
    # .PKGINFO is a plain `key = value` file present in every pacman package.
    info=$(bsdtar -xOqf "$pkg" .PKGINFO)
    field() { awk -F' = ' -v k="$1" '$1==k {sub(/^[^=]* = /, ""); print; exit}' <<<"$info"; }
    name=$(field pkgname | esc)
    ver=$(field pkgver | esc)
    desc=$(field pkgdesc | esc)
    source_url=$(field url)
    source_link=""
    case $source_url in
        https://*|http://*) source_link="<a href=\"$(esc <<<"$source_url")\">source</a>" ;;
    esac
    filename=$(basename "$pkg" | esc)
    size=$(( $(stat -c%s "$pkg") / 1024 ))
    rows+="<tr><td><code>${name}</code></td><td><code>${ver}</code></td><td>${desc}</td>"
    rows+="<td>${size} KiB</td><td><a href=\"x86_64/${filename}\">download</a> ${source_link}</td></tr>"$'\n'
done

keyline=""
if [[ -n $SIGN_KEY ]]; then
    keyline="<p>Signed with <code>$(esc <<<"$SIGN_KEY")</code> — public key at <a href=\"${REPO_NAME}.gpg\">${REPO_NAME}.gpg</a>.</p>"
fi

cat > "$PUBLIC/index.html" <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>[${REPO_NAME}] — Arch Linux repository</title>
<style>
  :root { color-scheme: light dark; --fg:#1b1b1b; --bg:#fbfbfa; --mut:#5d5d5d;
          --line:#e0dedb; --card:#fff; --acc:#3a6ea5; }
  @media (prefers-color-scheme: dark) {
    :root { --fg:#e8e6e3; --bg:#16181a; --mut:#9aa0a6; --line:#2c2f33;
            --card:#1d2023; --acc:#7aa7d9; }
  }
  * { box-sizing: border-box; }
  body { margin:0; padding:2.5rem 1rem; background:var(--bg); color:var(--fg);
         font:16px/1.6 ui-sans-serif, system-ui, sans-serif; }
  main { max-width: 52rem; margin:0 auto; }
  h1 { font-size:1.6rem; margin:0 0 .2rem; letter-spacing:-.01em; }
  .sub { color:var(--mut); margin:0 0 2rem; }
  h2 { font-size:1.05rem; margin:2.2rem 0 .6rem; }
  a { color:var(--acc); }
  pre { background:var(--card); border:1px solid var(--line); border-radius:8px;
        padding:.9rem 1rem; overflow-x:auto; font-size:.86rem; }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
  table { width:100%; border-collapse:collapse; font-size:.9rem; }
  th, td { text-align:left; padding:.5rem .6rem; border-bottom:1px solid var(--line);
           vertical-align:top; }
  th { color:var(--mut); font-weight:600; font-size:.78rem;
       text-transform:uppercase; letter-spacing:.04em; }
  .scroll { overflow-x:auto; }
  footer { margin-top:3rem; color:var(--mut); font-size:.82rem; }
</style>
</head>
<body>
<main>
<h1>[${REPO_NAME}]</h1>
<p class="sub">Personal Arch Linux repository. Built and published automatically.</p>
${keyline}

<h2>Trust the signing key</h2>
<pre><code>curl -O ${SITE_URL}/${REPO_NAME}.gpg
sudo pacman-key --add ${REPO_NAME}.gpg
sudo pacman-key --lsign-key ${SIGN_KEY:-&lt;KEY_ID&gt;}</code></pre>

<h2>Add the repository</h2>
<p>In <code>/etc/pacman.conf</code>, above <code>[core]</code>:</p>
<pre><code>[${REPO_NAME}]
SigLevel = Required
Server = ${SITE_URL}/\$arch</code></pre>
<pre><code>sudo pacman -Syu
pacman -Sl ${REPO_NAME}</code></pre>

<h2>Packages</h2>
<div class="scroll">
<table>
<thead><tr><th>Package</th><th>Version</th><th>Description</th><th>Size</th><th>Links</th></tr></thead>
<tbody>
${rows}</tbody>
</table>
</div>

<footer>Built $(date -u '+%Y-%m-%d %H:%M UTC').</footer>
</main>
</body>
</html>
HTML

echo "==> wrote $PUBLIC/index.html (${#packages[@]} package(s))"
