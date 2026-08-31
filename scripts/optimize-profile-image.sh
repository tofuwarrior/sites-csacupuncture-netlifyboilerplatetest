#!/usr/bin/env bash
# Resize and compress the about-me profile photo for web use.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${1:-$ROOT/images/uploads/profile_blue_shirt_portrait_source.png}"
OUTPUT="$ROOT/images/uploads/profile_head_squarecropped_weboptimised.jpg"
MAX_SIZE=1100
QUALITY=85

if [[ ! -f "$SOURCE" ]]; then
  echo "Source image not found: $SOURCE" >&2
  echo "Copy your PNG to images/uploads/profile_blue_shirt_portrait_source.png and run again." >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cp "$SOURCE" "$WORKDIR/in.png"
cd "$WORKDIR"
npm init -y >/dev/null 2>&1
npm install sharp >/dev/null 2>&1

node <<'NODE'
const sharp = require('sharp');
const fs = require('fs');

sharp('in.png')
  .rotate()
  .resize(1100, 1100, { fit: 'cover', position: 'centre' })
  .jpeg({ quality: 85, mozjpeg: true })
  .toFile('out.jpg')
  .then((info) => {
    console.log(`Optimized: ${info.width}x${info.height}, ${Math.round(info.size / 1024)} KB`);
  });
NODE

cp "$WORKDIR/out.jpg" "$OUTPUT"
echo "Written to: $OUTPUT"
ls -lh "$OUTPUT"
file "$OUTPUT"
