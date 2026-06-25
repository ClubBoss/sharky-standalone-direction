# Learn Route Numbering / Arc Clarity v1

## 1. Verdict

learn_copy_only_route_clarity_ready

## 2. Wave 2 scope finding addressed

Learn was truthful but numerically dense. The screen showed current world,
current mission progress, current task step, and journey-preview row numbers in
close proximity. This pass clarifies the role of the existing numbers without
adding a new route model or activating future worlds.

## 3. Learn owner map

- Learn route surface owner:
  `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- Current world strip:
  `_WorldContextStripV5`
- Current lesson / mission card:
  `_CurrentMissionCardV1`
- Journey preview:
  `_JourneyPreviewV5`
- Journey rows:
  `_JourneyPreviewRowV5`
- Focused route tests:
  `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## 4. Before/after route hierarchy

Before:

1. World strip labeled `World 1`.
2. World progress line showed lesson count and module progress.
3. Current mission used `Now` plus `Learning path`.
4. Current task step showed `Step 1 of 7`.
5. Journey preview rows also used numbered nodes.

After:

1. World strip labels the route scope as `Current world · W1`.
2. The progress line names the single canonical progress indicator:
   `World progress · ...`.
3. Current mission labels the active lesson role as `Current lesson`.
4. Current task step reads `Current step · 1 of 7`.
5. Journey preview remains a secondary browse preview and keeps existing
   completed/current/next/locked truth.

## 5. Current-progress indicator decision

The canonical current-progress indicator remains the world progress bar plus
the route-board line under it. This pass only labels that line as
`World progress`; it does not add another progress bar, counter, milestone
system, or completion claim.

The current mission card now separates:

- current world: `Current world · W1`;
- current lesson: `Current lesson`;
- current task step: `Current step · 1 of 7`.

## 6. Future-arc / planned-world boundary proof

No new future-arc display was added. The existing world menu already owns the
safe future truth:

- W1-W10 remain the active route-backed foundation truth currently surfaced by
  the app.
- W11-W12 remain planned foundation chapters, coming later.
- W13+ remains later strategic depth.

This pass does not show W11/W12 as active and does not show W13+ as active.
It also does not claim that the 36-world system is live in runtime.

## 7. Route/progression truth proof

- No route/progression mutation changed.
- No `Act0ShellStateV1` data changed.
- No lesson/world availability changed.
- No Learn CTA routing changed.
- No world-menu selection behavior changed.
- No W11/W12/W13 activation was added.
- No Volume I completion claim was added.

The change is display-only copy in existing Learn widgets plus focused tests.

## 8. Forbidden-claim proof

This pass does not introduce:

- premium, paywall, or trial copy;
- personalization, AI, leak, mastery, GTO, or solver claims;
- `36 worlds live`;
- `Volume I complete`;
- W11/W12 active entry;
- W13+ active entry;
- new content, route targets, or unlock behavior.

## 9. Screenshot/capture proof

Required local proof commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Expected local artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated screenshot packets are local-only evidence and must remain
uncommitted.

## 10. Tests / validation

Required validation for this local wave:

- focused Learn shell tests;
- affected Act0 shell preview tests;
- `./tools/screen_review_fast_v1.sh first_week compact`;
- `./tools/screen_review_fast_v1.sh full_scroll compact`;
- `graphify hook-check`;
- `flutter analyze`;
- touched-file format check only;
- `git diff --check`;
- `git status --short`.

## 11. Next recommended wave

Run a gated push for `Learn Route Numbering / Arc Clarity v1` after validation.
Then continue Wave 2 with:

`Onboarding Handoff Simplification v1`

That should remain a handoff-only simplification and must not add new
onboarding beats, route state, content, premium, AI/persona, or progression
behavior.
