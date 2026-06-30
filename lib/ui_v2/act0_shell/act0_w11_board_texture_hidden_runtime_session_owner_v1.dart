import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W11BoardTextureHiddenRunKindV1 =
    'w11_hidden_runtime_session_owner_v1';
const String act0W11BoardTextureHiddenStartedByV1 =
    'Act0W11BoardTextureHiddenRuntimeSessionOwnerV1';

class Act0W11BoardTextureHiddenRuntimeSessionOwnerV1 {
  const Act0W11BoardTextureHiddenRuntimeSessionOwnerV1();

  Act0W11BoardTextureHiddenTaskSpecV1 get taskSpec =>
      act0W11BoardTextureHiddenTaskSpecV1;
  List<Act0W11BoardTextureHiddenTaskSpecV1> get taskSpecs =>
      act0W11BoardTextureHiddenTaskSpecsV1;

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
      worldId: 'world_11',
      lessonId: 'board_texture_danger_awareness_lite',
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
      worldId: 'world_11',
      lessonId: 'board_texture_danger_awareness_lite',
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
        runKind: act0W11BoardTextureHiddenRunKindV1,
        startedBy: act0W11BoardTextureHiddenStartedByV1,
      ),
    );
  }

  Act0W11BoardTextureHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W11BoardTextureHiddenTaskSpecV1 {
  const Act0W11BoardTextureHiddenTaskSpecV1({
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

const Act0W11BoardTextureHiddenTaskSpecV1
act0W11BoardTextureHiddenTaskSpecV1 = Act0W11BoardTextureHiddenTaskSpecV1(
  worldId: 'world_11',
  lessonId: 'board_texture_danger_awareness_lite',
  taskId: 'dry_board_texture_recognition_intro',
  sourceTaskId: 'dry_board_texture_recognition_intro',
  conceptFamilyId: 'w11_board_texture_danger_awareness',
  repairFocusId: 'w11_dry_board_texture_recognition',
  skillAtomId: 'w11_board_texture_read',
  errorType: 'missed_dry_board_texture',
  drillKind: 'board_texture_choice_v1',
  boardContext: 'Unpaired rainbow board with wide gaps',
  learningPurpose:
      'Recognize a board with fewer obvious draws and fewer connections.',
  expectedChoiceId: 'dry_board_fewer_clear_connections',
  choiceIds: <String>[
    'dry_board_fewer_clear_connections',
    'connected_board_more_dangerous',
    'suited_board_flush_pressure',
    'board_result_known',
  ],
  learnerPrompt:
      'The board is rainbow and the ranks are far apart. What is the safest '
      'texture read?',
  choiceLabels: <String, String>{
    'dry_board_fewer_clear_connections':
        'It is a drier board with fewer clear connections.',
    'connected_board_more_dangerous':
        'It is highly connected and more dangerous.',
    'suited_board_flush_pressure': 'It has clear flush pressure.',
    'board_result_known': 'The board makes the result known.',
  },
  feedbackReason:
      'A dry board has fewer obvious straight or flush paths. That makes the '
      'texture less coordinated, not decided.',
  incorrectFeedback: <String, String>{
    'connected_board_more_dangerous':
        'Far-apart ranks usually create fewer straight connections.',
    'suited_board_flush_pressure':
        'A rainbow board does not show a clear flush-pressure pattern.',
    'board_result_known': 'Board texture is a clue, not a known result.',
  },
  practiceCtaAllowed: false,
  mapperNoTargetReason: 'w11_route_locked_no_safe_practice_target_v1',
);

const List<Act0W11BoardTextureHiddenTaskSpecV1>
act0W11BoardTextureHiddenTaskSpecsV1 = <Act0W11BoardTextureHiddenTaskSpecV1>[
  act0W11BoardTextureHiddenTaskSpecV1,
  Act0W11BoardTextureHiddenTaskSpecV1(
    worldId: 'world_11',
    lessonId: 'board_texture_danger_awareness_lite',
    taskId: 'connected_board_texture_recognition_intro',
    sourceTaskId: 'connected_board_texture_recognition_intro',
    conceptFamilyId: 'w11_board_texture_danger_awareness',
    repairFocusId: 'w11_connected_board_texture_recognition',
    skillAtomId: 'w11_board_connection_read',
    errorType: 'missed_connected_board_texture',
    drillKind: 'board_texture_choice_v1',
    boardContext: 'Middle connected ranks',
    learningPurpose:
        'Recognize that connected ranks can create more straight paths.',
    expectedChoiceId: 'connected_cards_create_more_paths',
    choiceIds: <String>[
      'connected_cards_create_more_paths',
      'dry_board_safer_texture',
      'suit_pattern_only_matters',
      'rank_connection_never_matters',
    ],
    learnerPrompt:
        'The board cards sit close together in rank. What is the safest '
        'texture read?',
    choiceLabels: <String, String>{
      'connected_cards_create_more_paths':
          'Connected ranks can create more straight paths.',
      'dry_board_safer_texture': 'The board is dry and disconnected.',
      'suit_pattern_only_matters': 'Only the suits matter.',
      'rank_connection_never_matters': 'Rank connection never matters.',
    },
    feedbackReason:
        'Connected ranks can interact with more hands because straight paths '
        'are easier to imagine.',
    incorrectFeedback: <String, String>{
      'dry_board_safer_texture':
          'Close ranks are more connected than far-apart ranks.',
      'suit_pattern_only_matters':
          'Suits matter, but rank connection is also a board clue.',
      'rank_connection_never_matters':
          'Ranks matter when they create straight paths.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w11_route_locked_no_safe_practice_target_v1',
  ),
  Act0W11BoardTextureHiddenTaskSpecV1(
    worldId: 'world_11',
    lessonId: 'board_texture_danger_awareness_lite',
    taskId: 'suited_texture_pressure_lite',
    sourceTaskId: 'suited_texture_pressure_lite',
    conceptFamilyId: 'w11_board_texture_danger_awareness',
    repairFocusId: 'w11_suited_texture_pressure_lite',
    skillAtomId: 'w11_suit_texture_read',
    errorType: 'missed_suited_texture_pressure',
    drillKind: 'board_texture_suit_choice_v1',
    boardContext: 'Two or three cards sharing a suit',
    learningPurpose:
        'Recognize when suited board cards create flush-draw or flush pressure.',
    expectedChoiceId: 'suited_cards_add_flush_pressure',
    choiceIds: <String>[
      'suited_cards_add_flush_pressure',
      'rainbow_board_more_flush_pressure',
      'suits_do_not_matter',
      'flush_result_already_known',
    ],
    learnerPrompt:
        'Two or more board cards share a suit. What is the safest texture '
        'read?',
    choiceLabels: <String, String>{
      'suited_cards_add_flush_pressure': 'Shared suits can add flush pressure.',
      'rainbow_board_more_flush_pressure':
          'A rainbow board has more flush pressure.',
      'suits_do_not_matter': 'Suits do not matter for texture.',
      'flush_result_already_known': 'The flush result is already known.',
    },
    feedbackReason:
        'Shared suits can add flush pressure. The clue is pressure, not a '
        'known final hand.',
    incorrectFeedback: <String, String>{
      'rainbow_board_more_flush_pressure':
          'Rainbow boards usually show less immediate flush pressure.',
      'suits_do_not_matter': 'Suits can be an important texture clue.',
      'flush_result_already_known':
          'A suited texture can create pressure without deciding the result.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w11_route_locked_no_safe_practice_target_v1',
  ),
  Act0W11BoardTextureHiddenTaskSpecV1(
    worldId: 'world_11',
    lessonId: 'board_texture_danger_awareness_lite',
    taskId: 'one_pair_board_danger_transfer_check',
    sourceTaskId: 'one_pair_board_danger_transfer_check',
    conceptFamilyId: 'w11_board_texture_danger_awareness',
    repairFocusId: 'w11_one_pair_board_danger_transfer',
    skillAtomId: 'w11_texture_transfer_check',
    errorType: 'missed_one_pair_board_danger_transfer',
    drillKind: 'board_texture_transfer_choice_v1',
    boardContext: 'One pair on dry board vs coordinated board',
    learningPurpose:
        'Transfer texture awareness to a one-pair danger comparison.',
    expectedChoiceId: 'coordinated_board_more_danger_for_one_pair',
    choiceIds: <String>[
      'coordinated_board_more_danger_for_one_pair',
      'dry_board_more_danger_for_one_pair',
      'one_pair_always_safe',
      'texture_predicts_result',
    ],
    learnerPrompt:
        'You have one pair. One board is dry; another is connected and suited. '
        'Which board deserves more caution?',
    choiceLabels: <String, String>{
      'coordinated_board_more_danger_for_one_pair':
          'The connected and suited board deserves more caution.',
      'dry_board_more_danger_for_one_pair':
          'The dry board deserves more caution.',
      'one_pair_always_safe': 'One pair is always safe.',
      'texture_predicts_result': 'Texture predicts the result.',
    },
    feedbackReason:
        'A coordinated board can connect with more hands. One pair may still '
        'be useful, but the texture asks for more caution.',
    incorrectFeedback: <String, String>{
      'dry_board_more_danger_for_one_pair':
          'Dry boards usually show fewer immediate connection clues.',
      'one_pair_always_safe':
          'One pair can face pressure on coordinated boards.',
      'texture_predicts_result':
          'Texture is a caution signal, not a result prediction.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w11_route_locked_no_safe_practice_target_v1',
  ),
];
