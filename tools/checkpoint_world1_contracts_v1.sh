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
  test/ui_v2/act0_shell_preview_screen_v1_test.dart
  test/ui_v2/act0_play_shell_v1_test.dart
  test/ui_v2/act0_en_alpha_residue_guard_test.dart
  test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart
  test/guards/campaign_pack_registry_invariants_test.dart
  test/guards/campaign_followup_pack_registry_invariants_test.dart
  test/ui_v2/act0_shell_state_v1_feedback_test.dart
)

for test_file in "${WORLD1_CONTRACT_TESTS_V1[@]}"; do
  echo "checkpoint_world1_contracts_v1: run file=${test_file}"
  if ! flutter test "$test_file"; then
    echo "checkpoint_world1_contracts_v1: FAIL file=${test_file}"
    exit 1
  fi
done

echo "checkpoint_world1_contracts_v1: OK tests=${#WORLD1_CONTRACT_TESTS_V1[@]}"
