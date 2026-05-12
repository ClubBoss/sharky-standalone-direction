# ACT0 RU Wave 7 Editorial Handoff v1

Date: 2026-05-12
Scope: learner-facing `*_ru` fields only
Goal: move the current Act0 Russian from `93/100` toward launch-grade `100/100`

## What Changed Since Wave 6

- `world_1`, `world_2`, and `world_3` no longer have blank learner-facing `*_ru` fields.
- all early-world teaching steps are now covered in RU inside the pack layer.
- `world_4`, `world_6`, `world_7`, `world_9`, `world_10`, `world_11`, and `world_12` received another bounded cleanup pass.
- the next wave is now pure editorial improvement, not coverage rescue.

## Primary Files To Review

- [ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md)
- [RU_POKER_TERMS_CANON_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/RU_POKER_TERMS_CANON_v1.md)
- [ACT0_RU_TRANSLATION_WORKBOOK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/ACT0_RU_TRANSLATION_WORKBOOK_v1.md)
- [ACT0_RU_EDITORIAL_CALIBRATION_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_EDITORIAL_CALIBRATION_v1.md)

## Highest-EV Worlds For This Wave

1. `world_4`
Reason: structurally restored and readable, but still the clearest product-tone upgrade opportunity.

2. `world_6`
Reason: coherent now, but board/draw teaching can still sound warmer and less template-driven.

3. `world_7`
Reason: terminology is safe; next gains are pedagogy warmth, compactness, and table-natural phrasing.

4. `world_9`
Reason: tournament pressure is understandable, but still slightly technical and abstract.

5. `world_10`
Reason: player-adjustment copy is clean, yet some lines still sound like study notes rather than live coaching.

6. `world_11` and `world_12`
Reason: mindset/transfer blocks are coherent; remaining gains come from rhythm, emotional realism, and compactness.

7. `world_1` to `world_3`
Reason: coverage is no longer the problem. Only final launch-grade polish remains.

## Hard Rules

- Edit only `*_ru` fields.
- Do not change ids.
- Do not add or remove fields.
- Keep copy compact enough for mobile UI.
- Prefer calm product-coach Russian over forum slang, solver-speak, or training-manual tone.
- Early worlds must stay beginner-safe.
- Later worlds may be more advanced, but still must not sound like reg notes.

## Specific Risks To Catch

- phrases that are technically correct but still sound like translated worksheets
- repeated sentence skeletons across neighboring tasks
- lines that are too cold, too abstract, or too explanatory for learner-facing product copy
- places where later worlds still use more jargon than needed
- places where a shorter, warmer line would preserve meaning better than a literal translation

## Output Wanted From External Editor

Return one fully edited file:
- `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`

Optional short note:
- top 25 still-questionable lines
- any terms intentionally left closer to poker jargon and why

## Ready Prompt

```md
You are doing Wave 7 final-product Russian editing for Act0 in Sharky_1.0.

Goal: move the current Russian from 93/100 toward launch-grade 100/100.

Read first:
1. ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md
2. RU_POKER_TERMS_CANON_v1.md
3. ACT0_RU_TRANSLATION_WORKBOOK_v1.md
4. ACT0_RU_EDITORIAL_CALIBRATION_v1.md
5. ACT0_RU_WAVE7_EDITORIAL_HANDOFF_v1.md

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
7. world_1 to world_3 only for final polish

Style target:
- native Russian
- calm product-coach tone
- compact enough for mobile UI
- beginner-safe in early worlds
- no solver/admin/forum voice
- no wooden direct-calque sentence structure

Return:
- the fully edited `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`
- optional short note with the 25 lines you still consider the weakest
```
