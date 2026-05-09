#!/usr/bin/env bash
set -euo pipefail

stdout_clean="${PUBLIC_DEMO_SEEDED:-0}"
log_step() {
  local msg="$1"
  if [[ "$stdout_clean" == "1" ]]; then
    >&2 echo "==> $msg"
  else
    echo "==> $msg"
  fi
}
run_step() {
  local label="$1"
  shift
  log_step "$label"
  if [[ "$stdout_clean" == "1" ]]; then
    "$@" 1>&2
  else
    "$@"
  fi
}

run_step "dart format" dart format --set-exit-if-changed .
run_step "dart analyze" dart analyze
run_step "dart test" dart test
run_step "personalization demo ready" bash tool/dev/personalization_demo_ready.sh

if [[ "$stdout_clean" == "1" ]]; then
  >&2 echo "PUBLIC DEMO GATE PASSED"
else
  echo "PUBLIC DEMO GATE PASSED"
fi
