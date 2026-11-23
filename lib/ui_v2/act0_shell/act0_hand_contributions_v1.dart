import 'package:poker_analyzer/models/poker_street.dart';

enum Act0ContributionKindV1 { blind, ante, wager, uncalledReturn }

/// An amount added or returned at this action, in BB. Raise-to totals must be
/// converted to the additional contribution before they enter the ledger.
class Act0ContributionV1 {
  const Act0ContributionV1(this.street, this.seatId, this.kind, this.amountBb);

  final PokerStreet street;
  final String seatId;
  final Act0ContributionKindV1 kind;
  final double amountBb;

  double get netAmountBb =>
      kind == Act0ContributionKindV1.uncalledReturn ? -amountBb : amountBb;
}

/// Source-owned contributions through one decision frame. Betting-street
/// evidence can establish a call price even when earlier contributions are
/// missing. Stack amounts refer to the beginning of the recorded interval.
class Act0HandContributionsV1 {
  const Act0HandContributionsV1({
    required this.throughStreet,
    required this.entries,
    this.fromStreet = PokerStreet.preflop,
    this.startingStackBbBySeat = const {},
    this.minimumStartingStackBbBySeat = const {},
  });

  final PokerStreet fromStreet;
  final PokerStreet throughStreet;
  final List<Act0ContributionV1> entries;
  final Map<String, double> startingStackBbBySeat;
  final Map<String, double> minimumStartingStackBbBySeat;

  List<({double amountBb, Set<String> eligibleSeatIds})>? contestablePots({
    required Set<String> activeSeatIds,
  }) {
    if (fromStreet != PokerStreet.preflop) return null;
    final committed = <String, double>{};
    var antes = 0.0;
    for (final entry in entries) {
      if (entry.kind == Act0ContributionKindV1.ante) {
        antes += entry.amountBb;
        continue;
      }
      committed[entry.seatId] =
          (committed[entry.seatId] ?? 0) + entry.netAmountBb;
    }
    final pots = act0ContestablePotsV1(
      committed,
      liveSeats: activeSeatIds,
      deadChips: antes,
    );
    if (pots == null) return null;
    return [
      for (final pot in pots)
        (amountBb: pot.amount.toDouble(), eligibleSeatIds: pot.eligibleSeats),
    ];
  }

  ({double potBb, double? toCallBb}) amounts({
    required Set<String> seatIds,
    String? actorSeatId,
  }) {
    const tolerance = 1e-9;
    if (fromStreet.index > throughStreet.index) {
      throw const FormatException('Invalid contribution ledger street range');
    }
    final budgets = [
      ...startingStackBbBySeat.entries,
      ...minimumStartingStackBbBySeat.entries,
    ];
    if (budgets.any(
      (entry) =>
          !seatIds.contains(entry.key) ||
          !entry.value.isFinite ||
          entry.value < 0,
    )) {
      throw const FormatException(
        'Invalid starting stack in contribution ledger',
      );
    }

    final addedBySeat = <String, double>{};
    final streetWagers = <String, double>{};
    var currentStreet = fromStreet;
    var pot = 0.0;
    for (final entry in entries) {
      final amount = entry.amountBb;
      if (!seatIds.contains(entry.seatId) ||
          !amount.isFinite ||
          amount <= 0 ||
          entry.street.index < currentStreet.index ||
          entry.street.index > throughStreet.index) {
        throw const FormatException(
          'Invalid seat, chips or street in contribution ledger',
        );
      }
      if (entry.street != currentStreet) {
        currentStreet = entry.street;
        streetWagers.clear();
      }
      if ((entry.kind == Act0ContributionKindV1.ante ||
              entry.kind == Act0ContributionKindV1.blind) &&
          currentStreet != PokerStreet.preflop) {
        throw const FormatException('Forced posts must be recorded preflop');
      }

      final delta = entry.netAmountBb;
      if (entry.kind != Act0ContributionKindV1.ante) {
        final wager = (streetWagers[entry.seatId] ?? 0.0) + delta;
        if (wager < -tolerance) {
          throw const FormatException(
            'Uncalled return exceeds live commitment',
          );
        }
        streetWagers[entry.seatId] = wager;
      }
      final invested = (addedBySeat[entry.seatId] ?? 0.0) + delta;
      final startingStack = startingStackBbBySeat[entry.seatId];
      if (startingStack != null && invested > startingStack + tolerance) {
        throw const FormatException('Contribution exceeds starting stack');
      }
      addedBySeat[entry.seatId] = invested;
      pot += delta;
    }

    if (actorSeatId == null || !seatIds.contains(actorSeatId)) {
      return (potBb: pot, toCallBb: null);
    }
    if (throughStreet != currentStreet) {
      return (potBb: pot, toCallBb: 0);
    }
    final highestWager = streetWagers.values.fold<double>(
      0,
      (highest, wager) => wager > highest ? wager : highest,
    );
    final due = highestWager - (streetWagers[actorSeatId] ?? 0.0);
    if (due <= tolerance) return (potBb: pot, toCallBb: 0);
    final invested = addedBySeat[actorSeatId] ?? 0.0;
    final stack = startingStackBbBySeat[actorSeatId];
    if (stack == null) {
      final floor = minimumStartingStackBbBySeat[actorSeatId];
      return (
        potBb: pot,
        toCallBb: floor != null && floor - invested + tolerance >= due
            ? due
            : null,
      );
    }
    final behind = stack - invested;
    return (
      potBb: pot,
      toCallBb: behind < due ? behind.clamp(0.0, due).toDouble() : due,
    );
  }
}

/// Splits net commitments into contestable pots. Folded chips stay in the
/// pot. A live player's unmatched excess is excluded until matched.
List<({num amount, Set<T> eligibleSeats})>? act0ContestablePotsV1<T>(
  Map<T, num> commitments, {
  required Set<T> liveSeats,
  num deadChips = 0,
}) {
  const tolerance = 1e-9;
  final levels = commitments.values.toSet().toList()..sort();
  final pots = <({num amount, Set<T> eligibleSeats})>[];
  num previous = 0;
  for (final level in levels) {
    if (level <= previous + tolerance) continue;
    final contributors = commitments.keys
        .where((seat) => commitments[seat]! >= level - tolerance)
        .toList();
    if (contributors.length == 1 && liveSeats.contains(contributors.single)) {
      break;
    }
    final eligible = contributors.where(liveSeats.contains).toSet();
    final amount =
        (level - previous) * contributors.length +
        (pots.isEmpty ? deadChips : 0);
    if (eligible.isEmpty && pots.isEmpty) return null;
    if (pots.isNotEmpty &&
        (eligible.isEmpty ||
            (pots.last.eligibleSeats.length == eligible.length &&
                pots.last.eligibleSeats.containsAll(eligible)))) {
      final prior = pots.removeLast();
      pots.add((
        amount: prior.amount + amount,
        eligibleSeats: prior.eligibleSeats,
      ));
    } else {
      pots.add((amount: amount, eligibleSeats: eligible));
    }
    previous = level;
  }
  return pots;
}
