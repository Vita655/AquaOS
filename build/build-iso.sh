
#!/usr/bin/env bash
set -Eeuo pipefail

ARCH="${1:-amd64}"

case "$ARCH" in
  amd64|i386) ;;
  *)
    echo "Usage: $0 {amd64|i386}" >&2
    exit 2
    ;;
esac

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo bash build/build-iso.sh amd64" >&2
  exit 1
fi

command -v lb >/dev/null 2>&1 || {
  echo "Install live-build first: apt install live-build" >&2
  exit 1
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/aquaos-live-build.XXXXXX")"

trap 'rm -rf "$WORK"' EXIT

cp -a "$ROOT/config" "$WORK/config"
cd "$WORK"

# Force Debian mode and ignore Ubuntu system defaults.
lb config \
  --ignore-system-defaults \
  --mode debian \
  --distribution bookworm \
  --architectures "$ARCH" \
  --mirror-bootstrap "https://deb.debian.org/debian" \
  --mirror-chroot "https://deb.debian.org/debian" \
  --mirror-chroot-security "https://security.debian.org/debian-security" \
  --mirror-binary "https://deb.debian.org/debian" \
  --mirror-binary-security "https://security.debian.org/debian-security" \
  --debian-installer live \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components quiet splash username=aquaos hostname=aquaos" \
  --iso-application "AquaOS" \
  --iso-publisher "AquaOS Project" \
  --iso-volume "AQUAOS_LIVE" \
  --apt-recommends true

# Build the ISO.
lb build

ISO="$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)"

if [[ -z "$ISO" ]]; then
  echo "ERROR: No ISO produced." >&2
  exit 1
fi

# Export the ISO.
OUT="$ROOT/dist"
mkdir -p "$OUT"

cp "$ISO" "$OUT/AquaOS-${ARCH}.iso"

sha256sum "$OUT/AquaOS-${ARCH}.iso" \
  > "$OUT/AquaOS-${ARCH}.iso.sha256"

echo "Successfully created: $OUT/AquaOS-${ARCH}.iso"
