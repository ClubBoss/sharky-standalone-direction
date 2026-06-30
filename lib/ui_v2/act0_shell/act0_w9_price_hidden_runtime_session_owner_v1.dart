import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W9PriceHiddenRunKindV1 = 'w9_hidden_runtime_session_owner_v1';
const String act0W9PriceHiddenStartedByV1 =
    'Act0W9PriceHiddenRuntimeSessionOwnerV1';

class Act0W9PriceHiddenRuntimeSessionOwnerV1 {
  const Act0W9PriceHiddenRuntimeSessionOwnerV1();

  Act0W9PriceHiddenTaskSpecV1 get taskSpec => act0W9PriceHiddenTaskSpecV1;
  List<Act0W9PriceHiddenTaskSpecV1> get taskSpecs =>
      act0W9PriceHiddenTaskSpecsV1;

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
      worldId: 'world_9',
      lessonId: 'pot_odds_price_intuition_lite',
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
      worldId: 'world_9',
      lessonId: 'pot_odds_price_intuition_lite',
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
        runKind: act0W9PriceHiddenRunKindV1,
        startedBy: act0W9PriceHiddenStartedByV1,
      ),
    );
  }

  Act0W9PriceHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W9PriceHiddenTaskSpecV1 {
  const Act0W9PriceHiddenTaskSpecV1({
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

const Act0W9PriceHiddenTaskSpecV1 act0W9PriceHiddenTaskSpecV1 =
    Act0W9PriceHiddenTaskSpecV1(
      worldId: 'world_9',
      lessonId: 'pot_odds_price_intuition_lite',
      taskId: 'cheap_call_price_recognition_intro',
      sourceTaskId: 'cheap_call_price_recognition_intro',
      conceptFamilyId: 'w9_price_intuition_call_price',
      repairFocusId: 'w9_cheap_call_price_recognition',
      skillAtomId: 'w9_call_price_size_read',
      errorType: 'missed_cheap_call_price',
      drillKind: 'call_price_size_choice_v1',
      boardContext: 'Large pot with a small call',
      learningPurpose:
          'Recognize when the amount to call is small compared with the pot.',
      expectedChoiceId: 'cheap_call_small_price',
      choiceIds: <String>[
        'cheap_call_small_price',
        'cheap_call_large_price',
        'cheap_call_already_won',
        'cheap_call_exact_result_known',
      ],
      learnerPrompt:
          'The pot is much bigger than the amount to call. What is the safe '
          'price idea?',
      choiceLabels: <String, String>{
        'cheap_call_small_price':
            'The call is a small price compared with the pot.',
        'cheap_call_large_price': 'The call is a large price.',
        'cheap_call_already_won': 'The hand is already won.',
        'cheap_call_exact_result_known': 'The next result is known.',
      },
      feedbackReason:
          'A small call compared with the pot is a cheaper price. It does not '
          'say the call will win; it only describes the price.',
      incorrectFeedback: <String, String>{
        'cheap_call_large_price':
            'Compare the call to the pot before calling it expensive.',
        'cheap_call_already_won':
            'Price describes the call cost, not a locked result.',
        'cheap_call_exact_result_known':
            'The price does not reveal the next card or result.',
      },
      practiceCtaAllowed: false,
      mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
    );

const List<Act0W9PriceHiddenTaskSpecV1>
act0W9PriceHiddenTaskSpecsV1 = <Act0W9PriceHiddenTaskSpecV1>[
  act0W9PriceHiddenTaskSpecV1,
  Act0W9PriceHiddenTaskSpecV1(
    worldId: 'world_9',
    lessonId: 'pot_odds_price_intuition_lite',
    taskId: 'expensive_call_price_recognition_intro',
    sourceTaskId: 'expensive_call_price_recognition_intro',
    conceptFamilyId: 'w9_price_intuition_call_price',
    repairFocusId: 'w9_expensive_call_price_recognition',
    skillAtomId: 'w9_call_price_size_read',
    errorType: 'missed_expensive_call_price',
    drillKind: 'call_price_size_choice_v1',
    boardContext: 'Small pot with a large call',
    learningPurpose:
        'Recognize when the amount to call is large compared with the pot.',
    expectedChoiceId: 'large_call_price',
    choiceIds: <String>[
      'large_call_price',
      'small_call_price',
      'call_is_free',
      'result_is_known',
    ],
    learnerPrompt:
        'The pot is small and the call is large. What is the safe price '
        'idea?',
    choiceLabels: <String, String>{
      'large_call_price': 'The call is a large price compared with the pot.',
      'small_call_price': 'The call is a small price.',
      'call_is_free': 'The call is free.',
      'result_is_known': 'The result is already known.',
    },
    feedbackReason:
        'A large call compared with the pot is an expensive price. That '
        'still does not decide the hand by itself.',
    incorrectFeedback: <String, String>{
      'small_call_price': 'A big call into a small pot is not a cheap price.',
      'call_is_free': 'A call amount still has a cost.',
      'result_is_known':
          'Price helps compare cost; it does not reveal the result.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
  ),
  Act0W9PriceHiddenTaskSpecV1(
    worldId: 'world_9',
    lessonId: 'pot_odds_price_intuition_lite',
    taskId: 'call_price_comparison_lite',
    sourceTaskId: 'call_price_comparison_lite',
    conceptFamilyId: 'w9_price_intuition_call_price',
    repairFocusId: 'w9_call_price_comparison_lite',
    skillAtomId: 'w9_price_comparison',
    errorType: 'missed_call_price_comparison',
    drillKind: 'call_price_comparison_choice_v1',
    boardContext: 'Two different calls into similar pots',
    learningPurpose: 'Compare two call prices using pot-relative cost.',
    expectedChoiceId: 'smaller_call_is_better_price',
    choiceIds: <String>[
      'smaller_call_is_better_price',
      'larger_call_is_better_price',
      'both_prices_same',
      'price_does_not_matter',
    ],
    learnerPrompt:
        'Two spots have similar pots. One call is smaller. Which call has '
        'the better price?',
    choiceLabels: <String, String>{
      'smaller_call_is_better_price': 'The smaller call has the better price.',
      'larger_call_is_better_price': 'The larger call has the better price.',
      'both_prices_same': 'Both prices are the same.',
      'price_does_not_matter': 'The price does not matter.',
    },
    feedbackReason:
        'When pots are similar, the smaller call asks for less and is the '
        'better price.',
    incorrectFeedback: <String, String>{
      'larger_call_is_better_price':
          'A larger call asks you to pay more for a similar pot.',
      'both_prices_same': 'Different call amounts are different prices.',
      'price_does_not_matter': 'The call price is part of the decision signal.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
  ),
  Act0W9PriceHiddenTaskSpecV1(
    worldId: 'world_9',
    lessonId: 'pot_odds_price_intuition_lite',
    taskId: 'better_call_price_transfer_check',
    sourceTaskId: 'better_call_price_transfer_check',
    conceptFamilyId: 'w9_price_intuition_call_price',
    repairFocusId: 'w9_better_price_transfer_check',
    skillAtomId: 'w9_price_transfer_check',
    errorType: 'missed_better_price_transfer',
    drillKind: 'call_price_transfer_choice_v1',
    boardContext: 'Lower call relative to pot vs higher call',
    learningPurpose: 'Transfer the price idea to a fresh call comparison.',
    expectedChoiceId: 'lower_call_relative_to_pot',
    choiceIds: <String>[
      'lower_call_relative_to_pot',
      'higher_call_relative_to_pot',
      'both_spots_are_made_hands',
      'price_predicts_next_card',
    ],
    learnerPrompt:
        'One spot asks for a lower call relative to the pot. Another asks '
        'for a higher call. Which has the better price?',
    choiceLabels: <String, String>{
      'lower_call_relative_to_pot':
          'The lower call relative to the pot has the better price.',
      'higher_call_relative_to_pot':
          'The higher call relative to the pot has the better price.',
      'both_spots_are_made_hands': 'Both spots are made hands.',
      'price_predicts_next_card': 'The price predicts the next card.',
    },
    feedbackReason:
        'A lower call relative to the pot is the better price signal. It '
        'does not predict the next card.',
    incorrectFeedback: <String, String>{
      'higher_call_relative_to_pot':
          'Paying more relative to the pot is a worse price.',
      'both_spots_are_made_hands':
          'The comparison is about call price, not made-hand status.',
      'price_predicts_next_card':
          'Price gives cost context; it does not predict the next card.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
  ),
];
