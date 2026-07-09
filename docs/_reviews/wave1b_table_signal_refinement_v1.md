# Wave 1B Table Signal Refinement v1

## 1. Executive verdict

Wave 1B is implemented and ready for design re-review before Wave 2. The refinement keeps Wave 1's table-first learning intent while reducing label weight, making the first compact table-tap decision explicitly actionable, and preserving W11/W12 table clue/status/pot visibility.

Terminal verdict: `wave1b_table_signal_refinement_complete_ready_for_design_rereview`

## 2. Baseline branch/commit

- Baseline branch: `codex/wave1-table-signal-first-decision-v1`
- Required baseline commit: `21cd7b36eb733f888a50ed4e48b7d7528b78a10c`
- Working branch: `codex/wave1b-table-signal-refinement-v1`

## 3. Wave 1 issues addressed

- First decision compact viewport did not clearly show how to act next.
- Table clue treatment was visible but too banner-like inside the felt.
- Center clue/street/pot stack had too many separated labels.
- Feedback bridge clarified cause/effect but added another dense label row.
- Correct feedback CTA needed continued safe-area protection.
- Hero/BTN treatment needed a less technical, more polished marker pass.
- W11/W12 table status needed no-regression coverage.

## 4. First decision actionability fix

- Added explicit `Tap your hero seat` actionability cue for the first table-tap decision.
- Added stable anchors:
  - `act0_shell_wave1b_actionability_anchor`
  - `act0_shell_wave1b_answer_peek`
- Increased the compact lower-slot reservation with Wave 1B-specific constants so the prompt/action area has first-viewport priority.
- Preserved table-tap semantics and did not change answer correctness.

## 5. Table clue refinement

- Refined the Wave 1 table clue from a full-width educational banner into a compact in-felt chip.
- Preserved the original Wave 1 table signal key while adding Wave 1B-specific keys:
  - `act0_shell_wave1_table_signal_anchor`
  - `act0_shell_wave1b_table_signal_chip`
  - `act0_shell_wave1b_table_signal_text`
- Kept deterministic real table copy.

## 6. Center board/status/pot hierarchy refinement

- Combined table clue and street into one status lane keyed by `act0_shell_wave1b_status_lane`.
- Reduced street badge and pot stat visual weight while keeping pot/price above v5 visibility.
- Kept board cards centered and source-owned; no route or content data changed.

## 7. Table-to-feedback bridge refinement

- Replaced the heavier visible `Clue from table` label row with a lighter `Table evidence` bridge.
- Preserved the original bridge key and added a Wave 1B evidence key:
  - `act0_shell_wave1_feedback_signal_bridge`
  - `act0_shell_wave1b_feedback_evidence_bridge`
- Kept explanation/reason content intact.

## 8. CTA/safe-area refinement

- Compact lower-slot reservation gives feedback and prompt surfaces more protected vertical room.
- Compact visible contact sheet shows `07_correct_feedback`, `08_wrong_feedback`, `09_repair_focus`, and `10_targeted_recheck` primary CTAs fully visible.

## 9. Hero/BTN/stack refinement

- Preserved clear Hero `You` and `BTN` semantics while adding Wave 1B polished marker keys:
  - `act0_shell_wave1b_hero_badge`
  - `act0_shell_wave1b_button_marker`
- Kept Hero readable without making it louder than the active table clue.
- Stack/blind semantics and placement remained bounded to the existing table component.

## 10. Scope explicitly not touched

- Route semantics.
- Answer correctness.
- W13+ activation.
- Telemetry.
- Content-engine architecture.
- Human QA.
- Public readiness, launch readiness, 10/10 proof, or durable learning-effect claims.
- Fake progress, fake proof, fake misses, fake achievements.
- Monetization/paywall.
- Broad app redesign.
- Sharky art production.
- Wave 2 feedback color-semantic system.
- Late-route ceremony redesign.
- Fold/Check/Call action button design.

## 11. Evidence pack path

`output/design_review/real_text_visual_pack_wave1b_table_signal_refinement_v1/`

## 12. Screenshot coverage

- Manifest schema: `real_text_visual_pack_wave1b_table_signal_refinement_v1`
- Screens: 19/19
- Entries: 108
- Compact visible contact sheet: `output/design_review/real_text_visual_pack_wave1b_table_signal_refinement_v1/contact_sheets/compact_visible_contact_sheet.png`
- Compact full-scroll/segment contact sheet: `output/design_review/real_text_visual_pack_wave1b_table_signal_refinement_v1/contact_sheets/compact_full_scroll_contact_sheet.png`
- Tablet visible contact sheet: `output/design_review/real_text_visual_pack_wave1b_table_signal_refinement_v1/contact_sheets/tablet_visible_contact_sheet.png`
- Tablet full-scroll/segment contact sheet: `output/design_review/real_text_visual_pack_wave1b_table_signal_refinement_v1/contact_sheets/tablet_full_scroll_contact_sheet.png`
- Primary screens covered: 05-10 and 17-19.
- Full 19-screen contact sheets generated for compact and tablet.

## 13. Validation run

- `flutter test test/guards/wave1b_table_signal_refinement_contract_test.dart --reporter expanded` - failed first for missing Wave 1B anchors and builder, then passed after implementation.
- `flutter test test/guards/wave1b_table_signal_refinement_contract_test.dart test/guards/wave1_table_signal_first_decision_contract_test.dart --reporter expanded` - 9/9 passed.
- `flutter analyze` - passed with no issues.
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
- `python3 tools/build_real_text_visual_pack_wave1b_table_signal_refinement_v1.py` - passed.
- Compact and tablet contact sheets were visually inspected for first-decision actionability, feedback CTA visibility, blank screens, clipping, and W11/W12 no-regression.

## 14. Known limitations

- Evidence is static visual evidence only. It does not prove Human QA, learning effect, public readiness, launch readiness, or 10/10 product quality.
- Tablet is smoke coverage for layout/clipping/action access, not the primary quality target.
- `06_first_decision` is a table-tap decision, so actionability is expressed as an explicit tap cue rather than answer-list buttons.
- Existing output screenshot directories are local-only evidence and are not product source.

## 15. Whether Wave 1B is ready for design re-review or Wave 2

Ready for design re-review first. If design review accepts this pass without new P0/P1 table-actionability issues, proceed to Wave 2.

## 16. Explicit non-claims

This artifact does not claim Human QA approval, public readiness, launch readiness, App Store readiness, 9.0 proof, 10/10 proof, durable learning effect, beginner mastery, premium commercial readiness, or that Wave 2 feedback-system work is complete.
