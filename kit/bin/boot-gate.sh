#!/usr/bin/env bash
# kit/bin/boot-gate.sh
#
# REAL boot gate — starts Convex, web, and mobile dev servers in parallel,
# then asks the operator to confirm each one ACTUALLY rendered on its
# target before exiting 0.
#
# Bundle compile success is not boot success. Native module errors (the
# missing expo-crypto crash from D1) only manifest at JS execution time
# on a real device.
#
# Fixes KIT_RETROSPECTIVE.md E1.

set -euo pipefail

# ---------- setup ----------
# Script lives at <repo>/kit/bin/, so REPO_ROOT is two levels up.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$REPO_ROOT/.boot-gate-logs"

# Configurable ports (override via env)
MOBILE_PORT="${MOBILE_PORT:-8082}"
WEB_PORT="${WEB_PORT:-3000}"

mkdir -p "$LOG_DIR"

# ---------- cleanup on exit ----------
PIDS=()
cleanup() {
  echo
  echo "  Shutting down boot-gate processes..."
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  # Belt-and-braces: kill any stray expo/next/convex processes this script started
  pkill -P $$ 2>/dev/null || true
  wait 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# ---------- helpers ----------
start_service() {
  local name="$1"
  local logfile="$LOG_DIR/$name.log"
  shift
  echo "  [$name] starting (log: $logfile)..."
  cd "$REPO_ROOT"
  ( "$@" >"$logfile" 2>&1 ) &
  PIDS+=($!)
}

confirm_running() {
  local name="$1"
  local hint="$2"
  echo
  printf "  ❓ Is $name actually rendering on its target?\n     ($hint)\n     [y/N] "
  read -r ok
  if [[ "$ok" != "y" && "$ok" != "Y" ]]; then
    echo
    echo "  ✗ $name failed boot gate."
    echo "    Check: $LOG_DIR/$name.log"
    echo "    Common causes:"
    case "$name" in
      Convex) echo "      - .env.kit missing CONVEX_TEAM/CONVEX_PROJECT" ;;
      Web)    echo "      - apps/web/.env.local missing NEXT_PUBLIC_CONVEX_URL or Clerk keys" ;;
      Mobile) echo "      - missing expo-crypto peer (KIT_RETROSPECTIVE D1)" ;;
    esac
    exit 1
  fi
  echo "  ✓ $name confirmed."
}

# ---------- header ----------
echo
echo "================================================================"
echo "  monorepo-kit boot-gate"
echo "================================================================"
echo
echo "  This is NOT a curl test. You will be asked to actually open the"
echo "  app on a device/browser and confirm visible render before this"
echo "  script exits successfully."
echo
echo "  Logs stream to .boot-gate-logs/. Tail them in another terminal"
echo "  if a service won't start."
echo

# ---------- start all three services ----------
cd "$REPO_ROOT"

start_service "Convex" \
  pnpm --filter @kit/backend exec convex dev --tail-logs

start_service "Web" \
  pnpm --filter web exec next dev --port "$WEB_PORT"

start_service "Mobile" \
  bash -c "cd apps/mobile && npx expo start --port $MOBILE_PORT --non-interactive"

# Give them a moment to warm up
echo
echo "  Waiting 20 seconds for services to spin up..."
sleep 20

# ---------- confirm one by one ----------
confirm_running "Convex" \
  "tail $LOG_DIR/Convex.log — schema sync complete, no auth errors"

confirm_running "Web" \
  "open http://localhost:$WEB_PORT in browser — page renders, no Clerk/Convex errors in console"

confirm_running "Mobile" \
  "scan QR with Expo Go on a REAL device — app renders default tabs template"

# ---------- success ----------
echo
echo "  ----------------------------------------------------------------"
echo "  ✓ All three services confirmed running on real targets."
echo "  ----------------------------------------------------------------"
echo
echo "  Stage 1 boot gate PASSED."
echo "  Closing this script will kill the dev servers."
echo "  To keep them running, leave this terminal open."
echo
