import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_hand_timeline_v1.dart';

typedef Act0StreetSummaryActionV1 = ({
  String seat,
  Act0HandVerbV1 verb,
  double amountBb,
  bool allIn,
});

typedef Act0StreetSummaryRowV1 = ({
  PokerStreet name,
  List<String> boardOnStreet,
  List<Act0StreetSummaryActionV1> actions,
  double? potAfterBb,
});

typedef Act0PausedStreetFrameV1 = ({
  Map<String, double>? stacksBb,
  double? potBb,
  List<String> board,
  Set<String>? foldedSeats,
});

/// Read-only projection of the B20 visibility boundary. A task or saved
/// attempt stops before the decision street, even if it contains its opening
/// actions. A completed own hand can also expose its last recorded frame.
class Act0StreetSummaryV1 {
  Act0StreetSummaryV1(
    this._prefix, {
    String? heroSeat,
    PokerStreet? decisionStreet,
    bool completedHand = false,
  }) : heroSeat = _prefix?.heroSeat ?? heroSeat,
       decisionStreet = _prefix?.street ?? decisionStreet {
    final prefix = _prefix;
    if (prefix == null) return;

    final complete = coverage == Act0HandHistoryCoverageV1.complete;
    final stacks = Map<String, int>.of(prefix.startingStacks);
    final folded = <String>{};
    final board = <String>[];
    final rows = <Act0StreetSummaryRowV1>[];
    for (final street in PokerStreet.values.take(
      prefix.street.index + (completedHand ? 1 : 0),
    )) {
      final actions = <Act0StreetSummaryActionV1>[];
      for (final event in prefix.eventsOn(street)) {
        switch (event) {
          case Act0HandDealV1(:final cards):
            board.addAll(cards);
          case Act0HandActionV1(
            :final seat,
            :final verb,
            :final chipsAdded,
            :final allIn,
          ):
            stacks[seat] = stacks[seat]! - chipsAdded;
            if (verb == Act0HandVerbV1.fold) folded.add(seat);
            actions.add((
              seat: seat,
              verb: verb,
              amountBb: chipsAdded / prefix.bigBlind,
              allIn: allIn,
            ));
        }
      }
      final visibleBoard = List<String>.unmodifiable(board);
      final pot = complete
          ? prefix
                .contributionsThrough(street)
                .amounts(seatIds: stacks.keys.toSet())
                .potBb
          : null;
      _frames[street] = (
        stacksBb: complete
            ? Map.unmodifiable(
                stacks.map(
                  (seat, chips) => MapEntry(seat, chips / prefix.bigBlind),
                ),
              )
            : null,
        potBb: pot,
        board: visibleBoard,
        foldedSeats: complete ? Set.unmodifiable(folded) : null,
      );
      if (prefix.street != PokerStreet.preflop) {
        rows.add((
          name: street,
          boardOnStreet: visibleBoard,
          actions: List.unmodifiable(actions),
          potAfterBb: pot,
        ));
      }
    }
    _streets = List.unmodifiable(rows);
  }

  final Act0HandTimelinePrefixV1? _prefix;
  final String? heroSeat;
  final PokerStreet? decisionStreet;

  Act0HandHistoryCoverageV1 get coverage =>
      _prefix?.coverage ?? Act0HandHistoryCoverageV1.missing;

  List<Act0StreetSummaryRowV1> _streets = const [];
  List<Act0StreetSummaryRowV1> get streets => _streets;
  final _frames = <PokerStreet, Act0PausedStreetFrameV1>{};

  /// End-of-street frame, before payouts. Partial coverage exposes the board
  /// but cannot certify the pot, remaining stacks or the full set of folds.
  Act0PausedStreetFrameV1? frameAt(PokerStreet street) => _frames[street];

  /// The in-progress decision can have a different pot from the last row.
  ({double potBb, double? toCallBb})? amountsAtDecision({String? actorSeat}) {
    final prefix = _prefix;
    if (prefix == null || coverage != Act0HandHistoryCoverageV1.complete) {
      return null;
    }
    return prefix.contributions.amounts(
      seatIds: prefix.startingStacks.keys.toSet(),
      actorSeatId: actorSeat,
    );
  }
}

/// A read-only replay of only the authored decision prefix. No attempt,
/// answer, future street or inferred action is used to build this journal.
class Act0TaskStreetReplayV1 {
  Act0TaskStreetReplayV1(Act0HandTimelinePrefixV1? source, this.decisionStreet)
    : prefix = source?.takeEvents(
        source.events
            .takeWhile((event) => event.street.index <= decisionStreet.index)
            .length,
      );

  Act0StreetSummaryV1 get summary =>
      Act0StreetSummaryV1(prefix, decisionStreet: decisionStreet);

  final Act0HandTimelinePrefixV1? prefix;
  final PokerStreet decisionStreet;

  Iterable<Act0HandEventV1> get _events =>
      (prefix?.events ?? const <Act0HandEventV1>[]).takeWhile(
        (event) => event.street.index <= decisionStreet.index,
      );

  List<String> get labels => [
    for (final event in _events)
      switch (event) {
        Act0HandDealV1(:final street, :final cards) =>
          '${pokerStreetToString(street)}: ${cards.join(' ')}',
        Act0HandActionV1(
          :final street,
          :final seat,
          :final verb,
          :final chipsAdded,
        ) =>
          '${pokerStreetToString(street)}: $seat · ${verb.name}'
              '${chipsAdded == 0 ? '' : ' ${chipsAdded / prefix!.bigBlind} BB'}',
      },
  ];

  Map<String, int> get streetPositions => {
    'Preflop': 0,
    for (final (index, event) in _events.indexed)
      if (event is Act0HandDealV1) pokerStreetToString(event.street): index + 1,
  };

  List<String> boardAt(int position) => [
    for (final event in _events.take(position))
      if (event is Act0HandDealV1) ...event.cards,
  ];
}
