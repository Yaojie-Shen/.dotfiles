#!/usr/bin/env bash
# Fixed-width MEM usage for tmux status bar.
set -uo pipefail

if free -m >/dev/null 2>&1; then
  free -m | awk '/Mem:/ { printf "%5.1f%%", $3/$2*100 }'
else
  printf "%6s" "N/A"
fi
