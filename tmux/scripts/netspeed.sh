#!/usr/bin/env bash
# Fixed-width network throughput (down/up) for tmux status bar, auto-scaled
# between K/s, M/s and G/s.
# Rate needs two samples, so this keeps the last one in a state file and
# diffs against it each run - non-blocking, unlike sleeping between samples.
# Only sums eth*/en*/wlan*/wlp* interfaces (physical-ish NIC naming), not
# docker/veth/bridge/lxc interfaces, to avoid double-counting bridged traffic.
set -uo pipefail

STATE="/tmp/.dotfiles_tmux_netspeed_${USER:-$(id -un)}"

if [ ! -r /proc/net/dev ]; then
  printf "%13s" "N/A"
  exit 0
fi

NOW=$(date +%s)
set -- $(awk '$1 ~ /^(eth|en|wlan|wlp)/ { gsub(":", "", $1); rx += $2; tx += $10 } END { print rx+0, tx+0 }' /proc/net/dev)
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
  if [ "$kb" -ge 1048576 ]; then
    awk -v kb="$kb" 'BEGIN { printf "%5.1fG", kb / 1048576 }'
  elif [ "$kb" -ge 1024 ]; then
    awk -v kb="$kb" 'BEGIN { printf "%5.1fM", kb / 1024 }'
  else
    awk -v kb="$kb" 'BEGIN { printf "%5dK", kb }'
  fi
}

printf " %s  %s" "$(fmt "$RX_K")" "$(fmt "$TX_K")"
