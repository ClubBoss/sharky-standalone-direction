#!/usr/bin/env bash
set -euo pipefail

group="${1:-}"
device="${2:-}"

usage() {
  echo 'Usage: ./tools/screen_review_fast_v1.sh <core|runner|first_week|day2_return|full_scroll> compact' >&2
}

if [[ ( "$group" != "core" && "$group" != "runner" && "$group" != "first_week" && "$group" != "day2_return" && "$group" != "full_scroll" ) || "$device" != "compact" ]]; then
  usage
  exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

(
  cd "$root"
  dart run tools/act0_real_text_surface_capture_v1.dart "$group" "$device"
  python3 tools/screen_review_fast_text_repair_v1.py \
    "output/screen_review/current/${group}_fast" "$device"
  ./tools/package_screen_review_v1.sh current "${group}_fast" "output/screen_review/current/${group}_fast"
)
