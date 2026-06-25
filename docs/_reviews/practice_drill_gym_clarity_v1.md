# Practice Drill Gym Clarity v1

## 1. Verdict

practice_drill_gym_clarity_ready

## 2. Wave 2 scope finding addressed

Claude UX/UI v2 Wave 2 selected Practice as the first safe-now target because
the screen had a useful daily-drill hero, but the lower `Skill packs` area still
read like a locked wall or placeholder. This pass reframes that lower area as
route-backed topic practice without changing availability or behavior.

## 3. Practice owner map

- Practice surface owner:
  `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- Practice shell tests:
  `test/ui_v2/act0_play_shell_v1_test.dart`
- Affected Act0 preview tests:
  `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Primary daily action owner:
  `_DailyTrainingHeroV1`
- Repair empty state owner:
  `_PlayRepairEmptyCardV1`
- Topic-rep preview owner:
  `_SkillPacksPreviewV1`
- Topic tile owner:
  `_SkillPackPreviewCardV1`
- Locked-summary owner:
  `_LockedPacksSummaryV1`

Internal class names were left unchanged to avoid broad churn; the visible
surface copy now describes the area as topic reps.

## 4. Implemented hierarchy/copy changes

- Kept the daily drill hero as the primary Practice action.
- Preserved the honest no-repair state:
  `Nothing to repair right now.`
- Changed the no-repair support copy from skill-pack phrasing to:
  `Topic reps stay ready for extra practice areas.`
- Renamed the lower visible section from:
  `Skill packs`
  to:
  `Topic reps`
- Replaced the unlock-wall hint:
  `Topic reps unlock as your route grows.`
  with:
  `Focused reps open as your route grows.`
- Replaced the locked summary with route-backed practice copy:
  `More practice areas open with the route`
  and
  `Finish lessons to open more focused reps.`
- Replaced lock glyphs in disabled topic previews / summary with route glyphs
  so the area reads as future route-backed practice rather than a hard lockwall.

## 5. Daily drill hero proof

The daily drill remains the hero and keeps its existing CTA behavior:

- hero key: `act0_shell_play_daily_hero`
- CTA key: `act0_shell_play_featured_cta`
- visible hero title: `Quick daily drill`
- primary CTA: `Start daily set`

The focused Practice test confirms tapping the hero CTA still starts the
`daily` practice group.

When a repair group exists, the current accepted behavior is preserved: daily
drill stays primary and repair remains a secondary Practice reinforcement lane.

## 6. Locked-pack / topic-rep boundary proof

This pass does not unlock packs or create new availability. Disabled topic
tiles remain non-tappable:

- disabled topic group taps do not call `onStartGroup`;
- enabled topic group taps still call `onStartGroup`;
- disabled hidden source subtitles such as `Clear it on the route first.` do
  not leak into the compact preview;
- no fake `0/12`, `Later`, or disabled CTA promise is exposed in the topic
  preview.

The visible language now says topic reps open as the route grows, not that the
learner can buy, claim, or immediately unlock them.

## 7. Route/progression truth proof

- No new Practice state was added.
- No route/progression mutation changed.
- No daily drill launch behavior changed.
- No repair behavior changed.
- No topic group availability logic changed.
- No Learn/Home/Review/Profile surface code changed.
- Existing `Act0PracticeGroupV1.isEnabled` remains the source of topic
  availability truth.

## 8. Forbidden-claim proof

The Practice copy added in this pass does not introduce:

- premium, paywall, trial, or purchase language;
- `recommended for you`;
- `based on your mistakes`;
- AI, leak, mastery, GTO, solver, or personalization claims;
- Review history;
- repair queue claims;
- new content or route promises beyond existing route growth.

Focused tests assert the absence of the most sensitive recommendation,
personalization, and premium/paywall phrases in the Practice preview.

## 9. Screenshot/capture proof

Required local proof commands:

- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Expected local artifacts:

- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/screen_review_core_fast.zip`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated screenshot packets are local-only evidence and must remain
uncommitted.

## 10. Tests / validation

Required validation for this local wave:

- focused Practice shell tests;
- affected Act0 shell preview tests;
- `./tools/screen_review_fast_v1.sh core compact`;
- `./tools/screen_review_fast_v1.sh first_week compact`;
- `./tools/screen_review_fast_v1.sh full_scroll compact`;
- `graphify hook-check`;
- `flutter analyze`;
- touched-file format check only;
- `git diff --check`;
- `git status --short`.

## 11. Next recommended wave

Run a gated push for `Practice Drill Gym Clarity v1` after validation. Then run
a new Wave 2 evidence review before selecting between:

1. Learn Route Numbering / Arc Clarity v1;
2. Onboarding Handoff Simplification v1;
3. Review Compact Honest Shell v1.

Learn remains the likely next high-EV target, but it should stay route-truth
bounded because W11/W12 are planned-only and W13+ is frontier-only.
