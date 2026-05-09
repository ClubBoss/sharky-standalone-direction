import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';

@immutable
class SessionDrillCanonicalOutsScenarioStateV1 {
  const SessionDrillCanonicalOutsScenarioStateV1({
    required this.streetV1,
    required this.heroHoleCardsV1,
    required this.boardCardsV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final List<String> heroHoleCardsV1;
  final List<String> boardCardsV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

SessionDrillCanonicalOutsScenarioStateV1?
resolveSessionDrillCanonicalOutsScenarioStateV1(DrillSpecV1 spec) {
  final outsContext = spec.scenarioOutsContextV1;
  if (outsContext == null) {
    return null;
  }

  return SessionDrillCanonicalOutsScenarioStateV1(
    streetV1: outsContext.streetV1,
    heroHoleCardsV1: List<String>.unmodifiable(outsContext.heroHoleCardsV1),
    boardCardsV1: List<String>.unmodifiable(outsContext.boardCardsV1),
    availableActionsV1: outsContext.availableActionsV1 == null
        ? null
        : List<String>.unmodifiable(outsContext.availableActionsV1!),
    expectedActionIdV1: outsContext.expectedActionIdV1,
  );
}
