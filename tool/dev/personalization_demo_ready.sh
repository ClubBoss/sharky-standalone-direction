#!/usr/bin/env bash
set -uo pipefail

run_step() {
  local label="$1"
  shift
  echo "==> ${label}"
  set +e
  "$@"
  local code=$?
  set -e
  if [ "$code" -ne 0 ]; then
    exit "$code"
  fi
}

run_step "personalization_smoke" bash tool/dev/personalization_smoke.sh
run_step "personalization_phase1_smoke" bash tool/dev/personalization_phase1_smoke.sh
echo "OK: personalization demo ready"
