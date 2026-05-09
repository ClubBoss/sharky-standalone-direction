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

source "$ROOT/tools/_world7_selected_tests_v1.sh"

echo "[demo-world7] Plan: targeted confidence tests (single pass)"
echo "[demo-world7] Selected tests:"
for t in "${WORLD7_SELECTED_TESTS_V1[@]}"; do
  echo "  - $t"
done

demo_tests_env="$(printf '%s\n' "${WORLD7_SELECTED_TESTS_V1[@]}")"
FAST_LOOP_SELECTED_TESTS_V1="$demo_tests_env" ./tools/fast_loop_world1_v1.sh --no-analyze --force-tests

echo "[demo-world7] PASS"
