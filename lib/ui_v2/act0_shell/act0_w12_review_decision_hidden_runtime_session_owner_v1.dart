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
      lessonId: 'tilt_reset_protocol',
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
      lessonId: 'tilt_reset_protocol',
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
  lessonId: 'tilt_reset_protocol',
  taskId: 'w12_tilt_reset_hidden',
  sourceTaskId: 'w12_tilt_reset_hidden',
  conceptFamilyId: 'w12_mindset_bridge',
  repairFocusId: 'w12_tilt_reset_protocol',
  skillAtomId: 'w12_tilt_reset_read',
  errorType: 'missed_tilt_reset',
  drillKind: 'mindset_bridge_choice_v1',
  boardContext: 'Emotional spike after a painful result',
  learningPurpose: 'Use a short reset before the next major decision.',
  expectedChoiceId: 'run_short_reset',
  choiceIds: <String>[
    'run_short_reset',
    'revenge_next_hand',
    'deny_emotion',
    'quit_every_time',
  ],
  learnerPrompt:
      'You feel tilt after a painful result. What is the clean W12 bridge '
      'action before the next major spot?',
  choiceLabels: <String, String>{
    'run_short_reset': 'Run a short reset and re-anchor.',
    'revenge_next_hand': 'Force action in the next hand.',
    'deny_emotion': 'Pretend the emotion is not there.',
    'quit_every_time': 'Auto-quit every time.',
  },
  feedbackReason:
      'Mindset Bridge protects decision quality with a short reset before '
      'emotion leaks into the next hand.',
  incorrectFeedback: <String, String>{
    'revenge_next_hand': 'Revenge action is tilt, not discipline.',
    'deny_emotion': 'Naming the emotion helps you control it.',
    'quit_every_time':
        'Leaving can be valid if control is gone, but the first bridge habit '
        'is a quick reset and re-check.',
  },
  practiceCtaAllowed: true,
  mapperNoTargetReason: '',
);

const List<Act0W12ReviewDecisionHiddenTaskSpecV1>
act0W12ReviewDecisionHiddenTaskSpecsV1 =
    <Act0W12ReviewDecisionHiddenTaskSpecV1>[
      act0W12ReviewDecisionHiddenTaskSpecV1,
      Act0W12ReviewDecisionHiddenTaskSpecV1(
        worldId: 'world_12',
        lessonId: 'decision_over_outcome',
        taskId: 'w12_process_quality_hidden',
        sourceTaskId: 'w12_process_quality_hidden',
        conceptFamilyId: 'w12_mindset_bridge',
        repairFocusId: 'w12_process_over_outcome',
        skillAtomId: 'w12_process_quality_read',
        errorType: 'missed_process_quality',
        drillKind: 'mindset_process_choice_v1',
        boardContext: 'Good decision loses one result',
        learningPurpose: 'Judge decision quality before reacting to outcome.',
        expectedChoiceId: 'judge_process_first',
        choiceIds: <String>[
          'outcome_proves_quality',
          'judge_process_first',
          'ignore_learning',
          'self_attack',
        ],
        learnerPrompt:
            'A good process loses this time. What should you judge first?',
        choiceLabels: <String, String>{
          'judge_process_first': 'Judge the process first.',
          'outcome_proves_quality': 'Outcome proves decision quality.',
          'ignore_learning': 'Ignore the hand completely.',
          'self_attack': 'Attack your confidence.',
        },
        feedbackReason:
            'Stable mindset separates process quality from one noisy outcome.',
        incorrectFeedback: <String, String>{
          'outcome_proves_quality':
              'One result can lie; process is the first check.',
          'ignore_learning': 'Short process review is better than avoidance.',
          'self_attack': 'The goal is clear review, not confidence collapse.',
        },
        practiceCtaAllowed: true,
        mapperNoTargetReason: '',
      ),
      Act0W12ReviewDecisionHiddenTaskSpecV1(
        worldId: 'world_12',
        lessonId: 'confidence_and_discipline',
        taskId: 'w12_confidence_discipline_hidden',
        sourceTaskId: 'w12_confidence_discipline_hidden',
        conceptFamilyId: 'w12_mindset_bridge',
        repairFocusId: 'w12_confidence_without_ego',
        skillAtomId: 'w12_discipline_read',
        errorType: 'missed_discipline',
        drillKind: 'mindset_discipline_choice_v1',
        boardContext: 'Table talk tempts an ego call',
        learningPurpose: 'Keep confidence disciplined instead of entitled.',
        expectedChoiceId: 'process_over_ego',
        choiceIds: <String>[
          'prove_point',
          'play_scared',
          'process_over_ego',
          'force_control',
        ],
        learnerPrompt:
            'Villain needles you into a marginal spot. What keeps confidence '
            'disciplined?',
        choiceLabels: <String, String>{
          'process_over_ego': 'Stay with process over ego.',
          'prove_point': 'Take the spot to prove a point.',
          'play_scared': 'Play scared to avoid conflict.',
          'force_control': 'Force control with a dramatic action.',
        },
        feedbackReason:
            'Confidence stays useful only when discipline and evidence still '
            'drive the action.',
        incorrectFeedback: <String, String>{
          'prove_point': 'Point-proving is ego, not confidence.',
          'play_scared': 'Fear can avoid risk but also leaks value.',
          'force_control': 'Control must come from evidence, not emotion.',
        },
        practiceCtaAllowed: true,
        mapperNoTargetReason: '',
      ),
      Act0W12ReviewDecisionHiddenTaskSpecV1(
        worldId: 'world_12',
        lessonId: 'mindset_bridge_checkpoint',
        taskId: 'w12_mindset_bridge_loop_hidden',
        sourceTaskId: 'w12_mindset_bridge_loop_hidden',
        conceptFamilyId: 'w12_mindset_bridge',
        repairFocusId: 'w12_mindset_bridge_loop',
        skillAtomId: 'w12_mindset_bridge_read',
        errorType: 'missed_mindset_bridge_loop',
        drillKind: 'mindset_bridge_checkpoint_choice_v1',
        boardContext: 'Process, reset, discipline loop',
        learningPurpose:
            'Combine the W12 bridge habits before Volume I review.',
        expectedChoiceId: 'process_reset_discipline',
        choiceIds: <String>[
          'result_reset_ego',
          'skip_reset',
          'future_world_unlock',
          'process_reset_discipline',
        ],
        learnerPrompt: 'What is the W12 bridge before Volume I review?',
        choiceLabels: <String, String>{
          'process_reset_discipline': 'Process, reset, and discipline.',
          'result_reset_ego': 'Result, reset, and ego.',
          'skip_reset': 'Skip reset and push through.',
          'future_world_unlock': 'Unlock a future world now.',
        },
        feedbackReason:
            'W12 closes by stabilizing process, reset, and discipline before '
            'the terminal recap.',
        incorrectFeedback: <String, String>{
          'result_reset_ego': 'Outcome and ego are the traps W12 controls.',
          'skip_reset': 'Reset is one of the bridge habits.',
          'future_world_unlock':
              'W12 routes to Volume I review, not a future world.',
        },
        practiceCtaAllowed: true,
        mapperNoTargetReason: '',
      ),
    ];
