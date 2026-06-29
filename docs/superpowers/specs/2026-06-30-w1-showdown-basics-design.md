# W1 Showdown Basics Source/Authorship Repair Design

## Decision

Select Path B: add a tiny W1-owned source slice and generate one bounded
canonical `showdown_basics` fixture from it.

Path A is unavailable because current W1 source has no hand-ranking, showdown,
best-5-of-7, or kicker tasks. Path C is unnecessary because the missing
beginner foundation can be added safely without broadening into strategy.

## Source Ownership

Create a non-routed source slice under
`content/worlds/world1/v1/source_repairs/showdown_basics_v1/`. The source is
new W1 authorship and must not copy W2 task IDs, source metadata, or bridge
status. W2 showdown material remains reference-only evidence that the ownership
gap is real.

Update W1 world source truth so `Poker from Zero` honestly owns beginner
showdown comparison without adding an unsupported runtime session.

## Learning Slice

The source and fixture contain exactly six tasks in one concept family and one
same-signal group:

1. straight outranks two pair;
2. flush outranks straight;
3. select the best five cards from seven available cards;
4. identify a simple showdown winner from visible cards;
5. use a kicker only when the main hand rank ties;
6. recognize a tie when the board supplies the same best five cards.

Transfer surfaces:

- `hand_rank_order_v1`;
- `best_five_selection_v1`;
- `showdown_winner_v1`;
- `kicker_tiebreak_v1`;
- `board_plays_tie_v1`.

The shared repair focus is `best_five_before_showdown_winner`.

## Fixture And Factory

Generate
`test/fixtures/content_factory_mvp/w1_showdown_basics_source_authorship_repair_v1.json`
through `tools/content_factory_import_export_mvp_v1.dart`.

Every task uses W1-owned migration metadata, `source_truth_status=migrated`,
`safe_claim_status=canonical_pilot`, and `launch_coverage_claimed=false`.
Add the fixture to `w1ContentFactoryCoverageFixturePathsV1`; W1 aggregate
coverage becomes seven fixtures and 42 countable tasks.

## Claim Safety

This proves only beginner showdown basics. It does not prove all hand-comparison
edge cases, full poker mastery, Human QA readiness, 9.0, launch readiness, or
strategy competence. It adds no ranges, equity math, odds, stack/tournament
content, exploit material, or solver language.

## Testing

Use TDD:

1. add tests that fail because the fixture/exporter/source do not exist;
2. add the minimal source and exporter implementation;
3. regenerate the fixture and make focused tests pass;
4. run W1 foundation and L2/L3 validators;
5. run factory import/export, Flutter analyze, graphify, and repository hygiene
   checks.

## Score And Route Impact

W1 remains technical 8.5. If all evidence passes, W1-W12 readiness may move
from 8.1 to 8.2. Overall top-1 remains 6.6. Runtime routes and W7-W12 remain
unchanged. The next wave is W1-W6 Outcome Repair Verification / Local Cleanup,
not Human QA execution or route expansion.
