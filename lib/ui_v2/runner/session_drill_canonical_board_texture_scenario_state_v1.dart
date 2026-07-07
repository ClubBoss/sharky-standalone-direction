import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';

@immutable
class SessionDrillCanonicalBoardTextureScenarioStateV1 {
  const SessionDrillCanonicalBoardTextureScenarioStateV1({
    required this.streetV1,
    required this.boardCardsV1,
    required this.boardTextureV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final List<String> boardCardsV1;
  final String boardTextureV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

SessionDrillCanonicalBoardTextureScenarioStateV1?
resolveSessionDrillCanonicalBoardTextureScenarioStateV1({
  required String sessionId,
  required DrillSpecV1 spec,
}) {
  final authoredContext = spec.scenarioBoardTextureContextV1;
  if (authoredContext != null) {
    return SessionDrillCanonicalBoardTextureScenarioStateV1(
      streetV1: authoredContext.streetV1,
      boardCardsV1: List<String>.unmodifiable(authoredContext.boardCardsV1),
      boardTextureV1: authoredContext.boardTextureV1,
      availableActionsV1: authoredContext.availableActionsV1 == null
          ? null
          : List<String>.unmodifiable(authoredContext.availableActionsV1!),
      expectedActionIdV1: authoredContext.expectedActionIdV1,
    );
  }

  return null;
}
