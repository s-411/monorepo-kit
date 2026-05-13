#!/usr/bin/env bash
# Flip pnpm 11's auto-appended 'set this to true or false' placeholders in
# pnpm-workspace.yaml to real `true` values (KIT_RETROSPECTIVE G1c).
# pnpm 11 appends these stubs whenever `pnpm add` introduces a new
# build-requiring package; left unflipped, they defeat the allowBuilds
# defence and the next scaffolder hits ERR_PNPM_IGNORED_BUILDS.
set -euo pipefail
WORKSPACE_YAML="pnpm-workspace.yaml"
if [ ! -f "$WORKSPACE_YAML" ]; then
  echo "Error: $WORKSPACE_YAML not found. Run from repo root."
  exit 1
fi
PLACEHOLDERS=$(grep -v '^[[:space:]]*#' "$WORKSPACE_YAML" \
  | grep -c 'set this to true or false' || true)
if [ "${PLACEHOLDERS:-0}" -eq 0 ]; then
  echo "No placeholder entries found — nothing to fix."
  exit 0
fi
echo "Found $PLACEHOLDERS placeholder entries:"
grep -v '^[[:space:]]*#' "$WORKSPACE_YAML" \
  | grep 'set this to true or false' | sed 's/^/  /'
echo ""
read -p "Flip all to 'true'? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted. No changes made."
  exit 0
fi
sed -i.bak 's/set this to true or false/true/g' "$WORKSPACE_YAML"
rm -f "${WORKSPACE_YAML}.bak"
echo "✓ $PLACEHOLDERS entries flipped to true."
echo "  Re-run 'pnpm install' to pick up the change."
