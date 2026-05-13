#!/usr/bin/env bash
# Two-step install ritual after touching Expo deps (KIT_RETROSPECTIVE B2):
# `expo install --fix` bumps package.json versions but does NOT materialise
# node_modules; the trailing `pnpm install` does the swap.
set -euo pipefail
echo "→ pnpm install (baseline)"
pnpm install
echo "→ expo install --fix (align Expo-prefixed packages to SDK)"
pnpm --filter mobile exec expo install --fix
echo "→ pnpm install (materialise version changes)"
pnpm install
echo "✓ install ritual complete."
