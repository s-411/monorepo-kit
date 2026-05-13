#!/usr/bin/env bash
# Inline Figma's var(--fill-X, #color) CSS-var fills in SVGs so
# react-native-svg can parse them (KIT_RETROSPECTIVE F4).
# Usage: kit/bin/process-figma-svgs.sh [path-to-svg-dir]
# Default target: apps/mobile/assets/
set -euo pipefail
TARGET="${1:-apps/mobile/assets}"
if [ ! -d "$TARGET" ]; then
  echo "Error: '$TARGET' is not a directory"
  exit 1
fi
echo "Scanning $TARGET for SVGs with var(--fill-X, #color) refs..."
count=0
while IFS= read -r -d '' svg; do
  if grep -qE 'var\(--fill-[^,]+,\s*#[0-9A-Fa-f]+\)' "$svg"; then
    sed -i.bak -E 's/var\(--fill-[^,]+,[[:space:]]*(#[0-9A-Fa-f]+)\)/\1/g' "$svg"
    rm -f "${svg}.bak"
    echo "  fixed: $svg"
    count=$((count + 1))
  fi
done < <(find "$TARGET" -name "*.svg" -print0)
echo "✓ Done. Inlined $count file(s)."
