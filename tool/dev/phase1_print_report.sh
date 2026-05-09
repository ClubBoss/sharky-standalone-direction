#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PHASE1_LOG_INPUT:-}" ]]; then
  echo "ERROR: PHASE1_LOG_INPUT is required"
  exit 1
fi
if [[ ! -f "${PHASE1_LOG_INPUT}" ]]; then
  echo "ERROR: PHASE1_LOG_INPUT not found: ${PHASE1_LOG_INPUT}"
  exit 1
fi

comparator="tools/phase1_compare_passes.dart"
compare_output="${PHASE1_PASS_COMPARE_JSON:-}"
if [[ -z "${compare_output}" ]]; then
  if [[ -f "$comparator" ]]; then
    set +e
    compare_output=$(dart run "$comparator" --input "${PHASE1_LOG_INPUT}")
    compare_rc=$?
    set -e
    if [[ $compare_rc -ne 0 ]]; then
      echo "NOTE: phase1_compare_passes failed (exit=$compare_rc)"
      compare_output=""
    fi
  else
    echo "NOTE: comparator missing ($comparator)"
  fi
fi

python_cmd=""
if command -v python3 >/dev/null 2>&1; then
  python_cmd=python3
elif command -v python >/dev/null 2>&1; then
  python_cmd=python
else
  echo "NOTE: python3/python not found for parsing comparator output"
  exit 2
fi

 "$python_cmd" - "$compare_output" <<'PY'
import json
import sys

text = sys.argv[1] if len(sys.argv) > 1 else ""
candidate = None
last_payload = None
schema = "phase1_pass_compare_v1"

for line in text.splitlines():
    line = line.strip()
    if not line:
        continue
    payload_text = line
    if line.startswith("PHASE1_PASS_COMPARE_JSON="):
        payload_text = line.split("=", 1)[1].strip()
    try:
        payload = json.loads(payload_text)
    except json.JSONDecodeError:
        continue
    last_payload = payload
    if payload.get("schema") == schema:
        candidate = payload

if candidate is None:
    if last_payload is not None:
        candidate = last_payload
    else:
        candidate = {}

data = candidate
passes = data.get("passes", {})
pass_a = passes.get('A', {})
pass_b = passes.get('B', {})

def fmt_accuracy(value):
    if value is None:
        return 'NA'
    return f'{float(value):.3f}'

def fmt_count(value):
    if value is None:
        return 'NA'
    value = float(value)
    if value.is_integer():
        return str(int(value))
    return f'{value:.1f}'

def fmt_time(value, decimals=1):
    if value is None:
        return 'NA'
    value = float(value)
    if value.is_integer():
        return str(int(value))
    return f'{value:.{decimals}f}'

acc_a = pass_a.get('accuracy')
acc_b = pass_b.get('accuracy')
acc_delta = data.get('accuracy_delta') or (acc_b is not None and acc_a is not None and float(acc_b) - float(acc_a))
mean_a = pass_a.get('decision_time_ms_mean')
mean_b = pass_b.get('decision_time_ms_mean')
mean_delta = data.get('decision_time_mean_delta_ms') or (
    mean_b is not None and mean_a is not None and float(mean_b) - float(mean_a)
)
p50_a = pass_a.get('decision_time_ms_p50')
p50_b = pass_b.get('decision_time_ms_p50')
p90_a = pass_a.get('decision_time_ms_p90')
p90_b = pass_b.get('decision_time_ms_p90')

attempts_a = pass_a.get('attempts_total')
attempts_b = pass_b.get('attempts_total')
correct_a = pass_a.get('correct_count')
correct_b = pass_b.get('correct_count')
incorrect_a = pass_a.get('incorrect_count')
incorrect_b = pass_b.get('incorrect_count')

report_line = (
    f"PHASE1_REPORT attempts_A={fmt_count(attempts_a)} "
    f"correct_A={fmt_count(correct_a)} "
    f"incorrect_A={fmt_count(incorrect_a)} "
    f"mean_ms_A={fmt_time(mean_a)} "
    f"attempts_B={fmt_count(attempts_b)} "
    f"correct_B={fmt_count(correct_b)} "
    f"incorrect_B={fmt_count(incorrect_b)} "
    f"mean_ms_B={fmt_time(mean_b)} "
    f"accuracy_A={fmt_accuracy(acc_a)} "
    f"accuracy_B={fmt_accuracy(acc_b)} "
    f"accuracy_delta={fmt_accuracy(acc_delta)} "
    f"decision_time_mean_delta_ms={fmt_time(mean_delta)} | "
    f"p50_ms A={fmt_time(p50_a)} B={fmt_time(p50_b)} | "
    f"p90_ms A={fmt_time(p90_a)} B={fmt_time(p90_b)}"
)
print(report_line)
print(f"PHASE1_REPORT_JSON={json.dumps(data)}")
PY
