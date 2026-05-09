#!/usr/bin/env bash
set -euo pipefail

latest_pattern="/private/tmp/poker_analyzer_phase_logs_*.txt"
phase1_log="${PHASE1_LOG_INPUT:-}"
resolved="${PHASE_LOG_INPUT:-}"
phase1_log="${phase1_log:-$resolved}"

if [[ -z "$phase1_log" ]]; then
  phase1_log=$({ ls -t $latest_pattern 2>/dev/null || true; } | head -n1)
fi

if [[ -z "$phase1_log" ]]; then
  echo "ERROR: no Phase 1 log available" >&2
  exit 2
fi

marker_count=$(grep -c 'PHASE1_FLOW_END' "$phase1_log" || true)

if [[ "$marker_count" -eq 0 ]]; then
  echo "ERROR: PHASE1_FLOW_END missing in $phase1_log" >&2
  exit 2
fi

if [[ "$marker_count" -gt 1 ]]; then
  echo "ERROR: PHASE1_FLOW_END appears $marker_count times in $phase1_log" >&2
  exit 2
fi

echo "OK: PHASE1_FLOW_END observed once in $(basename "$phase1_log")"
