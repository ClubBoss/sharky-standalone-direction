import 'package:poker_analyzer/services/drill_contract_v1.dart';

const String kSessionDrillSpatialProjectionHostSurfaceV1 = 'sessionDrillPlayer';
const String kSessionDrillSpatialProjectionRequiredLayoutFamilyV1 =
    'embedded_table_projected';
const String kSessionDrillSpatialProjectionHostGateReasonCodeV1 =
    'table_required_but_host_not_projected';
const String kSessionDrillSpatialProjectionMissingSceneReasonCodeV1 =
    'missing_required_scene_fields';

class SessionDrillSpatialProjectionContractEvaluationV1 {
  const SessionDrillSpatialProjectionContractEvaluationV1({
    required this.applies,
    required this.tableRequired,
    required this.payloadFamily,
    required this.requiredSceneFields,
    required this.optionalSceneFields,
    required this.requiredLayoutFamily,
    required this.hostGateSatisfied,
    required this.hasRequiredScenePayload,
    this.hostGateReasonCode,
    this.payloadReasonCode,
  });

  final bool applies;
  final bool tableRequired;
  final String payloadFamily;
  final List<String> requiredSceneFields;
  final List<String> optionalSceneFields;
  final String requiredLayoutFamily;
  final bool hostGateSatisfied;
  final bool hasRequiredScenePayload;
  final String? hostGateReasonCode;
  final String? payloadReasonCode;
}

class SessionDrillSpatialProjectionContractV1 {
  const SessionDrillSpatialProjectionContractV1._();

  static SessionDrillSpatialProjectionContractEvaluationV1 evaluate({
    required String hostSurface,
    required String layoutFamily,
    required DrillSpecV1 drill,
  }) {
    final payloadFamily = _payloadFamilyForKindV1(drill.kind);
    if (payloadFamily == null ||
        hostSurface != kSessionDrillSpatialProjectionHostSurfaceV1) {
      return const SessionDrillSpatialProjectionContractEvaluationV1(
        applies: false,
        tableRequired: false,
        payloadFamily: 'not_applicable',
        requiredSceneFields: <String>[],
        optionalSceneFields: <String>[],
        requiredLayoutFamily:
            kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
        hostGateSatisfied: true,
        hasRequiredScenePayload: true,
      );
    }

    final requiredSceneFields = _requiredSceneFieldsForKindV1(drill.kind);
    final optionalSceneFields = _optionalSceneFieldsForKindV1(drill.kind);
    final hostGateSatisfied =
        hostSurface == kSessionDrillSpatialProjectionHostSurfaceV1 &&
        layoutFamily == kSessionDrillSpatialProjectionRequiredLayoutFamilyV1;
    final hasRequiredScenePayload = _hasRequiredScenePayloadV1(drill);

    return SessionDrillSpatialProjectionContractEvaluationV1(
      applies: true,
      tableRequired: true,
      payloadFamily: payloadFamily,
      requiredSceneFields: requiredSceneFields,
      optionalSceneFields: optionalSceneFields,
      requiredLayoutFamily:
          kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
      hostGateSatisfied: hostGateSatisfied,
      hasRequiredScenePayload: hasRequiredScenePayload,
      hostGateReasonCode: hostGateSatisfied
          ? null
          : kSessionDrillSpatialProjectionHostGateReasonCodeV1,
      payloadReasonCode: hasRequiredScenePayload
          ? null
          : kSessionDrillSpatialProjectionMissingSceneReasonCodeV1,
    );
  }

  static String? _payloadFamilyForKindV1(DrillKindV1 kind) {
    switch (kind) {
      case DrillKindV1.seatTap:
        return 'seat_anchor_scene';
      case DrillKindV1.boardTap:
        return 'board_slot_scene';
      case DrillKindV1.holeCardsTap:
        return 'hero_hole_cards_scene';
      case DrillKindV1.actionChoice:
      case DrillKindV1.betSizingChoice:
      case DrillKindV1.rangeBucketClassifier:
      case DrillKindV1.showdownWinnerChoice:
      case DrillKindV1.positionThinkingChoice:
      case DrillKindV1.initiativeAggressorChoice:
      case DrillKindV1.outsCountChoice:
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.handChain:
        return null;
    }
  }

  static List<String> _requiredSceneFieldsForKindV1(DrillKindV1 kind) {
    switch (kind) {
      case DrillKindV1.seatTap:
        return const <String>[
          'player_count_v1',
          'hero_seat_v1',
          'villain_seat_v1',
          'active_seats_v1',
        ];
      case DrillKindV1.boardTap:
        return const <String>['board_cards_v1'];
      case DrillKindV1.holeCardsTap:
        return const <String>['hero_hole_cards_v1'];
      case DrillKindV1.actionChoice:
      case DrillKindV1.betSizingChoice:
      case DrillKindV1.rangeBucketClassifier:
      case DrillKindV1.showdownWinnerChoice:
      case DrillKindV1.positionThinkingChoice:
      case DrillKindV1.initiativeAggressorChoice:
      case DrillKindV1.outsCountChoice:
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.handChain:
        return const <String>[];
    }
  }

  static List<String> _optionalSceneFieldsForKindV1(DrillKindV1 kind) {
    switch (kind) {
      case DrillKindV1.seatTap:
        return const <String>[
          'folded_seats_v1',
          'empty_seats_v1',
          'last_aggressor_v1',
          'initiative_owner_v1',
        ];
      case DrillKindV1.boardTap:
        return const <String>['hero_hole_cards_v1'];
      case DrillKindV1.holeCardsTap:
        return const <String>['board_cards_v1'];
      case DrillKindV1.actionChoice:
      case DrillKindV1.betSizingChoice:
      case DrillKindV1.rangeBucketClassifier:
      case DrillKindV1.showdownWinnerChoice:
      case DrillKindV1.positionThinkingChoice:
      case DrillKindV1.initiativeAggressorChoice:
      case DrillKindV1.outsCountChoice:
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.handChain:
        return const <String>[];
    }
  }

  static bool _hasRequiredScenePayloadV1(DrillSpecV1 drill) {
    switch (drill.kind) {
      case DrillKindV1.seatTap:
        return drill.scenarioSeatContextV1 != null;
      case DrillKindV1.boardTap:
        final boardCards = drill.scenarioBoardContextV1?.boardCardsV1;
        return boardCards != null && boardCards.isNotEmpty;
      case DrillKindV1.holeCardsTap:
        final heroHoleCards = drill.scenarioBoardContextV1?.heroHoleCardsV1;
        return heroHoleCards != null && heroHoleCards.length == 2;
      case DrillKindV1.actionChoice:
      case DrillKindV1.betSizingChoice:
      case DrillKindV1.rangeBucketClassifier:
      case DrillKindV1.showdownWinnerChoice:
      case DrillKindV1.positionThinkingChoice:
      case DrillKindV1.initiativeAggressorChoice:
      case DrillKindV1.outsCountChoice:
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.handChain:
        return true;
    }
  }
}
