# Act0 RU Translation Workbook v1

Status: ACTIVE  
Scope: `Act0` canonical launch path in `/Users/elmarsalimzade/Sharky_1.0`

## Purpose

This workbook is the handoff document for a dedicated translation agent or
human translator.

It exists so translation quality work can happen outside the main coding loop,
then come back in a format that can be dropped into the stable-id copy seam
with minimal token cost.

RU editing rule:

- treat `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart` as the single Act0
  Russian data file
- do not patch Russian by hunting through screen files

## Canon

Read this first:

- `docs/l10n/RU_POKER_TERMS_CANON_v1.md`

Active copy seam:

- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- `docs/plan/ACT0_LOCALIZATION_FILE_MODEL_SSOT_v1.md`

Source content truth:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

Helper tools:

- `dart run tools/act0_content_copy_authoring_pack.dart --world world_X`
- `dart run tools/act0_translation_workbook_sync.dart --lang ru`
- `dart run tools/act0_content_copy_coverage_report.dart --lang ru`
- `dart run tools/act0_translation_pack_audit.dart --lang ru`
- `dart run tools/act0_translation_pack_ingest.dart --lang ru <pack files>`
- `dart run tools/act0_content_copy_priority_audit.dart --lang ru`
- `dart run tools/act0_content_copy_gap_audit.dart`
- `dart run tools/act0_copy_fit_audit.dart`

Generated world-pack docs:

- `docs/l10n/act0_world_packs/ACT0_RU_TRANSLATION_MASTER_v1.md`
- `docs/l10n/act0_world_packs/W##_world_X_RU_PACK_v1.md`

## Non-Negotiables

1. Translate by stable ids, not by visible English labels alone.
2. Use native Russian, not literal mirrored English syntax.
3. Keep learner-facing product tone:
   - calm
   - modern
   - compact
   - poker-literate
4. Do not introduce solver/admin wording.
5. Prefer accepted poker borrowings when natural:
   - `префлоп`
   - `рейз`
   - `колл`
   - `фолд`
   - `блайнды`
   - `кикер`
6. Keep copy short enough for mobile surfaces.
7. Never rename ids.
8. If landed RU sounds stiff, rewrite it in the world pack first. Do not patch UI-local strings as a shortcut.

## Return Format

Return translations in plain Markdown using this exact structure:

```md
## lesson <lessonId>
title_ru: ...
subtitle_ru: ...

- taskId: <taskId>
  title_ru: ...
  summary_ru: ...
  lockedSummary_ru: ...
  runnerPrompt_ru: ...
  runnerSupport_ru: ...
  runnerQuestion_ru: ...
```

Rules:

- Omit fields that are not present in the source pack.
- Keep ids unchanged.
- If improving an already-landed RU line, return the same id with the improved
  text.

## What Is Already Landed

These areas already have meaningful RU and should be preserved or improved
carefully, not retranslated blindly:

- world titles/subtitles: `world_1` through `world_12`
- launch-route surface atoms:
  - `Home`
  - `Play`
  - `Review`
  - `You`
- early `World 1` lesson/task copy around:
  - `what_poker_is`
  - `cards_ranks_suits`
  - `your_first_hand`
  - `fold_check_call_raise`
  - `blinds_action_order`
- `World 2` hand-discipline pack:
  - `hand_discipline_buckets`
  - `hand_discipline_apply`

If the translation agent wants to improve landed RU, that is allowed, but the
rewrite must remain:

- compact
- learner-facing
- more natural, not more verbose

## Accepted Current RU Snapshot

These current lines are already good enough to serve as style anchors:

### lesson hand_discipline_buckets

- `title_ru`: `Группы стартовых рук`
- `subtitle_ru`:
  `Сначала разложи руку по простой группе, а уже потом вкладывай фишки.`

### task hand_discipline_buckets_intro

- `title_ru`: `Четыре группы`
- `summary_ru`:
  `Перед действием сначала назови группу руки: премиум, сильная, средняя или мусор.`
- `runnerPrompt_ru`:
  `Сначала назови группу руки, а уже потом думай о действии.`
- `runnerSupport_ru`:
  `Этот первый фильтр убирает суету: премиум и сильные руки играются иначе, чем средние и мусорные.`
- `runnerQuestion_ru`: `Что лучше назвать до действия?`

### task apply_intro

- `title_ru`: `Привычка в три шага`
- `summary_ru`:
  `Группа руки, место и ситуация дают простую опору ещё до выбора действия.`
- `runnerPrompt_ru`:
  `Иди по порядку: группа руки, место, ситуация, потом действие.`
- `runnerSupport_ru`:
  `Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоят ли фишки входа.`
- `runnerQuestion_ru`: `Какой порядок здесь самый чистый?`

## Priority Translation Packs

These are the current highest-EV packs from `act0_content_copy_priority_audit`.

### Pack A: `world_1` visible learning path

Use:

```bash
dart run tools/act0_content_copy_authoring_pack.dart --world world_1 --max-lessons 3
```

Current extracted pack:

```md
# Act0 RU Authoring Pack

## world_1
EN title: Poker from Zero
EN subtitle: Table literacy: cards, seats, blinds, stack, and pot.

### lesson what_poker_is
EN title: What poker is
EN subtitle: Meet the table, the players, and the goal.

- taskId: what_poker_is_theory
  title: Meet the table
  summary: Get the basic layout: seats, chips, cards, and what the table is trying to decide.
  phase: theory
  stepKind: learn
  runner: _meetTableRunner
  caption: You are always the hero seat at the bottom.
  hint: Button, blinds, and your seat stay visible.
  question: Which seat is the hero seat?

- taskId: what_poker_is_find_hero
  title: Find your seat
  summary: Spot where Hero sits before anything else starts moving.
  phase: drill
  stepKind: practice
  runner: _findHeroSeatRunner
  caption: Your seat is marked as Hero.
  hint: Start every hand by finding your own cards and seat.
  question: Which seat is the hero seat?

- taskId: what_poker_is_pot_stack
  title: Pot and stack
  summary: Separate chips in the middle from chips still in a player stack.
  phase: drill
  stepKind: practice
  runner: _potStackRunner
  caption: Stack is your chips. Pot is what players fight for.
  hint: Do not mix your stack with the pot.
  question: Which label shows the chips in the middle?

- taskId: what_poker_is_win_ways
  title: How pots are won
  summary: See the two basic ways a hand ends: folds or showdown.
  phase: drill
  stepKind: practice
  runner: _winWaysRunner
  caption: You win when others fold or when your hand wins showdown.
  hint: Early lessons only need these two endings.
  question: Which is a way to win a pot?

- taskId: what_poker_is_showdown_win
  title: Win at showdown
  summary: Pick which hand wins once the cards are all face up.
  phase: drill
  stepKind: practice
  runner: _showdownBestHandRunner
  caption: At showdown, the best hand wins the pot.
  hint: Compare the final five-card hand.
  question: What decides a showdown?

- taskId: what_poker_is_table_read_transfer
  title: Real-table first read
  summary: Carry the first table scan into a live-looking spot: private cards, board, then pot.
  phase: drill
  stepKind: practice
  runner: _w1TableReadTransferRunner
  caption: Real table. Hero has two cards, flop has three board cards, pot is 6 BB.
  hint: Separate private cards, board cards, and pot before any action.
  question: What is the clean first table read?

- taskId: what_poker_is_review
  title: Table recap
  summary: Run the full table read once clean, from seat to pot to finish.
  phase: review
  stepKind: proveIt
  runner: _tableRecapRunner
  caption: Lesson learned: read the table before choosing.
  hint: Hero is you, opponents fight you, blinds create the first pot.
  question: What is the pot?
```

Continue the same way for:

- `cards_ranks_suits`
- `your_first_hand`

### Pack B: `world_3` position-apply spine

Use:

```bash
dart run tools/act0_content_copy_authoring_pack.dart --world world_3 --max-lessons 2
```

Current extracted pack:

```md
## world_3
EN title: Position Thinking
EN subtitle: See why seat order changes hand value and comfort.

### lesson position_apply
EN title: Position at the table
EN subtitle: Seat shapes the decision before anything else.

- taskId: position_apply_intro
  title: Position shapes action
  phase: theory
  stepKind: learn
  runner: _w3PositionApplyIntroRunner
  caption: Position tells you how comfortable a hand is before you act.
  hint: BTN is the best seat. UTG needs stronger hands to open. No charts needed yet.
  question: Why does position matter at the table?

- taskId: position_apply_btn_open
  title: BTN: open strong hand
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  caption: Folded to BTN with KTs.
  hint: First in and late position: opening is the clean action.
  question: What is the simple first-in action?

- taskId: position_apply_late_open
  title: Late: open or limp?
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  caption: Unopened pot. Hero is late with ATo.
  hint: Late position supports a clean open with this playable hand.
  question: What is the simple action?

- taskId: position_apply_early_fold
  title: Early: same hand folds
  phase: drill
  stepKind: fixMistakes
  runner: _world3PositionDisciplineRunner
  caption: Unopened pot. Hero is early with ATo.
  hint: The same hand is less comfortable from early position.
  question: What is the disciplined action?

- taskId: position_apply_hj_fold
  title: HJ: discipline hold
  phase: drill
  stepKind: fixMistakes
  runner: _world3PositionDisciplineRunner
  caption: Unopened pot. Hero is early with ATo.
  hint: The same hand is less comfortable from early position.
  question: What is the disciplined action?

- taskId: position_apply_recap
  title: Position apply recap
  phase: review
  stepKind: proveIt
  runner: _world3PositionRecapRunner
  caption: Lesson learned: position changes preflop comfort.
  hint: Late helps. Early demands stronger buckets and cleaner frames.
  question: What should you check after the bucket?
```

## Full Backlog Inventory

This is the current untranslated gap footprint inside the Act0 copy seam.

Snapshot from `tools/act0_content_copy_gap_audit.dart`:

- world ids missing: `0`
- lesson ids missing: `332`
- task ids missing: `303`

Use these tools to inspect the live backlog:

```bash
dart run tools/act0_content_copy_gap_audit.dart
dart run tools/act0_content_copy_priority_audit.dart
```

Working rule:

- do not translate all `332/303` blindly in one pass
- always start from the priority audit
- package translation by `world`

## Recommended Workflow With External Translation Agent

1. Run the authoring pack tool for one world.
2. Paste the pack plus this workbook into the translation agent.
3. Ask it for:
   - native Russian
   - compact mobile-safe lines
   - same ids
   - no solver/admin wording
4. Return the completed pack in the exact `title_ru / summary_ru / runner..._ru`
   format.
5. Feed that result back into the coding loop.
6. Then run:

```bash
dart run tools/act0_content_copy_priority_audit.dart
dart run tools/act0_copy_fit_audit.dart
```

7. After code integration, verify with focused Act0 tests.

## What To Avoid

- Translating directly from old donor docs
- Broad repo-wide translation sweeps
- Rewriting tone into long literary Russian
- Translating ids
- Replacing accepted poker terms with awkward literal Russian
- Making lines longer just because the English source is abstract

## Next Best Packs After A and B

Current next likely packs from priority audit:

- `world_5`
- `world_7`
- `world_8`
- `world_9`

But only after `world_1` and `world_3` are returned and integrated.
