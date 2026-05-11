# Act0 Execution Snapshot 2026-05-11 v1

Status: ACTIVE SNAPSHOT

Purpose: preserve the current Act0 product route, landed waves, remaining
residue, and the next best execution order so future sessions can continue
without reconstructing context from chat history.

## 1. Current Product Read

Act0 is no longer just a detached prototype shell.

The active route now behaves like one coherent product mechanism:

- `Placement` routes and sets trust
- `Home` dispatches
- `Learn` owns the canonical path
- `Play` is a secondary optional branch
- `Review` is repair-first
- `You` is identity-first
- `Table -> Feedback -> Result` is compressed into a cleaner core loop

The current app is much closer to a launch-grade learning product than to a
UI exploration shell.

## 2. Landed Waves

### Surface role and flow waves

- `Home / Learn / Play` role clarification landed
- `Review` simplification landed
- `You` compression landed
- `Learn` moved from zigzag feel toward a clearer centered spine
- lesson open choreography was fixed to `scroll first, then open`

### Core loop waves

- `Table Core Compression` landed
- `Feedback Verdict Simplification` landed
- `Result As Pure Handoff` landed
- immediate mistake repair plus end-of-lesson retry loop landed

### Product feel waves

- `Sharky Motion + Presence System` landed
- `Visual Premium Pass` landed
- `Habit Loop Deepening` landed
- `Placement` trust/premium/value-first routing landed
- value-first premium preview landed without hard pressure

### Russian route waves

- RU foundation landed
- active shell primary RU pass landed
- preview/state RU pass landed
- dev preview RU/EN switcher landed

### Content scaling wave

- content localization scaling foundation landed
- canonical seam: `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- policy doc: `docs/plan/ACT0_CONTENT_LOCALIZATION_SCALING_v1.md`

## 3. What The New Content Seam Solves

The product should not localize or scale content by scattering raw-string
switches across multiple surfaces.

The current content-copy seam now owns:

- world title localization by `worldId`
- world subtitle localization by `worldId`
- lesson title localization by `lessonId`
- lesson subtitle localization by `lessonId`
- title-atom fallback for routed recommendation text

This means:

- future worlds `13+` can be added by extending one seam
- RU display copy no longer requires repeated shell surgery
- launch-path display copy can improve without destabilizing core state

## 4. Honest Residue

The biggest remaining localization/content residue is not shell chrome anymore.

It is deeper visible authored copy:

- task titles on the active launch path
- task summaries on the active launch path
- runner prompt/support lines still authored in English
- deeper `Review` / `You` / `Play` detail copy
- result/support copy that still comes from authored atoms outside the new seam

The current seam is intentionally launch-first, not full-depth:

- all 12 world titles/subtitles are covered
- launch-path lesson titles/subtitles are covered
- deeper task-level content is not fully migrated yet

## 5. Next Best Wave Order

### Wave A: RU Wave 4

Priority: highest

Goal:

- localize deeper visible launch-path content, not just shell surfaces

In:

- task titles
- task summaries
- runner-facing prompt/support text on the active launch path
- deeper `Review` / `Play` / `You` visible detail copy where it is actually seen

Stop rule:

- do not mass-translate archive, legacy, or inactive deep content just for
  coverage optics

### Wave B: RU Core Loop Completion

Goal:

- finish the Russian feel in `Table / Feedback / Result`

Use after Wave A if deeper shell/detail copy is no longer the main visible
English residue.

### Wave C: ID-Key Migration Only If Worth It

Goal:

- migrate lesson/task test keys from visible English titles to `lessonId` /
  `taskId`

Only do this in a dedicated bounded wave if the current title-based keys start
blocking real product movement.

### Wave D: Final Russian Editorial Pass

Goal:

- repetition cleanup
- tone alignment
- CTA consistency
- small-screen readability
- final launch-path QA

## 6. Rules For World 13+

When new worlds are added:

1. add authored content to the content/state source
2. add display-copy entries to `act0_content_copy_v1.dart`
3. do not patch each surface individually

If a future world becomes launch-visible, extend the same seam first before
editing multiple screens.

## 7. Verification Floor

Default proof floor for bounded Act0 waves:

- `dart format`
- `flutter analyze`
- one or more focused `act0_shell_preview_screen_v1_test.dart` contracts
- `git diff --check`

Run Flutter verification sequentially to avoid the startup lock.

## 8. Recommended New-Chat Start

When continuing in a fresh chat:

1. read `docs/plan/MASTER_PLAN_v3.0.md`
2. read `docs/plan/ACT0_EXECUTION_SNAPSHOT_2026_05_11_v1.md`
3. read `docs/plan/RUSSIAN_LOCALIZATION_ROLLOUT_v1.md`
4. read `docs/plan/ACT0_CONTENT_LOCALIZATION_SCALING_v1.md`
5. continue with one bounded wave only
