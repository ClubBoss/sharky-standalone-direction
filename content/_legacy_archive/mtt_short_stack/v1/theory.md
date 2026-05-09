What it is
Short-stack play covers 8-25bb effective in 9-max MTTs. At 8-12bb, decisions cluster around push/fold and reshove. At 13-17bb, mixes include jam, raise-call, and raise-fold. At 18-25bb, small opens and 3-bet/4-bet trees reappear, but SPR stays low, so commitment math drives lines more than fancy maneuvering.


Why it matters
Antes inflate pots and shorten SPR. Small mistakes compound fast when close to all-in. A clean, tokenized plan avoids spew: map preflop to simple shove/reshove families and keep postflop sizes tied to equity and geometry. Pools under-4bet and overfold turns; exploit while staying value heavy.

Rules of thumb
- Preflop: treat 3bet_ip_9bb and 3bet_oop_12bb as shove/reshove proxies at 8-17bb; use 4bet_ip_21bb and 4bet_oop_24bb as all-in 4-bet proxies.
- Stack depth: 8-12bb jam or reshove with blockers, avoid flats OOP; 13-17bb raise-call premiums and raise-fold suited wheels; 18-25bb reopen small opens, prefer 3bet_oop_12bb over flats from blinds.
- Open sizes: keep opens small; when dominated multiway risk is high, prefer fold or 3bet_oop_12bb over flatting trash.
- Postflop: small_cbet_33 on dry to deny cheaply; half_pot_50 when planning to commit; big_bet_75 only with size_up_wet and strong equity. As OOP, protect_check_range on middling, avoid thin stabs.
- Exploits: tag overfold_exploit on turns where population gives up; do not bluff-catch without blockers at shallow SPR.

Mini example
UTG and MP fold; CO opens 2.2bb; BTN 3bet_ip_9bb to 9bb; SB reshoves 15bb; BB folds. CO folds; action returns to BTN. With QQ/AK, BTN treats 4bet_ip_21bb as a call-off and commits; with AJs/KQs he releases versus the reshove. Result: clean preflop commitment at low SPR without awkward postflop guessing.

Common mistakes
- Flatting 10-15bb OOP versus late opens, then folding flop. You donate antes and realize poorly.
- Auto big_bet_75 at low SPR without equity. You polarize, get raised, and cannot fold.
- Bluff 4-betting without blockers at 15-20bb. Ranges are strong and you torch EV.

Mini-glossary
Shove/reshove proxy: Using 3bet_ip_9bb or 3bet_oop_12bb as shorthand for jam/reshove trees.
Commitment math: Plan lines that commit by turn when price and SPR align.
SPR: Stack-to-pot ratio; low values compress play and favor all-in decisions.
overfold_exploit: Intentional pressure where pools fold too much, often on turns.
EV: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Unlike deep-stacked cash, short-stack MTT play compresses ranges and forces commitment earlier. You map preflop to shove/reshove families, default to small_cbet_33 on dry, and reserve big_bet_75 for size_up_wet with real equity; most thin lines vanish at low SPR.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- cash_short_handed (score 27) -> ../../cash_short_handed/v1/theory.md
- database_leakfinder_playbook (score 27) -> ../../database_leakfinder_playbook/v1/theory.md
- donk_bets_and_leads (score 27) -> ../../donk_bets_and_leads/v1/theory.md
- icm_final_table_hu (score 27) -> ../../icm_final_table_hu/v1/theory.md
- live_chip_handling_and_bet_declares (score 27) -> ../../live_chip_handling_and_bet_declares/v1/theory.md
