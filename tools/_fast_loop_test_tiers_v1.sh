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

fast_loop_read_changeset_v1() {
  local root="$1"
  local result
  result="$(python3 "$root/tools/collect_changeset_v1.py" "$root" --with-scope)" || return $?
  local header="${result%%$'\n'*}"
  case "$header" in
    SCOPE:bounded) SHARKY_CHANGE_SCOPE_V1=bounded ;;
    SCOPE:full-scope) SHARKY_CHANGE_SCOPE_V1=full-scope ;;
    *) echo "CHANGESET_UNKNOWN: invalid scope protocol" >&2; return 75 ;;
  esac
  SHARKY_CHANGED_FILES_V1=""
  if [[ "$result" == *$'\n'* ]]; then
    SHARKY_CHANGED_FILES_V1="${result#*$'\n'}"
  fi
}

fast_loop_collect_changed_files_v1() {
  local root="$1"
  python3 "$root/tools/collect_changeset_v1.py" "$root"
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
