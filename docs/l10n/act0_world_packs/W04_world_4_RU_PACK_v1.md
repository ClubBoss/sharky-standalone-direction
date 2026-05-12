# world_4 RU Translation Pack

Status: GENERATED
World number: 4
EN title: Preflop Framework
EN subtitle: Use bucket, seat, and action frame before choosing.
title_ru: Префлоп-каркас
subtitle_ru: Смотри на руку, место и действие до того, как выбирать линию.

## Coverage
- Lessons: 0/5
- Tasks: 0/21
- Runner prompts: 0/21
- Runner supports: 0/21
- Runner questions: 0/21
- Teaching step titles: 0/21
- Teaching step bodies: 0/21

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson preflop_first_in_open
status: missing
title_en: First-in open
subtitle_en: When nobody entered, raising can start the hand.
title_ru: Открытие первым
subtitle_ru: Если в банк ещё никто не вошёл, раздачу можно начать рейзом.

- taskId: w3_first_in_intro
  status: missing
  title_en: Unopened pot
  phase: theory
  stepKind: learn
  runner: _world3FirstInIntroRunner
  runnerPrompt_en: First in means nobody has entered the pot yet.
  runnerSupport_en: You can limp by calling the blind, but open or fold is cleaner.
  runnerQuestion_en: What is cleaner than limping first in?
  teachingStep0_title_en: Unopened pot.
  teachingStep0_body_en: When nobody entered, raising is called opening. Calling is limping.
  teachingStep0_title_ru: Банк не открыт.
  teachingStep0_body_ru: Если до тебя никто не вошёл в банк, рейз называется открытием. Просто колл — это лимп.
  title_ru: Банк не открыт
  runnerPrompt_ru: Если ты входишь первым, в банке ещё никого нет.
  runnerSupport_ru: Можно зайти лимпом, но опен-рейз или пас обычно чище.
  runnerQuestion_ru: Что чище, чем пассивно входить первым?

- taskId: w3_button_open
  status: missing
  title_en: Button open
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Открытие с баттона
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_early_fold
  status: missing
  title_en: Early fold
  phase: drill
  stepKind: practice
  runner: _world3EarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is early with J8o.
  runnerSupport_en: Early position removes the comfort from weak offsuit hands.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Discipline is allowed.
  teachingStep0_body_en: Opening weak early hands creates hard spots later.
  teachingStep0_title_ru: Дисциплина здесь уместна.
  teachingStep0_body_ru: Открытие слабых ранних рук часто создаёт тяжёлые споты на следующих решениях.
  title_ru: Ранний пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с J8o.
  runnerSupport_ru: Ранняя позиция лишает слабые разномастные руки любого комфорта.
  runnerQuestion_ru: Какое действие здесь будет самым чистым?

- taskId: w3_first_in_recap
  status: missing
  title_en: Open recap
  phase: review
  stepKind: review
  runner: _world3FirstInRecapRunner
  runnerPrompt_en: Lesson learned: first in means open or fold.
  runnerSupport_en: Calling the blind is a limp; it is legal, but not the clean default.
  runnerQuestion_en: What is the passive first-in action?
  teachingStep0_title_en: First-in takeaway.
  teachingStep0_body_en: Unopened pots ask whether to open or let the hand go.
  teachingStep0_title_ru: Вывод по входу первым.
  teachingStep0_body_ru: Если банк не открыт, сначала решай: открыть раздачу или спокойно отпустить руку.
  title_ru: Повтор по открытию
  runnerPrompt_ru: Главная мысль: если входишь первым, обычно выбираешь между открытием и пасом.
  runnerSupport_ru: Колл блайнда — это лимп: он допустим, но не выглядит чистым вариантом по умолчанию.
  runnerQuestion_ru: Как называется пассивный вход первым?

## lesson preflop_facing_open
status: missing
title_en: Facing an open
subtitle_en: A raise before you changes the decision.
title_ru: Против открытия
subtitle_ru: Рейз до тебя меняет решение.

- taskId: w3_facing_open_intro
  status: missing
  title_en: Someone opened
  phase: theory
  stepKind: learn
  runner: _world3FacingOpenIntroRunner
  runnerPrompt_en: Facing an open means someone raised before you.
  runnerSupport_en: Now calling can exist, and weak continues can fold.
  runnerQuestion_en: What changed from first in?
  teachingStep0_title_en: The frame changed.
  teachingStep0_body_en: An opener created a price. Now call or fold can be natural.
  teachingStep0_title_ru: Рамка изменилась.
  teachingStep0_body_ru: Открытие до тебя создаёт цену входа. Теперь колл или пас часто становятся естественными вариантами.
  title_ru: Кто-то уже открылся
  runnerPrompt_ru: Против открытия — значит, кто-то уже сделал рейз до тебя.
  runnerSupport_ru: Теперь колл уже может быть нормальным, а слабые продолжения спокойно уходят в пас.
  runnerQuestion_ru: Что изменилось по сравнению со входом первым?

- taskId: w3_playable_call
  status: missing
  title_en: Playable call
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто заколлить открытие, если ты действуешь после CO.
  title_ru: Играбельный колл
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: w3_weak_facing_fold
  status: missing
  title_en: Weak facing fold
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не бесплатный пропуск.
  teachingStep0_body_ru: J8o всё равно идёт в пас, если группа руки слишком слабая.
  title_ru: Слабая рука против открытия
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё ещё слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: w3_facing_open_recap
  status: missing
  title_en: Facing-open recap
  phase: review
  stepKind: review
  runner: _world3FacingOpenRecapRunner
  runnerPrompt_en: Lesson learned: facing an open creates a price.
  runnerSupport_en: Playable hands can call; weak hands can still fold.
  runnerQuestion_en: What did the opener create?
  teachingStep0_title_en: Facing-open checklist.
  teachingStep0_body_en: Read the hand bucket, your position, and the price.
  teachingStep0_title_ru: Проверка против открытия.
  teachingStep0_body_ru: Смотри на группу руки, свою позицию и цену входа.
  title_ru: Повтор против открытия
  runnerPrompt_ru: Главное правило: чужой рейз устанавливает цену за просмотр флопа.
  runnerSupport_ru: Играбельные руки могут коллировать, а слабые спокойно уходят в пас.
  runnerQuestion_ru: Что создал рейз до тебя?

## lesson open_call_fold
status: missing
title_en: Open, call, fold
subtitle_en: Read first-in, facing-open, then act.
title_ru: Открыть, заколлить, выбросить
subtitle_ru: Сначала пойми рамку, потом действуй.

- taskId: frame_intro
  status: missing
  title_en: Frame first
  phase: theory
  stepKind: learn
  runner: _world3FirstInIntroRunner
  runnerPrompt_en: First in means nobody has entered the pot yet.
  runnerSupport_en: You can limp by calling the blind, but open or fold is cleaner.
  runnerQuestion_en: What is cleaner than limping first in?
  teachingStep0_title_en: Unopened pot.
  teachingStep0_body_en: When nobody entered, raising is called opening. Calling is limping.
  teachingStep0_title_ru: Банк не открыт.
  teachingStep0_body_ru: Если до тебя никто не вошёл в банк, рейз называется открытием. Просто колл — это лимп.
  title_ru: Сначала рамка
  runnerPrompt_ru: Если ты входишь первым, в банке ещё никого нет.
  runnerSupport_ru: Можно заколлить блайнд и зайти пассивно, но открыть или выбросить обычно чище.
  runnerQuestion_ru: Что чище, чем пассивно входить первым?

- taskId: frame_open
  status: missing
  title_en: Open
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Открыть
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: frame_call
  status: missing
  title_en: Call
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто заколлить открытие, если ты действуешь после CO.
  title_ru: Колл
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: frame_recap
  status: missing
  title_en: Action frame recap
  phase: review
  stepKind: review
  runner: _world3FirstInRecapRunner
  runnerPrompt_en: Lesson learned: first in means open or fold.
  runnerSupport_en: Calling the blind is a limp; it is legal, but not the clean default.
  runnerQuestion_en: What is the passive first-in action?
  teachingStep0_title_en: First-in takeaway.
  teachingStep0_body_en: Unopened pots ask whether to open or let the hand go.
  teachingStep0_title_ru: Проверка рамки.
  teachingStep0_body_ru: Сначала спроси, банк не открыт или рейз уже был. Только потом выбирай действие.
  title_ru: Повтор по рамке решения
  runnerPrompt_ru: Главная мысль: контекст меняет действие.
  runnerSupport_ru: Одна и та же рука может открыться первой, заколлить против открытия или уйти в пас в худшей рамке.
  runnerQuestion_ru: Что не даёт мышлению сводиться к «одна рука — один ответ»?

## lesson preflop_frame_before_action
status: missing
title_en: Frame before action
subtitle_en: Same hand, different action frame.
title_ru: Рамка до действия
subtitle_ru: Одна и та же рука ведёт себя по-разному в разной рамке.

- taskId: w3_same_hand_intro
  status: missing
  title_en: Context first
  phase: theory
  stepKind: learn
  runner: _world3SameHandIntroRunner
  runnerPrompt_en: The same hand can change action when the frame changes.
  runnerSupport_en: First in, facing open, and early position are different frames.
  runnerQuestion_en: What should you re-check?
  teachingStep0_title_en: No permanent answer.
  teachingStep0_body_en: Re-check bucket, seat, and whether someone already opened.
  teachingStep0_title_ru: Постоянного ответа нет.
  teachingStep0_body_ru: Снова посмотри на группу руки, место за столом и на то, был ли уже рейз.
  title_ru: Сначала контекст
  runnerPrompt_ru: Одна и та же рука может менять действие, если меняется рамка.
  runnerSupport_ru: Вход первым, игра против открытия и ранняя позиция — это разные условия.
  runnerQuestion_ru: Что нужно перепроверить?

- taskId: w3_same_hand_open
  status: missing
  title_en: Open frame
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Рамка открытия
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_same_hand_call
  status: missing
  title_en: Call frame
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто заколлить открытие, если ты действуешь после CO.
  title_ru: Рамка колла
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: w3_same_hand_recap
  status: missing
  title_en: Frame recap
  phase: review
  stepKind: review
  runner: _world3SameHandRecapRunner
  runnerPrompt_en: Lesson learned: context can change the action.
  runnerSupport_en: A hand can open first in, call facing an open, or fold in a worse frame.
  runnerQuestion_en: What prevents one-hand-one-answer thinking?
  teachingStep0_title_en: Frame checklist.
  teachingStep0_body_en: Ask if the pot is unopened or if a raise already happened.
  teachingStep0_title_ru: Проверка рамки.
  teachingStep0_body_ru: Сначала пойми, банк не открыт или рейз уже был.
  title_ru: Повтор по рамке
  runnerPrompt_ru: Главная мысль: контекст меняет действие.
  runnerSupport_ru: Одна и та же рука может открываться первой, коллировать против открытия или уходить в пас в худшей рамке.
  runnerQuestion_ru: Что мешает мышлению «одна рука — один ответ»?

## lesson preflop_framework_checkpoint
status: missing
title_en: Preflop checkpoint
subtitle_en: Bucket, seat, frame, then action.
title_ru: Префлоп-контрольная
subtitle_ru: Группа, место, рамка, потом действие.

- taskId: w3_checkpoint_intro
  status: missing
  title_en: Three checks
  phase: theory
  stepKind: learn
  runner: _world3CheckpointIntroRunner
  runnerPrompt_en: Checkpoint: bucket, position, frame, then action.
  runnerSupport_en: Keep one reason in focus for each preflop decision.
  runnerQuestion_en: What is the World 3 preflop order?
  teachingStep0_title_en: Preflop order.
  teachingStep0_body_en: Name the bucket, read position, read frame, choose action.
  teachingStep0_title_ru: Префлоп-порядок.
  teachingStep0_body_ru: Назови группу руки, прочитай позицию, пойми рамку и только потом выбирай действие.
  title_ru: Три проверки
  runnerPrompt_ru: Контрольная проста: группа руки, позиция, рамка, потом действие.
  runnerSupport_ru: Держи в голове одну причину на каждое префлоп-решение.
  runnerQuestion_ru: Какой порядок нужен в World 4?

- taskId: w3_checkpoint_open
  status: missing
  title_en: Open decision
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Решение на открытие
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_checkpoint_fold
  status: missing
  title_en: Fold decision
  phase: drill
  stepKind: practice
  runner: _world3EarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is early with J8o.
  runnerSupport_en: Early position removes the comfort from weak offsuit hands.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Discipline is allowed.
  teachingStep0_body_en: Opening weak early hands creates hard spots later.
  teachingStep0_title_ru: Дисциплина здесь уместна.
  teachingStep0_body_ru: Открытие слабых ранних рук часто создаёт тяжёлые споты на следующих решениях.
  title_ru: Решение на пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с J8o.
  runnerSupport_ru: Ранняя позиция убирает комфорт у слабых разномастных рук.
  runnerQuestion_ru: Какое действие здесь будет самым чистым?

- taskId: checkpoint_table_frame
  status: missing
  title_en: Real-table frame read
  phase: drill
  stepKind: practice
  runner: _w4TableFrameNoticeRunner
  runnerPrompt_en: Real table. HJ opens 2.5 BB and hero is CO with AJo.
  runnerSupport_en: Before deciding call, fold, or raise, name the frame cleanly.
  runnerQuestion_en: What frame are you in?
  teachingStep0_title_en: Frame before action.
  teachingStep0_body_en: Real tables get simpler when you first ask whether the pot is unopened or facing an open.
  teachingStep0_title_ru: Рамка до действия.
  teachingStep0_body_ru: За живым столом всё становится проще, если сначала понять: банк не открыт или ты играешь против открытия.
  title_ru: Живая рамка раздачи
  runnerPrompt_ru: Живой стол. HJ открылся 2.5 BB, ты на CO с AJo.
  runnerSupport_ru: Перед тем как коллировать, пасовать или рейзить, сначала чисто назови рамку.
  runnerQuestion_ru: В какой рамке ты сейчас находишься?

- taskId: w3_checkpoint_review
  status: missing
  title_en: Preflop recap
  phase: review
  stepKind: proveIt
  runner: _world3CheckpointRunner
  runnerPrompt_en: Lesson learned: simple preflop choices need a framework.
  runnerSupport_en: No charts yet. Just bucket, position, frame, action.
  runnerQuestion_en: What makes preflop less random?
  teachingStep0_title_en: World 3 checkpoint.
  teachingStep0_body_en: Use one compact read instead of guessing the first action.
  teachingStep0_title_ru: Контрольная по World 4.
  teachingStep0_body_ru: Используй один компактный порядок вместо того, чтобы гадать первое действие.
  title_ru: Префлоп-повтор
  runnerPrompt_ru: Главная мысль: простым префлоп-решениям нужен каркас.
  runnerSupport_ru: Пока без чартов. Только группа руки, позиция, рамка и действие.
  runnerQuestion_ru: Что делает префлоп менее случайным?
