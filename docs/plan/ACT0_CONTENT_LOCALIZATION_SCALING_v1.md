# Act0 Content Localization Scaling v1

## Purpose

This file defines the cheap, scalable path for Act0 content copy so Russian launch quality and future world growth do not require repeated shell rewrites.

## Current rule

- Content truth can stay authored in `act0_shell_state_v1.dart`.
- Learner-facing display copy must not be localized by scattering raw-string switches across multiple surfaces.
- Surface owners should read display copy through one reusable content-copy seam.

## Canonical seam

- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`

This seam owns:

- world title localization by `worldId`
- world subtitle localization by `worldId`
- lesson title localization by `lessonId`
- lesson subtitle localization by `lessonId`
- title-atom fallback for routed recommendation text

## Stable key policy

Use stable IDs, not visible English strings, as the scaling truth:

- world: `worldId`
- lesson: `lessonId`
- task: `taskId`
- placement question/result: explicit placement ids if/when these move into the same seam

Visible English strings may stay in authored content as fallback, but localization and future reuse should key off IDs.

## Launch-first migration rule

Do not migrate every content surface at once.

Priority order:

1. launch-path worlds
2. launch-path lesson titles and subtitles
3. placement/recommendation atoms
4. task titles and summaries
5. deeper world content

This keeps the wave cheap and avoids reopening unrelated test families.

## Test-safety rule

- Visible display text may localize.
- Existing contract keys based on current English lesson titles may remain temporarily if changing them would create broad test churn.
- When key migration becomes worth it, move keys to `lessonId` and `taskId` in a dedicated bounded wave.

## World 13+ rule

When new worlds are added:

1. add authored content to the state/content source
2. add display-copy entries to `act0_content_copy_v1.dart`
3. do not patch each surface individually

The shell should keep reading through the same content-copy seam.

## Token-economy rule

For future localization/content expansion:

- extend copy maps by id
- avoid duplicate translation switches in multiple screens
- prefer one owner seam over many ad hoc string patches
- migrate task-level copy only when that content becomes visible on the active launch path
