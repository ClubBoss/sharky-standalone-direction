import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W8StackDepthHiddenRunKindV1 =
    'w8_hidden_runtime_session_owner_v1';
const String act0W8StackDepthHiddenStartedByV1 =
    'Act0W8StackDepthHiddenRuntimeSessionOwnerV1';

class Act0W8StackDepthHiddenRuntimeSessionOwnerV1 {
  const Act0W8StackDepthHiddenRuntimeSessionOwnerV1();

  Act0W8StackDepthHiddenTaskSpecV1 get taskSpec =>
      act0W8StackDepthHiddenTaskSpecV1;
  List<Act0W8StackDepthHiddenTaskSpecV1> get taskSpecs =>
      act0W8StackDepthHiddenTaskSpecsV1;

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
      lessonId: 'stack_depth_risk_control_lite',
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
      lessonId: 'stack_depth_risk_control_lite',
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
        runKind: act0W8StackDepthHiddenRunKindV1,
        startedBy: act0W8StackDepthHiddenStartedByV1,
      ),
    );
  }

  Act0W8StackDepthHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W8StackDepthHiddenTaskSpecV1 {
  const Act0W8StackDepthHiddenTaskSpecV1({
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

const Act0W8StackDepthHiddenTaskSpecV1 act0W8StackDepthHiddenTaskSpecV1 =
    Act0W8StackDepthHiddenTaskSpecV1(
      worldId: 'world_8',
      lessonId: 'stack_depth_risk_control_lite',
      taskId: 'short_stack_all_in_pressure_intro',
      sourceTaskId: 'short_stack_all_in_pressure_intro',
      conceptFamilyId: 'w8_stack_depth_risk_control',
      repairFocusId: 'w8_stack_depth_short_stack_pressure',
      skillAtomId: 'w8_stack_depth_short_stack_read',
      errorType: 'missed_short_stack_pressure',
      drillKind: 'stack_depth_choice_v1',
      boardContext: 'Short stack with all-in pressure possible',
      learningPurpose:
          'Recognize that a short stack has less room before all-in risk.',
      expectedChoiceId: 'short_stack_less_room',
      choiceIds: <String>[
        'short_stack_less_room',
        'short_stack_more_room',
        'stack_depth_irrelevant',
        'all_in_always_required',
      ],
      learnerPrompt:
          'A player has a short stack before acting. What is the safer stack '
          'depth read?',
      choiceLabels: <String, String>{
        'short_stack_less_room':
            'The short stack has less room before all-in risk.',
        'short_stack_more_room': 'The short stack has more room.',
        'stack_depth_irrelevant': 'Stack depth does not affect risk.',
        'all_in_always_required': 'The player must always move all-in.',
      },
      feedbackReason:
          'Short stacks make risk tighter because fewer chips remain behind.',
      incorrectFeedback: <String, String>{
        'short_stack_more_room':
            'A shorter stack usually has less room, not more.',
        'stack_depth_irrelevant':
            'Stack depth changes how much risk remains behind.',
        'all_in_always_required':
            'Short stack pressure matters, but it does not force every action.',
      },
      practiceCtaAllowed: false,
      mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
    );

const List<Act0W8StackDepthHiddenTaskSpecV1>
act0W8StackDepthHiddenTaskSpecsV1 = <Act0W8StackDepthHiddenTaskSpecV1>[
  act0W8StackDepthHiddenTaskSpecV1,
  Act0W8StackDepthHiddenTaskSpecV1(
    worldId: 'world_8',
    lessonId: 'stack_depth_risk_control_lite',
    taskId: 'deep_stack_postflop_room_intro',
    sourceTaskId: 'deep_stack_postflop_room_intro',
    conceptFamilyId: 'w8_stack_depth_risk_control',
    repairFocusId: 'w8_stack_depth_deep_stack_room',
    skillAtomId: 'w8_stack_depth_deep_stack_read',
    errorType: 'missed_deep_stack_room',
    drillKind: 'stack_depth_choice_v1',
    boardContext: 'Deep stack with more chips behind',
    learningPurpose:
        'Recognize that a deeper stack leaves more future betting room.',
    expectedChoiceId: 'deep_stack_more_room',
    choiceIds: <String>[
      'deep_stack_less_room',
      'deep_stack_more_room',
      'stack_depth_irrelevant',
      'all_in_risk_absent',
    ],
    learnerPrompt:
        'A player has many chips behind after the first bet. What does that '
        'stack depth usually create?',
    choiceLabels: <String, String>{
      'deep_stack_more_room':
          'More chips behind leave more future betting room.',
      'deep_stack_less_room': 'More chips behind leave less room.',
      'stack_depth_irrelevant': 'Stack depth does not matter.',
      'all_in_risk_absent': 'All-in risk can never appear.',
    },
    feedbackReason:
        'Deeper stacks can create more future decisions because more chips '
        'remain behind.',
    incorrectFeedback: <String, String>{
      'deep_stack_less_room':
          'More chips behind usually means more room, not less.',
      'stack_depth_irrelevant':
          'The amount behind changes future risk and commitment.',
      'all_in_risk_absent':
          'All-in risk can still appear later when more chips remain.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
  ),
  Act0W8StackDepthHiddenTaskSpecV1(
    worldId: 'world_8',
    lessonId: 'stack_depth_risk_control_lite',
    taskId: 'stack_to_pot_commitment_lite',
    sourceTaskId: 'stack_to_pot_commitment_lite',
    conceptFamilyId: 'w8_stack_depth_risk_control',
    repairFocusId: 'w8_stack_depth_commitment_pressure',
    skillAtomId: 'w8_stack_depth_to_pot_risk_read',
    errorType: 'missed_commitment_pressure',
    drillKind: 'stack_to_pot_choice_v1',
    boardContext: 'Pot is large relative to the stack behind',
    learningPurpose:
        'Compare stack behind to the pot before choosing a risk line.',
    expectedChoiceId: 'large_pot_tighter_commitment',
    choiceIds: <String>[
      'large_pot_removes_risk',
      'large_pot_tighter_commitment',
      'stack_behind_does_not_matter',
      'small_pot_always_all_in',
    ],
    learnerPrompt:
        'The pot is large compared with the stack behind. What is the safer '
        'risk read?',
    choiceLabels: <String, String>{
      'large_pot_tighter_commitment':
          'The decision can become commitment-heavy faster.',
      'large_pot_removes_risk': 'A large pot removes future risk.',
      'stack_behind_does_not_matter': 'Only the current cards matter.',
      'small_pot_always_all_in': 'A small pot is always all-in.',
    },
    feedbackReason:
        'When the pot is large relative to the stack, later bets can commit '
        'chips quickly.',
    incorrectFeedback: <String, String>{
      'large_pot_removes_risk':
          'A large pot can increase commitment pressure, not remove it.',
      'stack_behind_does_not_matter':
          'The stack behind is part of the risk signal.',
      'small_pot_always_all_in':
          'Pot size and stack depth guide risk; neither forces all spots.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
  ),
  Act0W8StackDepthHiddenTaskSpecV1(
    worldId: 'world_8',
    lessonId: 'stack_depth_risk_control_lite',
    taskId: 'all_in_threshold_transfer_check',
    sourceTaskId: 'all_in_threshold_transfer_check',
    conceptFamilyId: 'w8_stack_depth_risk_control',
    repairFocusId: 'w8_stack_depth_all_in_threshold',
    skillAtomId: 'w8_stack_depth_all_in_threshold_transfer',
    errorType: 'missed_all_in_threshold',
    drillKind: 'stack_depth_transfer_choice_v1',
    boardContext: 'Two stacks with different all-in thresholds',
    learningPurpose:
        'Transfer the stack-depth idea across shallow and deeper stacks.',
    expectedChoiceId: 'shallower_stack_reaches_all_in_faster',
    choiceIds: <String>[
      'deeper_stack_reaches_all_in_faster',
      'shallower_stack_reaches_all_in_faster',
      'both_stacks_same_risk',
      'stack_size_predicts_result',
    ],
    learnerPrompt:
        'One player is shallow and one is deeper. Which stack reaches all-in '
        'pressure faster?',
    choiceLabels: <String, String>{
      'shallower_stack_reaches_all_in_faster':
          'The shallower stack reaches all-in pressure faster.',
      'deeper_stack_reaches_all_in_faster':
          'The deeper stack reaches all-in pressure faster.',
      'both_stacks_same_risk': 'Both stacks create the same risk.',
      'stack_size_predicts_result': 'Stack size predicts the result.',
    },
    feedbackReason:
        'The shallower stack has fewer chips behind, so all-in pressure can '
        'arrive faster.',
    incorrectFeedback: <String, String>{
      'deeper_stack_reaches_all_in_faster':
          'A deeper stack usually has more room before all-in pressure.',
      'both_stacks_same_risk':
          'Different stack depths create different risk profiles.',
      'stack_size_predicts_result':
          'Stack depth shapes risk; it does not predict the outcome.',
    },
    practiceCtaAllowed: false,
    mapperNoTargetReason: 'w8_route_locked_no_safe_practice_target_v1',
  ),
];
