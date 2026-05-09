#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PHASE3_LOG_INPUT:-}" ]]; then
  echo "NOTE: PHASE3_LOG_INPUT missing"
  exit 1
fi
if [[ ! -f "${PHASE3_LOG_INPUT}" ]]; then
  echo "NOTE: PHASE3_LOG_INPUT not found: ${PHASE3_LOG_INPUT}"
  exit 1
fi

summarizer="tools/phase3_summarize_logs.dart"
if [[ ! -f "$summarizer" ]]; then
  echo "NOTE: $summarizer missing"
  exit 1
fi

set +e
summary_output=$(dart run "$summarizer" --input "$PHASE3_LOG_INPUT" --fail_on_missing --min_runs 1 2>&1)
rc=$?
set -e
if [[ $rc -ne 0 ]]; then
  echo "NOTE: phase3_summarize_logs failed (exit=$rc)"
  exit $rc
fi

python_cmd=""
if command -v python3 >/dev/null 2>&1; then
  python_cmd=python3
elif command -v python >/dev/null 2>&1; then
  python_cmd=python
fi

phase_summary_extractor=$(cat <<'PY'
import json
import sys

schema = sys.argv[1]
candidate = None
last = None
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        payload = json.loads(line)
    except json.JSONDecodeError:
        continue
    last = payload
    if payload.get("schema") == schema:
        candidate = payload
if candidate is None:
    candidate = last
print(json.dumps(candidate or {}))
PY
)

extract_summary_json_python() {
  local schema="$1"
  "$python_cmd" -c "$phase_summary_extractor" "$schema"
}

extract_summary_json_shell() {
  local schema="$1"
  local input="$2"
  local candidate=""
  while IFS= read -r line; do
    line="${line//$'\r'/}"
    if [[ "$line" == *"\"schema\""*"\"$schema\""* ]]; then
      candidate="$line"
    fi
  done <<< "$input"
  printf '%s' "${candidate:-}"
}

extract_summary_json() {
  local schema="$1"
  local input="$2"
  if [[ -n "$python_cmd" ]]; then
    printf '%s\n' "$input" | extract_summary_json_python "$schema"
  else
    extract_summary_json_shell "$schema" "$input"
  fi
}

phase_json=$(extract_summary_json phase3_summary_v1 "$summary_output")

if [[ -z "$phase_json" ]]; then
  phase_json="{}"
fi

echo "PHASE3_REPORT_JSON=${phase_json}"

if [[ -z "$python_cmd" ]]; then
  echo "NOTE: phase3_print_report python unavailable"
  exit 0
fi

phase3_report_formatter=$(cat <<'PY'
import json
import sys

def fmt(value):
    if value is None:
        return "NA"
    return str(value)

def fmt_latency(value):
    if value is None:
        return "NA"
    return str(value)

try:
    data = json.loads(sys.stdin.read())
except Exception:
    data = {}

latency = data.get("cta_tap_latency_ms", {})

print(
    "PHASE3_REPORT total_runs={total_runs} cta_shown={cta_shown} "
    "cta_tapped={cta_tapped} latency_ms_p50={latency_p50} "
    "latency_ms_mean={latency_mean}".format(
        total_runs=fmt(data.get("total_runs")),
        cta_shown=fmt(data.get("cta_shown_count")),
        cta_tapped=fmt(data.get("cta_tapped_count")),
        latency_p50=fmt_latency(latency.get("p50")),
        latency_mean=fmt_latency(latency.get("mean")),
    )
)
PY
)

printf '%s\n' "$phase_json" | "$python_cmd" -c "$phase3_report_formatter" || true
