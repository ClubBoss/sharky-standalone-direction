import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_ledger_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_pot_showdown_truth_v1.dart';

final _action = RegExp(
  r'^(check|call|fold|bet|raise|open|limp|reraise|re-raise|[345]-bet|(?:go\s+)?all[ -]in|shove|jam)\b',
  caseSensitive: false,
);

String? catalogActionV1(String label) {
  final action = _action.firstMatch(label.trim())?.group(1)?.toLowerCase();
  return switch (action) {
    'open' ||
    'reraise' ||
    're-raise' ||
    '3-bet' ||
    '4-bet' ||
    '5-bet' => 'raise',
    'all-in' || 'all in' || 'go all-in' || 'go all in' || 'jam' => 'shove',
    'limp' => 'call',
    _ => action,
  };
}

final _processQuestion = RegExp(
  r'\b(?:bankroll|buy.in|stake(?:s| level)?|tilt|session|quit|reset|stop.loss|take a break|stop playing)\b',
  caseSensitive: false,
);

Act0DecisionKindV1? catalogDecisionKindV1(Act0LessonTaskV1 task, int world) {
  final runner = task.runner;
  if (runner.options.length < 2) return null;
  final table = runner.table;
  if (table.seats.any((seat) => seat.isHero && seat.isOccupied) &&
      decisionStreetV1(table) != null &&
      runner.options.where((o) => catalogActionV1(o.label) != null).length >=
          2) {
    return Act0DecisionKindV1.table;
  }
  if (world >= 11 &&
      _processQuestion.hasMatch('${task.title} ${runner.question}')) {
    return Act0DecisionKindV1.process;
  }
  return null;
}

PokerStreet? decisionStreetV1(Act0TableStateV1 table) {
  for (final street in PokerStreet.values) {
    if (street.name.toLowerCase() == table.streetLabel.toLowerCase())
      return street;
  }
  return null;
}

class CatalogDecisionLedgerV1 {
  CatalogDecisionLedgerV1(this.table);

  final Act0TableStateV1 table;
  Act0HandContributionsV1? get ledger => table.handContributions;
  late final activeSeatIds = {
    for (final seat in table.seats)
      if (seat.isOccupied && seat.isInHand && !seat.isFolded) seat.seatId,
  };
  late final occupiedSeatIds = {
    for (final seat in table.seats)
      if (seat.isOccupied) seat.seatId,
  };
  late final effectiveStacks = ledger == null
      ? const <String, double>{}
      : act0EffectiveStacksV1(
          ledger!,
          heroSeatId: table.heroSeat.seatId,
          activeSeatIds: activeSeatIds,
        );
  late final hasAllIn =
      table.seats.any(
        (seat) =>
            activeSeatIds.contains(seat.seatId) &&
            seat.bet?.kind == Act0SeatBetKindV1.allIn,
      ) ||
      table.actionTrail.any(
        (item) => potTruthParseActionV1(table, item.label)?.verb == 'all_in',
      );
  late final pots = _potsForDecision();

  List<Act0DecisionPotV1>? _potsForDecision() {
    final current = ledger;
    if (!hasAllIn ||
        current == null ||
        current.fromStreet != PokerStreet.preflop) {
      return null;
    }

    final hero = table.heroSeat.seatId;
    var projected = current;
    if (current.throughStreet != PokerStreet.preflop &&
        activeSeatIds.contains(hero)) {
      // Show what the hero can contest after calling. Use the ledger's
      // stack-capped price and project no other player's future action.
      final due = current
          .amounts(seatIds: occupiedSeatIds, actorSeatId: hero)
          .toCallBb;
      if (due == null) return null;
      if (due > 0) {
        projected = Act0HandContributionsV1(
          fromStreet: current.fromStreet,
          throughStreet: current.throughStreet,
          startingStackBbBySeat: current.startingStackBbBySeat,
          minimumStartingStackBbBySeat: current.minimumStartingStackBbBySeat,
          entries: [
            ...current.entries,
            Act0ContributionV1(
              current.throughStreet,
              hero,
              Act0ContributionKindV1.wager,
              due,
            ),
          ],
        );
      }
    }
    return act0PotEligibilityV1(projected, activeSeatIds: activeSeatIds);
  }

  late final callBb =
      ledger
          ?.amounts(
            seatIds: occupiedSeatIds,
            actorSeatId: table.decisionActorSeatId,
          )
          .toCallBb ??
      potTruthBbV1(table.toCallLabel.replaceFirst('To call ', ''));
  late final facingWager =
      (callBb ?? 0) > 0 &&
      ledger?.entries.any(
            (entry) =>
                entry.street == ledger!.throughStreet &&
                entry.kind == Act0ContributionKindV1.wager &&
                entry.seatId != table.decisionActorSeatId,
          ) ==
          true;

  String seatLabel(String id) =>
      table.seats.firstWhere((seat) => seat.seatId == id).seatLabel;
}
