# world_7 RU Translation Pack

Status: GENERATED
World number: 7
EN title: Range Thinking Lite
EN subtitle: Group hands into simple buckets without solver talk.
title_ru: Диапазоны без перегруза
subtitle_ru: Группируй руки просто, без лишней теории.

## Coverage
- Lessons: 0/5
- Tasks: 0/35
- Runner prompts: 0/35
- Runner supports: 0/35
- Runner questions: 0/35
- Teaching step titles: 0/35
- Teaching step bodies: 0/35

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
title_ru: Группы диапазона
subtitle_ru: Сначала раздели руки на вэлью, кандидаты для блефа и полный промах.

- taskId: w6_range_intro
  status: missing
  title_en: Three buckets
  phase: theory
  stepKind: learn
  runner: _w6RangeIntroRunner
  runnerPrompt_en: A range is the group of hands that fit a situation.
  runnerSupport_en: Value, bluff candidate, and missed are the three range buckets.
  runnerQuestion_en: What are range buckets?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: После флопа сначала пойми, где стоит твоя рука: вэлью, кандидат для блефа или полный промах. Это даёт опору ещё до выбора действия.
  title_ru: Три группы
  runnerPrompt_ru: Диапазон — это группа рук, которые подходят под ситуацию.
  runnerSupport_ru: Дели руки на три простые группы: вэлью, возможный блеф и полный промах.
  runnerQuestion_ru: Что такое группы диапазона?

- taskId: w6_value_dry_board
  status: missing
  title_en: Value on dry board
  phase: drill
  stepKind: practice
  runner: _w6ValueDryBoardRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q.
  runnerSupport_en: Top pair with the best possible kicker.
  runnerQuestion_en: Which range bucket is K-Q on this board?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Если рука уже уверенно сильнее диапазона продолжения соперника, это обычно вэлью. Здесь сначала важна сама группа, а не размер ставки.
  title_ru: Вэлью на сухой доске
  runnerPrompt_ru: K-7-2 радугой. У тебя K-Q.
  runnerSupport_ru: Топ-пара с лучшим кикером на такой доске.
  runnerQuestion_ru: В какую группу попадает K-Q на этой доске?

- taskId: w6_missed_dry_board
  status: missing
  title_en: Missed on dry board
  phase: drill
  stepKind: practice
  runner: _w6MissedDryBoardRunner
  runnerPrompt_en: Same K-7-2 rainbow. Hero holds J-T.
  runnerSupport_en: No pair, no draw on a dry board.
  runnerQuestion_en: Which range bucket is J-T on this board?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Если у руки нет ни пары, ни дро, ни заметного давления на соперника, это обычно промах. Сначала честно назови эту группу.
  title_ru: Промах на сухой доске
  runnerPrompt_ru: Та же доска K-7-2 радугой. У тебя J-T.
  runnerSupport_ru: Ни пары, ни дро на сухом флопе.
  runnerQuestion_ru: В какую группу попадает J-T здесь?

- taskId: w6_table_bucket_notice
  status: missing
  title_en: First live read
  phase: drill
  stepKind: practice
  runner: _w6TableBucketNoticeRunner
  runnerPrompt_en: Real table. K-7-2 rainbow lands and you hold A-Q.
  runnerSupport_en: Before picking a size, make the first useful read.
  runnerQuestion_en: What should you ask first?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: За живым столом сначала не выбирай размер, а быстро пойми, что у тебя вообще за история на этой доске. Группа важнее первого импульса.
  title_ru: Первый живой вывод
  runnerPrompt_ru: Реальный стол. На флоп приходит K-7-2 радугой, у тебя A-Q.
  runnerSupport_ru: До выбора сайза сначала сделай первый полезный вывод.
  runnerQuestion_ru: Что нужно спросить себя первым?

- taskId: w6_buckets_recap
  status: missing
  title_en: Buckets recap
  phase: review
  stepKind: review
  runner: _w6BucketsRecapRunner
  runnerPrompt_en: Lesson learned: range buckets start with board fit.
  runnerSupport_en: Ask which bucket before choosing an action.
  runnerQuestion_en: Which range bucket reads the board first?
  teachingStep0_title_en: Bucket before action.
  teachingStep0_body_en: Assign your hand to a range bucket before choosing to bet, check, or fold.
  teachingStep0_title_ru: Сначала группа.
  teachingStep0_body_ru: До ставки, чека или паса сначала разложи руку по группам. Это убирает хаос и делает решение чище.
  title_ru: Повтор по группам
  runnerPrompt_ru: Главная мысль урока: группы диапазона начинаются с того, как рука попала в доску.
  runnerSupport_ru: Сначала пойми группу, потом выбирай действие.
  runnerQuestion_ru: Что в этой модели сначала читает доску?

## lesson range_board_fit
status: missing
title_en: Range meets board
subtitle_en: Board texture can shift a hand from value to missed.
title_ru: Как диапазон встречает доску
subtitle_ru: Одна и та же рука может стать вэлью на одной доске и промахом на другой.

- taskId: w6_board_fit_intro
  status: missing
  title_en: Board shifts bucket
  phase: theory
  stepKind: learn
  runner: _w6BoardFitIntroRunner
  runnerPrompt_en: Board texture can shift a hand from value to missed.
  runnerSupport_en: The same hand can be value on one board and missed on another.
  runnerQuestion_en: What changes a hand's range bucket?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: Сильная рука префлоп ещё не гарантирует сильную руку на флопе. Сначала посмотри, во что именно попала доска.
  title_ru: Доска меняет группу
  runnerPrompt_ru: Текстура доски может перевести руку из вэлью в промах.
  runnerSupport_ru: Одни и те же карты могут быть сильными на одном флопе и совсем пустыми на другом.
  runnerQuestion_ru: Что меняет группу руки?

- taskId: w6_wrong_board
  status: missing
  title_en: Missed on wet board
  phase: drill
  stepKind: practice
  runner: _w6WrongBoardRunner
  runnerPrompt_en: 8-7-6 two-tone. Hero holds K-Q.
  runnerSupport_en: K-Q was strong preflop, but this board changed everything.
  runnerQuestion_en: Which range bucket is K-Q on 8-7-6?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: K-Q выглядела красиво префлоп, но доска 8-7-6 с мастевым дро проходит мимо неё. Здесь важно отпустить прежнюю силу руки.
  title_ru: Промах на мокрой доске
  runnerPrompt_ru: 8-7-6 с двумя картами одной масти. У тебя K-Q.
  runnerSupport_ru: K-Q была сильной префлоп, но эта доска всё изменила.
  runnerQuestion_ru: В какую группу попадает K-Q на 8-7-6?

- taskId: w6_value_wet_board
  status: missing
  title_en: Value on wet board
  phase: drill
  stepKind: practice
  runner: _w6ValueWetBoardRunner
  runnerPrompt_en: Same 8-7-6 two-tone. Hero holds 9-8.
  runnerSupport_en: 9-8 flopped two pair on a connected board.
  runnerQuestion_en: Which range bucket is 9-8 on 8-7-6?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: На связанной доске две пары всё равно остаются сильной готовой рукой. Здесь доска опасная, но твоя группа по-прежнему вэлью.
  title_ru: Вэлью на мокрой доске
  runnerPrompt_ru: Та же доска 8-7-6 с двумя картами одной масти. У тебя 9-8.
  runnerSupport_ru: 9-8 попали в две пары на связанной доске.
  runnerQuestion_ru: В какую группу попадает 9-8 на 8-7-6?

- taskId: w6_turn_shift_bucket
  status: missing
  title_en: Turn changes bucket
  phase: drill
  stepKind: practice
  runner: _w6TurnShiftBucketRunner
  runnerPrompt_en: Flop gave you a bluff candidate. Turn bricks and pairs the board.
  runnerSupport_en: When pressure drops, the bucket can slide.
  runnerQuestion_en: What often happens to the hand now?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: Если тёрн убирает давление и делает твоё полублефовое продолжение слабее, рука может сдвинуться вниз по группам. Эту смену нужно замечать сразу.
  title_ru: Тёрн меняет группу
  runnerPrompt_ru: На флопе у тебя был кандидат для блефа. На тёрне бланк и спарка доски.
  runnerSupport_ru: Когда давление падает, группа руки тоже может сдвинуться.
  runnerQuestion_ru: Что часто происходит с рукой теперь?

- taskId: w6_board_fit_recap
  status: missing
  title_en: Board fit recap
  phase: review
  stepKind: review
  runner: _w6BoardFitRecapRunner
  runnerPrompt_en: Lesson learned: the same hand hits different buckets on different boards.
  runnerSupport_en: Always read the board before assigning a bucket.
  runnerQuestion_en: What decides which bucket a hand lands in?
  teachingStep0_title_en: Texture shifts buckets.
  teachingStep0_body_en: Read the board, then assign the bucket. Preflop hand strength is only the starting point.
  teachingStep0_title_ru: Текстура двигает группы.
  teachingStep0_body_ru: Не оценивай руку в вакууме. Сначала смотри на доску, потом уже называй группу.
  title_ru: Повтор по попаданию в доску
  runnerPrompt_ru: Главная мысль урока: одна и та же рука попадает в разные группы на разных досках.
  runnerSupport_ru: Всегда сначала читай доску, а уже потом назначай группу.
  runnerQuestion_ru: Что решает, в какую группу попадает рука?

## lesson range_pressure_lines
status: missing
title_en: Value, bluff, missed
subtitle_en: Each bucket suggests a different action direction.
title_ru: Вэлью, блеф, промах
subtitle_ru: Каждая группа ведёт к своему типу действия.

- taskId: w6_pressure_lines_intro
  status: missing
  title_en: Bucket shapes action
  phase: theory
  stepKind: learn
  runner: _w6PressureLinesIntroRunner
  runnerPrompt_en: Each range bucket suggests a different action direction.
  runnerSupport_en: Value bets to get called. Bluff candidates can bet to fold out better hands.
  runnerQuestion_en: What does a value hand do?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: Вэлью обычно ставит ради колла хуже. Кандидат для блефа давит на пас. Полный промах чаще не хочет разгонять банк.
  title_ru: Группа задаёт ход
  runnerPrompt_ru: Каждая группа рук ведёт к своему типу действия.
  runnerSupport_ru: Вэлью ставит ради оплаты. Кандидат для блефа ставит ради пасов.
  runnerQuestion_ru: Что обычно делает рука из группы вэлью?

- taskId: w6_value_range_action
  status: missing
  title_en: Value bets
  phase: drill
  stepKind: practice
  runner: _w6ValueRangeActionRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q. You are in the value range.
  runnerSupport_en: Value hands want to build the pot.
  runnerQuestion_en: What does K-Q do here?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: Если рука относится к вэлью, она обычно хочет вложить деньги в банк. Здесь действие должно продолжать силу руки, а не прятать её.
  title_ru: Вэлью ставит
  runnerPrompt_ru: K-7-2 радугой. У тебя K-Q. Ты находишься в группе вэлью.
  runnerSupport_ru: Вэлью-руки хотят строить банк.
  runnerQuestion_ru: Что делает K-Q в такой ситуации?

- taskId: w6_bluff_candidate
  status: missing
  title_en: Bluff candidate
  phase: drill
  stepKind: practice
  runner: _w6BluffCandidateRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds A-Q.
  runnerSupport_en: Two overcards, no pair. Some fold equity exists.
  runnerQuestion_en: Which range bucket is A-Q here?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: A-Q без пары на сухой доске не готовая сила, но ещё может давить на пас. Это не чистое вэлью и не полный ноль.
  title_ru: Кандидат для блефа
  runnerPrompt_ru: K-7-2 радугой. У тебя A-Q.
  runnerSupport_ru: Две оверкарты, пары нет. Есть небольшой шанс забрать банк пасом соперника.
  runnerQuestion_ru: В какую группу попадает A-Q здесь?

- taskId: w6_missed_hand_action
  status: missing
  title_en: Missed hand direction
  phase: drill
  stepKind: practice
  runner: _w6MissedHandActionRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds J-T with no draw.
  runnerSupport_en: Pure missed hands usually do not want a big pot.
  runnerQuestion_en: What is the clean action direction?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: Если у руки нет ни шоудаун-вэлью, ни давления, она редко хочет большой банк. Здесь чистое направление обычно спокойнее и уже.
  title_ru: Куда идёт промах
  runnerPrompt_ru: K-7-2 радугой. У тебя J-T без дро.
  runnerSupport_ru: Чистый промах обычно не хочет большой банк.
  runnerQuestion_ru: Какое направление действия здесь самое чистое?

- taskId: w6_table_value_line_transfer
  status: missing
  title_en: Live-table value line
  phase: drill
  stepKind: proveIt
  runner: _w6TableValueLineTransferRunner
  runnerPrompt_en: Real table. K-8-4 rainbow. Hero holds K-J on the button after BB checks.
  runnerSupport_en: Bucket first, then line: top pair is value, so the clean action is bet for value.
  runnerQuestion_en: What is the clean flop action?
  teachingStep0_title_en: Bucket first, line second.
  teachingStep0_body_en: On a real table, top pair on a dry board belongs to value. Once the bucket is clear, the clean line is bet for value instead of guessing.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w6_turn_pressure_shift_transfer
  status: missing
  title_en: Turn pressure shift
  phase: drill
  stepKind: proveIt
  runner: _w6TurnPressureShiftTransferRunner
  runnerPrompt_en: Real table. Flop K-7-2 made A-Q a bluff candidate. BB called, and the turn pairs the 2.
  runnerSupport_en: When the board pairs and the first bluff gets called, some pressure lines cool off.
  runnerQuestion_en: What is the cleaner turn plan now?
  teachingStep0_title_en: Street changes can cool pressure.
  teachingStep0_body_en: A bluff candidate is not a forever-barrel pass. On a paired turn after a call, the cleaner transfer can be slow down and check more often.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Repair story before line.
  teachingStep0_body_en: Board texture changed. Fix the story first, then decide whether the old value plan still belongs.
  teachingStep0_title_ru: Сначала почини историю.
  teachingStep0_body_ru: Если доска изменилась, сначала пересобери чтение ситуации, а уже потом думай, осталось ли старое действие верным. Линия без новой истории часто ломается.
  title_ru: Почини чтение мокрой доски
  runnerPrompt_ru: Тёрн связал доску, но ты всё ещё играешь одну пару так, будто флоп остался сухим.
  runnerSupport_ru: Сначала почини чтение доски, а не повторяй старое действие по инерции.
  runnerQuestion_ru: Что здесь нужно исправить первым?

- taskId: w6_pressure_lines_recap
  status: missing
  title_en: Pressure recap
  phase: review
  stepKind: review
  runner: _w6PressureLinesRecapRunner
  runnerPrompt_en: Lesson learned: bucket decides the action direction.
  runnerSupport_en: Value bets. Bluff candidates can bet or fold. Missed usually folds.
  runnerQuestion_en: What does each range bucket suggest?
  teachingStep0_title_en: Action follows bucket.
  teachingStep0_body_en: Assign the bucket first, then let it guide your action.
  teachingStep0_title_ru: Действие идёт за группой.
  teachingStep0_body_ru: Сначала назови группу руки, и только потом решай, нужен ли бет, чек или пас. Так решение не разваливается на ходу.
  title_ru: Повтор по давлению
  runnerPrompt_ru: Главная мысль урока: группа задаёт направление действия.
  runnerSupport_ru: Вэлью чаще ставит. Кандидат для блефа может ставить или сдаться. Промах чаще выбрасывает.
  runnerQuestion_ru: К какому действию обычно ведёт каждая группа?

## lesson range_combo_counts
status: missing
title_en: Count the combos
subtitle_en: AK has 16 combos. A pocket pair has 6.
title_ru: Считай комбинации
subtitle_ru: AK даёт 16 комбинаций, карманная пара — 6.

- taskId: w6_combo_counts_intro
  status: missing
  title_en: Why combo counts matter
  phase: theory
  stepKind: learn
  runner: _w6ComboCountsIntroRunner
  runnerPrompt_en: Ranges are not just hand names. They also have combo counts.
  runnerSupport_en: More combos means that hand family appears more often in a range.
  runnerQuestion_en: Why do combo counts matter?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: Some hand families have more possible versions than others. A-K has
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: Диапазон — это не только названия рук, но и то, как часто они вообще встречаются. Чем больше комбинаций, тем тяжелее это семейство внутри диапазона.
  title_ru: Зачем считать комбинации
  runnerPrompt_ru: Диапазоны состоят не только из названий рук, но и из количества комбинаций.
  runnerSupport_ru: Чем больше комбинаций, тем чаще это семейство появляется в диапазоне.
  runnerQuestion_ru: Почему количество комбинаций важно?

- taskId: w6_ak_combos
  status: missing
  title_en: AK combo count
  phase: drill
  stepKind: practice
  runner: _w6AkComboRunner
  runnerPrompt_en: A-K can be suited or offsuit.
  runnerSupport_en: Four aces can pair with four kings.
  runnerQuestion_en: How many combos does A-K have before blockers?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: Some hand families have more possible versions than others. A-K has
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: У A-K четыре туза и четыре короля, поэтому до блокеров получается шестнадцать сочетаний. Это и даёт вес этой руке в диапазоне.
  title_ru: Сколько комбинаций у AK
  runnerPrompt_ru: A-K бывают одномастными и разномастными.
  runnerSupport_ru: Четыре туза можно сочетать с четырьмя королями.
  runnerQuestion_ru: Сколько комбинаций у A-K до блокеров?

- taskId: w6_pair_combos
  status: missing
  title_en: Pocket pair combo count
  phase: drill
  stepKind: practice
  runner: _w6PairComboRunner
  runnerPrompt_en: Pocket eights are one pair family.
  runnerSupport_en: You pick 2 suits out of the 4 eights in the deck.
  runnerQuestion_en: How many combos does 8-8 have?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: Some hand families have more possible versions than others. A-K has
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: Карманная пара собирается из двух мастей из четырёх доступных карт одного ранга. Поэтому её комбинаций заметно меньше, чем у непарной руки.
  title_ru: Сколько комбинаций у пары
  runnerPrompt_ru: Карманные восьмёрки — это одно семейство пар.
  runnerSupport_ru: Ты выбираешь две масти из четырёх восьмёрок в колоде.
  runnerQuestion_ru: Сколько комбинаций у 8-8?

- taskId: w6_combo_weight_compare
  status: missing
  title_en: Which family appears more?
  phase: drill
  stepKind: practice
  runner: _w6ComboWeightCompareRunner
  runnerPrompt_en: Compare A-K with pocket eights before blockers.
  runnerSupport_en: One family has 16 combos. The other has 6.
  runnerQuestion_en: Which family appears more often in a range?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: Some hand families have more possible versions than others. A-K has
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: Если одно семейство имеет 16 комбинаций, а другое 6, первое будет попадаться в диапазоне заметно чаще. Чем больше комбинаций, тем чаще ты будешь встречать эту руку.
  title_ru: Что встречается чаще
  runnerPrompt_ru: Сравни A-K и карманные восьмёрки до блокеров.
  runnerSupport_ru: У одного семейства 16 комбинаций, у другого 6.
  runnerQuestion_ru: Какое семейство чаще встречается в диапазоне?

- taskId: w6_combo_counts_recap
  status: missing
  title_en: Combo recap
  phase: review
  stepKind: review
  runner: _w6ComboCountsRecapRunner
  runnerPrompt_en: Lesson learned: combo counts measure how often a hand family appears.
  runnerSupport_en: A-K = 16 combos. A pocket pair = 6 combos.
  runnerQuestion_en: What do combo counts help you measure?
  teachingStep0_title_en: Count before you guess.
  teachingStep0_body_en: Range thinking is not only names like A-K or pocket eights. The combo count shows how much weight that family carries.
  teachingStep0_title_ru: Сначала считай, потом гадай.
  teachingStep0_body_ru: Важно не только название руки, но и её частота внутри диапазона. Количество комбинаций показывает, сколько веса у семейства.
  title_ru: Повтор по комбинациям
  runnerPrompt_ru: Главная мысль урока: количество комбинаций показывает, как часто семейство рук вообще встречается.
  runnerSupport_ru: A-K = 16 комбинаций. Карманная пара = 6 комбинаций.
  runnerQuestion_ru: Что помогает измерять подсчёт комбинаций?

## lesson range_thinking_checkpoint
status: missing
title_en: Range thinking checkpoint
subtitle_en: Bucket, board fit, combo count, then pressure.
title_ru: Контрольная по диапазонам
subtitle_ru: Сначала группа, потом попадание в доску, вес комбинаций и только затем давление.

- taskId: range_checkpoint_intro
  status: missing
  title_en: Three-step read
  phase: theory
  stepKind: learn
  runner: _w6RangeIntroRunner
  runnerPrompt_en: A range is the group of hands that fit a situation.
  runnerSupport_en: Value, bluff candidate, and missed are the three range buckets.
  runnerQuestion_en: What are range buckets?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Контрольная собирает весь путь вместе: сначала группа руки, потом её связь с доской, затем вес комбинаций и только после этого действие.
  title_ru: Чтение в три шага
  runnerPrompt_ru: Диапазон — это группа рук, которые подходят под ситуацию.
  runnerSupport_ru: Здесь три базовые группы: вэлью, кандидат для блефа и промах.
  runnerQuestion_ru: Что такое группы диапазона?

- taskId: range_checkpoint_value
  status: missing
  title_en: Value on dry board
  phase: drill
  stepKind: practice
  runner: _w6ValueDryBoardRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q.
  runnerSupport_en: Top pair with the best possible kicker.
  runnerQuestion_en: Which range bucket is K-Q on this board?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Сначала назови силу руки на этой доске, а не пытайся сразу угадывать действие. Группа остаётся первой опорой.
  title_ru: Вэлью на сухой доске
  runnerPrompt_ru: K-7-2 радугой. У тебя K-Q.
  runnerSupport_ru: Топ-пара с лучшим кикером на такой доске.
  runnerQuestion_ru: В какую группу попадает K-Q на этой доске?

- taskId: range_checkpoint_board_fit
  status: missing
  title_en: Board changes bucket
  phase: drill
  stepKind: practice
  runner: _w6WrongBoardRunner
  runnerPrompt_en: 8-7-6 two-tone. Hero holds K-Q.
  runnerSupport_en: K-Q was strong preflop, but this board changed everything.
  runnerQuestion_en: Which range bucket is K-Q on 8-7-6?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: Даже сильная префлоп-рука может резко ослабнуть, если доска ей не подходит. Здесь важно увидеть именно смену группы.
  title_ru: Доска меняет группу
  runnerPrompt_ru: 8-7-6 с двумя картами одной масти. У тебя K-Q.
  runnerSupport_ru: K-Q была сильной префлоп, но эта доска всё изменила.
  runnerQuestion_ru: В какую группу попадает K-Q на 8-7-6?

- taskId: range_checkpoint_combos
  status: missing
  title_en: Count the family
  phase: drill
  stepKind: practice
  runner: _w6AkComboRunner
  runnerPrompt_en: A-K can be suited or offsuit.
  runnerSupport_en: Four aces can pair with four kings.
  runnerQuestion_en: How many combos does A-K have before blockers?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: Some hand families have more possible versions than others. A-K has
  teachingStep0_title_ru: У семейства есть вес.
  teachingStep0_body_ru: Контрольная напоминает: диапазон — это не только названия рук, но и их частота. Вес семейства помогает не переоценивать редкие варианты.
  title_ru: Посчитай семейство
  runnerPrompt_ru: A-K бывают одномастными и разномастными.
  runnerSupport_ru: Четыре туза можно сочетать с четырьмя королями.
  runnerQuestion_ru: Сколько комбинаций у A-K до блокеров?

- taskId: w6_suited_offsuit_weight_compare
  status: missing
  title_en: Suited or offsuit weight
  phase: drill
  stepKind: practice
  runner: _w6SuitedOffsuitWeightCompareRunner
  runnerPrompt_en: Compare A-K suited with A-K offsuit before blockers.
  runnerSupport_en: Offsuit hands usually have more combinations than suited hands.
  runnerQuestion_en: Which family appears more often in a range?
  teachingStep0_title_en: Suited is rarer.
  teachingStep0_body_en: Combos count how many ways a hand can exist. Offsuit versions usually carry more weight because there are more of them.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w6_pair_vs_suited_weight_compare
  status: missing
  title_en: Pair or suited family
  phase: drill
  stepKind: practice
  runner: _w6PairVsSuitedWeightCompareRunner
  runnerPrompt_en: Compare pocket nines with K-Q suited before blockers.
  runnerSupport_en: Not every unpaired hand is denser than a pocket pair.
  runnerQuestion_en: Which family appears more often in a range?
  teachingStep0_title_en: Weight beats intuition.
  teachingStep0_body_en: A pocket pair has fewer combos than a broad unpaired hand overall, but it can still outweigh one suited hand family. Use the count, not the label.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w6_checkpoint_table_combo_weight
  status: missing
  title_en: Live-table combo weight
  phase: drill
  stepKind: proveIt
  runner: _w6CheckpointTableComboWeightRunner
  runnerPrompt_en: Real table. CO opens preflop. Before guessing exact hands in a simple opening range, you want the heavier family first.
  runnerSupport_en: Use combo counts as weight, not as a guess.
  runnerQuestion_en: Which family should you expect more often in a simple opening range before blockers?
  teachingStep0_title_en: Start with the heavier family.
  teachingStep0_body_en: More combos means the family appears more often. That does not prove the exact hand, but it gives your first range read a better weight.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: После группы, доски и веса руки уже проще понять, есть ли давление на пас или нет. Только теперь действие начинает складываться чисто.
  title_ru: Кандидат для блефа
  runnerPrompt_ru: K-7-2 радугой. У тебя A-Q.
  runnerSupport_ru: Две оверкарты, пары нет. Есть небольшой шанс забрать банк пасом соперника.
  runnerQuestion_ru: В какую группу попадает A-Q здесь?

- taskId: w6_kicker_showdown_compare
  status: missing
  title_en: Same pair, better kicker
  phase: drill
  stepKind: practice
  runner: _w6KickerShowdownCompareRunner
  runnerPrompt_en: River board is K-7-2-9-4. Hero shows A-K. Villain shows K-Q.
  runnerSupport_en: Name the made hand first. Both players have one pair.
  runnerQuestion_en: Which hand is stronger at showdown?
  teachingStep0_title_en: Pair first, kicker second.
  teachingStep0_body_en: Name the made hand before judging the winner. If the pair matches, compare the kicker that still plays in the best five.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w6_board_pair_strength_compare
  status: missing
  title_en: Paired board changes the winner
  phase: drill
  stepKind: practice
  runner: _w6BoardPairStrengthCompareRunner
  runnerPrompt_en: River board is J-8-8-2-2. Hero shows A-J. Villain shows K-8.
  runnerSupport_en: The board helped both players. Compare the full five-card hand.
  runnerQuestion_en: Which hand is stronger at showdown?
  teachingStep0_title_en: Board can help both players.
  teachingStep0_body_en: Do not stop at pair. Compare the full five-card hand after the board pairs, because one player may jump to trips while the other stays on two pair.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w6_checkpoint_table_best_five
  status: missing
  title_en: Live-table best five
  phase: drill
  stepKind: proveIt
  runner: _w6CheckpointTableBestFiveRunner
  runnerPrompt_en: Real table showdown. River board is A-K-Q-J-T. Hero shows A-5. Villain shows K-4.
  runnerSupport_en: Best five cards decide the hand, not the loudest private card.
  runnerQuestion_en: What is the clean read before the pot is pushed?
  teachingStep0_title_en: Board can lock the showdown.
  teachingStep0_body_en: Best five cards decide the hand. When the full straight sits on the board, private cards do not break the tie.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: World 7 checkpoint.
  teachingStep0_body_en: Group hands into ranges, fit them to texture, then adjust risk by stack depth.
  teachingStep0_title_ru: Контрольная мира 7.
  teachingStep0_body_ru: Сначала собери руки в диапазоны, потом привяжи их к текстуре доски, а затем уже смотри, как глубина стека меняет риск и план.
  title_ru: Повтор по диапазонам
  runnerPrompt_ru: Главная мысль урока: группы диапазона нужно читать вместе с попаданием в доску.
  runnerSupport_ru: Сначала группа, потом доска, а дальше уже глубина и риск.
  runnerQuestion_ru: Что переносит это чтение дальше, в Мир 8?
