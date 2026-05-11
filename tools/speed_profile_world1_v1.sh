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
source "$ROOT/tools/_test_policy_v1.sh"
test_policy_should_run_full_suite_v1 "$@"
test_policy_require_full_suite_enabled_v1

no_cache_s=0
cached_s=0
full_s=0

run_timed() {
  local label="$1"
  shift
  local start end elapsed
  start=$(date +%s)
  "$@"
  end=$(date +%s)
  elapsed=$((end - start))
  echo "[speed] ${label}: ${elapsed}s"
  printf -v "$label" "%s" "$elapsed"
}

echo "[speed] 1/2 fast_loop no-cache"
mkdir -p .dart_tool
printf 'force-no-cache-key' > .dart_tool/fast_loop_world1_v1.cache
run_timed no_cache_s ./tools/fast_loop_world1_v1.sh --force-tests

echo "[speed] 2/2 fast_loop cached"
run_timed cached_s ./tools/fast_loop_world1_v1.sh --force-tests

if [[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]]; then
  echo "[speed] 3/3 flutter full-suite (checkpoint mode)"
  run_timed full_s flutter test -r expanded
fi

echo
echo "SPEED SNAPSHOT"
echo "- fast_loop_no_cache: ${no_cache_s}s"
echo "- fast_loop_cached: ${cached_s}s"
if [[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]]; then
  echo "- full_suite: ${full_s}s"
else
  echo "- full_suite: skipped (policy OFF: $TEST_POLICY_REASON_V1)"
fi
