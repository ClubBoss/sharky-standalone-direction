import 'act0_shell_state_v1.dart';

/// Authored card focus can encode a pair, a draw or the best five before a
/// learner chooses. Assessment displays the cards without that solution layer.
/// This projection does not inspect an option's grade or compute a poker answer.
/// Requested solver help is a separate overlay with assistance provenance.
Act0TableStateV1 act0PredecisionCardFocusV1(
  Act0TableStateV1 table, {
  required bool isActiveAssessment,
}) {
  if (!isActiveAssessment || table.highlightedCardIds.isEmpty) return table;
  return table.copyWith(highlightedCardIds: const <String>[]);
}

/// Current-proof lineage for a changed assessment presentation. Old saved
/// answers remain historical facts; they must not prove today's neutral read.
/// The existing quads guard already removes this focus, so it is unchanged.
String? act0PredecisionCardFocusSourceRevisionV1(Act0LessonTaskV1 task) {
  if (task.entryPhase != Act0LessonPhaseV1.drill ||
      task.runner.options.isEmpty ||
      task.runner.table.highlightedCardIds.isEmpty ||
      task.taskId == 'hand_rankings_quads_drill') {
    return null;
  }
  return 'act0_predecision_card_focus_v1';
}
