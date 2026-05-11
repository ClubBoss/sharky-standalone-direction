# world_10 RU Translation Pack

Status: GENERATED
World number: 10
EN title: Player Adjustment
EN subtitle: Adjust one lever at a time against real player types.
title_ru: Подстройка под игроков
subtitle_ru: Меняй один рычаг за раз против реальных типов игроков.

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

## lesson player_type_basics
status: missing
title_en: Who is at the table
subtitle_en: Tag players by one tendency before changing your line.
title_ru: 
subtitle_ru: 

- taskId: w10_player_type_intro
  status: missing
  title_en: One tendency first
  phase: theory
  stepKind: learn
  runner: _w10PlayerTypeIntroRunner
  runnerPrompt_en: Tag one clear tendency before you change strategy.
  runnerSupport_en: One useful read beats five vague labels.
  runnerQuestion_en: What is the first step in player adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_nit_tag
  status: missing
  title_en: Nit profile
  phase: drill
  stepKind: practice
  runner: _w10NitTagRunner
  runnerPrompt_en: Villain folds to steals repeatedly and rarely 3-bets.
  runnerSupport_en: Tight fold-heavy behavior has one obvious label.
  runnerQuestion_en: What is the most useful quick tag?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_loose_passive_tag
  status: missing
  title_en: Loose-passive profile
  phase: drill
  stepKind: practice
  runner: _w10LoosePassiveTagRunner
  runnerPrompt_en: Villain calls often preflop and postflop but rarely raises.
  runnerSupport_en: Calling wide without raises signals a common profile.
  runnerQuestion_en: What quick tag fits best?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_overaggressive_tag
  status: missing
  title_en: Over-aggressive profile
  phase: drill
  stepKind: practice
  runner: _w10OveraggressiveTagRunner
  runnerPrompt_en: Villain double-barrels missed boards and raises often.
  runnerSupport_en: Frequent pressure with weak showdowns points to one useful tag.
  runnerQuestion_en: What quick tag fits best?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_player_type_recap
  status: missing
  title_en: Player-type recap
  phase: review
  stepKind: review
  runner: _w10PlayerTypeRecapRunner
  runnerPrompt_en: Lesson learned: one tendency tag creates a cleaner exploit plan.
  runnerSupport_en: Avoid complex labels before evidence is stable.
  runnerQuestion_en: What is the tagging takeaway?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson adjust_one_lever
status: missing
title_en: Adjust one lever
subtitle_en: Change one action size or frequency, not everything at once.
title_ru: 
subtitle_ru: 

- taskId: w10_one_lever_intro
  status: missing
  title_en: One change at a time
  phase: theory
  stepKind: learn
  runner: _w10OneLeverIntroRunner
  runnerPrompt_en: Change one lever first: opening width, value density, or bluff rate.
  runnerSupport_en: Small precise changes are easier to trust and test.
  runnerQuestion_en: Why adjust one lever at a time?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_vs_nit_open_wider
  status: missing
  title_en: Steal more vs tight folds
  phase: drill
  stepKind: practice
  runner: _w10VsNitOpenWiderRunner
  runnerPrompt_en: Blinds fold too much to late-position steals.
  runnerSupport_en: Overfolding behind you increases steal EV.
  runnerQuestion_en: What is the clean first exploit?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_vs_caller_value_heavier
  status: missing
  title_en: Value heavier vs callers
  phase: drill
  stepKind: practice
  runner: _w10VsCallerValueHeavierRunner
  runnerPrompt_en: Villain calls down too wide with weak pairs.
  runnerSupport_en: Call-heavy opponents pay off thin value more often.
  runnerQuestion_en: What is the cleaner exploit lever?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_vs_sticky_defender_tighten_steals
  status: missing
  title_en: Tighten steals vs sticky defenders
  phase: drill
  stepKind: practice
  runner: _w10VsStickyDefenderTightenStealsRunner
  runnerPrompt_en: Blinds defend wide and call postflop too often.
  runnerSupport_en: A sticky defender changes the cleanest steal lever.
  runnerQuestion_en: What is the better first adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_one_lever_recap
  status: missing
  title_en: One-lever recap
  phase: review
  stepKind: review
  runner: _w10OneLeverRecapRunner
  runnerPrompt_en: Lesson learned: one lever gives cleaner exploit feedback loops.
  runnerSupport_en: Test one change before stacking new assumptions.
  runnerQuestion_en: What is the one-lever takeaway?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson exploit_guardrails
status: missing
title_en: Exploit guardrails
subtitle_en: Exploit with discipline so your line stays coherent.
title_ru: 
subtitle_ru: 

- taskId: w10_guardrails_intro
  status: missing
  title_en: Exploit without chaos
  phase: theory
  stepKind: learn
  runner: _w10ExploitGuardrailsIntroRunner
  runnerPrompt_en: Exploit does not mean abandoning discipline or hand quality.
  runnerSupport_en: Guardrails keep you from over-adjusting on thin evidence.
  runnerQuestion_en: Why do exploit guardrails matter?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_overbluff_punish
  status: missing
  title_en: Punish overbluffs
  phase: drill
  stepKind: practice
  runner: _w10OverbluffPunishRunner
  runnerPrompt_en: Villain barrels many missed draws in obvious spots.
  runnerSupport_en: Overbluffing can be punished by wider bluff-catch windows.
  runnerQuestion_en: What is the cleaner exploit response?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_underbluff_fold_more
  status: missing
  title_en: Fold more vs underbluffs
  phase: drill
  stepKind: practice
  runner: _w10UnderbluffFoldMoreRunner
  runnerPrompt_en: Villain reaches river with strong value and few bluffs.
  runnerSupport_en: Underbluffing changes bluff-catch requirements.
  runnerQuestion_en: What is the sharper adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_guardrail_sample_size
  status: missing
  title_en: Respect sample size
  phase: drill
  stepKind: practice
  runner: _w10GuardrailSampleSizeRunner
  runnerPrompt_en: You saw two odd hands but no long pattern yet.
  runnerSupport_en: Guardrails protect you when evidence is still thin.
  runnerQuestion_en: What is the cleaner exploit posture?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_guardrails_recap
  status: missing
  title_en: Guardrails recap
  phase: review
  stepKind: review
  runner: _w10ExploitGuardrailsRecapRunner
  runnerPrompt_en: Lesson learned: exploits work best with guardrails and evidence.
  runnerSupport_en: Do not let one read become a full strategy collapse.
  runnerQuestion_en: What is the guardrail takeaway?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson player_adjustment_checkpoint
status: missing
title_en: Player-adjustment checkpoint
subtitle_en: Tag tendency, adjust one lever, keep guardrails, then transfer to real play.
title_ru: 
subtitle_ru: 

- taskId: w10_checkpoint_intro
  status: missing
  title_en: Three-step exploit loop
  phase: theory
  stepKind: learn
  runner: _w10PlayerTypeIntroRunner
  runnerPrompt_en: Tag one clear tendency before you change strategy.
  runnerSupport_en: One useful read beats five vague labels.
  runnerQuestion_en: What is the first step in player adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_checkpoint_tag_line
  status: missing
  title_en: Tag then act
  phase: drill
  stepKind: practice
  runner: _w10CheckpointTagLineRunner
  runnerPrompt_en: Opponent folds blinds often but calls rivers too wide.
  runnerSupport_en: You can tag both tendencies, then choose one main lever first.
  runnerQuestion_en: What is the cleaner first step?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_checkpoint_lever_line
  status: missing
  title_en: One-lever exploit line
  phase: drill
  stepKind: practice
  runner: _w10CheckpointLeverLineRunner
  runnerPrompt_en: A tight blind fold profile appears in your sample.
  runnerSupport_en: Single-lever adjustment is the test.
  runnerQuestion_en: Which exploit line is the cleanest first move?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_checkpoint_guardrail_line
  status: missing
  title_en: Guardrail discipline
  phase: drill
  stepKind: practice
  runner: _w10CheckpointGuardrailLineRunner
  runnerPrompt_en: You saw one wild bluff from villain this orbit.
  runnerSupport_en: Single hand reads can be noisy.
  runnerQuestion_en: What is the best guardrail action?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_checkpoint_table_notice
  status: missing
  title_en: Real-table exploit read
  phase: drill
  stepKind: practice
  runner: _w10TableAdjustmentNoticeRunner
  runnerPrompt_en: Real table. Both blinds have folded to your late steals again and again.
  runnerSupport_en: Choose the first exploit you can actually track at the table.
  runnerQuestion_en: What is the clean first live adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w10_checkpoint_review
  status: missing
  title_en: Player-adjustment recap
  phase: review
  stepKind: proveIt
  runner: _world10PlayerAdjustmentCheckpointRunner
  runnerPrompt_en: Lesson learned: tag tendency, adjust one lever, keep guardrails.
  runnerSupport_en: Next you will transfer these guardrails-based adjustments into real-play decisions across mixed table conditions.
  runnerQuestion_en: What does player adjustment add before real-play transfer?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

