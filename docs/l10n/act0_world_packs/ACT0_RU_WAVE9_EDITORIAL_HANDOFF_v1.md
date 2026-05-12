# ACT0 RU Wave 9 Editorial Handoff v1

Date: 2026-05-12
Scope: learner-facing `*_ru` fields only
Goal: move the current Act0 Russian from `95/100` toward launch-grade `100/100`

## What Changed Since Wave 8

- early-world coverage debt is already closed
- `world_11` transfer language is less worksheet-like
- `world_12` mindset/reset copy no longer leans on false-friend `сброс`
- `world_9` and `world_10` got a small humanization pass
- current work is now pure finish-pass editorial work, not coverage rescue

## Primary Files To Review

- [ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md)
- [RU_POKER_TERMS_CANON_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/RU_POKER_TERMS_CANON_v1.md)
- [ACT0_RU_TRANSLATION_WORKBOOK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/ACT0_RU_TRANSLATION_WORKBOOK_v1.md)
- [ACT0_RU_EDITORIAL_CALIBRATION_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_EDITORIAL_CALIBRATION_v1.md)

## Highest-EV Worlds For This Wave

1. `world_4`
Reason: still the softest restored world and the clearest place for a launch-grade tone upgrade.

2. `world_6`
Reason: coherent now, but board/draw teaching still wants a warmer first-user rhythm.

3. `world_7`
Reason: terminology is safe; the next gain is better pedagogy and cadence.

4. `world_8`
Reason: stable, but still slightly more mechanical than neighbouring worlds.

5. `world_9` and `world_10`
Reason: now understandable and safer, but still not fully premium-editorial in rhythm.

6. light final polish on the rest
Reason: `world_1-3` and `world_11-12` are no longer rescue zones; only finish work remains.

## Hard Rules

- Edit only `*_ru` fields.
- Do not change ids.
- Do not add or remove fields.
- Keep copy compact enough for mobile UI.
- Prefer calm product-coach Russian over training-manual, solver, or forum tone.
- Do not reintroduce `Hero`, `Villain`, `chip EV`, `risk premium`, `fold equity`, `bluff-catcher`, or false-friend `сброс` for emotional reset.

## Specific Risks To Catch

- range/combo lines that still sound translated rather than taught
- board/draw lines that explain instead of coach
- tournament lines that feel analytical instead of lived
- player-adjustment lines that still read like notes from a study review
- any repeated sentence skeletons that flatten neighboring tasks

## Output Wanted From External Editor

Return one fully edited file:
- `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`

Optional short note:
- top 20 still-questionable lines
- any terms intentionally kept closer to poker jargon and why

## Ready Prompt

```md
You are doing Wave 9 final-product Russian editing for Act0 in Sharky_1.0.

Goal: move the current Russian from 95/100 toward launch-grade 100/100.

Read first:
1. ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md
2. RU_POKER_TERMS_CANON_v1.md
3. ACT0_RU_TRANSLATION_WORKBOOK_v1.md
4. ACT0_RU_EDITORIAL_CALIBRATION_v1.md
5. ACT0_RU_WAVE9_EDITORIAL_HANDOFF_v1.md

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
4. world_8
5. world_9 and world_10
6. light polish on the rest

Style target:
- native Russian
- calm product-coach tone
- compact enough for mobile UI
- no training-manual or solver voice
- no wooden direct-calque syntax
- no false-friend `сброс` where the concept is emotional reset or fast mental restart

Return:
- the fully edited `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`
- optional short note with the 20 lines you still consider the weakest
```
