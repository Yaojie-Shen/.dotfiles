#!/usr/bin/env bash
# Fixed-width CPU usage for tmux status bar. A single awk pass does both the
# calculation and the fixed-width formatting.
set -uo pipefail

if top -bn1 >/dev/null 2>&1; then
  top -bn1 | grep "Cpu(s)" | awk '{ printf "%5.1f%%", $2 + $4 }'
else
  printf "%6s" "N/A"
fi
