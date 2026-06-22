import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

typedef Act0RepairIntentTargetMapperV1 =
    ({String worldId, String lessonId, String taskId, String mappingType})?
    Function({
      required String nextRepId,
      required String skillAtomId,
      required String sourceSignalId,
      required String sourceTaskId,
      required String receiptOutcome,
    });

class Act0RepairIntentV1 {
  const Act0RepairIntentV1({
    this.schemaVersion = 1,
    required this.sourceWorldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
    required this.choiceId,
    required this.result,
    required this.errorType,
    required this.missedSignalId,
    required this.missedSignalLabel,
    required this.skillAtomId,
    required this.skillLabel,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.mappingType,
    required this.reasonCode,
  });

  final int schemaVersion;
  final String sourceWorldId;
  final String sourceLessonId;
  final String sourceTaskId;
  final String choiceId;
  final String result;
  final String errorType;
  final String missedSignalId;
  final String missedSignalLabel;
  final String skillAtomId;
  final String skillLabel;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String mappingType;
  final String reasonCode;

  Map<String, Object> toPayload() {
    return <String, Object>{
      'schemaVersion': schemaVersion,
      'sourceWorldId': sourceWorldId,
      'sourceLessonId': sourceLessonId,
      'sourceTaskId': sourceTaskId,
      'choiceId': choiceId,
      'result': result,
      'errorType': errorType,
      'missedSignalId': missedSignalId,
      'missedSignalLabel': missedSignalLabel,
      'skillAtomId': skillAtomId,
      'skillLabel': skillLabel,
      'targetWorldId': targetWorldId,
      'targetLessonId': targetLessonId,
      'targetTaskId': targetTaskId,
      'mappingType': mappingType,
      'reasonCode': reasonCode,
    };
  }

  static Act0RepairIntentV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    if (schemaVersion != 1) {
      return null;
    }
    final sourceWorldId = _requiredString(map, 'sourceWorldId');
    final sourceLessonId = _requiredString(map, 'sourceLessonId');
    final sourceTaskId = _requiredString(map, 'sourceTaskId');
    final choiceId = _requiredString(map, 'choiceId');
    final result = _requiredString(map, 'result');
    final errorType = _requiredString(map, 'errorType');
    final missedSignalId = _requiredString(map, 'missedSignalId');
    final missedSignalLabel = _requiredString(map, 'missedSignalLabel');
    final skillAtomId = _requiredString(map, 'skillAtomId');
    final skillLabel = _requiredString(map, 'skillLabel');
    final targetWorldId = _requiredString(map, 'targetWorldId');
    final targetLessonId = _requiredString(map, 'targetLessonId');
    final targetTaskId = _requiredString(map, 'targetTaskId');
    final mappingType = _requiredString(map, 'mappingType');
    final reasonCode = _requiredString(map, 'reasonCode');
    if (sourceWorldId == null ||
        sourceLessonId == null ||
        sourceTaskId == null ||
        choiceId == null ||
        result == null ||
        errorType == null ||
        missedSignalId == null ||
        missedSignalLabel == null ||
        skillAtomId == null ||
        skillLabel == null ||
        targetWorldId == null ||
        targetLessonId == null ||
        targetTaskId == null ||
        mappingType == null ||
        reasonCode == null) {
      return null;
    }
    return Act0RepairIntentV1(
      schemaVersion: schemaVersion,
      sourceWorldId: sourceWorldId,
      sourceLessonId: sourceLessonId,
      sourceTaskId: sourceTaskId,
      choiceId: choiceId,
      result: result,
      errorType: errorType,
      missedSignalId: missedSignalId,
      missedSignalLabel: missedSignalLabel,
      skillAtomId: skillAtomId,
      skillLabel: skillLabel,
      targetWorldId: targetWorldId,
      targetLessonId: targetLessonId,
      targetTaskId: targetTaskId,
      mappingType: mappingType,
      reasonCode: reasonCode,
    );
  }
}

String? _requiredString(Map<String, Object?> map, String key) {
  final value = map[key]?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

Act0RepairIntentV1? buildAct0RepairIntentV1({
  required String sourceWorldId,
  required String sourceLessonId,
  required String sourceTaskId,
  required Act0RunnerStateV1 runner,
  required Act0RunnerOptionV1 selectedOption,
  Act0RepairIntentTargetMapperV1? mapSameSignalRep,
}) {
  if (selectedOption.isCorrect ||
      selectedOption.quality == Act0FeedbackQualityV1.correct) {
    return null;
  }

  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: runner,
    option: selectedOption,
    taskFamily: Act0TaskFamilyV1.decision,
  );
  if (receipt == null) {
    return null;
  }

  final result = _resultForQualityV1(selectedOption.quality);
  final receiptOutcome = _receiptOutcomeIdV1(receipt.outcome);
  final mappedTarget = mapSameSignalRep?.call(
    nextRepId: receipt.nextRepId,
    skillAtomId: receipt.skillAtomId,
    sourceSignalId: receipt.sourceSignalId,
    sourceTaskId: sourceTaskId,
    receiptOutcome: receiptOutcome,
  );

  final targetWorldId = mappedTarget?.worldId ?? sourceWorldId;
  final targetLessonId = mappedTarget?.lessonId ?? sourceLessonId;
  final targetTaskId = mappedTarget?.taskId ?? sourceTaskId;
  final mappingType = mappedTarget?.mappingType ?? 'exact';
  final reasonCode = mappedTarget == null
      ? 'exact_replay_${receipt.skillAtomId}_${receipt.sourceSignalId}'
      : 'same_signal_${receipt.skillAtomId}_${receipt.sourceSignalId}';

  return Act0RepairIntentV1(
    sourceWorldId: sourceWorldId,
    sourceLessonId: sourceLessonId,
    sourceTaskId: sourceTaskId,
    choiceId: selectedOption.id,
    result: result,
    errorType: _errorTypeForResultV1(
      result: result,
      skillAtomId: receipt.skillAtomId,
    ),
    missedSignalId: receipt.sourceSignalId,
    missedSignalLabel: receipt.sourceSignalLabel,
    skillAtomId: receipt.skillAtomId,
    skillLabel: receipt.skillLabel,
    targetWorldId: targetWorldId,
    targetLessonId: targetLessonId,
    targetTaskId: targetTaskId,
    mappingType: mappingType,
    reasonCode: reasonCode,
  );
}

String _resultForQualityV1(Act0FeedbackQualityV1 quality) {
  return switch (quality) {
    Act0FeedbackQualityV1.correct => 'correct',
    Act0FeedbackQualityV1.wrong => 'incorrect',
    Act0FeedbackQualityV1.suboptimal => 'suboptimal',
  };
}

String _errorTypeForResultV1({
  required String result,
  required String skillAtomId,
}) {
  return switch (result) {
    'incorrect' => 'missed_$skillAtomId',
    'suboptimal' => 'thin_$skillAtomId',
    _ => 'none',
  };
}

String _receiptOutcomeIdV1(Act0SkillReceiptOutcomeV1 outcome) {
  return switch (outcome) {
    Act0SkillReceiptOutcomeV1.learned => 'learned',
    Act0SkillReceiptOutcomeV1.repairStarted => 'repair_started',
    Act0SkillReceiptOutcomeV1.needsRep => 'needs_rep',
  };
}
