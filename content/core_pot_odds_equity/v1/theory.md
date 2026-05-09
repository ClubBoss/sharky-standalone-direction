# Pot Odds & Equity

## Key Idea
- Pot odds compare the price of a call to the size of the pot.
- Equity is your chance to win by showdown if both hands keep going.
- The rule of 4 on the flop and the rule of 2 on the turn give a fast estimate from clean outs.

## Mini-Example
- On the flop, the pot is 120 and the bet is 30. Calling costs 30 to win 150, so the price is 20%.
- If you have 9 clean outs, the rule of 4 gives about 36% equity, so calling is profitable.
- On the turn, the same 9 outs give about 18%. If the price is higher than that and no extra money is likely later, folding is fine.

## Working Rules
- Compute pot odds as `call / (pot + call)`.
- Count only clean outs. Ignore cards that can complete a stronger hand for the other player.
- Use the rule of 4 on the flop and the rule of 2 on the turn for a quick estimate.
- When the numbers are close, ask whether future betting helps or hurts you before you continue.

## Quick Check
- What price are you getting when you call 25 to win a pot that will become 125?
- Why do dirty outs make a draw look better than it really is?
