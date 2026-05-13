#!/usr/bin/env bash
# Always launch Expo from apps/mobile/ (KIT_RETROSPECTIVE B3).
# Running `expo start` from the repo root triggers the legacy
# expo/AppEntry.js fallback which resolves to a non-existent workspace-root
# App.tsx — cryptic failure.
# Pass-through args: --clear (B5), --port <N> (B6), --tunnel, etc.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -d "$REPO_ROOT/apps/mobile" ]; then
  echo "Error: apps/mobile/ not found at $REPO_ROOT/apps/mobile"
  echo "Are you running this from a kit-bootstrapped app, not the kit itself?"
  exit 1
fi
cd "$REPO_ROOT/apps/mobile"
exec npx expo start "$@"
