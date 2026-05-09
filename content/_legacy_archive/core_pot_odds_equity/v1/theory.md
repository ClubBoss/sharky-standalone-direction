# Theory Micro-Loop


## Key Idea
- Pot odds tie the call price to potential winnings, equity captures your showdown chance, and the rule of 2/4 offers a quick estimate so math drives the decision.

## Mini-Example
- BTN bets 30 into a 120 pot; rule of 4 with nine clean outs yields 36% equity vs pot odds 20%, so call. The turn rule of 2 gives ~18% vs pot odds 25%, so fold without implied odds.

## Actionable Rules
- Compute pot odds as call_amount / (pot + call_amount) to find your breakeven percentage.
- Use rule of 4 on the flop and rule of 2 on the turn to translate clean outs into equity.
- Count only clean outs; drop cards that pair the board, give opponents better hands, or are blocked.
- Factor implied odds when current pot odds are marginal, and respect reverse implied odds when made hands can still lose.

## Quick Check
- When do you trust pot odds instead of waiting for implied odds?
- Why does the rule of 2 apply only after the flop?

See also
- cash_3bet_oop_playbook (score 4) -> ../../cash_3bet_oop_playbook/v1/theory.md
- cash_blind_defense (score 4) -> ../../cash_blind_defense/v1/theory.md
- cash_blind_defense_vs_btn_co (score 4) -> ../../cash_blind_defense_vs_btn_co/v1/theory.md
- cash_blind_vs_blind (score 4) -> ../../cash_blind_vs_blind/v1/theory.md
- cash_delayed_cbet_and_probe_systems (score 4) -> ../../cash_delayed_cbet_and_probe_systems/v1/theory.md
