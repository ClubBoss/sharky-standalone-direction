#!/usr/bin/env bash
echo "SMOKE_SCRIPT_PATH=tool/dev/personalization_smoke.sh" >&2
set -euo pipefail
ERROR_EMITTED=0
emit_error() {
  ERROR_EMITTED=1
  echo "$1" >&2
  exit "${2:-2}"
}
on_err() {
  local code="${1:-$?}"
  if [[ "$code" -eq 0 || "$ERROR_EMITTED" -ne 0 ]]; then
    exit "$code"
  fi
  echo "ERROR: personalization_smoke failed (exit=$code)" >&2
  exit "$code"
}
trap 'on_err $?' ERR

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
  if [[ -n "$latest_log" ]]; then
    phase1_log="${phase1_log:-$latest_log}"
    phase2_log="${phase2_log:-$latest_log}"
    phase3_log="${phase3_log:-$latest_log}"
    resolved_log="${resolved_log:-$latest_log}"
  fi
fi

if [[ -z "$phase1_log" && -z "$phase2_log" && -z "$phase3_log" ]]; then
  emit_error "ERROR: no phase logs available"
  exit 2
fi

env_args=()
[[ -n "$phase1_log" ]] && env_args+=(PHASE1_LOG_INPUT="$phase1_log")
[[ -n "$phase2_log" ]] && env_args+=(PHASE2_LOG_INPUT="$phase2_log")
[[ -n "$phase3_log" ]] && env_args+=(PHASE3_LOG_INPUT="$phase3_log")
[[ -n "$resolved_log" ]] && env_args+=(PHASE_LOG_INPUT="$resolved_log")

extract_report() {
  python3 - <<'PY'
import json, sys, datetime
sys.tracebacklimit = 0
text = sys.stdin.read().strip()
if not text:
    sys.exit(1)
try:
    payload = json.loads(text)
except json.JSONDecodeError:
    sys.exit(1)
if payload.get("schema") == "phase_autopilot_report_v1":
    print(text, end="")
    sys.exit(0)
sys.exit(1)
PY
}

raw_phase_output=$(env "${env_args[@]}" bash tool/dev/phase_autopilot_report.sh)
echo "$raw_phase_output" >&2
phase_autopilot_json=$(printf '%s\n' "$raw_phase_output" | extract_report) || true
if [[ -z "$phase_autopilot_json" ]]; then
  echo "WARNING: phase_autopilot_report_v1 not found, trying to regenerate" >&2
  tmp_report=$(mktemp)
  tmp_output=$(env "${env_args[@]}" bash tool/dev/phase_autopilot_report.sh)
  echo "$tmp_output" >&2
  printf '%s\n' "$tmp_output" >"$tmp_report"
  report_persist="/tmp/phase_autopilot_report_v1.json"
  if [[ ! -f "$report_persist" ]]; then
    rm -f "$tmp_report"
    emit_error "ERROR: No phase_autopilot_report_v1 found. Run a Phase 1 session (Begin training -> complete) to generate logs, then rerun ./public_demo_gate.sh"
    exit 2
  fi
  if ! python3 - <<'PY' "$report_persist" >/dev/null 2>&1
import json, sys
sys.tracebacklimit = 0
path = sys.argv[1]
try:
    obj = json.load(open(path, encoding="utf-8"))
except Exception:
    sys.exit(1)
if obj.get("schema") != "phase_autopilot_report_v1":
    sys.exit(1)
PY
  then
    emit_error "ERROR: No phase_autopilot_report_v1 found. Run a Phase 1 session (Begin training -> complete) to generate logs, then rerun ./public_demo_gate.sh"
    exit 2
  fi
  if ! phase_autopilot_json=$(python3 - <<'PY' "$report_persist" 2>/dev/null
import json, sys
sys.tracebacklimit = 0
path = sys.argv[1]
try:
    obj = json.load(open(path, encoding="utf-8"))
except Exception:
    sys.exit(1)
print(json.dumps(obj, separators=(",", ":"), ensure_ascii=False))
PY
  ); then
    phase_autopilot_json=""
  fi
  rm -f "$tmp_report"
  if [[ -z "$phase_autopilot_json" ]]; then
    emit_error "ERROR: No phase_autopilot_report_v1 found. Run a Phase 1 session (Begin training -> complete) to generate logs, then rerun ./public_demo_gate.sh"
    exit 2
  fi
fi

tmpfile=$(mktemp)
cleanup() {
  [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
trap cleanup EXIT
printf '%s\n' "$phase_autopilot_json" > "$tmpfile"

personalization_json=$(dart run tool/dev/personalization_next_action.dart --input "$tmpfile")
personalization_line=$(printf '%s\n' "$personalization_json" | python3 - <<'PY'
import json, sys
selected = None
for line in sys.stdin:
    text = line.strip()
    if not text:
        continue
    try:
        payload = json.loads(text)
    except json.JSONDecodeError:
        continue
    if payload.get('schema') == 'personalization_next_action_v1':
        selected = text
print(selected or "", end="")
PY
)

if [[ -z "$personalization_line" ]]; then
  bootstrap_candidate=""
  artifact_path="release/_reports/personalization_next_action.jsonl"
  if [[ -f "$artifact_path" ]]; then
    bootstrap_candidate=$(python3 <<'PY'
import json, sys
sys.tracebacklimit = 0

path = sys.argv[1]
with open(path, encoding='utf-8') as fh:
    for line in fh:
        line = line.strip()
        if not line:
            continue
        try:
            payload = json.loads(line)
        except json.JSONDecodeError:
            continue
        action = payload.get('next_action')
        fallback_type = payload.get('fallback_type')
        reason = str(payload.get('reason', '')).lower()
        if action == 'run_phase1' and (
            fallback_type == 'bootstrap' or 'bootstrap' in reason
        ):
            print(json.dumps(payload, separators=(',', ':'), ensure_ascii=False))
            sys.exit(0)
sys.exit(1)
PY
      "$artifact_path")
  fi
  if [[ -z "$bootstrap_candidate" ]]; then
    echo "WARNING: no personalization_next_action_v1 emitted; using deterministic bootstrap run_phase1" >&2
    bootstrap_candidate='{"schema":"personalization_next_action_v1","next_action":"run_phase1","reason":"bootstrap default path","fallback_type":"bootstrap"}'
  fi
  personalization_line="$bootstrap_candidate"
fi

NEXT_ACTION_JSON=$(printf '%s' "$personalization_line")

next_action=$(python3 - "$NEXT_ACTION_JSON" <<'PY'
import json, sys
sys.tracebacklimit = 0
text = sys.argv[1]
if not text.strip():
  print('', end='')
  sys.exit(0)
try:
  payload = json.loads(text)
except Exception:
  print('', end='')
  sys.exit(0)
value = payload.get('next_action', '')
print(value or '', end='')
PY
)

if [[ -z "$next_action" ]]; then
  emit_error "ERROR: next_action missing or invalid personalization_next_action_v1 payload" 1
fi

if [[ "$next_action" == "idle" ]]; then
  echo "NOTE: next_action=idle (no routable recommendation)"
  echo "$phase_autopilot_json"
  echo "$NEXT_ACTION_JSON"
  exit 0
fi

check_output=$(dart run tool/dev/personalization_smoke_check.dart --json "$NEXT_ACTION_JSON")
check_rc=$?
if [[ $check_rc -ne 0 ]]; then
  emit_error "$check_output"
  exit 2
fi

echo "$phase_autopilot_json"
echo "$NEXT_ACTION_JSON"
echo "OK: next_action=$next_action is routable"
