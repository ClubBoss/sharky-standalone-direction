# Profile / Review Proof Hierarchy Pass v1

## Scope

Local-only bounded visual/product hierarchy pass on `main` after the pushed
First-Week Visual Rhythm Pass:

- Step A pushed commit: `9a9f087dbd4fce89e2a85f7d9fbff18e8d7eacf7`
- Step B local slice: Profile / Review proof hierarchy only

This pass improves the visible proof chain:

`Repair -> Review/Profile`

It does not redesign the app, add product features, alter routes, change
learning decisions, change telemetry, or touch Modern Table visuals.

## Files changed

- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/profile_review_proof_hierarchy_pass_v1.md`

## Hierarchy before / after

### Review

Before:

- active repair coach card rendered first;
- repeated pattern context rendered after the repair action block;
- recovered proof was already secondary.

After:

- repeated `Pattern to repair` context appears before the repair coach block
  when repeated evidence exists;
- the repair coach remains the primary action card and CTA owner;
- recovered proof remains secondary proof/growth;
- Review stays a coach surface, not an analytics dashboard or error log.

### Profile / You

Before:

- hero/level/XP context appeared before the strongest proof-return story;
- recent progress proof was available but not mounted in the top hierarchy;
- progress/rhythm metrics competed earlier with the improvement story.

After:

- current focus appears first as the return/focus owner;
- recent proof appears directly below current focus when real proof exists;
- hero/level/progress context moves below the focus/proof story;
- consistency, skill stats, and milestones remain secondary.

## Product behavior truth

- Product behavior changed: no.
- Data contracts changed: no.
- Repair selection changed: no.
- Engine decisions changed: no.
- Routes changed: no.
- Telemetry changed: no.
- Progress/completion semantics changed: no.

## Surface safety

- Modern Table untouched.
- Placement untouched in Step B.
- Welcome untouched in Step B.
- Home untouched.
- Learn untouched.
- Practice untouched.
- Runner decision/feedback/repair surfaces untouched in Step B.
- Review changed only in proof hierarchy order.
- Profile changed only in proof hierarchy order and a small focus label.

## Tests / checks

Planned validation:

- targeted Review tests;
- targeted Profile hierarchy tests;
- `dart format` on touched Dart/test files;
- `flutter analyze`;
- `git diff --check`;
- `git status --short`;
- `./tools/screen_review_fast_v1.sh first_week compact`.

## First-week packet artifact paths

Expected local-only output after validation:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Generated outputs must remain untracked and uncommitted.

## Remaining visual limitations

- Fast-renderer button-label white bars remain accepted.
- Completed placement result remains uncaptured.
- Dynamic personalized Profile repair-return reason remains uncaptured.
- This pass is not a broad visual redesign.

## Recommended next step

Package and push the Profile / Review proof hierarchy pass after local checks
are green, then proceed to the next visual-system slice from the full-surface
spec instead of expanding this pass.
