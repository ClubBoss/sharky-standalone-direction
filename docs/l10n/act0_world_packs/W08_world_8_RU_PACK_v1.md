# world_8 RU Translation Pack

Status: GENERATED
World number: 8
EN title: Stack Depth And Risk
EN subtitle: See why 100 BB and 20 BB need different plans.
title_ru: Глубина стека и риск
subtitle_ru: Пойми, почему 100 BB и 20 BB требуют разного мышления.

## Coverage
- Lessons: 0/4
- Tasks: 0/21
- Runner prompts: 0/21
- Runner supports: 0/21
- Runner questions: 0/21

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson effective_stack_basics
status: missing
title_en: Effective stack
subtitle_en: The smaller stack sets the maximum risk in the hand.
title_ru: 
subtitle_ru: 

- taskId: w7_effective_stack_intro
  status: missing
  title_en: Smaller stack rules
  phase: theory
  stepKind: learn
  runner: _w7EffectiveStackIntroRunner
  runnerPrompt_en: The smaller stack sets the maximum risk in the hand.
  runnerSupport_en: No one can win or lose more than the smaller stack.
  runnerQuestion_en: What is the effective stack?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_effective_stack_30bb
  status: missing
  title_en: 200 vs 30
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackThirtyRunner
  runnerPrompt_en: Hero has 200 BB. Villain has 30 BB.
  runnerSupport_en: Look for the smaller stack.
  runnerQuestion_en: What is the effective stack?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_effective_stack_100bb
  status: missing
  title_en: 100 vs 100
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackEvenRunner
  runnerPrompt_en: Hero has 100 BB. Villain has 100 BB.
  runnerSupport_en: Equal stacks keep the full depth in play.
  runnerQuestion_en: What is the effective stack?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_table_effective_notice
  status: missing
  title_en: Find the real risk
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackTableNoticeRunner
  runnerPrompt_en: You cover a player 120 BB to 18 BB on a real table.
  runnerSupport_en: Notice the number that caps the real risk.
  runnerQuestion_en: What should you notice first before planning?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_effective_stack_recap
  status: missing
  title_en: Effective stack recap
  phase: review
  stepKind: review
  runner: _w7EffectiveStackRecapRunner
  runnerPrompt_en: Lesson learned: the smaller stack sets the hand risk.
  runnerSupport_en: Effective stack tells you how much room the hand really has.
  runnerQuestion_en: Why does effective stack matter?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson same_hand_different_depth
status: missing
title_en: Same hand, different depth
subtitle_en: A hand can widen at 20 BB and tighten at 100 BB.
title_ru: 
subtitle_ru: 

- taskId: w7_depth_shift_intro
  status: missing
  title_en: Depth changes the plan
  phase: theory
  stepKind: learn
  runner: _w7DepthShiftIntroRunner
  runnerPrompt_en: The same hand can widen at 20 BB and tighten at 100 BB.
  runnerSupport_en: Short stacks simplify decisions. Deep stacks create more future risk.
  runnerQuestion_en: Why does stack depth change the plan?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_20bb_wider
  status: missing
  title_en: 20 BB decision
  phase: drill
  stepKind: practice
  runner: _w7TwentyBbWiderRunner
  runnerPrompt_en: You hold A-J suited with 20 BB effective.
  runnerSupport_en: Shorter stacks reduce the postflop burden.
  runnerQuestion_en: Which depth usually plays this hand more simply and more often?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_100bb_tighter
  status: missing
  title_en: 100 BB decision
  phase: drill
  stepKind: practice
  runner: _w7HundredBbTighterRunner
  runnerPrompt_en: Now look at the same hand with 100 BB effective.
  runnerSupport_en: More streets create more ways to make a second-best hand.
  runnerQuestion_en: What changes when the hand is 100 BB deep?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_40bb_middle
  status: missing
  title_en: 40 BB middle plan
  phase: drill
  stepKind: practice
  runner: _w7FortyBbMiddleRunner
  runnerPrompt_en: Now the same hand plays 40 BB effective.
  runnerSupport_en: This is not pure jam depth and not carefree deep depth.
  runnerQuestion_en: What is the cleaner 40 BB read?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_depth_shift_recap
  status: missing
  title_en: Depth recap
  phase: review
  stepKind: review
  runner: _w7DepthShiftRecapRunner
  runnerPrompt_en: Lesson learned: stack depth changes hand value and plan.
  runnerSupport_en: Short stacks simplify. Deep stacks ask for more caution.
  runnerQuestion_en: What changes when stack depth changes?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson spr_and_commitment
status: missing
title_en: Room or commitment
subtitle_en: Low SPR means less room. High SPR means more room to maneuver.
title_ru: 
subtitle_ru: 

- taskId: w7_spr_intro
  status: missing
  title_en: Low room vs high room
  phase: theory
  stepKind: learn
  runner: _w7SprIntroRunner
  runnerPrompt_en: SPR tells you how much room is left after the flop.
  runnerSupport_en: Low SPR means little room. High SPR means more room to maneuver.
  runnerQuestion_en: What does low SPR usually mean?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_low_spr_commit
  status: missing
  title_en: SPR 2
  phase: drill
  stepKind: practice
  runner: _w7LowSprCommitRunner
  runnerPrompt_en: SPR is 2 on the flop and you hold top pair.
  runnerSupport_en: Little room is left.
  runnerQuestion_en: What does low SPR usually tell you?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_high_spr_room
  status: missing
  title_en: SPR 8
  phase: drill
  stepKind: practice
  runner: _w7HighSprRoomRunner
  runnerPrompt_en: SPR is 8 on the flop.
  runnerSupport_en: A lot of stack is still behind.
  runnerQuestion_en: What does high SPR usually give you?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_spr4_middle
  status: missing
  title_en: SPR 4
  phase: drill
  stepKind: practice
  runner: _w7SprFourRunner
  runnerPrompt_en: SPR is 4 with one pair and some stack still behind.
  runnerSupport_en: Middle SPR is neither pure jam nor huge freedom.
  runnerQuestion_en: What does SPR 4 usually feel like?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_spr_recap
  status: missing
  title_en: SPR recap
  phase: review
  stepKind: review
  runner: _w7SprRecapRunner
  runnerPrompt_en: Lesson learned: low SPR pushes commitment, high SPR keeps room.
  runnerSupport_en: Do not treat every flop the same when stack room changes.
  runnerQuestion_en: What does SPR help you feel?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson format_pressure
status: missing
title_en: 6-max vs full ring
subtitle_en: The same hand can open wider in 6-max than in full ring.
title_ru: 
subtitle_ru: 

- taskId: w7_format_intro
  status: missing
  title_en: Format changes pressure
  phase: theory
  stepKind: learn
  runner: _w7FormatPressureIntroRunner
  runnerPrompt_en: The same hand can open wider in 6-max than in full ring.
  runnerSupport_en: Fewer players behind means less chance someone wakes up with a premium hand.
  runnerQuestion_en: Why does 6-max usually widen ranges?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_6max_wider
  status: missing
  title_en: 6-max opens wider
  phase: drill
  stepKind: practice
  runner: _w7SixMaxWiderRunner
  runnerPrompt_en: A-J offsuit in early position.
  runnerSupport_en: Compare 6-max with 9-handed full ring.
  runnerQuestion_en: Where does this hand usually open wider?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_fullring_tighter
  status: missing
  title_en: Full ring tightens
  phase: drill
  stepKind: practice
  runner: _w7FullRingTighterRunner
  runnerPrompt_en: Now imagine the same hand in full ring.
  runnerSupport_en: More players still need to act.
  runnerQuestion_en: What usually changes in full ring?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_format_table_notice
  status: missing
  title_en: Count players behind
  phase: drill
  stepKind: practice
  runner: _w7FormatTableNoticeRunner
  runnerPrompt_en: You jump from 6-max online to a 9-handed live table.
  runnerSupport_en: Start by counting how many players are still behind you.
  runnerQuestion_en: What is the first useful adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_format_recap
  status: missing
  title_en: Format recap
  phase: review
  stepKind: review
  runner: _w7FormatRecapRunner
  runnerPrompt_en: Lesson learned: the same hand can open wider in 6-max and tighter in full ring.
  runnerSupport_en: Format changes pressure before the cards even hit the flop.
  runnerQuestion_en: Why does format change opening pressure?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w7_stack_checkpoint
  status: missing
  title_en: Stack-depth checkpoint
  phase: review
  stepKind: proveIt
  runner: _world7StackCheckpointRunner
  runnerPrompt_en: Lesson learned: depth, SPR, and format all change risk.
  runnerSupport_en: Next you will see how tournament pressure makes stack risk even sharper.
  runnerQuestion_en: What does stack-depth thinking add to range thinking?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

