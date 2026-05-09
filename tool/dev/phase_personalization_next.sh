#!/usr/bin/env bash
set -euo pipefail

REPORTS_DIR="release/_reports"
OUT_PATH="${REPORTS_DIR}/personalization_next_action.jsonl"

tmpfile=""
cleanup_tempfile() {
  if [[ -n "${tmpfile:-}" && -f "$tmpfile" ]]; then
    rm -f "$tmpfile"
  fi
}
trap cleanup_tempfile EXIT

latest_pattern="/private/tmp/poker_analyzer_phase_logs_*.txt"

phase1_log="${PHASE1_LOG_INPUT:-}"
phase2_log="${PHASE2_LOG_INPUT:-}"
phase3_log="${PHASE3_LOG_INPUT:-}"
resolved_log="${PHASE_LOG_INPUT:-}"

phase1_log="${phase1_log:-$resolved_log}"
phase2_log="${phase2_log:-$resolved_log}"
phase3_log="${phase3_log:-$resolved_log}"

if [[ -z "$phase1_log" || -z "$phase2_log" || -z "$phase3_log" ]]; then
  latest_log=$({ ls -t $latest_pattern 2>/dev/null || true; } | head -n1)
  if [[ -n "${latest_log:-}" ]]; then
    phase1_log="${phase1_log:-$latest_log}"
    phase2_log="${phase2_log:-$latest_log}"
    phase3_log="${phase3_log:-$latest_log}"
    resolved_log="${resolved_log:-$latest_log}"
  fi
fi

if [[ -z "$phase1_log" && -z "$phase2_log" && -z "$phase3_log" ]]; then
  echo "ERROR: no phase logs available for personalization next action" >&2
  exit 2
fi

autop_env=()
if [[ -n "$phase1_log" ]]; then
  autop_env+=(PHASE1_LOG_INPUT="$phase1_log")
fi
if [[ -n "$phase2_log" ]]; then
  autop_env+=(PHASE2_LOG_INPUT="$phase2_log")
fi
if [[ -n "$phase3_log" ]]; then
  autop_env+=(PHASE3_LOG_INPUT="$phase3_log")
fi
if [[ -n "$resolved_log" ]]; then
  autop_env+=(PHASE_LOG_INPUT="$resolved_log")
fi

set +e
autop_output=$(env "${autop_env[@]}" bash tool/dev/phase_autopilot_report.sh)
autop_rc=$?
set -e
if [[ $autop_rc -ne 0 ]]; then
  echo "ERROR: phase_autopilot_report.sh failed (exit=$autop_rc)" >&2
  exit 2
fi

phase_autopilot_json=$(printf '%s\n' "$autop_output" | python - <<'PY'
import json
import sys

selected = None
for row in sys.stdin:
    candidate = row.rstrip('\n')
    stripped = candidate.strip()
    if not stripped:
        continue
    try:
        payload = json.loads(stripped)
    except json.JSONDecodeError:
        continue
    if payload.get("schema") == "phase_autopilot_report_v1":
        selected = candidate
print(selected or "", end="")
PY
)

if [[ -z "$phase_autopilot_json" ]]; then
  echo "ERROR: phase_autopilot_report_v1 not found in phase_autopilot_report output" >&2
  exit 2
fi

tmpfile=$(mktemp)
printf '%s\n' "$phase_autopilot_json" > "$tmpfile"

set +e
personalization_output=$(dart run tool/dev/personalization_next_action.dart --input "$tmpfile")
personalization_rc=$?
set -e
if [[ $personalization_rc -ne 0 ]]; then
  printf '%s\n' "$personalization_output"
  exit $personalization_rc
fi

if [[ -z "${personalization_output:-}" ]]; then
  echo "ERROR: personalization_next_action did not emit output" >&2
  exit 2
fi

summary_line=$(printf '%s\n' "$personalization_output" | python - <<'PY'
import json
import sys

content = sys.stdin.read().strip()
if not content:
    sys.exit(1)
data = json.loads(content)
action = data.get("next_action", "")
reason = json.dumps(data.get("reason", ""))
print(f"PERSONALIZATION_NEXT_ACTION={action} reason={reason}")
PY
)

printf '%s\n' "$summary_line"
printf '%s\n' "$personalization_output"

mkdir -p "$REPORTS_DIR"
printf '%s\n' "$personalization_output" > "$OUT_PATH"
printf 'NOTE: personalization_next_action artifact written to %s\n' "$OUT_PATH" >&2
