# world_9 RU Translation Pack

Status: GENERATED
World number: 9
EN title: Tournament Pressure
EN subtitle: Learn survival pressure and risk without equations.
title_ru: Турнирное давление
subtitle_ru: Почувствуй давление выживания и риска без формул.

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

## lesson survival_pressure_basics
status: missing
title_en: Chips are not life
subtitle_en: Tournament chips have survival pressure that cash chips do not.
title_ru: 
subtitle_ru: 

- taskId: w9_survival_intro
  status: missing
  title_en: Tournament life pressure
  phase: theory
  stepKind: learn
  runner: _w9SurvivalIntroRunner
  runnerPrompt_en: Tournament chips carry survival value, not only chip EV.
  runnerSupport_en: When you bust, your tournament run ends.
  runnerQuestion_en: What makes tournament chips different from cash chips?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_cash_vs_tournament
  status: missing
  title_en: Cash vs tournament
  phase: drill
  stepKind: practice
  runner: _w9CashVsTournamentRunner
  runnerPrompt_en: You face a thin all-in edge with 20 BB.
  runnerSupport_en: Compare cash-game reload logic with tournament survival.
  runnerQuestion_en: Which frame should be stronger in a tournament?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_short_stack_survival
  status: missing
  title_en: Short stack survival
  phase: drill
  stepKind: practice
  runner: _w9ShortStackSurvivalRunner
  runnerPrompt_en: You have 9 BB with blinds about to hit.
  runnerSupport_en: Very short stacks cannot wait forever.
  runnerQuestion_en: What is usually the sharper plan?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_survival_stack_tradeoff
  status: missing
  title_en: Life vs reload
  phase: drill
  stepKind: practice
  runner: _w9SurvivalTradeoffRunner
  runnerPrompt_en: Cash table can reload. Tournament table cannot.
  runnerSupport_en: The same thin edge does not carry the same downside.
  runnerQuestion_en: Which table should pass more thin stack-off spots?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_survival_recap
  status: missing
  title_en: Survival recap
  phase: review
  stepKind: review
  runner: _w9SurvivalRecapRunner
  runnerPrompt_en: Lesson learned: tournament chips include survival value.
  runnerSupport_en: Life pressure changes which thin spots are worth taking.
  runnerQuestion_en: What is the key survival takeaway?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson m_ratio_zones_lite
status: missing
title_en: M-ratio zones
subtitle_en: Use simple zones to choose urgency without formulas.
title_ru: 
subtitle_ru: 

- taskId: w9_m_ratio_intro
  status: missing
  title_en: Zone thinking
  phase: theory
  stepKind: learn
  runner: _w9MRatioIntroRunner
  runnerPrompt_en: M-ratio gives a quick urgency signal for tournament decisions.
  runnerSupport_en: Think in simple zones first, not formulas.
  runnerQuestion_en: What does M-ratio help you read?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_m_ratio_red_zone
  status: missing
  title_en: Red zone urgency
  phase: drill
  stepKind: practice
  runner: _w9MZoneRedRunner
  runnerPrompt_en: Your M-ratio is in the red zone.
  runnerSupport_en: Low zone means blinds are hurting fast.
  runnerQuestion_en: What is the sharper mindset?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_m_ratio_green_zone
  status: missing
  title_en: Green zone patience
  phase: drill
  stepKind: practice
  runner: _w9MZoneGreenRunner
  runnerPrompt_en: Your M-ratio is in the green zone.
  runnerSupport_en: You still have room to pick spots.
  runnerQuestion_en: What usually improves in green zone?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_m_ratio_yellow_zone
  status: missing
  title_en: Yellow zone planning
  phase: drill
  stepKind: practice
  runner: _w9MZoneYellowRunner
  runnerPrompt_en: Your M-ratio is in the yellow zone.
  runnerSupport_en: Yellow zone asks for planning before panic.
  runnerQuestion_en: What usually becomes sharper in yellow zone?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_m_ratio_recap
  status: missing
  title_en: M-ratio recap
  phase: review
  stepKind: review
  runner: _w9MRatioRecapRunner
  runnerPrompt_en: Lesson learned: M-ratio zones map urgency.
  runnerSupport_en: Green keeps room. Red needs action soon.
  runnerQuestion_en: What is the M-ratio takeaway?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson bubble_risk_premium
status: missing
title_en: Bubble risk premium
subtitle_en: Medium stacks tighten while big stacks can apply pressure.
title_ru: 
subtitle_ru: 

- taskId: w9_bubble_intro
  status: missing
  title_en: Bubble pressure basics
  phase: theory
  stepKind: learn
  runner: _w9BubblePressureIntroRunner
  runnerPrompt_en: Near the bubble, losing chips can hurt more than winning chips helps.
  runnerSupport_en: Medium stacks often feel this pressure most.
  runnerQuestion_en: What is risk premium in simple terms?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_medium_stack_tighten
  status: missing
  title_en: Medium stack discipline
  phase: drill
  stepKind: practice
  runner: _w9MediumStackTightenRunner
  runnerPrompt_en: You are a medium stack two spots from the money.
  runnerSupport_en: Bust risk is expensive here.
  runnerQuestion_en: What is usually the sharper adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_big_stack_leverage
  status: missing
  title_en: Big stack leverage
  phase: drill
  stepKind: practice
  runner: _w9BigStackLeverageRunner
  runnerPrompt_en: You cover both blinds near the bubble.
  runnerSupport_en: Leverage works because others face elimination risk.
  runnerQuestion_en: What usually improves for the big stack?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_bubble_short_stack
  status: missing
  title_en: Short stack urgency
  phase: drill
  stepKind: practice
  runner: _w9BubbleShortStackRunner
  runnerPrompt_en: You are the short stack near the bubble.
  runnerSupport_en: Short stacks still need survival spots, not endless folding.
  runnerQuestion_en: What usually stays true for the short stack?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_bubble_recap
  status: missing
  title_en: Bubble recap
  phase: review
  stepKind: review
  runner: _w9BubbleRecapRunner
  runnerPrompt_en: Lesson learned: bubble pressure changes who can risk chips.
  runnerSupport_en: Medium stacks tighten more; big stacks can lean with leverage.
  runnerQuestion_en: What is the bubble-pressure takeaway?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson tournament_pressure_checkpoint
status: missing
title_en: Tournament pressure checkpoint
subtitle_en: Survival, M-ratio, and bubble pressure before player adjustment.
title_ru: 
subtitle_ru: 

- taskId: w9_checkpoint_intro
  status: missing
  title_en: Three-part pressure read
  phase: theory
  stepKind: learn
  runner: _w9SurvivalIntroRunner
  runnerPrompt_en: Tournament chips carry survival value, not only chip EV.
  runnerSupport_en: When you bust, your tournament run ends.
  runnerQuestion_en: What makes tournament chips different from cash chips?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_checkpoint_survival_line
  status: missing
  title_en: Preserve tournament life
  phase: drill
  stepKind: practice
  runner: _w9CheckpointSurvivalLineRunner
  runnerPrompt_en: You are short with one orbit left.
  runnerSupport_en: Tournament life still needs action windows.
  runnerQuestion_en: What is the best pressure line?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_checkpoint_zone_line
  status: missing
  title_en: Urgency by zone
  phase: drill
  stepKind: practice
  runner: _w9CheckpointZoneLineRunner
  runnerPrompt_en: Two players face similar hand strength in different M-ratio zones.
  runnerSupport_en: Zone changes urgency.
  runnerQuestion_en: Which player should act sooner?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_checkpoint_bubble_line
  status: missing
  title_en: Bubble risk premium line
  phase: drill
  stepKind: practice
  runner: _w9CheckpointBubbleLineRunner
  runnerPrompt_en: Near bubble: medium stack faces big-stack open.
  runnerSupport_en: Risk premium should influence the response.
  runnerQuestion_en: What is often the cleaner medium-stack plan?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_checkpoint_table_notice
  status: missing
  title_en: Real-table pressure read
  phase: drill
  stepKind: practice
  runner: _w9TablePressureNoticeRunner
  runnerPrompt_en: Real table. Medium stack near the bubble faces a covering big-stack open.
  runnerSupport_en: Read the pressure before you click call or jam.
  runnerQuestion_en: What is the clean first pressure read?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: w9_checkpoint_review
  status: missing
  title_en: Tournament pressure recap
  phase: review
  stepKind: proveIt
  runner: _world9TournamentCheckpointRunner
  runnerPrompt_en: Lesson learned: tournament pressure changes risk and adjustment windows.
  runnerSupport_en: Next you will convert pressure reads into opponent-specific player adjustments.
  runnerQuestion_en: What does tournament-pressure thinking add before player adjustment?
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

