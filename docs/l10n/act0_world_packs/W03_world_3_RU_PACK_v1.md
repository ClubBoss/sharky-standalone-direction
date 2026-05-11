# world_3 RU Translation Pack

Status: GENERATED
World number: 3
EN title: Position Thinking
EN subtitle: See why seat order changes hand value and comfort.
title_ru: Мышление позицией
subtitle_ru: Почувствуй, почему порядок мест меняет силу руки и комфорт.

## Coverage
- Lessons: 0/1
- Tasks: 6/6
- Runner prompts: 6/6
- Runner supports: 6/6
- Runner questions: 6/6

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson position_apply
status: missing
title_en: Position at the table
subtitle_en: Seat shapes the decision before anything else.
title_ru: 
subtitle_ru: 

- taskId: position_apply_intro
  status: landed_or_partial
  title_en: Position shapes action
  phase: theory
  stepKind: learn
  runner: _w3PositionApplyIntroRunner
  runnerPrompt_en: Position tells you how comfortable a hand is before you act.
  runnerSupport_en: BTN is the best seat. UTG needs stronger hands to open. No charts needed yet.
  runnerQuestion_en: Why does position matter at the table?
  title_ru: Позиция меняет решение
  runnerPrompt_ru: Позиция заранее подсказывает, насколько руке будет удобно.
  runnerSupport_ru: Баттон даёт больше свободы, ранние места требуют большей аккуратности. Чарты пока не нужны.
  runnerQuestion_ru: Почему позиция так важна за столом?

- taskId: position_apply_btn_open
  status: landed_or_partial
  title_en: BTN: open strong hand
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  title_ru: Баттон: открыть сильную руку
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым продолжением.
  runnerQuestion_ru: Какое здесь самое простое первое действие?

- taskId: position_apply_late_open
  status: landed_or_partial
  title_en: Late: open or limp?
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  runnerPrompt_en: Unopened pot. Hero is late with ATo.
  runnerSupport_en: Late position supports a clean open with this playable hand.
  runnerQuestion_en: What is the simple action?
  title_ru: Поздняя позиция: открыть или зайти пассивно?
  runnerPrompt_ru: Банк не открыт. Hero в поздней позиции с ATo.
  runnerSupport_ru: В поздней позиции такая рука спокойно тянет на открытие, а не на пассивный вход.
  runnerQuestion_ru: Какое действие здесь выглядит самым простым?

- taskId: position_apply_early_fold
  status: landed_or_partial
  title_en: Early: same hand folds
  phase: drill
  stepKind: fixMistakes
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  title_ru: Ранняя позиция: та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Hero в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже и не требует упрямства.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_apply_hj_fold
  status: landed_or_partial
  title_en: HJ: discipline hold
  phase: drill
  stepKind: fixMistakes
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  title_ru: HJ: держим дисциплину
  runnerPrompt_ru: Банк не открыт. Hero в раннем участке стола с ATo.
  runnerSupport_ru: Даже знакомая рука не обязана продолжать, если место за столом делает спот неудобным.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_apply_recap
  status: landed_or_partial
  title_en: Position apply recap
  phase: review
  stepKind: proveIt
  runner: _world3PositionRecapRunner
  runnerPrompt_en: Lesson learned: position changes preflop comfort.
  runnerSupport_en: Late helps. Early demands stronger buckets and cleaner frames.
  runnerQuestion_en: What should you check after the bucket?
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль проста: позиция меняет комфорт ещё до действия.
  runnerSupport_ru: Поздние места помогают, ранние требуют более крепкой руки и более чистой причины продолжать.
  runnerQuestion_ru: На что нужно смотреть сразу после группы руки?

