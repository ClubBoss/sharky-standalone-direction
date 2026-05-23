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

readonly TOOL_FILES=(
  tools/fast_loop_world1_v1.sh
  tools/_fast_loop_cache_v1.sh
  tools/_fast_loop_test_tiers_v1.sh
  tools/_test_policy_v1.sh
  tools/release_gate_world1.sh
  tools/release_gate_world2.sh
  tools/release_gate_world3.sh
  tools/checkpoint_world1_v1.sh
  tools/checkpoint_world1_contracts_v1.sh
  tools/checkpoint_world1_v1_capture.sh
  tools/demo_world1.sh
  tools/demo_world2.sh
  tools/demo_world3.sh
  tools/fast_loop_runner_compact_v1.sh
  tools/speed_profile_world1_v1.sh
  tools/_world1_selected_tests_v1.sh
  tools/_world2_selected_tests_v1.sh
  tools/_world3_selected_tests_v1.sh
)

echo "[lint-tools] syntax check"
for f in "${TOOL_FILES[@]}"; do
  bash -n "$f"
  echo "  - ok: $f"
done

echo "[lint-tools] executable checks"
test -x tools/release_gate_world1.sh
echo "  - ok: tools/release_gate_world1.sh"
test -x tools/release_gate_world2.sh
echo "  - ok: tools/release_gate_world2.sh"
test -x tools/release_gate_world3.sh
echo "  - ok: tools/release_gate_world3.sh"
test -x tools/checkpoint_world1_v1.sh
echo "  - ok: tools/checkpoint_world1_v1.sh"
test -x tools/checkpoint_world1_contracts_v1.sh
echo "  - ok: tools/checkpoint_world1_contracts_v1.sh"
test -x tools/checkpoint_world1_v1_capture.sh
echo "  - ok: tools/checkpoint_world1_v1_capture.sh"
test -x tools/demo_world1.sh
echo "  - ok: tools/demo_world1.sh"
test -x tools/demo_world2.sh
echo "  - ok: tools/demo_world2.sh"
test -x tools/demo_world3.sh
echo "  - ok: tools/demo_world3.sh"
test -x tools/fast_loop_runner_compact_v1.sh
echo "  - ok: tools/fast_loop_runner_compact_v1.sh"
test -x tools/speed_profile_world1_v1.sh
echo "  - ok: tools/speed_profile_world1_v1.sh"

echo "TOOLS LINT PASS"
