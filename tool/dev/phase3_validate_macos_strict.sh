#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "ERROR: run from repo root"
  exit 1
fi

summarizer="tools/phase3_summarize_logs.dart"
if [[ ! -f "$summarizer" ]]; then
  echo "ERROR: $summarizer missing"
  exit 1
fi

run_phase3_print_report() {
  local run_log="$1"
  local script="tool/dev/phase3_print_report.sh"
  if [[ ! -f "$script" ]]; then
    echo "NOTE: phase3_print_report unavailable"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  PHASE3_LOG_INPUT="$run_log" "$script"
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase3_print_report unavailable"
  fi
}

echo "START Phase-3 capture; run 1 Phase-3 session (tap the Continue training CTA once if you want PHASE3_RETURN_CTA_TAPPED logged), then press q when ready to exit."
CAPTURE_LOG=1 bash tool/dev/run_macos_debug.sh | tee /tmp/phase3_capture_output.log

log_path=""
for prefix in "Log capture:" "Log saved to"; do
  path=$(grep -m1 "$prefix" /tmp/phase3_capture_output.log || true)
  if [[ -n "$path" ]]; then
    log_path=$(printf '%s\n' "$path" | awk -F"$prefix" '{print $2}' | tr -d '[:space:]')
    break
  fi
done

if [[ -z "$log_path" ]]; then
  log_path=$(ls -t /private/tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null | head -n1)
  [[ -z "$log_path" ]] && log_path=$(ls -t /tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null | head -n1)
fi

if [[ -z "$log_path" ]]; then
  echo "ERROR: No Phase-3 log created."
  echo "EXIT_CODE=1"
  exit 1
fi

attempt=0
while [[ $attempt -lt 20 && ! -s "$log_path" ]]; do
  sleep 1
  attempt=$((attempt + 1))
  if [[ $attempt -eq 5 ]]; then
    if [[ "$log_path" == /tmp/* && -f "/private/tmp/${log_path#/tmp/}" ]]; then
      log_path="/private/tmp/${log_path#/tmp/}"
    fi
  fi
done

if [[ ! -s "$log_path" ]]; then
  echo "ERROR: Log $log_path is empty."
  echo "EXIT_CODE=1"
  exit 1
fi

echo "FOUND_LOG=$log_path"
return_signal_count=$(grep -c 'PHASE3_RETURN_SIGNAL' "$log_path")
flow_end_count=$(grep -c 'PHASE3_FLOW_END' "$log_path")
cta_shown_count=$(grep -c 'PHASE3_RETURN_CTA_SHOWN' "$log_path")
cta_tapped_count=$(grep -c 'PHASE3_RETURN_CTA_TAPPED' "$log_path")
echo "PHASE3_RETURN_SIGNAL=$return_signal_count"
echo "PHASE3_FLOW_END=$flow_end_count"
echo "PHASE3_RETURN_CTA_SHOWN=$cta_shown_count"
echo "PHASE3_RETURN_CTA_TAPPED=$cta_tapped_count"
if ! grep -q 'PHASE3_FLOW_END' "$log_path"; then
  echo "ERROR: missing PHASE3_FLOW_END in $log_path"
  echo "EXIT_CODE=1"
  exit 1
fi
echo "CHECK_MARKER=OK"

signaled_count=$(grep -c 'PHASE3_FLOW_END.*"result":"signaled"' "$log_path")
if [[ $signaled_count -gt 0 && $cta_shown_count -eq 0 ]]; then
  echo "WARNING: signaled run(s) detected but PHASE3_RETURN_CTA_SHOWN count is 0."
fi

# Phase3 summarizer contract: exit 0=ok, 2=missing markers, 3=below --min_runs (here 1).
set +e
summary_json=$(dart run "$summarizer" --input "$log_path" --fail_on_missing --min_runs 1)
exit_code=$?
set -e

echo "$summary_json"
python_bin=""
if command -v python3 >/dev/null 2>&1; then
  python_bin=python3
elif command -v python >/dev/null 2>&1; then
  python_bin=python
fi
if [[ -z "$python_bin" ]]; then
  echo "NOTE: python not found; skipping CTA latency stats."
else
  set +e
  latency_info=$(printf '%s' "$summary_json" | "$python_bin" - <<'PY'
import json
import sys

text = sys.stdin.read()
try:
    data = json.loads(text) if text.strip() else {}
except Exception:
    print("CTA_TAP_LATENCY_MS min=NA p50=NA p90=NA max=NA mean=NA")
    sys.exit(0)

latency = data.get('cta_tap_latency_ms') or {}
keys = ('min', 'p50', 'p90', 'max', 'mean')
values = {key: latency.get(key) for key in keys}
line = "CTA_TAP_LATENCY_MS " + " ".join(
    f"{key}={(values[key] if values[key] is not None else 'NA')}" for key in keys
)
print(line)
tapped = data.get('cta_tapped_count', 0) or 0
invalid = any(
    values[key] is None or
    (isinstance(values[key], (int, float)) and values[key] < 0)
    for key in keys
)
if tapped and invalid:
    print("WARNING: CTA tap latency stats look suspicious (tapped_count>0 with null/negative values).")
PY
  )
  python_status=$?
  set -e
  if [[ $python_status -ne 0 ]]; then
    echo "NOTE: python failed to parse CTA latency stats."
  else
    echo "$latency_info"
  fi
fi
if [[ $exit_code -eq 0 ]]; then
  run_phase3_print_report "$log_path"
fi
echo "EXIT_CODE=$exit_code"
exit $exit_code
