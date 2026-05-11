# world_7 RU Translation Pack

Status: GENERATED
World number: 7
EN title: Range Thinking Lite
EN subtitle: Group hands into simple buckets without solver talk.
title_ru: Диапазоны без перегруза
subtitle_ru: Группируй руки в простые диапазоны без солверного шума.

## Coverage
- Lessons: 0/5
- Tasks: 0/27
- Runner prompts: 0/27
- Runner supports: 0/27
- Runner questions: 0/27

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson range_bucket_basics
status: missing
title_en: Range buckets
subtitle_en: Sort hands into value, bluff candidate, and missed buckets.
title_ru: 
subtitle_ru: 

- taskId: w6_range_intro
  status: missing
  title_en: Three buckets
  phase: theory
  stepKind: learn
  runner: _w6RangeIntroRunner
  runnerPrompt_en: A range is the group of hands that fit a situation.
  runnerSupport_en: Value, bluff candidate, and missed are the three range buckets.
  runnerQuestion_en: What are range buckets?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_value_dry_board
  status: missing
  title_en: Value on dry board
  phase: drill
  stepKind: practice
  runner: _w6ValueDryBoardRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q.
  runnerSupport_en: Top pair with the best possible kicker.
  runnerQuestion_en: Which range bucket is K-Q on this board?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_missed_dry_board
  status: missing
  title_en: Missed on dry board
  phase: drill
  stepKind: practice
  runner: _w6MissedDryBoardRunner
  runnerPrompt_en: Same K-7-2 rainbow. Hero holds J-T.
  runnerSupport_en: No pair, no draw on a dry board.
  runnerQuestion_en: Which range bucket is J-T on this board?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_table_bucket_notice
  status: missing
  title_en: First live read
  phase: drill
  stepKind: practice
  runner: _w6TableBucketNoticeRunner
  runnerPrompt_en: Real table. K-7-2 rainbow lands and you hold A-Q.
  runnerSupport_en: Before picking a size, make the first useful read.
  runnerQuestion_en: What should you ask first?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_buckets_recap
  status: missing
  title_en: Buckets recap
  phase: review
  stepKind: review
  runner: _w6BucketsRecapRunner
  runnerPrompt_en: Lesson learned: range buckets start with board fit.
  runnerSupport_en: Ask which bucket before choosing an action.
  runnerQuestion_en: Which range bucket reads the board first?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson range_board_fit
status: missing
title_en: Range meets board
subtitle_en: Board texture can shift a hand from value to missed.
title_ru: 
subtitle_ru: 

- taskId: w6_board_fit_intro
  status: missing
  title_en: Board shifts bucket
  phase: theory
  stepKind: learn
  runner: _w6BoardFitIntroRunner
  runnerPrompt_en: Board texture can shift a hand from value to missed.
  runnerSupport_en: The same hand can be value on one board and missed on another.
  runnerQuestion_en: What changes a hand's range bucket?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_wrong_board
  status: missing
  title_en: Missed on wet board
  phase: drill
  stepKind: practice
  runner: _w6WrongBoardRunner
  runnerPrompt_en: 8-7-6 two-tone. Hero holds K-Q.
  runnerSupport_en: K-Q was strong preflop, but this board changed everything.
  runnerQuestion_en: Which range bucket is K-Q on 8-7-6?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_value_wet_board
  status: missing
  title_en: Value on wet board
  phase: drill
  stepKind: practice
  runner: _w6ValueWetBoardRunner
  runnerPrompt_en: Same 8-7-6 two-tone. Hero holds 9-8.
  runnerSupport_en: 9-8 flopped two pair on a connected board.
  runnerQuestion_en: Which range bucket is 9-8 on 8-7-6?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_turn_shift_bucket
  status: missing
  title_en: Turn changes bucket
  phase: drill
  stepKind: practice
  runner: _w6TurnShiftBucketRunner
  runnerPrompt_en: Flop gave you a bluff candidate. Turn bricks and pairs the board.
  runnerSupport_en: When pressure drops, the bucket can slide.
  runnerQuestion_en: What often happens to the hand now?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_board_fit_recap
  status: missing
  title_en: Board fit recap
  phase: review
  stepKind: review
  runner: _w6BoardFitRecapRunner
  runnerPrompt_en: Lesson learned: the same hand hits different buckets on different boards.
  runnerSupport_en: Always read the board before assigning a bucket.
  runnerQuestion_en: What decides which bucket a hand lands in?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson range_pressure_lines
status: missing
title_en: Value, bluff, missed
subtitle_en: Each bucket suggests a different action direction.
title_ru: 
subtitle_ru: 

- taskId: w6_pressure_lines_intro
  status: missing
  title_en: Bucket shapes action
  phase: theory
  stepKind: learn
  runner: _w6PressureLinesIntroRunner
  runnerPrompt_en: Each range bucket suggests a different action direction.
  runnerSupport_en: Value bets to get called. Bluff candidates can bet to fold out better hands.
  runnerQuestion_en: What does a value hand do?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_value_range_action
  status: missing
  title_en: Value bets
  phase: drill
  stepKind: practice
  runner: _w6ValueRangeActionRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q. You are in the value range.
  runnerSupport_en: Value hands want to build the pot.
  runnerQuestion_en: What does K-Q do here?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_bluff_candidate
  status: missing
  title_en: Bluff candidate
  phase: drill
  stepKind: practice
  runner: _w6BluffCandidateRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds A-Q.
  runnerSupport_en: Two overcards, no pair. Some fold equity exists.
  runnerQuestion_en: Which range bucket is A-Q here?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_missed_hand_action
  status: missing
  title_en: Missed hand direction
  phase: drill
  stepKind: practice
  runner: _w6MissedHandActionRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds J-T with no draw.
  runnerSupport_en: Pure missed hands usually do not want a big pot.
  runnerQuestion_en: What is the clean action direction?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_wet_board_repair
  status: missing
  title_en: Repair wet-board read
  phase: drill
  stepKind: fixMistakes
  runner: _w6WetBoardRepairRunner
  runnerPrompt_en: Turn card connected the board, but hero still treats one pair like the flop stayed dry.
  runnerSupport_en: Repair the board read before forcing the same old action.
  runnerQuestion_en: What needs fixing first?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_pressure_lines_recap
  status: missing
  title_en: Pressure recap
  phase: review
  stepKind: review
  runner: _w6PressureLinesRecapRunner
  runnerPrompt_en: Lesson learned: bucket decides the action direction.
  runnerSupport_en: Value bets. Bluff candidates can bet or fold. Missed usually folds.
  runnerQuestion_en: What does each range bucket suggest?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson range_combo_counts
status: missing
title_en: Count the combos
subtitle_en: AK has 16 combos. A pocket pair has 6.
title_ru: 
subtitle_ru: 

- taskId: w6_combo_counts_intro
  status: missing
  title_en: Why combo counts matter
  phase: theory
  stepKind: learn
  runner: _w6ComboCountsIntroRunner
  runnerPrompt_en: Ranges are not just hand names. They also have combo counts.
  runnerSupport_en: More combos means that hand family appears more often in a range.
  runnerQuestion_en: Why do combo counts matter?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_ak_combos
  status: missing
  title_en: AK combo count
  phase: drill
  stepKind: practice
  runner: _w6AkComboRunner
  runnerPrompt_en: A-K can be suited or offsuit.
  runnerSupport_en: Four aces can pair with four kings.
  runnerQuestion_en: How many combos does A-K have before blockers?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_pair_combos
  status: missing
  title_en: Pocket pair combo count
  phase: drill
  stepKind: practice
  runner: _w6PairComboRunner
  runnerPrompt_en: Pocket eights are one pair family.
  runnerSupport_en: You pick 2 suits out of the 4 eights in the deck.
  runnerQuestion_en: How many combos does 8-8 have?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_combo_weight_compare
  status: missing
  title_en: Which family appears more?
  phase: drill
  stepKind: practice
  runner: _w6ComboWeightCompareRunner
  runnerPrompt_en: Compare A-K with pocket eights before blockers.
  runnerSupport_en: One family has 16 combos. The other has 6.
  runnerQuestion_en: Which family appears more often in a range?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w6_combo_counts_recap
  status: missing
  title_en: Combo recap
  phase: review
  stepKind: review
  runner: _w6ComboCountsRecapRunner
  runnerPrompt_en: Lesson learned: combo counts measure how often a hand family appears.
  runnerSupport_en: A-K = 16 combos. A pocket pair = 6 combos.
  runnerQuestion_en: What do combo counts help you measure?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson range_thinking_checkpoint
status: missing
title_en: Range thinking checkpoint
subtitle_en: Bucket, board fit, combo count, then pressure.
title_ru: 
subtitle_ru: 

- taskId: range_checkpoint_intro
  status: missing
  title_en: Three-step read
  phase: theory
  stepKind: learn
  runner: _w6RangeIntroRunner
  runnerPrompt_en: A range is the group of hands that fit a situation.
  runnerSupport_en: Value, bluff candidate, and missed are the three range buckets.
  runnerQuestion_en: What are range buckets?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: range_checkpoint_value
  status: missing
  title_en: Value on dry board
  phase: drill
  stepKind: practice
  runner: _w6ValueDryBoardRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q.
  runnerSupport_en: Top pair with the best possible kicker.
  runnerQuestion_en: Which range bucket is K-Q on this board?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: range_checkpoint_board_fit
  status: missing
  title_en: Board changes bucket
  phase: drill
  stepKind: practice
  runner: _w6WrongBoardRunner
  runnerPrompt_en: 8-7-6 two-tone. Hero holds K-Q.
  runnerSupport_en: K-Q was strong preflop, but this board changed everything.
  runnerQuestion_en: Which range bucket is K-Q on 8-7-6?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: range_checkpoint_combos
  status: missing
  title_en: Count the family
  phase: drill
  stepKind: practice
  runner: _w6AkComboRunner
  runnerPrompt_en: A-K can be suited or offsuit.
  runnerSupport_en: Four aces can pair with four kings.
  runnerQuestion_en: How many combos does A-K have before blockers?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: range_checkpoint_pressure
  status: missing
  title_en: Bluff candidate
  phase: drill
  stepKind: practice
  runner: _w6BluffCandidateRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds A-Q.
  runnerSupport_en: Two overcards, no pair. Some fold equity exists.
  runnerQuestion_en: Which range bucket is A-Q here?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: range_checkpoint_review
  status: missing
  title_en: Range recap
  phase: review
  stepKind: proveIt
  runner: _world6RangeCheckpointRunner
  runnerPrompt_en: Lesson learned: range buckets need board-fit context.
  runnerSupport_en: Bucket first, board fit second, stack depth next.
  runnerQuestion_en: What carries this read into World 8?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

