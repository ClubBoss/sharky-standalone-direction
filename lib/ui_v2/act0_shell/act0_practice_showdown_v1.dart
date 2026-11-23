import 'package:poker_solver/poker_solver.dart';

typedef Act0ShowdownSampleV1 = ({double share, int wins, int outcomes});

final act0PracticeDeckV1 = List<String>.unmodifiable([
  for (final rank in 'AKQJT98765432'.split(''))
    for (final suit in 'shdc'.split('')) '$rank$suit',
]);

Iterable<List<String>> _runouts(List<String> deck, int needed) sync* {
  if (needed == 0) {
    yield const [];
  } else if (needed == 1) {
    for (final card in deck) {
      yield [card];
    }
  } else {
    for (var i = 0; i < deck.length; i++) {
      for (var j = i + 1; j < deck.length; j++) {
        yield [deck[i], deck[j]];
      }
    }
  }
}

Act0ShowdownSampleV1 act0PracticeShowdownV1(
  List<String> hero,
  List<String> board,
  List<String> opponents,
) {
  final villains = opponents.map((hand) => hand.split(' ')).toList();
  final seen = {...hero, ...board, ...villains.expand((hand) => hand)};
  final remaining = act0PracticeDeckV1
      .where((card) => !seen.contains(card))
      .toList();
  var wins = 0;
  var outcomes = 0;
  var potShares = 0.0;
  for (final runout in _runouts(remaining, 5 - board.length)) {
    final complete = [...board, ...runout];
    final heroHand = Hand.solveHand([...hero, ...complete]);
    final comparisons = [
      for (final villain in villains)
        heroHand.compare(Hand.solveHand([...villain, ...complete])),
    ];
    outcomes++;
    if (comparisons.any((result) => result > 0)) continue;
    final tied = comparisons.where((result) => result == 0).length;
    if (tied == 0) wins++;
    potShares += 1 / (1 + tied);
  }
  return (share: potShares / outcomes, wins: wins, outcomes: outcomes);
}

double act0PracticeBetPayoffV1({
  required double equity,
  required double pot,
  required double bet,
  required bool folds,
}) => folds ? pot : equity * (pot + 2 * bet) - bet;
