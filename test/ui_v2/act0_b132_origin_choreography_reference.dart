// Frozen plan producer from origin/main 83a1a9cccfd4032908c6349d6294c870f70c3393.
// Test-only reference; do not update to match future parser changes.
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

Act0TableChoreographyPlanV1? originChoreographyPlanV1(
  Act0TableStateV1 table, {
  bool actorFocusSafe = true,
}) {
  if (!actorFocusSafe ||
      table.scope != Act0TableScopeV1.playedHand ||
      table.actionTrail.isEmpty ||
      act0BettingRoundOrderTruthForTableV1(table) ==
          Act0BettingRoundOrderTruthV1.contradiction) {
    return null;
  }

  final finalStreet = _streetFromLabelV1(table.streetLabel);
  if (finalStreet == null ||
      table.boardCards.length != finalStreet.boardCardCount ||
      table.boardCards.length > 5 ||
      table.boardCards.any((card) => !_isValidBoardCardV1(card))) {
    return null;
  }

  final heroSeats = table.seats.where((seat) => seat.isHero).toList();
  if (heroSeats.length != 1) {
    return null;
  }
  final heroSeat = heroSeats.single;
  final explicitHeroSeatId = table.heroSeatId?.trim();
  if (explicitHeroSeatId != null &&
      explicitHeroSeatId.isNotEmpty &&
      explicitHeroSeatId != heroSeat.seatId) {
    return null;
  }
  final heroSeatId = heroSeat.seatId;
  final activeSeatId = table.activeSeatId?.trim();
  if (heroSeat.isFolded ||
      activeSeatId == null ||
      activeSeatId.isEmpty ||
      activeSeatId != heroSeatId) {
    return null;
  }

  final seatByActor = <String, Act0SeatStateV1>{};
  for (final seat in table.seats) {
    final actor = seat.seatLabel.trim().toUpperCase();
    if (actor.isEmpty || seatByActor.containsKey(actor)) {
      return null;
    }
    seatByActor[actor] = seat;
  }

  final parsed = <_ParsedTrailItemV1>[];
  for (var index = 0; index < table.actionTrail.length; index++) {
    if (table.actionTrail[index].isNote) continue;
    final item = _parseTrailItemV1(
      table.actionTrail[index].label,
      sourceIndex: index,
      seatByActor: seatByActor,
      heroSeat: heroSeat,
    );
    if (item == null) {
      return null;
    }
    parsed.add(item);
  }
  if (parsed.isEmpty || !parsed.any((item) => item.street != null)) {
    return null;
  }

  final first = parsed.first;
  final firstStreet = first.street;
  final Act0TableChoreographyStreetV1 initialStreet;
  if (firstStreet != null) {
    initialStreet = firstStreet;
  } else if (first.action == _TrailActionV1.blind) {
    initialStreet = Act0TableChoreographyStreetV1.preflop;
  } else {
    return null;
  }

  if (initialStreet.index > finalStreet.index) {
    return null;
  }

  var currentStreet = initialStreet;
  final beats = <Act0TableChoreographyBeatV1>[];
  final transientCommitments = <String>{};
  var terminalSeen = false;
  final foldedActors = <String>{};
  String? previousVoluntaryActor;

  for (final item in parsed) {
    if (terminalSeen) {
      return null;
    }

    final nextStreet = item.street;
    if (nextStreet != null && nextStreet != currentStreet) {
      if (nextStreet.index != currentStreet.index + 1) {
        return null;
      }
      if (transientCommitments.isNotEmpty) {
        beats.add(
          Act0TableChoreographyBeatV1(
            kind: Act0TableChoreographyBeatKindV1.commitmentsCollect,
            street: currentStreet,
            sourceIndex: item.sourceIndex,
          ),
        );
        transientCommitments.clear();
      }
      currentStreet = nextStreet;
      previousVoluntaryActor = null;
      final revealKind = switch (currentStreet) {
        Act0TableChoreographyStreetV1.preflop => null,
        Act0TableChoreographyStreetV1.flop =>
          Act0TableChoreographyBeatKindV1.flopReveal,
        Act0TableChoreographyStreetV1.turn =>
          Act0TableChoreographyBeatKindV1.turnReveal,
        Act0TableChoreographyStreetV1.river =>
          Act0TableChoreographyBeatKindV1.riverReveal,
      };
      if (revealKind != null) {
        beats.add(
          Act0TableChoreographyBeatV1(
            kind: revealKind,
            street: currentStreet,
            sourceIndex: item.sourceIndex,
          ),
        );
      }
    }

    if (item.action == null) {
      continue;
    }
    if (item.street == null && currentStreet.index > finalStreet.index) {
      return null;
    }

    final actorSeat = item.actorSeat;
    if (actorSeat == null ||
        !actorSeat.isOccupied ||
        foldedActors.contains(actorSeat.seatId)) {
      return null;
    }
    if (item.action == _TrailActionV1.folds) {
      foldedActors.add(actorSeat.seatId);
    }

    if (item.action == _TrailActionV1.acts) {
      if (actorSeat.seatId != heroSeatId) {
        return null;
      }
      terminalSeen = true;
      continue;
    }

    // Posts and the pending-decision marker do not consume a voluntary turn.
    // Never animate the same seat acting twice without an intervening actor.
    if (item.action != _TrailActionV1.blind) {
      if (previousVoluntaryActor == actorSeat.seatId) return null;
      previousVoluntaryActor = actorSeat.seatId;
    }

    beats.add(
      Act0TableChoreographyBeatV1(
        kind: Act0TableChoreographyBeatKindV1.actionFocus,
        street: currentStreet,
        actorSeatId: actorSeat.seatId,
        actorLabel: actorSeat.seatLabel,
        sourceIndex: item.sourceIndex,
      ),
    );

    final commitment = _commitmentForTrailItemV1(item);
    if (commitment != null) {
      transientCommitments.add(actorSeat.seatId);
      beats.add(
        Act0TableChoreographyBeatV1(
          kind: Act0TableChoreographyBeatKindV1.commitmentMove,
          street: currentStreet,
          actorSeatId: actorSeat.seatId,
          actorLabel: actorSeat.seatLabel,
          commitment: commitment,
          sourceIndex: item.sourceIndex,
        ),
      );
    } else if (item.action == _TrailActionV1.folds) {
      beats.add(
        Act0TableChoreographyBeatV1(
          kind: Act0TableChoreographyBeatKindV1.foldRecess,
          street: currentStreet,
          actorSeatId: actorSeat.seatId,
          actorLabel: actorSeat.seatLabel,
          sourceIndex: item.sourceIndex,
        ),
      );
    }
  }

  if (currentStreet != finalStreet ||
      beats.isEmpty ||
      foldedActors.contains(heroSeatId)) {
    return null;
  }

  beats.add(
    Act0TableChoreographyBeatV1(
      kind: Act0TableChoreographyBeatKindV1.heroDecisionReady,
      street: finalStreet,
      actorSeatId: heroSeatId,
      actorLabel: heroSeat.seatLabel,
    ),
  );

  return Act0TableChoreographyPlanV1(
    initialStreet: initialStreet,
    finalStreet: finalStreet,
    heroSeatId: heroSeatId,
    beats: List<Act0TableChoreographyBeatV1>.unmodifiable(beats),
  );
}

enum _TrailActionV1 {
  blind,
  opens,
  raises,
  bets,
  calls,
  checks,
  folds,
  shoves,
  allIn,
  acts,
}

class _ParsedTrailItemV1 {
  const _ParsedTrailItemV1({
    required this.sourceIndex,
    required this.street,
    required this.actorSeat,
    required this.action,
    required this.amountLabel,
  });

  final int sourceIndex;
  final Act0TableChoreographyStreetV1? street;
  final Act0SeatStateV1? actorSeat;
  final _TrailActionV1? action;
  final String? amountLabel;
}

_ParsedTrailItemV1? _parseTrailItemV1(
  String source, {
  required int sourceIndex,
  required Map<String, Act0SeatStateV1> seatByActor,
  required Act0SeatStateV1 heroSeat,
}) {
  var text = source.trim();
  if (text.isEmpty) {
    return null;
  }

  Act0TableChoreographyStreetV1? street;
  final prefix = RegExp(
    r'^(Flop|Turn|River):\s*',
    caseSensitive: false,
  ).firstMatch(text);
  if (prefix != null) {
    street = _streetFromLabelV1(prefix.group(1)!);
    text = text.substring(prefix.end).trim();
  }

  if (RegExp(
    r'^(Flop|Turn|River)\s+dealt$',
    caseSensitive: false,
  ).hasMatch(text)) {
    final match = RegExp(
      r'^(Flop|Turn|River)',
      caseSensitive: false,
    ).firstMatch(text)!;
    final boundary = _streetFromLabelV1(match.group(1)!);
    if (street != null && street != boundary) {
      return null;
    }
    return _ParsedTrailItemV1(
      sourceIndex: sourceIndex,
      street: boundary,
      actorSeat: null,
      action: null,
      amountLabel: null,
    );
  }

  final actorMatch = RegExp(r'^([A-Za-z0-9+_-]+)\s+').firstMatch(text);
  if (actorMatch == null) {
    return null;
  }
  final actorToken = actorMatch.group(1)!.toUpperCase();
  final actorSeat = actorToken == 'HERO' ? heroSeat : seatByActor[actorToken];
  if (actorSeat == null) {
    return null;
  }
  var remainder = text.substring(actorMatch.end).trim();

  final actionMatch = RegExp(
    r'^(blind|opens?|raises?|bets?|calls?|checks?|folds?|shoves?|all[- ]in|acts)\b',
    caseSensitive: false,
  ).firstMatch(remainder);
  if (actionMatch == null) {
    return null;
  }
  final action = _trailActionFromTokenV1(actionMatch.group(1)!);
  if (action == null) {
    return null;
  }
  remainder = remainder.substring(actionMatch.end).trim();

  final suffix = RegExp(
    r'\b(flop|turn|river)$',
    caseSensitive: false,
  ).firstMatch(remainder);
  if (suffix != null) {
    final suffixStreet = _streetFromLabelV1(suffix.group(1)!);
    if (street != null && street != suffixStreet) {
      return null;
    }
    street = suffixStreet;
    remainder = remainder.substring(0, suffix.start).trim();
  }

  if (action == _TrailActionV1.acts && remainder.isNotEmpty) {
    return null;
  }

  String? amountLabel;
  if (remainder.isNotEmpty) {
    if (!RegExp(
      r'^\d+(?:\.\d+)?\s*BB$',
      caseSensitive: false,
    ).hasMatch(remainder)) {
      return null;
    }
    amountLabel = remainder;
  }

  return _ParsedTrailItemV1(
    sourceIndex: sourceIndex,
    street: street,
    actorSeat: actorSeat,
    action: action,
    amountLabel: amountLabel,
  );
}

_TrailActionV1? _trailActionFromTokenV1(String token) {
  return switch (token.trim().toLowerCase()) {
    'blind' => _TrailActionV1.blind,
    'open' || 'opens' => _TrailActionV1.opens,
    'raise' || 'raises' => _TrailActionV1.raises,
    'bet' || 'bets' => _TrailActionV1.bets,
    'call' || 'calls' => _TrailActionV1.calls,
    'check' || 'checks' => _TrailActionV1.checks,
    'fold' || 'folds' => _TrailActionV1.folds,
    'shove' || 'shoves' => _TrailActionV1.shoves,
    'all-in' || 'all in' => _TrailActionV1.allIn,
    'acts' => _TrailActionV1.acts,
    _ => null,
  };
}

Act0SeatBetStateV1? _commitmentForTrailItemV1(_ParsedTrailItemV1 item) {
  final actor = item.actorSeat;
  final action = item.action;
  if (actor == null || action == null) {
    return null;
  }
  final kind = switch (action) {
    _TrailActionV1.blind => Act0SeatBetKindV1.post,
    _TrailActionV1.opens || _TrailActionV1.raises => Act0SeatBetKindV1.raise,
    _TrailActionV1.bets => Act0SeatBetKindV1.bet,
    _TrailActionV1.calls => Act0SeatBetKindV1.call,
    _TrailActionV1.shoves || _TrailActionV1.allIn => Act0SeatBetKindV1.allIn,
    _TrailActionV1.checks ||
    _TrailActionV1.folds ||
    _TrailActionV1.acts => null,
  };
  if (kind == null) {
    return null;
  }
  return Act0SeatBetStateV1(
    kind: kind,
    label: actor.seatLabel,
    amountLabel: item.amountLabel ?? '',
  );
}

Act0TableChoreographyStreetV1? _streetFromLabelV1(String label) {
  return switch (label.trim().toLowerCase()) {
    'preflop' => Act0TableChoreographyStreetV1.preflop,
    'flop' => Act0TableChoreographyStreetV1.flop,
    'turn' => Act0TableChoreographyStreetV1.turn,
    'river' => Act0TableChoreographyStreetV1.river,
    _ => null,
  };
}

bool _isValidBoardCardV1(Act0CardStateV1 card) {
  final rank = card.rank.trim().toUpperCase();
  final suit = card.suit.trim().toLowerCase();
  const ranks = <String>{
    'A',
    'K',
    'Q',
    'J',
    'T',
    '10',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
  };
  const suits = <String>{'s', 'h', 'd', 'c', '♠', '♥', '♦', '♣'};
  return rank != '?' &&
      suit != '?' &&
      ranks.contains(rank) &&
      suits.contains(suit);
}
