# Mascot Consistency / Coach Identity v1

## Verdict

mascot_consistency_ready

## Claude audit finding addressed

The first-week feedback and repair surfaces used a local circular mascot badge
inside the lesson runner while the rest of Act0 used the shared Sharky presence
component. That made Sharky feel less consistent across feedback, repair, and
summary proof states.

## Mascot owner map

- Shared owner: `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
- Feedback / repair wrapper: `Act0SharkyMascotV1` in
  `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- Block completion / session summary: shared `Act0SharkyPresenceBubbleV1`
- Profile identity: already asset-backed and outside this implementation slice

## Root cause

The lesson runner had a second mascot renderer that wrapped the same PNG assets
inside a local cyan/blue circular badge. The shared presence renderer already
owned the canonical asset-backed Sharky treatment, but it did not expose stable
mood keys for focused tests.

## Implemented fix

- Added stable keys to the canonical `Act0SharkyPresenceMascotV1`.
- Changed the lesson-runner mascot wrapper to delegate rendering to
  `Act0SharkyPresenceMascotV1`.
- Preserved existing runner mascot wrapper keys and motion behavior so existing
  test and call-site contracts remain compatible.
- Removed the local duplicate mascot asset resolver from the runner.
- Added focused assertions for correct feedback, wrong feedback, and block
  completion to prove canonical Sharky presence is used.

## Surface coverage

- Correct feedback: canonical happy Sharky presence.
- Wrong feedback / repair cue: canonical repair Sharky presence.
- Block completion / session summary: canonical celebrate Sharky presence.
- Profile identity remains unchanged because it already uses an asset-backed
  Sharky treatment and this wave does not redesign Profile.

## Boundary proof

- No route, progression, telemetry, content, glossary, Modern Table, premium,
  AI/persona, or dashboard/economy behavior changed.
- No new mascot asset, mood, animation family, or onboarding behavior was added.
- No generated screenshot/output artifact is intended for commit.

## Screenshot/capture proof

Final local proof commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`

Expected local artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`

These artifacts are local-only evidence and must remain uncommitted.

## Tests / validation

Required validation for this wave:

- focused mascot / feedback / block-completion widget tests
- affected Sharky presence tests
- first-week and day-2 fast screen review packets
- `graphify hook-check`
- `flutter analyze`
- touched-file format check
- `git diff --check`
- `git status --short`

## Next recommended wave

If visual proof is accepted, move to the next scoped Claude UX v2 item. Do not
expand this wave into persona, onboarding, table visuals, or Profile evidence.
