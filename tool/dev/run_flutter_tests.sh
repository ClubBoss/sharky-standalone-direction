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

if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  echo "ERROR: Cannot locate pubspec.yaml; run_flutter_tests.sh must run from repo root or subdir."
  exit 1
fi

cd "$ROOT"
echo "Running flutter test (Tier 2)..."
flutter test
