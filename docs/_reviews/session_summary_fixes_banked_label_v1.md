# Session Summary Fixes Banked Label v1

## 1. Verdict

session_summary_fixes_banked_label_ready_local_only

## 2. Source contract alignment

Primary contract:

- `docs/_reviews/fixes_youve_banked_proof_home_contract_v1.md`

Supporting sources:

- `docs/_reviews/session_summary_repair_outcome_receipt_v1.md`
- `docs/_reviews/repair_outcome_consumer_local_proof_v1.md`
- `docs/_reviews/repair_outcome_projection_v1.md`
- `docs/_reviews/evidence_based_skill_rpg_taxonomy_contract_v1.md`
- `docs/_reviews/achievement_taxonomy_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`

The proof-home contract admitted only a session/current proof model through the
existing Session Summary repair receipt. This slice consumes the existing
`Act0RepairOutcomeConsumerV1.sessionReceipt` title and rows only.

## 3. What changed

Changed the Session Summary repair receipt title:

- from `Fix attempts`
- to `Fixes you've banked`

Existing rows were preserved:

- `Good fixes: X`
- `Still to fix: Y`
- `Fixes tried: Z`

No subtitle was added because the existing card can carry the label change
without new layout behavior.

## 4. Session-local boundary

`Fixes you've banked` is local to the current Session Summary repair receipt.
It is backed by current repair outcome projection data only:

- `Act0RepairOutcomeProjectionV1`
- `Act0RepairOutcomeConsumerV1`
- `_SessionSummaryRepairOutcomeReceiptCardV1`

The copy is not used as an all-time Profile, Review, Practice, or dashboard
claim.

## 5. No durable/all-time boundary

This PR does not add:

- durable repair outcome history;
- all-time fix counts;
- cross-session fix counts;
- Profile proof-home totals;
- rating, radar, levels, or skill score.

Durable `Fixes you've banked` remains blocked until a durable repair outcome
history/source owner exists.

## 6. No queue/Review resolution boundary

This PR does not add or change:

- queue item removal;
- queue resolution;
- queue done state;
- Review clearing;
- Review resolved/recovered state;
- permanent fixed state.

`Good fixes: X` still means current/session repair outcomes answered correctly,
not that a Review item, queue item, leak, or skill family was resolved.

## 7. Forbidden-copy proof

Focused tests assert the Session Summary repair receipt avoids:

- `Cleared`
- `Resolved`
- `Fixed forever`
- `Leak fixed`
- `Mastered`
- `All-time`
- `Rating`
- `Radar`
- `Level`

The implementation continues to avoid premium/paywall, AI, GTO, solver,
guaranteed-improvement, and old repair-loop plumbing copy in the same receipt
family.

## 8. Tests / validation

Validation run:

- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart` - passed, 0 files changed.
- `flutter test test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart` - passed.
- `./tools/screen_review_fast_v1.sh first_week compact` - passed.
- `./tools/screen_review_fast_v1.sh day2_return compact` - passed.
- `./tools/screen_review_fast_v1.sh full_scroll compact` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `git diff --check` - passed.
- `git status --short` - source/test/review changes only, plus pre-existing generated output directories.

Targeted copy scan over the touched receipt owner, Session Summary card, and
focused tests found no remaining `Fix attempts` copy and no forbidden repair
receipt/title copy. Existing `Level` matches are pre-existing XP/progression
fields outside this Session Summary repair receipt slice and were not changed.

TDD proof:

- Updated focused receipt title assertions first.
- The focused consumer and Session Summary tests failed against `Fix attempts`.
- The minimal production title change made those tests pass.

## 9. Screenshot proof

Screenshot review generated local-only proof:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated output directories are local-only and must remain untracked:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`

## 10. Next recommended PR

Repair Outcome History Source Contract v1.

If product wants durable all-time `Fixes you've banked`, the next safe step is a
source-contract wave for durable repair outcome history, not a UI dashboard.
