# First-Week Visual Rhythm Pass v1

## Scope

Local-only Slice 2 implementation from
`docs/_reviews/full_surface_visual_design_spec_v1.md`.

This pass only adjusted the existing first-week visual rhythm across:

- Placement intro / route-check framing;
- Welcome intro and handoff beat framing;
- W1 runner decision prompt / option anchoring;
- the already-existing first-week feedback proof packet.

No routes, placement decisions, Welcome beat count, learning engine decisions,
telemetry, progression, Modern Table visuals, Home, Learn, Practice, Profile,
or Review behavior changed.

## PIEC result

The first-week proof chain already existed:

`Placement -> Welcome -> W1 decision -> Feedback/Repair`

The smallest safe seams were:

- Placement: wrap the existing hero and launch path in one route-check frame;
- Welcome: wrap existing text beats in one first-start beat frame and mark the
  handoff proof block;
- Runner: wrap the existing compact prompt/options surface in a clearer
  decision rhythm surface.

No new product state, route, capture state, table component, or telemetry seam
was needed.

## Rhythm before / after

Before:

- Placement hero and launch path read as adjacent dark cards.
- Welcome beats had the right content, but the title, preview, and Sharky
  coaching card read as separate stacked panels.
- Compact runner decisions were readable but visually tight between the table
  and the prompt/options surface.

After:

- Placement now reads as one short route-check entry gate.
- Welcome intro and handoff beats share one framed first-start rhythm.
- Welcome handoff keeps the micro-win proof connected to the next W1 handoff.
- Compact runner decision state has clearer prompt/options anchoring under the
  table without changing table visuals.

## Product behavior truth

- No new placement questions.
- No placement diagnostic expansion.
- No new Welcome beat.
- No World 0.
- No Learn map node.
- No route behavior change.
- No curriculum progress mutation.
- No engine or telemetry change.

## Modern Table

Modern Table visuals were not changed. The runner change only affects the
surface around the prompt/options below the table.

## Untouched surfaces

- Home: unchanged.
- Learn: unchanged.
- Practice: unchanged.
- Profile: unchanged.
- Review: unchanged.

## Files changed

- `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `docs/_reviews/first_week_visual_rhythm_pass_v1.md`

## Tests / checks

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "First-run placement asks questions before the app shell"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Welcome completes one local micro win before Home handoff"`
- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `flutter analyze`
- `dart format` on touched Dart files
- `git diff --check`
- `git status --short`

## First-week packet artifacts

Local-only outputs:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Generated artifacts remain uncommitted.

## Remaining limitations

- The fast-rendered packet still has the accepted button-label white bar issue.
- Completed placement result is still not captured.
- Dynamic personalized Profile repair-return reason is still not captured.
- Profile / Review proof hierarchy remains the next ranked visual slice, not
  part of this pass.

## Recommended next step

Package and push this local rhythm pass when ready, then continue with
Profile / Review Proof Hierarchy Pass v1.
