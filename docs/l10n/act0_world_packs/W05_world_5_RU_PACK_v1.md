# world_5 RU Translation Pack

Status: GENERATED
World number: 5
EN title: Bet Purpose And Price
EN subtitle: Understand value, bluff, protection, and call price.
title_ru: Смысл ставки и цена
subtitle_ru: Пойми вэлью, блеф, защиту и цену колла без перегруза.

## Coverage
- Lessons: 0/7
- Tasks: 0/33
- Runner prompts: 0/33
- Runner supports: 0/33
- Runner questions: 0/33
- Teaching step titles: 0/33
- Teaching step bodies: 0/33

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson why_bets_happen
status: missing
title_en: Why bets happen
subtitle_en: Every bet should have a simple purpose.
title_ru: Зачем вообще ставят
subtitle_ru: У каждой ставки должна быть простая и понятная цель.

- taskId: w4_purpose_intro
  status: missing
  title_en: Bet purpose
  phase: theory
  stepKind: learn
  runner: _world4PurposeIntroRunner
  runnerPrompt_en: A bet should have a reason before it has a size.
  runnerSupport_en: Start with purpose: value, bluff, or protection.
  runnerQuestion_en: What should you name before sizing a bet?
  teachingStep0_title_en: Purpose first.
  teachingStep0_body_en: Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.
  teachingStep0_title_ru: Сначала цель.
  teachingStep0_body_ru: До выбора размера сначала пойми, что ставка пытается сделать. На флопе в банке 6 BB. Ты ставишь, чтобы добрать с рук хуже, выбить руки лучше или заставить следующую карту стоить денег. Сначала назови цель, потом выбирай размер.
  title_ru: Смысл ставки
  runnerPrompt_ru: У ставки должна быть причина раньше, чем размер.
  runnerSupport_ru: Начни с цели: вэлью, блеф или защита.
  runnerQuestion_ru: Что нужно назвать до размера ставки?

- taskId: w4_value_purpose
  status: missing
  title_en: Value reason
  phase: drill
  stepKind: practice
  runner: _world4ValuePurposeRunner
  runnerPrompt_en: Hero has top pair. Worse hands can call.
  runnerSupport_en: This bet is not just noise. It wants calls from weaker hands.
  runnerQuestion_en: What is the main purpose?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Вэлью хочет колл.
  teachingStep0_body_ru: С топ-парой хуже могут платить: более слабые пары и худшие тузы ещё часто продолжают.
  title_ru: Причина для вэлью
  runnerPrompt_ru: У тебя топ-пара. Руки слабее могут заплатить.
  runnerSupport_ru: Эта ставка нужна не для шума, а чтобы руки хуже продолжали за деньги.
  runnerQuestion_ru: Какая здесь главная цель ставки?

- taskId: w4_bluff_purpose
  status: missing
  title_en: Bluff reason
  phase: drill
  stepKind: practice
  runner: _world4BluffPurposeRunner
  runnerPrompt_en: Hero missed. The bet tries to win by folds.
  runnerSupport_en: A bluff needs fold pressure, not a made hand.
  runnerQuestion_en: What is the main purpose?
  teachingStep0_title_en: Bluff wants folds.
  teachingStep0_body_en: When hero has no pair, the bet works only if folds happen.
  teachingStep0_title_ru: Блеф хочет пас.
  teachingStep0_body_ru: Если у тебя ничего не собрано, ставка работает только тогда, когда соперник выбрасывает.
  title_ru: Причина для блефа
  runnerPrompt_ru: Ты не попал. Ставка пытается забрать банк пасом соперника.
  runnerSupport_ru: Блеф держится на давлении на пас, а не на готовой руке.
  runnerQuestion_ru: Какая здесь главная цель ставки?

- taskId: w4_purpose_recap
  status: missing
  title_en: Purpose recap
  phase: review
  stepKind: review
  runner: _world4PurposeRecapRunner
  runnerPrompt_en: Lesson learned: name the purpose before the size.
  runnerSupport_en: Value gets calls. Bluff gets folds. Protection denies free cards.
  runnerQuestion_en: What comes before the bet size?
  teachingStep0_title_en: Purpose checklist.
  teachingStep0_body_en: Ask what the bet wants before asking how big it should be.
  teachingStep0_title_ru: Короткая проверка цели.
  teachingStep0_body_ru: Сначала пойми, чего хочет ставка, и только потом думай, какого она должна быть размера.
  title_ru: Повтор по цели ставки
  runnerPrompt_ru: Главное правило: сначала цель, потом размер.
  runnerSupport_ru: Вэлью добирает, блеф выбивает, защита не даёт увидеть карту бесплатно.
  runnerQuestion_ru: Что должно появиться раньше размера ставки?

## lesson value_bets
status: missing
title_en: Value bets
subtitle_en: Bet when worse hands can still call.
title_ru: Вэлью-ставки
subtitle_ru: Ставь, когда руки хуже ещё готовы платить.

- taskId: w4_value_intro
  status: missing
  title_en: Worse calls
  phase: theory
  stepKind: learn
  runner: _world4ValueIntroRunner
  runnerPrompt_en: A value bet targets weaker hands that can call.
  runnerSupport_en: If no weaker hand can call, value is thin or missing.
  runnerQuestion_en: Who should a value bet get called by?
  teachingStep0_title_en: Worse calls.
  teachingStep0_body_en: Value means worse hands can still call.
  teachingStep0_title_ru: Вэлью добирает с рук хуже.
  teachingStep0_body_ru: Вэлью простое: ты ставишь, потому что руки хуже ещё заплатят. У тебя топ-пара с AQ на доске A-7-2. Банк 6 BB. Более слабые тузы и младшие пары ещё могут вложить фишки, которые ты будешь выигрывать в среднем.
  title_ru: Колл от рук слабее
  runnerPrompt_ru: Вэлью-ставка нацелена на руки слабее, которые ещё могут коллировать.
  runnerSupport_ru: Если хуже уже не платит, вэлью становится тонким или исчезает совсем.
  runnerQuestion_ru: Кто должен платить в ответ на вэлью-ставку?

- taskId: w4_value_bet
  status: missing
  title_en: Bet top pair
  phase: drill
  stepKind: practice
  runner: _world4ValueBetRunner
  runnerPrompt_en: Top pair on a safe flop. BB can call worse.
  runnerSupport_en: A half-pot bet is a simple value size here.
  runnerQuestion_en: What action fits the purpose?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Вэлью хочет колл.
  teachingStep0_body_ru: С топ-парой хуже ещё может заплатить, поэтому ставка здесь выглядит естественно.
  title_ru: Ставка с топ-парой
  runnerPrompt_ru: Топ-пара на безопасном флопе. BB может платить хуже.
  runnerSupport_ru: Полбанка здесь выглядит как простой и чистый размер на вэлью.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цели?

- taskId: w4_value_missed
  status: missing
  title_en: Do not hide value
  phase: drill
  stepKind: practice
  runner: _world4ValueCheckMissRunner
  runnerPrompt_en: Hero has top pair. Checking gives up a value chance.
  runnerSupport_en: When worse hands can call, betting is the lesson.
  runnerQuestion_en: Which action misses value?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Не прячь вэлью.
  teachingStep0_body_ru: Если руки хуже готовы платить, чек часто просто отдаёт им бесплатный выход.
  title_ru: Не прячь добор
  runnerPrompt_ru: У тебя топ-пара. Чек отдаёт шанс на добор.
  runnerSupport_ru: Если хуже может платить, ставка и есть главный учебный вывод.
  runnerQuestion_ru: Какое действие здесь упускает вэлью?

- taskId: w4_value_recap
  status: missing
  title_en: Value recap
  phase: review
  stepKind: review
  runner: _world4ValueRecapRunner
  runnerPrompt_en: Lesson learned: value means worse can call.
  runnerSupport_en: Do not hide strong but call-able hands every time.
  runnerQuestion_en: What makes a bet value?
  teachingStep0_title_en: Value checklist.
  teachingStep0_body_en: Ask what worse hands can call before choosing a size.
  teachingStep0_title_ru: Проверка на вэлью.
  teachingStep0_body_ru: До выбора размера сначала спроси себя, какие руки хуже реально могут платить.
  title_ru: Повтор по вэлью
  runnerPrompt_ru: Вывод простой: вэлью значит, что хуже ещё платит.
  runnerSupport_ru: Не прячь сильные, но оплачиваемые руки слишком часто.
  runnerQuestion_ru: Что делает ставку именно вэлью-ставкой?

## lesson bluff_pressure
status: missing
title_en: Bluff pressure
subtitle_en: A bluff tries to make better hands fold.
title_ru: Давление блефом
subtitle_ru: Блеф работает тогда, когда руки лучше ещё могут выбросить.

- taskId: w4_bluff_intro
  status: missing
  title_en: Fold pressure
  phase: theory
  stepKind: learn
  runner: _world4BluffIntroRunner
  runnerPrompt_en: A bluff tries to win when better hands fold.
  runnerSupport_en: No fold chance, no clean bluff.
  runnerQuestion_en: What does a bluff need?
  teachingStep0_title_en: Fold pressure.
  teachingStep0_body_en: A bluff is a story backed by chips, not random betting.
  teachingStep0_title_ru: Блефу нужен пас.
  teachingStep0_body_ru: Блеф — это не случайная ставка, а история, за которой стоят фишки. Если лучшая рука не собирается выбрасывать, чистого блефа здесь уже нет.
  title_ru: Давление на пас
  runnerPrompt_ru: Блеф пытается выиграть банк тогда, когда лучшая рука выбрасывает.
  runnerSupport_ru: Без реального шанса на пас чистого блефа не получается.
  runnerQuestion_ru: Что обязательно нужно блефу?

- taskId: w4_bluff_pressure
  status: missing
  title_en: Apply pressure
  phase: drill
  stepKind: practice
  runner: _world4BluffPressureRunner
  runnerPrompt_en: Hero missed, but BB checked and can fold.
  runnerSupport_en: A small bet can apply pressure without risking too much.
  runnerQuestion_en: What action matches the bluff purpose?
  teachingStep0_title_en: Bluff wants folds.
  teachingStep0_body_en: When hero has no pair, the bet works only if folds happen.
  teachingStep0_title_ru: Блеф хочет выбить.
  teachingStep0_body_ru: Если у тебя нет пары, ставка работает только тогда, когда соперник сдаётся под давлением.
  title_ru: Дай давление
  runnerPrompt_ru: Ты не попал, но BB чекнул и ещё может выбросить.
  runnerSupport_ru: Небольшая ставка здесь может дать давление без лишнего риска.
  runnerQuestion_ru: Какое действие лучше совпадает с целью блефа?

- taskId: w4_bad_bluff
  status: missing
  title_en: Bad pressure
  phase: drill
  stepKind: practice
  runner: _world4BadBluffRunner
  runnerPrompt_en: Villain called big already. Fold pressure is low.
  runnerSupport_en: A bluff is weaker when the opponent is not folding.
  runnerQuestion_en: What is the safer beginner action?
  teachingStep0_title_en: Bluff wants folds.
  teachingStep0_body_en: When hero has no pair, the bet works only if folds happen.
  teachingStep0_title_ru: Плохой блеф не работает.
  teachingStep0_body_ru: Если соперник уже показал готовность платить, давление на пас становится заметно слабее.
  title_ru: Плохое давление
  runnerPrompt_ru: Соперник уже много вложил и не выглядит готовым выбрасывать.
  runnerSupport_ru: Когда пас маловероятен, блеф становится заметно хуже для новичка.
  runnerQuestion_ru: Какое действие здесь безопаснее для новичка?

- taskId: w4_bluff_recap
  status: missing
  title_en: Bluff recap
  phase: review
  stepKind: review
  runner: _world4BluffRecapRunner
  runnerPrompt_en: Lesson learned: bluff only when folds can happen.
  runnerSupport_en: Pressure matters, but not every missed hand must fire.
  runnerQuestion_en: What does a bluff try to create?
  teachingStep0_title_en: Bluff checklist.
  teachingStep0_body_en: Ask whether better hands can fold before betting a miss.
  teachingStep0_title_ru: Проверка на блеф.
  teachingStep0_body_ru: Перед ставкой с промахом сначала спроси себя, могут ли руки лучше реально выбросить.
  title_ru: Повтор по блефу
  runnerPrompt_ru: Вывод простой: блефовать стоит только там, где пас реально возможен.
  runnerSupport_ru: Давление важно, но не каждый промах обязан превращаться в ставку.
  runnerQuestion_ru: Что именно пытается создать блеф?

## lesson protection_and_denial
status: missing
title_en: Protection and denial
subtitle_en: Bet so the next card is not free.
title_ru: Защита от бесплатной карты
subtitle_ru: Ставь так, чтобы следующая карта не доставалась даром.

- taskId: w4_protection_intro
  status: missing
  title_en: Deny free card
  phase: theory
  stepKind: learn
  runner: _world4ProtectionIntroRunner
  runnerPrompt_en: Protection bets make the next card cost something.
  runnerSupport_en: This is value-adjacent, but the key word is deny.
  runnerQuestion_en: What does protection deny?
  teachingStep0_title_en: Deny free cards.
  teachingStep0_body_en: Protection makes the next card cost something.
  teachingStep0_title_ru: Не давай бесплатную карту.
  teachingStep0_body_ru: Если следующая карта может усилить соперника, ставка заставляет его платить за это улучшение. На доске Qh-9h-4c чек позволяет третьей черве прийти бесплатно. Ставка в 3 BB в банк 6 BB делает это улучшение платным и всё ещё может добрать, когда соперник не попал.
  title_ru: Не дать карту бесплатно
  runnerPrompt_ru: Защита делает следующую карту платной.
  runnerSupport_ru: Это рядом с вэлью, но здесь ключевое слово именно лишить бесплатного усиления.
  runnerQuestion_ru: Чего именно лишает защитная ставка?

- taskId: w4_protection_bet
  status: missing
  title_en: Protect pair
  phase: drill
  stepKind: practice
  runner: _world4ProtectionBetRunner
  runnerPrompt_en: Hero has top pair. Checking gives villain a free next card.
  runnerSupport_en: Betting protects value by denying that free card.
  runnerQuestion_en: What action fits protection?
  teachingStep0_title_en: Deny free cards.
  teachingStep0_body_en: Protection makes the next card cost something.
  teachingStep0_title_ru: Не давай бесплатную карту.
  teachingStep0_body_ru: Если следующая карта может усилить соперника, ставка заставляет его платить за просмотр этой карты.
  title_ru: Защитить пару
  runnerPrompt_ru: У тебя топ-пара. Чек отдаёт сопернику бесплатную следующую карту.
  runnerSupport_ru: Ставка защищает твоё вэлью, потому что бесплатной карты уже не будет.
  runnerQuestion_ru: Какое действие лучше всего подходит для защиты?

- taskId: w4_protection_check
  status: missing
  title_en: Free card risk
  phase: drill
  stepKind: practice
  runner: _world4ProtectionCheckRunner
  runnerPrompt_en: Hero checks. Villain gets a free next card.
  runnerSupport_en: This is the risk protection bets are trying to avoid.
  runnerQuestion_en: What did checking allow?
  teachingStep0_title_en: Deny free cards.
  teachingStep0_body_en: Protection makes the next card cost something.
  teachingStep0_title_ru: Чек отдал карту даром.
  teachingStep0_body_ru: Когда ты чекаешь, соперник может увидеть следующую карту бесплатно, даже если она опасна для твоей руки.
  title_ru: Риск бесплатной карты
  runnerPrompt_ru: Ты чекаешь. Соперник получает бесплатную следующую карту.
  runnerSupport_ru: Именно этот риск и пытаются убрать защитные ставки.
  runnerQuestion_ru: Что именно позволил чек?

- taskId: w4_protection_recap
  status: missing
  title_en: Protection recap
  phase: review
  stepKind: review
  runner: _world4ProtectionRecapRunner
  runnerPrompt_en: Lesson learned: protection denies a free next card.
  runnerSupport_en: Denying a free card is a real purpose.
  runnerQuestion_en: What does a protection bet deny?
  teachingStep0_title_en: Protection checklist.
  teachingStep0_body_en: Ask if checking gives away the next card too cheaply.
  teachingStep0_title_ru: Проверка на защиту.
  teachingStep0_body_ru: Сначала спроси себя, не отдаёт ли чек следующую карту слишком дёшево.
  title_ru: Повтор по защите
  runnerPrompt_ru: Вывод простой: защита не даёт следующей карте прийти бесплатно.
  runnerSupport_ru: Лишить бесплатной карты — это уже полноценная причина для ставки.
  runnerQuestion_ru: Чего лишает защитная ставка?

## lesson call_price
status: missing
title_en: Call price
subtitle_en: A bet gives you a price to continue.
title_ru: Цена колла
subtitle_ru: Любая ставка задаёт цену, за которую ты можешь продолжать.

- taskId: w4_price_intro
  status: missing
  title_en: Facing a price
  phase: theory
  stepKind: learn
  runner: _world4PriceIntroRunner
  runnerPrompt_en: When someone bets, they set your price to continue.
  runnerSupport_en: Price is what you must pay to continue. Read pot, to call, and hand strength together.
  runnerQuestion_en: What does a bet give the caller?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Pot tells what you can win. To call tells what you must risk. Compare both to hand strength before calling.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Колл значит, что ты платишь указанную цену за то, чтобы увидеть следующие карты и остаться в раздаче.
  title_ru: Перед тобой цена
  runnerPrompt_ru: Когда соперник ставит, он задаёт цену твоего продолжения.
  runnerSupport_ru: Маленькая цена чаще тянет на колл, большая уже часто толкает к пасу.
  runnerQuestion_ru: Что даёт ставка тому, кто думает о колле?

- taskId: w4_good_price_call
  status: missing
  title_en: Call small price
  phase: drill
  stepKind: practice
  runner: _world4GoodPriceCallRunner
  runnerPrompt_en: Pot is 8 BB. To call is 1 BB with one pair.
  runnerSupport_en: Small price, paired hand: calling is acceptable.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Pot tells what you can win. To call tells what you must risk. Compare both to hand strength before calling.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Маленькая цена с готовой рукой часто позволяет спокойно продолжить.
  title_ru: Колл по хорошей цене
  runnerPrompt_ru: В банке 8 BB. За колл нужно 1 BB, а у тебя пара.
  runnerSupport_ru: Маленькая цена и готовая рука делают колл здесь нормальным продолжением.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цене?

- taskId: w4_bad_price_fold
  status: missing
  title_en: Fold high price
  phase: drill
  stepKind: practice
  runner: _world4BadPriceFoldRunner
  runnerPrompt_en: Pot is 8 BB. To call is 7 BB with a weak pair.
  runnerSupport_en: The price is high and the hand is not strong enough.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Pot tells what you can win. To call tells what you must risk. Compare both to hand strength before calling.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Когда цена почти догоняет банк, а рука слабая, продолжение становится слишком дорогим.
  title_ru: Пас на высокой цене
  runnerPrompt_ru: В банке 8 BB. За колл нужно 7 BB, а у тебя слабая пара.
  runnerSupport_ru: Цена слишком высокая, а рука слишком слабая для такого продолжения.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цене?

- taskId: w4_cheap_price_marginal_call
  status: missing
  title_en: Cheap call with middle pair
  phase: drill
  stepKind: practice
  runner: _world4CheapPriceMarginalCallRunner
  runnerPrompt_en: Pot is 10 BB. To call is 1 BB with middle pair.
  runnerSupport_en: A cheap call can be okay when the pot is large enough and the hand still has value.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Cheap price, honest hand.
  teachingStep0_body_en: Do not look only at fear. Pot 10 BB and To call 1 BB make middle pair worth one calm continue.
  teachingStep0_title_ru: Дешёвая цена, нормальная рука.
  teachingStep0_body_ru: Не поддавайся страху. Банк 10 BB при цене колла всего в 1 BB делает продолжение со средней парой математически выгодным и спокойным решением.
  title_ru: Дешёвый колл со средней парой
  runnerPrompt_ru: В банке 10 BB. За колл нужно 1 BB со средней парой.
  runnerSupport_ru: Дешёвый колл может быть хорош, когда банк достаточно велик, а у руки всё ещё есть шоудаун-вэлью.
  runnerQuestion_ru: Какое действие лучше всего соответствует цене?

- taskId: w4_big_price_marginal_fold
  status: missing
  title_en: Big price, thinner hand
  phase: drill
  stepKind: practice
  runner: _world4BigPriceMarginalFoldRunner
  runnerPrompt_en: Pot is 9 BB. To call is 6 BB with top pair, weak kicker.
  runnerSupport_en: A bigger call needs a stronger reason. Hand strength alone is not enough here.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Big price needs more.
  teachingStep0_body_en: Top pair is not an auto-continue. Pot 9 BB and To call 6 BB mean the hand needs a stronger reason.
  teachingStep0_title_ru: Высокая цена требует большего.
  teachingStep0_body_ru: Топ-пара — это не автоматический колл. При банке 9 BB и цене колла 6 BB твоей руке нужна очень веская причина, чтобы продолжать.
  title_ru: Высокая цена, слабая рука
  runnerPrompt_ru: В банке 9 BB. За колл нужно 6 BB с топ-парой при слабом кикере.
  runnerSupport_ru: Дорогой колл требует сильных аргументов. Одной лишь силы топ-пары здесь уже недостаточно.
  runnerQuestion_ru: Какое действие лучше всего соответствует цене?

- taskId: w4_price_recap
  status: missing
  title_en: Price recap
  phase: review
  stepKind: review
  runner: _world4PriceRecapRunner
  runnerPrompt_en: Lesson learned: every call has a price.
  runnerSupport_en: Compare the price to hand strength and future cards.
  runnerQuestion_en: What should you read before calling?
  teachingStep0_title_en: Price checklist.
  teachingStep0_body_en: Read pot, to-call, and hand strength before calling.
  teachingStep0_title_ru: Короткая проверка цены.
  teachingStep0_body_ru: Перед коллом сначала прочитай банк, цену продолжения и силу своей руки.
  title_ru: Повтор по цене
  runnerPrompt_ru: Вывод простой: у каждого колла есть своя цена.
  runnerSupport_ru: Сравни цену с силой руки и тем, что может случиться дальше.
  runnerQuestion_ru: Что нужно прочитать перед коллом?

## lesson small_half_pot
status: missing
title_en: Small, half, pot
subtitle_en: Size says how much pressure you create.
title_ru: Маленькая, полбанка, банк
subtitle_ru: Размер ставки задаёт, сколько давления и цены ты создаёшь.

- taskId: w4_sizing_intro
  status: missing
  title_en: Size language
  phase: theory
  stepKind: learn
  runner: _world4SizingIntroRunner
  runnerPrompt_en: Bet size changes pressure and price.
  runnerSupport_en: One-third is light, half-pot is common, pot-size is heavy.
  runnerQuestion_en: What does size change?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Ставки в треть банка, полбанка и банк создают разную цену и разное давление. Треть банка — лёгкий пробный размер, полбанка — середина, банк — уже тяжёлое давление.
  title_ru: Язык размеров
  runnerPrompt_ru: Размер ставки меняет и давление, и цену.
  runnerSupport_ru: Треть банка лёгкая, полбанка стандартная, банк уже тяжёлый размер.
  runnerQuestion_ru: Что именно меняет размер ставки?

- taskId: w4_small_bet
  status: missing
  title_en: One-third bet
  phase: drill
  stepKind: practice
  runner: _world4SmallBetRunner
  runnerPrompt_en: Pot is 6 BB. Hero wants light pressure.
  runnerSupport_en: One-third pot is the smallest simple pressure size here.
  runnerQuestion_en: Which size is one-third pot?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Треть банка создаёт самый лёгкий и дешёвый вариант давления в этой базовой линейке.
  title_ru: Ставка в треть банка
  runnerPrompt_ru: В банке 6 BB. Ты хочешь дать лёгкое давление.
  runnerSupport_ru: Треть банка здесь — самый маленький из простых размеров давления.
  runnerQuestion_ru: Какой размер здесь равен трети банка?

- taskId: w4_half_pot_bet
  status: missing
  title_en: Half-pot bet
  phase: drill
  stepKind: practice
  runner: _world4HalfPotRunner
  runnerPrompt_en: Pot is 6 BB. Hero wants the clean middle size.
  runnerSupport_en: Half-pot means betting half the pot, not the smallest or biggest size.
  runnerQuestion_en: Which size is half-pot?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Полбанка — это средний и самый универсальный учебный размер между маленьким и тяжёлым давлением.
  title_ru: Ставка в полбанка
  runnerPrompt_ru: В банке 6 BB. Ты хочешь выбрать чистый средний размер.
  runnerSupport_ru: Полбанка — это половина банка, а не самый маленький и не самый тяжёлый размер.
  runnerQuestion_ru: Какой размер здесь равен половине банка?

- taskId: w4_pot_bet
  status: missing
  title_en: Pot-size bet
  phase: drill
  stepKind: practice
  runner: _world4PotBetRunner
  runnerPrompt_en: Pot is 6 BB. A pot-size bet is heavy pressure.
  runnerSupport_en: Pot-size means the bet matches the pot.
  runnerQuestion_en: Which size is pot-size?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Ставка в банк создаёт тяжёлое давление, потому что цена продолжения становится самой жёсткой в этой базовой тройке.
  title_ru: Ставка в банк
  runnerPrompt_ru: В банке 6 BB. Ставка размером в банк — это уже тяжёлое давление.
  runnerSupport_ru: Размер в банк означает, что ставка по величине равна самому банку.
  runnerQuestion_ru: Какой размер здесь равен банку?

- taskId: w4_sizing_recap
  status: missing
  title_en: Sizing recap
  phase: review
  stepKind: review
  runner: _world4SizingRecapRunner
  runnerPrompt_en: Lesson learned: size sets pressure and price.
  runnerSupport_en: Small, half-pot, and pot-size should match the purpose.
  runnerQuestion_en: What should size match?
  teachingStep0_title_en: Sizing checklist.
  teachingStep0_body_en: Name purpose, then choose a size that fits the pressure: light, middle, or heavy.
  teachingStep0_title_ru: Проверка по размеру.
  teachingStep0_body_ru: Сначала назови цель ставки, а потом подбери под неё лёгкий, средний или тяжёлый размер.
  title_ru: Повтор по размерам
  runnerPrompt_ru: Вывод простой: размер задаёт давление и цену.
  runnerSupport_ru: Маленький, полбанка и банк должны совпадать с тем, чего ты хочешь от ставки.
  runnerQuestion_ru: С чем должен совпадать размер ставки?

## lesson price_checkpoint
status: missing
title_en: Price checkpoint
subtitle_en: Read purpose, size, and price before action.
title_ru: Проверка цели, размера и цены
subtitle_ru: Перед действием прочитай цель ставки, её размер и цену продолжения.

- taskId: w4_checkpoint_intro
  status: missing
  title_en: Three reads
  phase: theory
  stepKind: learn
  runner: _world4CheckpointIntroRunner
  runnerPrompt_en: Checkpoint: purpose, size, and price work together.
  runnerSupport_en: The bettor sets pressure. The caller reads the price.
  runnerQuestion_en: What are the three World 4 reads?
  teachingStep0_title_en: Three reads.
  teachingStep0_body_en: Purpose explains why. Size creates pressure. Price decides calls.
  teachingStep0_title_ru: Три чтения.
  teachingStep0_body_ru: Цель объясняет зачем, размер создаёт давление, а цена отвечает, стоит ли продолжать.
  title_ru: Три чтения
  runnerPrompt_ru: Контрольная точка: цель, размер и цена работают вместе.
  runnerSupport_ru: Тот, кто ставит, создаёт давление. Тот, кто думает о колле, читает цену.
  runnerQuestion_ru: Какие три чтения собирает World 5?

- taskId: w4_checkpoint_value
  status: missing
  title_en: Value or bluff
  phase: drill
  stepKind: practice
  runner: _world4ValuePurposeRunner
  runnerPrompt_en: Hero has top pair. Worse hands can call.
  runnerSupport_en: This bet is not just noise. It wants calls from weaker hands.
  runnerQuestion_en: What is the main purpose?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Вэлью хочет колл.
  teachingStep0_body_ru: С топ-парой хуже ещё платит, значит цель ставки здесь остаётся простой и чистой.
  title_ru: Вэлью или блеф
  runnerPrompt_ru: У тебя топ-пара. Руки слабее ещё могут платить.
  runnerSupport_ru: Эта ставка нужна не для шума, а для коллов от рук хуже.
  runnerQuestion_ru: Какая здесь главная цель ставки?

- taskId: w4_checkpoint_price
  status: missing
  title_en: Call or fold
  phase: drill
  stepKind: practice
  runner: _world4BadPriceFoldRunner
  runnerPrompt_en: Pot is 8 BB. To call is 7 BB with a weak pair.
  runnerSupport_en: The price is high and the hand is not strong enough.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Pot tells what you can win. To call tells what you must risk. Compare both to hand strength before calling.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Колл — это всегда плата за продолжение. Когда цена слишком велика для силы руки, спокойный пас лучше.
  title_ru: Колл или пас
  runnerPrompt_ru: В банке 8 BB. За колл нужно 7 BB, а у тебя слабая пара.
  runnerSupport_ru: Цена высокая, а рука слишком слабая, чтобы продолжать с комфортом.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цене?

- taskId: w4_checkpoint_table_price
  status: missing
  title_en: Real-table price read
  phase: drill
  stepKind: practice
  runner: _world4PriceTableTransferRunner
  runnerPrompt_en: Real table. Pot is 7 BB. To call is 2 BB. Hero has second pair.
  runnerSupport_en: Do not look only at your hand. Compare hand strength with the price before reacting.
  runnerQuestion_en: What is the clean turn action?
  teachingStep0_title_en: Live table price read.
  teachingStep0_body_en: Pot tells what you can win. To call tells what you must risk. Compare both with second pair before choosing.
  teachingStep0_title_ru: Чтение цены за столом.
  teachingStep0_body_ru: Банк показывает, сколько можно выиграть, а цена колла — сколько нужно рискнуть. Сопоставь оба значения со своей второй парой перед принятием решения.
  title_ru: Чтение цены за живым столом
  runnerPrompt_ru: Живой стол. В банке 7 BB. За колл нужно 2 BB. У тебя вторая пара.
  runnerSupport_ru: Не смотри только на карту. Всегда сравнивай силу руки с ценой продолжения, прежде чем нажать кнопку.
  runnerQuestion_ru: Какое действие на тёрне будет самым чистым?

- taskId: w4_checkpoint_table_purpose_price
  status: missing
  title_en: Live purpose and price
  phase: drill
  stepKind: practice
  runner: _world4PurposePriceTableTransferRunner
  runnerPrompt_en: Real table. Pot is 6 BB. BTN bets 2 BB with top pair on a dry flop.
  runnerSupport_en: Read both halves together: the bet has a value purpose, and the small size gives BB a cheap continue price.
  runnerQuestion_en: What is the clean read?
  teachingStep0_title_en: Purpose and price travel together.
  teachingStep0_body_en: A live bet is clearer when you name both the job and the price it creates. Here top pair wants calls, and 2 BB keeps that continue cheap.
  teachingStep0_title_ru: Цель и цена идут вместе.
  teachingStep0_body_ru: Любую ставку проще читать, если назвать её задачу и цену, которую она создаёт. Здесь топ-пара соперника хочет добрать (вэлью), а ставка 2 BB оставляет колл дешёвым.
  title_ru: Цель и цена в реальной раздаче
  runnerPrompt_ru: Живой стол. В банке 6 BB. BTN ставит 2 BB с топ-парой на сухом флопе.
  runnerSupport_ru: Читай обе половины вместе: у ставки есть цель (добор), а её небольшой размер даёт BB дешёвую цену для продолжения.
  runnerQuestion_ru: Какое чтение ситуации будет самым точным?

- taskId: w4_checkpoint_review
  status: missing
  title_en: Price recap
  phase: review
  stepKind: proveIt
  runner: _world4CheckpointRunner
  runnerPrompt_en: Lesson learned: betting is purpose plus price.
  runnerSupport_en: Value, bluff, protection, and call price are now one system.
  runnerQuestion_en: What makes a bet easier to understand?
  teachingStep0_title_en: World 4 checkpoint.
  teachingStep0_body_en: Read what the bet wants and what it costs to continue.
  teachingStep0_title_ru: Контрольная точка World 5.
  teachingStep0_body_ru: Сначала прочитай, чего ставка хочет, потом посмотри, какой размер она создаёт и сколько стоит продолжение.
  title_ru: Повтор по цене и смыслу
  runnerPrompt_ru: Вывод простой: ставка читается через цель и цену вместе.
  runnerSupport_ru: Вэлью, блеф, защита и цена колла теперь складываются в одну систему.
  runnerQuestion_ru: Что делает ставку понятнее для игрока?

