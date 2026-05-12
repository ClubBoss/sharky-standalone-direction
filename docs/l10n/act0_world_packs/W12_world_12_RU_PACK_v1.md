# world_12 RU Translation Pack

Status: GENERATED
World number: 12
EN title: Mindset Bridge
EN subtitle: Stabilize process, reset, and discipline for deeper postflop work.
title_ru: Мост к мышлению игрока
subtitle_ru: Собери дисциплину, ясность и устойчивый игровой тон.

## Coverage
- Lessons: 0/4
- Tasks: 0/17
- Runner prompts: 0/16
- Runner supports: 0/16
- Runner questions: 0/16
- Teaching step titles: 0/16
- Teaching step bodies: 0/16

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson decision_over_outcome
status: missing
title_en: Decision quality over outcome
subtitle_en: Judge decisions by process, not one result.
title_ru: Качество решения важнее результата
subtitle_ru: Оценивай раздачи по процессу, а не по одному исходу.

- taskId: w12_decision_quality_intro
  status: missing
  title_en: Process first
  phase: theory
  stepKind: learn
  runner: _w12DecisionQualityIntroRunner
  runnerPrompt_en: Short-term outcomes can lie. Process quality must stay the anchor.
  runnerSupport_en: Judge choices by logic, not one card on river.
  runnerQuestion_en: What should be judged first after a hand?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Хорошее решение может проиграть, а плохое — выиграть. Рост приходит из качества процесса, а не из коротких эмоциональных качелей результата.
  title_ru: Сначала процесс
  runnerPrompt_ru: Короткий результат может врать. Опорой должно оставаться качество процесса.
  runnerSupport_ru: Оценивай выбор по логике, а не по одной карте на ривере.
  runnerQuestion_ru: Что нужно судить первым после раздачи?

- taskId: w12_good_fold_bad_result
  status: missing
  title_en: Good fold, bad result
  phase: drill
  stepKind: practice
  runner: _w12GoodFoldBadResultRunner
  runnerPrompt_en: You folded a marginal bluff-catcher and villain later showed a bluff.
  runnerSupport_en: Do not auto-label by reveal result only.
  runnerQuestion_en: What is the sharper review reaction?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Если соперник потом показал блеф, это ещё не доказывает, что твой фолд был плохим. Сначала проверь логику решения, а не сам факт вскрытия.
  title_ru: Хороший пас, плохой результат
  runnerPrompt_ru: Ты выбросил пограничную руку для колла, а потом соперник показал блеф.
  runnerSupport_ru: Не вешай ярлык только по открытому результату.
  runnerQuestion_ru: Какая реакция разбора здесь будет острее?

- taskId: w12_bad_call_good_result
  status: missing
  title_en: Bad call, lucky win
  phase: drill
  stepKind: practice
  runner: _w12BadCallGoodResultRunner
  runnerPrompt_en: You made a loose call and got lucky on river.
  runnerSupport_en: Winning the pot does not guarantee a good decision.
  runnerQuestion_en: What is the best mindset response?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Выигранный банк не автоматически делает колл правильным. Удача не должна закрывать глаза на слабую логику.
  title_ru: Плохой колл, удачная победа
  runnerPrompt_ru: Ты сделал слишком широкий колл и доехал на ривере.
  runnerSupport_ru: Выигранный банк сам по себе не подтверждает качество решения.
  runnerQuestion_ru: Какой ответ по мышлению здесь лучший?

- taskId: w12_decision_quality_recap
  status: missing
  title_en: Process recap
  phase: review
  stepKind: review
  runner: _w12DecisionQualityRecapRunner
  runnerPrompt_en: Lesson learned: process quality is the anchor under variance.
  runnerSupport_en: Outcome is data, not verdict.
  runnerQuestion_en: What is the process-quality takeaway?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Исход — это данные, но не приговор качеству игры. Устойчивый игрок сначала проверяет процесс.
  title_ru: Повтор по процессу
  runnerPrompt_ru: Главная мысль урока: качество процесса остаётся опорой под дисперсией.
  runnerSupport_ru: Исход раздачи — это данные, а не финальный вердикт.
  runnerQuestion_ru: Какой главный вывод по качеству процесса здесь нужен?

## lesson tilt_reset_protocol
status: missing
title_en: Tilt reset protocol
subtitle_en: Use a short reset so one hand does not own the session.
title_ru: Протокол перезагрузки после тильта
subtitle_ru: Короткая перезагрузка не даёт одной раздаче захватить всю сессию.

- taskId: w12_tilt_reset_intro
  status: missing
  title_en: Reset in under 20s
  phase: theory
  stepKind: learn
  runner: _w12TiltResetIntroRunner
  runnerPrompt_en: One short reset can protect decision quality after emotional spikes.
  runnerSupport_en: Pause, breathe, re-anchor to plan.
  runnerQuestion_en: What is the purpose of a tilt reset?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: Назови эмоцию, сделай один спокойный цикл дыхания, повтори свой текущий фокус и сузь масштаб следующего решения. Этого часто уже достаточно.
  title_ru: Перезагрузка меньше чем за 20 секунд
  runnerPrompt_ru: Одна короткая перезагрузка помогает сохранить качество решений после эмоционального всплеска.
  runnerSupport_ru: Пауза, дыхание, возврат к плану.
  runnerQuestion_ru: В чём цель быстрой перезагрузки после тильта?

- taskId: w12_after_bad_beat_reset
  status: missing
  title_en: After bad beat
  phase: drill
  stepKind: practice
  runner: _w12AfterBadBeatResetRunner
  runnerPrompt_en: You lose a big all-in as favorite and feel immediate anger.
  runnerSupport_en: Reset before next hand starts.
  runnerQuestion_en: What is the cleaner immediate action?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: После болезненного переезда важнее всего не нести гнев в следующую раздачу. Сначала короткая перезагрузка, потом новое решение.
  title_ru: После болезненного переезда
  runnerPrompt_ru: Ты проиграл крупный олл-ин фаворитом и сразу чувствуешь злость.
  runnerSupport_ru: Сначала короткая перезагрузка, потом следующая раздача.
  runnerQuestion_ru: Какое действие здесь самое чистое прямо сейчас?

- taskId: w12_after_mistake_reset
  status: missing
  title_en: After your own mistake
  phase: drill
  stepKind: practice
  runner: _w12AfterMistakeResetRunner
  runnerPrompt_en: You realize you made an avoidable call error.
  runnerSupport_en: Use reset to prevent second error spiral.
  runnerQuestion_en: What response keeps discipline highest?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: Собственная ошибка легко запускает вторую ошибку подряд. Перезагрузка здесь нужна не для красоты, а чтобы оборвать спираль.
  title_ru: После собственной ошибки
  runnerPrompt_ru: Ты понимаешь, что только что сделал тяжёлый колл на эмоциях.
  runnerSupport_ru: Используй короткую перезагрузку, чтобы не допустить вторую ошибку подряд.
  runnerQuestion_ru: Какой ответ здесь лучше всего сохраняет дисциплину?

- taskId: w12_tilt_reset_recap
  status: missing
  title_en: Reset recap
  phase: review
  stepKind: review
  runner: _w12TiltResetRecapRunner
  runnerPrompt_en: Lesson learned: reset protects process under emotional pressure.
  runnerSupport_en: Fast reset now prevents leak cascade later.
  runnerQuestion_en: What is the reset takeaway?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: Быстрая перезагрузка защищает процесс до того, как мелкий срыв превратится в целую цепочку ошибок. Именно скорость здесь и ценна.
  title_ru: Повтор по перезагрузке
  runnerPrompt_ru: Главная мысль урока: перезагрузка защищает процесс под эмоциональным давлением.
  runnerSupport_ru: Быстрая перезагрузка сейчас не даёт ошибкам разрастись позже.
  runnerQuestion_ru: Какой главный вывод по перезагрузке здесь нужен?

## lesson confidence_and_discipline
status: missing
title_en: Confidence with discipline
subtitle_en: Play assertively without drifting into ego calls.
title_ru: Уверенность с дисциплиной
subtitle_ru: Играй уверенно, но не скатывайся в упрямые коллы и споры с собой.

- taskId: w12_confidence_intro
  status: missing
  title_en: Calm assertive baseline
  phase: theory
  stepKind: learn
  runner: _w12ConfidenceDisciplineIntroRunner
  runnerPrompt_en: Confident play means clear actions, not ego battles.
  runnerSupport_en: Assertive decisions still obey plan and evidence.
  runnerQuestion_en: What balance should confidence hold?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Чёткие линии хороши, когда их держит доказательство. Уверенность не должна превращаться в обиду, месть или желание что-то доказать.
  title_ru: Спокойная уверенная база
  runnerPrompt_ru: Уверенная игра — это ясные действия, а не попытка что-то себе доказать.
  runnerSupport_ru: Уверенные решения всё равно подчиняются плану и доказательствам.
  runnerQuestion_ru: Какой баланс должна держать уверенность?

- taskId: w12_assertive_not_ego
  status: missing
  title_en: Assertive, not ego
  phase: drill
  stepKind: practice
  runner: _w12AssertiveNotEgoRunner
  runnerPrompt_en: Villain needles you after winning a pot.
  runnerSupport_en: Decision quality should not react to table talk.
  runnerQuestion_en: What is the stronger mindset line?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Реплика соперника не должна толкать тебя в упрямый колл или блеф из злости. Сильная линия здесь — не кормить разговор своим решением.
  title_ru: Уверенно, без упрямства
  runnerPrompt_ru: Соперник поддевает тебя после выигранного банка.
  runnerSupport_ru: Качество решения не должно зависеть от разговоров за столом.
  runnerQuestion_ru: Какая линия мышления здесь сильнее?

- taskId: w12_discipline_under_pressure
  status: missing
  title_en: Discipline under pressure
  phase: drill
  stepKind: practice
  runner: _w12DisciplineUnderPressureRunner
  runnerPrompt_en: Deep in session, fatigue rises and decisions speed up.
  runnerSupport_en: Discipline means slowing only the critical spots.
  runnerQuestion_en: What is the best pressure adjustment?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Усталость не требует тормозить всё подряд. Дисциплина здесь чаще значит чуть замедлить только критические споты.
  title_ru: Дисциплина под давлением
  runnerPrompt_ru: Ближе к концу сессии усталость растёт, и решения начинают ускоряться.
  runnerSupport_ru: Дисциплина здесь значит замедлять только по-настоящему важные споты.
  runnerQuestion_ru: Какая подстройка под давление здесь будет лучшей?

- taskId: w12_confidence_recap
  status: missing
  title_en: Confidence recap
  phase: review
  stepKind: review
  runner: _w12ConfidenceDisciplineRecapRunner
  title_ru: Повтор по уверенности

## lesson mindset_bridge_checkpoint
status: missing
title_en: Mindset bridge checkpoint
subtitle_en: Carry process, reset, and discipline into postflop growth.
title_ru: Контрольная по игровому мышлению
subtitle_ru: Забери процесс, перезагрузку и дисциплину с собой в более глубокую постфлоп-игру.

- taskId: w12_checkpoint_intro
  status: missing
  title_en: Mindset loop map
  phase: theory
  stepKind: learn
  runner: _w12DecisionQualityIntroRunner
  runnerPrompt_en: Short-term outcomes can lie. Process quality must stay the anchor.
  runnerSupport_en: Judge choices by logic, not one card on river.
  runnerQuestion_en: What should be judged first after a hand?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Контрольная собирает весь мост: сначала процесс против результата, потом быстрая перезагрузка и затем уверенная дисциплина. Только на такой базе сложная стратегия закрепляется.
  title_ru: Карта цикла мышления
  runnerPrompt_ru: Короткий результат может врать. Опорой должно оставаться качество процесса.
  runnerSupport_ru: Оценивай выбор по логике, а не по одной карте на ривере.
  runnerQuestion_ru: Что нужно судить первым после раздачи?

- taskId: w12_checkpoint_process_line
  status: missing
  title_en: Process line
  phase: drill
  stepKind: practice
  runner: _w12CheckpointProcessLineRunner
  runnerPrompt_en: A correct line loses in a high-variance pot.
  runnerSupport_en: Process verdict comes before emotional verdict.
  runnerQuestion_en: What is the best immediate checkpoint reaction?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Даже если правильная линия проиграла большой банк, первый чекпоинт — не эмоция, а качество решения. Именно это удерживает рост.
  title_ru: Фокус на процессе
  runnerPrompt_ru: Правильная линия проиграла банк в споте с высокой дисперсией.
  runnerSupport_ru: Вердикт по процессу должен прийти раньше эмоционального вердикта.
  runnerQuestion_ru: Какая реакция на таком checkpoint здесь самая лучшая?

- taskId: w12_checkpoint_reset_line
  status: missing
  title_en: Reset line
  phase: drill
  stepKind: practice
  runner: _w12CheckpointResetLineRunner
  runnerPrompt_en: You feel tilt signs after two rough spots in a row.
  runnerSupport_en: Reset should be fast and repeatable.
  runnerQuestion_en: What is the cleaner bridge action?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Если ты чувствуешь признаки тильта, мост обратно в стабильность должен быть коротким и повторяемым. Перезагрузка здесь важнее анализа на полстраницы.
  title_ru: Линия перезагрузки
  runnerPrompt_ru: После двух тяжёлых спотов подряд ты чувствуешь признаки тильта.
  runnerSupport_ru: Перезагрузка должна быть быстрой и повторяемой.
  runnerQuestion_ru: Какое мостовое действие здесь самое чистое?

- taskId: w12_checkpoint_discipline_line
  status: missing
  title_en: Discipline line
  phase: drill
  stepKind: practice
  runner: _w12CheckpointDisciplineLineRunner
  runnerPrompt_en: A player taunts you into marginal high-variance spots.
  runnerSupport_en: Discipline means evidence over ego.
  runnerQuestion_en: Which line is strongest?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Когда соперник провоцирует тебя на пограничные споты, дисциплина значит держать факты выше эмоций. Это и есть зрелая уверенность.
  title_ru: Линия дисциплины
  runnerPrompt_ru: Игрок пытается поддеть тебя и втянуть в пограничные, высокодисперсионные споты.
  runnerSupport_ru: Дисциплина здесь значит ставить факты выше эмоций.
  runnerQuestion_ru: Какая линия здесь будет самой сильной?

- taskId: w12_checkpoint_review
  status: missing
  title_en: Mindset recap
  phase: review
  stepKind: proveIt
  runner: _world12MindsetCheckpointRunner
  runnerPrompt_en: Lesson learned: process, reset, and discipline stabilize your game.
  runnerSupport_en: Next you carry this mindset into deeper postflop decision trees and pressure spots.
  runnerQuestion_en: What does mindset bridge add before deeper strategy worlds?
  teachingStep0_title_en: Stability before complexity.
  teachingStep0_body_en: Strong strategy growth requires stable mindset loops. Process audits, resets, and discipline make advanced learning stick.
  teachingStep0_title_ru: Стабильность раньше сложности.
  teachingStep0_body_ru: Рост в сложной стратегии начинается не с блестящих линий, а со стабильного процесса, умения быстро перезагружаться и дисциплины.
  title_ru: Повтор по игровому мышлению
  runnerPrompt_ru: Главная мысль: фокус на процессе, быстрая перезагрузка и дисциплина — фундамент стабильной игры.
  runnerSupport_ru: Дальше это игровое мышление переносится уже в более глубокие постфлоп-деревья и споты под давлением.
  runnerQuestion_ru: Что даёт этот mindset bridge перед более глубокими стратегическими мирами?
