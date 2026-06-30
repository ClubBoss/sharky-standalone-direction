import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W10BetPurposeHiddenRunKindV1 =
    'w10_hidden_runtime_session_owner_v1';
const String act0W10BetPurposeHiddenStartedByV1 =
    'Act0W10BetPurposeHiddenRuntimeSessionOwnerV1';

class Act0W10BetPurposeHiddenRuntimeSessionOwnerV1 {
  const Act0W10BetPurposeHiddenRuntimeSessionOwnerV1();

  Act0W10BetPurposeHiddenTaskSpecV1 get taskSpec =>
      act0W10BetPurposeHiddenTaskSpecV1;
  List<Act0W10BetPurposeHiddenTaskSpecV1> get taskSpecs =>
      act0W10BetPurposeHiddenTaskSpecsV1;

  Object? get practiceLaunchRequest => null;

  bool supports({
    required String worldId,
    required String lessonId,
    required String taskId,
  }) {
    return _taskSpecFor(worldId: worldId, lessonId: lessonId, taskId: taskId) !=
        null;
  }

  Act0CompletedDecisionV1 completedDecisionForChoice({
    String? taskId,
    required String selectedChoiceId,
    required String attemptKey,
    required String decisionTimeBucket,
  }) {
    final spec = _taskSpecFor(
      worldId: 'world_10',
      lessonId: 'value_bluff_intuition_lite',
      taskId: taskId ?? taskSpec.taskId,
    );
    if (spec == null) {
      throw ArgumentError.value(taskId ?? taskSpec.taskId, 'taskId');
    }
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
    String? taskId,
    required String selectedChoiceId,
    required String attemptKey,
    required String decisionTimeBucket,
  }) {
    final spec = _taskSpecFor(
      worldId: 'world_10',
      lessonId: 'value_bluff_intuition_lite',
      taskId: taskId ?? taskSpec.taskId,
    );
    if (spec == null) {
      throw ArgumentError.value(taskId ?? taskSpec.taskId, 'taskId');
    }
    return history.appendCompletedDecision(
      completedDecisionForChoice(
        taskId: spec.taskId,
        selectedChoiceId: selectedChoiceId,
        attemptKey: attemptKey,
        decisionTimeBucket: decisionTimeBucket,
      ),
      runKey: Act0EvidenceRunKeyV1(
        runId: '${spec.taskId}|hidden_v1',
        worldId: spec.worldId,
        lessonId: spec.lessonId,
        runOrdinal: 1,
        runKind: act0W10BetPurposeHiddenRunKindV1,
        startedBy: act0W10BetPurposeHiddenStartedByV1,
      ),
    );
  }

  Act0W10BetPurposeHiddenTaskSpecV1? _taskSpecFor({
    required String worldId,
    required String lessonId,
    required String taskId,
  }) {
    final cleanWorldId = worldId.trim();
    final cleanLessonId = lessonId.trim();
    final cleanTaskId = taskId.trim();
    for (final spec in taskSpecs) {
      if (spec.worldId == cleanWorldId &&
          spec.lessonId == cleanLessonId &&
          spec.taskId == cleanTaskId) {
        return spec;
      }
    }
    return null;
  }
}

class Act0W10BetPurposeHiddenTaskSpecV1 {
  const Act0W10BetPurposeHiddenTaskSpecV1({
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
    required this.learningPurpose,
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
  final String learningPurpose;
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

const Act0W10BetPurposeHiddenTaskSpecV1
act0W10BetPurposeHiddenTaskSpecV1 = Act0W10BetPurposeHiddenTaskSpecV1(
  worldId: 'world_10',
  lessonId: 'value_bluff_intuition_lite',
  taskId: 'clear_value_bet_recognition_intro',
  sourceTaskId: 'clear_value_bet_recognition_intro',
  conceptFamilyId: 'w10_bet_purpose_value_bluff',
  repairFocusId: 'w10_clear_value_bet_recognition',
  skillAtomId: 'w10_bet_purpose_value_read',
  errorType: 'missed_clear_value_bet',
  drillKind: 'bet_purpose_choice_v1',
  boardContext: 'Strong made hand against weaker calls',
  learningPurpose:
      'Recognize a bet whose main purpose is getting called by worse hands.',
  expectedChoiceId: 'bet_for_value_called_by_worse',
  choiceIds: <String>[
    'bet_for_value_called_by_worse',
    'bet_to_make_better_fold',
    'bet_has_no_purpose',
    'bet_result_known',
  ],
  learnerPrompt:
      'You have a strong made hand and expect worse hands to call. What is '
      'the safest bet-purpose read?',
  choiceLabels: <String, String>{
    'bet_for_value_called_by_worse':
        'The bet is mainly for worse hands to call.',
    'bet_to_make_better_fold': 'The bet is mainly to make better hands fold.',
    'bet_has_no_purpose': 'The bet has no purpose.',
    'bet_result_known': 'The result is already known.',
  },
  feedbackReason:
      'A value bet is mainly about getting called by worse hands. It does not '
      'prove the result in advance.',
  incorrectFeedback: <String, String>{
    'bet_to_make_better_fold':
        'With a strong hand and worse calls available, the main purpose is '
        'value.',
    'bet_has_no_purpose': 'A bet can have a clear value purpose.',
    'bet_result_known':
        'The purpose of the bet does not make the result known.',
  },
  practiceCtaAllowed: false,
  mapperNoTargetReason: 'w10_route_locked_no_safe_practice_target_v1',
);

const List<Act0W10BetPurposeHiddenTaskSpecV1>
act0W10BetPurposeHiddenTaskSpecsV1 = <Act0W10BetPurposeHiddenTaskSpecV1>[
  act0W10BetPurposeHiddenTaskSpecV1,
  Act0W10BetPurposeHiddenTaskSpecV1(
    worldId: 'world_10',
    lessonId: 'value_bluff_intuition_lite',
    taskId: 'clear_bluff_intention_recognition_intro',
    sourceTaskId: 'clear_bluff_intention_recognition_intro',
    conceptFamilyId: 'w10_bet_purpose_value_bluff',
    repairFocusId: 'w10_clear_bluff_intention_recognition',
    skillAtomId: 'w10_bet_purpose_bluff_read',
    errorType: 'missed_clear_bluff_intention',
    drillKind: 'bet_purpose_choice_v1',
    boardContext: 'Weak hand trying to make stronger hands fold',
    learningPurpose:
        'Recognize a bet whose main purpose is making stronger hands fold.',
    expectedChoiceId: 'bet_to_make_stronger_hands_fold',
    choiceIds: <String>[
      'bet_to_make_stronger_hands_fold',
      'bet_for_worse_to_call',
      'bet_already_won',
      'bet_shows_exact_hand',
    ],
    learnerPrompt:
        'You have little showdown strength and are betting to pressure '
        'stronger hands. What is the safest purpose read?',
    choiceLabels: <String, String>{
      'bet_to_make_stronger_hands_fold':
          'The bet is mainly to make stronger hands fold.',
      'bet_for_worse_to_call': 'The bet is mainly for worse hands to call.',
      'bet_already_won': 'The hand is already won.',
      'bet_shows_exact_hand': 'The bet reveals the exact hand.',
    },
    feedbackReason:
        'A bluff-purpose bet is mainly about pressuring stronger hands to '
        'fold. It still does not guarantee that stronger hands fold.',
    incorrectFeedback: <String, String>{
      'bet_for_worse_to_call':
          'With little showdown strength, worse calls are not the main value '
          'story.',
      'bet_already_won':
          'A pressure bet is not the same as already winning the hand.',
      'bet_shows_exact_hand': 'A bet purpose does not reveal the exact cards.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w10_route_locked_no_safe_practice_target_v1',
  ),
  Act0W10BetPurposeHiddenTaskSpecV1(
    worldId: 'world_10',
    lessonId: 'value_bluff_intuition_lite',
    taskId: 'thin_value_caution_lite',
    sourceTaskId: 'thin_value_caution_lite',
    conceptFamilyId: 'w10_bet_purpose_value_bluff',
    repairFocusId: 'w10_thin_value_caution_lite',
    skillAtomId: 'w10_bet_purpose_caution',
    errorType: 'missed_thin_value_caution',
    drillKind: 'bet_purpose_caution_choice_v1',
    boardContext: 'Medium hand with unclear worse calls',
    learningPurpose:
        'Recognize when a value bet is close because worse calls are unclear.',
    expectedChoiceId: 'worse_calls_are_unclear',
    choiceIds: <String>[
      'worse_calls_are_unclear',
      'many_worse_hands_clearly_call',
      'bet_must_be_bluff',
      'purpose_does_not_matter',
    ],
    learnerPrompt:
        'You have a medium hand, and it is unclear how many worse hands call. '
        'What is the safest purpose read?',
    choiceLabels: <String, String>{
      'worse_calls_are_unclear':
          'The value case is close because worse calls are unclear.',
      'many_worse_hands_clearly_call': 'Many worse hands clearly call.',
      'bet_must_be_bluff': 'The bet must only try to make stronger hands fold.',
      'purpose_does_not_matter': 'The bet purpose does not matter.',
    },
    feedbackReason:
        'A close value spot means worse calls are not obvious. The safest read '
        'is caution, not a forced value or pressure label.',
    incorrectFeedback: <String, String>{
      'many_worse_hands_clearly_call':
          'If worse calls are unclear, the value case is close.',
      'bet_must_be_bluff':
          'Unclear value does not automatically make the bet pure pressure.',
      'purpose_does_not_matter':
          'Purpose matters because it explains what the bet is trying to do.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w10_route_locked_no_safe_practice_target_v1',
  ),
  Act0W10BetPurposeHiddenTaskSpecV1(
    worldId: 'world_10',
    lessonId: 'value_bluff_intuition_lite',
    taskId: 'bet_purpose_transfer_check',
    sourceTaskId: 'bet_purpose_transfer_check',
    conceptFamilyId: 'w10_bet_purpose_value_bluff',
    repairFocusId: 'w10_bet_purpose_transfer_check',
    skillAtomId: 'w10_bet_purpose_transfer',
    errorType: 'missed_bet_purpose_transfer',
    drillKind: 'bet_purpose_transfer_choice_v1',
    boardContext:
        'Compare value purpose with pressure to make stronger hands fold',
    learningPurpose:
        'Transfer the value-versus-pressure purpose read across spots.',
    expectedChoiceId: 'main_purpose_value_or_fold_pressure',
    choiceIds: <String>[
      'main_purpose_value_or_fold_pressure',
      'bet_size_predicts_result',
      'all_bets_have_same_purpose',
      'answer_already_known',
    ],
    learnerPrompt:
        'In a new betting spot, what is the safest first question about the '
        'bet?',
    choiceLabels: <String, String>{
      'main_purpose_value_or_fold_pressure':
          'Ask whether the main purpose is value or making stronger hands fold.',
      'bet_size_predicts_result': 'The bet size predicts the result.',
      'all_bets_have_same_purpose': 'All bets have the same purpose.',
      'answer_already_known': 'The answer is already known.',
    },
    feedbackReason:
        'The first purpose question is whether the bet mainly wants worse '
        'calls or stronger folds.',
    incorrectFeedback: <String, String>{
      'bet_size_predicts_result':
          'Bet size can inform a read, but it does not predict the result.',
      'all_bets_have_same_purpose':
          'Different bets can have different purposes.',
      'answer_already_known':
          'A purpose read is a decision signal, not a known answer.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w10_route_locked_no_safe_practice_target_v1',
  ),
];
