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

WORLD1_CONTRACT_TESTS_V1=("${WORLD1_SELECTED_TESTS_V1[@]}")

for test_file in "${WORLD1_CONTRACT_TESTS_V1[@]}"; do
  echo "checkpoint_world1_contracts_v1: run file=${test_file}"
  if ! flutter test "$test_file"; then
    echo "checkpoint_world1_contracts_v1: FAIL file=${test_file}"
    exit 1
  fi
done

echo "checkpoint_world1_contracts_v1: OK tests=${#WORLD1_CONTRACT_TESTS_V1[@]}"
