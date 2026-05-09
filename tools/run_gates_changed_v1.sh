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

declare -a changed_files=()
declare -a executed_commands=()

change_source="origin/main...HEAD"

collect_changed_files() {
  local output
  if output="$(git diff --name-only origin/main...HEAD 2>/dev/null)"; then
    change_source="origin/main...HEAD"
    if [[ -n "$output" ]]; then
      mapfile -t changed_files <<< "$output"
    fi
    return 0
  fi

  output="$(git diff --name-only HEAD~1...HEAD 2>/dev/null || true)"
  change_source="HEAD~1...HEAD (fallback)"
  if [[ -n "$output" ]]; then
    mapfile -t changed_files <<< "$output"
  fi
}

has_change_in_prefix() {
  local prefix="$1"
  local file
  for file in "${changed_files[@]}"; do
    if [[ "$file" == "$prefix"* ]]; then
      return 0
    fi
  done
  return 1
}

has_exact_change() {
  local path="$1"
  local file
  for file in "${changed_files[@]}"; do
    if [[ "$file" == "$path" ]]; then
      return 0
    fi
  done
  return 1
}

run_cmd() {
  local cmd="$1"
  executed_commands+=("$cmd")
  echo "[run] $cmd"
  eval "$cmd"
}

collect_changed_files

has_content_changes=false
has_tools_changes=false
has_lib_changes=false
has_test_changes=false
has_theory_index_changes=false
has_screenshot_tool_change=false

if has_change_in_prefix "content/"; then
  has_content_changes=true
fi
if has_change_in_prefix "tools/"; then
  has_tools_changes=true
fi
if has_change_in_prefix "lib/"; then
  has_lib_changes=true
fi
if has_change_in_prefix "test/"; then
  has_test_changes=true
fi
if has_exact_change "assets/theory_index.json"; then
  has_theory_index_changes=true
fi
if has_exact_change "tools/modern_table_screenshot_v1.dart"; then
  has_screenshot_tool_change=true
fi

run_screenshot=false
if [[ "$has_screenshot_tool_change" == "true" || "$has_theory_index_changes" == "true" ]]; then
  run_screenshot=true
fi

status="PASS"
failure_message=""

trap 'if [[ "$status" != "PASS" ]]; then print_summary; fi' EXIT

print_summary() {
  echo ""
  echo "=== Diff-Aware Gate Summary v1 ==="
  echo "Change source: $change_source"
  echo "Changed files count: ${#changed_files[@]}"
  echo "Detected categories:"
  echo "- content/: $has_content_changes"
  echo "- tools/: $has_tools_changes"
  echo "- lib/: $has_lib_changes"
  echo "- test/: $has_test_changes"
  echo "- assets/theory_index.json: $has_theory_index_changes"
  echo "- tools/modern_table_screenshot_v1.dart: $has_screenshot_tool_change"
  if ((${#changed_files[@]} > 0)); then
    echo "Changed files:"
    printf '  - %s\n' "${changed_files[@]}"
  else
    echo "Changed files: none"
  fi
  echo "Commands executed:"
  if ((${#executed_commands[@]} > 0)); then
    printf '  - %s\n' "${executed_commands[@]}"
  else
    echo "  - none"
  fi
  echo "Result: $status"
  if [[ -n "$failure_message" ]]; then
    echo "Failure: $failure_message"
  fi
}

{
  run_cmd "flutter analyze"

  if [[ "$has_content_changes" == "true" ]]; then
    run_cmd "dart run tools/validate_training_content.dart"
    run_cmd "flutter test test/tools/content_quality_validator_v1_test.dart"
  fi

  if [[ "$has_tools_changes" == "true" ]]; then
    run_cmd "flutter test test/tools/content_quality_validator_v1_test.dart"
  fi

  if [[ "$run_screenshot" == "true" ]]; then
    run_cmd "dart run tools/modern_table_screenshot_v1.dart"
  fi

  if [[ "$has_lib_changes" == "true" || "$has_test_changes" == "true" ]]; then
    run_cmd "./tools/fast_loop_world1_v1.sh"
  fi
} || {
  status="FAIL"
  failure_message="A gate command failed."
  exit 1
}

print_summary
