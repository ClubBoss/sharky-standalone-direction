import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W9TournamentPressureHiddenRunKindV1 =
    'w9_hidden_runtime_session_owner_v1';
const String act0W9TournamentPressureHiddenStartedByV1 =
    'Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1';

class Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1 {
  const Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1();

  Act0W9TournamentPressureHiddenTaskSpecV1 get taskSpec =>
      act0W9TournamentPressureHiddenTaskSpecV1;
  List<Act0W9TournamentPressureHiddenTaskSpecV1> get taskSpecs =>
      act0W9TournamentPressureHiddenTaskSpecsV1;

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
      lessonId: 'tournament_pressure_lite',
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
      lessonId: 'tournament_pressure_lite',
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
        runKind: act0W9TournamentPressureHiddenRunKindV1,
        startedBy: act0W9TournamentPressureHiddenStartedByV1,
      ),
    );
  }

  Act0W9TournamentPressureHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W9TournamentPressureHiddenTaskSpecV1 {
  const Act0W9TournamentPressureHiddenTaskSpecV1({
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

const Act0W9TournamentPressureHiddenTaskSpecV1
act0W9TournamentPressureHiddenTaskSpecV1 =
    Act0W9TournamentPressureHiddenTaskSpecV1(
      worldId: 'world_9',
      lessonId: 'tournament_pressure_lite',
      taskId: 'bubble_survival_pressure_intro',
      sourceTaskId: 'bubble_survival_pressure_intro',
      conceptFamilyId: 'w9_tournament_pressure_risk_premium',
      repairFocusId: 'w9_tournament_pressure_bubble_survival',
      skillAtomId: 'w9_tournament_pressure_bubble_read',
      errorType: 'missed_bubble_survival_pressure',
      drillKind: 'tournament_pressure_choice_v1',
      boardContext: 'Near bubble with survival pressure',
      learningPurpose:
          'Recognize that tournament survival pressure can make risk tighter.',
      expectedChoiceId: 'bubble_pressure_tightens_risk',
      choiceIds: <String>[
        'bubble_pressure_tightens_risk',
        'bubble_pressure_removes_risk',
        'chip_counts_do_not_matter',
        'survival_pressure_predicts_win',
      ],
      learnerPrompt:
          'The tournament is near the bubble. What is the safer pressure read?',
      choiceLabels: <String, String>{
        'bubble_pressure_tightens_risk':
            'Survival pressure can make risky actions tighter.',
        'bubble_pressure_removes_risk': 'Bubble pressure removes risk.',
        'chip_counts_do_not_matter': 'Chip counts do not matter.',
        'survival_pressure_predicts_win':
            'Survival pressure predicts the result.',
      },
      feedbackReason:
          'Near the bubble, tournament survival pressure can make chips at '
          'risk feel more costly.',
      incorrectFeedback: <String, String>{
        'bubble_pressure_removes_risk':
            'Bubble pressure usually adds caution instead of removing risk.',
        'chip_counts_do_not_matter':
            'Chip counts and survival both shape tournament pressure.',
        'survival_pressure_predicts_win':
            'Pressure shapes decisions; it does not predict the result.',
      },
      practiceCtaAllowed: false,
      mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
    );

const List<Act0W9TournamentPressureHiddenTaskSpecV1>
act0W9TournamentPressureHiddenTaskSpecsV1 =
    <Act0W9TournamentPressureHiddenTaskSpecV1>[
      act0W9TournamentPressureHiddenTaskSpecV1,
      Act0W9TournamentPressureHiddenTaskSpecV1(
        worldId: 'world_9',
        lessonId: 'tournament_pressure_lite',
        taskId: 'risk_premium_medium_stack_intro',
        sourceTaskId: 'risk_premium_medium_stack_intro',
        conceptFamilyId: 'w9_tournament_pressure_risk_premium',
        repairFocusId: 'w9_tournament_pressure_risk_premium',
        skillAtomId: 'w9_tournament_pressure_risk_premium_read',
        errorType: 'missed_risk_premium',
        drillKind: 'tournament_pressure_choice_v1',
        boardContext: 'Medium stack facing tournament risk',
        learningPurpose:
            'Recognize that tournament pressure can require extra risk reward.',
        expectedChoiceId: 'risk_premium_requires_extra_care',
        choiceIds: <String>[
          'risk_premium_means_any_action',
          'risk_premium_requires_extra_care',
          'pressure_removes_fold',
          'chip_position_irrelevant',
        ],
        learnerPrompt:
            'A medium stack faces meaningful tournament pressure. What is the '
            'safer risk-premium read?',
        choiceLabels: <String, String>{
          'risk_premium_requires_extra_care':
              'Extra tournament risk asks for extra care.',
          'risk_premium_means_any_action': 'Pressure makes any action fine.',
          'pressure_removes_fold': 'Pressure removes fold from the tree.',
          'chip_position_irrelevant': 'Chip position does not matter.',
        },
        feedbackReason:
            'Tournament pressure can raise the bar before taking a risky line.',
        incorrectFeedback: <String, String>{
          'risk_premium_means_any_action':
              'Pressure asks for discipline, not random action.',
          'pressure_removes_fold':
              'Fold can still be disciplined under pressure.',
          'chip_position_irrelevant':
              'Chip position is part of the tournament pressure signal.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
      ),
      Act0W9TournamentPressureHiddenTaskSpecV1(
        worldId: 'world_9',
        lessonId: 'tournament_pressure_lite',
        taskId: 'short_stack_ladder_pressure_lite',
        sourceTaskId: 'short_stack_ladder_pressure_lite',
        conceptFamilyId: 'w9_tournament_pressure_risk_premium',
        repairFocusId: 'w9_tournament_pressure_ladder_pressure',
        skillAtomId: 'w9_tournament_pressure_ladder_read',
        errorType: 'missed_ladder_pressure',
        drillKind: 'tournament_ladder_choice_v1',
        boardContext: 'Short stack with payout ladder pressure',
        learningPurpose:
            'Compare tournament chip risk with payout-ladder survival pressure.',
        expectedChoiceId: 'ladder_pressure_values_survival',
        choiceIds: <String>[
          'ladder_pressure_ignores_survival',
          'ladder_pressure_values_survival',
          'short_stack_has_no_pressure',
          'payout_ladder_predicts_cards',
        ],
        learnerPrompt:
            'A short stack can ladder by surviving. What is the safer '
            'tournament-pressure read?',
        choiceLabels: <String, String>{
          'ladder_pressure_values_survival':
              'Survival can carry extra value on the ladder.',
          'ladder_pressure_ignores_survival': 'The ladder ignores survival.',
          'short_stack_has_no_pressure': 'The short stack has no pressure.',
          'payout_ladder_predicts_cards': 'The ladder predicts the cards.',
        },
        feedbackReason:
            'Payout-ladder pressure can make survival more important than in a '
            'cash-game spot.',
        incorrectFeedback: <String, String>{
          'ladder_pressure_ignores_survival':
              'Ladder pressure is partly about survival.',
          'short_stack_has_no_pressure':
              'Short stacks can feel strong tournament pressure.',
          'payout_ladder_predicts_cards':
              'The payout ladder shapes incentives, not card outcomes.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
      ),
      Act0W9TournamentPressureHiddenTaskSpecV1(
        worldId: 'world_9',
        lessonId: 'tournament_pressure_lite',
        taskId: 'pressure_transfer_check',
        sourceTaskId: 'pressure_transfer_check',
        conceptFamilyId: 'w9_tournament_pressure_risk_premium',
        repairFocusId: 'w9_tournament_pressure_transfer_check',
        skillAtomId: 'w9_tournament_pressure_transfer',
        errorType: 'missed_tournament_pressure_transfer',
        drillKind: 'tournament_pressure_transfer_choice_v1',
        boardContext: 'Same hand class under different tournament pressure',
        learningPurpose:
            'Transfer tournament pressure across bubble and ladder contexts.',
        expectedChoiceId: 'higher_pressure_needs_more_caution',
        choiceIds: <String>[
          'higher_pressure_means_auto_all_in',
          'higher_pressure_needs_more_caution',
          'lower_pressure_is_always_fold',
          'pressure_predicts_result',
        ],
        learnerPrompt:
            'Two tournament spots have different pressure. Which one needs '
            'more caution before risking chips?',
        choiceLabels: <String, String>{
          'higher_pressure_needs_more_caution':
              'The higher-pressure spot needs more caution.',
          'higher_pressure_means_auto_all_in':
              'Higher pressure means automatic all-in.',
          'lower_pressure_is_always_fold': 'Lower pressure is always a fold.',
          'pressure_predicts_result': 'Pressure predicts the result.',
        },
        feedbackReason:
            'Higher tournament pressure can raise the risk bar, but it still '
            'does not force one action in every decision.',
        incorrectFeedback: <String, String>{
          'higher_pressure_means_auto_all_in':
              'Pressure changes caution; it does not force all-in.',
          'lower_pressure_is_always_fold':
              'Lower pressure does not automatically mean fold.',
          'pressure_predicts_result':
              'Pressure shapes incentives; it does not reveal the result.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w9_route_locked_no_safe_practice_target_v1',
      ),
    ];
