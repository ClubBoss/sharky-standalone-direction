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

# The positive checkpoint uses the existing canonical Test Authority
# Tier A + terminal Tier B, not the historic unpartitioned global test suite.
# Historical tests remain accessible through an explicit diagnostic command.
#
# Preserve explicit legacy FULL requests exactly: CAPTURE, CHECKPOINT=1
# and --checkpoint/--full never silently narrow to the canonical lane.
if [[ "${CAPTURE:-0}" == "1" ]]; then
  echo "[checkpoint] CAPTURE legacy full-suite diagnostic (not canonical PASS)"
  exec ./tools/checkpoint_world1_v1_capture.sh "$@"
fi

if [[ "${CHECKPOINT:-0}" == "1" || "${1:-}" == "--checkpoint" || "${1:-}" == "--full" || "${1:-}" == "--legacy-global" ]]; then
  case "${1:-}" in
    ""|--checkpoint|--full|--legacy-global) ;;
    *) echo "[checkpoint] ERROR invalid explicit full-suite flag: $1" >&2; exit 2 ;;
  esac
  [[ "$#" -le 1 ]] || { echo "[checkpoint] ERROR unexpected extra arguments" >&2; exit 2; }
  echo "[checkpoint] EXPLICIT legacy global full-suite: ALL tests, including historical (may be RED)"
  exec env CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint
fi

[[ "$#" -eq 0 ]] || {
  echo "[checkpoint] ERROR unknown flags; use no args for canonical Tier A/B, or explicit --legacy-global" >&2
  exit 2
}

# The canonical lane already runs structural manifest checks, Tier A,
# World1 fast/release checks, and terminal Tier B. It fails closed on red cases.
# Its GitHub Actions counterpart also seals/verifies the OBS04 machine receipt.
echo "[checkpoint] CANONICAL source-and-test authority: Tier A + terminal Tier B"
exec ./tools/test_authority_canonical_lane_v1.sh
