import 'package:poker_analyzer/services/drill_contract_v1.dart';

const String kSessionDrillHandChainProjectionPayloadFamilyV1 =
    'authored_hand_chain_table';
const String kSessionDrillHandChainProjectionRequiredLayoutFamilyV1 =
    'embedded_table_projected';
const String kSessionDrillHandChainProjectionHostGateReasonCodeV1 =
    'table_required_but_host_not_projected';
const String kSessionDrillHandChainProjectionMissingSceneReasonCodeV1 =
    'missing_required_scene_fields';

class SessionDrillHandChainProjectionContractEvaluationV1 {
  const SessionDrillHandChainProjectionContractEvaluationV1({
    required this.applies,
    required this.tableRequired,
    required this.payloadFamily,
    required this.requiredLayoutFamily,
    required this.hostGateSatisfied,
    required this.hasRequiredScenePayload,
    required this.authoredProjectionStepCount,
    this.hostGateReasonCode,
    this.payloadReasonCode,
  });

  final bool applies;
  final bool tableRequired;
  final String payloadFamily;
  final String requiredLayoutFamily;
  final bool hostGateSatisfied;
  final bool hasRequiredScenePayload;
  final int authoredProjectionStepCount;
  final String? hostGateReasonCode;
  final String? payloadReasonCode;
}

class SessionDrillHandChainProjectionContractV1 {
  const SessionDrillHandChainProjectionContractV1._();

  static SessionDrillHandChainProjectionContractEvaluationV1 evaluate({
    required String hostSurface,
    required String layoutFamily,
    required DrillSpecV1 drill,
  }) {
    if (drill.kind != DrillKindV1.handChain) {
      return const SessionDrillHandChainProjectionContractEvaluationV1(
        applies: false,
        tableRequired: false,
        payloadFamily: 'not_applicable',
        requiredLayoutFamily:
            kSessionDrillHandChainProjectionRequiredLayoutFamilyV1,
        hostGateSatisfied: true,
        hasRequiredScenePayload: true,
        authoredProjectionStepCount: 0,
      );
    }
    final steps = drill.chainStepsV1;
    if (steps == null || steps.isEmpty) {
      return const SessionDrillHandChainProjectionContractEvaluationV1(
        applies: false,
        tableRequired: false,
        payloadFamily: 'not_applicable',
        requiredLayoutFamily:
            kSessionDrillHandChainProjectionRequiredLayoutFamilyV1,
        hostGateSatisfied: true,
        hasRequiredScenePayload: true,
        authoredProjectionStepCount: 0,
      );
    }
    final authoredProjectionStepCount = steps
        .where(_stepRequiresProjectedTableV1)
        .length;
    if (authoredProjectionStepCount == 0) {
      return const SessionDrillHandChainProjectionContractEvaluationV1(
        applies: false,
        tableRequired: false,
        payloadFamily: 'not_applicable',
        requiredLayoutFamily:
            kSessionDrillHandChainProjectionRequiredLayoutFamilyV1,
        hostGateSatisfied: true,
        hasRequiredScenePayload: true,
        authoredProjectionStepCount: 0,
      );
    }
    final hostGateSatisfied =
        hostSurface == 'sessionDrillPlayer' &&
        layoutFamily == kSessionDrillHandChainProjectionRequiredLayoutFamilyV1;
    final hasRequiredScenePayload = steps
        .where(_stepRequiresProjectedTableV1)
        .every(_stepHasRequiredProjectedPayloadV1);
    return SessionDrillHandChainProjectionContractEvaluationV1(
      applies: true,
      tableRequired: true,
      payloadFamily: kSessionDrillHandChainProjectionPayloadFamilyV1,
      requiredLayoutFamily:
          kSessionDrillHandChainProjectionRequiredLayoutFamilyV1,
      hostGateSatisfied: hostGateSatisfied,
      hasRequiredScenePayload: hasRequiredScenePayload,
      authoredProjectionStepCount: authoredProjectionStepCount,
      hostGateReasonCode: hostGateSatisfied
          ? null
          : kSessionDrillHandChainProjectionHostGateReasonCodeV1,
      payloadReasonCode: hasRequiredScenePayload
          ? null
          : kSessionDrillHandChainProjectionMissingSceneReasonCodeV1,
    );
  }

  static bool _stepRequiresProjectedTableV1(DrillChainStepV1 step) {
    if (step.scenarioTableContextV1 != null) {
      return true;
    }
    return step.scenarioActionFollowUpV1?.tableContextV1 != null;
  }

  static bool _stepHasRequiredProjectedPayloadV1(DrillChainStepV1 step) {
    final tableContext = step.scenarioTableContextV1;
    final followUp = step.scenarioActionFollowUpV1?.tableContextV1;
    return _tableContextHasPayloadV1(tableContext) &&
        _tableContextHasPayloadV1(followUp);
  }

  static bool _tableContextHasPayloadV1(DrillScenarioTableContextV1? context) {
    if (context == null) {
      return true;
    }
    return context.seatContextV1 != null || context.boardContextV1 != null;
  }
}
