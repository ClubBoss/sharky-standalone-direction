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
      lessonId: 'session_plan_basics',
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
      lessonId: 'session_plan_basics',
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
  lessonId: 'session_plan_basics',
  taskId: 'w11_session_plan_hidden',
  sourceTaskId: 'w11_session_plan_hidden',
  conceptFamilyId: 'w11_real_play_transfer',
  repairFocusId: 'w11_one_focus_session_plan',
  skillAtomId: 'w11_session_plan_read',
  errorType: 'missed_session_plan',
  drillKind: 'real_play_transfer_choice_v1',
  boardContext: 'Short session with noisy tables',
  learningPurpose: 'Create one executable session focus before real play.',
  expectedChoiceId: 'one_focus_session_plan',
  choiceIds: <String>[
    'one_focus_session_plan',
    'six_goals_at_once',
    'no_plan_react_only',
    'review_without_focus',
  ],
  learnerPrompt:
      'You have one hour at a noisy table. What is the clean W11 transfer '
      'setup?',
  choiceLabels: <String, String>{
    'one_focus_session_plan': 'Set one measurable focus.',
    'six_goals_at_once': 'Track six goals at once.',
    'no_plan_react_only': 'Use no plan and just react.',
    'review_without_focus': 'Wait until review to choose a focus.',
  },
  feedbackReason:
      'Real-play transfer starts with one focus that can be noticed live and '
      'reviewed after the session.',
  incorrectFeedback: <String, String>{
    'six_goals_at_once': 'Too many goals blur transfer and make review noisy.',
    'no_plan_react_only':
        'Reactive play can work, but deliberate transfer needs one target.',
    'review_without_focus':
        'Review is stronger when the session starts with a focus to check.',
  },
  practiceCtaAllowed: true,
  mapperNoTargetReason: '',
);

const List<Act0W11BoardTextureHiddenTaskSpecV1>
act0W11BoardTextureHiddenTaskSpecsV1 = <Act0W11BoardTextureHiddenTaskSpecV1>[
  act0W11BoardTextureHiddenTaskSpecV1,
  Act0W11BoardTextureHiddenTaskSpecV1(
    worldId: 'world_11',
    lessonId: 'table_trigger_reads',
    taskId: 'w11_table_trigger_hidden',
    sourceTaskId: 'w11_table_trigger_hidden',
    conceptFamilyId: 'w11_real_play_transfer',
    repairFocusId: 'w11_table_trigger_read',
    skillAtomId: 'w11_trigger_transfer_read',
    errorType: 'missed_table_trigger',
    drillKind: 'real_play_transfer_choice_v1',
    boardContext: 'Repeated blind overfold trigger',
    learningPurpose: 'Use one live trigger to apply a prepared adjustment.',
    expectedChoiceId: 'activate_one_trigger',
    choiceIds: <String>[
      'apply_all_triggers',
      'activate_one_trigger',
      'ignore_live_trigger',
      'wait_for_results_only',
    ],
    learnerPrompt: 'A repeated live trigger appears. What is the clean action?',
    choiceLabels: <String, String>{
      'activate_one_trigger': 'Activate one trigger-action lever.',
      'apply_all_triggers': 'Apply every possible trigger at once.',
      'ignore_live_trigger': 'Ignore the live trigger.',
      'wait_for_results_only': 'Wait for results before acting.',
    },
    feedbackReason:
        'Transfer works when one repeated trigger activates one prepared lever.',
    incorrectFeedback: <String, String>{
      'apply_all_triggers': 'Many simultaneous levers create noisy execution.',
      'ignore_live_trigger': 'A repeated trigger is the live transfer cue.',
      'wait_for_results_only':
          'The W11 loop acts from a prepared trigger, then reviews.',
    },
    practiceCtaAllowed: true,
    mapperNoTargetReason: '',
  ),
  Act0W11BoardTextureHiddenTaskSpecV1(
    worldId: 'world_11',
    lessonId: 'post_session_review_loop',
    taskId: 'w11_review_loop_hidden',
    sourceTaskId: 'w11_review_loop_hidden',
    conceptFamilyId: 'w11_real_play_transfer',
    repairFocusId: 'w11_post_session_review_loop',
    skillAtomId: 'w11_review_loop_read',
    errorType: 'missed_review_loop',
    drillKind: 'real_play_review_choice_v1',
    boardContext: 'Session ends with two repeated mistakes',
    learningPurpose: 'Close real play with one actionable review target.',
    expectedChoiceId: 'one_leak_one_fix',
    choiceIds: <String>[
      'write_long_notes_only',
      'skip_review',
      'one_leak_one_fix',
      'fix_everything_tomorrow',
    ],
    learnerPrompt:
        'The session is over and two mistakes repeated. What closes the W11 '
        'loop?',
    choiceLabels: <String, String>{
      'one_leak_one_fix': 'Choose one leak and one fix for tomorrow.',
      'write_long_notes_only': 'Write long notes with no action.',
      'skip_review': 'Skip review and rely on memory.',
      'fix_everything_tomorrow': 'Fix everything tomorrow.',
    },
    feedbackReason:
        'A clean review loop outputs one repair target for the next session.',
    incorrectFeedback: <String, String>{
      'write_long_notes_only':
          'Notes help only when they produce a next-session action.',
      'skip_review': 'Memory fades; the loop needs a short closeout.',
      'fix_everything_tomorrow':
          'Fixing everything at once usually weakens execution.',
    },
    practiceCtaAllowed: true,
    mapperNoTargetReason: '',
  ),
  Act0W11BoardTextureHiddenTaskSpecV1(
    worldId: 'world_11',
    lessonId: 'real_play_transfer_checkpoint',
    taskId: 'w11_real_play_loop_hidden',
    sourceTaskId: 'w11_real_play_loop_hidden',
    conceptFamilyId: 'w11_real_play_transfer',
    repairFocusId: 'w11_real_play_transfer_loop',
    skillAtomId: 'w11_transfer_loop_read',
    errorType: 'missed_transfer_loop',
    drillKind: 'real_play_transfer_checkpoint_choice_v1',
    boardContext: 'Plan, trigger, review, repeat',
    learningPurpose: 'Combine the W11 real-play transfer loop.',
    expectedChoiceId: 'plan_trigger_review_repeat',
    choiceIds: <String>[
      'play_without_plan',
      'only_review_results',
      'copy_random_line',
      'plan_trigger_review_repeat',
    ],
    learnerPrompt:
        'What is the full W11 loop that transfers app work into real play?',
    choiceLabels: <String, String>{
      'plan_trigger_review_repeat': 'Plan, trigger, review, then repeat.',
      'play_without_plan': 'Play without a plan.',
      'only_review_results': 'Only review whether you won.',
      'copy_random_line': 'Copy a random line from memory.',
    },
    feedbackReason:
        'W11 is the transfer loop: one session plan, one live trigger, one '
        'review output.',
    incorrectFeedback: <String, String>{
      'play_without_plan': 'Transfer starts before the session with one focus.',
      'only_review_results': 'Results are noisy; review the actionable leak.',
      'copy_random_line': 'The line must come from the planned trigger.',
    },
    practiceCtaAllowed: true,
    mapperNoTargetReason: '',
  ),
];
