#!/usr/bin/env bash
# Fixed-width average GPU load + memory usage for tmux status bar.
# On Apple Silicon, GPU memory is unified memory, so the second percentage is
# the GPU's in-use system memory divided by total system memory.
set -uo pipefail

if command -v nvidia-smi >/dev/null 2>&1; then
  GPU_MEM=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits |
    awk '{used += $1; total += $2} END {if (total > 0) print int(used / total * 100)}')
  GPU_LOAD=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits |
    awk '{sum += $1; count++} END {if (count > 0) print int(sum / count)}')
  if [ -n "$GPU_MEM" ] && [ -n "$GPU_LOAD" ]; then
    printf "%3d%% / %3d%%" "$GPU_LOAD" "$GPU_MEM"
  else
    # A one-off nvidia-smi query failure on a machine that does have a GPU -
    # keep the width matching real content, since the next tick likely goes
    # back to it (unlike the no-GPU branch below, which is permanent).
    printf "%11s" "N/A"
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v ioreg >/dev/null 2>&1; then
  GPU_STATS=$(ioreg -r -c IOAccelerator -l -w 0 2>/dev/null |
    awk '/"PerformanceStatistics"/ { print; exit }')
  GPU_LOAD=$(printf "%s\n" "$GPU_STATS" |
    sed -nE 's/.*"Device Utilization %"=([0-9]+).*/\1/p')
  GPU_USED=$(printf "%s\n" "$GPU_STATS" |
    sed -nE 's/.*"In use system memory"=([0-9]+).*/\1/p')
  TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null || true)

  if [ -n "$GPU_LOAD" ] && [ -n "$GPU_USED" ] && [ -n "$TOTAL_MEM" ]; then
    GPU_MEM=$((GPU_USED * 100 / TOTAL_MEM))
    [ "$GPU_MEM" -gt 100 ] && GPU_MEM=100
    printf "%3d%% / %3d%%" "$GPU_LOAD" "$GPU_MEM"
  else
    printf "%11s" "N/A"
  fi
else
  # No nvidia-smi at all - this machine never shows real content, so there's
  # no width to stay consistent with; keep the placeholder short.
  printf "N/A"
fi
