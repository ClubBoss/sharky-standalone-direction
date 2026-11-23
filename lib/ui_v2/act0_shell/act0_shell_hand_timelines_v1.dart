part of 'act0_shell_state_v1.dart';

extension on Act0TableStateV1 {
  Act0TableStateV1 _withB20TurnTimeline() => _withTimeline(const {
    PokerStreet.preflop: [
      ('sb', Act0HandVerbV1.smallBlind, 50),
      ('bb', Act0HandVerbV1.bigBlind, 100),
      ('utg', Act0HandVerbV1.fold, 0),
      ('hj', Act0HandVerbV1.fold, 0),
      ('co', Act0HandVerbV1.raise, 250),
      ('btn', Act0HandVerbV1.fold, 0),
      ('sb', Act0HandVerbV1.call, 200),
      ('bb', Act0HandVerbV1.fold, 0),
    ],
    PokerStreet.flop: [
      ('sb', Act0HandVerbV1.check, 0),
      ('co', Act0HandVerbV1.bet, 200),
      ('sb', Act0HandVerbV1.call, 200),
    ],
    PokerStreet.turn: [
      ('sb', Act0HandVerbV1.check, 0),
      ('co', Act0HandVerbV1.bet, 800),
    ],
  });

  Act0TableStateV1 _withB20RiverTimeline() => _withTimeline(const {
    PokerStreet.preflop: [
      ('sb', Act0HandVerbV1.smallBlind, 50),
      ('bb', Act0HandVerbV1.bigBlind, 100),
      ('utg', Act0HandVerbV1.fold, 0),
      ('hj', Act0HandVerbV1.fold, 0),
      ('co', Act0HandVerbV1.fold, 0),
      ('btn', Act0HandVerbV1.raise, 200),
      ('sb', Act0HandVerbV1.call, 150),
      ('bb', Act0HandVerbV1.fold, 0),
    ],
    PokerStreet.flop: [
      ('sb', Act0HandVerbV1.check, 0),
      ('btn', Act0HandVerbV1.bet, 250),
      ('sb', Act0HandVerbV1.call, 250),
    ],
    PokerStreet.turn: [
      ('sb', Act0HandVerbV1.check, 0),
      ('btn', Act0HandVerbV1.bet, 200),
      ('sb', Act0HandVerbV1.call, 200),
    ],
  });

  // The drill supplies the turn exchange. Earlier streets retain their
  // board cards but have no certified betting sequence in this slice.
  Act0TableStateV1 _withB20Day7Timeline() => _withTimeline(const {
    PokerStreet.turn: [
      ('bb', Act0HandVerbV1.check, 0),
      ('co', Act0HandVerbV1.bet, 300),
      ('bb', Act0HandVerbV1.raise, 1000),
    ],
  }, coverage: Act0HandHistoryCoverageV1.partialDrill);

  Act0TableStateV1 _withTimeline(
    Map<PokerStreet, List<(String, Act0HandVerbV1, int)>> byStreet, {
    Act0HandHistoryCoverageV1 coverage = Act0HandHistoryCoverageV1.complete,
  }) => copyWith(
    handTimelinePrefix: Act0HandTimelineV1.fromDeltas(
      coverage: coverage,
      startingStacks: {
        for (final label in canonicalSeatOrder)
          label.toLowerCase():
              (handContributions!.startingStackBbBySeat[label.toLowerCase()]! *
                      100)
                  .round(),
      },
      heroSeat: heroSeatId ?? heroSeat.seatId,
      button: seats.singleWhere((seat) => seat.isDealerButton).seatId,
      smallBlind: 50,
      bigBlind: 100,
      board: [for (final card in boardCards) '${card.rank}${card.suit}'],
      actions: [
        for (final entry in byStreet.entries)
          for (final (seat, verb, chipsAdded) in entry.value)
            (street: entry.key, seat: seat, verb: verb, chipsAdded: chipsAdded),
      ],
    ).beforeDecision,
  );
}
