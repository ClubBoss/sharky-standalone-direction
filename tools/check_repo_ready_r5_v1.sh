#!/usr/bin/env bash
set -euo pipefail

quick_mode=0
for arg in "$@"; do
  case "$arg" in
    --quick)
      quick_mode=1
      ;;
    -h|--help)
      echo "usage: ./tools/check_repo_ready_r5_v1.sh [--quick]"
      echo "  --quick   Run command/executable checks only (skip release gate)"
      exit 0
      ;;
    *)
      echo "check_repo_ready_r5_v1: FAIL unknown arg '$arg'" >&2
      echo "usage: ./tools/check_repo_ready_r5_v1.sh [--quick]" >&2
      exit 64
      ;;
  esac
done

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
  echo "check_repo_ready_r5_v1: FAIL could not locate repo root (pubspec.yaml missing)" >&2
  exit 2
fi

cd "$ROOT"

echo "check_repo_ready_r5_v1: root=$ROOT"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "check_repo_ready_r5_v1: FAIL missing command '$cmd'" >&2
    echo "next: install '$cmd' and re-run ./tools/check_repo_ready_r5_v1.sh" >&2
    exit 2
  fi
  echo "check_repo_ready_r5_v1: OK command '$cmd'"
}

require_exec() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "check_repo_ready_r5_v1: FAIL missing script '$path'" >&2
    exit 2
  fi
  if [[ ! -x "$path" ]]; then
    echo "check_repo_ready_r5_v1: FAIL script not executable '$path'" >&2
    echo "next: chmod +x '$path'" >&2
    exit 2
  fi
  echo "check_repo_ready_r5_v1: OK executable '$path'"
}

require_cmd flutter
require_cmd dart
require_cmd bash

require_exec ./tools/run_release_gate_r5_v1.sh
require_exec ./tools/run_table_first_tiers.sh

if [[ "$quick_mode" == "1" ]]; then
  echo "READY_OK (quick)"
  exit 0
fi

echo "check_repo_ready_r5_v1: RUN ./tools/run_release_gate_r5_v1.sh"
if ! ./tools/run_release_gate_r5_v1.sh; then
  rc=$?
  echo "check_repo_ready_r5_v1: FAIL release gate exit=$rc" >&2
  echo "next: inspect output above and fix the first failing gate step" >&2
  echo "next: re-run ./tools/check_repo_ready_r5_v1.sh" >&2
  exit "$rc"
fi

echo "READY_OK"
