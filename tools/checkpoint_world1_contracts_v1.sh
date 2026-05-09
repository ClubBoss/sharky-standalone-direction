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

WORLD1_CONTRACT_TESTS_V1=(
  test/guards/world1_readiness_smoke_contract_test.dart
  test/guards/world1_campaign_telemetry_contract_test.dart
  test/guards/world_campaign_routing_matrix_contract_test.dart
  test/guards/world_campaign_map_home_contract_test.dart
  test/guards/world1_foundations_microtask_contract_test.dart
  test/ui_v2/world1_map_node_states_contract_test.dart
  test/guards/campaign_pack_registry_invariants_test.dart
  test/guards/campaign_followup_pack_registry_invariants_test.dart
)

for test_file in "${WORLD1_CONTRACT_TESTS_V1[@]}"; do
  echo "checkpoint_world1_contracts_v1: run file=${test_file}"
  if ! flutter test "$test_file"; then
    echo "checkpoint_world1_contracts_v1: FAIL file=${test_file}"
    exit 1
  fi
done

echo "checkpoint_world1_contracts_v1: OK tests=${#WORLD1_CONTRACT_TESTS_V1[@]}"
