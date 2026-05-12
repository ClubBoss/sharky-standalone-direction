# Act0 RU Next Batch v1

Status: GENERATED
Purpose: one-file handoff for the next highest-EV RU batch

## Recommended Order
1. `world_3`
Reason: tiny remaining gap, cheap closure, keeps early route coherent.
2. `world_5`
Reason: first large empty teaching block with real task volume.
3. `world_7` to `world_10`
Reason: consecutive mid-course empty blocks; best batching efficiency.
4. `world_11` to `world_12`
Reason: tail blocks can be drafted last without blocking active route.

## Runtime Rule
Do not paste raw machine output straight into `act0_copy_ru_v1.dart`.
First fill this batch doc, then review, then ingest selected worlds back into the language file.

## Included Packs

---

## Pack: world_3

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
- Teaching step titles: 0/6
- Teaching step bodies: 0/6

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
  teachingStep0_title_en: Seat, then hand.
  teachingStep0_body_en: Check where you sit before deciding what to do with the hand.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Position checklist.
  teachingStep0_body_en: Bucket the hand, then ask if the seat helps or hurts.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль проста: позиция меняет комфорт ещё до действия.
  runnerSupport_ru: Поздние места помогают, ранние требуют более крепкой руки и более чистой причины продолжать.
  runnerQuestion_ru: На что нужно смотреть сразу после группы руки?


---

## Pack: world_5

# world_5 RU Translation Pack

Status: GENERATED
World number: 5
EN title: Bet Purpose And Price
EN subtitle: Understand value, bluff, protection, and call price.
title_ru: Смысл ставки и цена
subtitle_ru: Пойми вэлью, блеф, защиту и цену колла без перегруза.

## Coverage
- Lessons: 0/7
- Tasks: 0/29
- Runner prompts: 0/29
- Runner supports: 0/29
- Runner questions: 0/29
- Teaching step titles: 0/29
- Teaching step bodies: 0/29

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
title_ru:
subtitle_ru:

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
  teachingStep0_body_en: Before choosing chips, ask what the bet is trying to do. Pot is 6 BB on the flop. Are you betting to collect chips from weaker hands (value), to fold out better hands (bluff), or to charge the next card before it arrives free (protection)? Name one reason, then pick a size.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson value_bets
status: missing
title_en: Value bets
subtitle_en: Bet when worse hands can still call.
title_ru:
subtitle_ru:

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
  teachingStep0_body_en: Value is simple: bet because worse hands can still pay. Hero has top pair with AQ on an A-7-2 board. Pot is 6 BB. Betting 3 BB asks every weaker ace, every pair of sevens, every pair of twos to put in chips you win on average.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson bluff_pressure
status: missing
title_en: Bluff pressure
subtitle_en: A bluff tries to make better hands fold.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson protection_and_denial
status: missing
title_en: Protection and denial
subtitle_en: Bet so the next card is not free.
title_ru:
subtitle_ru:

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
  teachingStep0_body_en: If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson call_price
status: missing
title_en: Call price
subtitle_en: A bet gives you a price to continue.
title_ru:
subtitle_ru:

- taskId: w4_price_intro
  status: missing
  title_en: Facing a price
  phase: theory
  stepKind: learn
  runner: _world4PriceIntroRunner
  runnerPrompt_en: When someone bets, they set your price to continue.
  runnerSupport_en: Small price can invite a call. Big price can force a fold.
  runnerQuestion_en: What does a bet give the caller?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson small_half_pot
status: missing
title_en: Small, half, pot
subtitle_en: Size says how much pressure you create.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson price_checkpoint
status: missing
title_en: Price checkpoint
subtitle_en: Read purpose, size, and price before action.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:


---

## Pack: world_7

# world_7 RU Translation Pack

Status: GENERATED
World number: 7
EN title: Range Thinking Lite
EN subtitle: Group hands into simple buckets without solver talk.
title_ru: Диапазоны без перегруза
subtitle_ru: Группируй руки в простые диапазоны без солверного шума.

## Coverage
- Lessons: 0/5
- Tasks: 0/27
- Runner prompts: 0/27
- Runner supports: 0/27
- Runner questions: 0/27
- Teaching step titles: 0/27
- Teaching step bodies: 0/27

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
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson range_board_fit
status: missing
title_en: Range meets board
subtitle_en: Board texture can shift a hand from value to missed.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson range_pressure_lines
status: missing
title_en: Value, bluff, missed
subtitle_en: Each bucket suggests a different action direction.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson range_combo_counts
status: missing
title_en: Count the combos
subtitle_en: AK has 16 combos. A pocket pair has 6.
title_ru:
subtitle_ru:

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
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson range_thinking_checkpoint
status: missing
title_en: Range thinking checkpoint
subtitle_en: Bucket, board fit, combo count, then pressure.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:


---

## Pack: world_8

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
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson same_hand_different_depth
status: missing
title_en: Same hand, different depth
subtitle_en: A hand can widen at 20 BB and tighten at 100 BB.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson spr_and_commitment
status: missing
title_en: Room or commitment
subtitle_en: Low SPR means less room. High SPR means more room to maneuver.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson format_pressure
status: missing
title_en: 6-max vs full ring
subtitle_en: The same hand can open wider in 6-max than in full ring.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:


---

## Pack: world_9

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
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Name pressure before action.
  teachingStep0_body_en: Real tournament spots get easier when you first identify who can pressure and who pays the bigger busting cost.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Pressure before exploit.
  teachingStep0_body_en: First map pressure with stack and payout context. Then choose exploit lines based on who is overfolding, calling too wide, or avoiding risk.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:


---

## Pack: world_10

# world_10 RU Translation Pack

Status: GENERATED
World number: 10
EN title: Player Adjustment
EN subtitle: Adjust one lever at a time against real player types.
title_ru: Подстройка под игроков
subtitle_ru: Меняй один рычаг за раз против реальных типов игроков.

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

## lesson player_type_basics
status: missing
title_en: Who is at the table
subtitle_en: Tag players by one tendency before changing your line.
title_ru:
subtitle_ru:

- taskId: w10_player_type_intro
  status: missing
  title_en: One tendency first
  phase: theory
  stepKind: learn
  runner: _w10PlayerTypeIntroRunner
  runnerPrompt_en: Tag one clear tendency before you change strategy.
  runnerSupport_en: One useful read beats five vague labels.
  runnerQuestion_en: What is the first step in player adjustment?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_nit_tag
  status: missing
  title_en: Nit profile
  phase: drill
  stepKind: practice
  runner: _w10NitTagRunner
  runnerPrompt_en: Villain folds to steals repeatedly and rarely 3-bets.
  runnerSupport_en: Tight fold-heavy behavior has one obvious label.
  runnerQuestion_en: What is the most useful quick tag?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_loose_passive_tag
  status: missing
  title_en: Loose-passive profile
  phase: drill
  stepKind: practice
  runner: _w10LoosePassiveTagRunner
  runnerPrompt_en: Villain calls often preflop and postflop but rarely raises.
  runnerSupport_en: Calling wide without raises signals a common profile.
  runnerQuestion_en: What quick tag fits best?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_overaggressive_tag
  status: missing
  title_en: Over-aggressive profile
  phase: drill
  stepKind: practice
  runner: _w10OveraggressiveTagRunner
  runnerPrompt_en: Villain double-barrels missed boards and raises often.
  runnerSupport_en: Frequent pressure with weak showdowns points to one useful tag.
  runnerQuestion_en: What quick tag fits best?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_player_type_recap
  status: missing
  title_en: Player-type recap
  phase: review
  stepKind: review
  runner: _w10PlayerTypeRecapRunner
  runnerPrompt_en: Lesson learned: one tendency tag creates a cleaner exploit plan.
  runnerSupport_en: Avoid complex labels before evidence is stable.
  runnerQuestion_en: What is the tagging takeaway?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson adjust_one_lever
status: missing
title_en: Adjust one lever
subtitle_en: Change one action size or frequency, not everything at once.
title_ru:
subtitle_ru:

- taskId: w10_one_lever_intro
  status: missing
  title_en: One change at a time
  phase: theory
  stepKind: learn
  runner: _w10OneLeverIntroRunner
  runnerPrompt_en: Change one lever first: opening width, value density, or bluff rate.
  runnerSupport_en: Small precise changes are easier to trust and test.
  runnerQuestion_en: Why adjust one lever at a time?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_vs_nit_open_wider
  status: missing
  title_en: Steal more vs tight folds
  phase: drill
  stepKind: practice
  runner: _w10VsNitOpenWiderRunner
  runnerPrompt_en: Blinds fold too much to late-position steals.
  runnerSupport_en: Overfolding behind you increases steal EV.
  runnerQuestion_en: What is the clean first exploit?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_vs_caller_value_heavier
  status: missing
  title_en: Value heavier vs callers
  phase: drill
  stepKind: practice
  runner: _w10VsCallerValueHeavierRunner
  runnerPrompt_en: Villain calls down too wide with weak pairs.
  runnerSupport_en: Call-heavy opponents pay off thin value more often.
  runnerQuestion_en: What is the cleaner exploit lever?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_vs_sticky_defender_tighten_steals
  status: missing
  title_en: Tighten steals vs sticky defenders
  phase: drill
  stepKind: practice
  runner: _w10VsStickyDefenderTightenStealsRunner
  runnerPrompt_en: Blinds defend wide and call postflop too often.
  runnerSupport_en: A sticky defender changes the cleanest steal lever.
  runnerQuestion_en: What is the better first adjustment?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_one_lever_recap
  status: missing
  title_en: One-lever recap
  phase: review
  stepKind: review
  runner: _w10OneLeverRecapRunner
  runnerPrompt_en: Lesson learned: one lever gives cleaner exploit feedback loops.
  runnerSupport_en: Test one change before stacking new assumptions.
  runnerQuestion_en: What is the one-lever takeaway?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson exploit_guardrails
status: missing
title_en: Exploit guardrails
subtitle_en: Exploit with discipline so your line stays coherent.
title_ru:
subtitle_ru:

- taskId: w10_guardrails_intro
  status: missing
  title_en: Exploit without chaos
  phase: theory
  stepKind: learn
  runner: _w10ExploitGuardrailsIntroRunner
  runnerPrompt_en: Exploit does not mean abandoning discipline or hand quality.
  runnerSupport_en: Guardrails keep you from over-adjusting on thin evidence.
  runnerQuestion_en: Why do exploit guardrails matter?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_overbluff_punish
  status: missing
  title_en: Punish overbluffs
  phase: drill
  stepKind: practice
  runner: _w10OverbluffPunishRunner
  runnerPrompt_en: Villain barrels many missed draws in obvious spots.
  runnerSupport_en: Overbluffing can be punished by wider bluff-catch windows.
  runnerQuestion_en: What is the cleaner exploit response?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_underbluff_fold_more
  status: missing
  title_en: Fold more vs underbluffs
  phase: drill
  stepKind: practice
  runner: _w10UnderbluffFoldMoreRunner
  runnerPrompt_en: Villain reaches river with strong value and few bluffs.
  runnerSupport_en: Underbluffing changes bluff-catch requirements.
  runnerQuestion_en: What is the sharper adjustment?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_guardrail_sample_size
  status: missing
  title_en: Respect sample size
  phase: drill
  stepKind: practice
  runner: _w10GuardrailSampleSizeRunner
  runnerPrompt_en: You saw two odd hands but no long pattern yet.
  runnerSupport_en: Guardrails protect you when evidence is still thin.
  runnerQuestion_en: What is the cleaner exploit posture?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_guardrails_recap
  status: missing
  title_en: Guardrails recap
  phase: review
  stepKind: review
  runner: _w10ExploitGuardrailsRecapRunner
  runnerPrompt_en: Lesson learned: exploits work best with guardrails and evidence.
  runnerSupport_en: Do not let one read become a full strategy collapse.
  runnerQuestion_en: What is the guardrail takeaway?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson player_adjustment_checkpoint
status: missing
title_en: Player-adjustment checkpoint
subtitle_en: Tag tendency, adjust one lever, keep guardrails, then transfer to real play.
title_ru:
subtitle_ru:

- taskId: w10_checkpoint_intro
  status: missing
  title_en: Three-step exploit loop
  phase: theory
  stepKind: learn
  runner: _w10PlayerTypeIntroRunner
  runnerPrompt_en: Tag one clear tendency before you change strategy.
  runnerSupport_en: One useful read beats five vague labels.
  runnerQuestion_en: What is the first step in player adjustment?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_checkpoint_tag_line
  status: missing
  title_en: Tag then act
  phase: drill
  stepKind: practice
  runner: _w10CheckpointTagLineRunner
  runnerPrompt_en: Opponent folds blinds often but calls rivers too wide.
  runnerSupport_en: You can tag both tendencies, then choose one main lever first.
  runnerQuestion_en: What is the cleaner first step?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_checkpoint_lever_line
  status: missing
  title_en: One-lever exploit line
  phase: drill
  stepKind: practice
  runner: _w10CheckpointLeverLineRunner
  runnerPrompt_en: A tight blind fold profile appears in your sample.
  runnerSupport_en: Single-lever adjustment is the test.
  runnerQuestion_en: Which exploit line is the cleanest first move?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_checkpoint_guardrail_line
  status: missing
  title_en: Guardrail discipline
  phase: drill
  stepKind: practice
  runner: _w10CheckpointGuardrailLineRunner
  runnerPrompt_en: You saw one wild bluff from villain this orbit.
  runnerSupport_en: Single hand reads can be noisy.
  runnerQuestion_en: What is the best guardrail action?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_checkpoint_table_notice
  status: missing
  title_en: Real-table exploit read
  phase: drill
  stepKind: practice
  runner: _w10TableAdjustmentNoticeRunner
  runnerPrompt_en: Real table. Both blinds have folded to your late steals again and again.
  runnerSupport_en: Choose the first exploit you can actually track at the table.
  runnerQuestion_en: What is the clean first live adjustment?
  teachingStep0_title_en: Carry one exploit to the table.
  teachingStep0_body_en: Tag the tendency, pick one lever, and keep the change small enough that you can see whether it is working.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_checkpoint_review
  status: missing
  title_en: Player-adjustment recap
  phase: review
  stepKind: proveIt
  runner: _world10PlayerAdjustmentCheckpointRunner
  runnerPrompt_en: Lesson learned: tag tendency, adjust one lever, keep guardrails.
  runnerSupport_en: Next you will transfer these guardrails-based adjustments into real-play decisions across mixed table conditions.
  runnerQuestion_en: What does player adjustment add before real-play transfer?
  teachingStep0_title_en: Exploit with structure.
  teachingStep0_body_en: Tag one tendency, choose one lever, keep guardrails, then test across table dynamics instead of one isolated hand.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:


---

## Pack: world_11

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
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson table_trigger_reads
status: missing
title_en: In-session trigger reads
subtitle_en: Spot one trigger and apply one adjustment immediately.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson post_session_review_loop
status: missing
title_en: Post-session review loop
subtitle_en: Convert one leak into one repair target for tomorrow.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson real_play_transfer_checkpoint
status: missing
title_en: Real-play transfer checkpoint
subtitle_en: Plan, trigger, review, then repeat as a daily loop.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:


---

## Pack: world_12

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
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson tilt_reset_protocol
status: missing
title_en: Tilt reset protocol
subtitle_en: Use a short reset so one hand does not own the session.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson confidence_and_discipline
status: missing
title_en: Confidence with discipline
subtitle_en: Play assertively without drifting into ego calls.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w12_confidence_recap
  status: missing
  title_en: Confidence recap
  phase: review
  stepKind: review
  runner: _w12ConfidenceDisciplineRecapRunner
  title_ru:

## lesson mindset_bridge_checkpoint
status: missing
title_en: Mindset bridge checkpoint
subtitle_en: Carry process, reset, and discipline into postflop growth.
title_ru:
subtitle_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

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
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

