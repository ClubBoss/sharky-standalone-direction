# POKER_SEMANTICS_TRUTH_v1

## Purpose

Define the first canonical poker semantics truth layer so future content, validators, and feedback logic are governed by one explicit semantic source of truth instead of local wording or partial hand-category rules.

This SSOT is intentionally bounded.
It covers the current visible-card showdown truth slice and adjacent wording rules that are already active in the World 2 validator foundation.

It does not define a full poker rules engine or a full strategy handbook.

## Governs Now

This SSOT governs:
- canonical hand/category naming inside the current bounded truth scope
- showdown winner truth wording for visible-card comparisons
- board-plays / tie / shared-best-hand semantics
- copy-strength boundaries for the current family
- the rule that prompt/feedback/why copy must not contradict visible card truth

This SSOT does not yet govern:
- full all-hand taxonomy across every world and mode family
- pot-odds, betting, strategy, or exploit language
- every future tie subtype
- full kicker-explanation pedagogy
- runtime solver logic or a universal ranking engine rewrite

## Core Principle

Visible card truth owns semantic truth.

Operational meaning:
- if the source exposes enough cards to resolve the made hand or showdown winner, copy must follow that truth
- copy may simplify wording, but it must not overclaim, underclaim, or contradict what the visible cards justify

## Bounded Semantic Domain

This SSOT currently covers:
- visible-card showdown comparisons
- winner truth in bounded hero vs villain visible showdowns
- pair-family naming boundaries
- explicit made-hand wording for:
  - two pair
  - trips
  - set
  - straight
  - flush
- board-plays / tie / shared-best-hand semantics

## Canonical Hand / Category Naming

Use these canonical terms in the current bounded scope:

### Pair Family

- `top pair`
- `second pair`
- `bottom pair`
- `overpair`
- `underpair`

These terms are only allowed when the visible cards truly justify them.

### Made Hands

- `two pair`
- `trips`
- `set`
- `straight`
- `flush`

These terms are stronger than generic pair-family wording and must not appear unless the visible cards really make that hand.

### Showdown Outcome Terms

- `hero wins`
- `villain wins`
- `board plays`
- `tie`
- `both players tie`
- `shared best hand`
- `best hand for both players`

These terms describe showdown truth, not strategy advice.

## Pair-Family Boundary Rules

### Top / Second / Bottom Pair

These labels are relative to the board ranks actually paired by the player’s best hand.

Use them only when:
- the player holds exactly one pair-category hand in the relevant bounded wording sense
- and the pair rank really corresponds to the top, second, or bottom relevant board-pair layer

Do not use them when the visible cards actually resolve to:
- two pair
- trips
- set
- a stronger made hand

### Overpair

`overpair` is allowed only when:
- the player’s pocket pair is higher than every board rank
- and the best visible made hand remains one pair in the relevant bounded sense

Do not use `overpair` if the visible cards actually resolve to:
- two pair
- trips / set
- straight or better

### Underpair

`underpair` is allowed only when:
- the player’s pocket pair is lower than the relevant board-pair threshold
- and the visible hand remains one pair rather than a stronger made hand

Do not use `underpair` if the visible cards actually resolve to:
- two pair
- trips / set
- straight or better

## Board-Pair Handling Rule

A paired board can change pair-family semantics.

Operational rule:
- if the board pairing upgrades a player beyond a simple single-pair description, stronger single-pair wording becomes invalid

Examples of invalid simplification:
- saying `top pair` when the visible cards actually make `two pair`
- saying `stronger pair` when kicker logic or board structure does not justify that phrase

## Two Pair Rule

`two pair` is allowed only when the visible cards actually produce two pair for the relevant player.

Disallowed:
- comparison copy that says `straight beats two pair` if no visible player actually has two pair
- actor copy that says `hero has two pair` or `villain has two pair` when the cards do not justify it

## Trips vs Set Rule

Use this distinction:
- `set`
  - pocket pair plus one matching board card
- `trips`
  - one hole card plus a paired board

If the current source does not need to distinguish them, weaker wording such as `trips` should still not contradict the actual visible category.

Operational rule:
- do not call a hand a `set` unless the pocket-pair condition is true
- do not collapse a clear `two pair` or `full house` style truth into `trips`

## Straight Rule

`straight` is allowed only when the visible best five-card hand truly forms a straight.

This includes:
- player-specific straight wording
- board-straight wording

Disallowed:
- saying `villain makes a straight` when the visible cards do not produce one
- saying `the board already makes the best straight for both players` when the board does not in fact do that

## Flush Rule

`flush` is allowed only when the visible best five-card hand truly forms a flush.

This SSOT establishes the naming rule now even if the current bounded validator family has not yet expanded into full flush-copy coverage.

Disallowed:
- any explicit `flush` claim not supported by visible cards

## Showdown Winner Truth Rule

If visible cards resolve the showdown winner, copy must match one of:
- hero wins
- villain wins
- board plays / tie

Disallowed:
- expected-answer truth that contradicts visible showdown truth
- prompt/feedback/why text that assigns the win to the wrong side
- actor praise/correction language that implies the wrong winner

## Board-Plays / Tie / Shared-Best-Hand Rule

When the board supplies the best hand for both players, copy must be explicit.

Allowed phrases include:
- `board plays`
- `both players tie`
- `shared best hand`
- `best hand for both players`
- equivalent bounded wording that clearly states the result is shared

Disallowed:
- ambiguous winner language when the board plays
- silence that implies one player wins when the best hand is shared
- vague wording that hides split-pot truth behind generic showdown phrasing

## Copy Strength Rule

The stronger the wording, the stronger the visible-card justification required.

Interpretation:
- generic wording may summarize
- strong categorical wording must be exact

Examples:
- `pair` is weaker than `top pair`
- `made hand` is weaker than `straight`
- `wins` is weaker than `wins with the stronger pair`

Operational rule:
- do not use a stronger phrase if the visible cards only justify a weaker one

## Kicker-Sensitive Boundary Rule

When wording depends on kicker-sensitive comparison, copy must stay within what the cards justify.

Allowed:
- exact winner wording if the cards resolve the winner
- exact pair-rank naming if the rank is correct

Disallowed:
- `stronger pair` unless the visible cards actually support that phrase
- pair-rank naming that points to the wrong rank

This SSOT does not yet require a full kicker pedagogy system.
It only requires that explicit kicker-sensitive copy not contradict visible truth.

## Source-vs-Copy Rule

Source owns truth.
Copy must respect that truth.

Operational rule:
- `prompt`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`
- `recap_v1`

must not contradict the visible-card truth available in source.

Runner or feedback logic must not rescue bad semantic wording by guessing what the author meant.

## “Too Strong To Allow” Rule

The following kinds of wording are too strong to allow unless the cards really justify them:
- exact made-hand claims
- exact winner claims
- exact pair-family claims
- board-plays / tie claims
- pair-rank claims
- `stronger pair` claims

If the source cannot justify the stronger phrase, use weaker wording or revise the source.

## Strategic Use Rule

Before adding a new validator slice or new visible-showdown copy family, ask:

1. Which semantic category is being claimed?
2. Do the visible cards actually justify that category?
3. Is the wording stronger than the cards support?
4. Is board-plays / tie truth being stated clearly enough?
5. Would a deterministic validator be able to check this without guessing intent?

If those answers are unclear, the wording is not yet canonical enough for safe scaling.

## Relationship To Current World 2 Truth Work

This SSOT sits underneath the current bounded World 2 visible-showdown validator work.

It gives one canonical semantic reference for:
- hand-category naming
- showdown winner truth
- board-plays/tie wording
- source-versus-copy boundaries

It does not itself expand validator coverage.
It only defines the truth layer that later validator/content work should follow.

## Out Of Scope

This SSOT does not yet define:
- full all-world hand taxonomy
- every future tie subtype
- full house / quads / straight flush teaching rules
- betting strategy terminology
- solver/exploit semantics
- pot-odds/equity wording
- a full poker handbook

Those belong to later bounded expansions if and when the authored corpus requires them.
