import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_hand_personalization_ids_v1.dart';

/// Typed admission contract for the canonical W2 starting-hand discipline
/// family. Authored answers and repair routing remain owned by the existing
/// task and repair-intent systems; this adapter only admits their exact tuple.
class Act0StartingHandPersonalizationV1 {
  static const String sequenceId = act0StartingHandPersonalizationSequenceIdV1;
  static const String worldId = act0StartingHandPersonalizationWorldIdV1;
  static const String sourceLessonId =
      act0StartingHandPersonalizationSourceLessonIdV1;
  static const String sourceTaskId =
      act0StartingHandPersonalizationSourceTaskIdV1;
  static const String repairLessonId =
      act0StartingHandPersonalizationRepairLessonIdV1;
  static const String repairTaskId =
      act0StartingHandPersonalizationRepairTaskIdV1;
  static const String errorType = act0StartingHandPersonalizationErrorTypeV1;
  static const String missedSignalId =
      act0StartingHandPersonalizationSignalIdV1;
  static const String skillId = act0StartingHandPersonalizationSkillIdV1;

  static Act0StartingHandPersonalizationCaseV1? fromRepairIntent(
    Act0RepairIntentV1 intent,
  ) {
    if (intent.sourceWorldId != worldId ||
        intent.sourceLessonId != sourceLessonId ||
        intent.sourceTaskId != sourceTaskId ||
        intent.errorType != errorType ||
        intent.skillAtomId != skillId ||
        intent.missedSignalId != missedSignalId ||
        intent.targetWorldId != worldId ||
        intent.targetLessonId != repairLessonId ||
        intent.targetTaskId != repairTaskId ||
        intent.mappingType != 'repair') {
      return null;
    }
    return const Act0StartingHandPersonalizationCaseV1();
  }

  static bool isCanonicalSourceTask(String taskId) => taskId == sourceTaskId;
}

class Act0StartingHandPersonalizationCaseV1 {
  const Act0StartingHandPersonalizationCaseV1();

  String get feedbackMappingId => 'w2_hj_kqo_open_feedback_v1';
  String get feedbackFocus =>
      'KQo in HJ is a clean open when the pot is unopened.';
  String get repairStrategyId => 'compare_seat_and_action_frame_v1';
  String get recheckMappingId => 'same_starting_hand_discipline_signal_v1';
  String get cleanPayoffOutcome => 'hand_discipline_read_cleanly';
  String get successfulPayoffOutcome => 'hand_discipline_recovered';
  String get failedRecheckOutcome => 'hand_discipline_still_needs_rep';

  Map<String, Object?> telemetryFields({
    required String attemptPhase,
    required String finalLearningOutcome,
  }) => <String, Object?>{
    'schemaVersion': 1,
    'sequence_id': Act0StartingHandPersonalizationV1.sequenceId,
    'lesson_id': Act0StartingHandPersonalizationV1.sourceLessonId,
    'task_id': Act0StartingHandPersonalizationV1.sourceTaskId,
    'skill_id': Act0StartingHandPersonalizationV1.skillId,
    'error_type': Act0StartingHandPersonalizationV1.errorType,
    'missed_signal_id': Act0StartingHandPersonalizationV1.missedSignalId,
    'attempt_phase': attemptPhase,
    'feedback_mapping_id': feedbackMappingId,
    'repair_strategy': repairStrategyId,
    'recheck_mapping_id': recheckMappingId,
    'final_learning_outcome': finalLearningOutcome,
  };
}
