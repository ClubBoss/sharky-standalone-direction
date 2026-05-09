#!/usr/bin/env bash

TEST_POLICY_FULL_SUITE_V1=0
TEST_POLICY_REASON_V1="default"
TEST_POLICY_WANTS_FULL_SUITE_V1=0

test_policy_should_run_full_suite_v1() {
  local arg

  TEST_POLICY_FULL_SUITE_V1=0
  TEST_POLICY_REASON_V1="default: full-suite OFF"
  TEST_POLICY_WANTS_FULL_SUITE_V1=0

  if [[ "${CHECKPOINT:-0}" == "1" ]]; then
    TEST_POLICY_FULL_SUITE_V1=1
    TEST_POLICY_REASON_V1="env CHECKPOINT=1"
  else
    for arg in "$@"; do
      if [[ "$arg" == "--full" || "$arg" == "--checkpoint" ]]; then
        TEST_POLICY_WANTS_FULL_SUITE_V1=1
      fi
      if [[ "$arg" == "--checkpoint" ]]; then
        TEST_POLICY_FULL_SUITE_V1=1
        TEST_POLICY_REASON_V1="explicit flag: $arg"
      fi
    done
  fi

  if [[ "$TEST_POLICY_FULL_SUITE_V1" == "0" ]]; then
    local head_subject
    head_subject="$(git log -1 --pretty=%s 2>/dev/null || true)"
    if [[ "$head_subject" == *"[checkpoint]"* ]]; then
      TEST_POLICY_FULL_SUITE_V1=1
      TEST_POLICY_REASON_V1="HEAD subject contains [checkpoint]"
    fi
  fi
}

test_policy_require_full_suite_enabled_v1() {
  if [[ "$TEST_POLICY_WANTS_FULL_SUITE_V1" == "1" && "$TEST_POLICY_FULL_SUITE_V1" != "1" ]]; then
    echo "ERROR: full-suite is policy-locked and currently OFF ($TEST_POLICY_REASON_V1)." >&2
    echo "Use CHECKPOINT=1 or --checkpoint or [checkpoint] in commit subject." >&2
    return 2
  fi
}
