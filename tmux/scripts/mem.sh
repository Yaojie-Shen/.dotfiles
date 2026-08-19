#!/usr/bin/env bash
# Fixed-width MEM usage for tmux status bar on Linux and macOS.
set -uo pipefail

MEM_USAGE=""
case $(uname -s) in
  Darwin)
    TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null || true)
    if [ -n "$TOTAL_MEM" ]; then
      MEM_USAGE=$(vm_stat 2>/dev/null | awk -v total="$TOTAL_MEM" '
        NR == 1 { page_size = $8 }
        /Pages free:/ { sub(/\.$/, "", $3); free = $3 }
        /Pages inactive:/ { sub(/\.$/, "", $3); inactive = $3 }
        /Pages speculative:/ { sub(/\.$/, "", $3); speculative = $3 }
        END {
          if (page_size > 0 && total > 0)
            printf "%5.1f%%", 100 - (free + inactive + speculative) * page_size / total * 100
        }')
    fi
    ;;
  Linux)
    MEM_USAGE=$(free -m 2>/dev/null |
      awk '/Mem:/ { printf "%5.1f%%", $3 / $2 * 100; exit }')
    ;;
esac

if [ -n "$MEM_USAGE" ]; then
  printf "%s" "$MEM_USAGE"
else
  printf "%6s" "N/A"
fi
