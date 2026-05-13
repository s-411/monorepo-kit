#!/usr/bin/env bash
# Nuke lingering Metro/Expo dev servers (KIT_RETROSPECTIVE B7).
# Useful when Expo Go on device has cached a connection to a dead Metro
# on another port. If misbehaviour persists, force-quit Expo Go and rescan.
set -euo pipefail
echo "Killing all 'expo start' processes..."
if pkill -f "expo start"; then
  echo "✓ killed one or more processes."
else
  echo "(none running)"
fi
