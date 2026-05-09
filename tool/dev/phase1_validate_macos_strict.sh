#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "ERROR: run from repo root"
  exit 1
fi

summarizer="tools/phase1_summarize_logs.dart"
if [[ ! -f "$summarizer" ]]; then
  echo "ERROR: $summarizer missing"
  exit 1
fi

echo "START Phase-1 capture; run 1 Phase-1 session, then press q when ready to exit."
CAPTURE_LOG=1 bash tool/dev/run_macos_debug.sh | tee /tmp/phase1_capture_output.log

log_path=""
for prefix in "Log capture:" "Log saved to"; do
  path=$(grep -m1 "$prefix" /tmp/phase1_capture_output.log || true)
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
  echo "ERROR: No Phase-1 log created."
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
for marker in 'PHASE1_SESSION_START' 'PHASE1_ATTEMPT_START' 'PHASE1_ATTEMPT_RESULT' 'PHASE1_FLOW_END'; do
  printf '%s=%s\n' "$marker" "$(grep -c "$marker" "$log_path")"
done

# Phase1 summarizer contract: exit 0=ok, 2=missing markers, 3=below --min_runs (1).
set +e
summary=$(dart run "$summarizer" --input "$log_path" --fail_on_missing --min_runs 1)
exit_code=$?
set -e

echo "$summary"
echo "EXIT_CODE=$exit_code"

if [[ $exit_code -eq 0 ]]; then
  comparator="tools/phase1_compare_passes.dart"
  if [[ -f "$comparator" ]]; then
    set +e
    compare_json=$(dart run "$comparator" --input "$log_path")
    compare_rc=$?
    set -e
    if [[ $compare_rc -eq 0 ]]; then
      echo "PHASE1_PASS_COMPARE_JSON="
      printf '%s\n' "$compare_json"
    else
      echo "NOTE: phase1 comparator failed with exit code $compare_rc"
    fi
  else
    echo "NOTE: comparator missing ($comparator)"
  fi
  report_script="tool/dev/phase1_print_report.sh"
  if [[ -f "$report_script" ]]; then
    set +e
    PHASE1_LOG_INPUT="$log_path" "$report_script"
    report_rc=$?
    set -e
    if [[ $report_rc -ne 0 ]]; then
      echo "NOTE: phase1_print_report failed (exit=$report_rc)"
    fi
  else
    echo "NOTE: phase1_print_report not found"
  fi
fi
exit $exit_code
