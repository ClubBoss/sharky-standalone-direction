import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';

enum SessionDrillCanonicalSeatContextScenarioFamilyV1 { position, initiative }

@immutable
class SessionDrillCanonicalSeatContextScenarioStateV1 {
  const SessionDrillCanonicalSeatContextScenarioStateV1({
    required this.family,
    required this.streetV1,
    required this.playerCountV1,
    required this.heroSeatV1,
    required this.villainSeatV1,
    required this.activeSeatsV1,
    required this.actingSeatV1,
    required this.availableActionsV1,
    required this.expectedActionIdV1,
    this.foldedSeatsV1,
    this.emptySeatsV1,
    this.lastAggressorV1,
    this.initiativeOwnerV1,
    this.blindLevelV1,
  });

  final SessionDrillCanonicalSeatContextScenarioFamilyV1 family;
  final String streetV1;
  final int playerCountV1;
  final String heroSeatV1;
  final String villainSeatV1;
  final List<String> activeSeatsV1;
  final String actingSeatV1;
  final List<String> availableActionsV1;
  final String expectedActionIdV1;
  final List<String>? foldedSeatsV1;
  final List<String>? emptySeatsV1;
  final String? lastAggressorV1;
  final String? initiativeOwnerV1;
  final DrillScenarioBlindLevelContextV1? blindLevelV1;
}

SessionDrillCanonicalSeatContextScenarioStateV1?
resolveSessionDrillCanonicalSeatContextScenarioStateV1(DrillSpecV1 spec) {
  final blindLevelV1 = spec.scenarioSeatContextV1?.blindLevelV1;
  final positionContext = spec.scenarioPositionContextV1;
  if (positionContext != null) {
    final actingSeatV1 = positionContext.expectedActionIdV1 == 'hero'
        ? positionContext.heroSeatV1
        : positionContext.villainSeatV1;
    return SessionDrillCanonicalSeatContextScenarioStateV1(
      family: SessionDrillCanonicalSeatContextScenarioFamilyV1.position,
      streetV1: positionContext.streetV1,
      playerCountV1: positionContext.playerCountV1,
      heroSeatV1: positionContext.heroSeatV1,
      villainSeatV1: positionContext.villainSeatV1,
      activeSeatsV1: List<String>.unmodifiable(positionContext.activeSeatsV1),
      foldedSeatsV1: positionContext.foldedSeatsV1 == null
          ? null
          : List<String>.unmodifiable(positionContext.foldedSeatsV1!),
      emptySeatsV1: positionContext.emptySeatsV1 == null
          ? null
          : List<String>.unmodifiable(positionContext.emptySeatsV1!),
      actingSeatV1: actingSeatV1,
      availableActionsV1: List<String>.unmodifiable(
        positionContext.availableActionsV1!,
      ),
      expectedActionIdV1: positionContext.expectedActionIdV1!,
      blindLevelV1: blindLevelV1,
    );
  }

  final initiativeContext = spec.scenarioInitiativeContextV1;
  if (initiativeContext != null) {
    final actingSeatV1 = initiativeContext.initiativeOwnerV1 == 'hero'
        ? initiativeContext.heroSeatV1
        : initiativeContext.villainSeatV1;
    return SessionDrillCanonicalSeatContextScenarioStateV1(
      family: SessionDrillCanonicalSeatContextScenarioFamilyV1.initiative,
      streetV1: initiativeContext.streetV1,
      playerCountV1: initiativeContext.playerCountV1,
      heroSeatV1: initiativeContext.heroSeatV1,
      villainSeatV1: initiativeContext.villainSeatV1,
      activeSeatsV1: List<String>.unmodifiable(initiativeContext.activeSeatsV1),
      actingSeatV1: actingSeatV1,
      availableActionsV1: List<String>.unmodifiable(
        initiativeContext.availableActionsV1!,
      ),
      expectedActionIdV1: initiativeContext.expectedActionIdV1!,
      lastAggressorV1: initiativeContext.lastAggressorV1,
      initiativeOwnerV1: initiativeContext.initiativeOwnerV1,
      blindLevelV1: blindLevelV1,
    );
  }

  return null;
}
