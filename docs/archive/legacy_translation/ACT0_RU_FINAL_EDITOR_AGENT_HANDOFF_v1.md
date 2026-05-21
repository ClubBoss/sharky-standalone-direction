# ACT0 RU Final Editor Agent Handoff v1

Status: ready for full `world_1` through `world_12` editorial pass  
Goal: move Act0 Russian localization from strong draft / cleanup state to `100/100` launch-grade product Russian  
Scope: learner-facing RU copy only

## Package To Send

Send these files together:

1. [ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md:1)
2. [RU_POKER_TERMS_CANON_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/RU_POKER_TERMS_CANON_v1.md:1)
3. [ACT0_RU_TRANSLATION_WORKBOOK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/ACT0_RU_TRANSLATION_WORKBOOK_v1.md:1)
4. [ACT0_RU_EDITORIAL_CALIBRATION_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_EDITORIAL_CALIBRATION_v1.md:1)
5. This file: [ACT0_RU_FINAL_EDITOR_AGENT_HANDOFF_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/ACT0_RU_FINAL_EDITOR_AGENT_HANDOFF_v1.md:1)

## What The Agent Is Editing

- Edit only `*_ru` fields inside the consolidated export.
- Do not change ids.
- Do not edit any `*_en` field.
- Do not add or remove fields.
- Do not change structure, markdown headers, lesson order, task order, or metadata.

## Product Goal

We want Russian copy that feels:

- native
- calm
- product-grade
- table-literate
- beginner-safe in early worlds
- clean and compact on mobile

This is not a forum hand-history translation.
This is not solver-note Russian.
This is not admin/curriculum prose.

It should feel like a strong in-product coach teaching poker clearly, naturally, and without showing internal tooling language.

## Hard Rules

1. Keep all ids unchanged.
2. Edit only learner-facing `*_ru` fields.
3. Preserve meaning from English, but do not mirror English sentence shape.
4. Prefer direct, natural Russian over literal poker-English calques.
5. Keep lines compact enough for mobile UI.
6. Use poker terms only when they genuinely help the learner.
7. Do not introduce bureaucratic, academic, or solver-style tone.
8. Do not make copy longer unless the shorter version would be unclear.

## Canonical Terminology Policy

### `Hero`

Preferred default:

- `ты`
- `у тебя`
- `твоё место`
- `игрок снизу`

Allowed exception:

- keep `Hero` only where the UI literally shows a visible `Hero` label and the learner is being taught what that label means

Avoid:

- `Хиро` as default product wording
- overusing `Hero` in prompts, supports, and questions after the concept is already introduced

### `Villain`

Use:

- `соперник`
- `оппонент`
- `другой игрок`

Do not leave `Villain` in learner-facing RU.

### Technical/pro-study terms that must not remain raw in learner-facing RU

Replace these when they appear in RU fields:

- `chip EV`
- `risk premium`
- `fold equity`
- `bluff-catcher`
- `exploit`
- `suited`
- `offsuit`
- `full ring`
- `made hand`

Preferred replacement directions:

- `chip EV` -> `ценность фишек`, `выгодность в фишках`
- `risk premium` -> `цена риска`, `надбавка за риск вылета`, `цена вылета`
- `fold equity` -> `шанс забрать банк пасом соперника`
- `bluff-catcher` -> `рука для колла против блефа`
- `exploit` -> `подстройка`, `план против такого соперника`, `использовать привычку соперника`
- `suited` -> `одномастные`
- `offsuit` -> `разномастные`
- `full ring` -> `полный стол`, `стол на 9 игроков`
- `made hand` -> `готовая рука`

### Range-language policy

Do not use `корзина/корзины` as the main learner-facing pedagogy term.

Prefer:

- `группа`
- `тип руки`
- `категория`

depending on context.

### Leak-language policy

Do not use mistranslations like `течёт` for gameplay leaks.

Prefer:

- `лик`
- `слабое место`
- `ошибка, которая повторяется`
- `стоит фишек`

## Tone Rules By World Stage

### Worlds 1-3

- maximum beginner clarity
- minimal jargon
- explain visible table labels once, then switch to natural Russian
- short and calm

### Worlds 5-8

- still product-coach tone
- can use standard poker vocabulary
- avoid textbook rhythm and “translated study guide” feel

### Worlds 9-12

- concepts may be more advanced
- wording must still sound like coaching inside an app, not like a reg writing notes to another reg
- keep tournament and player-adjustment language human, not solver-ish

## Editorial Quality Bar

For every edited line, the agent should ask:

1. Would a Russian-speaking learner understand this immediately?
2. Does this sound like native Russian, not translated English?
3. Is there one clear idea in the line?
4. Is this compact enough for mobile?
5. Does this avoid internal/game-study/tooling language?
6. If a technical term remains, is it either standard poker notation or gently explained?
7. Does the line help a learner act, notice, or understand?

## Priority Attention Areas

Even though the full export should be reviewed, these families deserve extra attention:

1. `world_7`
Reason: range pedagogy still risks sounding translated/study-like.

2. `world_9`
Reason: tournament pressure concepts can drift into technical jargon fast.

3. `world_10`
Reason: player-adjustment copy can still sound like study notes instead of coaching.

4. `world_1` to `world_3`
Reason: these are close to good, but they need final polish because they shape first-user trust.

## Desired Output Format From The External Agent

Return exactly one edited file:

- the same `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`

Optional second file:

- a short review note with only:
  - top 10 lines still questionable
  - any intentional uses of `Hero`
  - any terms the agent believes should remain in English poker notation

Do not return long essays unless asked.

## Prompt To Send

```md
You are doing the final Russian editorial pass for Act0 in Sharky_1.0.

Your target is not “acceptable translation”.
Your target is `100/100` launch-grade product Russian.

Read these files first, in order:
1. ACT0_RU_FINAL_EDITOR_AGENT_HANDOFF_v1.md
2. RU_POKER_TERMS_CANON_v1.md
3. ACT0_RU_EDITORIAL_CALIBRATION_v1.md
4. ACT0_RU_TRANSLATION_WORKBOOK_v1.md
5. ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md

Task:
- edit only `*_ru` fields inside the consolidated export
- keep all ids unchanged
- do not edit any `*_en` fields
- do not add or remove fields
- do not alter markdown structure

Quality target:
- native Russian
- product-grade
- calm coaching voice
- beginner-safe in early worlds
- compact enough for mobile
- no solver/admin/forum translation vibe

Important policy:
- Prefer `ты`, `у тебя`, `твоё место` over `Hero`, except where `Hero` is a literal visible UI label that must be explained
- Replace `Villain` with `соперник` / `оппонент`
- Do not leave raw learner-facing RU terms like:
  `chip EV`, `risk premium`, `fold equity`, `bluff-catcher`, `exploit`, `suited`, `offsuit`, `full ring`, `made hand`
- Do not use `корзины диапазона` as the main learner-facing term
- Do not use mistranslation like `течёт` for gameplay leaks

What we want:
- no English-shaped sentence structure
- no bureaucratic training-copy tone
- no forum-hand-history awkwardness
- no overexplaining
- no unnecessary length growth

World-specific attention:
- `world_7`: make range language sound native and teachable
- `world_9`: humanize tournament pressure
- `world_10`: remove study-note / exploit-heavy vibe
- `world_1-3`: final trust-building polish for first-user path

How to judge each line:
1. Would a Russian-speaking learner understand this immediately?
2. Does it sound like native Russian?
3. Is it compact enough for mobile?
4. Does it sound like a real product coach?
5. If a poker term remains, is it either standard notation or gently explained?

Return:
- the fully edited `ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`
- optionally a very short note with:
  - top 10 still-questionable lines
  - any intentional remaining `Hero` uses and why
```

## Success Definition

We consider the external pass successful if:

- the export is still structurally valid
- `*_ru` fields are materially more native
- early worlds feel launch-grade
- `world_7`, `world_9`, `world_10` feel less translated / less study-like
- there is no obvious learner-facing English/pro leakage left
