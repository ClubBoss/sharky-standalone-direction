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
  title_ru: 
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

