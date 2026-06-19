import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

class Act0RuleBasedRepairDecisionV1 {
  const Act0RuleBasedRepairDecisionV1({
    this.schemaVersion = 1,
    required this.recommendationSource,
    required this.actionType,
    required this.selectionSource,
    required this.decisionRule,
    required this.priorityBand,
    required this.priorityScore,
    required this.sourceWorldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
    required this.choiceId,
    required this.result,
    required this.errorType,
    required this.missedSignalId,
    required this.skillAtomId,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.mappingType,
    required this.reasonCode,
  });

  final int schemaVersion;
  final String recommendationSource;
  final String actionType;
  final String selectionSource;
  final String decisionRule;
  final String priorityBand;
  final int priorityScore;
  final String sourceWorldId;
  final String sourceLessonId;
  final String sourceTaskId;
  final String choiceId;
  final String result;
  final String errorType;
  final String missedSignalId;
  final String skillAtomId;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String mappingType;
  final String reasonCode;

  Map<String, Object> toPayload() {
    return <String, Object>{
      'schemaVersion': schemaVersion,
      'recommendationSource': recommendationSource,
      'actionType': actionType,
      'selectionSource': selectionSource,
      'decisionRule': decisionRule,
      'priorityBand': priorityBand,
      'priorityScore': priorityScore,
      'sourceWorldId': sourceWorldId,
      'sourceLessonId': sourceLessonId,
      'sourceTaskId': sourceTaskId,
      'choiceId': choiceId,
      'result': result,
      'errorType': errorType,
      'missedSignalId': missedSignalId,
      'skillAtomId': skillAtomId,
      'targetWorldId': targetWorldId,
      'targetLessonId': targetLessonId,
      'targetTaskId': targetTaskId,
      'mappingType': mappingType,
      'reasonCode': reasonCode,
    };
  }
}

Act0RuleBasedRepairDecisionV1? buildAct0RuleBasedRepairDecisionV1({
  required Act0RepairIntentV1? openRepairIntent,
  required bool isOpen,
  int repeatedMissCount = 1,
}) {
  final intent = openRepairIntent;
  if (!isOpen || intent == null || intent.result == 'correct') {
    return null;
  }

  final isExactReplay = intent.mappingType == 'exact';
  final actionType = isExactReplay ? 'exact_replay' : 'same_signal_repair';
  final selectionSource = isExactReplay
      ? 'repair_intent_exact_replay'
      : 'repair_intent_mapped';
  final decisionRule = isExactReplay
      ? 'exact_replay_fallback_v1'
      : 'same_signal_repair_v1';
  final priorityScore = _priorityScoreV1(
    isExactReplay: isExactReplay,
    repeatedMissCount: repeatedMissCount,
  );

  return Act0RuleBasedRepairDecisionV1(
    recommendationSource: 'repair_intent',
    actionType: actionType,
    selectionSource: selectionSource,
    decisionRule: decisionRule,
    priorityBand: priorityScore >= 85 ? 'repair_first' : 'repair_next',
    priorityScore: priorityScore,
    sourceWorldId: intent.sourceWorldId,
    sourceLessonId: intent.sourceLessonId,
    sourceTaskId: intent.sourceTaskId,
    choiceId: intent.choiceId,
    result: intent.result,
    errorType: intent.errorType,
    missedSignalId: intent.missedSignalId,
    skillAtomId: intent.skillAtomId,
    targetWorldId: intent.targetWorldId,
    targetLessonId: intent.targetLessonId,
    targetTaskId: intent.targetTaskId,
    mappingType: intent.mappingType,
    reasonCode: intent.reasonCode,
  );
}

int _priorityScoreV1({
  required bool isExactReplay,
  required int repeatedMissCount,
}) {
  final base = isExactReplay ? 70 : 80;
  final repeatBoost = (repeatedMissCount - 1).clamp(0, 3) * 5;
  return base + repeatBoost;
}
