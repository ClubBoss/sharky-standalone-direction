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

readonly TEST_FILE="test/ui_v2/act0_shell_preview_screen_v1_test.dart"
readonly -a RUNNER_COMPACT_TESTS=(
  "Runner Theory keeps table and Continue visible on compact portrait"
  "Runner Drill keeps table and action options visible on compact portrait"
  "Compact drill stacks long 3-option answer labels when the row budget is exceeded"
  "Action prompt keeps compact question readable without truncation"
  "Runner Review keeps table and Continue visible on compact portrait"
  "Compact runner review keeps hero cluster clear of the bottom dock"
  "Blind bet chips stay clear of compact center info"
  "Compact seat-tap prompt keeps active table targets above the bottom dock"
  "Hero marker cluster stays clear of hero cards and seat label"
  "Compact refined side seats stay inset to the felt arc"
  "Compact refined side seats preserve an open center lane"
  "Compact refined top and hero clusters stay on the table axis"
  "Compact refined blind chips stay clear of blind seat cards"
)

echo "RUNNER COMPACT MINI LOOP"
echo "file: $TEST_FILE"
echo "count: ${#RUNNER_COMPACT_TESTS[@]}"

run_test() {
  local name="$1"
  echo
  echo "[runner-compact] $name"
  flutter test "$TEST_FILE" --plain-name "$name"
}

for test_name in "${RUNNER_COMPACT_TESTS[@]}"; do
  run_test "$test_name"
done

echo
echo "RUNNER COMPACT MINI LOOP PASS"
