# ACT0 RU Wave 5 Editorial Handoff v1

Date: 2026-05-12
Scope: learner-facing `*_ru` fields only
Goal: push Act0 Russian from `90/100` toward launch-grade `100/100`

## What Changed Since Wave 4

- `world_4` and `world_6` were not missing content after all.
- Their lesson/task content existed in `act0_shell_state_v1.dart` and has now been restored into the translation pipeline.
- Both worlds now have full RU draft packs and are ready for editorial improvement.

## Primary Files To Review

- [ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md)
- [RU_POKER_TERMS_CANON_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/RU_POKER_TERMS_CANON_v1.md)
- [ACT0_RU_TRANSLATION_WORKBOOK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/ACT0_RU_TRANSLATION_WORKBOOK_v1.md)
- [ACT0_RU_EDITORIAL_CALIBRATION_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_EDITORIAL_CALIBRATION_v1.md)

## Highest-EV Worlds For This Wave

1. `world_4`
Reason: newly restored, full draft exists, but still needs a true product-editorial pass.

2. `world_6`
Reason: newly restored, strong draft base, but board/draw teaching can still become warmer and more natural.

3. `world_7`
Reason: terminology is now clean; remaining gains are style and pedagogy.

4. `world_9`
Reason: tournament language is safer now, but still more technical than early learner worlds.

5. `world_10`
Reason: player-adjustment copy is clean enough to polish, but still slightly study-note-like.

6. `world_11` and `world_12`
Reason: mindset/session loops are now coherent; next gains come from rhythm and compactness.

## Hard Rules

- Edit only `*_ru` fields.
- Do not change ids.
- Do not add or remove fields.
- Keep copy compact enough for mobile UI.
- Prefer calm product-coach Russian over forum slang or solver language.
- Early worlds must stay beginner-safe.
- Later worlds may be more advanced, but still must not read like reg notes.

## Specific Risks To Catch

- residual stiffness from direct English sentence structure
- repeated title verbs that feel mechanical
- explanation walls that can be shortened without losing clarity
- places where poker vocabulary is correct but still too cold for product copy
- places where the same concept can be explained more simply

## Output Wanted From External Editor

Return one fully edited file:
- `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`

Optional short note:
- top 20 still-questionable lines
- any terms intentionally left in English and why

## Ready Prompt

```md
You are doing Wave 5 final-product Russian editing for Act0 in Sharky_1.0.

Goal: move the current Russian from strong draft quality to launch-grade product quality.

Read first:
1. ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md
2. RU_POKER_TERMS_CANON_v1.md
3. ACT0_RU_TRANSLATION_WORKBOOK_v1.md
4. ACT0_RU_EDITORIAL_CALIBRATION_v1.md
5. ACT0_RU_WAVE5_EDITORIAL_HANDOFF_v1.md

Task:
- edit only `*_ru` fields
- do not change ids
- do not change markdown structure
- do not add comments inside the export
- do not rewrite English source fields

Priorities:
1. world_4
2. world_6
3. world_7
4. world_9
5. world_10
6. world_11 and world_12

Style target:
- native Russian
- calm product-coach tone
- compact enough for mobile UI
- beginner-safe in early worlds
- no solver/admin/forum voice
- no wooden direct-calque sentence structure

Return:
- the fully edited `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`
- optional short note with the 20 lines you still consider the weakest
```
