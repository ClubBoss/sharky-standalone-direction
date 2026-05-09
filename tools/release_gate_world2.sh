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

source "$ROOT/tools/_world2_selected_tests_v1.sh"
source "$ROOT/tools/_test_policy_v1.sh"

test_policy_should_run_full_suite_v1 "$@"
test_policy_require_full_suite_enabled_v1

echo "[gate-world2] Policy: full-suite $([[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]] && echo "ON" || echo "OFF") ($TEST_POLICY_REASON_V1)"

echo "[gate-world2] 1/4 lint tools"
./tools/lint_tools_v1.sh

echo "[gate-world2] 2/4 dart analyze"
dart analyze

echo "[gate-world2] 3/4 selected tests"
echo "[gate-world2] Selected tests:"
for t in "${WORLD2_SELECTED_TESTS_V1[@]}"; do
  echo "  - $t"
done
flutter test -r expanded "${WORLD2_SELECTED_TESTS_V1[@]}"

if [[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]]; then
  echo "[gate-world2] 4/4 checkpoint full-suite"
  flutter test -r expanded
fi

echo "[gate-world2] World2 release gate passed."
