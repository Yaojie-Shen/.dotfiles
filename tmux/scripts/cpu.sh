#!/usr/bin/env bash
# Fixed-width CPU usage for tmux status bar on Linux and macOS.
set -uo pipefail

CPU_USAGE=""
case $(uname -s) in
  Darwin)
    CPU_COUNT=$(sysctl -n hw.logicalcpu 2>/dev/null || true)
    if [ -n "$CPU_COUNT" ]; then
      CPU_USAGE=$(ps -A -o %cpu= 2>/dev/null |
        awk -v cores="$CPU_COUNT" '{ sum += $1 } END {
          if (cores > 0) printf "%5.1f%%", sum / cores
        }')
    fi
    ;;
  Linux)
    CPU_USAGE=$(top -bn1 2>/dev/null |
      awk '/Cpu\(s\)/ { printf "%5.1f%%", $2 + $4; exit }')
    ;;
esac

if [ -n "$CPU_USAGE" ]; then
  printf "%s" "$CPU_USAGE"
else
  printf "%6s" "N/A"
fi
