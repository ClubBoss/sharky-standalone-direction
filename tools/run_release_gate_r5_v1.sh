#!/usr/bin/env bash
set -u

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

quick_mode=0
for arg in "$@"; do
  case "$arg" in
    --quick)
      quick_mode=1
      ;;
    -h|--help)
      echo "usage: ./tools/run_release_gate_r5_v1.sh [--quick]"
      echo "  --quick   Skip targeted flutter test step"
      exit 0
      ;;
    *)
      echo "run_release_gate_r5_v1: unknown arg '$arg'" >&2
      echo "usage: ./tools/run_release_gate_r5_v1.sh [--quick]" >&2
      exit 64
      ;;
  esac
done

step_index=0
steps_total=4
if [[ "$quick_mode" == "1" ]]; then
  steps_total=3
fi

print_step() {
  step_index=$((step_index + 1))
  echo "[r5-gate] ${step_index}/${steps_total} $1"
}

run_step() {
  local label="$1"
  shift
  print_step "$label"
  "$@"
  local rc=$?
  if [[ "$rc" -ne 0 ]]; then
    echo "[r5-gate] FAIL $label exit=$rc"
    exit "$rc"
  fi
  echo "[r5-gate] OK $label"
}

run_step "flutter analyze" flutter analyze
run_step "fast loop" ./tools/fast_loop_world1_v1.sh
run_step "r2 content qa" dart run tools/run_content_qa_r2_v1.dart

if [[ "$quick_mode" == "0" ]]; then
  critical_tests=(
    "test/guards/world_campaign_map_home_contract_test.dart"
    "test/guards/world_campaign_routing_matrix_contract_test.dart"
  )

  # Monetization-critical tests are included when present.
  if [[ -f "test/payments/payment_service_restore_verification_policy_v1_test.dart" ]]; then
    critical_tests+=("test/payments/payment_service_restore_verification_policy_v1_test.dart")
  fi
  if [[ -f "test/services/energy_service_entitlement_ssot_test.dart" ]]; then
    critical_tests+=("test/services/energy_service_entitlement_ssot_test.dart")
  fi

  run_step "critical contract tests" flutter test "${critical_tests[@]}"
else
  echo "[r5-gate] skipped critical contract tests (--quick)"
fi

echo "[r5-gate] PASS"
exit 0
