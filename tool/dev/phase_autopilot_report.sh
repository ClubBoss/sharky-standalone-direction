#!/usr/bin/env bash
set -euo pipefail

print_help() {
  cat <<'USAGE'
Usage: bash tool/dev/phase_autopilot_report.sh [--help]

This helper prints a single JSON line summarizing Phase 1-3 reports.

Options:
  --help    show this help.

Environment:
  PHASE_LOG_INPUT   optional path to the merged log (auto-detected if unset).
  PHASE1_LOG_INPUT  optional Phase 1 log (takes precedence over PHASE_LOG_INPUT).
  PHASE2_LOG_INPUT
  PHASE3_LOG_INPUT
USAGE
}

if [[ "${1:-}" == "--help" ]]; then
  print_help
  exit 0
fi

latest_pattern="/private/tmp/poker_analyzer_phase_logs_*.txt"
merged_log="${PHASE_LOG_INPUT:-}"
phase_logs=(
  "${PHASE1_LOG_INPUT:-}"
  "${PHASE2_LOG_INPUT:-}"
  "${PHASE3_LOG_INPUT:-}"
)

if [[ -z "${merged_log}" && -n "${phase_logs[0]}" ]]; then
  merged_log="${phase_logs[0]}"
fi
if [[ -z "${merged_log}" && -n "${phase_logs[1]}" ]]; then
  merged_log="${phase_logs[1]}"
fi
if [[ -z "${merged_log}" && -n "${phase_logs[2]}" ]]; then
  merged_log="${phase_logs[2]}"
fi
if [[ -z "${merged_log}" ]]; then
  merged_log=$(ls -t $latest_pattern 2>/dev/null | head -n1 || true)
fi

if [[ -z "${merged_log}" && -z "${phase_logs[0]}" && -z "${phase_logs[1]}" && -z "${phase_logs[2]}" ]]; then
  echo "ERROR: no log available for autopilot report"
  print_help
  exit 1
fi

if [[ -n "${merged_log}" && ! -f "${merged_log}" ]]; then
  echo "ERROR: merged log not found: ${merged_log}"
  exit 1
fi

phase_cmd=(bash tool/dev/phase_print_reports.sh --json-only --quiet)

extract_phase_json() {
  local phase="$1"
  local output="$2"
  local prefix="PHASE${phase}_REPORT_JSON="
  local json=""
  local prev=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$prefix"* ]]; then
      local remainder="${line#$prefix}"
      if [[ -n "$remainder" ]]; then
        json="$remainder"
        break
      fi
      prev="$prefix"
      continue
    fi
    if [[ "$prev" == "$prefix" && -n "$line" ]]; then
      json="$line"
      break
    fi
    prev=""
  done <<< "$output"
  printf '%s' "$json"
}

emit_notes() {
  local output="$1"
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == NOTE:* ]]; then
      printf '%s\n' "$line" >&2
    fi
  done <<< "$output"
}

run_phase_report() {
  local phase="$1"
  local log_path="$2"
  local env_var="$3"
  if [[ -z "$log_path" ]]; then
    return
  fi
  set +e
  local output
  output=$(env "$env_var"="$log_path" "${phase_cmd[@]}" --only="phase${phase}" 2>&1)
  local rc=$?
  set -e
  emit_notes "$output"
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase_print_reports (phase${phase}) failed (exit=$rc)"
  fi
  local json
  json=$(extract_phase_json "$phase" "$output")
  if [[ -n "$json" ]]; then
    printf 'PHASE%s_REPORT_JSON=%s\n' "$phase" "$json" >&2
  fi
  printf '%s' "$json"
}

phase1_json=""
phase2_json=""
phase3_json=""

phase1_log="${PHASE1_LOG_INPUT:-$merged_log}"
phase2_log="${PHASE2_LOG_INPUT:-$merged_log}"
phase3_log="${PHASE3_LOG_INPUT:-$merged_log}"

if [[ -n "$phase1_log" ]]; then
  phase1_json=$(run_phase_report 1 "$phase1_log" PHASE1_LOG_INPUT)
fi
if [[ -n "$phase2_log" ]]; then
  phase2_json=$(run_phase_report 2 "$phase2_log" PHASE2_LOG_INPUT)
fi
if [[ -n "$phase3_log" ]]; then
  phase3_json=$(run_phase_report 3 "$phase3_log" PHASE3_LOG_INPUT)
fi



python_cmd=""
if command -v python3 >/dev/null 2>&1; then
  python_cmd=python3
elif command -v python >/dev/null 2>&1; then
  python_cmd=python
else
  echo "NOTE: python3/python not found; cannot emit autopilot report"
  exit 1
fi

summary_json=$(printf '%s\n' "$phase1_json" "$phase2_json" "$phase3_json" | "$python_cmd" - "$phase1_json" "$phase2_json" "$phase3_json" <<'PY'
import json
import sys
import datetime

inputs = sys.argv[1:]
phases = []
for payload in inputs:
    if payload:
        try:
            phases.append(json.loads(payload))
        except Exception:
            phases.append(None)
    else:
        phases.append(None)

ok = True
for payload in phases:
    if payload is None:
        continue
    payload_ok = payload.get("ok")
    if payload_ok is False:
        ok = False
        break

summary = {
    "schema": "phase_autopilot_report_v1",
    "generated_at_utc": datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat(),
    "phase1": phases[0],
    "phase2": phases[1],
    "phase3": phases[2],
    "ok": ok,
}
print(json.dumps(summary, separators=(',', ':')))
PY

)

summary_json="${summary_json%$'\n'}"

if [[ -z "${summary_json:-}" ]]; then
  echo "ERROR: failed to build phase_autopilot_report_v1" >&2
  exit 1
fi

if [[ "${summary_json}" != *phase_autopilot_report_v1* ]]; then
  echo "NOTE: phase_autopilot_report_v1 schema missing from summary" >&2
fi

printf '%s\n' "$summary_json" > /tmp/phase_autopilot_report_v1.json

printf '%s\n' "$summary_json"
