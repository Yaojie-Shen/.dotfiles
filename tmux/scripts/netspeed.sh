#!/usr/bin/env bash
# Fixed-width network throughput (down/up) for tmux status bar, auto-scaled
# between K/s, M/s and G/s.
# Rate needs two samples, so this keeps the last one in a state file and
# diffs against it each run - non-blocking, unlike sleeping between samples.
# Only sums physical-ish NIC names, not docker/veth/bridge/lxc interfaces, to
# avoid double-counting bridged traffic.
set -uo pipefail

STATE="${TMPDIR:-/tmp}/.dotfiles_tmux_netspeed_${USER:-$(id -un)}"

COUNTERS=""
case $(uname -s) in
  Darwin)
    COUNTERS=$(netstat -ibn 2>/dev/null | awk '
      $1 ~ /^en[0-9]+$/ && $3 ~ /^<Link#/ {
        rx += $7; tx += $10; found = 1
      }
      END { if (found) print rx, tx }')
    ;;
  Linux)
    if [ -r /proc/net/dev ]; then
      COUNTERS=$(awk '
        $1 ~ /^(eth|en|wlan|wlp)/ {
          gsub(":", "", $1); rx += $2; tx += $10; found = 1
        }
        END { if (found) print rx, tx }' /proc/net/dev)
    fi
    ;;
esac

if [ -z "$COUNTERS" ]; then
  printf "%13s" "N/A"
  exit 0
fi

NOW=$(date +%s)
set -- $COUNTERS
RX_NOW=$1
TX_NOW=$2

RX_K=0
TX_K=0
if [ -f "$STATE" ]; then
  read -r PREV_T PREV_RX PREV_TX < "$STATE"
  DT=$((NOW - PREV_T))
  [ "$DT" -lt 1 ] && DT=1
  RX_K=$(( (RX_NOW - PREV_RX) / DT / 1024 ))
  TX_K=$(( (TX_NOW - PREV_TX) / DT / 1024 ))
  [ "$RX_K" -lt 0 ] && RX_K=0
  [ "$TX_K" -lt 0 ] && TX_K=0
fi
echo "$NOW $RX_NOW $TX_NOW" > "$STATE"

fmt() {
  local kb=$1
  # Switch to G slightly early (1023900, not 1024^2): near the boundary,
  # "%5.1fM" renders 1000.0+ as 6 chars, overflowing the fixed width.
  if [ "$kb" -ge 1023900 ]; then
    awk -v kb="$kb" 'BEGIN { printf "%5.1fG", kb / 1048576 }'
  elif [ "$kb" -ge 1024 ]; then
    awk -v kb="$kb" 'BEGIN { printf "%5.1fM", kb / 1024 }'
  else
    awk -v kb="$kb" 'BEGIN { printf "%5dK", kb }'
  fi
}

printf "󰇚 %s | 󰕒 %s" "$(fmt "$RX_K")" "$(fmt "$TX_K")"
