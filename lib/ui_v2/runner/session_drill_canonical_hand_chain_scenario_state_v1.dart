import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';

@immutable
class SessionDrillCanonicalHandChainScenarioStateV1 {
  const SessionDrillCanonicalHandChainScenarioStateV1({
    required this.coreV1,
    this.tableContextV1,
    this.actionFollowUpV1,
    this.questionShapeV1,
    this.promptV1,
    this.whyV1,
    this.expectedPresetIdV1,
    this.acceptablePresetIdsV1,
    this.rangeBucketV1,
  });

  final DrillScenarioCoreV1 coreV1;
  final DrillScenarioTableContextV1? tableContextV1;
  final DrillScenarioActionFollowUpV1? actionFollowUpV1;
  final String? questionShapeV1;
  final String? promptV1;
  final String? whyV1;
  final String? expectedPresetIdV1;
  final List<String>? acceptablePresetIdsV1;
  final String? rangeBucketV1;
}

SessionDrillCanonicalHandChainScenarioStateV1?
resolveSessionDrillCanonicalHandChainScenarioStateV1({
  DrillChainStepV1? authoredStepV1,
  DrillScenarioHandChainStepContextV1? factualStepV1,
}) {
  final coreV1 = factualStepV1?.coreV1 ?? authoredStepV1?.scenarioCoreV1;
  if (coreV1 == null) {
    return null;
  }
  final acceptablePresetIdsV1 =
      factualStepV1?.acceptablePresetIdsV1 ??
      authoredStepV1?.acceptablePresetIds;
  return SessionDrillCanonicalHandChainScenarioStateV1(
    coreV1: coreV1,
    tableContextV1:
        factualStepV1?.tableContextV1 ?? authoredStepV1?.scenarioTableContextV1,
    actionFollowUpV1:
        factualStepV1?.actionFollowUpV1 ??
        authoredStepV1?.scenarioActionFollowUpV1,
    questionShapeV1:
        factualStepV1?.questionShapeV1 ?? authoredStepV1?.questionShapeV1,
    promptV1: factualStepV1?.promptV1 ?? authoredStepV1?.prompt,
    whyV1: factualStepV1?.whyV1 ?? authoredStepV1?.whyV1,
    expectedPresetIdV1:
        factualStepV1?.expectedPresetIdV1 ?? authoredStepV1?.expectedPresetIdV1,
    acceptablePresetIdsV1: acceptablePresetIdsV1 == null
        ? null
        : List<String>.unmodifiable(acceptablePresetIdsV1),
    rangeBucketV1:
        factualStepV1?.rangeBucketV1 ?? authoredStepV1?.rangeBucketV1,
  );
}
