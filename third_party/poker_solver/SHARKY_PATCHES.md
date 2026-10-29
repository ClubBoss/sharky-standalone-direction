# poker_solver: vendored copy with one Sharky patch

## Provenance

- Upstream package: `poker_solver` 1.0.0 on pub.dev
  (<https://pub.dev/packages/poker_solver>, source
  <https://github.com/rhymelph/poker_solver>), a Dart port of
  goldfire/pokersolver.
- Archive hash recorded in Sharky's `pubspec.lock` before vendoring:
  `bbcd38c3686ca9ede5f3b77bf6754950fae7e75000068ad9956e4dc6cb74dfb4`
  (matches the local pub cache `hosted-hashes` entry).
- Upstream `lib/game.dart` SHA-256 before the patch:
  `bd382415329a6da9a5305dc71b9f330c21f79f7ed00517e98c0e8ddc5af83bb2`.
- Files copied unchanged apart from the patch below: `lib/**`, `LICENSE`,
  `README.md`, `CHANGELOG.md`, `pubspec.yaml` (version marker only).
  The upstream `example/`, `test/` and `analysis_options.yaml` were not copied.
- License: Apache License 2.0 (`LICENSE`, unchanged). Copyright 2024 rhymelph.

## Modifications (Apache-2.0 §4(b) notice)

1. `lib/game.dart`, `gameRules['standard']['handValues']`: reordered to
   `StraightFlush, FourOfAKind, FullHouse, Flush, Straight, ThreeOfAKind,
   TwoPair, OnePair, HighCard`.
   Upstream 1.0.0 shipped `StraightFlush, Flush, Straight, FullHouse,
   FourOfAKind, …`. `Hand` derives both the category it reports
   (`solveHand` takes the first possible class in this list) and its
   comparison rank (`rank = handValues.length - index`) from this list, so a
   straight beat a full house and quads, and a 7-card hand holding quads plus
   trips was reported as a full house. The corrected order is the standard
   Texas Hold'em ranking and the order used by goldfire/pokersolver.
2. `pubspec.yaml`: version `1.0.0` -> `1.0.0+sharky.1` so the vendored copy is
   distinguishable from the hosted package.

No other game rule set (`jacksbetter`, `paigow*`, wild-card games) and no
`Hand`/`Card` API was changed. Duplicate cards still throw from the `Hand`
constructor for the `standard` game, as upstream.

## Proof

`test/poker/poker_solver_standard_ranking_v1_test.dart` holds independent
rule fixtures. The expectations come from the published hand rankings, not
from this library. The test fails against upstream 1.0.0 and passes against
this copy.

## Removing this copy

Switch `pubspec.yaml` back to a hosted `poker_solver` version once upstream
publishes a release whose `standard` order matches item 1 and whose fixtures
pass `test/poker/poker_solver_standard_ranking_v1_test.dart`.
