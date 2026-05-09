#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 <tier> [--update-goldens]"
  echo "  tier 0 => dart format --set-exit-if-changed . && dart analyze"
  echo "  tier 1 => targeted flutter tests (includes SSOT guard)"
  echo "  tier 2 => full checkpoint suite (dart format/analyze + flutter suites + content validation)"
  echo "             add --update-goldens to refresh the lesson overlay golden before Tier 2"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

tier="$1"
shift
opt="${1:-}"

manifest_path="./tools/tier_coverage_manifest.json"
if [[ ! -f "${manifest_path}" ]]; then
  echo "ERROR: manifest not found at ${manifest_path}"
  exit 1
fi

tier1_manifest=()
MANIFEST_PATH="${manifest_path}"
export MANIFEST_PATH
while IFS= read -r line; do
  tier1_manifest+=("${line}")
done < <(python3 - <<'PY'
import json
import os
from pathlib import Path

manifest = json.loads(Path(os.environ["MANIFEST_PATH"]).read_text())
for entry in manifest.get("tier1", []):
    print(entry)
PY
)

run_cmd() {
  local cmd="$1"
  echo "RUNNING: ${cmd}"
  echo "CMD: ${cmd}"
  eval "${cmd}"
}

run_cmd_tier2() {
  local cmd="$1"
  local timeout="${TIER2_TIMEOUT:-300}"
  echo "RUNNING: ${cmd}"
  echo "CMD: ${cmd}"
  perl -e 'alarm shift; exec @ARGV' "${timeout}" bash -c -- "${cmd}"
}

case "${tier}" in
  0)
    echo "Tier 0: running format + analyze"
    run_cmd "dart format --set-exit-if-changed ."
    run_cmd "dart analyze"
    ;;
  1)
    echo "Tier 1: running targeted flutter tests"
    tier1_tests=("${tier1_manifest[@]}")
    echo "Validating required tests are listed..."
    for required in "${tier1_manifest[@]}"; do
      found=false
      for candidate in "${tier1_tests[@]}"; do
        if [[ "${candidate}" == "${required}" ]]; then
          found=true
          break
        fi
      done
      if ! $found; then
        echo "ERROR: Missing required Tier 1 test: ${required}"
        exit 1
      fi
    done
    for path in "${tier1_tests[@]}"; do
      run_cmd "flutter test ${path}"
    done
    ;;
  2)
    echo "Tier 2: full checkpoint suite"
    local timeout="${TIER2_TIMEOUT:-300}"
    echo "Tier 2 timeout: ${timeout}s (TIER2_TIMEOUT env override)"
    if [[ -n "${opt}" ]]; then
      if [[ "${opt}" == "--update-goldens" ]]; then
        run_cmd_tier2 "flutter test --update-goldens test/ui_state_golden_test.dart"
      else
        echo "Unknown option for tier 2: ${opt}"
        usage
        exit 1
      fi
    fi
    cmds=(
      "dart format --set-exit-if-changed ."
      "dart analyze"
      "./run_flutter_tests.sh"
      "flutter test"
      "dart run tools/validate_training_content.dart --ci"
    )
    for cmd in "${cmds[@]}"; do
      run_cmd_tier2 "${cmd}"
    done
    ;;
  *)
    usage
    exit 1
    ;;
esac
