#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

readonly fresh_contract='tools/contracts/alpha_fresh_install_first_lesson_v1.json'
readonly action_contract='tools/contracts/alpha_action_repair_recovery_unlocked_v2.json'
readonly retired_contract='tools/contracts/alpha_action_repair_recovery_v1.json'
readonly base_sha="$(git rev-parse --short HEAD)"
readonly bundle="output/review_bundles/canonical_journey_truth_progression_v1_${base_sha}"
readonly zip_path="${bundle}.zip"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo 'P0 tracked worktree is dirty; Alpha QA Factory will not mix evidence with edits.' >&2
  exit 20
fi

if git diff --cached --name-only | rg -q '^output/'; then
  echo 'P0 output artifacts are staged.' >&2
  exit 21
fi

rm -rf "$bundle" "$zip_path" "${zip_path}.sha256"
mkdir -p "$bundle"/{01_report,02_owner_map,03_fresh_install_contract,04_action_capability_contract,05_progression_proof,06_computer_use_fresh,07_computer_use_action,08_telemetry,09_validation,10_manifest}
readonly log="$bundle/09_validation/command.log"

run_stage() {
  local stage="$1"
  shift
  printf '\n== %s ==\n' "$stage" | tee -a "$log"
  "$@" 2>&1 | tee -a "$log"
}

assert_modern_table_untouched() {
  local changed
  changed="$(git diff --name-only HEAD^ HEAD -- lib/ui_v2/table lib/ui_v2/screens/modern_table_screen_v1.dart || true)"
  if [[ -n "$changed" ]]; then
    printf 'P1 Modern Table boundary changed in HEAD:\n%s\n' "$changed" >&2
    return 1
  fi
  echo 'PASS Modern Table boundary unchanged; active Action raster owns geometry proof.'
}

assert_retired_misleading_contract_absent() {
  if [[ -e "$retired_contract" ]]; then
    echo "P1 retired misleading fresh-route contract still exists: $retired_contract" >&2
    return 1
  fi
  echo 'PASS retired misleading direct-fresh-user Action contract is absent.'
}

run_stage 'preflight' git status --short --branch
run_stage 'fresh-install contract' python3 tools/validate_alpha_journey_contract_v1.py --contract "$fresh_contract" --expected-version 1 --expected-kind fresh_install
run_stage 'Action capability contract' python3 tools/validate_alpha_journey_contract_v1.py --contract "$action_contract" --expected-version 2 --expected-kind action_capability
run_stage 'retired misleading contract guard' assert_retired_misleading_contract_absent

cp "$fresh_contract" "$bundle/03_fresh_install_contract/"
cp "$action_contract" tools/contracts/alpha_action_capability_prerequisite_progression_v1.json "$bundle/04_action_capability_contract/"

run_stage 'fresh-install visible progression proof' flutter test \
  test/ui_v2/alpha_journey_progression_truth_v1_test.dart

run_stage 'Action capability black-box replay and telemetry trace' flutter test \
  --dart-define=ALPHA_QA_TRACE_PATH="$bundle/08_telemetry/unlocked_action_wrong_repair_recheck_trace.json" \
  test/ui_v2/act0_telemetry_sink_v1_test.dart \
  --plain-name 'unlocked Action capability journey completes the alpha loop with ordered safe telemetry'

run_stage 'correct-first deterministic policy' flutter test \
  test/ui_v2/act0_action_sequence_personalization_v1_test.dart \
  --plain-name 'correct initial Action read continues canonical progression'
run_stage 'failed-recheck deterministic policy' flutter test \
  test/ui_v2/act0_action_sequence_personalization_v1_test.dart \
  --plain-name 'repeated missed action read takes precedence over other rules'
run_stage 'same-task route contract' flutter test test/ui_v2/act0_action_learning_sequence_v1_test.dart

for viewport in compact tall_phone large_phone; do
  case "$viewport" in
    compact) width=375; height=812 ;;
    tall_phone) width=390; height=844 ;;
    large_phone) width=430; height=932 ;;
  esac
  run_stage "${viewport} Action raster capture" flutter test \
    --dart-define=ACTION_EVIDENCE_DEVICE="$viewport" \
    --dart-define=ACTION_EVIDENCE_WIDTH="$width" \
    --dart-define=ACTION_EVIDENCE_HEIGHT="$height" \
    --dart-define=ACTION_EVIDENCE_OUTPUT="$bundle/07_computer_use_action/$viewport" \
    test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart \
    --plain-name 'captures canonical W1 Action production states'
done

for viewport in compact tall_phone large_phone; do
  cp "$bundle/07_computer_use_action/$viewport/"*contact_sheet.png "$bundle/07_computer_use_action/"
done

run_stage 'Modern Table boundary and Action geometry lock' assert_modern_table_untouched
run_stage 'factory shell syntax' bash -n tools/run_alpha_journey_qa_v1.sh
run_stage 'Flutter analyzer' flutter analyze
run_stage 'policy-gated fast loop' ./tools/fast_loop_world1_v1.sh
run_stage 'Graphify hook check' graphify hook-check
run_stage 'working diff check' git diff --check
run_stage 'staged diff check' git diff --cached --check
run_stage 'Action trace and evidence admission' python3 tools/validate_alpha_journey_contract_v1.py \
  --contract "$action_contract" \
  --expected-version 2 \
  --expected-kind action_capability \
  --trace "$bundle/08_telemetry/unlocked_action_wrong_repair_recheck_trace.json" \
  --bundle "$bundle" \
  --base-sha "$base_sha" \
  --replay-source test/ui_v2/act0_telemetry_sink_v1_test.dart

printf '%s\n' '# Fresh-install journey verdict' '- PASS: canonical onboarding reaches First Table Guide at 0/9; Action remains locked until ordered prerequisites are complete.' > "$bundle/01_report/fresh_install_journey.md"
printf '%s\n' '# Action capability journey verdict' '- PASS: validated persisted prerequisite history exposes Action before entry; no Dev/debug shortcut or intermediate Action state is used.' > "$bundle/01_report/action_capability_journey.md"

printf '\n== evidence manifest ==\n' >> "$log"
python3 tools/validate_alpha_journey_contract_v1.py \
  --contract "$action_contract" \
  --expected-version 2 \
  --expected-kind action_capability \
  --trace "$bundle/08_telemetry/unlocked_action_wrong_repair_recheck_trace.json" \
  --bundle "$bundle" \
  --base-sha "$base_sha" \
  --replay-source test/ui_v2/act0_telemetry_sink_v1_test.dart \
  --write-manifest >/dev/null

(cd "$(dirname "$bundle")" && zip -qry "$(basename "$zip_path")" "$(basename "$bundle")")
shasum -a 256 "$zip_path" > "${zip_path}.sha256"

if git diff --cached --name-only | rg -q '^output/'; then
  echo 'P0 output artifacts were staged during QA.' >&2
  exit 21
fi

printf 'PASS fresh_install_journey: %s\nPASS action_capability_journey: %s\nPASS canonical journey truth bundle: %s\nPASS ZIP: %s\n' "$fresh_contract" "$action_contract" "$bundle" "$zip_path"
