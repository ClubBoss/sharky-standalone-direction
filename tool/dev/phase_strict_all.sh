#!/usr/bin/env bash
set -euo pipefail

print_help() {
  cat <<'USAGE'
Usage: bash tool/dev/phase_strict_all.sh [--help] [--smoke] [--dry-run]

This helper resolves Phase logs and runs strict validation, per-phase reports,
and the consolidated autopilot report.

Options:
  --help    show this usage.
  --smoke   auto-select the latest per-phase logs and emit phase_autopilot_report_v1.
  --dry-run show the resolved commands but do not execute them.

Examples:
  bash tool/dev/phase_strict_all.sh
  PHASE_LOG_INPUT=/private/tmp/poker_analyzer_phase_logs_20260103T150311Z.txt \
    bash tool/dev/phase_strict_all.sh
  bash tool/dev/phase_strict_all.sh --smoke --dry-run
USAGE
}

find_latest_log() {
  local pattern="$1"
  ls -t $pattern 2>/dev/null | head -n1 || true
}

find_latest_phase_log() {
  local marker="$1"
  local fallback="$2"
  local log
  while IFS= read -r log; do
    [[ -z "$log" ]] && continue
    if [[ ! -f "$log" ]]; then
      continue
    fi
    if grep -Fq "$marker" "$log"; then
      printf '%s\n' "$log"
      return 0
    fi
    if [[ -n "$fallback" ]] && grep -Fq "$fallback" "$log"; then
      printf '%s\n' "$log"
      return 0
    fi
  done < <(ls -t /private/tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null || true)
  return 1
}

format_command() {
  local -a env_ref=("${!1}")
  local cmd="env"
  for token in "${env_ref[@]}"; do
    cmd+=" $token"
  done
  cmd+=" bash tool/dev/precommit_sanity.sh"
  printf '%s' "$cmd"
}

smoke_mode=0
dry_run=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      print_help
      exit 0
      ;;
    --smoke)
      smoke_mode=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    *)
      echo "ERROR: unknown argument: $1"
      print_help
      exit 1
      ;;
  esac
done

latest_pattern="/private/tmp/poker_analyzer_phase_logs_*.txt"
resolved_log="${PHASE_LOG_INPUT:-}"
phase1_log="${PHASE1_LOG_INPUT:-}"
phase2_log="${PHASE2_LOG_INPUT:-}"
phase3_log="${PHASE3_LOG_INPUT:-}"

if [[ $smoke_mode -eq 0 ]]; then
  if [[ -z "${resolved_log}" ]]; then
    resolved_log=$(find_latest_log "$latest_pattern")
  fi
  if [[ -z "$phase1_log" ]]; then
    phase1_log="$resolved_log"
  fi
  if [[ -z "$phase2_log" ]]; then
    phase2_log="$resolved_log"
  fi
  if [[ -z "$phase3_log" ]]; then
    phase3_log="$resolved_log"
  fi
else
  phase1_log="${phase1_log:-$(find_latest_phase_log 'PHASE1_FLOW_END' '')}"
  phase2_log="${phase2_log:-$(find_latest_phase_log 'PHASE2_FLOW_END' 'PHASE2_LOG_SUMMARY')}"
  phase3_log="${phase3_log:-$(find_latest_phase_log 'PHASE3_FLOW_END' 'PHASE3_RETURN_SIGNAL')}"
  resolved_log=""
fi

if [[ $smoke_mode -eq 0 && -z "${resolved_log}" ]]; then
  echo "ERROR: no log provided and no log found matching $latest_pattern"
  print_help
  exit 1
fi

printf 'PHASE1_LOG_INPUT=%s\n' "${phase1_log:-}"
printf 'PHASE2_LOG_INPUT=%s\n' "${phase2_log:-}"
printf 'PHASE3_LOG_INPUT=%s\n' "${phase3_log:-}"
if [[ -n "$resolved_log" ]]; then
  printf 'PHASE_LOG_INPUT=%s\n' "$resolved_log"
fi

strict_env=(RUN_PHASE_STRICT=1)
report_env=(RUN_PHASE_REPORTS=1)
autop_env=(RUN_AUTOPILOT_REPORT=1)
if [[ -n "$phase1_log" ]]; then
  strict_env+=(PHASE1_LOG_INPUT="$phase1_log")
  report_env+=(PHASE1_LOG_INPUT="$phase1_log")
  autop_env+=(PHASE1_LOG_INPUT="$phase1_log")
fi
if [[ -n "$phase2_log" ]]; then
  strict_env+=(PHASE2_LOG_INPUT="$phase2_log")
  report_env+=(PHASE2_LOG_INPUT="$phase2_log")
  autop_env+=(PHASE2_LOG_INPUT="$phase2_log")
fi
if [[ -n "$phase3_log" ]]; then
  strict_env+=(PHASE3_LOG_INPUT="$phase3_log")
  report_env+=(PHASE3_LOG_INPUT="$phase3_log")
  autop_env+=(PHASE3_LOG_INPUT="$phase3_log")
fi
if [[ -n "$resolved_log" ]]; then
  strict_env+=(PHASE_LOG_INPUT="$resolved_log")
  report_env+=(PHASE_LOG_INPUT="$resolved_log")
  autop_env+=(PHASE_LOG_INPUT="$resolved_log")
fi

strict_cmd=$(format_command strict_env[@])
report_cmd=$(format_command report_env[@])
autop_cmd=$(format_command autop_env[@])

if [[ $dry_run -eq 1 ]]; then
  echo "strict command: $strict_cmd"
  echo "phase reports command: $report_cmd"
  echo "autopilot command: $autop_cmd"
  exit 0
fi

set +e
env "${strict_env[@]}" bash tool/dev/precommit_sanity.sh
strict_rc=$?
set -e

run_best_effort() {
  local env_name="$1"
  local label="$2"
  local -a env_vars=()
  eval "env_vars=(\"\${${env_name}[@]}\")"
  set +e
  env "${env_vars[@]}" bash tool/dev/precommit_sanity.sh
  local rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo "NOTE: ${label} failed (exit=$rc)"
  fi
}

run_best_effort report_env "phase reports"
run_best_effort autop_env "phase_autopilot_report"

if [[ $smoke_mode -eq 1 ]]; then
  set +e
  env "${autop_env[@]}" bash tool/dev/phase_personalization_next.sh
  personalization_rc=$?
  set -e
  if [[ $personalization_rc -ne 0 ]]; then
    echo "NOTE: phase_personalization_next.sh failed (exit=$personalization_rc)"
  fi
fi

exit $strict_rc
