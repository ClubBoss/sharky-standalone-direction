import 'package:poker_analyzer/models/poker_street.dart';
import 'act0_hand_contributions_v1.dart';
import 'act0_hand_timeline_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

enum Act0TableChoreographyModeV1 { runtime, settled }

enum Act0TableChoreographyBeatKindV1 {
  actionFocus,
  commitmentMove,
  foldRecess,
  commitmentsCollect,
  flopReveal,
  turnReveal,
  riverReveal,
  heroDecisionReady,
}

enum Act0TableChoreographyStreetV1 {
  preflop,
  flop,
  turn,
  river;

  int get boardCardCount => switch (this) {
    Act0TableChoreographyStreetV1.preflop => 0,
    Act0TableChoreographyStreetV1.flop => 3,
    Act0TableChoreographyStreetV1.turn => 4,
    Act0TableChoreographyStreetV1.river => 5,
  };

  String get label => switch (this) {
    Act0TableChoreographyStreetV1.preflop => 'Preflop',
    Act0TableChoreographyStreetV1.flop => 'Flop',
    Act0TableChoreographyStreetV1.turn => 'Turn',
    Act0TableChoreographyStreetV1.river => 'River',
  };
}

class Act0TableChoreographyBeatV1 {
  const Act0TableChoreographyBeatV1({
    required this.kind,
    required this.street,
    this.actorSeatId,
    this.actorLabel,
    this.commitment,
    this.sourceIndex,
    this.contribution,
  });

  final Act0TableChoreographyBeatKindV1 kind;
  final Act0TableChoreographyStreetV1 street;
  final String? actorSeatId;
  final String? actorLabel;
  final Act0SeatBetStateV1? commitment;
  final int? sourceIndex;
  final Act0ContributionV1? contribution;
}

class Act0TableChoreographyPlanV1 {
  const Act0TableChoreographyPlanV1({
    required this.initialStreet,
    required this.finalStreet,
    required this.heroSeatId,
    required this.beats,
    this.verifiedHistory,
    this.verifiedHistoryEndsAtClosedStreet = false,
  });

  final Act0TableChoreographyStreetV1 initialStreet;
  final Act0TableChoreographyStreetV1 finalStreet;
  final String heroSeatId;
  final List<Act0TableChoreographyBeatV1> beats;
  final Act0HandTimelinePrefixV1? verifiedHistory;

  // Proof-only explanation: the recorded betting round is closed and the
  // learner is evaluating a hypothetical continuation, not taking a turn.
  final bool verifiedHistoryEndsAtClosedStreet;

  int get initialBoardCardCount => initialStreet.boardCardCount;
}

class Act0TableChoreographyFrameV1 {
  const Act0TableChoreographyFrameV1({
    required this.street,
    required this.visibleBoardCardCount,
    required this.commitments,
    required this.foldedSeatIds,
    required this.heroDecisionReady,
    this.sourceActorSeatIds = const <String>{},
    this.focusSeatId,
    this.latestCommitmentSeatId,
    this.handContributions,
  });

  final Act0TableChoreographyStreetV1 street;
  final int visibleBoardCardCount;
  final Map<String, Act0SeatBetStateV1> commitments;
  final Set<String> foldedSeatIds;

  // Only seats evidenced acting in this authored history can be restored
  // before their explicit fold. Final source flags are not initial flags.
  final Set<String> sourceActorSeatIds;
  final bool heroDecisionReady;
  final String? focusSeatId;
  final String? latestCommitmentSeatId;
  final Act0HandContributionsV1? handContributions;
}

Act0TableChoreographyPlanV1? act0TableChoreographyPlanForTableV1(
  Act0TableStateV1 table, {
  bool actorFocusSafe = true,
}) => _planForTableV1(table, actorFocusSafe: actorFocusSafe);

/// History certification can additionally prove non-autoplay single-bet
/// explanations without changing the runtime choreography contract.
Act0TableChoreographyPlanV1? act0TableHistoryProofPlanForTableV1(
  Act0TableStateV1 table,
) => _planForTableV1(table, includeBetHistoryProof: true);

/// Full D6 finder proof, including B164 non-autoplay decision histories.
/// Keep B157/B163 callers on their existing plan cohorts.
Act0TableChoreographyPlanV1? act0TableD6HistoryProofPlanForTableV1(
  Act0TableStateV1 table,
) => _planForTableV1(
  table,
  includeBetHistoryProof: true,
  includeDecisionHistoryProof: true,
);

Act0TableChoreographyPlanV1? _planForTableV1(
  Act0TableStateV1 table, {
  bool actorFocusSafe = true,
  bool includeBetHistoryProof = false,
  bool includeDecisionHistoryProof = false,
}) {
  // B157: an explicitly non-autoplay explanation can still carry a complete
  // recorded hand. Expose the verified plan through the same contract as
  // played hands. B163 additionally admits single-bet explanations on the
  // explicit proof path; existing runtime/replay callers retain their plans.
  // Runtime animation is independently gated by autoPlayHistory.
  final checkedHistoryOnly =
      table.scope == Act0TableScopeV1.explanation && !table.autoPlayHistory;
  if (!actorFocusSafe ||
      (table.scope != Act0TableScopeV1.playedHand && !checkedHistoryOnly) ||
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

  // The volume-2 ledger dialect explicitly qualifies every action with a
  // lower-case street. Keep the older (including partial) choreography
  // grammar unchanged; the extended dialect requires a complete legal replay.
  final extended =
      table.tableFormat == Act0TableFormatV1.sixMax &&
      table.actionTrail
              .where((item) => !item.isNote)
              .firstOrNull
              ?.label
              .startsWith('preflop:') ==
          true;
  final parsed = <_ParsedTrailItemV1>[];
  for (var index = 0; index < table.actionTrail.length; index++) {
    if (table.actionTrail[index].isNote) continue;
    final item = _parseTrailItemV1(
      table.actionTrail[index].label,
      sourceIndex: index,
      seatByActor: seatByActor,
      heroSeat: heroSeat,
      extended: extended,
    );
    if (item == null) {
      return null;
    }
    parsed.add(item);
  }
  if (parsed.isEmpty || !parsed.any((item) => item.street != null)) {
    return null;
  }

  final betHistory = checkedHistoryOnly && extended && includeBetHistoryProof
      ? _singleBetHeadsUpHistoryV1(table, parsed, finalStreet)
      : null;
  final decisionHistory =
      checkedHistoryOnly &&
      extended &&
      includeDecisionHistoryProof &&
      _isPreflopOrThreeWayDecisionHistoryV1(table, parsed, finalStreet);
  if (checkedHistoryOnly &&
      (!extended ||
          (betHistory == null &&
              !decisionHistory &&
              !_isCheckedHeadsUpHistoryV1(table, parsed, finalStreet)))) {
    return null;
  }
  final closedStreet = betHistory == _BetHistoryBoundaryV1.closedStreet;
  final verified = extended
      ? _verifyExtendedHistoryV1(table, parsed, closedStreet: closedStreet)
      : null;
  if (extended && verified == null) return null;
  // A complete replay can establish a newly dealt decision street before its
  // first action. The board is authored evidence for the reveal, not an
  // invented trail action or contribution.
  if (verified != null && parsed.last.street != finalStreet) {
    parsed.add(
      _ParsedTrailItemV1(
        sourceIndex: null,
        street: finalStreet,
        actorSeat: null,
        action: null,
        amountLabel: null,
      ),
    );
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

    final verifiedAction = verified?.actions[item.sourceIndex];
    final commitment = _commitmentForTrailItemV1(
      item,
      allIn: verifiedAction?.allIn ?? false,
      amountLabel: verifiedAction == null || verifiedAction.chipsAdded == 0
          ? null
          : _bbLabelV1(verifiedAction.streetTotal / 100),
    );
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
          contribution: verifiedAction == null
              ? null
              : act0TimelineContributionV1(
                  verifiedAction.street,
                  verifiedAction.seat,
                  verifiedAction.verb,
                  verifiedAction.chipsAdded / 100,
                ),
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
    verifiedHistory: verified?.timeline,
    verifiedHistoryEndsAtClosedStreet: closedStreet,
  );
}

// B164: the decision prefix must contain every action from the two blinds.
// Calls before an opening raise are limps; raises are street totals. The
// existing typed ledger, not the shape, validates the amounts and next actor.
bool _isPreflopOrThreeWayDecisionHistoryV1(
  Act0TableStateV1 table,
  List<_ParsedTrailItemV1> parsed,
  Act0TableChoreographyStreetV1 finalStreet,
) {
  if (parsed.any((item) => item.explicitAllIn)) return false;
  final preflop = parsed
      .where((item) => item.street == Act0TableChoreographyStreetV1.preflop)
      .toList();
  final shape = preflop
      .map(
        (item) => switch (item.action) {
          _TrailActionV1.blind => 'p',
          _TrailActionV1.folds => 'f',
          _TrailActionV1.raises => 'r',
          _TrailActionV1.calls => 'c',
          _ => '?',
        },
      )
      .join();
  final folded = preflop
      .where((item) => item.action == _TrailActionV1.folds)
      .map((item) => item.actorSeat?.seatId)
      .toSet();
  if (table.seats.any(
    (seat) =>
        seat.isFolded != folded.contains(seat.seatId) ||
        seat.isInHand == folded.contains(seat.seatId),
  ))
    return false;

  if (finalStreet == Act0TableChoreographyStreetV1.preflop) {
    return parsed.length == preflop.length &&
        RegExp(r'^pp[frc]*$').hasMatch(shape);
  }

  // One open and two calls; every completed postflop street must contain
  // all three checks, while the decision street stops before Hero checks.
  if (folded.length != 3 ||
      !RegExp(r'^pp[frc]{6}$').hasMatch(shape) ||
      'r'.allMatches(shape).length != 1 ||
      'c'.allMatches(shape).length != 2)
    return false;
  for (final street in Act0TableChoreographyStreetV1.values.skip(1)) {
    final actions = parsed.where((item) => item.street == street).toList();
    final expected = street.index > finalStreet.index
        ? 0
        : street == finalStreet
        ? 2
        : 3;
    if (actions.length != expected ||
        actions.any((item) => item.action != _TrailActionV1.checks)) {
      return false;
    }
  }
  return true;
}

// B157: the two six-max single-open/call shapes, ending after the first
// flop check or after two fully checked streets and the first river check.
// Match parsed actions, not display prose or task IDs. The typed ledger still
// proves the actors, contributions, round closure and next decision separately.
bool _isCheckedHeadsUpHistoryV1(
  Act0TableStateV1 table,
  List<_ParsedTrailItemV1> parsed,
  Act0TableChoreographyStreetV1 finalStreet,
) {
  if (finalStreet != Act0TableChoreographyStreetV1.flop &&
      finalStreet != Act0TableChoreographyStreetV1.river) {
    return false;
  }
  final preflop = parsed
      .where((item) => item.street == Act0TableChoreographyStreetV1.preflop)
      .toList();
  final shape = preflop
      .map(
        (item) => switch (item.action) {
          _TrailActionV1.blind => 'p',
          _TrailActionV1.folds => 'f',
          _TrailActionV1.raises => 'r',
          _TrailActionV1.calls => 'c',
          _ => '?',
        },
      )
      .join();
  if (shape != 'ppffrffc' && shape != 'ppfffrfc') return false;
  final folded = preflop
      .where((item) => item.action == _TrailActionV1.folds)
      .map((item) => item.actorSeat?.seatId)
      .toSet();
  if (folded.length != 4 ||
      table.seats.any(
        (seat) =>
            seat.isFolded != folded.contains(seat.seatId) ||
            seat.isInHand == folded.contains(seat.seatId),
      )) {
    return false;
  }
  for (final street in Act0TableChoreographyStreetV1.values.skip(1)) {
    final actions = parsed.where((item) => item.street == street).toList();
    final expected = street.index > finalStreet.index
        ? 0
        : street == finalStreet
        ? 1
        : 2;
    if (actions.length != expected ||
        actions.any((item) => item.action != _TrailActionV1.checks)) {
      return false;
    }
  }
  return true;
}

enum _BetHistoryBoundaryV1 { decision, closedStreet }

// The B163 proof dialect is intentionally limited to a single preflop open
// and call, four recorded folds, and postflop check/bet/call rounds. Shape
// alone is not a certificate: the same typed ledger verifies every actor,
// amount and street transition below. No raises or all-ins are admitted here.
_BetHistoryBoundaryV1? _singleBetHeadsUpHistoryV1(
  Act0TableStateV1 table,
  List<_ParsedTrailItemV1> parsed,
  Act0TableChoreographyStreetV1 finalStreet,
) {
  if (finalStreet == Act0TableChoreographyStreetV1.preflop ||
      parsed.any((item) => item.explicitAllIn))
    return null;
  final preflop = parsed
      .where((item) => item.street == Act0TableChoreographyStreetV1.preflop)
      .toList();
  final shape = preflop
      .map(
        (item) => switch (item.action) {
          _TrailActionV1.blind => 'p',
          _TrailActionV1.folds => 'f',
          _TrailActionV1.raises => 'r',
          _TrailActionV1.calls => 'c',
          _ => '?',
        },
      )
      .join();
  if (!const {'ppfrfffc', 'ppffrffc', 'ppfffrfc'}.contains(shape)) return null;
  final folded = preflop
      .where((item) => item.action == _TrailActionV1.folds)
      .map((item) => item.actorSeat?.seatId)
      .toSet();
  if (folded.length != 4 ||
      table.seats.any(
        (seat) =>
            seat.isFolded != folded.contains(seat.seatId) ||
            seat.isInHand == folded.contains(seat.seatId),
      ))
    return null;

  var sawBet = false;
  var boundary = _BetHistoryBoundaryV1.decision;
  for (final street in Act0TableChoreographyStreetV1.values.skip(1)) {
    final actions = parsed.where((item) => item.street == street).toList();
    final shape = actions
        .map(
          (item) => switch (item.action) {
            _TrailActionV1.checks => 'x',
            _TrailActionV1.bets => 'b',
            _TrailActionV1.calls => 'c',
            _ => '?',
          },
        )
        .join();
    if (shape.contains('b')) sawBet = true;
    if (street.index > finalStreet.index) {
      if (shape.isNotEmpty) return null;
    } else if (street.index < finalStreet.index) {
      if (!const {'xx', 'bc', 'xbc'}.contains(shape)) return null;
    } else if (const {'bc', 'xbc'}.contains(shape)) {
      // A called final street is a legal closed prefix, not a Hero turn.
      // Only non-autoplay explanations arrive here.
      boundary = _BetHistoryBoundaryV1.closedStreet;
    } else if (!const {'', 'x', 'b', 'xb'}.contains(shape)) {
      return null;
    }
  }
  return sawBet ? boundary : null;
}

Act0TableChoreographyFrameV1 act0TableChoreographyFrameAfterBeatV1(
  Act0TableChoreographyPlanV1 plan,
  int beatIndex,
) {
  var street = plan.initialStreet;
  var visibleBoardCardCount = plan.initialBoardCardCount;
  final commitments = <String, Act0SeatBetStateV1>{};
  final foldedSeatIds = <String>{};
  String? focusSeatId;
  String? latestCommitmentSeatId;
  var heroDecisionReady = false;
  final contributions = <Act0ContributionV1>[];

  final lastIndex = beatIndex.clamp(-1, plan.beats.length - 1);
  for (var index = 0; index <= lastIndex; index++) {
    final beat = plan.beats[index];
    latestCommitmentSeatId = null;
    switch (beat.kind) {
      case Act0TableChoreographyBeatKindV1.actionFocus:
        focusSeatId = beat.actorSeatId;
      case Act0TableChoreographyBeatKindV1.commitmentMove:
        final actorSeatId = beat.actorSeatId;
        final commitment = beat.commitment;
        if (actorSeatId != null && commitment != null) {
          commitments[actorSeatId] = commitment;
          if (beat.contribution case final contribution?)
            contributions.add(contribution);
          focusSeatId = actorSeatId;
          latestCommitmentSeatId = actorSeatId;
        }
      case Act0TableChoreographyBeatKindV1.foldRecess:
        final actorSeatId = beat.actorSeatId;
        if (actorSeatId != null) {
          foldedSeatIds.add(actorSeatId);
          focusSeatId = null;
        }
      case Act0TableChoreographyBeatKindV1.commitmentsCollect:
        commitments.clear();
      case Act0TableChoreographyBeatKindV1.flopReveal:
        street = Act0TableChoreographyStreetV1.flop;
        visibleBoardCardCount = 3;
      case Act0TableChoreographyBeatKindV1.turnReveal:
        street = Act0TableChoreographyStreetV1.turn;
        visibleBoardCardCount = 4;
      case Act0TableChoreographyBeatKindV1.riverReveal:
        street = Act0TableChoreographyStreetV1.river;
        visibleBoardCardCount = 5;
      case Act0TableChoreographyBeatKindV1.heroDecisionReady:
        street = plan.finalStreet;
        visibleBoardCardCount = plan.finalStreet.boardCardCount;
        commitments.clear();
        focusSeatId = plan.heroSeatId;
        heroDecisionReady = true;
    }
  }

  return Act0TableChoreographyFrameV1(
    street: street,
    visibleBoardCardCount: visibleBoardCardCount,
    commitments: Map<String, Act0SeatBetStateV1>.unmodifiable(commitments),
    foldedSeatIds: Set<String>.unmodifiable(foldedSeatIds),
    heroDecisionReady: heroDecisionReady,
    sourceActorSeatIds: Set<String>.unmodifiable(
      plan.beats.map((beat) => beat.actorSeatId).whereType<String>(),
    ),
    focusSeatId: focusSeatId,
    latestCommitmentSeatId: latestCommitmentSeatId,
    handContributions: plan.verifiedHistory == null
        ? null
        : Act0HandContributionsV1(
            throughStreet: PokerStreet.values[street.index],
            startingStackBbBySeat: {
              for (final entry in plan.verifiedHistory!.startingStacks.entries)
                entry.key: entry.value / 100,
            },
            entries: List.unmodifiable(contributions),
          ),
  );
}

Act0TableStateV1 act0TableForChoreographyFrameV1(
  Act0TableStateV1 source,
  Act0TableChoreographyFrameV1 frame, {
  bool showDecisionSeatDetails = true,
}) {
  if (frame.heroDecisionReady) {
    return source;
  }

  final ledger = frame.handContributions;
  final invested = <String, int>{};
  for (final entry in ledger?.entries ?? const <Act0ContributionV1>[]) {
    invested.update(
      entry.seatId,
      (total) => total + (entry.netAmountBb * 100).round(),
      ifAbsent: () => (entry.netAmountBb * 100).round(),
    );
  }
  final seats = source.seats
      .map((seat) {
        final sourceActor = frame.sourceActorSeatIds.contains(seat.seatId);
        final folded =
            frame.foldedSeatIds.contains(seat.seatId) ||
            (seat.isFolded && !sourceActor);
        return Act0SeatStateV1(
          seatId: seat.seatId,
          seatLabel: seat.seatLabel,
          displayName: seat.displayName,
          isHero: seat.isHero,
          isDealerButton: seat.isDealerButton,
          isSmallBlind: seat.isSmallBlind,
          isBigBlind: seat.isBigBlind,
          blindAmountLabel: seat.blindAmountLabel,
          isActive: seat.seatId == frame.focusSeatId,
          isTarget: showDecisionSeatDetails && seat.isTarget,
          isInHand: !folded && (sourceActor || seat.isInHand),
          isFolded: folded,
          hasActed: showDecisionSeatDetails && seat.hasActed,
          isLastAggressor: showDecisionSeatDetails && seat.isLastAggressor,
          isOccupied: seat.isOccupied,
          stackLabel: !showDecisionSeatDetails
              ? ''
              : ledger == null
              ? seat.stackLabel
              : _bbLabelV1(
                  ((ledger.startingStackBbBySeat[seat.seatId]! * 100).round() -
                          (invested[seat.seatId] ?? 0)) /
                      100,
                ),
          holeCards: seat.holeCards,
          cardsVisibleMode:
              !showDecisionSeatDetails &&
                  !seat.isHero &&
                  seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp
              ? Act0CardsVisibleModeV1.faceDown
              : seat.cardsVisibleMode,
          currentBetLabel: null,
          bet: frame.commitments[seat.seatId],
        );
      })
      .toList(growable: false);

  return Act0TableStateV1(
    scope: source.scope,
    tableFormat: source.tableFormat,
    playerCount: source.playerCount,
    density: source.density,
    seats: seats,
    heroCards: source.heroCards,
    boardCards: source.boardCards
        .take(frame.visibleBoardCardCount)
        .toList(growable: false),
    streetLabel: frame.street.label,
    potLabel: ledger == null
        ? ''
        : 'Pot ${_bbLabelV1(invested.values.fold<int>(0, (total, amount) => total + amount) / 100)}',
    handContributions: ledger,
    toCallLabel: '',
    centerLabel: '',
    focusCalloutLabel: '',
    emptyBoardLabel: source.emptyBoardLabel,
    actionTrail: const <Act0ActionTrailItemV1>[],
    activeSeatId: frame.focusSeatId,
    heroSeatId: source.heroSeatId,
    highlightedSeatIds: frame.focusSeatId == null
        ? const <String>[]
        : <String>[frame.focusSeatId!],
    highlightedCardIds: const <String>[],
    selectableSeatIds: const <String>[],
    selectedSeatId: null,
    instructionAnchor: source.instructionAnchor,
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
    this.callMore = false,
    this.explicitAllIn = false,
  });

  final int? sourceIndex;
  final Act0TableChoreographyStreetV1? street;
  final Act0SeatStateV1? actorSeat;
  final _TrailActionV1? action;
  final String? amountLabel;
  final bool callMore;
  final bool explicitAllIn;
}

_ParsedTrailItemV1? _parseTrailItemV1(
  String source, {
  required int sourceIndex,
  required Map<String, Act0SeatStateV1> seatByActor,
  required Act0SeatStateV1 heroSeat,
  required bool extended,
}) {
  var text = source.trim();
  if (text.isEmpty) {
    return null;
  }

  Act0TableChoreographyStreetV1? street;
  final prefix = RegExp(
    extended ? r'^(Preflop|Flop|Turn|River):\s*' : r'^(Flop|Turn|River):\s*',
    caseSensitive: false,
  ).firstMatch(text);
  if (prefix != null) {
    street = _streetFromLabelV1(prefix.group(1)!);
    text = text.substring(prefix.end).trim();
  }

  if (extended && street == null) return null;

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
    extended
        ? r'^(posts|raises|bets|calls|checks|folds|shoves|all-in)\b'
        : r'^(blind|opens?|raises?|bets?|calls?|checks?|folds?|shoves?|all[- ]in|acts)\b',
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

  var callMore = false;
  var explicitAllIn =
      action == _TrailActionV1.allIn || action == _TrailActionV1.shoves;
  if (extended) {
    if (remainder.endsWith(' (all-in)') &&
        (action == _TrailActionV1.raises ||
            action == _TrailActionV1.bets ||
            action == _TrailActionV1.calls)) {
      explicitAllIn = true;
      remainder = remainder.substring(0, remainder.length - 9);
    }
    if (action == _TrailActionV1.raises) {
      if (!remainder.startsWith('to ')) return null;
      remainder = remainder.substring(3);
    }
    if (action == _TrailActionV1.calls && remainder.endsWith(' more')) {
      callMore = true;
      remainder = remainder.substring(0, remainder.length - 5);
    }
  }
  String? amountLabel;
  if (remainder.isNotEmpty) {
    // The B19 street-qualified trail uses bare BB amounts, with calls
    // expressed as chips added rather than the resulting street total.
    // Normalize only this extended grammar; the source ledger and typed
    // replay must still independently confirm every contribution and turn.
    if (extended && RegExp(r'^\d+(?:\.\d+)?$').hasMatch(remainder)) {
      if (action == _TrailActionV1.calls) callMore = true;
      remainder = '$remainder BB';
    }
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
    callMore: callMore,
    explicitAllIn: explicitAllIn,
  );
}

_TrailActionV1? _trailActionFromTokenV1(String token) {
  return switch (token.trim().toLowerCase()) {
    'blind' || 'posts' => _TrailActionV1.blind,
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

Act0SeatBetStateV1? _commitmentForTrailItemV1(
  _ParsedTrailItemV1 item, {
  String? amountLabel,
  bool allIn = false,
}) {
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
    kind: allIn ? Act0SeatBetKindV1.allIn : kind,
    label: actor.seatLabel,
    amountLabel: amountLabel ?? item.amountLabel ?? '',
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

String _bbLabelV1(double bb) =>
    '${bb == bb.roundToDouble() ? bb.toInt() : bb} BB';

/// In the authored street-qualified dialect, raises are street totals and
/// calls with a BB suffix are street totals unless marked "more"; bare
/// numeric calls in the B19 dialect denote additional chips.
/// The independent source contribution ledger must agree action by action;
/// no inferred missing turns,
/// stacks, posts or contributions are allowed.
({Act0HandTimelinePrefixV1 timeline, Map<int, Act0HandActionV1> actions})?
_verifyExtendedHistoryV1(
  Act0TableStateV1 table,
  List<_ParsedTrailItemV1> parsed, {
  bool closedStreet = false,
}) {
  final source = table.handContributions;
  final actor = table.decisionSeatId ?? table.activeSeatId;
  final finalStreet = _streetFromLabelV1(table.streetLabel);
  if (source == null ||
      finalStreet == null ||
      actor == null ||
      actor.isEmpty ||
      actor != table.activeSeatId ||
      table.handHistoryCoverage == Act0HandHistoryCoverageV1.partialDrill ||
      source.fromStreet != PokerStreet.preflop ||
      source.throughStreet.index != finalStreet.index ||
      !table.usesCanonicalPlayerCount ||
      table.seats.length != table.playerCount ||
      table.seats.any((seat) => !seat.isOccupied))
    return null;
  final buttons = table.seats.where((seat) => seat.isDealerButton).toList();
  if (buttons.length != 1) return null;
  final stacks = <String, int>{};
  int? units(double? bb) {
    if (bb == null || !bb.isFinite || bb < 0) return null;
    final scaled = bb * 100;
    return (scaled - scaled.round()).abs() < 1e-7 ? scaled.round() : null;
  }

  for (final label in table.canonicalSeatOrder) {
    final matches = table.seats.where(
      (seat) => seat.seatLabel.toUpperCase() == label,
    );
    if (matches.length != 1) return null;
    final seat = matches.single.seatId;
    final stack = units(source.startingStackBbBySeat[seat]);
    if (stack == null || stack <= 0 || stacks.containsKey(seat)) return null;
    stacks[seat] = stack;
  }
  final deltas = <Act0HandDeltaV1>[];
  final indexes = <int>[];
  final explicitAllIns = <int>{};
  final totals = <String, int>{};
  var currentStreet = PokerStreet.preflop;
  var contributionIndex = 0;
  for (final item in parsed) {
    final street = item.street;
    final seat = item.actorSeat;
    final action = item.action;
    if (street == null ||
        seat == null ||
        action == null ||
        street.index < currentStreet.index ||
        street.index > currentStreet.index + 1)
      return null;
    if (street.index != currentStreet.index) {
      currentStreet = PokerStreet.values[street.index];
      totals.clear();
    }
    final genericAllIn =
        action == _TrailActionV1.allIn || action == _TrailActionV1.shoves;
    final old = totals[seat.seatId] ?? 0;
    final highest = totals.values.fold<int>(0, (a, b) => a > b ? a : b);
    final amount = item.amountLabel;
    final chips = amount == null
        ? null
        : units(double.tryParse(amount.substring(0, amount.length - 2).trim()));
    final verb = switch (action) {
      _TrailActionV1.blind when seat.isSmallBlind => Act0HandVerbV1.smallBlind,
      _TrailActionV1.blind when seat.isBigBlind => Act0HandVerbV1.bigBlind,
      _TrailActionV1.raises => Act0HandVerbV1.raise,
      _TrailActionV1.bets => Act0HandVerbV1.bet,
      _TrailActionV1.calls => Act0HandVerbV1.call,
      _TrailActionV1.folds => Act0HandVerbV1.fold,
      _TrailActionV1.checks => Act0HandVerbV1.check,
      _TrailActionV1.allIn || _TrailActionV1.shoves when chips != null =>
        highest == 0
            ? Act0HandVerbV1.bet
            : chips <= highest
            ? Act0HandVerbV1.call
            : Act0HandVerbV1.raise,
      _ => null,
    };
    if (verb == null) return null;
    final noChips = verb == Act0HandVerbV1.fold || verb == Act0HandVerbV1.check;
    var added = 0;
    if (noChips) {
      if (item.amountLabel != null) return null;
    } else {
      if (chips == null) return null;
      added =
          genericAllIn ||
              verb == Act0HandVerbV1.raise ||
              (verb == Act0HandVerbV1.call && !item.callMore)
          ? chips - old
          : chips;
      if (added <= 0 || contributionIndex >= source.entries.length) return null;
      final expected = act0TimelineContributionV1(
        currentStreet,
        seat.seatId,
        verb,
        added / 100,
      );
      final actual = source.entries[contributionIndex++];
      if (expected.street != actual.street ||
          expected.seatId != actual.seatId ||
          expected.kind != actual.kind ||
          added != units(actual.amountBb))
        return null;
    }
    totals[seat.seatId] = old + added;
    indexes.add(item.sourceIndex!);
    if (item.explicitAllIn) explicitAllIns.add(deltas.length);
    deltas.add((
      street: currentStreet,
      seat: seat.seatId,
      verb: verb,
      chipsAdded: added,
    ));
  }
  if (contributionIndex != source.entries.length ||
      finalStreet.index < currentStreet.index ||
      finalStreet.index > currentStreet.index + 1)
    return null;
  try {
    final timeline = Act0HandTimelineV1.fromDeltas(
      coverage: Act0HandHistoryCoverageV1.complete,
      startingStacks: stacks,
      button: buttons.single.seatId,
      smallBlind: 50,
      bigBlind: 100,
      board: table.boardCards
          .map((card) => '${card.rank == '10' ? 'T' : card.rank}${card.suit}')
          .toList(),
      actions: deltas,
      explicitAllInActions: explicitAllIns,
      heroSeat: table.heroSeatId,
    ).beforeDecision;
    if (closedStreet) {
      // Replay must be legal AND nobody may have a pending decision on this
      // board. Do not turn an incorrect actor into a successful certificate.
      if (timeline.replayError() != null ||
          stacks.keys.any((seat) => timeline.decisionError(seat) == null)) {
        return null;
      }
    } else if (timeline.decisionError(actor) != null) {
      return null;
    }
    final actions = timeline.events.whereType<Act0HandActionV1>().toList();
    return (
      timeline: timeline,
      actions: {
        for (var i = 0; i < indexes.length; i++) indexes[i]: actions[i],
      },
    );
  } on FormatException {
    return null;
  }
}
