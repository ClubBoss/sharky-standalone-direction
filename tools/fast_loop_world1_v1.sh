#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"

source "$ROOT/tools/_world1_selected_tests_v1.sh"
source "$ROOT/tools/_fast_loop_cache_v1.sh"
source "$ROOT/tools/_fast_loop_test_tiers_v1.sh"
source "$ROOT/tools/_test_policy_v1.sh"

readonly -a WORLD1_CONTRACTS_HIGH_RISK_PATHS_V1=(
  "lib/ui_v2/"
  "lib/services/today_router_v1.dart"
  "lib/campaign/"
)
readonly WORLD1_CONTRACTS_HIGH_RISK_REGEX_V1='^(lib/ui_v2/|lib/services/today_router_v1\.dart|lib/campaign/)'

should_run_world1_contracts_checkpoint_v1() {
  local changed_files="$1"
  [[ -n "$changed_files" ]] && echo "$changed_files" | rg -q "$WORLD1_CONTRACTS_HIGH_RISK_REGEX_V1"
}

selected_tests=("${WORLD1_SELECTED_TESTS_V1[@]}")
if [[ -n "${FAST_LOOP_SELECTED_TESTS_V1:-}" ]]; then
  selected_tests=()
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      selected_tests+=("$line")
    fi
  done <<< "$FAST_LOOP_SELECTED_TESTS_V1"
fi

run_analyze=true
run_tests=true
run_full=false
force=false
force_tests=false
force_world1_contracts=false
print_plan=false
run_content_validation=false
run_reason="default tier-0 selected guard list"
tier_label="Tier0"
policy_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --full)
      run_full=true
      policy_args+=("$1")
      ;;
    --checkpoint)
      run_full=true
      policy_args+=("$1")
      ;;
    --no-analyze)
      run_analyze=false
      ;;
    --no-tests)
      run_tests=false
      run_full=false
      ;;
    --force)
      force=true
      ;;
    --force-tests)
      force_tests=true
      ;;
    --force-world1-contracts)
      force_world1_contracts=true
      ;;
    --print-plan)
      print_plan=true
      ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: ./tools/fast_loop_world1_v1.sh [--full] [--checkpoint] [--no-analyze] [--no-tests] [--force] [--force-tests] [--force-world1-contracts] [--print-plan]"
      exit 2
      ;;
  esac
  shift
done

if [[ ${#policy_args[@]} -gt 0 ]]; then
  test_policy_should_run_full_suite_v1 "${policy_args[@]}"
else
  test_policy_should_run_full_suite_v1
fi
test_policy_require_full_suite_enabled_v1

if [[ "${FAST_LOOP_ALREADY_RAN:-0}" == "1" && "$force" == "false" ]]; then
  echo "Plan:"
  echo "- lint_tools: skipped (nested invocation guard)"
  echo "- dart_analyze: skipped (nested invocation guard)"
  echo "- selected_world1_tests: skipped (nested invocation guard)"
  echo "- full_flutter_test: skipped (nested invocation guard)"
  echo "- Tier: skipped"
  echo "- Reason: NOOP: FAST_LOOP_ALREADY_RAN=1"
  exit 0
fi
export FAST_LOOP_ALREADY_RAN=1

cache_key="$(fast_loop_compute_cache_key_v1 "$ROOT")"
cache_hit=false
if fast_loop_cache_matches_v1 "$cache_key"; then
  cache_hit=true
fi

analyze_status="enabled"
if [[ "$run_analyze" == "true" && "$cache_hit" == "true" && "$force" == "false" ]]; then
  run_analyze=false
  analyze_status="skipped (cache hit; use --force to override)"
elif [[ "$run_analyze" == "false" ]]; then
  analyze_status="skipped (--no-analyze)"
fi

tests_status="enabled"
if [[ "$run_tests" == "false" ]]; then
  tests_status="skipped (--no-tests)"
fi

content_validation_status="disabled"

if [[ "$run_tests" == "true" && "$run_full" == "true" ]]; then
  tests_status="skipped (covered by --full)"
  run_reason="tier-2 full suite requested"
  tier_label="Tier2"
elif [[ "$run_tests" == "true" && "$run_full" == "false" && "$force_tests" == "false" ]]; then
  changed_files="$(fast_loop_collect_changed_files_v1 "$ROOT")"
  if [[ -n "$changed_files" ]] && echo "$changed_files" | rg -q '^content/'; then
    run_content_validation=true
    content_validation_status="enabled"
  else
    content_validation_status="skipped (content unchanged)"
  fi
  if [[ -z "$changed_files" ]]; then
    run_tests=false
    tests_status="skipped (no changed files)"
    run_reason="NOOP: no relevant changes"
  elif ! echo "$changed_files" | rg -q '^(lib/|test/|pubspec\.yaml|pubspec\.lock)'; then
    run_tests=false
    tests_status="skipped (changes outside lib/test/pubspec)"
    run_reason="NOOP: no relevant changes"
  else
    if echo "$changed_files" | rg -q '^(lib/ui_v2/|test/ui_v2/)'; then
      fast_loop_append_unique_tests_v1 selected_tests "${FAST_LOOP_TIER1_UI_V2_TESTS_V1[@]}"
      run_reason="tier-0 + tier-1(ui_v2) by changed files"
      tier_label="Tier0+Tier1(ui_v2)"
    fi
    if echo "$changed_files" | rg -q '^(lib/services/|test/services/)'; then
      fast_loop_append_unique_tests_v1 selected_tests "${FAST_LOOP_TIER1_SERVICES_TESTS_V1[@]}"
      run_reason="tier-0 + tier-1(services) by changed files"
      tier_label="Tier0+Tier1(services)"
    fi
  fi
elif [[ "$force_tests" == "true" ]]; then
  run_reason="forced tests (--force-tests)"
  tier_label="Tier0 (forced)"
fi

full_status="disabled"
if [[ "$run_full" == "true" && "$run_tests" == "true" ]]; then
  full_status="enabled"
fi

run_world1_contracts_checkpoint=false
world1_contracts_reason="no matching changes"
if [[ "$force_world1_contracts" == "true" ]]; then
  run_world1_contracts_checkpoint=true
  world1_contracts_reason="force flag"
elif [[ "$run_tests" == "true" && "$force_tests" == "false" ]]; then
  changed_files_for_checkpoint="$(fast_loop_collect_changed_files_v1 "$ROOT")"
  if should_run_world1_contracts_checkpoint_v1 "$changed_files_for_checkpoint"; then
    run_world1_contracts_checkpoint=true
    world1_contracts_reason="changed files match high-risk paths"
  fi
fi

# Option A semantics: true only when this invocation runs lint/analyze only and
# schedules no Flutter tests (neither selected/full fast-loop tests nor the
# world1 contracts checkpoint).
tier0_only=false
if [[ "$run_tests" == "false" && "$run_world1_contracts_checkpoint" == "false" ]]; then
  tier0_only=true
fi

echo "Plan:"
echo "- lint_tools: enabled"
echo "- dart_analyze: $analyze_status"
echo "- selected_world1_tests: $tests_status"
echo "- full_flutter_test: $full_status"
echo "- world1_contracts_checkpoint: $([[ "$run_world1_contracts_checkpoint" == "true" ]] && echo "enabled" || echo "disabled")"
echo "- content_validation: $content_validation_status"
echo "- selected_count: ${#selected_tests[@]}"
echo "- Tier: $tier_label"
echo "- Reason: $run_reason"
echo "- Policy: full-suite $([[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]] && echo "ON" || echo "OFF") ($TEST_POLICY_REASON_V1)"

if [[ "$print_plan" == "true" ]]; then
  echo "world1_contracts_checkpoint: $([[ "$run_world1_contracts_checkpoint" == "true" ]] && echo "enabled" || echo "disabled")"
  echo "reason: $world1_contracts_reason"
  echo "tier0_only: $tier0_only"
  if [[ "$tier0_only" == "true" && "$run_world1_contracts_checkpoint" == "true" ]]; then
    echo "FAIL: tier0_only=true is inconsistent with world1_contracts_checkpoint=enabled"
    exit 2
  fi
fi

./tools/lint_tools_v1.sh

if [[ "$run_analyze" == "true" ]]; then
  dart analyze
fi

if [[ "$run_content_validation" == "true" ]]; then
  dart run tools/validate_training_content.dart --staged-only
fi

if [[ "$run_tests" == "true" && "$run_full" == "false" ]]; then
  echo "[fast-loop] Selected tests:"
  for t in "${selected_tests[@]}"; do
    echo "  - $t"
  done
  flutter test -r expanded "${selected_tests[@]}"
fi

if [[ "$run_tests" == "true" && "$run_full" == "true" ]]; then
  flutter test -r expanded
fi

if [[ "$run_world1_contracts_checkpoint" == "true" ]]; then
  bash tools/checkpoint_world1_contracts_v1.sh
fi

fast_loop_write_cache_v1 "$cache_key"
echo "FAST LOOP PASS"
