# Home De-dupe / Reward Hierarchy v1

## Verdict

home_dedupe_reward_hierarchy_ready

## Claude audit finding addressed

Home could show the same current lesson/action in both the hero card and the
below-hero Learn row. That made the route feel like two competing next actions
instead of one primary action plus supporting status.

## Home owner map

- Home surface owner: `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- Primary action owner: `_HomeMissionCommandCardV1`
- Below-hero sequence owner: `_HomeChecklistSurfaceV1`
- Row rendering owner: `_HomeChecklistRowTileV1`
- Focused proof: `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## Implemented hierarchy changes

- The hero remains the only owner of the current lesson title and primary CTA.
- The below-hero list title now frames the area as `Today's sequence`.
- The Learn row now reads as neutral route status:
  - `Learning path`
  - `Current lesson is above.`
- The Learn row no longer exposes a duplicated continue tap target.
- Practice and Review rows keep their existing safe owned-tab affordances.

## Primary CTA ownership

The single primary Home CTA remains `act0_shell_main_cta` inside the hero card.
It preserves the existing `onContinue` route behavior and availability.

## Reward/XP hierarchy decision

No new reward or XP treatment was added. The Home hero continues to lead with
the learning action, while XP/progress chrome remains outside this Home
checklist hierarchy and secondary to the route action.

## Route/progression truth proof

- No new Home data model or recommendation system was added.
- No route/progression mutation changed.
- Current lesson/world/repair truth still comes from existing `Act0ShellStateV1`
  and existing daily-plan job inputs.
- Repair urgency is not hidden or fabricated; this wave only prevents the Learn
  row from duplicating the hero's current lesson action.

## Boundary proof

- No Profile, Review history, Practice recommendation expansion, Learn route,
  telemetry, content, glossary, Modern Table, premium/paywall, AI/persona,
  mastery/leak/GTO/solver, or dashboard/economy change.
- No generated screenshot/output artifact is intended for commit.

## Screenshot/capture proof

Final local proof commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh core compact`

Expected local artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/contact_sheet.png`

These artifacts are local-only evidence and must remain uncommitted.

## Tests / validation

Required validation for this wave:

- focused Home shell tests
- first-week and core fast screenshot packets
- `graphify hook-check`
- `flutter analyze`
- touched-file format check
- `git diff --check`
- `git status --short`

## Next recommended wave

If the Home proof is accepted, run a gated push for this local commit, then
continue with the next Claude UX/UI v2 safe-now cleanup item.
