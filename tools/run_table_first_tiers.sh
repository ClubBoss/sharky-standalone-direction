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

run_tier0() {
  local -a changed_dart_files=()

  if git rev-parse --verify HEAD^ >/dev/null 2>&1; then
    while IFS= read -r path; do
      [[ -n "${path}" && -f "${path}" ]] && changed_dart_files+=("${path}")
    done < <(git diff --name-only HEAD^ HEAD -- '*.dart')
  fi

  if [[ ${#changed_dart_files[@]} -gt 0 ]]; then
    dart format --set-exit-if-changed "${changed_dart_files[@]}"
  else
    echo "Tier 0: no changed Dart files to format"
  fi
  dart analyze
}

load_tier1_manifest() {
  local manifest_path="${TIER_COVERAGE_MANIFEST:-./tools/tier_coverage_manifest.json}"
  local manifest_lines

  if [[ ! -f "${manifest_path}" ]]; then
    echo "ERROR: Tier 1 manifest not found at ${manifest_path}"
    exit 1
  fi

  if ! manifest_lines="$(python3 - "${manifest_path}" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    manifest = json.loads(path.read_text())
except (OSError, json.JSONDecodeError) as error:
    raise SystemExit(f"ERROR: invalid Tier 1 manifest {path}: {error}")

tier1 = manifest.get("tier1")
if not isinstance(tier1, list) or not tier1:
    raise SystemExit("ERROR: Tier 1 manifest must contain a non-empty tier1 array")
if any(not isinstance(entry, str) or not entry for entry in tier1):
    raise SystemExit("ERROR: Tier 1 manifest entries must be non-empty strings")
if len(tier1) != len(set(tier1)):
    raise SystemExit("ERROR: Tier 1 manifest contains duplicate entries")

print("\n".join(tier1))
PY
)"; then
    exit 1
  fi

  tier1_manifest=()
  while IFS= read -r line; do
    [[ -n "${line}" ]] && tier1_manifest+=("${line}")
  done <<< "${manifest_lines}"

  for path in "${tier1_manifest[@]}"; do
    if [[ "${path}" != test/* || ! -f "${path}" ]]; then
      echo "ERROR: Tier 1 manifest path is not an existing test: ${path}"
      exit 1
    fi
  done
}

case "${tier}" in
  0)
    echo "Tier 0: running format + analyze"
    run_tier0
    ;;
  1)
    echo "Tier 1: running targeted flutter tests"
    load_tier1_manifest
    for path in "${tier1_manifest[@]}"; do
      run_cmd "flutter test ${path}"
    done
    ;;
  2)
    echo "Tier 2: full checkpoint suite"
    timeout="${TIER2_TIMEOUT:-300}"
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
