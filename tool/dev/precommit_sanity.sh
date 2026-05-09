#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUN_PHASE4_ALL:-0}" == "1" ]]; then
  [[ -z "${RUN_PHASE4_REGRESSION+x}" ]] && export RUN_PHASE4_REGRESSION=1
  [[ -z "${RUN_PHASE4_REGRESSION_LOGS+x}" ]] && export RUN_PHASE4_REGRESSION_LOGS=1
  [[ -z "${RUN_PHASE4_REGRESSION_TESTS+x}" ]] && export RUN_PHASE4_REGRESSION_TESTS=1
  [[ -z "${RUN_PHASE4_INSET_GUARD+x}" ]] && export RUN_PHASE4_INSET_GUARD=1
  [[ -z "${RUN_PHASE4_INSET_GUARD_TESTS+x}" ]] && export RUN_PHASE4_INSET_GUARD_TESTS=1
fi

phase4_requested=0
stub_status="skip"
logs_status="skip"
log_tests_status="skip"
inset_guard_status="skip"
inset_guard_tests_status="skip"

## Phase 4 — Regression (opt-in)
if [[ "${RUN_PHASE4_REGRESSION:-0}" == "1" ]]; then
  phase4_requested=1
  # Phase 4 regression stub is debug-only; opt-in via env flag.
  dart run tools/phase4_regression_stub.dart
  stub_status="pass"
fi

if [[ "${RUN_PHASE4_REGRESSION_LOGS:-0}" == "1" ]]; then
  phase4_requested=1
  # Validate Phase 1-3 logs captured in PHASE4_LOG_INPUT.
  if [[ -z "${PHASE4_LOG_INPUT:-}" ]]; then
    latest_log="$(ls -t /tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null | head -n1 || true)"
    if [[ -n "$latest_log" ]]; then
      export PHASE4_LOG_INPUT="$latest_log"
    fi
  fi
  if [[ -n "${PHASE4_LOG_INPUT:-}" ]]; then
    dart run tools/phase4_regression_validate_logs.dart --input "${PHASE4_LOG_INPUT}"
    logs_status="pass"
  else
    echo "INFO: phase4 log validation skipped; no log file found."
  fi
fi

if [[ "${RUN_PHASE4_REGRESSION_TESTS:-0}" == "1" ]]; then
  phase4_requested=1
  # Run the Phase 4 regression log validator test suite (opt-in hook).
  dart test test/phase4_regression_validate_logs_test.dart
  log_tests_status="pass"
fi

if [[ "${RUN_PHASE4_INSET_GUARD:-0}" == "1" ]]; then
  phase4_requested=1
  # Guard against SafeArea bottom+padding stacking regressions.
  dart run tools/phase4_regression_inset_guard.dart
  inset_guard_status="pass"
fi

if [[ "${RUN_PHASE4_INSET_GUARD_TESTS:-0}" == "1" ]]; then
  phase4_requested=1
  # Opt-in test ensuring the inset guard stays green.
  dart test test/phase4_regression_inset_guard_test.dart
  inset_guard_tests_status="pass"
fi

if [[ "${phase4_requested:-0}" == "1" ]]; then
  printf '%s\n' \
    "{\"event\":\"REGRESSION_PHASE4_SUMMARY\",\"stub\":\"$stub_status\",\"logs\":\"$logs_status\",\"log_tests\":\"$log_tests_status\",\"inset_guard\":\"$inset_guard_status\",\"inset_guard_tests\":\"$inset_guard_tests_status\"}"
fi

if [[ "${RUN_PHASE2_STRICT:-0}" == "1" ]]; then
  check_shell_syntax_strict
  if [[ -z "${PHASE2_LOG_INPUT:-}" ]]; then
    echo "ERROR: RUN_PHASE2_STRICT requires PHASE2_LOG_INPUT"
    exit 1
  fi
  if [[ ! -f "${PHASE2_LOG_INPUT}" ]]; then
    echo "ERROR: PHASE2_LOG_INPUT not found: ${PHASE2_LOG_INPUT}"
    exit 1
  fi
  # Phase2 summarizer contract: 0=ok, 2=missing markers, 3=below --min_runs (1).
  dart run tools/phase2_summarize_logs.dart \
    --input "${PHASE2_LOG_INPUT}" \
    --fail_on_missing \
    --min_runs 1
  run_phase2_print_report "${PHASE2_LOG_INPUT}"
fi

if [[ "${RUN_PHASE3_STRICT:-0}" == "1" ]]; then
  check_shell_syntax_strict
  if [[ -z "${PHASE3_LOG_INPUT:-}" ]]; then
    echo "ERROR: RUN_PHASE3_STRICT requires PHASE3_LOG_INPUT"
    exit 1
  fi
  if [[ ! -f "${PHASE3_LOG_INPUT}" ]]; then
    echo "ERROR: PHASE3_LOG_INPUT not found: ${PHASE3_LOG_INPUT}"
    exit 1
  fi
  dart run tools/phase3_summarize_logs.dart \
    --input "${PHASE3_LOG_INPUT}" \
    --fail_on_missing \
    --min_runs 1
  run_phase3_print_report "${PHASE3_LOG_INPUT}"
  # Phase3 summarizer contract: 0=ok, 2=missing markers, 3=too few runs (min_runs=1).
fi
run_phase1_comparator() {
  local run_log="$1"
  local comparator="tools/phase1_compare_passes.dart"
  if [[ ! -f "$comparator" ]]; then
    echo "NOTE: comparator missing ($comparator)"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  local compare_json
  compare_json=$(dart run "$comparator" --input "$run_log")
  local compare_rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $compare_rc -eq 0 ]]; then
    echo "PHASE1_PASS_COMPARE_JSON="
    printf '%s\n' "$compare_json"
  else
    echo "NOTE: phase1_compare_passes failed (exit=$compare_rc)"
  fi
}

run_phase1_print_report() {
  local run_log="$1"
  local script="tool/dev/phase1_print_report.sh"
  if [[ ! -f "$script" ]]; then
    echo "NOTE: phase1_print_report not found"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  PHASE1_LOG_INPUT="$run_log" "$script"
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase1_print_report failed (exit=$rc)"
  fi
}

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

check_shell_syntax_strict() {
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  bash -n "$0" >/dev/null 2>&1
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: precommit_sanity.sh syntax check failed (exit=$rc)"
  fi
}

run_phase_report_wrapper() {
  local script="tool/dev/phase_print_reports.sh"
  if [[ ! -f "$script" ]]; then
    echo "NOTE: phase_print_reports not found"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  bash "$script" --json-only --quiet
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase_print_reports failed (exit=$rc)"
  fi
}

run_phase_autopilot_report() {
  local script="tool/dev/phase_autopilot_report.sh"
  if [[ ! -f "$script" ]]; then
    echo "NOTE: phase_autopilot_report unavailable"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  bash "$script"
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase_autopilot_report unavailable"
  fi
}

run_phase_personalization_next() {
  local script="tool/dev/phase_personalization_next.sh"
  if [[ ! -f "$script" ]]; then
    echo "NOTE: phase_personalization_next unavailable"
    return
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  bash "$script"
  local rc=$?
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: phase_personalization_next unavailable"
  fi
}

# helper to keep strict usage messaging consistent
print_phase_strict_usage() {
  echo "Phase strict: preferred usage -> RUN_PHASE_STRICT=1 PHASE_LOG_INPUT=\"/private/tmp/poker_analyzer_phase_logs_XXXX.txt\" bash tool/dev/precommit_sanity.sh"
  echo "Phase strict: override example -> RUN_PHASE_STRICT=1 PHASE_LOG_INPUT=\"A.txt\" PHASE2_LOG_INPUT=\"B.txt\" bash tool/dev/precommit_sanity.sh"
  echo "Tip: tool/dev/phase_strict_all.sh runs strict+reports via auto-resolved PHASE_LOG_INPUT"
}

if [[ "${RUN_PHASE_STRICT:-0}" == "1" ]]; then
  check_shell_syntax_strict
# Usage tip: seed all phases at once
# RUN_PHASE_STRICT=1 PHASE_LOG_INPUT="/private/tmp/poker_analyzer_phase_logs_20260103T154823Z.txt" bash tool/dev/precommit_sanity.sh
# Usage tip: override a specific phase
# RUN_PHASE_STRICT=1 PHASE_LOG_INPUT="/tmp/log_all.txt" PHASE2_LOG_INPUT="/tmp/only_phase2.txt" bash tool/dev/precommit_sanity.sh
  python_cmd=""
  if command -v python3 >/dev/null 2>&1; then
    python_cmd=python3
  elif command -v python >/dev/null 2>&1; then
    python_cmd=python
  fi
  check_phase_summary_ok() {
    local phase="$1"
    local summary="$2"
    printf '%s\n' "$summary"
    if [[ "${PHASE_SUMMARY_CHECK_ENABLED:-1}" -ne 1 ]]; then
      return
    fi
    if [[ -z "${python_cmd:-}" ]]; then
      echo "NOTE: python3/python not found; skipping ${phase} ok check"
      return
    fi
    local rc
    if "$python_cmd" - "$phase" "$summary" <<'PY'; then
import json
import sys

phase_name = sys.argv[1]
payload = sys.argv[2]

try:
    data = json.loads(payload)
except Exception as exc:
    print("NOTE: {} summary JSON parse failed: {}".format(phase_name, exc), file=sys.stderr)
    sys.exit(0)

if data.get("ok") is True:
    sys.exit(0)

print("ERROR: {} summary ok flag is {}".format(phase_name, data.get("ok")), file=sys.stderr)
sys.exit(2)
PY
      return
    fi
    rc=$?
    if [[ $rc -eq 2 ]]; then
      exit 2
    fi
  }
  seeded_phase1=0
  seeded_phase2=0
  seeded_phase3=0
  if [[ -n "${PHASE_LOG_INPUT:-}" ]]; then
    if [[ -z "${PHASE1_LOG_INPUT:-}" ]]; then
      export PHASE1_LOG_INPUT="${PHASE_LOG_INPUT}"
      seeded_phase1=1
    fi
    if [[ -z "${PHASE2_LOG_INPUT:-}" ]]; then
      export PHASE2_LOG_INPUT="${PHASE_LOG_INPUT}"
      seeded_phase2=1
    fi
    if [[ -z "${PHASE3_LOG_INPUT:-}" ]]; then
      export PHASE3_LOG_INPUT="${PHASE_LOG_INPUT}"
      seeded_phase3=1
    fi
  fi
  if [[ -z "${PHASE1_LOG_INPUT:-}" ]]; then
    echo "ERROR: RUN_PHASE_STRICT requires PHASE1_LOG_INPUT (or set PHASE_LOG_INPUT)"
    exit 1
  fi
  if [[ -z "${PHASE2_LOG_INPUT:-}" ]]; then
    echo "ERROR: RUN_PHASE_STRICT requires PHASE2_LOG_INPUT (or set PHASE_LOG_INPUT)"
    exit 1
  fi
  if [[ -z "${PHASE3_LOG_INPUT:-}" ]]; then
    echo "ERROR: RUN_PHASE_STRICT requires PHASE3_LOG_INPUT (or set PHASE_LOG_INPUT)"
    exit 1
  fi
  if [[ ! -f "${PHASE1_LOG_INPUT}" ]]; then
    echo "ERROR: PHASE1_LOG_INPUT not found: ${PHASE1_LOG_INPUT}"
    exit 1
  fi
  if [[ ! -f "${PHASE2_LOG_INPUT}" ]]; then
    echo "ERROR: PHASE2_LOG_INPUT not found: ${PHASE2_LOG_INPUT}"
    exit 1
  fi
  if [[ ! -f "${PHASE3_LOG_INPUT}" ]]; then
    echo "ERROR: PHASE3_LOG_INPUT not found: ${PHASE3_LOG_INPUT}"
    exit 1
  fi
  print_phase_strict_usage
  echo "Phase 1 strict: exit codes -> 0=ok, 2=missing markers, 3=below --min_runs"
  echo "Phase 2 strict: exit codes -> 0=ok, 2=missing markers, 3=below --min_runs"
  echo "Phase 3 strict: exit codes -> 0=ok, 2=missing markers, 3=below --min_runs"
  echo "PHASE1_LOG_INPUT=${PHASE1_LOG_INPUT}"
  if [[ $seeded_phase1 -eq 1 ]]; then
    echo "NOTE: seeded PHASE1_LOG_INPUT from PHASE_LOG_INPUT"
  fi
  set +e
  phase1_summary_json=$(dart run tools/phase1_summarize_logs.dart \
    --input "${PHASE1_LOG_INPUT}" \
    --fail_on_missing \
    --min_runs 1)
  phase1_rc=$?
  set -e
  if [[ $phase1_rc -eq 0 ]]; then
    PHASE_SUMMARY_CHECK_ENABLED=1
  else
    PHASE_SUMMARY_CHECK_ENABLED=0
  fi
  check_phase_summary_ok "PHASE1" "${phase1_summary_json}"
  if [[ $phase1_rc -eq 0 ]]; then
    run_phase1_comparator "${PHASE1_LOG_INPUT}"
    run_phase1_print_report "${PHASE1_LOG_INPUT}"
  fi
  echo "PHASE1_EXIT_CODE=${phase1_rc}"
  if [[ $phase1_rc -ne 0 ]]; then
    exit $phase1_rc
  fi
  echo "PHASE2_LOG_INPUT=${PHASE2_LOG_INPUT}"
  if [[ $seeded_phase2 -eq 1 ]]; then
    echo "NOTE: seeded PHASE2_LOG_INPUT from PHASE_LOG_INPUT"
  fi
  set +e
  phase2_summary_json=$(dart run tools/phase2_summarize_logs.dart \
    --input "${PHASE2_LOG_INPUT}" \
    --fail_on_missing \
    --min_runs 1)
  phase2_rc=$?
  set -e
  if [[ $phase2_rc -eq 0 ]]; then
    PHASE_SUMMARY_CHECK_ENABLED=1
  else
    PHASE_SUMMARY_CHECK_ENABLED=0
  fi
  check_phase_summary_ok "PHASE2" "${phase2_summary_json}"
  if [[ $phase2_rc -eq 0 ]]; then
    run_phase2_print_report "${PHASE2_LOG_INPUT}"
  fi
  echo "PHASE2_EXIT_CODE=${phase2_rc}"
  if [[ $phase2_rc -ne 0 ]]; then
    exit $phase2_rc
  fi
  echo "PHASE3_LOG_INPUT=${PHASE3_LOG_INPUT}"
  if [[ $seeded_phase3 -eq 1 ]]; then
    echo "NOTE: seeded PHASE3_LOG_INPUT from PHASE_LOG_INPUT"
  fi
  set +e
  phase3_summary_json=$(dart run tools/phase3_summarize_logs.dart \
    --input "${PHASE3_LOG_INPUT}" \
    --fail_on_missing \
    --min_runs 1)
  phase3_rc=$?
  set -e
  if [[ $phase3_rc -eq 0 ]]; then
    PHASE_SUMMARY_CHECK_ENABLED=1
  else
    PHASE_SUMMARY_CHECK_ENABLED=0
  fi
  check_phase_summary_ok "PHASE3" "${phase3_summary_json}"
  if [[ $phase3_rc -eq 0 ]]; then
    run_phase3_print_report "${PHASE3_LOG_INPUT}"
  fi
  echo "PHASE3_EXIT_CODE=${phase3_rc}"
  if [[ $phase3_rc -ne 0 ]]; then
    exit $phase3_rc
  fi
fi
if [[ "${RUN_PHASE1_STRICT:-0}" == "1" ]]; then
  check_shell_syntax_strict
  if [[ -z "${PHASE1_LOG_INPUT:-}" ]]; then
    echo "ERROR: RUN_PHASE1_STRICT requires PHASE1_LOG_INPUT"
    exit 1
  fi
  if [[ ! -f "${PHASE1_LOG_INPUT}" ]]; then
    echo "ERROR: PHASE1_LOG_INPUT not found: ${PHASE1_LOG_INPUT}"
    exit 1
  fi
  echo "Phase 1 strict: exit codes -> 0=ok, 2=missing markers, 3=below --min_runs"
  dart run tools/phase1_summarize_logs.dart \
    --input "${PHASE1_LOG_INPUT}" \
    --fail_on_missing \
    --min_runs 1
  run_phase1_comparator "${PHASE1_LOG_INPUT}"
  run_phase1_print_report "${PHASE1_LOG_INPUT}"
fi

if [[ "${RUN_PHASE_REPORTS:-0}" == "1" ]]; then
  run_phase_report_wrapper
fi

if [[ "${RUN_AUTOPILOT_REPORT:-0}" == "1" ]]; then
  run_phase_autopilot_report
fi

if [[ "${RUN_PERSONALIZATION_NEXT:-0}" == "1" ]]; then
  run_phase_personalization_next
fi

dart run tools/foundation_guard.dart
dart format --set-exit-if-changed .
dart analyze
echo "ok"
