# Feedback / Repair Card Hierarchy Pass v1

## Scope

Local-only Slice 1 implementation from
`docs/_reviews/full_surface_visual_design_spec_v1.md`.

This pass only touched the existing Act0 feedback seam for:

- wrong feedback;
- table-signal proof;
- action contrast;
- Repair focus;
- Repair result;
- Session repair.

No routing, repair selection, telemetry, progression, Modern Table visuals,
Placement, Welcome, Home, Learn, Practice, Review, or Profile behavior changed.

## PIEC result

The relevant repair proof data already lived in `Act0FeedbackShellV1`:

- table signal via `Act0FeedbackSignalProofV1`;
- chosen/better action labels via existing feedback labels;
- repair focus via existing `repairReasonLine` mapping;
- repair outcome via existing `repairResultReceiptLine`;
- session closure via existing `repairSessionSummaryLines`.

No new product state or repair engine behavior was needed.

## Hierarchy change

The feedback card now groups the proof sequence as:

1. result label;
2. table signal proof;
3. action contrast;
4. reason;
5. Repair focus;
6. Repair result;
7. Session repair.

The visible copy remains the existing calm repair copy. The change is hierarchy
and spacing only.

## Files changed

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `docs/_reviews/feedback_repair_card_hierarchy_pass_v1.md`

## Checks

- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `flutter analyze`
- `git diff --check`
- `git status --short`

## Screen review artifacts

Expected local-only output:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Generated artifacts remain uncommitted.

## Remaining limitations

- The fast-rendered packet is still not final CTA-copy proof where the renderer
  shows button-label white bars.
- Completed placement result and dynamic personalized Profile repair-return
  reason remain accepted capture gaps.
- Broader Profile, Review, and cross-surface visual rhythm work remain future
  slices.

## Recommendation

Package and push this hierarchy pass when ready, then continue with the next
bounded visual slice from the full surface design spec.
