import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_reconciliation_v1.dart';

enum SessionDrillCanonicalSpatialScenarioFamilyV1 {
  seatTap,
  boardTap,
  holeCardsTap,
  actionChoice,
}

@immutable
class SessionDrillCanonicalSpatialScenarioStateV1 {
  const SessionDrillCanonicalSpatialScenarioStateV1({
    required this.family,
    required this.projectedStreetV1,
    this.playerCountV1,
    this.heroSeatV1,
    this.villainSeatV1,
    this.activeSeatsV1,
    this.foldedSeatsV1,
    this.emptySeatsV1,
    this.blindLevelV1,
    this.boardCardsV1,
    this.heroHoleCardsV1,
  });

  final SessionDrillCanonicalSpatialScenarioFamilyV1 family;
  final Street projectedStreetV1;
  final int? playerCountV1;
  final String? heroSeatV1;
  final String? villainSeatV1;
  final List<String>? activeSeatsV1;
  final List<String>? foldedSeatsV1;
  final List<String>? emptySeatsV1;
  final DrillScenarioBlindLevelContextV1? blindLevelV1;
  final List<String>? boardCardsV1;
  final List<String>? heroHoleCardsV1;
}

SessionDrillCanonicalSpatialScenarioStateV1?
resolveSessionDrillCanonicalSpatialScenarioStateV1(DrillSpecV1 spec) {
  final family = switch (spec.kind) {
    DrillKindV1.seatTap => SessionDrillCanonicalSpatialScenarioFamilyV1.seatTap,
    DrillKindV1.boardTap =>
      SessionDrillCanonicalSpatialScenarioFamilyV1.boardTap,
    DrillKindV1.holeCardsTap =>
      SessionDrillCanonicalSpatialScenarioFamilyV1.holeCardsTap,
    DrillKindV1.actionChoice when spec.scenarioTableContextV1 != null =>
      SessionDrillCanonicalSpatialScenarioFamilyV1.actionChoice,
    _ => null,
  };
  if (family == null) {
    return null;
  }

  final seatContext = spec.scenarioSeatContextV1;
  final boardContext = spec.scenarioBoardContextV1;
  return SessionDrillCanonicalSpatialScenarioStateV1(
    family: family,
    projectedStreetV1: resolveSessionDrillProjectedStreetV1(
      expectedV1: spec.expected,
      boardCardsV1: boardContext?.boardCardsV1,
    ),
    playerCountV1: seatContext?.playerCountV1,
    heroSeatV1: seatContext?.heroSeatV1,
    villainSeatV1: seatContext?.villainSeatV1,
    activeSeatsV1: seatContext?.activeSeatsV1 == null
        ? null
        : List<String>.unmodifiable(seatContext!.activeSeatsV1),
    foldedSeatsV1: seatContext?.foldedSeatsV1 == null
        ? null
        : List<String>.unmodifiable(seatContext!.foldedSeatsV1!),
    emptySeatsV1: seatContext?.emptySeatsV1 == null
        ? null
        : List<String>.unmodifiable(seatContext!.emptySeatsV1!),
    blindLevelV1: seatContext?.blindLevelV1,
    boardCardsV1: boardContext?.boardCardsV1 == null
        ? null
        : List<String>.unmodifiable(boardContext!.boardCardsV1!),
    heroHoleCardsV1: boardContext?.heroHoleCardsV1 == null
        ? null
        : List<String>.unmodifiable(boardContext!.heroHoleCardsV1!),
  );
}
