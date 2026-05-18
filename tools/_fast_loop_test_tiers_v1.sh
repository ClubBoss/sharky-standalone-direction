#!/usr/bin/env bash

# Tier-1 suites that run only when related paths change.
# Keep this aligned to the current Act0 canonical route rather than archived
# map/result seams.
FAST_LOOP_TIER1_UI_V2_TESTS_V1=(
  test/ui_v2/act0_shell_preview_screen_v1_test.dart
  test/ui_v2/act0_play_shell_v1_test.dart
  test/ui_v2/act0_shell_state_v1_feedback_test.dart
)

FAST_LOOP_TIER1_SERVICES_TESTS_V1=(
  test/services/outcome_summary_v1_test.dart
  test/services/campaign_spine_runner_v1_test.dart
)

fast_loop_collect_changed_files_v1() {
  local root="$1"
  (
    git -C "$root" diff --name-only HEAD
    git -C "$root" diff --name-only --cached
  ) | sed '/^$/d' | LC_ALL=C sort -u
}

fast_loop_append_unique_tests_v1() {
  local out_name="$1"
  shift
  local existing
  local candidate
  for candidate in "$@"; do
    if [[ -z "$candidate" ]]; then
      continue
    fi
    eval "existing=\" \${$out_name[*]} \""
    if [[ "$existing" == *" $candidate "* ]]; then
      continue
    fi
    eval "$out_name+=(\"\$candidate\")"
  done
}
