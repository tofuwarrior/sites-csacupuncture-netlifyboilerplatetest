#!/usr/bin/env bash
# Download real image files from production when the repo only has Git LFS pointers.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_URL="${FETCH_IMAGES_URL:-https://clearspringacupuncture.co.uk}"

cd "$ROOT"

count=0
while IFS= read -r -d '' file; do
  if head -1 "$file" | grep -q "git-lfs"; then
    rel="${file#./}"
    url="${BASE_URL}/${rel}"
    echo "Fetching ${rel}"
    curl -sfL "$url" -o "${file}.tmp"
    mv "${file}.tmp" "$file"
    count=$((count + 1))
  fi
done < <(find images -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.webp' \) -print0)

echo "Fetched ${count} image(s)."
