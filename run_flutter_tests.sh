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

if [[ -x tool/dev/run_flutter_tests.sh ]]; then
  exec tool/dev/run_flutter_tests.sh
elif [[ -x tool/run_flutter_tests.sh ]]; then
  exec tool/run_flutter_tests.sh
else
  echo "Running flutter test (Tier 2)..."
  flutter test
fi
