#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "ERROR: run this script from the repo root (pubspec.yaml not found)"
  exit 1
fi

summarizer=""
for candidate in tool/phase2_summarize_logs.dart tools/phase2_summarize_logs.dart; do
  if [[ -f "$candidate" ]]; then
    summarizer="$candidate"
    break
  fi
done

if [[ -z "$summarizer" ]]; then
  echo "ERROR: summarizer not found (checked tool/phase2_summarize_logs.dart, tools/phase2_summarize_logs.dart)"
  exit 1
fi

run_phase2_print_report() {
  local run_log="$1"
  local script="tool/dev/phase2_print_report.sh"
  if [[ ! -f "$script" ]]; then
    echo "NOTE: phase2_print_report unavailable"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  PHASE2_LOG_INPUT="$run_log" "$script"
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase2_print_report unavailable"
  fi
}

echo "Start Flutter capture: run 1 Phase-2 session, then press q when finished."
CAPTURE_LOG=1 bash tool/dev/run_macos_debug.sh

log_path=$(ls -t /private/tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null | head -n1)
if [[ -z "$log_path" ]]; then
  log_path=$(ls -t /tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null | head -n1)
fi

if [[ -z "$log_path" ]]; then
  echo "ERROR: no poker_analyzer_phase_logs_*.txt found after capture."
  echo "EXIT_CODE=1"
  exit 1
fi

for i in {1..5}; do
  if [[ -s "$log_path" ]]; then
    break
  fi
  sleep 1
done

if [[ ! -s "$log_path" ]]; then
  echo "ERROR: log $log_path is empty."
  echo "EXIT_CODE=1"
  exit 1
fi

echo "FOUND_LOG=$log_path"
if ! grep -q 'PHASE2_FLOW_END' "$log_path"; then
  echo "ERROR: $log_path lacks PHASE2_FLOW_END marker."
  echo "EXIT_CODE=1"
  exit 1
fi
echo "CHECK_FLOW_END=OK"

# Phase2 summarizer: 0=ok, 2=missing markers, 3=below --min_runs (1).
dart run "$summarizer" \
  --input "$log_path" \
  --fail_on_missing \
  --min_runs 1
exit_code=$?
if [[ $exit_code -eq 0 ]]; then
  run_phase2_print_report "$log_path"
fi
echo "EXIT_CODE=$exit_code"
exit $exit_code
