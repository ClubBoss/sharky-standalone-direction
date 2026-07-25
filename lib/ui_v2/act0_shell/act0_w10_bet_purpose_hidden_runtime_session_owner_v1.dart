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
    final spec = _taskSpecById(taskId ?? taskSpec.taskId);
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
    final spec = _taskSpecById(taskId ?? taskSpec.taskId);
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

  Act0W10BetPurposeHiddenTaskSpecV1? _taskSpecById(String taskId) {
    final cleanTaskId = taskId.trim();
    for (final spec in taskSpecs) {
      if (spec.taskId == cleanTaskId) {
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
  lessonId: 'player_type_basics',
  taskId: 'w10_player_tendency_tag_hidden',
  sourceTaskId: 'w10_player_tendency_tag_hidden',
  conceptFamilyId: 'w10_player_adjustment',
  repairFocusId: 'w10_player_tendency_tag',
  skillAtomId: 'w10_player_tendency_read',
  errorType: 'missed_player_tendency',
  drillKind: 'player_adjustment_choice_v1',
  boardContext: 'Repeated tight folds and low aggression',
  learningPurpose:
      'Tag one player tendency before choosing an exploit adjustment.',
  expectedChoiceId: 'tight_folding_profile',
  choiceIds: <String>[
    'tight_folding_profile',
    'loose_passive_caller',
    'overaggressive_bluffer',
    'no_read_ignore_forever',
  ],
  learnerPrompt:
      'Villain keeps folding blinds and rarely fights back. What is the '
      'safest first player-adjustment tag?',
  choiceLabels: <String, String>{
    'tight_folding_profile': 'Tight-folding profile.',
    'loose_passive_caller': 'Loose-passive caller.',
    'overaggressive_bluffer': 'Over-aggressive bluffer.',
    'no_read_ignore_forever': 'No read, ignore every future signal.',
  },
  feedbackReason:
      'Repeated folds and low resistance support a tight-folding tag before '
      'you choose one exploit lever.',
  incorrectFeedback: <String, String>{
    'loose_passive_caller':
        'Loose-passive means call-heavy and low aggression, not repeated '
        'folding.',
    'overaggressive_bluffer':
        'Over-aggressive players apply pressure; this player is avoiding it.',
    'no_read_ignore_forever':
        'Small samples need care, but repeated folds are still a usable light '
        'tag.',
  },
  practiceCtaAllowed: true,
  mapperNoTargetReason: '',
);

const List<Act0W10BetPurposeHiddenTaskSpecV1>
act0W10BetPurposeHiddenTaskSpecsV1 = <Act0W10BetPurposeHiddenTaskSpecV1>[
  act0W10BetPurposeHiddenTaskSpecV1,
  Act0W10BetPurposeHiddenTaskSpecV1(
    worldId: 'world_10',
    lessonId: 'adjust_one_lever',
    taskId: 'w10_adjustment_lever_hidden',
    sourceTaskId: 'w10_adjustment_lever_hidden',
    conceptFamilyId: 'w10_player_adjustment',
    repairFocusId: 'w10_one_lever_adjustment',
    skillAtomId: 'w10_adjustment_lever_read',
    errorType: 'missed_adjustment_lever',
    drillKind: 'player_adjustment_choice_v1',
    boardContext: 'Blinds fold too often to late steals',
    learningPurpose: 'Choose one bounded adjustment from a player read.',
    expectedChoiceId: 'open_wider_vs_overfolders',
    choiceIds: <String>[
      'triple_barrel_every_spot',
      'open_wider_vs_overfolders',
      'change_every_strategy_part',
      'ignore_repeated_folds',
    ],
    learnerPrompt:
        'Both blinds keep overfolding. What is the clean first exploit lever?',
    choiceLabels: <String, String>{
      'open_wider_vs_overfolders': 'Open slightly wider in late position.',
      'triple_barrel_every_spot': 'Triple-barrel every future spot.',
      'change_every_strategy_part': 'Change every strategy part now.',
      'ignore_repeated_folds': 'Ignore the repeated folds.',
    },
    feedbackReason:
        'Overfolding blinds support one measured late-position widen, not a '
        'full strategy rewrite.',
    incorrectFeedback: <String, String>{
      'triple_barrel_every_spot':
          'The read is preflop overfolding, so a postflop pressure plan is too '
          'broad.',
      'change_every_strategy_part':
          'One-lever changes are easier to track and less noisy.',
      'ignore_repeated_folds':
          'Baseline is safe, but repeated overfolds deserve a small targeted '
          'adjustment.',
    },
    practiceCtaAllowed: true,
    mapperNoTargetReason: '',
  ),
  Act0W10BetPurposeHiddenTaskSpecV1(
    worldId: 'world_10',
    lessonId: 'exploit_guardrails',
    taskId: 'w10_sample_guardrail_hidden',
    sourceTaskId: 'w10_sample_guardrail_hidden',
    conceptFamilyId: 'w10_player_adjustment',
    repairFocusId: 'w10_sample_size_guardrail',
    skillAtomId: 'w10_guardrail_read',
    errorType: 'missed_sample_guardrail',
    drillKind: 'player_adjustment_guardrail_choice_v1',
    boardContext: 'Two odd hands without a long pattern',
    learningPurpose: 'Avoid over-adjusting from thin player-read evidence.',
    expectedChoiceId: 'small_adjust_keep_watching',
    choiceIds: <String>[
      'full_counter_now',
      'never_adjust_again',
      'small_adjust_keep_watching',
      'copy_every_exploit',
    ],
    learnerPrompt:
        'You saw two unusual hands from villain but no long pattern yet. What '
        'keeps the exploit disciplined?',
    choiceLabels: <String, String>{
      'small_adjust_keep_watching':
          'Make a small adjustment and keep watching.',
      'full_counter_now': 'Commit to a full counter-strategy now.',
      'never_adjust_again': 'Never adjust from player reads.',
      'copy_every_exploit': 'Apply every exploit at once.',
    },
    feedbackReason:
        'Guardrails turn thin evidence into a small watchful adjustment, not a '
        'hard counter.',
    incorrectFeedback: <String, String>{
      'full_counter_now':
          'A full counter from two hands creates more noise than edge.',
      'never_adjust_again':
          'Guardrails do not mean ignoring reads; they mean adjusting carefully.',
      'copy_every_exploit':
          'Stacking all exploits hides which read is actually working.',
    },
    practiceCtaAllowed: true,
    mapperNoTargetReason: '',
  ),
  Act0W10BetPurposeHiddenTaskSpecV1(
    worldId: 'world_10',
    lessonId: 'player_adjustment_checkpoint',
    taskId: 'w10_player_adjustment_transfer_hidden',
    sourceTaskId: 'w10_player_adjustment_transfer_hidden',
    conceptFamilyId: 'w10_player_adjustment',
    repairFocusId: 'w10_player_adjustment_transfer',
    skillAtomId: 'w10_player_adjustment_transfer',
    errorType: 'missed_player_adjustment_transfer',
    drillKind: 'player_adjustment_transfer_choice_v1',
    boardContext: 'Real-table repeated blind overfold pattern',
    learningPurpose:
        'Transfer a player read into one tracked table adjustment.',
    expectedChoiceId: 'tag_one_lever_guardrail',
    choiceIds: <String>[
      'rewrite_entire_strategy',
      'ignore_all_tendencies',
      'copy_random_counter',
      'tag_one_lever_guardrail',
    ],
    learnerPrompt:
        'At a real table, you notice one repeated player tendency. What is the '
        'safe W10 transfer loop?',
    choiceLabels: <String, String>{
      'tag_one_lever_guardrail':
          'Tag one tendency, pick one lever, keep guardrails.',
      'rewrite_entire_strategy': 'Rewrite the entire strategy immediately.',
      'ignore_all_tendencies': 'Ignore all tendencies forever.',
      'copy_random_counter': 'Copy a random counter-strategy.',
    },
    feedbackReason:
        'W10 closes by turning one tendency into one measured adjustment with '
        'guardrails.',
    incorrectFeedback: <String, String>{
      'rewrite_entire_strategy':
          'A full rewrite makes it hard to know which read helped.',
      'ignore_all_tendencies':
          'Reliable repeated tendencies are part of the adjustment plan.',
      'copy_random_counter':
          'The counter must fit the actual tendency and remain small enough to '
          'track.',
    },
    practiceCtaAllowed: true,
    mapperNoTargetReason: '',
  ),
];
