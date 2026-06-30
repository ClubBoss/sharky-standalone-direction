import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W8DrawsHiddenRunKindV1 = 'w8_hidden_runtime_session_owner_v1';
const String act0W8DrawsHiddenStartedByV1 =
    'Act0W8DrawsHiddenRuntimeSessionOwnerV1';

class Act0W8DrawsHiddenRuntimeSessionOwnerV1 {
  const Act0W8DrawsHiddenRuntimeSessionOwnerV1();

  Act0W8DrawsHiddenTaskSpecV1 get taskSpec => act0W8DrawsHiddenTaskSpecV1;
  List<Act0W8DrawsHiddenTaskSpecV1> get taskSpecs =>
      act0W8DrawsHiddenTaskSpecsV1;

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
      worldId: 'world_8',
      lessonId: 'draws_equity_intuition_lite',
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
      worldId: 'world_8',
      lessonId: 'draws_equity_intuition_lite',
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
        runKind: act0W8DrawsHiddenRunKindV1,
        startedBy: act0W8DrawsHiddenStartedByV1,
      ),
    );
  }

  Act0W8DrawsHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W8DrawsHiddenTaskSpecV1 {
  const Act0W8DrawsHiddenTaskSpecV1({
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

const Act0W8DrawsHiddenTaskSpecV1 act0W8DrawsHiddenTaskSpecV1 =
    Act0W8DrawsHiddenTaskSpecV1(
      worldId: 'world_8',
      lessonId: 'draws_equity_intuition_lite',
      taskId: 'flush_draw_recognition_intro',
      sourceTaskId: 'flush_draw_recognition_intro',
      conceptFamilyId: 'w8_draw_improvement_potential',
      repairFocusId: 'w8_flush_draw_recognition',
      skillAtomId: 'w8_draw_improvement_recognition',
      errorType: 'missed_flush_draw_improvement',
      drillKind: 'draw_improvement_choice_v1',
      boardContext: 'Two cards of the same suit on board',
      learningPurpose: 'Recognize that a flush draw can improve to a flush.',
      expectedChoiceId: 'flush_draw_can_improve',
      choiceIds: <String>[
        'flush_draw_can_improve',
        'flush_draw_no_improvement',
        'flush_draw_already_made',
        'flush_draw_exact_hand_known',
      ],
      learnerPrompt:
          'You hold two hearts and the board has two more hearts. What is the '
          'safe draw idea?',
      choiceLabels: <String, String>{
        'flush_draw_can_improve':
            'More hearts can improve this hand to a flush.',
        'flush_draw_no_improvement': 'More hearts do not matter.',
        'flush_draw_already_made': 'This hand is already a flush.',
        'flush_draw_exact_hand_known': 'The next card is known.',
      },
      feedbackReason:
          'A flush draw is not a made flush yet, but another card of the suit '
          'can improve the hand.',
      incorrectFeedback: <String, String>{
        'flush_draw_no_improvement':
            'Suited future cards can matter when you have a flush draw.',
        'flush_draw_already_made':
            'A draw means the hand can improve later; it is not made yet.',
        'flush_draw_exact_hand_known':
            'The draw shows improvement potential, not the exact next card.',
      },
      practiceCtaAllowed: false,
      mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
    );

const List<Act0W8DrawsHiddenTaskSpecV1>
act0W8DrawsHiddenTaskSpecsV1 = <Act0W8DrawsHiddenTaskSpecV1>[
  act0W8DrawsHiddenTaskSpecV1,
  Act0W8DrawsHiddenTaskSpecV1(
    worldId: 'world_8',
    lessonId: 'draws_equity_intuition_lite',
    taskId: 'open_ended_straight_draw_intro',
    sourceTaskId: 'open_ended_straight_draw_intro',
    conceptFamilyId: 'w8_draw_improvement_potential',
    repairFocusId: 'w8_open_ended_straight_draw_recognition',
    skillAtomId: 'w8_draw_improvement_recognition',
    errorType: 'missed_open_ended_straight_draw',
    drillKind: 'draw_improvement_choice_v1',
    boardContext: '5-6-7-8 shape',
    learningPurpose:
        'Recognize that an open-ended straight draw has several clear '
        'improvement cards.',
    expectedChoiceId: 'straight_draw_multiple_cards',
    choiceIds: <String>[
      'straight_draw_multiple_cards',
      'straight_draw_only_one_card',
      'straight_draw_already_made',
      'straight_draw_no_cards_help',
    ],
    learnerPrompt:
        'Your hand and board line up as 5-6-7-8. What is the safe draw '
        'idea?',
    choiceLabels: <String, String>{
      'straight_draw_multiple_cards':
          'Cards on either end can complete the straight.',
      'straight_draw_only_one_card': 'Only one exact card can help.',
      'straight_draw_already_made': 'The straight is already made.',
      'straight_draw_no_cards_help': 'No future card can help.',
    },
    feedbackReason:
        'An open-ended straight draw can improve from either side of the '
        'sequence, so more than one future card can matter.',
    incorrectFeedback: <String, String>{
      'straight_draw_only_one_card':
          'Open-ended means the sequence can complete from either side.',
      'straight_draw_already_made':
          'This is still a draw if the straight is not complete yet.',
      'straight_draw_no_cards_help':
          'Some future cards can complete this kind of straight draw.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
  ),
  Act0W8DrawsHiddenTaskSpecV1(
    worldId: 'world_8',
    lessonId: 'draws_equity_intuition_lite',
    taskId: 'gutshot_vs_open_ended_comparison_lite',
    sourceTaskId: 'gutshot_vs_open_ended_comparison_lite',
    conceptFamilyId: 'w8_draw_improvement_potential',
    repairFocusId: 'w8_gutshot_open_ended_comparison',
    skillAtomId: 'w8_draw_quality_comparison',
    errorType: 'missed_draw_quality_comparison',
    drillKind: 'draw_comparison_choice_v1',
    boardContext: 'Inside gap vs two-ended straight draw',
    learningPurpose: 'Compare a one-gap straight draw with an open-ended draw.',
    expectedChoiceId: 'open_ended_has_more_clear_improvement',
    choiceIds: <String>[
      'open_ended_has_more_clear_improvement',
      'gutshot_always_has_more_improvement',
      'both_draws_are_made_hands',
      'draw_shape_does_not_matter',
    ],
    learnerPrompt:
        'One straight draw needs one inside card. Another can complete '
        'from either end. Which has more clear improvement potential?',
    choiceLabels: <String, String>{
      'open_ended_has_more_clear_improvement':
          'The open-ended draw has more clear improvement cards.',
      'gutshot_always_has_more_improvement':
          'The inside draw always has more improvement cards.',
      'both_draws_are_made_hands': 'Both are already made hands.',
      'draw_shape_does_not_matter': 'The draw shape does not matter.',
    },
    feedbackReason:
        'A draw that can complete from either end usually has more clear '
        'improvement paths than a one-gap draw.',
    incorrectFeedback: <String, String>{
      'gutshot_always_has_more_improvement':
          'A one-gap draw is narrower than an open-ended draw.',
      'both_draws_are_made_hands':
          'These are still draws, not completed hands.',
      'draw_shape_does_not_matter':
          'The shape matters because it changes how many cards can help.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
  ),
  Act0W8DrawsHiddenTaskSpecV1(
    worldId: 'world_8',
    lessonId: 'draws_equity_intuition_lite',
    taskId: 'draw_improvement_potential_transfer_check',
    sourceTaskId: 'draw_improvement_potential_transfer_check',
    conceptFamilyId: 'w8_draw_improvement_potential',
    repairFocusId: 'w8_draw_improvement_transfer_check',
    skillAtomId: 'w8_draw_transfer_check',
    errorType: 'missed_draw_improvement_transfer',
    drillKind: 'draw_transfer_choice_v1',
    boardContext: 'Flush draw vs no clear draw',
    learningPurpose:
        'Transfer the improvement-potential idea across draw types.',
    expectedChoiceId: 'flush_draw_has_more_improvement_potential',
    choiceIds: <String>[
      'flush_draw_has_more_improvement_potential',
      'no_draw_has_more_improvement_potential',
      'both_spots_are_already_complete',
      'visible_cards_show_next_card',
    ],
    learnerPrompt:
        'One hand has a flush draw. Another has no clear draw. Which has '
        'more visible improvement potential?',
    choiceLabels: <String, String>{
      'flush_draw_has_more_improvement_potential':
          'The flush draw has more visible improvement potential.',
      'no_draw_has_more_improvement_potential':
          'The hand with no clear draw has more improvement potential.',
      'both_spots_are_already_complete': 'Both spots are already complete.',
      'visible_cards_show_next_card': 'The visible cards show the next card.',
    },
    feedbackReason:
        'A clear draw gives the hand visible ways to improve. It still '
        'does not say what the next card will be.',
    incorrectFeedback: <String, String>{
      'no_draw_has_more_improvement_potential':
          'A hand with no clear draw has fewer visible ways to improve.',
      'both_spots_are_already_complete':
          'A draw is not complete yet; it is a path to improvement.',
      'visible_cards_show_next_card':
          'Visible cards help you reason about draws, not predict the '
          'next card.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
  ),
];
