import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_hand_betting_ledger_v1.dart';
import 'act0_hand_contributions_v1.dart';

export 'act0_hand_betting_ledger_v1.dart' show Act0HandVerbV1;

typedef Act0HandDeltaV1 = ({
  PokerStreet street,
  String seat,
  Act0HandVerbV1 verb,
  int chipsAdded,
});

enum Act0HandHistoryCoverageV1 { complete, partialDrill, missing }

sealed class Act0HandEventV1 {
  const Act0HandEventV1(this.street);
  final PokerStreet street;
}

/// The newly dealt cards, in order. The flop is one three-card event.
final class Act0HandDealV1 extends Act0HandEventV1 {
  Act0HandDealV1(super.street, Iterable<String> cards)
    : cards = List.unmodifiable(cards);
  final List<String> cards;
}

final class Act0HandActionV1 extends Act0HandEventV1 {
  const Act0HandActionV1(
    super.street,
    this.seat,
    this.verb,
    this.chipsAdded, {
    required this.streetTotal,
    this.allIn = false,
  });

  final String seat;
  final Act0HandVerbV1 verb;

  /// Signed integer units. A return removes chips from the pot.
  final int chipsAdded;
  final int streetTotal;
  final bool allIn;
}

/// Shared source for an imported or authored timeline. The boundary counts
/// events (including deals). No public accessor returns events beyond it.
class Act0HandTimelineV1 {
  Act0HandTimelineV1({
    required Act0HandHistoryCoverageV1 coverage,
    required Map<String, int> startingStacks,
    required String button,
    required int smallBlind,
    required int bigBlind,
    required List<Act0HandEventV1> events,
    required int decisionIndex,
    String? heroSeat,
  }) : beforeDecision = Act0HandTimelinePrefixV1._(
         coverage,
         startingStacks,
         button,
         smallBlind,
         bigBlind,
         events.sublist(0, decisionIndex),
         heroSeat,
       );

  /// Normalize source contributions and insert a marker for each dealt street.
  factory Act0HandTimelineV1.fromDeltas({
    required Act0HandHistoryCoverageV1 coverage,
    required Map<String, int> startingStacks,
    required String button,
    required int smallBlind,
    required int bigBlind,
    required List<String> board,
    required List<Act0HandDeltaV1> actions,
    String? heroSeat,
  }) {
    final events = <Act0HandEventV1>[];
    final totals = <(PokerStreet, String), int>{};
    final paid = <String, int>{};
    const boardCounts = [0, 3, 4, 5];
    final finalStreet = boardCounts.indexOf(board.length);
    if (finalStreet < 0) throw const FormatException('Invalid board size');
    var streetIndex = 0;
    void dealThrough(int index) {
      if (index < streetIndex || index > finalStreet) {
        throw const FormatException('Action outside dealt streets');
      }
      while (streetIndex < index) {
        streetIndex++;
        events.add(
          Act0HandDealV1(
            PokerStreet.values[streetIndex],
            board.sublist(
              boardCounts[streetIndex - 1],
              boardCounts[streetIndex],
            ),
          ),
        );
      }
    }

    for (final (:street, :seat, :verb, :chipsAdded) in actions) {
      dealThrough(street.index);
      final key = (street, seat);
      final total =
          (totals[key] ?? 0) + (verb == Act0HandVerbV1.ante ? 0 : chipsAdded);
      totals[key] = total;
      paid[seat] = (paid[seat] ?? 0) + chipsAdded;
      events.add(
        Act0HandActionV1(
          street,
          seat,
          verb,
          chipsAdded,
          streetTotal: total,
          allIn:
              coverage == Act0HandHistoryCoverageV1.complete &&
              chipsAdded > 0 &&
              paid[seat] == startingStacks[seat],
        ),
      );
    }
    dealThrough(finalStreet);
    return Act0HandTimelineV1(
      coverage: coverage,
      startingStacks: startingStacks,
      button: button,
      smallBlind: smallBlind,
      bigBlind: bigBlind,
      events: events,
      decisionIndex: events.length,
      heroSeat: heroSeat,
    );
  }

  final Act0HandTimelinePrefixV1 beforeDecision;
}

/// An immutable projection, suitable for saving with the submitted attempt.
class Act0HandTimelinePrefixV1 {
  Act0HandTimelinePrefixV1._(
    this.coverage,
    Map<String, int> stacks,
    this.button,
    this.smallBlind,
    this.bigBlind,
    List<Act0HandEventV1> events,
    String? heroSeat,
  ) : heroSeat = stacks.containsKey(heroSeat) ? heroSeat : null,
      startingStacks = Map.unmodifiable(stacks),
      events = List.unmodifiable(events) {
    if (_structureError() case final error?) throw FormatException(error);
  }

  final Act0HandHistoryCoverageV1 coverage;

  /// In clockwise seat order, starting at any occupied seat.
  final Map<String, int> startingStacks;
  final String button;
  final String? heroSeat;
  final int smallBlind, bigBlind;
  final List<Act0HandEventV1> events;

  List<Act0HandEventV1> eventsOn(PokerStreet street) =>
      List.unmodifiable(events.where((event) => event.street == street));

  List<String> get board => List.unmodifiable(
    events.whereType<Act0HandDealV1>().expand((deal) => deal.cards),
  );

  PokerStreet get street => events.lastOrNull?.street ?? PokerStreet.preflop;

  Act0HandContributionsV1 get contributions => contributionsThrough(street);

  Act0HandContributionsV1 contributionsThrough(PokerStreet endStreet) {
    if (coverage != Act0HandHistoryCoverageV1.complete) {
      throw StateError('History has gaps. A full-hand pot cannot be derived.');
    }
    if (endStreet.index > street.index) {
      throw ArgumentError.value(
        endStreet,
        'endStreet',
        'Outside visible history',
      );
    }
    return Act0HandContributionsV1(
      throughStreet: endStreet,
      startingStackBbBySeat: {
        for (final entry in startingStacks.entries)
          entry.key: entry.value / bigBlind,
      },
      entries: [
        for (final action in events.whereType<Act0HandActionV1>())
          if (action.street.index <= endStreet.index && action.chipsAdded != 0)
            act0TimelineContributionV1(
              action.street,
              action.seat,
              action.verb,
              action.chipsAdded.abs() / bigBlind,
            ),
      ],
    );
  }

  String? _structureError() {
    if (smallBlind <= 0 ||
        bigBlind <= smallBlind ||
        startingStacks.length < 2 ||
        startingStacks.length > 9 ||
        !startingStacks.containsKey(button) ||
        startingStacks.entries.any(
          (row) => row.key.isEmpty || row.value <= 0,
        ) ||
        coverage == Act0HandHistoryCoverageV1.missing ||
        events.length > 154) {
      return 'Invalid timeline metadata';
    }
    final knownCards = <String>{};
    final cardPattern = RegExp(r'^[2-9TJQKA][cdhs]$');
    final totals = <(PokerStreet, String), int>{};
    final invested = <String, int>{};
    var current = PokerStreet.preflop;
    for (final event in events) {
      switch (event) {
        case Act0HandDealV1(:final street, :final cards):
          if (street.index != current.index + 1 ||
              cards.length != (street == PokerStreet.flop ? 3 : 1) ||
              cards.any(
                (card) => !cardPattern.hasMatch(card) || !knownCards.add(card),
              )) {
            return 'Invalid deal marker';
          }
          current = street;
        case Act0HandActionV1(
          :final seat,
          :final verb,
          :final chipsAdded,
          :final streetTotal,
          :final allIn,
        ):
          final stack = startingStacks[seat];
          if (event.street != current || stack == null)
            return 'Unknown seat or street';
          final key = (current, seat);
          final total =
              (totals[key] ?? 0) +
              (verb == Act0HandVerbV1.ante ? 0 : chipsAdded);
          final paid = (invested[seat] ?? 0) + chipsAdded;
          final validAmount = switch (verb) {
            Act0HandVerbV1.fold || Act0HandVerbV1.check => chipsAdded == 0,
            Act0HandVerbV1.uncalledReturn => chipsAdded < 0,
            _ => chipsAdded > 0,
          };
          if (!validAmount ||
              total < 0 ||
              streetTotal != total ||
              paid < 0 ||
              paid > stack ||
              (chipsAdded > 0 &&
                  coverage == Act0HandHistoryCoverageV1.complete &&
                  allIn != (paid == stack)) ||
              (allIn && chipsAdded <= 0)) {
            return 'Invalid contribution, street total or all-in flag for $seat';
          }
          totals[key] = total;
          invested[seat] = paid;
      }
    }
    return null;
  }

  /// Complete coverage establishes legality all the way to the next actor.
  String? decisionError(String actor) {
    if (coverage != Act0HandHistoryCoverageV1.complete) return null;
    final seatNumbers = {
      for (final (index, seat) in startingStacks.keys.indexed) seat: index + 1,
    };
    final ledger = Act0HandBettingLedgerV1(
      [
        for (final entry in startingStacks.entries)
          (number: seatNumbers[entry.key]!, stackCents: entry.value),
      ],
      startingStacks.length,
      seatNumbers[button]!,
      smallBlind,
      bigBlind,
      allowShortRaises: true,
    );
    for (final (index, event) in events.indexed) {
      final legal = switch (event) {
        Act0HandDealV1() => ledger.advance(),
        Act0HandActionV1(:final seat, :final verb, :final chipsAdded) =>
          ledger.add((
            street: event.street,
            seat: seatNumbers[seat]!,
            kind: verb,
            cents: chipsAdded.abs(),
          )),
      };
      if (!legal) return 'Illegal action or deal at event ${index + 1}';
    }
    if (ledger.nextActor == null || ledger.nextActor != seatNumbers[actor]) {
      return 'Incorrect decision actor';
    }
    return null;
  }

  Map<String, Object?> toPayload() => {
    'version': 1,
    'coverage': coverage.name,
    'stacks': [
      for (final row in startingStacks.entries) [row.key, row.value],
    ],
    'button': button,
    if (heroSeat != null) 'heroSeat': heroSeat,
    'blinds': [smallBlind, bigBlind],
    'events': [
      for (final event in events)
        switch (event) {
          Act0HandDealV1(:final cards) => [event.street.name, cards],
          Act0HandActionV1(
            :final seat,
            :final verb,
            :final chipsAdded,
            :final streetTotal,
            :final allIn,
          ) =>
            [
              event.street.name,
              seat,
              verb.name,
              chipsAdded,
              streetTotal,
              allIn,
            ],
        },
    ],
  };

  static Act0HandTimelinePrefixV1? tryParse(Object? raw) {
    if (raw case {
      'version': 1,
      'coverage': final String name,
      'stacks': final List stacks,
      'button': final String button,
      'blinds': [final int smallBlind, final int bigBlind],
      'events': final List rows,
    }) {
      final coverage = Act0HandHistoryCoverageV1.values
          .where((value) => value.name == name)
          .firstOrNull;
      if (coverage == null || stacks.length > 9 || rows.length > 154)
        return null;
      final startingStacks = <String, int>{};
      for (final row in stacks) {
        if (row case [
          final String seat,
          final int chips,
        ] when !startingStacks.containsKey(seat)) {
          startingStacks[seat] = chips;
        } else {
          return null;
        }
      }
      final events = <Act0HandEventV1>[];
      for (final row in rows) {
        if (row is! List || row.isEmpty) return null;
        final street = PokerStreet.values
            .where((value) => value.name == row.first)
            .firstOrNull;
        if (street == null) return null;
        switch (row) {
          case [_, final List cards] when cards.every((card) => card is String):
            events.add(Act0HandDealV1(street, cards.cast<String>()));
          case [
            _,
            final String seat,
            final String verbName,
            final int delta,
            final int total,
            final bool allIn,
          ]:
            final verb = Act0HandVerbV1.values
                .where((value) => value.name == verbName)
                .firstOrNull;
            if (verb == null) return null;
            events.add(
              Act0HandActionV1(
                street,
                seat,
                verb,
                delta,
                streetTotal: total,
                allIn: allIn,
              ),
            );
          default:
            return null;
        }
      }
      try {
        return Act0HandTimelinePrefixV1._(
          coverage,
          startingStacks,
          button,
          smallBlind,
          bigBlind,
          events,
          switch (raw['heroSeat']) {
            String seat => seat,
            _ => null,
          },
        );
      } on FormatException {
        return null;
      }
    }
    return null;
  }
}

Act0ContributionV1 act0TimelineContributionV1(
  PokerStreet street,
  String seat,
  Act0HandVerbV1 verb,
  double amountBb,
) => Act0ContributionV1(street, seat, switch (verb) {
  Act0HandVerbV1.smallBlind ||
  Act0HandVerbV1.bigBlind => Act0ContributionKindV1.blind,
  Act0HandVerbV1.ante => Act0ContributionKindV1.ante,
  Act0HandVerbV1.uncalledReturn => Act0ContributionKindV1.uncalledReturn,
  _ => Act0ContributionKindV1.wager,
}, amountBb);
