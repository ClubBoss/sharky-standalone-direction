import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

/// Typed admission contract for the one canonical W5 board-texture repair.
class Act0BoardTexturePersonalizationV1 {
  static const String worldId = 'world_5';
  static const String lessonId = 'board_texture_basics';
  // `board_texture_basics` composes its tasks through the lesson-prefixing
  // builder, so the runtime task identity carries the lesson prefix. The
  // admission contract must name that runtime identity, the same way the W2
  // repair task is named `continue_or_let_go_medium_call_or_fold`.
  static const String sourceTaskId = 'board_texture_basics_w5_dry_board';
  static const String repairTaskId = 'board_texture_basics_w5_wet_board';
  static const String errorType = 'misread_board_texture';
  static const String skillId = 'board_read';
  static const String missedSignalId = 'board_cards';
  static const String reasonCode = 'same_signal_board_read_board_cards';

  static Act0BoardTexturePersonalizationCaseV1? fromRepairIntent(
    Act0RepairIntentV1 intent,
  ) {
    if (intent.sourceWorldId != worldId ||
        intent.sourceLessonId != lessonId ||
        intent.sourceTaskId != sourceTaskId ||
        intent.targetWorldId != worldId ||
        intent.targetLessonId != lessonId ||
        intent.targetTaskId != repairTaskId ||
        intent.errorType != errorType ||
        intent.skillAtomId != skillId ||
        intent.missedSignalId != missedSignalId ||
        intent.mappingType != 'repair' ||
        intent.reasonCode != reasonCode)
      return null;
    return const Act0BoardTexturePersonalizationCaseV1();
  }

  static bool isCanonicalSourceTask(String taskId) => taskId == sourceTaskId;
}

class Act0BoardTexturePersonalizationCaseV1 {
  const Act0BoardTexturePersonalizationCaseV1();

  String get feedbackMappingId => 'w5_board_texture_feedback_v1';
  String get feedbackFocus =>
      'Read the visible board cards together: connection and suits change the texture.';
  String get repairStrategyId => 'compare_board_connection_v1';
  String get recheckMappingId => 'same_board_texture_signal_v1';
  String get cleanPayoffOutcome => 'board_texture_read_cleanly';
  String get successfulPayoffOutcome => 'board_texture_recovered';
  String get failedRecheckOutcome => 'board_texture_still_needs_rep';

  Map<String, Object?> telemetryFields({
    required String attemptPhase,
    required String finalLearningOutcome,
  }) => <String, Object?>{
    'schemaVersion': 1,
    'lesson_id': Act0BoardTexturePersonalizationV1.lessonId,
    'task_id': Act0BoardTexturePersonalizationV1.sourceTaskId,
    'skill_id': Act0BoardTexturePersonalizationV1.skillId,
    'error_type': Act0BoardTexturePersonalizationV1.errorType,
    'missed_signal_id': Act0BoardTexturePersonalizationV1.missedSignalId,
    'mapping_type': 'repair',
    'reason_code': Act0BoardTexturePersonalizationV1.reasonCode,
    'attempt_phase': attemptPhase,
    'feedback_mapping_id': feedbackMappingId,
    'repair_strategy': repairStrategyId,
    'recheck_mapping_id': recheckMappingId,
    'final_learning_outcome': finalLearningOutcome,
  };
}
