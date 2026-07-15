#!/usr/bin/env bash
set -euo pipefail

group="${1:-}"
device="${2:-}"

usage() {
  echo 'Usage: ./tools/screen_review_fast_v1.sh <alpha_journey|core|runner|first_week|day2_return|profile_evidence|full_scroll|route_w7_w12|active_route_w7_w12|presentation_closure|review_return> <compact|tall_phone|large_phone|tablet|iphone17_class>' >&2
}

if [[ ( "$group" != "alpha_journey" && "$group" != "core" && "$group" != "runner" && "$group" != "first_week" && "$group" != "day2_return" && "$group" != "profile_evidence" && "$group" != "full_scroll" && "$group" != "route_w7_w12" && "$group" != "active_route_w7_w12" && "$group" != "presentation_closure" && "$group" != "review_return" ) || ( "$device" != "compact" && "$device" != "tall_phone" && "$device" != "large_phone" && "$device" != "tablet" && "$device" != "iphone17_class" ) ]]; then
  usage
  exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
packet="${group}_fast"
if [[ "$group" == "presentation_closure" ]]; then
  packet="presentation_closure_v1"
elif [[ "$group" == "review_return" ]]; then
  packet="review_return_v1"
elif [[ "$device" != "compact" ]]; then
  packet="${group}_${device}_fast"
fi

(
  cd "$root"
  dart run tools/act0_real_text_surface_capture_v1.dart "$group" "$device"
  python3 tools/screen_review_fast_text_repair_v1.py \
    "output/screen_review/current/${packet}" "$device"
  ./tools/package_screen_review_v1.sh current "${packet}" "output/screen_review/current/${packet}"
)
