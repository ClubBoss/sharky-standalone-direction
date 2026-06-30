import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W12ReviewDecisionHiddenRunKindV1 =
    'w12_hidden_runtime_session_owner_v1';
const String act0W12ReviewDecisionHiddenStartedByV1 =
    'Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1';

class Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1 {
  const Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1();

  Act0W12ReviewDecisionHiddenTaskSpecV1 get taskSpec =>
      act0W12ReviewDecisionHiddenTaskSpecV1;
  List<Act0W12ReviewDecisionHiddenTaskSpecV1> get taskSpecs =>
      act0W12ReviewDecisionHiddenTaskSpecsV1;

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
      worldId: 'world_12',
      lessonId: 'review_decision_intuition_lite',
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
      worldId: 'world_12',
      lessonId: 'review_decision_intuition_lite',
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
        runKind: act0W12ReviewDecisionHiddenRunKindV1,
        startedBy: act0W12ReviewDecisionHiddenStartedByV1,
      ),
    );
  }

  Act0W12ReviewDecisionHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W12ReviewDecisionHiddenTaskSpecV1 {
  const Act0W12ReviewDecisionHiddenTaskSpecV1({
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

const Act0W12ReviewDecisionHiddenTaskSpecV1
act0W12ReviewDecisionHiddenTaskSpecV1 = Act0W12ReviewDecisionHiddenTaskSpecV1(
  worldId: 'world_12',
  lessonId: 'review_decision_intuition_lite',
  taskId: 'main_clue_identification_intro',
  sourceTaskId: 'main_clue_identification_intro',
  conceptFamilyId: 'w12_review_decision_intuition',
  repairFocusId: 'w12_main_clue_identification',
  skillAtomId: 'w12_spot_clue_read',
  errorType: 'missed_main_clue_identification',
  drillKind: 'review_clue_choice_v1',
  boardContext: 'Review spot with one clear board-texture clue',
  learningPurpose: 'Identify the main clue before choosing an explanation.',
  expectedChoiceId: 'board_texture_clue',
  choiceIds: <String>[
    'board_texture_clue',
    'bet_purpose_clue',
    'price_clue',
    'result_already_known',
  ],
  learnerPrompt:
      'In this review spot, the board is connected and suited. What is '
      'the main clue to start with?',
  choiceLabels: <String, String>{
    'board_texture_clue': 'Start with the board texture clue.',
    'bet_purpose_clue': 'Start with bet purpose only.',
    'price_clue': 'Start with call price only.',
    'result_already_known': 'The result is already known.',
  },
  feedbackReason:
      'The connected and suited board is the main first clue. It helps '
      'frame the decision without deciding the result.',
  incorrectFeedback: <String, String>{
    'bet_purpose_clue':
        'Bet purpose can matter, but this spot first points at texture.',
    'price_clue': 'Price can matter, but the clear clue here is board texture.',
    'result_already_known':
        'A review clue explains the spot; it does not make the result '
        'known.',
  },
  practiceCtaAllowed: false,
  mapperNoTargetReason: 'w12_route_locked_no_safe_practice_target_v1',
);

const List<Act0W12ReviewDecisionHiddenTaskSpecV1>
act0W12ReviewDecisionHiddenTaskSpecsV1 =
    <Act0W12ReviewDecisionHiddenTaskSpecV1>[
      act0W12ReviewDecisionHiddenTaskSpecV1,
      Act0W12ReviewDecisionHiddenTaskSpecV1(
        worldId: 'world_12',
        lessonId: 'review_decision_intuition_lite',
        taskId: 'turn_card_change_recognition_intro',
        sourceTaskId: 'turn_card_change_recognition_intro',
        conceptFamilyId: 'w12_review_decision_intuition',
        repairFocusId: 'w12_turn_card_change_recognition',
        skillAtomId: 'w12_turn_change_read',
        errorType: 'missed_turn_card_change',
        drillKind: 'review_turn_change_choice_v1',
        boardContext: 'Turn card completes a visible draw path',
        learningPurpose:
            'Identify what changed when a new card altered the texture.',
        expectedChoiceId: 'turn_added_draw_pressure',
        choiceIds: <String>[
          'turn_added_draw_pressure',
          'turn_changed_nothing',
          'turn_set_final_result',
          'preflop_action_only_matters',
        ],
        learnerPrompt:
            'The turn card adds a third suited card. What changed in the '
            'spot?',
        choiceLabels: <String, String>{
          'turn_added_draw_pressure': 'The turn added more flush pressure.',
          'turn_changed_nothing': 'The turn changed nothing.',
          'turn_set_final_result': 'The turn set the final result.',
          'preflop_action_only_matters': 'Only the preflop action matters.',
        },
        feedbackReason:
            'A new suited card can change the texture by adding flush '
            'pressure. It is a clue, not a final answer.',
        incorrectFeedback: <String, String>{
          'turn_changed_nothing':
              'A new suited card can materially change the board texture.',
          'turn_set_final_result':
              'The new card changes the clue, not the known result.',
          'preflop_action_only_matters':
              'Earlier action matters, but the new card also changes the read.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w12_route_locked_no_safe_practice_target_v1',
      ),
      Act0W12ReviewDecisionHiddenTaskSpecV1(
        worldId: 'world_12',
        lessonId: 'review_decision_intuition_lite',
        taskId: 'safe_beginner_explanation_choice_lite',
        sourceTaskId: 'safe_beginner_explanation_choice_lite',
        conceptFamilyId: 'w12_review_decision_intuition',
        repairFocusId: 'w12_safe_beginner_explanation_choice',
        skillAtomId: 'w12_explanation_choice_read',
        errorType: 'missed_safe_beginner_explanation',
        drillKind: 'review_explanation_choice_v1',
        boardContext: 'Spot with action and texture clues',
        learningPurpose:
            'Choose a simple explanation that uses visible clues without '
            'overclaiming.',
        expectedChoiceId: 'simple_clues_explain_caution',
        choiceIds: <String>[
          'simple_clues_explain_caution',
          'one_clue_solves_everything',
          'ignore_board_and_action',
          'answer_is_known_before_choice',
        ],
        learnerPrompt:
            'A connected board and a strong bet both appear. Which explanation '
            'is safest?',
        choiceLabels: <String, String>{
          'simple_clues_explain_caution':
              'The visible clues explain why caution is reasonable.',
          'one_clue_solves_everything': 'One clue solves the whole spot.',
          'ignore_board_and_action': 'Ignore the board and the action.',
          'answer_is_known_before_choice': 'The answer is known before choice.',
        },
        feedbackReason:
            'A safe explanation combines visible clues and stays modest about '
            'what they prove.',
        incorrectFeedback: <String, String>{
          'one_clue_solves_everything':
              'One clue rarely explains every part of a spot.',
          'ignore_board_and_action':
              'Board and action clues are both useful in a review.',
          'answer_is_known_before_choice':
              'A review explanation should not claim the answer is known.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w12_route_locked_no_safe_practice_target_v1',
      ),
      Act0W12ReviewDecisionHiddenTaskSpecV1(
        worldId: 'world_12',
        lessonId: 'review_decision_intuition_lite',
        taskId: 'combined_decision_read_transfer_check',
        sourceTaskId: 'combined_decision_read_transfer_check',
        conceptFamilyId: 'w12_review_decision_intuition',
        repairFocusId: 'w12_combined_decision_read_transfer',
        skillAtomId: 'w12_combined_read_transfer',
        errorType: 'missed_combined_decision_read_transfer',
        drillKind: 'review_transfer_choice_v1',
        boardContext: 'Texture, draw, price, and purpose clues together',
        learningPurpose:
            'Transfer the review habit by combining several simple clues.',
        expectedChoiceId: 'combine_texture_draw_price_purpose',
        choiceIds: <String>[
          'combine_texture_draw_price_purpose',
          'use_only_last_card',
          'ignore_bet_purpose',
          'call_price_predicts_result',
        ],
        learnerPrompt:
            'A spot has board texture, draw pressure, call price, and bet '
            'purpose clues. What is the safest review read?',
        choiceLabels: <String, String>{
          'combine_texture_draw_price_purpose':
              'Combine the simple clues into one cautious read.',
          'use_only_last_card': 'Use only the last card.',
          'ignore_bet_purpose': 'Ignore the bet purpose.',
          'call_price_predicts_result': 'Call price predicts the result.',
        },
        feedbackReason:
            'A good review read combines the visible clues without claiming '
            'that any single clue decides the spot.',
        incorrectFeedback: <String, String>{
          'use_only_last_card':
              'The last card matters, but it is not the only clue.',
          'ignore_bet_purpose': 'Bet purpose can help explain the action.',
          'call_price_predicts_result':
              'Call price gives cost context; it does not predict the result.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w12_route_locked_no_safe_practice_target_v1',
      ),
    ];
