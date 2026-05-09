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

echo "[checkpoint] CHECKPOINT MODE: lint -> analyze -> tier tests -> full-suite"
if [[ "${CAPTURE:-0}" == "1" ]]; then
  ./tools/checkpoint_world1_v1_capture.sh "$@"
else
  CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint "$@"
fi
