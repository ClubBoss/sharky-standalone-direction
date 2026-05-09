#!/usr/bin/env bash
set -euo pipefail

dart format --set-exit-if-changed .
dart analyze

if command -v flutter >/dev/null 2>&1; then
  flutter test --coverage
else
  echo "skip: flutter not installed"
fi
