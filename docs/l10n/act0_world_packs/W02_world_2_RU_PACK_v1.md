# world_2 RU Translation Pack

Status: GENERATED
World number: 2
EN title: Hand Discipline
EN subtitle: Learn which hands deserve chips and which can fold.
title_ru: Дисциплина рук
subtitle_ru: Пойми, какие руки стоят фишек, а какие спокойно уходят в пас.

## Coverage
- Lessons: 2/6
- Tasks: 12/35
- Runner prompts: 12/35
- Runner supports: 12/35
- Runner questions: 12/35
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

## lesson hand_discipline_buckets
status: landed_or_partial
title_en: Hand buckets
subtitle_en: Sort hands before putting chips in.
title_ru: Группы стартовых рук
subtitle_ru: Сначала разложи руку по простой группе, а уже потом вкладывай фишки.

- taskId: hand_discipline_buckets_intro
  status: landed_or_partial
  title_en: Four buckets
  phase: theory
  stepKind: learn
  runner: _world3BucketsIntroRunner
  runnerPrompt_en: Preflop starts by sorting the hand into a simple bucket.
  runnerSupport_en: Use premium, strong, medium, and trash before choosing. No charts needed at this stage.
  runnerQuestion_en: What should you name before the action?
  teachingStep0_title_en: Bucket first.
  teachingStep0_body_en: Name the hand bucket before choosing open, call, or fold. Keep it simple and repeatable.
  teachingStep0_title_ru: Сначала группа.
  teachingStep0_body_ru: До открытия, колла или паса сначала назови группу руки. Этот порядок должен стать простым и повторяемым.
  title_ru: Четыре группы
  runnerPrompt_ru: Сначала назови группу руки, а уже потом думай о действии.
  runnerSupport_ru: Этот первый фильтр убирает суету: премиум и сильные руки играются иначе, чем средние и мусорные.
  runnerQuestion_ru: Что лучше назвать до действия?

- taskId: hand_discipline_buckets_premium
  status: landed_or_partial
  title_en: Premium hand
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  teachingStep0_title_en: Premium means top bucket.
  teachingStep0_body_en: AA starts in the premium bucket before context changes anything.
  teachingStep0_title_ru: Премиум — это верхняя группа.
  teachingStep0_body_ru: AA сразу попадает в премиум. Здесь контекст уже потом уточняет линию, но не меняет базовую силу руки.
  title_ru: Премиум-рука
  runnerPrompt_ru: Сначала определи группу руки.
  runnerSupport_ru: Премиум-руки не требуют сложных оправданий: они чаще хотят строить банк, а не прятаться.
  runnerQuestion_ru: Какая группа у АА?

- taskId: hand_discipline_buckets_strong
  status: landed_or_partial
  title_en: Strong hand
  phase: drill
  stepKind: practice
  runner: _w1StrongBucketRunner
  runnerPrompt_en: JJ is a strong preflop hand.
  runnerSupport_en: Strong hands play well but are not the absolute top bucket.
  runnerQuestion_en: Which bucket is JJ?
  teachingStep0_title_en: Strong, not premium.
  teachingStep0_body_en: JJ is strong but can face an ace on the flop. Strong is the second bucket.
  teachingStep0_title_ru: Сильная, но не премиум.
  teachingStep0_body_ru: JJ — сильная рука, но не самый верх диапазона. Это вторая группа, а не абсолютная вершина.
  title_ru: Сильная рука
  runnerPrompt_ru: Назови группу руки до выбора линии.
  runnerSupport_ru: Сильная рука почти всегда играбельна, но это ещё не вершина диапазона.
  runnerQuestion_ru: Какая группа у JJ?

- taskId: hand_discipline_buckets_medium
  status: landed_or_partial
  title_en: Medium hand
  phase: drill
  stepKind: practice
  runner: _w1MediumBucketRunner
  runnerPrompt_en: KQo is a medium preflop hand.
  runnerSupport_en: Medium hands play best in good positions with the right frame.
  runnerQuestion_en: Which bucket is KQo?
  teachingStep0_title_en: Medium needs position.
  teachingStep0_body_en: KQo is playable but not strong enough to play from anywhere.
  teachingStep0_title_ru: Средней руке нужна опора.
  teachingStep0_body_ru: KQo играется, но не отовсюду одинаково хорошо. Средней руке важнее позиция и чистая ситуация.
  title_ru: Средняя рука
  runnerPrompt_ru: Сначала пойми, насколько рука пограничная.
  runnerSupport_ru: Средняя рука не обязана лезть в каждый банк. Ей нужен более удобный спот, чем премиуму.
  runnerQuestion_ru: Какая группа у KQo?

- taskId: hand_discipline_buckets_trash
  status: landed_or_partial
  title_en: Trash hand
  phase: drill
  stepKind: practice
  runner: _world3TrashBucketRunner
  runnerPrompt_en: J8o is a weak offsuit starter from early position.
  runnerSupport_en: Weak early hands should not be forced into action.
  runnerQuestion_en: Which bucket fits J8o early?
  teachingStep0_title_en: Weak and early is trouble.
  teachingStep0_body_en: J8o has little help, especially before seeing others act.
  teachingStep0_title_ru: Слабая рука рано — это проблема.
  teachingStep0_body_ru: У J8o слишком мало запаса, особенно когда ты ещё не видел действий остальных. Такой спот лучше не форсировать.
  title_ru: Мусорная рука
  runnerPrompt_ru: Слабая рука не обязана становиться приключением.
  runnerSupport_ru: Если рука не тянет на продолжение, дисциплина экономит фишки простым фолдом.
  runnerQuestion_ru: К какой группе отнести J8o в ранней позиции?

- taskId: hand_discipline_buckets_borderline
  status: landed_or_partial
  title_en: Borderline strong
  phase: drill
  stepKind: practice
  runner: _w1StrongBucketRunner
  runnerPrompt_en: JJ is a strong preflop hand.
  runnerSupport_en: Strong hands play well but are not the absolute top bucket.
  runnerQuestion_en: Which bucket is JJ?
  teachingStep0_title_en: Strong, not premium.
  teachingStep0_body_en: JJ is strong but can face an ace on the flop. Strong is the second bucket.
  teachingStep0_title_ru: Сильная, но не верхняя.
  teachingStep0_body_ru: Такая рука всё ещё хороша, но ей не нужно приписывать силу абсолютного топа. Это просто крепкая вторая группа.
  title_ru: Погранично сильная
  runnerPrompt_ru: Не путай просто сильную руку с премиумом.
  runnerSupport_ru: Эта группа всё ещё играет уверенно, но ей не нужно приписывать силу самого верха.
  runnerQuestion_ru: Какая группа здесь ближе всего?

- taskId: hand_discipline_buckets_recap
  status: landed_or_partial
  title_en: Bucket recap
  phase: review
  stepKind: review
  runner: _world3BucketsRecapRunner
  runnerPrompt_en: Lesson learned: bucket the hand before the action.
  runnerSupport_en: Premium, strong, medium, or trash is the first preflop read.
  runnerQuestion_en: What is the first preflop habit?
  teachingStep0_title_en: Bucket checklist.
  teachingStep0_body_en: Name the hand bucket, then read position and action frame.
  teachingStep0_title_ru: Проверка по группе.
  teachingStep0_body_ru: Сначала назови группу руки, потом смотри на позицию и на то, кто уже вошёл в банк. Так префлоп читается заметно чище.
  title_ru: Повтор по группам
  runnerPrompt_ru: До действия сначала назови группу руки.
  runnerSupport_ru: Когда рука быстро попадает в нужную группу, префлоп-решения становятся спокойнее и чище.
  runnerQuestion_ru: Какая префлоп-привычка здесь первая?

## lesson fold_discipline
status: missing
title_en: Fold discipline
subtitle_en: Learn that folding weak hands saves chips.
title_ru: Дисциплина паса
subtitle_ru: Пойми, что пас слабых рук не трусость, а защита фишек.

- taskId: discipline_intro
  status: missing
  title_en: Fold is a tool
  phase: theory
  stepKind: learn
  runner: _foldActionRunner
  runnerPrompt_en: HJ bets and your hand is weak.
  runnerSupport_en: Folding saves chips when continuing is not worth it.
  runnerQuestion_en: Which action gives up the hand?
  teachingStep0_title_en: A bet creates a price.
  teachingStep0_body_en: If your hand is not worth the price, folding saves chips.
  teachingStep0_title_ru: Ставка создаёт цену.
  teachingStep0_body_ru: Если рука не стоит этой цены, пас просто сохраняет фишки. Это не слабость, а нормальный рабочий ответ.
  title_ru: Пас — это инструмент
  runnerPrompt_ru: HJ ставит, а твоя рука слишком слаба для продолжения.
  runnerSupport_ru: Пас экономит фишки в спотах, где дальше платить уже невыгодно.
  runnerQuestion_ru: Какое действие сразу сдаёт эту руку?

- taskId: early_fold
  status: missing
  title_en: Early weak hand
  phase: drill
  stepKind: practice
  runner: _world3EarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is early with J8o.
  runnerSupport_en: Early position removes the comfort from weak offsuit hands.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Discipline is allowed.
  teachingStep0_body_en: Opening weak early hands creates hard spots later.
  teachingStep0_title_ru: Дисциплина здесь уместна.
  teachingStep0_body_ru: Слабое открытие из ранней позиции слишком часто создаёт тяжёлые решения дальше. Чистый пас обычно лучше лишней надежды.
  title_ru: Слабая рука рано
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с J8o.
  runnerSupport_ru: Ранняя позиция лишает слабые разномастные руки любого комфорта.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: facing_fold
  status: missing
  title_en: Facing pressure
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не индульгенция.
  teachingStep0_body_ru: Даже на баттоне J8o остаётся слишком слабой рукой против открытия. Позиция помогает не всему подряд.
  title_ru: Пас под давлением
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё равно слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: discipline_stack_protect
  status: missing
  title_en: Protect stack
  phase: drill
  stepKind: practice
  runner: _world3DominatedFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with A7o.
  runnerSupport_en: This can be behind stronger aces, so folding is clean.
  runnerQuestion_en: What is the disciplined response?
  teachingStep0_title_en: Weak ace caution.
  teachingStep0_body_en: A7o can be dominated when someone opened first.
  teachingStep0_title_ru: Осторожно со слабым тузом.
  teachingStep0_body_ru: A7o легко оказывается позади более сильных тузов, если кто-то уже открылся. Здесь дисциплина важнее любопытства.
  title_ru: Сохрани стек
  runnerPrompt_ru: CO открылся. Ты на баттоне с A7o.
  runnerSupport_ru: Такая рука часто доминируется более сильными тузами, поэтому пас здесь чистый.
  runnerQuestion_ru: Какой ответ здесь будет дисциплинированным?

- taskId: fold_recap
  status: missing
  title_en: Discipline recap
  phase: review
  stepKind: review
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  teachingStep0_title_en: Trouble-hand checklist.
  teachingStep0_body_en: High card alone is not enough. Read the opener and bucket.
  teachingStep0_title_ru: Проверка на проблемные руки.
  teachingStep0_body_ru: Одной высокой карты мало. Сначала смотри на открытие соперника и на группу своей руки, а уже потом решай.
  title_ru: Повтор по дисциплине
  runnerPrompt_ru: Главная мысль урока: знакомые карты всё равно требуют контекста.
  runnerSupport_ru: Не продолжай только потому, что одна карта выглядит красиво.
  runnerQuestion_ru: Чего должны избегать такие знакомые, но слабые руки?

## lesson weak_ace_warning
status: missing
title_en: Weak ace warning
subtitle_en: Familiar hands can still be dominated.
title_ru: Осторожно со слабым тузом
subtitle_ru: Знакомая рука всё ещё может оказаться под доминацией.

- taskId: w3_dominated_intro
  status: missing
  title_en: Trouble hands
  phase: theory
  stepKind: learn
  runner: _world3DominatedIntroRunner
  runnerPrompt_en: Some familiar hands are trouble when stronger versions open.
  runnerSupport_en: A weak ace can be behind a better ace.
  runnerQuestion_en: What kind of hand needs caution?
  teachingStep0_title_en: Familiar is not always safe.
  teachingStep0_body_en: Weak aces and weak broadways can run into stronger versions.
  teachingStep0_title_ru: Знакомое — не значит безопасное.
  teachingStep0_body_ru: Слабые тузы и слабые бродвеи часто упираются в более сильные версии тех же рук. Важно заметить это заранее.
  title_ru: Проблемные руки
  runnerPrompt_ru: Некоторые знакомые руки превращаются в проблему, если впереди уже открылись сильнее.
  runnerSupport_ru: Слабый туз легко оказывается позади более сильного туза.
  runnerQuestion_ru: Какая рука здесь требует осторожности?

- taskId: w3_dominated_fold
  status: missing
  title_en: Fold trouble
  phase: drill
  stepKind: practice
  runner: _world3DominatedFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with A7o.
  runnerSupport_en: This can be behind stronger aces, so folding is clean.
  runnerQuestion_en: What is the disciplined response?
  teachingStep0_title_en: Weak ace caution.
  teachingStep0_body_en: A7o can be dominated when someone opened first.
  teachingStep0_title_ru: Осторожно со слабым тузом.
  teachingStep0_body_ru: A7o может оказаться под доминацией, если кто-то уже открыл раздачу. Такой пас часто не слабость, а дисциплина.
  title_ru: Пас с проблемной рукой
  runnerPrompt_ru: CO открылся. Ты на баттоне с A7o.
  runnerSupport_ru: Такая рука нередко уже позади более сильных тузов, поэтому чистый пас здесь нормален.
  runnerQuestion_ru: Какой ответ здесь будет самым дисциплинированным?

- taskId: w3_strong_continue
  status: missing
  title_en: Strong continue
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo можно спокойно коллировать простое открытие, когда ты действуешь после CO. Здесь уже есть и сила, и удобство позиции.
  title_ru: Сильное продолжение
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: weak_ace_pressure_fold
  status: missing
  title_en: Pressure fold
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не индульгенция.
  teachingStep0_body_ru: J8o всё равно идёт в пас, если сама рука слишком слаба. Позиция не обязана спасать плохой старт.
  title_ru: Пас под давлением
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё ещё слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: weak_ace_kicker_compare
  status: missing
  title_en: A7 vs KQ spot
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может продолжать против простого открытия, а A7o чаще страдает от доминации. Важна не знакомость руки, а её реальное качество.
  title_ru: A7 против KQ
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может продолжать, когда слабый туз чаще уже отстаёт.
  runnerQuestion_ru: Какой ответ здесь выглядит чище всего?

- taskId: w3_dominated_recap
  status: missing
  title_en: Discipline recap
  phase: review
  stepKind: review
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  teachingStep0_title_en: Trouble-hand checklist.
  teachingStep0_body_en: High card alone is not enough. Read the opener and bucket.
  teachingStep0_title_ru: Проверка по проблемным рукам.
  teachingStep0_body_ru: Одной высокой карты мало. Сначала смотри, кто открылся, и не путай знакомую руку с действительно сильной.
  title_ru: Повтор по доминации
  runnerPrompt_ru: Главная мысль урока: знакомые карты всё равно требуют контекста.
  runnerSupport_ru: Не продолжай только потому, что одна карта выглядит высокой.
  runnerQuestion_ru: Чего должны избегать такие слабые знакомые руки?

## lesson continue_or_let_go
status: missing
title_en: Continue or let go
subtitle_en: Separate strong continues from weak hopes.
title_ru: Продолжать или отпустить
subtitle_ru: Отделяй уверенное продолжение от слабой надежды.

- taskId: continue_intro
  status: missing
  title_en: Strong enough
  phase: theory
  stepKind: learn
  runner: _world3BucketsIntroRunner
  runnerPrompt_en: Preflop starts by sorting the hand into a simple bucket.
  runnerSupport_en: Use premium, strong, medium, and trash before choosing. No charts needed at this stage.
  runnerQuestion_en: What should you name before the action?
  teachingStep0_title_en: Bucket first.
  teachingStep0_body_en: Name the hand bucket before choosing open, call, or fold. Keep it simple and repeatable.
  teachingStep0_title_ru: Сначала группа.
  teachingStep0_body_ru: До открытия, колла или паса сначала назови группу руки. Это делает решение чище и повторяемее.
  title_ru: Достаточно ли силы
  runnerPrompt_ru: Префлоп начинается с простой группы руки.
  runnerSupport_ru: Премиум, сильная, средняя или мусорная — этого уже достаточно для первого решения. Чарты на старте не нужны.
  runnerQuestion_ru: Что нужно назвать до действия?

- taskId: premium_continue
  status: missing
  title_en: Premium continue
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  teachingStep0_title_en: Premium means top bucket.
  teachingStep0_body_en: AA starts in the premium bucket before context changes anything.
  teachingStep0_title_ru: Премиум — это верх.
  teachingStep0_body_ru: AA начинает в премиум-группе ещё до любого контекста. Такая рука не ищет оправдания, чтобы продолжать.
  title_ru: Премиум продолжает
  runnerPrompt_ru: AA — это премиум-рука на префлопе.
  runnerSupport_ru: Премиум-руки обычно хотят строить банк, а не прятаться.
  runnerQuestion_ru: К какой группе относится AA?

- taskId: medium_open
  status: missing
  title_en: Medium hand opens
  phase: drill
  stepKind: practice
  runner: _w1MediumOpenRunner
  runnerPrompt_en: BTN. Pot unopened. Hero holds K♦ Q♣.
  runnerSupport_en: Medium hand in the best seat. Raising is sharper than limping.
  runnerQuestion_en: What is the best first-in action?
  teachingStep0_title_en: Medium hand, good seat.
  teachingStep0_body_en: KQo is medium bucket. The Button is the best seat. Raise to open cleanly.
  teachingStep0_title_ru: Средняя рука, хорошее место.
  teachingStep0_body_ru: KQo — средняя группа. Баттон — лучшее место за столом. Здесь чистый рейз выглядит естественно.
  title_ru: Средняя рука открывает
  runnerPrompt_ru: Баттон. Банк не открыт. У тебя K♦ Q♣.
  runnerSupport_ru: Средняя рука в лучшем месте за столом чаще открывается, чем заходит пассивно.
  runnerQuestion_ru: Какое первое действие здесь лучше всего?

- taskId: weak_let_go
  status: missing
  title_en: Weak let go
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не индульгенция.
  teachingStep0_body_ru: J8o всё равно идёт в пас, если рука слишком слаба для продолжения. Надежда без опоры здесь не помогает.
  title_ru: Слабое лучше отпустить
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё ещё слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: medium_call_or_fold
  status: missing
  title_en: Medium facing open
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто коллировать открытие, когда ты действуешь после CO. Это уже не надежда, а нормальное продолжение.
  title_ru: Средняя рука против открытия
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: continue_recap
  status: missing
  title_en: Continue recap
  phase: review
  stepKind: review
  runner: _world3FacingOpenRecapRunner
  runnerPrompt_en: Lesson learned: facing an open creates a price.
  runnerSupport_en: Playable hands can call; weak hands can still fold.
  runnerQuestion_en: What did the opener create?
  teachingStep0_title_en: Facing-open checklist.
  teachingStep0_body_en: Read the hand bucket, your position, and the price.
  teachingStep0_title_ru: Проверка против открытия.
  teachingStep0_body_ru: Смотри на группу руки, свою позицию и цену входа. Так сильное продолжение и слабая надежда перестают путаться.
  title_ru: Повтор по продолжению
  runnerPrompt_ru: Главная мысль урока: открытие до тебя создаёт цену входа.
  runnerSupport_ru: Играбельные руки могут коллировать, а слабые спокойно уходят в пас.
  runnerQuestion_ru: Что создал рейз до тебя?

## lesson hand_discipline_apply
status: landed_or_partial
title_en: Discipline at the table
subtitle_en: Bucket, seat, and frame — then the action is simple.
title_ru: Дисциплина за столом
subtitle_ru: Сначала группа руки, потом место и ситуация. Дальше решение проще.

- taskId: apply_intro
  status: landed_or_partial
  title_en: Three-step habit
  phase: theory
  stepKind: learn
  runner: _w1DisciplineApplyIntroRunner
  runnerPrompt_en: Three steps make the decision easier.
  runnerSupport_en: Bucket the hand, read the seat, read the frame — then act. No chart memorization required.
  runnerQuestion_en: What order helps most?
  teachingStep0_title_en: Bucket, seat, frame.
  teachingStep0_body_en: Name the hand bucket. Check the seat. Read who acted first.
  teachingStep0_title_ru: Группа, место, ситуация.
  teachingStep0_body_ru: Сначала назови группу руки, потом посмотри на место за столом и уже после этого на ситуацию. Такой порядок делает решение заметно проще.
  title_ru: Привычка в три шага
  runnerPrompt_ru: Иди по порядку: группа руки, место, ситуация, потом действие.
  runnerSupport_ru: Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоит ли входить в игру.
  runnerQuestion_ru: Какой порядок здесь самый чистый?

- taskId: apply_utg_fold
  status: landed_or_partial
  title_en: UTG, trash hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyEarlyFoldRunner
  runnerPrompt_en: UTG. Pot unopened. Hero holds 8♠ 4♦.
  runnerSupport_en: Early position, trash bucket. Discipline says fold.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Trash in early seat.
  teachingStep0_body_en: 8♠4♦ from UTG is clear trash. No context rescues it.
  teachingStep0_title_ru: Мусор в ранней позиции.
  teachingStep0_body_ru: 8♠4♦ из UTG — это чистый мусор. Никакой контекст здесь не обязан спасать такую руку.
  title_ru: UTG, мусорная рука
  runnerPrompt_ru: Ранняя позиция плюс мусорная рука редко требуют героизма.
  runnerSupport_ru: Не усложняй спот. Если рука слабая и ты говоришь первым, фолд сохраняет фишки и внимание.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: apply_btn_open
  status: landed_or_partial
  title_en: BTN, strong hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyLateOpenRunner
  runnerPrompt_en: BTN. Pot unopened. Hero holds A♠ J♦.
  runnerSupport_en: Late position, strong hand, no one entered. Clean open.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Strong hand, good seat.
  teachingStep0_body_en: AJo is a strong bucket. BTN acts last. Pot is clean. Open.
  teachingStep0_title_ru: Сильная рука, хорошее место.
  teachingStep0_body_ru: AJo — это сильная группа. Баттон действует позже остальных. Банк чистый, значит открытие выглядит естественно.
  title_ru: Баттон, сильная рука
  runnerPrompt_ru: Сильная рука на баттоне любит инициативу.
  runnerSupport_ru: Когда до тебя все выбросили, поздняя позиция и хорошая рука дают чистый повод открыть раздачу.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: apply_hj_decision
  status: landed_or_partial
  title_en: HJ, medium hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyEarlyFoldRunner
  runnerPrompt_en: UTG. Pot unopened. Hero holds 8♠ 4♦.
  runnerSupport_en: Early position, trash bucket. Discipline says fold.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Trash in early seat.
  teachingStep0_body_en: 8♠4♦ from UTG is clear trash. No context rescues it.
  teachingStep0_title_ru: Средняя рука просит честности.
  teachingStep0_body_ru: Средняя рука в неудобной ситуации не обязана продолжать только потому, что выглядит знакомо. Сначала каркас, потом амбиции.
  title_ru: HJ, средняя рука
  runnerPrompt_ru: Средняя рука требует оценки ситуации, а не игры на автопилоте.
  runnerSupport_ru: Здесь важно не упрямство, а трезвый каркас: группа руки, место и ситуация должны дать чистую причину продолжать.
  runnerQuestion_ru: Какое решение здесь выглядит наиболее дисциплинированным?

- taskId: apply_recap
  status: landed_or_partial
  title_en: Discipline holds
  phase: review
  stepKind: proveIt
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  teachingStep0_title_en: Trouble-hand checklist.
  teachingStep0_body_en: High card alone is not enough. Read the opener and bucket.
  teachingStep0_title_ru: Проверка проблемной руки.
  teachingStep0_body_ru: Одной высокой карты мало. Сначала смотри на открытие соперника и на группу руки, а уже потом решай продолжать ли.
  title_ru: Дисциплина держится
  runnerPrompt_ru: Собери весь каркас в один спокойный префлоп-ритм.
  runnerSupport_ru: Хорошая дисциплина не ищет подвигов. Она снова и снова приводит к чистому решению по понятным причинам.
  runnerQuestion_ru: Чего должны избегать знакомые, но слабые руки?

## lesson discipline_checkpoint
status: missing
title_en: Hand discipline checkpoint
subtitle_en: Name the bucket, then protect your stack.
title_ru: Контрольная по дисциплине рук
subtitle_ru: Сначала назови группу руки, потом защищай стек.

- taskId: checkpoint_intro
  status: missing
  title_en: Bucket first
  phase: theory
  stepKind: learn
  runner: _world3BucketsRecapRunner
  runnerPrompt_en: Lesson learned: bucket the hand before the action.
  runnerSupport_en: Premium, strong, medium, or trash is the first preflop read.
  runnerQuestion_en: What is the first preflop habit?
  teachingStep0_title_en: Bucket checklist.
  teachingStep0_body_en: Name the hand bucket, then read position and action frame.
  teachingStep0_title_ru: Проверка по группе.
  teachingStep0_body_ru: Сначала назови группу руки, потом смотри на позицию и на рамку действия. Это и есть первый префлоп-ритм.
  title_ru: Сначала группа
  runnerPrompt_ru: Главная мысль урока: группу руки нужно назвать ещё до действия.
  runnerSupport_ru: Премиум, сильная, средняя или мусорная — это первый префлоп-сигнал.
  runnerQuestion_ru: Какая привычка на префлопе идёт первой?

- taskId: checkpoint_premium
  status: missing
  title_en: Premium hand
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  teachingStep0_title_en: Premium means top bucket.
  teachingStep0_body_en: AA starts in the premium bucket before context changes anything.
  teachingStep0_title_ru: Премиум — это верхняя группа.
  teachingStep0_body_ru: AA начинает в премиум-группе ещё до контекста. Такая рука обычно хочет строить банк, а не отказываться от инициативы.
  title_ru: Премиум-рука
  runnerPrompt_ru: AA — это премиум-рука на префлопе.
  runnerSupport_ru: Премиум-руки чаще всего хотят вложить деньги в банк и сохранить инициативу.
  runnerQuestion_ru: К какой группе относится AA?

- taskId: checkpoint_fold
  status: missing
  title_en: Disciplined fold
  phase: drill
  stepKind: practice
  runner: _world3DominatedFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with A7o.
  runnerSupport_en: This can be behind stronger aces, so folding is clean.
  runnerQuestion_en: What is the disciplined response?
  teachingStep0_title_en: Weak ace caution.
  teachingStep0_body_en: A7o can be dominated when someone opened first.
  teachingStep0_title_ru: Осторожно со слабым тузом.
  teachingStep0_body_ru: A7o легко оказывается под доминацией, если кто-то уже открылся. Пас здесь чаще защищает стек, чем лишает тебя шанса.
  title_ru: Дисциплинированный пас
  runnerPrompt_ru: CO открылся. Ты на баттоне с A7o.
  runnerSupport_ru: Такая рука часто уже позади более сильных тузов, поэтому пас здесь выглядит чисто.
  runnerQuestion_ru: Какой ответ здесь будет дисциплинированным?

- taskId: checkpoint_borderline_continue
  status: missing
  title_en: Borderline continue
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может спокойно продолжать простое открытие, когда ты действуешь после CO. Здесь рука и место работают вместе.
  title_ru: Пограничное продолжение
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может оставаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: checkpoint_table_discipline
  status: missing
  title_en: Real-table discipline read
  phase: drill
  stepKind: practice
  runner: _w2DisciplineTableNoticeRunner
  runnerPrompt_en: Real table. Hero is HJ with J4o and the pot is unopened.
  runnerSupport_en: Use the bucket first before hope or curiosity shows up.
  runnerQuestion_en: What is the clean discipline read?
  teachingStep0_title_en: Bucket before curiosity.
  teachingStep0_body_en: Some live-table leaks start because a weak hand looks tempting. Name the bucket first, then act with discipline.
  teachingStep0_title_ru: Группа важнее любопытства.
  teachingStep0_body_ru: Некоторые live-утечки начинаются с того, что слабая рука вдруг кажется соблазнительной. Сначала назови группу, а потом действуй дисциплинированно.
  title_ru: Дисциплина за живым столом
  runnerPrompt_ru: Живой стол. Ты в HJ с J4o, банк не открыт.
  runnerSupport_ru: Сначала определи группу руки, пока надежда и любопытство не полезли вперёд.
  runnerQuestion_ru: Какое чтение здесь будет самым чистым?

- taskId: checkpoint_review
  status: missing
  title_en: Discipline recap
  phase: review
  stepKind: proveIt
  runner: _w1DisciplineCheckpointRunner
  runnerPrompt_en: Lesson learned: discipline comes before action.
  runnerSupport_en: Next world adds position: the same bucket can change action by seat.
  runnerQuestion_en: What comes right after naming the bucket?
  teachingStep0_title_en: W1 to W2 bridge.
  teachingStep0_body_en: Bucket first. Position second. Then choose the action frame.
  teachingStep0_title_ru: Мост к следующему миру.
  teachingStep0_body_ru: Сначала группа руки. Потом позиция. И только после этого рамка действия. Этот порядок понесёт тебя дальше.
  title_ru: Повтор по дисциплине
  runnerPrompt_ru: Главная мысль урока: дисциплина приходит раньше действия.
  runnerSupport_ru: Следующий мир добавит позицию: та же группа руки может играться по-разному в разных местах.
  runnerQuestion_ru: Что идёт сразу после группы руки?
