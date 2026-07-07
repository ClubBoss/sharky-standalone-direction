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

status=0

./tools/test_authority_validate_v1.sh || status=1
./tools/test_authority_tier_a_v1.sh "$@" || status=1
./tools/test_authority_tier_b_v1.sh "$@" || status=1
./tools/test_authority_tier_c_v1.sh "$@" || true
./tools/test_authority_tier_d_v1.sh "$@" || status=1

exit "$status"
