#!/usr/bin/env bash
set -euo pipefail

# PHP-4 positive authority entrypoint.  Tier C/D are validated by the manifest
# contract but never executed as learner-facing authority tests.
ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" && ! -f "$ROOT/pubspec.yaml" ]]; do ROOT="$(dirname "$ROOT")"; done
fi
cd "$ROOT"

if [[ "${1:-}" == "--tier-b-proof" ]]; then
  echo "canonical test authority: disposable positive Tier-B proof"
  ./tools/test_authority_validate_v1.sh
  ./tools/test_authority_tier_b_v1.sh
  exit 0
fi

echo "canonical test authority: structural manifest validation"
./tools/test_authority_validate_v1.sh
python3 tools/test_authority/validate_manifest_v1_fixtures_test.py
python3 tools/test_authority/run_lane_diagnostics_fixtures_test.py
# Guard event scope, single nested execution and interrupted legacy-run truth.
python3 tools/test_authority/changeset_base_fixtures_test.py
python3 tools/test_authority/changeset_context_fixtures_test.py
python3 tools/test_authority/process_orchestration_fixtures_test.py
python3 tools/test_authority/release_gate_full_suite_completion_fixtures_test.py

echo "canonical test authority: positive Tier A"
./tools/test_authority_tier_a_v1.sh
echo "canonical test authority: positive terminal Tier B"
./tools/test_authority_tier_b_v1.sh
echo "canonical test authority: PASS (Tier A + terminal Tier B)"
