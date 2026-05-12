# world_11 RU Translation Pack

Status: GENERATED
World number: 11
EN title: Real Play Transfer
EN subtitle: Combine the course into a practical table-ready checkpoint.
title_ru: Перенос в реальную игру
subtitle_ru: Перенеси учебные решения в реальные игровые ритмы.

## Coverage
- Lessons: 0/4
- Tasks: 0/17
- Runner prompts: 0/17
- Runner supports: 0/17
- Runner questions: 0/17
- Teaching step titles: 0/17
- Teaching step bodies: 0/17

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson session_plan_basics
status: missing
title_en: Session plan in 30 seconds
subtitle_en: Pick one focus before cards are dealt.
title_ru: План сессии за 30 секунд
subtitle_ru: Выбери один фокус ещё до первой раздачи.

- taskId: w11_session_plan_intro
  status: missing
  title_en: One-focus plan
  phase: theory
  stepKind: learn
  runner: _w11SessionPlanIntroRunner
  runnerPrompt_en: Pick one concrete focus before each real session starts.
  runnerSupport_en: One focus keeps decisions clear under pressure.
  runnerQuestion_en: What is the best pre-session plan style?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Выбери один фокус вроде стила блайндов, размера вэлью-ставок или дисциплины паса. После сессии оценивай именно его, а не всё сразу.
  title_ru: План с одним фокусом
  runnerPrompt_ru: До начала реальной сессии выбери один конкретный фокус.
  runnerSupport_ru: Один фокус делает решения чище под давлением.
  runnerQuestion_ru: Какой стиль плана до сессии здесь самый лучший?

- taskId: w11_plan_focus_choice
  status: missing
  title_en: Choose one focus
  phase: drill
  stepKind: practice
  runner: _w11PlanFocusChoiceRunner
  runnerPrompt_en: You have 45 minutes and noisy tables today.
  runnerSupport_en: Simple focus beats wide ambition.
  runnerQuestion_en: What is the cleaner session objective?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Когда времени мало и столы шумные, слишком широкий план распадается. Один конкретный навык обычно даёт лучший перенос в игру.
  title_ru: Выбери один фокус
  runnerPrompt_ru: У тебя сегодня 45 минут и шумные столы.
  runnerSupport_ru: Простой фокус почти всегда лучше широкой амбиции.
  runnerQuestion_ru: Какая цель сессии здесь будет чище?

- taskId: w11_plan_avoid_overload
  status: missing
  title_en: Avoid overload plan
  phase: drill
  stepKind: practice
  runner: _w11PlanAvoidOverloadRunner
  runnerPrompt_en: Your prior session had scattered notes and no clear pattern.
  runnerSupport_en: Reduce cognitive load first.
  runnerQuestion_en: What is the sharper adjustment?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Если в прошлой сессии заметки разъехались во все стороны, сначала убери перегруз. Простая цель обычно чинит это лучше всего.
  title_ru: Не перегружай план
  runnerPrompt_ru: В прошлой сессии у тебя были разбросанные заметки и ни одного ясного паттерна.
  runnerSupport_ru: Сначала снизь когнитивную нагрузку.
  runnerQuestion_ru: Какая подстройка здесь будет острее?

- taskId: w11_session_plan_recap
  status: missing
  title_en: Session-plan recap
  phase: review
  stepKind: review
  runner: _w11SessionPlanRecapRunner
  runnerPrompt_en: Lesson learned: one focus plan creates cleaner real-play transfer.
  runnerSupport_en: Simple plan first, then repetitions.
  runnerQuestion_en: What is the session-plan takeaway?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Сессия переносится в реальную игру лучше, когда у неё одна ясная тема и серия повторов, а не длинный список идей.
  title_ru: Повтор по плану сессии
  runnerPrompt_ru: Главная мысль урока: один фокус делает перенос в реальную игру чище.
  runnerSupport_ru: Сначала простой план, потом серия повторов.
  runnerQuestion_ru: Какой главный вывод по плану сессии здесь нужен?

## lesson table_trigger_reads
status: missing
title_en: In-session trigger reads
subtitle_en: Spot one trigger and apply one adjustment immediately.
title_ru: Сигналы во время сессии
subtitle_ru: Заметь один сигнал и сразу привяжи к нему одну подстройку.

- taskId: w11_trigger_intro
  status: missing
  title_en: Trigger-first loop
  phase: theory
  stepKind: learn
  runner: _w11TriggerReadIntroRunner
  runnerPrompt_en: When a trigger appears, apply one prepared adjustment quickly.
  runnerSupport_en: Trigger -> one lever -> observe result.
  runnerQuestion_en: What is a trigger read for transfer play?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От наблюдения к действию.
  teachingStep0_body_ru: Если блайнды часто пасуют, стил чуть расширяется. Если соперник переплачивает коллами, вэлью становится тяжелее. На каждый сигнал нужна одна простая подстройка.
  title_ru: Сигнал и подстройка
  runnerPrompt_ru: Когда появляется понятный сигнал, быстро применяй одну заранее подготовленную подстройку.
  runnerSupport_ru: Один сигнал, один рычаг, потом наблюдение за результатом.
  runnerQuestion_ru: Что такое сигнал для чтения за реальным столом?

- taskId: w11_trigger_overfold_blinds
  status: missing
  title_en: Blind overfold trigger
  phase: drill
  stepKind: practice
  runner: _w11TriggerOverfoldBlindsRunner
  runnerPrompt_en: Both blinds folded to 5 of your last 6 steals.
  runnerSupport_en: Overfold trigger supports a preflop widen lever.
  runnerQuestion_en: What is the cleaner transfer action?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От паттерна к действию.
  teachingStep0_body_ru: Если оба блайнда слишком часто сдаются, это уже не шум, а рабочий сигнал. Первый ответ здесь должен быть простым и отслеживаемым.
  title_ru: Сигнал: блайнды часто пасуют
  runnerPrompt_ru: Оба блайнда выбросили на 5 из 6 последних твоих стилов.
  runnerSupport_ru: Такой сигнал поддерживает расширение префлоп-стила.
  runnerQuestion_ru: Какое действие переноса здесь самое чистое?

- taskId: w11_trigger_overcall_flop
  status: missing
  title_en: Overcall trigger
  phase: drill
  stepKind: practice
  runner: _w11TriggerOvercallFlopRunner
  runnerPrompt_en: Villain keeps calling flop and turn with weak pairs.
  runnerSupport_en: Overcall trigger points to value-density change.
  runnerQuestion_en: What is the sharper one-lever response?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От паттерна к действию.
  teachingStep0_body_ru: Если игрок снова и снова доплачивает слабыми руками, усиливай добор, а не изобретай сложную подстройку. Один рычаг здесь снова лучший путь.
  title_ru: Сигнал: соперник переплачивает коллами
  runnerPrompt_ru: Соперник снова и снова платит флоп и тёрн со слабыми парами.
  runnerSupport_ru: Такой сигнал подсказывает ставить плотнее на вэлью.
  runnerQuestion_ru: Какой ответ одним рычагом здесь будет острее?

- taskId: w11_trigger_recap
  status: missing
  title_en: Trigger recap
  phase: review
  stepKind: review
  runner: _w11TriggerReadRecapRunner
  runnerPrompt_en: Lesson learned: trigger reads convert pattern into one action lever.
  runnerSupport_en: Trigger must be repeated, not imagined.
  runnerQuestion_en: What is the trigger-read takeaway?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От паттерна к действию.
  teachingStep0_body_ru: Сигнал должен повторяться, а не быть фантазией после одной руки. Только тогда перенос в реальную игру остаётся устойчивым.
  title_ru: Повтор по сигналам
  runnerPrompt_ru: Главная мысль урока: сигналы переводят наблюдение в одно рабочее действие.
  runnerSupport_ru: Сигнал должен повторяться, а не придумыватьcя на ходу.
  runnerQuestion_ru: Какой главный вывод по чтению сигналов здесь нужен?

## lesson post_session_review_loop
status: missing
title_en: Post-session review loop
subtitle_en: Convert one leak into one repair target for tomorrow.
title_ru: Цикл разбора сессии
subtitle_ru: Переводи один лик в одну задачу на исправление к завтрашней игре.

- taskId: w11_review_loop_intro
  status: missing
  title_en: One leak one fix
  phase: theory
  stepKind: learn
  runner: _w11ReviewLoopIntroRunner
  runnerPrompt_en: After play, name one leak and one repair target for tomorrow.
  runnerSupport_en: One leak, one fix, one next session test.
  runnerQuestion_en: What makes review actionable?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: План запускает день, сигналы ведут игру, а разбор после сессии ставит завтрашний фокус. Именно этот цикл и накапливает навык.
  title_ru: Один лик, одно исправление
  runnerPrompt_ru: После игры назови один лик, то есть слабое место в игре, и одну цель на исправление к завтрашней сессии.
  runnerSupport_ru: Один лик, одно исправление, один тест в следующей игре.
  runnerQuestion_ru: Что делает разбор действительно рабочим?

- taskId: w11_review_pick_leak
  status: missing
  title_en: Pick priority leak
  phase: drill
  stepKind: practice
  runner: _w11ReviewPickLeakRunner
  runnerPrompt_en: Today you missed thin value and overcalled one river.
  runnerSupport_en: Pick the leak that repeats most often first.
  runnerQuestion_en: What is the clean first review action?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Если ошибок несколько, сначала выбери ту, что повторяется чаще всего и сильнее всего стоит фишек. Это и будет лучший первый ремонт.
  title_ru: Выбери главный лик
  runnerPrompt_ru: Сегодня ты недобрал тонкое вэлью и один раз переплатил ривер.
  runnerSupport_ru: Сначала выбирай тот лик, который повторяется чаще всего.
  runnerQuestion_ru: Какое первое действие в разборе здесь самое чистое?

- taskId: w11_review_define_fix
  status: missing
  title_en: Define tomorrow fix
  phase: drill
  stepKind: practice
  runner: _w11ReviewDefineFixRunner
  runnerPrompt_en: Priority leak: overcalling rivers vs tight players.
  runnerSupport_en: Define an if-then fix for next session.
  runnerQuestion_en: Which repair target is most actionable?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Хороший разбор не заканчивается абстрактным “играть лучше”. Он должен превратиться в конкретное правило на следующую сессию.
  title_ru: Сформулируй завтрашнее исправление
  runnerPrompt_ru: Главный лик: лишние коллы на ривере против тайтовых игроков.
  runnerSupport_ru: Сформулируй для следующей сессии правило в формате «если-то».
  runnerQuestion_ru: Какая цель на исправление здесь самая рабочая?

- taskId: w11_review_loop_recap
  status: missing
  title_en: Review-loop recap
  phase: review
  stepKind: review
  runner: _w11ReviewLoopRecapRunner
  runnerPrompt_en: Lesson learned: review closes the transfer loop into tomorrow.
  runnerSupport_en: Write one leak and one fix before ending session.
  runnerQuestion_en: What is the review-loop takeaway?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Разбор сессии работает только тогда, когда даёт тебе один понятный фокус на следующую игру.
  title_ru: Повтор по петле разбора
  runnerPrompt_ru: Главная мысль урока: разбор замыкает петлю переноса в завтрашнюю игру.
  runnerSupport_ru: До конца сессии запиши один лик и одно исправление.
  runnerQuestion_ru: Какой главный вывод по петле разбора здесь нужен?

## lesson real_play_transfer_checkpoint
status: missing
title_en: Real-play transfer checkpoint
subtitle_en: Plan, trigger, review, then repeat as a daily loop.
title_ru: Контрольная по переносу в реальную игру
subtitle_ru: План, сигнал, разбор и повторение в ежедневной петле.

- taskId: w11_checkpoint_intro
  status: missing
  title_en: Transfer loop map
  phase: theory
  stepKind: learn
  runner: _w11SessionPlanIntroRunner
  runnerPrompt_en: Pick one concrete focus before each real session starts.
  runnerSupport_en: One focus keeps decisions clear under pressure.
  runnerQuestion_en: What is the best pre-session plan style?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Контрольная собирает весь цикл: до сессии один фокус, во время игры один сигнал и одна подстройка, после игры один разбор и новая цель на завтра.
  title_ru: Карта петли переноса
  runnerPrompt_ru: До начала каждой реальной сессии выбери один конкретный фокус.
  runnerSupport_ru: Один фокус держит решения ясными под давлением.
  runnerQuestion_ru: Какой стиль плана до сессии здесь самый лучший?

- taskId: w11_checkpoint_plan_line
  status: missing
  title_en: Plan line
  phase: drill
  stepKind: practice
  runner: _w11CheckpointPlanLineRunner
  runnerPrompt_en: You start a session after a long workday with low energy.
  runnerSupport_en: Plan should stay simple and executable.
  runnerQuestion_en: What is the clean transfer plan?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: После тяжёлого дня план должен становиться проще, а не шире. Рабочий перенос любит исполнимость, а не амбициозность.
  title_ru: Линия плана
  runnerPrompt_ru: Ты начинаешь сессию после длинного рабочего дня и с низкой энергией.
  runnerSupport_ru: План должен оставаться простым и исполнимым.
  runnerQuestion_ru: Какой план переноса здесь самый чистый?

- taskId: w11_checkpoint_trigger_line
  status: missing
  title_en: Trigger line
  phase: drill
  stepKind: practice
  runner: _w11CheckpointTriggerLineRunner
  runnerPrompt_en: You detect repeated blind overfold and river underbluff patterns.
  runnerSupport_en: Pick one trigger-action pair first.
  runnerQuestion_en: Which transfer action is best?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Даже если ты видишь несколько перекосов, сначала выбери одну пару «сигнал -> действие». Это помогает держать реальную игру под контролем.
  title_ru: Линия сигнала
  runnerPrompt_ru: Ты замечаешь частые пасы блайндов и редкий доблеф на ривере.
  runnerSupport_ru: Сначала выбери одну пару сигнал-действие.
  runnerQuestion_ru: Какое действие переноса здесь лучше всего?

- taskId: w11_checkpoint_review_line
  status: missing
  title_en: Review line
  phase: drill
  stepKind: practice
  runner: _w11CheckpointReviewLineRunner
  runnerPrompt_en: Session ends with mixed results and two recurring mistakes.
  runnerSupport_en: Review should output one next-session repair task.
  runnerQuestion_en: What is the strongest closeout action?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Правильное завершение сессии — это не эмоции, а чёткая цель. Даже после тяжёлого дня найди одну конкретную ошибку, которую исправишь завтра.
  title_ru: Линия разбора
  runnerPrompt_ru: Сессия заканчивается смешанным результатом и двумя повторяющимися ошибками.
  runnerSupport_ru: Разбор должен выдать одну задачу на исправление к следующей игре.
  runnerQuestion_ru: Какое завершающее действие здесь самое сильное?

- taskId: w11_checkpoint_review
  status: missing
  title_en: Real-play recap
  phase: review
  stepKind: proveIt
  runner: _world11RealPlayCheckpointRunner
  runnerPrompt_en: Lesson learned: plan, trigger, and review form one daily transfer loop.
  runnerSupport_en: This closes the core route and feeds your daily play-review habit loop. Next you build the mindset bridge.
  runnerQuestion_en: What does real-play transfer produce when done well?
  teachingStep0_title_en: Loop beats intensity.
  teachingStep0_body_en: Sustainable progress comes from repeating a clean transfer loop daily, not from occasional complex sessions.
  teachingStep0_title_ru: Цикл сильнее разового рывка.
  teachingStep0_body_ru: Устойчивый прогресс строится на чистой ежедневной петле, а не на редких сложных сессиях. В этом и есть настоящий перенос в живую игру.
  title_ru: Повтор по реальной игре
  runnerPrompt_ru: Главная мысль урока: план, сигнал и разбор образуют одну ежедневную петлю переноса.
  runnerSupport_ru: Это закрывает базовый маршрут и кормит ежедневную привычку играть и разбирать. Дальше идёт мост к игровому мышлению.
  runnerQuestion_ru: Что даёт хороший перенос в реальную игру?
