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

## lesson effective_stack_basics
status: missing
title_en: Effective stack
subtitle_en: The smaller stack sets the maximum risk in the hand.
title_ru: Эффективный стек
subtitle_ru: Меньший стек задаёт предел риска в раздаче.

- taskId: w7_effective_stack_intro
  status: missing
  title_en: Smaller stack rules
  phase: theory
  stepKind: learn
  runner: _w7EffectiveStackIntroRunner
  runnerPrompt_en: The smaller stack sets the maximum risk in the hand.
  runnerSupport_en: No one can win or lose more than the smaller stack.
  runnerQuestion_en: What is the effective stack?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: Если у тебя 200 BB, а у соперника 30 BB, реально в раздаче разыгрываются только 30 BB. Именно этот меньший стек и задаёт настоящий риск.
  title_ru: Меньший стек решает
  runnerPrompt_ru: Максимальный риск в раздаче задаёт меньший стек.
  runnerSupport_ru: Никто не может выиграть или проиграть больше, чем меньший стек.
  runnerQuestion_ru: Что такое эффективный стек?

- taskId: w7_effective_stack_30bb
  status: missing
  title_en: 200 vs 30
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackThirtyRunner
  runnerPrompt_en: Hero has 200 BB. Villain has 30 BB.
  runnerSupport_en: Look for the smaller stack.
  runnerQuestion_en: What is the effective stack?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: Не смотри на то, сколько покрываешь сам. Сначала найди меньший стек между двумя игроками.
  title_ru: 200 против 30
  runnerPrompt_ru: У тебя 200 BB. У соперника 30 BB.
  runnerSupport_ru: Ищи меньший стек.
  runnerQuestion_ru: Какой здесь эффективный стек?

- taskId: w7_effective_stack_100bb
  status: missing
  title_en: 100 vs 100
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackEvenRunner
  runnerPrompt_en: Hero has 100 BB. Villain has 100 BB.
  runnerSupport_en: Equal stacks keep the full depth in play.
  runnerQuestion_en: What is the effective stack?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: Когда стеки равны, в игре остаётся вся их глубина. Здесь эффективный стек совпадает с обоими.
  title_ru: 100 против 100
  runnerPrompt_ru: У тебя 100 BB. У соперника 100 BB.
  runnerSupport_ru: Равные стеки оставляют в игре полную глубину.
  runnerQuestion_ru: Какой здесь эффективный стек?

- taskId: w7_table_effective_notice
  status: missing
  title_en: Find the real risk
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackTableNoticeRunner
  runnerPrompt_en: You cover a player 120 BB to 18 BB on a real table.
  runnerSupport_en: Notice the number that caps the real risk.
  runnerQuestion_en: What should you notice first before planning?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: За живым столом легко смотреть на свой большой стек и забыть о лимите риска. Полезнее сразу заметить, сколько реально можно проиграть или выиграть.
  title_ru: Найди реальный риск
  runnerPrompt_ru: Ты покрываешь соперника: 120 BB против 18 BB за реальным столом.
  runnerSupport_ru: Заметь число, которое ставит потолок настоящему риску.
  runnerQuestion_ru: Что нужно увидеть первым до любого плана?

- taskId: w7_effective_stack_recap
  status: missing
  title_en: Effective stack recap
  phase: review
  stepKind: review
  runner: _w7EffectiveStackRecapRunner
  runnerPrompt_en: Lesson learned: the smaller stack sets the hand risk.
  runnerSupport_en: Effective stack tells you how much room the hand really has.
  runnerQuestion_en: Why does effective stack matter?
  teachingStep0_title_en: Risk starts here.
  teachingStep0_body_en: Find the smaller stack first. That tells you how deep the hand really plays.
  teachingStep0_title_ru: Риск начинается здесь.
  teachingStep0_body_ru: Сначала найди меньший стек. Он сразу показывает, насколько глубоко реально будет сыграна раздача.
  title_ru: Повтор по эффективному стеку
  runnerPrompt_ru: Главная мысль урока: меньший стек задаёт риск раздачи.
  runnerSupport_ru: Эффективный стек показывает, сколько пространства у руки на самом деле.
  runnerQuestion_ru: Почему эффективный стек так важен?

## lesson same_hand_different_depth
status: missing
title_en: Same hand, different depth
subtitle_en: A hand can widen at 20 BB and tighten at 100 BB.
title_ru: Одна рука, разная глубина
subtitle_ru: Одна и та же рука при 20 BB играется шире, чем при 100 BB.

- taskId: w7_depth_shift_intro
  status: missing
  title_en: Depth changes the plan
  phase: theory
  stepKind: learn
  runner: _w7DepthShiftIntroRunner
  runnerPrompt_en: The same hand can widen at 20 BB and tighten at 100 BB.
  runnerSupport_en: Short stacks simplify decisions. Deep stacks create more future risk.
  runnerQuestion_en: Why does stack depth change the plan?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: При 20 BB решений на будущих улицах меньше, поэтому многие руки играются проще. При 100 BB остаётся больше денег позади, и риск второй по силе руки растёт.
  title_ru: Глубина меняет план
  runnerPrompt_ru: Одна и та же рука при 20 BB может открываться шире, чем при 100 BB.
  runnerSupport_ru: Короткие стеки упрощают решение. Глубокие стеки добавляют будущий риск.
  runnerQuestion_ru: Почему глубина стека меняет план?

- taskId: w7_20bb_wider
  status: missing
  title_en: 20 BB decision
  phase: drill
  stepKind: practice
  runner: _w7TwentyBbWiderRunner
  runnerPrompt_en: You hold A-J suited with 20 BB effective.
  runnerSupport_en: Shorter stacks reduce the postflop burden.
  runnerQuestion_en: Which depth usually plays this hand more simply and more often?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: С коротким стеком меньше пространства для тяжёлых постфлоп-ошибок, поэтому многие руки играются прямее и чаще.
  title_ru: Решение при 20 BB
  runnerPrompt_ru: У тебя одномастные A-J и эффективный стек 20 BB.
  runnerSupport_ru: Короткий стек снимает часть постфлоп-нагрузки.
  runnerQuestion_ru: При какой глубине эта рука обычно играется проще и чаще?

- taskId: w7_100bb_tighter
  status: missing
  title_en: 100 BB decision
  phase: drill
  stepKind: practice
  runner: _w7HundredBbTighterRunner
  runnerPrompt_en: Now look at the same hand with 100 BB effective.
  runnerSupport_en: More streets create more ways to make a second-best hand.
  runnerQuestion_en: What changes when the hand is 100 BB deep?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: При 100 BB впереди больше улиц и больше шансов попасть во вторую по силе руку. Поэтому диапазон часто становится аккуратнее.
  title_ru: Решение при 100 BB
  runnerPrompt_ru: Теперь посмотри на ту же руку при 100 BB эффективных.
  runnerSupport_ru: Больше улиц — больше способов проиграть второй по силе рукой.
  runnerQuestion_ru: Что меняется, когда глубина уже 100 BB?

- taskId: w7_40bb_middle
  status: missing
  title_en: 40 BB middle plan
  phase: drill
  stepKind: practice
  runner: _w7FortyBbMiddleRunner
  runnerPrompt_en: Now the same hand plays 40 BB effective.
  runnerSupport_en: This is not pure jam depth and not carefree deep depth.
  runnerQuestion_en: What is the cleaner 40 BB read?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: 40 BB — это уже не пуш-фолд, но ещё и не беззаботная глубина. Здесь нужен средний, более дисциплинированный план.
  title_ru: План при 40 BB
  runnerPrompt_ru: Теперь та же рука играется при 40 BB эффективных.
  runnerSupport_ru: Это уже не чистый пуш-стек, но и не свободная глубокая игра.
  runnerQuestion_ru: Какой вывод о 40 BB здесь самый чистый?

- taskId: w7_depth_shift_recap
  status: missing
  title_en: Depth recap
  phase: review
  stepKind: review
  runner: _w7DepthShiftRecapRunner
  runnerPrompt_en: Lesson learned: stack depth changes hand value and plan.
  runnerSupport_en: Short stacks simplify. Deep stacks ask for more caution.
  runnerQuestion_en: What changes when stack depth changes?
  teachingStep0_title_en: Same hand, new plan.
  teachingStep0_body_en: Do not memorize one answer for every hand. Depth changes what the hand can safely do.
  teachingStep0_title_ru: Та же рука, новый план.
  teachingStep0_body_ru: Не запоминай один ответ на руку навсегда. Глубина меняет, что эта рука может делать безопасно.
  title_ru: Повтор по глубине
  runnerPrompt_ru: Главная мысль урока: глубина стека меняет ценность руки и план розыгрыша.
  runnerSupport_ru: Короткий стек упрощает. Глубокий просит больше аккуратности.
  runnerQuestion_ru: Что меняется, когда меняется глубина стека?

## lesson spr_and_commitment
status: missing
title_en: Room or commitment
subtitle_en: Low SPR means less room. High SPR means more room to maneuver.
title_ru: Пространство или привязка
subtitle_ru: Низкий SPR, то есть отношение стека к банку, оставляет мало пространства, высокий — больше манёвра.

- taskId: w7_spr_intro
  status: missing
  title_en: Low room vs high room
  phase: theory
  stepKind: learn
  runner: _w7SprIntroRunner
  runnerPrompt_en: SPR tells you how much room is left after the flop.
  runnerSupport_en: Low SPR means little room. High SPR means more room to maneuver.
  runnerQuestion_en: What does low SPR usually mean?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: Когда SPR, то есть отношение стека к банку, низкий, одна ставка уже может почти привязать тебя к банку. Когда SPR высокий, ещё остаётся пространство для паса, блефа или контроля банка.
  title_ru: Мало места против большого
  runnerPrompt_ru: SPR, то есть отношение стека к банку, показывает, сколько пространства остаётся после флопа.
  runnerSupport_ru: Низкий SPR — это мало места. Высокий SPR — больше манёвра.
  runnerQuestion_ru: Что обычно означает низкий SPR?

- taskId: w7_low_spr_commit
  status: missing
  title_en: SPR 2
  phase: drill
  stepKind: practice
  runner: _w7LowSprCommitRunner
  runnerPrompt_en: SPR is 2 on the flop and you hold top pair.
  runnerSupport_en: Little room is left.
  runnerQuestion_en: What does low SPR usually tell you?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: При SPR 2 на решение остаётся совсем немного воздуха. Здесь раздача часто быстро идёт к привязке.
  title_ru: SPR 2
  runnerPrompt_ru: На флопе SPR равен 2, и у тебя топ-пара.
  runnerSupport_ru: Пространства осталось совсем мало.
  runnerQuestion_ru: О чём обычно говорит низкий SPR?

- taskId: w7_high_spr_room
  status: missing
  title_en: SPR 8
  phase: drill
  stepKind: practice
  runner: _w7HighSprRoomRunner
  runnerPrompt_en: SPR is 8 on the flop.
  runnerSupport_en: A lot of stack is still behind.
  runnerQuestion_en: What does high SPR usually give you?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: При SPR 8 за спиной ещё много стека, поэтому раздача не обязана ускоряться сразу. У тебя остаётся выбор на следующих улицах.
  title_ru: SPR 8
  runnerPrompt_ru: На флопе SPR равен 8.
  runnerSupport_ru: За спиной ещё много стека.
  runnerQuestion_ru: Что обычно даёт высокий SPR?

- taskId: w7_spr4_middle
  status: missing
  title_en: SPR 4
  phase: drill
  stepKind: practice
  runner: _w7SprFourRunner
  runnerPrompt_en: SPR is 4 with one pair and some stack still behind.
  runnerSupport_en: Middle SPR is neither pure jam nor huge freedom.
  runnerQuestion_en: What does SPR 4 usually feel like?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: SPR 4 — это середина: не мгновенная привязка, но и не полная свобода. Здесь особенно важно чувствовать баланс пространства.
  title_ru: SPR 4
  runnerPrompt_ru: SPR равен 4, у тебя одна пара и часть стека ещё позади.
  runnerSupport_ru: Средний SPR — это не чистый олл-ин и не полная свобода.
  runnerQuestion_ru: Как обычно ощущается SPR 4?

- taskId: w7_spr_recap
  status: missing
  title_en: SPR recap
  phase: review
  stepKind: review
  runner: _w7SprRecapRunner
  runnerPrompt_en: Lesson learned: low SPR pushes commitment, high SPR keeps room.
  runnerSupport_en: Do not treat every flop the same when stack room changes.
  runnerQuestion_en: What does SPR help you feel?
  teachingStep0_title_en: Room matters.
  teachingStep0_body_en: Low SPR speeds up commitment. High SPR keeps later-street choices alive.
  teachingStep0_title_ru: Пространство имеет значение.
  teachingStep0_body_ru: Низкий SPR ускоряет привязку к банку. Высокий SPR оставляет живыми решения на следующих улицах.
  title_ru: Повтор по SPR
  runnerPrompt_ru: Главная мысль урока: низкий SPR тянет к привязке, высокий оставляет место.
  runnerSupport_ru: Не играй каждый флоп одинаково, если пространство в раздаче разное.
  runnerQuestion_ru: Что помогает почувствовать SPR?

## lesson format_pressure
status: missing
title_en: 6-max vs full ring
subtitle_en: The same hand can open wider in 6-max than in full ring.
title_ru: 6-max и полный стол
subtitle_ru: Одна и та же рука в 6-max открывается шире, чем за полным столом.

- taskId: w7_format_intro
  status: missing
  title_en: Format changes pressure
  phase: theory
  stepKind: learn
  runner: _w7FormatPressureIntroRunner
  runnerPrompt_en: The same hand can open wider in 6-max than in full ring.
  runnerSupport_en: Fewer players behind means less chance someone wakes up with a premium hand.
  runnerQuestion_en: Why does 6-max usually widen ranges?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: В 6-max за тобой меньше игроков, которые могут найти руку сильнее. Поэтому диапазоны открытия там обычно шире, чем за полным столом.
  title_ru: Формат меняет давление
  runnerPrompt_ru: Одна и та же рука в 6-max может открываться шире, чем за полным столом.
  runnerSupport_ru: Чем меньше игроков позади, тем ниже шанс, что кто-то проснётся с премиум-рукой.
  runnerQuestion_ru: Почему 6-max обычно расширяет диапазоны?

- taskId: w7_6max_wider
  status: missing
  title_en: 6-max opens wider
  phase: drill
  stepKind: practice
  runner: _w7SixMaxWiderRunner
  runnerPrompt_en: A-J offsuit in early position.
  runnerSupport_en: Compare 6-max with 9-handed full ring.
  runnerQuestion_en: Where does this hand usually open wider?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: При одинаковой руке и позиции 6-max даёт меньше давления со стороны оставшихся игроков. Поэтому открытие там чаще выглядит нормальным.
  title_ru: В 6-max шире
  runnerPrompt_ru: Разномастные A-J на ранней позиции.
  runnerSupport_ru: Сравни 6-max и полный стол на 9 игроков.
  runnerQuestion_ru: Где эта рука обычно открывается шире?

- taskId: w7_fullring_tighter
  status: missing
  title_en: Full ring tightens
  phase: drill
  stepKind: practice
  runner: _w7FullRingTighterRunner
  runnerPrompt_en: Now imagine the same hand in full ring.
  runnerSupport_en: More players still need to act.
  runnerQuestion_en: What usually changes in full ring?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: За полным столом больше людей ещё ждут решения, поэтому давление на открытие возрастает. Та же рука часто требует больше дисциплины.
  title_ru: Полный стол сужает
  runnerPrompt_ru: Теперь представь ту же руку за полным столом.
  runnerSupport_ru: Игроков, которым ещё предстоит сказать слово, стало больше.
  runnerQuestion_ru: Что обычно меняется за полным столом?

- taskId: w7_format_table_notice
  status: missing
  title_en: Count players behind
  phase: drill
  stepKind: practice
  runner: _w7FormatTableNoticeRunner
  runnerPrompt_en: You jump from 6-max online to a 9-handed live table.
  runnerSupport_en: Start by counting how many players are still behind you.
  runnerQuestion_en: What is the first useful adjustment?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: При смене формата не начинай с самой руки. Сначала посчитай, сколько игроков ещё позади, и только потом решай, насколько широко можно открываться.
  title_ru: Посчитай игроков позади
  runnerPrompt_ru: Ты пересел с онлайн 6-max за живой стол на 9 игроков.
  runnerSupport_ru: Начни с подсчёта тех, кто ещё сидит за тобой.
  runnerQuestion_ru: Какая первая полезная поправка нужна здесь?

- taskId: w7_format_recap
  status: missing
  title_en: Format recap
  phase: review
  stepKind: review
  runner: _w7FormatRecapRunner
  runnerPrompt_en: Lesson learned: the same hand can open wider in 6-max and tighter in full ring.
  runnerSupport_en: Format changes pressure before the cards even hit the flop.
  runnerQuestion_en: Why does format change opening pressure?
  teachingStep0_title_en: Format shapes pressure.
  teachingStep0_body_en: The hand is the same, but table format changes how often someone behind wakes up with strength.
  teachingStep0_title_ru: Формат задаёт давление.
  teachingStep0_body_ru: Сама рука не изменилась, но формат меняет, как часто за спиной найдётся сила. Именно это и двигает диапазон открытия.
  title_ru: Повтор по формату
  runnerPrompt_ru: Главная мысль урока: одна и та же рука в 6-max открывается шире, а за полным столом уже.
  runnerSupport_ru: Формат меняет давление ещё до того, как карты попадут на флоп.
  runnerQuestion_ru: Почему формат меняет давление на открытие?

- taskId: w7_stack_checkpoint
  status: missing
  title_en: Stack-depth checkpoint
  phase: review
  stepKind: proveIt
  runner: _world7StackCheckpointRunner
  runnerPrompt_en: Lesson learned: depth, SPR, and format all change risk.
  runnerSupport_en: Next you will see how tournament pressure makes stack risk even sharper.
  runnerQuestion_en: What does stack-depth thinking add to range thinking?
  teachingStep0_title_en: Carry the range into risk.
  teachingStep0_body_en: Group the range first, then ask how deep the hand plays, how much room is left, and what the format changes.
  teachingStep0_title_ru: Перенеси диапазон в риск.
  teachingStep0_body_ru: Сначала собери диапазон, потом спроси, насколько глубоко играется рука, сколько пространства осталось и как формат меняет давление. Так риск становится читаемым.
  title_ru: Контрольная по глубине стека
  runnerPrompt_ru: Главная мысль блока: глубина, SPR и формат вместе меняют риск раздачи.
  runnerSupport_ru: Дальше ты увидишь, как турнирное давление делает стековый риск ещё острее.
  runnerQuestion_ru: Что добавляет к мышлению диапазонами взгляд на глубину стека?

