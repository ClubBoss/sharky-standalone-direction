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

echo "[preflight] 1/1 dart format check"
if ! dart format --set-exit-if-changed .; then
  echo "[preflight] FAIL: formatter drift detected."
  echo "[preflight] Rule: submit format-only unblock commit, then rerun preflight + release gate."
  echo "[preflight] Next commands:"
  echo "  dart format ."
  echo "  git add -A"
  echo "  git commit -m \"chore: dart format (release gate unblock) v1\""
  echo "  ./tools/release_preflight_world1.sh"
  echo "  ./tools/release_gate_world1.sh"
  exit 1
fi

echo "[preflight] 2/2 ssot continuity check"
if ! ./tools/ssot_continuity_guard_v1.sh; then
  echo "[preflight] FAIL: SSOT continuity guard failed."
  echo "[preflight] Fix roadmap execution continuity before release gate."
  exit 1
fi

echo "[preflight] PASS: formatter clean + SSOT continuity clean."
echo "[preflight] Next: ./tools/release_gate_world1.sh"
