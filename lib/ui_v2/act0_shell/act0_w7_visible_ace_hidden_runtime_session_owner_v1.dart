import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W7VisibleAceHiddenRunKindV1 =
    'w7_hidden_runtime_session_owner_v1';
const String act0W7VisibleAceHiddenStartedByV1 =
    'Act0W7VisibleAceHiddenRuntimeSessionOwnerV1';

class Act0W7VisibleAceHiddenRuntimeSessionOwnerV1 {
  const Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();

  Act0W7VisibleAceHiddenTaskSpecV1 get taskSpec =>
      act0W7VisibleAceHiddenTaskSpecV1;

  Object? get practiceLaunchRequest => null;

  bool supports({
    required String worldId,
    required String lessonId,
    required String taskId,
  }) {
    final spec = taskSpec;
    return worldId.trim() == spec.worldId &&
        lessonId.trim() == spec.lessonId &&
        taskId.trim() == spec.taskId;
  }

  Act0CompletedDecisionV1 completedDecisionForChoice({
    required String selectedChoiceId,
    required String attemptKey,
    required String decisionTimeBucket,
  }) {
    final spec = taskSpec;
    final choiceId = selectedChoiceId.trim();
    if (!spec.choiceIds.contains(choiceId)) {
      throw ArgumentError.value(selectedChoiceId, 'selectedChoiceId');
    }
    final isCorrect = choiceId == spec.expectedChoiceId;
    return Act0CompletedDecisionV1(
      attemptKey: attemptKey.trim(),
      worldId: spec.worldId,
      lessonId: spec.lessonId,
      taskId: spec.taskId,
      sourceTaskId: spec.sourceTaskId,
      decisionKind: Act0CompletedDecisionKindV1.actionList,
      selectedId: choiceId,
      expectedId: spec.expectedChoiceId,
      isCorrect: isCorrect,
      decisionTimeBucket: decisionTimeBucket.trim(),
      taskFamily: null,
      resultKind: isCorrect ? 'correct' : 'incorrect',
      conceptFamilyId: spec.conceptFamilyId,
      errorType: isCorrect ? 'none' : spec.errorType,
      skillAtomId: spec.skillAtomId,
      repairFocusId: spec.repairFocusId,
      missedSignalId: spec.repairFocusId,
    );
  }

  Act0LearningEvidenceHistoryV1 appendChoiceEvidence({
    required Act0LearningEvidenceHistoryV1 history,
    required String selectedChoiceId,
    required String attemptKey,
    required String decisionTimeBucket,
  }) {
    final spec = taskSpec;
    return history.appendCompletedDecision(
      completedDecisionForChoice(
        selectedChoiceId: selectedChoiceId,
        attemptKey: attemptKey,
        decisionTimeBucket: decisionTimeBucket,
      ),
      runKey: Act0EvidenceRunKeyV1(
        runId: '${spec.taskId}|hidden_v1',
        worldId: spec.worldId,
        lessonId: spec.lessonId,
        runOrdinal: 1,
        runKind: act0W7VisibleAceHiddenRunKindV1,
        startedBy: act0W7VisibleAceHiddenStartedByV1,
      ),
    );
  }
}

class Act0W7VisibleAceHiddenTaskSpecV1 {
  const Act0W7VisibleAceHiddenTaskSpecV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.sourceTaskId,
    required this.conceptFamilyId,
    required this.repairFocusId,
    required this.skillAtomId,
    required this.errorType,
    required this.drillKind,
    required this.boardContext,
    required this.expectedChoiceId,
    required this.choiceIds,
    required this.learnerPrompt,
    required this.choiceLabels,
    required this.feedbackReason,
    required this.incorrectFeedback,
    required this.practiceCtaAllowed,
    required this.mapperNoTargetReason,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final String sourceTaskId;
  final String conceptFamilyId;
  final String repairFocusId;
  final String skillAtomId;
  final String errorType;
  final String drillKind;
  final String boardContext;
  final String expectedChoiceId;
  final List<String> choiceIds;
  final String learnerPrompt;
  final Map<String, String> choiceLabels;
  final String feedbackReason;
  final Map<String, String> incorrectFeedback;
  final bool practiceCtaAllowed;
  final String mapperNoTargetReason;

  Map<String, Object?> get copySafetyPayload => <String, Object?>{
    'learnerPrompt': learnerPrompt,
    'choiceLabels': choiceLabels,
    'feedbackReason': feedbackReason,
    'incorrectFeedback': incorrectFeedback,
  };
}

const Act0W7VisibleAceHiddenTaskSpecV1 act0W7VisibleAceHiddenTaskSpecV1 =
    Act0W7VisibleAceHiddenTaskSpecV1(
      worldId: 'world_7',
      lessonId: 'range_thinking_lite_combo_density',
      taskId: 'visible_ace_combo_reduction_intro',
      sourceTaskId: 'visible_ace_combo_reduction_intro',
      conceptFamilyId: 'w7_combo_density_visible_card_removal',
      repairFocusId: 'w7_visible_card_combo_reduction',
      skillAtomId: 'w7_combo_density_card_removal',
      errorType: 'missed_visible_card_combo_reduction',
      drillKind: 'combo_density_visible_card_choice_v1',
      boardContext: 'A72 rainbow',
      expectedChoiceId: 'ace_combos_reduced',
      choiceIds: <String>[
        'ace_combos_reduced',
        'ace_combos_unchanged',
        'ace_combos_guaranteed',
        'ace_combos_impossible',
      ],
      learnerPrompt:
          'An ace is already visible on A72 rainbow. What does that do to '
          "ace-containing hands in the opponent's possible range?",
      choiceLabels: <String, String>{
        'ace_combos_reduced':
            'There are fewer ace-containing combinations left.',
        'ace_combos_unchanged':
            'The visible ace does not change the number of ace combinations.',
        'ace_combos_guaranteed': 'The opponent must have an ace.',
        'ace_combos_impossible': 'The opponent can never have an ace.',
      },
      feedbackReason:
          'One ace is already visible, so fewer ace-containing combinations '
          'remain possible. This does not tell us the exact hand; it only '
          'changes how many hands are available.',
      incorrectFeedback: <String, String>{
        'ace_combos_unchanged':
            'Visible cards are unavailable to private hands, so the number of '
            'possible ace-containing hands changes.',
        'ace_combos_guaranteed':
            'A visible ace reduces possible ace-containing hands; it does not '
            'prove the opponent has one.',
        'ace_combos_impossible':
            'One visible ace reduces ace-containing hands, but some '
            'ace-containing hands can still exist.',
      },
      practiceCtaAllowed: false,
      mapperNoTargetReason: 'w7_route_locked_no_safe_practice_target_v1',
    );
