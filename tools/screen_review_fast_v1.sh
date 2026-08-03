#!/usr/bin/env bash
set -euo pipefail

group="${1:-}"
device="${2:-}"
modifier="${3:-none}"

usage() {
  echo 'Usage: ./tools/screen_review_fast_v1.sh <alpha_journey|core|runner|first_week|day2_return|profile_evidence|wave2_closure|sharky_evidence|full_scroll|route_w7_w12|active_route_w7_w12|w2|presentation_closure|review_return|production_real_live> <compact|tall_phone|large_phone|tablet|iphone17_class>' >&2
}

if [[ ( "$group" != "alpha_journey" && "$group" != "core" && "$group" != "runner" && "$group" != "first_week" && "$group" != "day2_return" && "$group" != "profile_evidence" && "$group" != "wave2_closure" && "$group" != "sharky_evidence" && "$group" != "full_scroll" && "$group" != "route_w7_w12" && "$group" != "active_route_w7_w12" && "$group" != "w2" && "$group" != "presentation_closure" && "$group" != "review_return" && "$group" != "production_real_live" ) || ( "$device" != "compact" && "$device" != "tall_phone" && "$device" != "large_phone" && "$device" != "tablet" && "$device" != "iphone17_class" ) || ( "$group" != "production_real_live" && "$modifier" != "none" ) || ( "$group" == "production_real_live" && "$modifier" != "none" && "$modifier" != "text_scale_1_4" && "$modifier" != "reduced_motion" ) ]]; then
  usage
  exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
packet="${group}_fast"
if [[ "$group" == "presentation_closure" ]]; then
  if [[ "$device" == "compact" ]]; then
    packet="presentation_closure_v1"
  else
    packet="presentation_closure_${device}_v1"
  fi
elif [[ "$group" == "review_return" ]]; then
  packet="review_return_v1"
elif [[ "$device" != "compact" ]]; then
  packet="${group}_${device}_fast"
fi

(
  cd "$root"
  if [[ "$group" == "production_real_live" ]]; then
    if [[ "$modifier" == "none" ]]; then
      dart run tools/act0_production_real_runner_capture_v1.dart "$device"
    else
      dart run tools/act0_production_real_runner_capture_v1.dart "$device" "$modifier"
    fi
    lane="output/visual_master_audit/raw/live_runner_${device}_${modifier}_v1"
    python3 tools/screen_review_fast_text_repair_v1.py "$lane" "$device"
    ./tools/package_screen_review_v1.sh current production_real_live "$lane"
    exit 0
  fi
  dart run tools/act0_real_text_surface_capture_v1.dart "$group" "$device"
  python3 tools/screen_review_fast_text_repair_v1.py \
    "output/screen_review/current/${packet}" "$device"
  ./tools/package_screen_review_v1.sh current "${packet}" "output/screen_review/current/${packet}"
)
