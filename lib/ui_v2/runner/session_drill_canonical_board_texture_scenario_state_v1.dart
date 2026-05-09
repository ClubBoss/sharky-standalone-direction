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

  if (spec.kind != DrillKindV1.boardTextureClassifier ||
      !sessionId.startsWith('w5.s')) {
    return null;
  }

  final streetV1 = _resolveWorld5BoardTextureStreetIdV1(
    sessionId: sessionId,
    spec: spec,
  );
  return SessionDrillCanonicalBoardTextureScenarioStateV1(
    streetV1: streetV1,
    boardCardsV1: _resolveWorld5BoardTextureBoardCardsV1(
      streetV1: streetV1,
      boardTextureV1: spec.boardTextureV1,
    ),
    boardTextureV1: spec.boardTextureV1?.trim().toLowerCase() ?? 'neutral',
    availableActionsV1: spec.scenarioCoreV1.availableActionsV1 == null
        ? null
        : List<String>.unmodifiable(spec.scenarioCoreV1.availableActionsV1!),
    expectedActionIdV1: spec.scenarioCoreV1.expectedActionIdV1 ?? 'call',
  );
}

String _resolveWorld5BoardTextureStreetIdV1({
  required String sessionId,
  required DrillSpecV1 spec,
}) {
  final authoredStreet = spec.scenarioCoreV1.streetV1;
  if (authoredStreet != null && authoredStreet.isNotEmpty) {
    return authoredStreet;
  }
  final prompt = spec.prompt.toLowerCase();
  if (prompt.contains('river') ||
      prompt.contains('closure') ||
      prompt.contains('closes')) {
    return 'river';
  }
  if (prompt.contains('turn') || const <String>{'w5.s04'}.contains(sessionId)) {
    return 'turn';
  }
  if (const <String>{'w5.s05', 'w5.s08'}.contains(sessionId)) {
    return 'river';
  }
  return 'flop';
}

List<String> _resolveWorld5BoardTextureBoardCardsV1({
  required String streetV1,
  required String? boardTextureV1,
}) {
  final boardRunout = switch (boardTextureV1?.trim().toLowerCase()) {
    'wet' => const <String>['Kh', 'Qh', '9s', 'Jh', 'Th'],
    'connected' => const <String>['Js', 'Td', '9c', '8h', '7s'],
    'paired' => const <String>['Ks', 'Kd', '4c', '9h', '2s'],
    'high_card' => const <String>['Ac', 'Jd', '5s', '2h', '8c'],
    _ => const <String>['As', '7d', '2c', '4h', '9c'],
  };
  final visibleCards = switch (streetV1) {
    'flop' => 3,
    'turn' => 4,
    'river' => 5,
    _ => 0,
  };
  return List<String>.unmodifiable(
    boardRunout.take(visibleCards).toList(growable: false),
  );
}
