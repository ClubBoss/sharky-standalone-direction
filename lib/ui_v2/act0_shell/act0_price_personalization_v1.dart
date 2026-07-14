import 'package:poker_analyzer/ui_v2/act0_shell/act0_price_personalization_ids_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

/// Typed admission contract for the canonical W4 price-read family. The
/// runner owns the Pot / to call signal; this contract only admits its
/// deterministic feedback, same-signal repair, and local payoff semantics.
class Act0PricePersonalizationV1 {
  static const String sequenceId = act0PricePersonalizationSequenceIdV1;
  static const String worldId = act0PricePersonalizationWorldIdV1;
  static const String lessonId = act0PricePersonalizationLessonIdV1;
  static const String sourceTaskId = act0PricePersonalizationSourceTaskIdV1;
  static const String repairTaskId = act0PricePersonalizationRepairTaskIdV1;
  static const String errorType = act0PricePersonalizationErrorTypeV1;
  static const String missedSignalId = act0PricePersonalizationSignalIdV1;
  static const String skillId = act0PricePersonalizationSkillIdV1;

  static Act0PricePersonalizationCaseV1? fromRepairIntent(
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
    return const Act0PricePersonalizationCaseV1();
  }

  static bool isCanonicalSourceTask(String taskId) => taskId == sourceTaskId;
}

class Act0PricePersonalizationCaseV1 {
  const Act0PricePersonalizationCaseV1();

  String get feedbackMappingId => 'w4_high_price_fold_feedback_v1';
  String get feedbackFocus =>
      'Compare Pot 8 BB with To call 7 BB before you decide.';
  String get repairStrategyId => 'compare_pot_to_call_then_choose_v1';
  String get recheckMappingId => 'same_pot_to_call_signal_v1';
  String get successfulPayoffOutcome => 'price_signal_recovered';
  String get failedRecheckOutcome => 'price_signal_still_needs_rep';
  String get cleanPayoffOutcome => 'price_signal_read_cleanly';

  Map<String, Object?> telemetryFields({
    required String attemptPhase,
    required String finalLearningOutcome,
  }) => <String, Object?>{
    'schemaVersion': 1,
    'sequence_id': Act0PricePersonalizationV1.sequenceId,
    'lesson_id': Act0PricePersonalizationV1.lessonId,
    'task_id': Act0PricePersonalizationV1.sourceTaskId,
    'skill_id': Act0PricePersonalizationV1.skillId,
    'error_type': Act0PricePersonalizationV1.errorType,
    'missed_signal_id': Act0PricePersonalizationV1.missedSignalId,
    'attempt_phase': attemptPhase,
    'feedback_mapping_id': feedbackMappingId,
    'repair_strategy': repairStrategyId,
    'recheck_mapping_id': recheckMappingId,
    'final_learning_outcome': finalLearningOutcome,
  };
}
