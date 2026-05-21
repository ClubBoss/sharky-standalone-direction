# world_3 RU Translation Pack

Status: GENERATED
World number: 3
EN title: Position Thinking
EN subtitle: See why seat order changes hand value and comfort.
title_ru: Мышление позицией
subtitle_ru: Почувствуй, почему порядок мест меняет силу руки и комфорт.

## Coverage
- Lessons: 6/6
- Tasks: 13/38
- Runner prompts: 6/38
- Runner supports: 6/38
- Runner questions: 6/38
- Teaching step titles: 0/40
- Teaching step bodies: 0/40

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson position_six_seats
status: landed_or_partial
title_en: The 6 positions
subtitle_en: Recognize UTG, HJ, CO, BTN, SB, and BB.
title_ru: Шесть позиций
subtitle_ru: У каждого места есть имя и свой порядок хода.

- taskId: blinds_theory
  status: landed_or_partial
  title_en: Blinds post first
  phase: theory
  stepKind: learn
  runner: _blindsOrderRunner
  runnerPrompt_en: SB and BB post before cards are played.
  runnerSupport_en: The first decision comes after the big blind.
  runnerQuestion_en: Which blind posts 1 BB?
  teachingStep0_title_en: Blinds force a starting pot.
  teachingStep0_body_en: Blinds are real chips or money put in first. Players often count them in big blinds because BB is the clean shortcut for the price.
  teachingStep0_title_ru: Блайнды формируют начальный банк.
  teachingStep0_body_ru: Блайнды — это обязательные ставки вслепую, которые ставятся до раздачи карт. Игроки считают их в больших блайндах (BB), так как это самый простой ориентир для цены.
  teachingStep1_title_en: Action starts after BB.
  teachingStep1_body_en: If the big blind is 1 BB, then a 3 BB open means three times that price. Preflop, UTG is first to choose after the blinds post.
  teachingStep1_title_ru: Торговля начинается после BB.
  teachingStep1_body_ru: Если большой блайнд равен 1 BB, то открытие в 3 BB означает три таких блайнда. На префлопе первое слово за столом после блайндов принадлежит позиции UTG.
  title_ru: Блайнды ставятся первыми
  runnerPrompt_ru: Малый и большой блайнды ставятся до раздачи карт.
  runnerSupport_ru: Первое решение на префлопе принимается сразу после большого блайнда.
  runnerQuestion_ru: Какой блайнд равен 1 BB?

- taskId: blinds_posts_drill
  status: landed_or_partial
  title_en: Who posts 1 BB
  phase: drill
  stepKind: practice
  runner: _bigBlindPostRunner
  runnerPrompt_en: BB posts the full 1 BB blind.
  runnerSupport_en: SB posts the smaller 0.5 BB blind.
  runnerQuestion_en: Tap the big blind.
  teachingStep0_title_en: Big blind is the full blind.
  teachingStep0_body_en: Find the seat marked BB with the 1 BB post.
  teachingStep0_title_ru: Большой блайнд — это полная ставка.
  teachingStep0_body_ru: Найди место с меткой BB, где ставится полный блайнд размером в 1 BB.
  title_ru: Кто ставит 1 BB
  runnerPrompt_ru: Большой блайнд ставит полную обязательную ставку в 1 BB.
  runnerSupport_ru: Малый блайнд ставит половину — 0.5 BB.
  runnerQuestion_ru: Нажми на большой блайнд (BB).

- taskId: blinds_first_actor
  status: landed_or_partial
  title_en: First preflop actor
  phase: drill
  stepKind: practice
  runner: _firstPreflopActorRunner
  runnerPrompt_en: Preflop starts left of the big blind.
  runnerSupport_en: Tap the first preflop actor.
  runnerQuestion_en: Tap UTG.
  teachingStep0_title_en: Preflop begins after BB.
  teachingStep0_body_en: The first seat left of the big blind is UTG.
  teachingStep0_title_ru: Торговля на префлопе начинается после BB.
  teachingStep0_body_ru: Первое место слева от большого блайнда называется UTG (под прицелом). Именно этот игрок ходит первым.
  title_ru: Первый на префлопе
  runnerPrompt_ru: Действие на префлопе начинается слева от большого блайнда.
  runnerSupport_ru: Нажми на место игрока, который ходит первым на префлопе.
  runnerQuestion_ru: Нажми на UTG.

- taskId: blinds_last_actor
  status: landed_or_partial
  title_en: Last preflop actor
  phase: drill
  stepKind: practice
  runner: _lastPreflopActorRunner
  runnerPrompt_en: The big blind closes preflop when nobody raises.
  runnerSupport_en: Tap the last preflop actor.
  runnerQuestion_en: Tap BB.
  teachingStep0_title_en: BB closes the first round.
  teachingStep0_body_en: If nobody raises, the big blind can act last preflop.
  teachingStep0_title_ru: BB закрывает первый круг торговли.
  teachingStep0_body_ru: Если до большого блайнда никто не сделал рейз, то игрок на BB принимает решение последним на префлопе.
  title_ru: Последний на префлопе
  runnerPrompt_ru: Большой блайнд закрывает торговлю на префлопе, если не было рейзов.
  runnerSupport_ru: Нажми на игрока, который принимает решение последним на префлопе.
  runnerQuestion_ru: Нажми на BB.

- taskId: blinds_postflop_button
  status: landed_or_partial
  title_en: Last postflop actor
  phase: drill
  stepKind: practice
  runner: _postflopButtonActorRunner
  runnerPrompt_en: After the flop, Button often acts last.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the last postflop actor.
  teachingStep0_title_en: Postflop order changes.
  teachingStep0_body_en: After the flop, blinds act early and Button often acts last.
  teachingStep0_title_ru: Порядок хода после флопа меняется.
  teachingStep0_body_ru: После выхода флопа блайнды ходят первыми (в ранней позиции), а баттон (BTN) часто принимает решение последним.
  title_ru: Последний на постфлопе
  runnerPrompt_ru: После флопа баттон чаще всего действует последним.
  runnerSupport_ru: Нажми на BTN.
  runnerQuestion_ru: Нажми на игрока, который ходит последним на постфлопе.

- taskId: blinds_button_moves
  status: landed_or_partial
  title_en: Button moves
  phase: drill
  stepKind: practice
  runner: _buttonMovesRunner
  runnerPrompt_en: The Button moves one seat after each hand.
  runnerSupport_en: That keeps blinds and late position rotating.
  runnerQuestion_en: Which marker shows the dealer button this hand?
  teachingStep0_title_en: Button rotates.
  teachingStep0_body_en: After each hand, the button moves so blinds rotate too.
  teachingStep0_title_ru: Кнопка баттона перемещается.
  teachingStep0_body_ru: После каждой раздачи кнопка баттона сдвигается на одно место по часовой стрелке, благодаря чему позиции блайндов тоже меняются.
  title_ru: Баттон двигается
  runnerPrompt_ru: Баттон сдвигается на одно место после каждой раздачи.
  runnerSupport_ru: Это позволяет позициям блайндов и поздних мест постоянно меняться.
  runnerQuestion_ru: Какой маркер указывает на баттон дилера в этой раздаче?

- taskId: seat_order_decision
  status: missing
  title_en: Who acts earlier?
  phase: drill
  stepKind: practice
  runner: _w3SeatOrderDecisionRunner
  runnerPrompt_en: UTG and BTN are visible. One acts before the other preflop.
  runnerSupport_en: Earlier seats get less information first.
  runnerQuestion_en: Which seat acts before BTN?
  teachingStep0_title_en: Order matters before comfort.
  teachingStep0_body_en: UTG acts before BTN.
  teachingStep0_title_ru: Ранние места решают раньше.
  teachingStep0_body_ru: Когда ты говоришь первым, у тебя меньше подсказок и меньше права на надежду. Поэтому ранняя позиция всегда требует большей силы.
  teachingStep1_title_en: Information arrives later.
  teachingStep1_body_en: BTN can use more late-position information.
  teachingStep1_title_ru: Информация приходит позже.
  teachingStep1_body_ru: Баттон (BTN) может принимать решение, владея максимальным объёмом информации о действиях других игроков.
  title_ru: Кто действует раньше?
  runnerPrompt_ru: Ранние места принимают решение с меньшим количеством информации, чем поздние.
  runnerSupport_ru: UTG — ранняя позиция. BTN — поздняя.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: blinds_review
  status: landed_or_partial
  title_en: Order recap
  phase: review
  stepKind: proveIt
  runner: _blindsOrderRecapRunner
  runnerPrompt_en: Lesson learned: blinds start the order.
  runnerSupport_en: SB posts 0.5, BB posts 1, then action begins around the table.
  runnerQuestion_en: Who acts first preflop?
  teachingStep0_title_en: Order takeaway.
  teachingStep0_body_en: Blinds post first. Then each street follows the table order.
  teachingStep0_title_ru: Главное о порядке хода.
  teachingStep0_body_ru: Сначала ставятся блайнды. Затем на каждой следующей улице торговля идёт по стандартному кругу.
  title_ru: Повтор по порядку
  runnerPrompt_ru: Главный вывод урока: блайнды задают порядок хода.
  runnerSupport_ru: Малый блайнд ставит 0.5, большой — 1, после чего начинается игра по кругу.
  runnerQuestion_ru: Кто ходит первым на префлопе после блайндов?

## lesson button_advantage
status: landed_or_partial
title_en: Button advantage
subtitle_en: The Button often acts last and sees more.
title_ru: Преимущество баттона
subtitle_ru: Баттон часто действует последним и видит больше.

- taskId: button_intro
  status: missing
  title_en: Best seat
  phase: theory
  stepKind: learn
  runner: _world2PositionIntroRunner
  runnerPrompt_en: The same hand feels different from early and late seats.
  runnerSupport_en: Late seats act after seeing more decisions.
  runnerQuestion_en: Why can late position help?
  teachingStep0_title_en: Position is information.
  teachingStep0_body_en: Early seats decide sooner. Late seats see more before acting.
  teachingStep0_title_ru: Позиция — это информация.
  teachingStep0_body_ru: Ранние места решают раньше. Поздние сначала смотрят на остальных. Поэтому одна и та же рука ощущается по-разному.
  title_ru: Лучшее место
  runnerPrompt_ru: Одна и та же рука ощущается по-разному в ранней и поздней позиции.
  runnerSupport_ru: Поздние места принимают решение уже после того, как увидели больше чужих действий.
  runnerQuestion_ru: Почему поздняя позиция вообще помогает?

- taskId: find_button
  status: missing
  title_en: Tap BTN
  phase: drill
  stepKind: practice
  runner: _buttonSeatRunner
  runnerPrompt_en: Button is the dealer seat in this hand.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the Button.
  teachingStep0_title_en: BTN marks the Button.
  teachingStep0_body_en: The dealer button shows the late seat for this hand.
  teachingStep0_title_ru: BTN отмечает баттон.
  teachingStep0_body_ru: Баттон показывает место дилера в этой раздаче. После флопа он часто закрывает действие.
  title_ru: Найди BTN
  runnerPrompt_ru: Баттон показывает место дилера в этой раздаче.
  runnerSupport_ru: Нажми на BTN.
  runnerQuestion_ru: Где здесь баттон?

- taskId: button_open
  status: missing
  title_en: BTN first-in open
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука поздно.
  teachingStep0_body_ru: KTs на баттоне спокойно открывается, если до тебя никто не вошёл в банк. Позиция здесь работает на тебя.
  title_ru: Баттон открывает первым
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь выглядит самым простым?

- taskId: button_last
  status: missing
  title_en: Acts last
  phase: drill
  stepKind: practice
  runner: _postflopButtonActorRunner
  runnerPrompt_en: After the flop, Button often acts last.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the last postflop actor.
  teachingStep0_title_en: Postflop order changes.
  teachingStep0_body_en: After the flop, blinds act early and Button often acts last.
  teachingStep0_title_ru: Порядок после флопа меняется.
  teachingStep0_body_ru: После флопа блайнды действуют раньше, а баттон часто заканчивает круг последним. Это и есть его главное удобство.
  title_ru: Действует последним
  runnerPrompt_ru: После флопа баттон часто действует последним.
  runnerSupport_ru: Нажми на BTN.
  runnerQuestion_ru: Какое место здесь закрывает действие после флопа?

- taskId: button_vs_cutoff
  status: missing
  title_en: BTN vs CO
  phase: drill
  stepKind: practice
  runner: _w3LateSeatContrastRunner
  runnerPrompt_en: CO is late, but BTN still acts after CO.
  runnerSupport_en: Compare the two latest seats directly.
  runnerQuestion_en: Which seat is later than CO?
  teachingStep0_title_en: Late has levels.
  teachingStep0_body_en: Cutoff is late, but Button still gets the final late-position edge.
  teachingStep0_title_ru: Поздно — значит видеть больше.
  teachingStep0_body_ru: И баттон, и cutoff поздние, но баттон обычно получает ещё больше информации. Это и делает его лучшим местом.
  title_ru: Баттон против cutoff
  runnerPrompt_ru: Поздние места видят больше действий до решения.
  runnerSupport_ru: Баттон — самый чистый пример поздней позиции.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

- taskId: button_recap
  status: missing
  title_en: Button recap
  phase: review
  stepKind: review
  runner: _world2PositionRecapRunner
  runnerPrompt_en: Lesson learned: hand value depends on seat context.
  runnerSupport_en: A later seat usually has more information before choosing.
  runnerQuestion_en: Which seat usually sees more first?
  teachingStep0_title_en: Position-value checklist.
  teachingStep0_body_en: Name the seat, note who acts first, then compare the hand.
  teachingStep0_title_ru: Проверка ценности позиции.
  teachingStep0_body_ru: Сначала назови место, потом посмотри, кто действует раньше, и только потом оценивай удобство руки. Так баттон перестаёт быть просто значком.
  title_ru: Повтор по баттону
  runnerPrompt_ru: Главная мысль урока: ценность руки зависит от места за столом.
  runnerSupport_ru: Более поздняя позиция обычно даёт больше информации до решения.
  runnerQuestion_ru: Какое место чаще всего видит больше остальных?

## lesson early_vs_late
status: landed_or_partial
title_en: Early vs late
subtitle_en: Early seats decide with less information.
title_ru: Ранние и поздние места
subtitle_ru: Ранние места решают с меньшим объёмом информации.

- taskId: w2_position_intro
  status: missing
  title_en: Info changes
  phase: theory
  stepKind: learn
  runner: _world2PositionIntroRunner
  runnerPrompt_en: The same hand feels different from early and late seats.
  runnerSupport_en: Late seats act after seeing more decisions.
  runnerQuestion_en: Why can late position help?
  teachingStep0_title_en: Position is information.
  teachingStep0_body_en: Early seats decide sooner. Late seats see more before acting.
  teachingStep0_title_ru: Позиция — это информация.
  teachingStep0_body_ru: Ранние места действуют раньше. Поздние успевают увидеть больше чужих решений. Поэтому одна и та же рука играет по-разному.
  title_ru: Информация меняется
  runnerPrompt_ru: Одна и та же рука ощущается по-разному в ранней и поздней позиции.
  runnerSupport_ru: Поздние места принимают решение уже после того, как увидели больше действий.
  runnerQuestion_ru: Почему поздняя позиция вообще может помочь?

- taskId: w2_late_position
  status: missing
  title_en: Late seat
  phase: drill
  stepKind: practice
  runner: _latePositionRunner
  runnerPrompt_en: Late seats see more actions before deciding.
  runnerSupport_en: Button is the clearest late seat.
  runnerQuestion_en: Which seat acts latest after the flop?
  teachingStep0_title_en: Late means more information.
  teachingStep0_body_en: Late seats see more choices before they decide.
  teachingStep0_title_ru: Поздно — значит видеть больше.
  teachingStep0_body_ru: Поздние места успевают собрать больше подсказок до своего решения. Это и создаёт их преимущество.
  title_ru: Поздняя позиция
  runnerPrompt_ru: Поздние места видят больше действий до решения.
  runnerSupport_ru: Баттон — самый наглядный пример поздней позиции.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

- taskId: w2_early_position
  status: missing
  title_en: Early seat
  phase: drill
  stepKind: practice
  runner: _earlyLatePositionRunner
  runnerPrompt_en: Early seats act with less information than late seats.
  runnerSupport_en: UTG is early. BTN is late.
  runnerQuestion_en: Which seat is early preflop?
  teachingStep0_title_en: Early seats decide sooner.
  teachingStep0_body_en: UTG acts before seeing what most players will do.
  teachingStep0_title_ru: Ранние места решают раньше.
  teachingStep0_body_ru: UTG действует ещё до того, как большинство игроков что-то показали. Поэтому ранняя позиция всегда требует большей осторожности.
  title_ru: Ранняя позиция
  runnerPrompt_ru: Ранние места принимают решение с меньшим количеством информации, чем поздние.
  runnerSupport_ru: UTG — ранняя позиция. BTN — поздняя.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: early_pressure_choice
  status: missing
  title_en: Early pressure
  phase: drill
  stepKind: practice
  runner: _w3EarlySeatPressureRunner
  runnerPrompt_en: UTG must act before HJ, CO, BTN, SB, and BB.
  runnerSupport_en: More players behind means more pressure on the opening range.
  runnerQuestion_en: Why does UTG need more discipline here?
  teachingStep0_title_en: Early means pressure first.
  teachingStep0_body_en: UTG faces the most unseen decisions behind, so discipline starts there.
  teachingStep0_title_ru: Раннее давление реально.
  teachingStep0_body_ru: Когда ты говоришь первым, ошибиться легче, потому что подсказок меньше. Поэтому ранняя позиция и давит сильнее.
  title_ru: Давление ранней позиции
  runnerPrompt_ru: Ранние места действуют с меньшим количеством информации, чем поздние.
  runnerSupport_ru: UTG — ранняя позиция. BTN — поздняя.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: late_info_choice
  status: missing
  title_en: Late info edge
  phase: drill
  stepKind: practice
  runner: _w3LateInfoEdgeRunner
  runnerPrompt_en: CO already saw UTG and HJ fold before acting.
  runnerSupport_en: Late comfort comes from fewer players left to act.
  runnerQuestion_en: What gives CO more comfort than UTG here?
  teachingStep0_title_en: Late edge is practical.
  teachingStep0_body_en: Seeing two folds before CO acts is already more information than UTG gets.
  teachingStep0_title_ru: Поздняя позиция даёт край.
  teachingStep0_body_ru: Позднее место не делает руку сильнее само по себе, но даёт больше информации и чаще облегчает решение.
  title_ru: Преимущество поздней позиции
  runnerPrompt_ru: Поздние места видят больше действий до решения.
  runnerSupport_ru: Баттон — самый понятный пример места с информационным преимуществом.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

- taskId: w2_position_recap
  status: missing
  title_en: Position recap
  phase: review
  stepKind: review
  runner: _world2PositionRecapRunner
  runnerPrompt_en: Lesson learned: hand value depends on seat context.
  runnerSupport_en: A later seat usually has more information before choosing.
  runnerQuestion_en: Which seat usually sees more first?
  teachingStep0_title_en: Position-value checklist.
  teachingStep0_body_en: Name the seat, note who acts first, then compare the hand.
  teachingStep0_title_ru: Проверка по позиции.
  teachingStep0_body_ru: Назови место, посмотри, кто действует раньше, и только потом сравни комфорт руки. Так раннее и позднее место читаются без путаницы.
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль урока: ценность руки зависит от места за столом.
  runnerSupport_ru: Более поздняя позиция обычно даёт больше информации до решения.
  runnerQuestion_ru: Какое место чаще видит больше остальных?

## lesson same_hand_different_seat
status: landed_or_partial
title_en: Same hand, different seat
subtitle_en: A seat can change how comfortable a hand is.
title_ru: Одна рука, разные места
subtitle_ru: Место за столом меняет комфорт одной и той же руки.

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
  teachingStep0_title_ru: У руки нет вечного ответа.
  teachingStep0_body_ru: Перед действием снова проверь группу руки, своё место и то, открылся ли кто-то уже до тебя. Контекст важнее привычки.
  title_ru: Сначала контекст
  runnerPrompt_ru: Одна и та же рука может играться по-разному, если меняется ситуация.
  runnerSupport_ru: Вход первым, игра против открытия и ранняя позиция — это разные рамки.
  runnerQuestion_ru: Что нужно перепроверить до действия?

- taskId: w3_same_hand_open
  status: missing
  title_en: Open frame
  phase: drill
  stepKind: practice
  runner: _world3CutoffOpenRunner
  runnerPrompt_en: Folded to CO with AJo.
  runnerSupport_en: Cutoff is late, but Button and blinds still remain behind.
  runnerQuestion_en: What is the cleaner first-in action from CO?
  teachingStep0_title_en: Late, but not last.
  teachingStep0_body_en: AJo can open from CO, but you still respect the Button behind you.
  teachingStep0_title_ru: Играбельная рука поздно.
  teachingStep0_body_ru: KTs на баттоне спокойно открывается, если до тебя никто не вошёл в банк. Здесь и рука, и место работают вместе.
  title_ru: Та же рука открывает
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_same_hand_call
  status: missing
  title_en: Call frame
  phase: drill
  stepKind: practice
  runner: _world3CutoffCallRunner
  runnerPrompt_en: HJ opened. Hero is CO with KQo.
  runnerSupport_en: Same hand, one seat earlier, still facing an opener.
  runnerQuestion_en: What is the cleaner response from CO?
  teachingStep0_title_en: Same hand, tighter seat.
  teachingStep0_body_en: KQo still continues here, but one earlier seat makes the call a little less comfortable.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo можно просто коллировать открытие, когда ты действуешь после CO. Та же категория руки в новой рамке ведёт уже к другому действию.
  title_ru: Та же рука коллирует
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: same_hand_early_fold
  status: missing
  title_en: Early seat fold
  phase: drill
  stepKind: practice
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Ранняя позиция легко превращает пограничную руку в спокойный пас. Здесь комфорт руки уже совсем другой.
  title_ru: Та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: same_hand_late_open
  status: missing
  title_en: Late seat open
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  runnerPrompt_en: Unopened pot. Hero is late with ATo.
  runnerSupport_en: Late position supports a clean open with this playable hand.
  runnerQuestion_en: What is the simple action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Поздняя позиция облегчает решение.
  teachingStep0_body_ru: В поздней позиции ATo уже играет заметно комфортнее. Та же рука получает больше свободы просто из-за места.
  title_ru: Поздняя позиция открывает
  runnerPrompt_ru: Банк не открыт. Ты в поздней позиции с ATo.
  runnerSupport_ru: Поздняя позиция поддерживает чистое открытие с такой играбельной рукой.
  runnerQuestion_ru: Какое действие здесь выглядит самым простым?

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
  teachingStep0_title_ru: Проверка по рамке.
  teachingStep0_body_ru: Сначала спроси, банк уже открыт или нет, и только потом ищи действие. Так исчезает ловушка мышления «одна рука — один ответ».
  title_ru: Повтор по рамке
  runnerPrompt_ru: Главная мысль урока: контекст меняет действие той же самой руки.
  runnerSupport_ru: Одна и та же рука может открыть первой, коллировать против открытия или уйти в пас в худшей рамке.
  runnerQuestion_ru: Что защищает от мышления «одна рука — один ответ»?

## lesson position_apply
status: landed_or_partial
title_en: Position at the table
subtitle_en: Seat shapes the decision before anything else.
title_ru: Позиция за столом
subtitle_ru: Место за столом меняет решение ещё до действия.

- taskId: position_apply_intro
  status: landed_or_partial
  title_en: Position shapes action
  phase: theory
  stepKind: learn
  runner: _w3PositionApplyIntroRunner
  runnerPrompt_en: Position tells you how comfortable a hand is before you act.
  runnerSupport_en: BTN is the best seat. UTG needs stronger hands to open. No charts needed yet.
  runnerQuestion_en: Why does position matter at the table?
  teachingStep0_title_en: Seat, then hand.
  teachingStep0_body_en: Check where you sit before deciding what to do with the hand.
  teachingStep0_title_ru: Сначала место, потом рука.
  teachingStep0_body_ru: Сначала посмотри, где ты сидишь, и только потом решай, что делать с рукой.
  title_ru: Позиция меняет решение
  runnerPrompt_ru: Позиция заранее подсказывает, насколько руке будет удобно.
  runnerSupport_ru: Баттон даёт больше свободы, ранние места требуют большей аккуратности. Чарты пока не нужны.
  runnerQuestion_ru: Почему позиция так важна за столом?

- taskId: position_apply_btn_open
  status: landed_or_partial
  title_en: BTN: open strong hand
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenQtsRunner
  runnerPrompt_en: Folded to BTN with QTs.
  runnerSupport_en: Same late seat, different playable hand, same clean open-or-fold rule.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: QTs can still open first in from the Button.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играет открытием, если до тебя никто не вошёл в банк.
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
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: Поздняя позиция делает такую руку удобной для простого открытия, а не для пассивного входа.
  title_ru: Поздняя позиция: открыть или зайти пассивно?
  runnerPrompt_ru: Банк не открыт. Ты в поздней позиции с ATo.
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
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Ранняя позиция часто превращает пограничную руку в спокойный пас.
  title_ru: Ранняя позиция: та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже и не требует упрямства.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_apply_hj_fold
  status: landed_or_partial
  title_en: HJ: discipline hold
  phase: drill
  stepKind: fixMistakes
  runner: _world3HijDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is HJ with KTo.
  runnerSupport_en: Middle position still needs discipline when the offsuit hand gets loose.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Middle still needs discipline.
  teachingStep0_body_en: KTo from HJ is still too loose to auto-open just because UTG folded first.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Если место за столом неудобное, даже знакомая рука не обязана продолжать.
  title_ru: HJ: держим дисциплину
  runnerPrompt_ru: Банк не открыт. Ты в HJ с ATo.
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
  teachingStep0_title_en: Position checklist.
  teachingStep0_body_en: Bucket the hand, then ask if the seat helps or hurts.
  teachingStep0_title_ru: Короткая проверка по позиции.
  teachingStep0_body_ru: Сначала определи группу руки, потом спроси себя, помогает тебе это место или мешает.
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль проста: позиция меняет комфорт ещё до действия.
  runnerSupport_ru: Поздние места помогают, ранние требуют более крепкой руки и более чистой причины продолжать.
  runnerQuestion_ru: На что нужно смотреть сразу после группы руки?

## lesson position_checkpoint
status: landed_or_partial
title_en: Position checkpoint
subtitle_en: Use seat order before choosing an action.
title_ru: Проверка позиции
subtitle_ru: Сначала прочитай место за столом, потом выбирай действие.

- taskId: position_checkpoint_intro
  status: missing
  title_en: Seat before action
  phase: theory
  stepKind: learn
  runner: _world2PositionIntroRunner
  runnerPrompt_en: The same hand feels different from early and late seats.
  runnerSupport_en: Late seats act after seeing more decisions.
  runnerQuestion_en: Why can late position help?
  teachingStep0_title_en: Position is information.
  teachingStep0_body_en: Early seats decide sooner. Late seats see more before acting.
  teachingStep0_title_ru: Позиция — это информация.
  teachingStep0_body_ru: Ранние места решают раньше, поздние видят больше. Поэтому позицию нужно читать ещё до самого действия.
  title_ru: Место раньше действия
  runnerPrompt_ru: Одна и та же рука ощущается по-разному в ранней и поздней позиции.
  runnerSupport_ru: Поздние места успевают увидеть больше решений перед своим ходом.
  runnerQuestion_ru: Почему поздняя позиция вообще может помогать?

- taskId: position_checkpoint_late_open
  status: missing
  title_en: Late: open or limp?
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  runnerPrompt_en: Unopened pot. Hero is late with ATo.
  runnerSupport_en: Late position supports a clean open with this playable hand.
  runnerQuestion_en: What is the simple action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Поздняя рука открывает.
  teachingStep0_body_ru: В поздней позиции ATo уже может спокойно идти в открытие, если банк не открыт. Здесь место помогает руке.
  title_ru: Поздняя: открыть или зайти пассивно?
  runnerPrompt_ru: Банк не открыт. Ты в поздней позиции с ATo.
  runnerSupport_ru: Поздняя позиция поддерживает чистое открытие с такой играбельной рукой.
  runnerQuestion_ru: Какое действие здесь самое простое?

- taskId: position_checkpoint_early_fold
  status: missing
  title_en: Early: same hand folds
  phase: drill
  stepKind: practice
  runner: _world3CheckpointEarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is UTG with A9o.
  runnerSupport_en: A tempting ace still needs an early-seat discipline check.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Tempting ace, same discipline.
  teachingStep0_body_en: A9o still needs the early-seat fold because the seat is too exposed for a thin open.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Ранняя позиция может превратить пограничную руку в пас. Здесь уже важно не упрямство, а дисциплина.
  title_ru: Ранняя: та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_checkpoint_btn_call
  status: missing
  title_en: BTN: callable spot
  phase: drill
  stepKind: practice
  runner: _world3PositionCheckpointCallRunner
  runnerPrompt_en: HJ opened. Hero is BTN with KJs.
  runnerSupport_en: Late position helps when the hand can still continue cleanly.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Seat plus hand class.
  teachingStep0_body_en: KJs is not just late-position noise. The hand still needs enough playability to continue cleanly.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто коллировать простое открытие, когда ты действуешь после CO. Здесь место помогает руке продолжать.
  title_ru: Баттон: колл в удобной рамке
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может остаться в раздаче через спокойный колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: position_checkpoint_table_notice
  status: missing
  title_en: Real-table seat read
  phase: drill
  stepKind: practice
  runner: _w3TablePositionNoticeRunner
  runnerPrompt_en: Real table. Hero is CO with QJs and three seats still act after.
  runnerSupport_en: Before choosing an action, notice what the seat order gives you.
  runnerQuestion_en: What is the clean seat read here?
  teachingStep0_title_en: Seat read before action.
  teachingStep0_body_en: Late position helps, but Cutoff still leaves Button and the blinds behind you.
  teachingStep0_title_ru: Сначала место, потом действие.
  teachingStep0_body_ru: Поздняя позиция помогает, но cutoff всё ещё оставляет за спиной баттон и блайнды. Даже поздние места имеют разный вес.
  title_ru: Чтение места за живым столом
  runnerPrompt_ru: Живой стол. Ты в cutoff с QJs, и после тебя ещё три места.
  runnerSupport_ru: До действия сначала пойми, что именно даёт тебе это место и кто ещё остаётся за спиной.
  runnerQuestion_ru: Какое чтение позиции здесь будет самым чистым?

- taskId: position_checkpoint_review
  status: missing
  title_en: Position recap
  phase: review
  stepKind: proveIt
  runner: _world3PositionRecapRunner
  runnerPrompt_en: Lesson learned: position changes preflop comfort.
  runnerSupport_en: Late helps. Early demands stronger buckets and cleaner frames.
  runnerQuestion_en: What should you check after the bucket?
  teachingStep0_title_en: Position checklist.
  teachingStep0_body_en: Bucket the hand, then ask if the seat helps or hurts.
  teachingStep0_title_ru: Проверка по позиции.
  teachingStep0_body_ru: Сначала назови группу руки, потом спроси, помогает тебе место или мешает. Именно это и закрывает тему позиции.
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль урока: позиция меняет префлоп-комфорт ещё до действия.
  runnerSupport_ru: Поздние места помогают, ранние требуют более крепкой группы руки и более чистой рамки.
  runnerQuestion_ru: На что нужно посмотреть сразу после группы руки?
