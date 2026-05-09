#!/usr/bin/env bash
set -euo pipefail

print_usage() {
  cat <<'USAGE'
Usage: bash tool/dev/phase_print_reports.sh [options]

Options:
  PHASE_LOG_INPUT=<path> [...]
  --latest               force auto-detect of latest log (overrides PHASE*_LOG_INPUT)
  --only=phase1|phase2|phase3  run only those reports (repeatable)
  --quiet                suppress resolved path echo (reports still appear)
  --help                 show this help line

Examples:
  PHASE_LOG_INPUT=/tmp/... bash tool/dev/phase_print_reports.sh
  --latest --only=phase1 --quiet
  PHASE3_LOG_INPUT=/tmp/... bash tool/dev/phase_print_reports.sh
USAGE
}

quiet_mode=0
latest_mode=0
json_only=0
only_req=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      print_usage
      exit 0
      ;;
    --latest)
      latest_mode=1
      shift
      ;;
    --quiet)
      quiet_mode=1
      shift
      ;;
    --only=*)
      value="${1#--only=}"
      if [[ "$value" =~ ^phase[123]$ ]]; then
        if [[ ! " ${only_req[*]:-} " =~ " $value " ]]; then
          only_req+=("$value")
        fi
        shift
      else
        echo "ERROR: unknown --only value: $value"
        print_usage
        exit 1
      fi
      ;;
    --json-only)
      json_only=1
      shift
      ;;
    *)
      echo "ERROR: unknown argument: $1"
      print_usage
      exit 1
      ;;
  esac
done

if [[ $latest_mode -eq 1 ]]; then
  unset PHASE1_LOG_INPUT
  unset PHASE2_LOG_INPUT
  unset PHASE3_LOG_INPUT
fi

if [[ -z "${PHASE_LOG_INPUT:-}" && -z "${PHASE1_LOG_INPUT:-}" && -z "${PHASE2_LOG_INPUT:-}" && -z "${PHASE3_LOG_INPUT:-}" ]]; then
  latest_log=$(ls -t /private/tmp/poker_analyzer_phase_logs_*.txt 2>/dev/null | head -n1)
  if [[ -n "$latest_log" ]]; then
    export PHASE_LOG_INPUT="$latest_log"
    echo "NOTE: auto-selected PHASE_LOG_INPUT=$latest_log"
  else
    echo "ERROR: no phase log inputs provided and no log found to auto-select"
    print_usage
    exit 1
  fi
fi

resolve_phase_input() {
  local var_name="$1"
  local default="$2"
  local quiet=${3:-0}
  local current="${!var_name:-}"
  if [[ -z "$current" && -n "$default" ]]; then
    export "$var_name"="$default"
    current="$default"
  fi
  if [[ -n "$current" ]]; then
    if [[ ! -f "$current" ]]; then
      echo "NOTE: $var_name not found: $current"
      unset "$var_name"
      return 1
    fi
    if [[ $quiet -eq 0 ]]; then
      echo "$var_name=$current"
    fi
    return 0
  fi
  return 1
}

main() {
  local default_log="${PHASE_LOG_INPUT:-}"
  if [[ -n "$default_log" && ! -f "$default_log" ]]; then
    echo "ERROR: PHASE_LOG_INPUT not found: $default_log"
    exit 1
  fi

  resolve_phase_input PHASE1_LOG_INPUT "$default_log" "$quiet_mode"
  resolve_phase_input PHASE2_LOG_INPUT "$default_log" "$quiet_mode"
  resolve_phase_input PHASE3_LOG_INPUT "$default_log" "$quiet_mode"

run_report() {
  local phase_label="$1"
  local script="$2"
  local log_var="$3"
  local log_path="${!log_var:-}"
  if [[ -z "$log_path" ]]; then
    return
  fi
  local script_path="$script"
  if [[ ! -f "$script_path" ]]; then
    if [[ $json_only -eq 0 ]]; then
      echo "NOTE: ${script##*/} unavailable"
    fi
    return
  fi
  local env_vars=()
  if [[ "$log_var" == "PHASE1_LOG_INPUT" ]]; then
    env_vars=("PHASE1_LOG_INPUT=$log_path")
  elif [[ "$log_var" == "PHASE2_LOG_INPUT" ]]; then
    env_vars=("PHASE2_LOG_INPUT=$log_path")
  elif [[ "$log_var" == "PHASE3_LOG_INPUT" ]]; then
    env_vars=("PHASE3_LOG_INPUT=$log_path")
  fi
  local errexit_was_on=0
  if [[ "$-" == *e* ]]; then
    errexit_was_on=1
  fi
  set +e
  local rc=0
  if [[ $json_only -eq 1 ]]; then
    local output
    if [[ ${#env_vars[@]} -gt 0 ]]; then
      output="$(env "${env_vars[@]}" "$script_path" 2>&1)"
    else
      output="$("$script_path" 2>&1)"
    fi
    rc=$?
    if [[ $rc -eq 0 ]]; then
      echo "$output" | grep "^${phase_label}_REPORT_JSON=" || true
    fi
  else
    if [[ ${#env_vars[@]} -gt 0 ]]; then
      env "${env_vars[@]}" "$script_path"
    else
      "$script_path"
    fi
    rc=$?
  fi
  if [[ $errexit_was_on -eq 1 ]]; then
    set -e
  fi
  if [[ $json_only -eq 0 && $rc -ne 0 ]]; then
    echo "NOTE: ${script##*/} unavailable"
  fi
}

should_run_phase() {
  local phase="$1"
  if [[ ${#only_req[@]} -eq 0 ]]; then
    return 0
  fi
  for entry in "${only_req[@]}"; do
    if [[ "$entry" == "$phase" ]]; then
      return 0
    fi
  done
  return 1
}

  if [[ -n "${PHASE1_LOG_INPUT:-}" ]]; then
    if should_run_phase "phase1"; then
      run_report "PHASE1" "$(pwd)/tool/dev/phase1_print_report.sh" PHASE1_LOG_INPUT
    fi
  fi
  if [[ -n "${PHASE2_LOG_INPUT:-}" ]]; then
    if should_run_phase "phase2"; then
      run_report "PHASE2" "$(pwd)/tool/dev/phase2_print_report.sh" PHASE2_LOG_INPUT
    fi
  fi
  if [[ -n "${PHASE3_LOG_INPUT:-}" ]]; then
    if should_run_phase "phase3"; then
      run_report "PHASE3" "$(pwd)/tool/dev/phase3_print_report.sh" PHASE3_LOG_INPUT
    fi
  fi
}

main
