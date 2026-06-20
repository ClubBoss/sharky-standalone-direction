#!/usr/bin/env bash
set -euo pipefail

capture_set="${1:-}"
group="${2:-core}"
capture_dir="${3:-}"
if [[ "$capture_set" != "current" ]]; then
  echo 'Usage: ./tools/package_screen_review_v1.sh current [core] [capture_dir]' >&2
  exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$root/tools/package_screen_review_v1.py" "$capture_set" "$group" "$capture_dir"
