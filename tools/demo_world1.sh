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

source "$ROOT/tools/_world1_selected_tests_v1.sh"

readonly DEMO_TESTS_V1=(
  "${WORLD1_SELECTED_TESTS_V1[0]}"
  "${WORLD1_SELECTED_TESTS_V1[2]}"
)

echo "[demo] 1/2 targeted confidence tests (single pass)"
echo "[demo] Selected tests:"
for t in "${DEMO_TESTS_V1[@]}"; do
  echo "  - $t"
done
demo_tests_env="$(printf '%s\n' "${DEMO_TESTS_V1[@]}")"
FAST_LOOP_SELECTED_TESTS_V1="$demo_tests_env" ./tools/fast_loop_world1_v1.sh --no-analyze --force-tests
echo "[demo] 2/2 print demo checklist"

COMMIT_SHORT="$(git rev-parse --short HEAD)"
DATE_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat << 'FLOW'

DEMO STEPS (5 minutes)
1) Cold start -> Today Plan appears.
   Expected key: today_plan_start_cta
2) Tap START CAMPAIGN.
   Expected first pack id: world1_act0_table_literacy
3) Continue through Act0 packs.
   Expected path: table_literacy -> action_literacy -> street_flow
4) Continue into spine.
   Expected next pack id: world1_spine_campaign_v1
5) Reach Session Result and tap BACK TO MAP.
   Expected key: session_result_back_to_map_cta

SHARE ARTIFACTS (from Session Result / Today Plan)
A) Copy Skill Card
B) Copy Duel Code
C) Apply Duel Code in Today Plan

If flow diverges:
- Re-run ./tools/release_gate_world1.sh
- Re-run flutter test test/guards/world_campaign_routing_matrix_contract_test.dart
- Re-run flutter test test/guards/world1_readiness_smoke_contract_test.dart
- Re-open docs/canonical/phase_6/demo_flow_world1_v1.md
FLOW

cat << EOF

FEEDBACK PACKET (copy/paste)
- app_version: <local build label>
- app_commit: $COMMIT_SHORT
- date_utc: $DATE_UTC
- device_model: <device>
- device_os: <os + version>
- tester_skill_band: <beginner|intermediate|advanced|unknown>
- result_focus_label: <value|none>
- result_correct_total: <correct>/<total>
- result_review_due: <yes|no>
- skill_card:
  Paste Skill Card here: ____
- duel_code:
  Paste Duel Code here: ____
- q1_confusion_point: <one line>
- q2_fun_moment: <one line>
- q3_pressure_feel: <too weak|good|too harsh + one line>
- q4_stakes_clarity: <clear|unclear + one line>
- q5_next_action_clarity: <clear|unclear + one line>
EOF

cat << EOF

TELEMETRY DIGEST (copy/paste)
- commit: $COMMIT_SHORT
- utc: $DATE_UTC
- expected_events:
  - campaign_pack_start
  - campaign_hand_result
  - campaign_pack_end
  - campaign_calibration_resolved (if spine calibration completed in run)
  - campaign_complete (once only)
- verify_commands:
  flutter test test/guards/world_campaign_routing_matrix_contract_test.dart
  flutter test test/guards/world1_campaign_telemetry_contract_test.dart
EOF
