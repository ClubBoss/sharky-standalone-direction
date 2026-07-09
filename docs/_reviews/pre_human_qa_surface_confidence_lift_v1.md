# Pre-Human-QA Surface Confidence Lift v1

## Scope

Branch: `codex/pre-human-qa-surface-confidence-lift-v1`

Baseline before edits: `d4238882ef0456d0d5a65abcbfd16af39cf0c72e`

This was a bounded visual/product surface lift before Human QA. It did not run Human QA and did not change route ownership, telemetry schema, Modern Table behavior, answer correctness semantics, progression ownership, W13+, or content-engine architecture.

## Changes

- Home: no-repair review row now explains that Review stays ready and real lesson misses appear there when there is a clue to fix.
- Learn: current mission appears before the foundation map, and the foundation copy is quieter so the next lesson remains the first action.
- Practice: repair empty state now explains that repair unlocks from real lesson misses; locked topic summary now points back to route progress instead of reading like a closed drill wall.
- Review: empty state now explains where future misses go; active repair card now frames the Miss -> Repair -> Proof loop more directly and uses the premium action CTA style.
- W11/W12 copy: active-route and terminal copy now use player-facing `cue`, `Volume I review`, and locked-world language instead of audit/spec phrases such as trigger-action lever, terminal review state, no future world is open, or blocked in this route.
- CTA tone: `premiumActionButtonStyle` no longer reuses the generic blue primary button; premium action CTAs now use the Sharky cyan/felt treatment.

## Evidence Regenerated

Local-only screenshot evidence was regenerated under `output/screen_review/current/` and left unstaged:

- `act0_product_100_proof/manifest.json`
- `core_fast/manifest.json`
- `core_tablet_fast/manifest.json`
- `first_week_fast/manifest.json`
- `first_week_tablet_fast/manifest.json`
- `day2_return_fast/manifest.json`
- `day2_return_tablet_fast/manifest.json`
- `active_route_w7_w12_fast/manifest.json`
- `active_route_w7_w12_tablet_fast/manifest.json`

No generated PNGs or zips are intended for staging.

No dedicated generator for `output/design_review/real_text_visual_pack_v1/` was found in the local tool search. The current regenerated evidence is the supported real-text screen-review packet set above.

## Validation

Passed:

- `flutter test test/guards/act0_product_100_proof_capture_tooling_contract_test.dart test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/guards/pre_human_qa_screenshot_evidence_pipeline_contract_test.dart test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart test/guards/w1_w12_poker_correctness_review_contract_test.dart test/guards/w1_w12_answer_position_distribution_contract_test.dart test/guards/pre_human_qa_surface_confidence_lift_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart --reporter expanded`
- `dart run tools/act0_product_100_proof_capture_v1.dart`
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh core tablet`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh first_week tablet`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh day2_return tablet`
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 tablet`
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`

## Claim Boundary

This artifact documents implementation scope, regenerated local evidence, and automated validation only. It does not claim Human QA approval, public readiness, launch readiness, 10/10 proof, durable learning effect, beginner mastery, or premium readiness.
