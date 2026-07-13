import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_ids_v1.dart';

/// Typed admission contract for the first position-specific personalization
/// family. Classification and repair routing remain owned by the existing
/// repair-intent system; this contract only admits the canonical W3 BTN read
/// and names its feedback, recheck, and truthful outcome semantics.
class Act0PositionPersonalizationV1 {
  static const String sequenceId = act0PositionPersonalizationSequenceIdV1;
  static const String worldId = act0PositionPersonalizationWorldIdV1;
  static const String lessonId = act0PositionPersonalizationLessonIdV1;
  static const String sourceTaskId = act0PositionPersonalizationSourceTaskIdV1;
  static const String repairTaskId = act0PositionPersonalizationRepairTaskIdV1;
  static const String errorType = act0PositionPersonalizationErrorTypeV1;
  static const String missedSignalId = act0PositionPersonalizationSignalIdV1;
  static const String skillId = act0PositionPersonalizationSkillIdV1;

  static Act0PositionPersonalizationCaseV1? fromRepairIntent(
    Act0RepairIntentV1 intent,
  ) {
    if (intent.sourceWorldId != worldId ||
        intent.sourceLessonId != lessonId ||
        intent.sourceTaskId != sourceTaskId ||
        intent.errorType != errorType ||
        intent.missedSignalId != missedSignalId ||
        intent.skillAtomId != skillId ||
        intent.targetWorldId != worldId ||
        intent.targetLessonId != lessonId ||
        intent.targetTaskId != repairTaskId ||
        intent.mappingType != 'repair') {
      return null;
    }
    return const Act0PositionPersonalizationCaseV1();
  }

  static bool isCanonicalSourceTask(String taskId) => taskId == sourceTaskId;
}

class Act0PositionPersonalizationCaseV1 {
  const Act0PositionPersonalizationCaseV1();

  String get feedbackMappingId => 'w3_btn_anchor_feedback_v1';
  String get feedbackFocus => 'The Button anchors late position.';
  String get repairStrategyId => 'find_dealer_button_then_tap_btn_v1';
  String get recheckMappingId => 'same_hero_button_signal_v1';
  String get successfulPayoffOutcome => 'position_signal_recovered';
  String get failedRecheckOutcome => 'position_signal_still_needs_rep';
  String get cleanPayoffOutcome => 'position_signal_read_cleanly';

  Map<String, Object?> telemetryFields({
    required String attemptPhase,
    required String finalLearningOutcome,
  }) => <String, Object?>{
    'schemaVersion': 1,
    'sequence_id': Act0PositionPersonalizationV1.sequenceId,
    'lesson_id': Act0PositionPersonalizationV1.lessonId,
    'task_id': Act0PositionPersonalizationV1.sourceTaskId,
    'skill_id': Act0PositionPersonalizationV1.skillId,
    'error_type': Act0PositionPersonalizationV1.errorType,
    'missed_signal_id': Act0PositionPersonalizationV1.missedSignalId,
    'attempt_phase': attemptPhase,
    'feedback_mapping_id': feedbackMappingId,
    'repair_strategy': repairStrategyId,
    'recheck_mapping_id': recheckMappingId,
    'final_learning_outcome': finalLearningOutcome,
  };
}
