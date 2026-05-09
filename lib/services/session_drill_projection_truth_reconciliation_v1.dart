import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_topology_contract_v1.dart';

enum SessionDrillSeatOrderPolicyV1 {
  activeFoldedEmptyAuthored,
  canonicalAuthoredArcOrder,
  heroVillainThenStateBuckets,
}

class SessionDrillReconciledTableTruthV1 {
  const SessionDrillReconciledTableTruthV1({
    required this.playerCountV1,
    required this.heroSeatV1,
    required this.villainSeatV1,
    required this.seatOrderV1,
    required this.seatOccupanciesV1,
    required this.heroSeatIndexV1,
    required this.actingSeatIndexV1,
    required this.blindLevelStateV1,
  });

  final int playerCountV1;
  final String heroSeatV1;
  final String villainSeatV1;
  final List<String> seatOrderV1;
  final List<ScenarioSeatOccupancyV1> seatOccupanciesV1;
  final int heroSeatIndexV1;
  final int actingSeatIndexV1;
  final ScenarioBlindLevelStateV1? blindLevelStateV1;

  ScenarioSpecV1 buildScenarioSpec({
    required Street streetV1,
    required List<String> legalActionsV1,
    required String solutionBestActionV1,
  }) {
    return ScenarioSpecV1(
      seatCount: playerCountV1,
      heroSeat: heroSeatIndexV1,
      initialStacks: seatOccupanciesV1
          .map((value) => value == ScenarioSeatOccupancyV1.empty ? 0 : 1000)
          .toList(growable: false),
      seatOccupancies: seatOccupanciesV1,
      blindLevelStateV1: blindLevelStateV1,
      actingSeatStart: actingSeatIndexV1,
      decisionNodeV1: DecisionNodeV1(
        street: streetV1,
        legalActions: legalActionsV1,
        solutionBestAction: solutionBestActionV1,
      ),
    );
  }

  Map<int, String>? roleLabelsV1() {
    final labels = <int, String>{};
    labels[heroSeatIndexV1] = 'HERO';
    final villainSeatIndex = seatOrderV1.indexOf(villainSeatV1);
    if (villainSeatIndex >= 0 && villainSeatIndex != heroSeatIndexV1) {
      labels[villainSeatIndex] = 'VILLAIN';
    }
    return labels.isEmpty ? null : labels;
  }

  Map<int, String>? markerLabelsV1({required bool includeSeatIdsV1}) {
    return canonicalTableMarkerLabelsForSeatOrderV1(
      seatOrder: seatOrderV1,
      includeSeatIds: includeSeatIdsV1,
    );
  }
}

SessionDrillReconciledTableTruthV1 reconcileSessionDrillTableTruthV1({
  required String errorPrefix,
  required int playerCountV1,
  required String heroSeatV1,
  required String villainSeatV1,
  required List<String> activeSeatsV1,
  required String actingSeatV1,
  DrillScenarioBlindLevelContextV1? blindLevelV1,
  List<String> foldedSeatsV1 = const <String>[],
  List<String> emptySeatsV1 = const <String>[],
  SessionDrillSeatOrderPolicyV1 seatOrderPolicyV1 =
      SessionDrillSeatOrderPolicyV1.heroVillainThenStateBuckets,
}) {
  final allSeats = <String>{
    ...activeSeatsV1,
    ...foldedSeatsV1,
    ...emptySeatsV1,
  };
  if (allSeats.length !=
      activeSeatsV1.length + foldedSeatsV1.length + emptySeatsV1.length) {
    throw StateError(
      '$errorPrefix requires disjoint active/folded/empty seats',
    );
  }
  if (allSeats.length != playerCountV1) {
    throw StateError(
      '$errorPrefix requires player_count_v1 to match authored seat-state count',
    );
  }
  if (!allSeats.contains(heroSeatV1) || !allSeats.contains(villainSeatV1)) {
    throw StateError(
      '$errorPrefix requires hero/villain seats inside authored seat-state',
    );
  }
  final seatOrderV1 = switch (seatOrderPolicyV1) {
    SessionDrillSeatOrderPolicyV1.activeFoldedEmptyAuthored ||
    SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder => <String>[
      ...activeSeatsV1,
      ...foldedSeatsV1,
      ...emptySeatsV1,
    ],
    SessionDrillSeatOrderPolicyV1.heroVillainThenStateBuckets => <String>[
      heroSeatV1,
      if (villainSeatV1 != heroSeatV1) villainSeatV1,
      ...activeSeatsV1.where(
        (seat) => seat != heroSeatV1 && seat != villainSeatV1,
      ),
      ...foldedSeatsV1.where(
        (seat) => seat != heroSeatV1 && seat != villainSeatV1,
      ),
      ...emptySeatsV1.where(
        (seat) => seat != heroSeatV1 && seat != villainSeatV1,
      ),
    ],
  };
  if (seatOrderV1.length != allSeats.length ||
      seatOrderV1.toSet().length != seatOrderV1.length) {
    throw StateError('$errorPrefix produced invalid reconciled seat order');
  }
  final heroSeatIndexV1 = seatOrderV1.indexOf(heroSeatV1);
  final actingSeatIndexV1 = seatOrderV1.indexOf(actingSeatV1);
  if (heroSeatIndexV1 < 0 || actingSeatIndexV1 < 0) {
    throw StateError('$errorPrefix has invalid source seat mapping');
  }
  final activeSeatSetV1 = activeSeatsV1.toSet();
  final foldedSeatSetV1 = foldedSeatsV1.toSet();
  final seatOccupanciesV1 = seatOrderV1
      .map(
        (seat) => activeSeatSetV1.contains(seat)
            ? ScenarioSeatOccupancyV1.active
            : foldedSeatSetV1.contains(seat)
            ? ScenarioSeatOccupancyV1.folded
            : ScenarioSeatOccupancyV1.empty,
      )
      .toList(growable: false);
  return SessionDrillReconciledTableTruthV1(
    playerCountV1: playerCountV1,
    heroSeatV1: heroSeatV1,
    villainSeatV1: villainSeatV1,
    seatOrderV1: seatOrderV1,
    seatOccupanciesV1: seatOccupanciesV1,
    heroSeatIndexV1: heroSeatIndexV1,
    actingSeatIndexV1: actingSeatIndexV1,
    blindLevelStateV1: _blindLevelStateForSeatOrderV1(
      seatOrderV1: seatOrderV1,
      blindLevelV1: blindLevelV1,
    ),
  );
}

Street resolveSessionDrillProjectedStreetV1({
  required DrillExpectedV1 expectedV1,
  required List<String>? boardCardsV1,
}) {
  final boardSlot = expectedV1.boardSlot;
  if (boardSlot == 'turn') {
    return Street.turn;
  }
  if (boardSlot == 'river') {
    return Street.river;
  }
  if (boardSlot != null && boardSlot.startsWith('flop_')) {
    return Street.flop;
  }
  switch (boardCardsV1?.length ?? 0) {
    case 0:
      return Street.preflop;
    case 1:
    case 2:
    case 3:
      return Street.flop;
    case 4:
      return Street.turn;
    default:
      return Street.river;
  }
}

ScenarioBlindLevelStateV1? _blindLevelStateForSeatOrderV1({
  required List<String> seatOrderV1,
  required DrillScenarioBlindLevelContextV1? blindLevelV1,
}) {
  if (blindLevelV1 == null) {
    return null;
  }
  final smallBlindSeatIndexV1 = seatOrderV1.indexOf(
    blindLevelV1.smallBlindSeatV1,
  );
  final bigBlindSeatIndexV1 = seatOrderV1.indexOf(blindLevelV1.bigBlindSeatV1);
  if (smallBlindSeatIndexV1 < 0 || bigBlindSeatIndexV1 < 0) {
    return null;
  }
  return ScenarioBlindLevelStateV1(
    smallBlindSeatIndexV1: smallBlindSeatIndexV1,
    bigBlindSeatIndexV1: bigBlindSeatIndexV1,
    smallBlindAmountV1: blindLevelV1.smallBlindAmountV1,
    bigBlindAmountV1: blindLevelV1.bigBlindAmountV1,
    anteAmountV1: blindLevelV1.anteAmountV1,
  );
}
