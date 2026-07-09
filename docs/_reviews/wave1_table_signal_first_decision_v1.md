# Wave 1 Table Signal + First Decision Actionability v1

## 1. Executive verdict

Wave 1 is implemented for design re-review with known evidence-scope limitations. The Act0 lesson runner now treats the active table clue as a primary learning signal, raises table-critical pot/price/status labels, makes Hero/BTN/blind artifacts more poker-specific, and visually bridges table clues into feedback.

Terminal verdict: `wave1_table_signal_complete_with_known_limitations_ready_for_design_rereview`

## 2. Baseline branch/commit

- Baseline branch: `codex/pre-human-qa-max10-push-v5`
- Required baseline commit: `485e773c540638c7168a3d5a23d5dab339dd08b2`
- Working branch: `codex/wave1-table-signal-first-decision-v1`

## 3. Implemented MB IDs

- MB-001 - Table signal layer
- MB-002 - First decision actionability
- MB-003 - Table-to-feedback bridge
- MB-019 - Pot/stack/BTN/blind hierarchy
- MB-020 - Board/status header consistency
- MB-021 - Hero/villain card weighting
- MB-029 - Welcome first table exposure
- MB-031 - Text scale and contrast floor

## 4. Table signal changes

- Replaced the small center focus treatment with a dedicated `Table clue` anchor in the table center card.
- Added stable Wave 1 table signal keying: `act0_shell_wave1_table_signal_anchor`.
- Preserved real deterministic runtime copy; no fake clue, fake progress, route change, or answer-change data was introduced.

## 5. Board/status/pot hierarchy changes

- Consolidated clue and street into a coherent status cluster keyed by `act0_shell_wave1_status_cluster`.
- Kept street/status visible as a distinct table-state badge rather than a disconnected metadata label.
- Promoted pot and price/to-call into stronger center-table priority stats:
  - `act0_shell_wave1_pot_priority_stat`
  - `act0_shell_wave1_price_priority_stat`
- Preserved existing legacy keys for pot/to-call compatibility.

## 6. Hero/BTN/stack/blind changes

- Changed the hero seat avatar from an abstract `Y` marker to a direct `You` badge keyed by `act0_shell_wave1_hero_you_badge`.
- Changed the dealer marker from `D` to `BTN`, with dedicated key `act0_shell_wave1_dealer_marker`.
- Added stable blind marker keying via `act0_shell_wave1_blind_marker_*`.
- Kept table geometry and seat placement logic unchanged.

## 7. First decision actionability changes

- `06_first_decision` now presents the table read with a stronger visible clue/status/pot hierarchy before the learner chooses.
- Existing answer-control design was not changed, per non-goal. Compact screenshots show the decision panel and options remain available in the first decision capture.
- The table is still the primary learning surface; the action prompt remains below it as the deliberate next step.

## 8. Table-to-feedback bridge changes

- Feedback signal proof now repeats the table relationship with a `Clue from table` bridge treatment.
- Added stable key `act0_shell_wave1_feedback_signal_bridge`.
- Correct, wrong, and repair feedback retain existing proof/reason structures while visually tying the explanation back to the table clue.

## 9. Welcome first table exposure changes

- Welcome inherits the improved table signal/status/hero/BTN/blind treatment through the shared Act0 table components.
- The first table exposure now has a more intentional table-read surface without adding new fake state or extra onboarding content.

## 10. Scope explicitly not touched

- Route semantics.
- Answer correctness.
- W13+ activation.
- Telemetry.
- Content-engine architecture.
- Human QA.
- Public readiness, launch readiness, 10/10 proof, or durable learning-effect claims.
- Fake misses, fake proof, fake progress, fake achievements.
- Monetization or paywall logic.
- Broad app redesign.
- Action-control button design.
- Sharky art production changes.

## 11. Evidence pack path

`output/design_review/real_text_visual_pack_wave1_table_signal_v1/`

## 12. Screenshot coverage

- Manifest schema: `real_text_visual_pack_wave1_table_signal_v1`
- Screens: 19/19
- Entries: 108
- Compact visible contact sheet: `output/design_review/real_text_visual_pack_wave1_table_signal_v1/contact_sheets/compact_visible_contact_sheet.png`
- Compact full-scroll/segment contact sheet: `output/design_review/real_text_visual_pack_wave1_table_signal_v1/contact_sheets/compact_full_scroll_contact_sheet.png`
- Tablet visible contact sheet: `output/design_review/real_text_visual_pack_wave1_table_signal_v1/contact_sheets/tablet_visible_contact_sheet.png`
- Tablet full-scroll/segment contact sheet: `output/design_review/real_text_visual_pack_wave1_table_signal_v1/contact_sheets/tablet_full_scroll_contact_sheet.png`
- Primary screens covered: 05-10 and 17-19.
- Full 19-screen contact sheets generated for compact and tablet.

## 13. Validation run

- `flutter test test/guards/wave1_table_signal_first_decision_contract_test.dart --reporter expanded` - passed after red/green guard cycle.
- `flutter analyze` - passed with no issues.
- `flutter test test/guards/wave1_table_signal_first_decision_contract_test.dart test/guards/pre_human_qa_max10_push_v5_contract_test.dart --reporter expanded` - 8/8 passed.
- Screenshot capture lanes passed:
  - `./tools/screen_review_fast_v1.sh core compact`
  - `./tools/screen_review_fast_v1.sh core tablet`
  - `./tools/screen_review_fast_v1.sh first_week compact`
  - `./tools/screen_review_fast_v1.sh first_week tablet`
  - `./tools/screen_review_fast_v1.sh day2_return compact`
  - `./tools/screen_review_fast_v1.sh day2_return tablet`
  - `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`
  - `./tools/screen_review_fast_v1.sh active_route_w7_w12 tablet`
  - `./tools/screen_review_fast_v1.sh full_scroll compact`
  - `./tools/screen_review_fast_v1.sh full_scroll tablet`
- `python3 tools/build_real_text_visual_pack_wave1_table_signal_v1.py` - passed.
- Compact visible/full-scroll and tablet visible contact sheets were visually spot-checked for blank screens, obvious clipping, and primary-action occlusion.

## 14. Known limitations

- Evidence is static visual evidence only. It does not prove Human QA, learning effect, public readiness, launch readiness, or 10/10 product quality.
- Tablet is smoke coverage for layout/clipping/action access, not the primary quality target.
- The table-to-feedback bridge is deterministic UI treatment; it does not change content correctness or route behavior.
- Existing output screenshot directories are local-only evidence and are not intended as product source.

## 15. Whether Wave 1 is ready for Claude Design re-review

Ready with known limitations. Use the generated Wave 1 evidence pack and `wave1_table_signal_first_decision_rereview_prompt.md` for design re-review.

## 16. Explicit non-claims

This artifact does not claim Human QA approval, public readiness, launch readiness, App Store readiness, 9.0 proof, 10/10 proof, durable learning effect, beginner mastery, premium commercial readiness, or that all future UI backlog items are closed.
