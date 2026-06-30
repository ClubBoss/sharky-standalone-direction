import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

const String act0W7VisibleAceHiddenRunKindV1 =
    'w7_hidden_runtime_session_owner_v1';
const String act0W7VisibleAceHiddenStartedByV1 =
    'Act0W7VisibleAceHiddenRuntimeSessionOwnerV1';

class Act0W7VisibleAceHiddenRuntimeSessionOwnerV1 {
  const Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();

  Act0W7VisibleAceHiddenTaskSpecV1 get taskSpec =>
      act0W7VisibleAceHiddenTaskSpecV1;
  List<Act0W7VisibleAceHiddenTaskSpecV1> get taskSpecs =>
      act0W7VisibleAceHiddenTaskSpecsV1;

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
      worldId: 'world_7',
      lessonId: 'range_thinking_lite_combo_density',
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
      worldId: 'world_7',
      lessonId: 'range_thinking_lite_combo_density',
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
        runKind: act0W7VisibleAceHiddenRunKindV1,
        startedBy: act0W7VisibleAceHiddenStartedByV1,
      ),
    );
  }

  Act0W7VisibleAceHiddenTaskSpecV1? _taskSpecFor({
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

class Act0W7VisibleAceHiddenTaskSpecV1 {
  const Act0W7VisibleAceHiddenTaskSpecV1({
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

const Act0W7VisibleAceHiddenTaskSpecV1 act0W7VisibleAceHiddenTaskSpecV1 =
    Act0W7VisibleAceHiddenTaskSpecV1(
      worldId: 'world_7',
      lessonId: 'range_thinking_lite_combo_density',
      taskId: 'visible_ace_combo_reduction_intro',
      sourceTaskId: 'visible_ace_combo_reduction_intro',
      conceptFamilyId: 'w7_combo_density_visible_card_removal',
      repairFocusId: 'w7_visible_card_combo_reduction',
      skillAtomId: 'w7_combo_density_card_removal',
      errorType: 'missed_visible_card_combo_reduction',
      drillKind: 'combo_density_visible_card_choice_v1',
      boardContext: 'A72 rainbow',
      learningPurpose: 'Visible aces reduce ace-containing combinations.',
      expectedChoiceId: 'ace_combos_reduced',
      choiceIds: <String>[
        'ace_combos_reduced',
        'ace_combos_unchanged',
        'ace_combos_guaranteed',
        'ace_combos_impossible',
      ],
      learnerPrompt:
          'An ace is already visible on A72 rainbow. What does that do to '
          "ace-containing hands in the opponent's possible range?",
      choiceLabels: <String, String>{
        'ace_combos_reduced':
            'There are fewer ace-containing combinations left.',
        'ace_combos_unchanged':
            'The visible ace does not change the number of ace combinations.',
        'ace_combos_guaranteed': 'The opponent must have an ace.',
        'ace_combos_impossible': 'The opponent can never have an ace.',
      },
      feedbackReason:
          'One ace is already visible, so fewer ace-containing combinations '
          'remain possible. This does not tell us the exact hand; it only '
          'changes how many hands are available.',
      incorrectFeedback: <String, String>{
        'ace_combos_unchanged':
            'Visible cards are unavailable to private hands, so the number of '
            'possible ace-containing hands changes.',
        'ace_combos_guaranteed':
            'A visible ace reduces possible ace-containing hands; it does not '
            'prove the opponent has one.',
        'ace_combos_impossible':
            'One visible ace reduces ace-containing hands, but some '
            'ace-containing hands can still exist.',
      },
      practiceCtaAllowed: false,
      mapperNoTargetReason: 'w7_route_locked_no_safe_practice_target_v1',
    );

const List<Act0W7VisibleAceHiddenTaskSpecV1> act0W7VisibleAceHiddenTaskSpecsV1 =
    <Act0W7VisibleAceHiddenTaskSpecV1>[
      act0W7VisibleAceHiddenTaskSpecV1,
      Act0W7VisibleAceHiddenTaskSpecV1(
        worldId: 'world_7',
        lessonId: 'range_thinking_lite_combo_density',
        taskId: 'visible_king_combo_reduction_intro',
        sourceTaskId: 'visible_king_combo_reduction_intro',
        conceptFamilyId: 'w7_combo_density_visible_card_removal',
        repairFocusId: 'w7_visible_king_combo_reduction',
        skillAtomId: 'w7_combo_density_card_removal',
        errorType: 'missed_visible_king_combo_reduction',
        drillKind: 'combo_density_visible_card_choice_v1',
        boardContext: 'K84 rainbow',
        learningPurpose: 'Visible kings reduce king-containing combinations.',
        expectedChoiceId: 'king_combos_reduced',
        choiceIds: <String>[
          'king_combos_reduced',
          'king_combos_unchanged',
          'king_combos_certain',
          'king_combos_impossible',
        ],
        learnerPrompt:
            'A king is already visible on K84 rainbow. What does that do to '
            "king-containing hands in the opponent's possible range?",
        choiceLabels: <String, String>{
          'king_combos_reduced':
              'There are fewer king-containing combinations left.',
          'king_combos_unchanged':
              'The visible king does not change king combinations.',
          'king_combos_certain': 'The opponent must have a king.',
          'king_combos_impossible': 'The opponent can never have a king.',
        },
        feedbackReason:
            'The visible king cannot also be in a private hand, so fewer '
            'king-containing combinations remain possible.',
        incorrectFeedback: <String, String>{
          'king_combos_unchanged':
              'Visible cards are removed from private hands, so the count '
              'of king-containing hands changes.',
          'king_combos_certain':
              'A visible king reduces possible king hands; it does not prove '
              'the opponent has one.',
          'king_combos_impossible':
              'One visible king reduces king hands, but some king-containing '
              'hands can still exist.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w7_route_locked_no_safe_practice_target_v1',
      ),
      Act0W7VisibleAceHiddenTaskSpecV1(
        worldId: 'world_7',
        lessonId: 'range_thinking_lite_combo_density',
        taskId: 'paired_board_texture_lite_intro',
        sourceTaskId: 'paired_board_texture_lite_intro',
        conceptFamilyId: 'w7_combo_density_visible_card_removal',
        repairFocusId: 'w7_paired_board_combo_texture_lite',
        skillAtomId: 'w7_combo_density_board_texture',
        errorType: 'missed_paired_board_combo_texture',
        drillKind: 'combo_density_board_texture_choice_v1',
        boardContext: '772 rainbow',
        learningPurpose:
            'Paired boards change which strong hand combinations remain.',
        expectedChoiceId: 'seven_combos_reduced_trips_still_possible',
        choiceIds: <String>[
          'seven_combos_reduced_trips_still_possible',
          'all_strong_hands_removed',
          'pair_does_not_change_combos',
          'opponent_always_has_trips',
        ],
        learnerPrompt:
            'On 772 rainbow, two sevens are already visible. What is the '
            'safe range-thinking takeaway?',
        choiceLabels: <String, String>{
          'seven_combos_reduced_trips_still_possible':
              'There are fewer seven-containing hands, but trips can still '
              'exist.',
          'all_strong_hands_removed': 'All strong hands are removed.',
          'pair_does_not_change_combos':
              'The paired board does not change hand counts.',
          'opponent_always_has_trips': 'The opponent always has trips.',
        },
        feedbackReason:
            'The two visible sevens reduce seven-containing private hands, '
            'but they do not remove every strong hand or prove one exact hand.',
        incorrectFeedback: <String, String>{
          'all_strong_hands_removed':
              'Visible cards reduce some combinations; they do not remove '
              'every strong hand.',
          'pair_does_not_change_combos':
              'Paired visible cards change which combinations remain.',
          'opponent_always_has_trips':
              'A paired board changes counts; it does not prove trips.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w7_route_locked_no_safe_practice_target_v1',
      ),
      Act0W7VisibleAceHiddenTaskSpecV1(
        worldId: 'world_7',
        lessonId: 'range_thinking_lite_combo_density',
        taskId: 'visible_card_combo_density_transfer_check',
        sourceTaskId: 'visible_card_combo_density_transfer_check',
        conceptFamilyId: 'w7_combo_density_visible_card_removal',
        repairFocusId: 'w7_visible_card_combo_density_transfer',
        skillAtomId: 'w7_combo_density_transfer_check',
        errorType: 'missed_visible_card_combo_density_transfer',
        drillKind: 'combo_density_transfer_choice_v1',
        boardContext: 'A72 rainbow vs K84 rainbow',
        learningPurpose:
            'Transfer the visible-card reduction idea across ranks.',
        expectedChoiceId: 'visible_rank_reduces_matching_rank_combos',
        choiceIds: <String>[
          'visible_rank_reduces_matching_rank_combos',
          'visible_rank_increases_matching_rank_combos',
          'only_board_low_cards_matter',
          'visible_cards_show_exact_hand',
        ],
        learnerPrompt:
            'Across A72 rainbow and K84 rainbow, what shared idea should you '
            'use when a high card is visible?',
        choiceLabels: <String, String>{
          'visible_rank_reduces_matching_rank_combos':
              'The visible rank reduces matching-rank combinations.',
          'visible_rank_increases_matching_rank_combos':
              'The visible rank creates more matching-rank combinations.',
          'only_board_low_cards_matter': 'Only low board cards matter.',
          'visible_cards_show_exact_hand':
              "Visible cards show the opponent's exact hand.",
        },
        feedbackReason:
            'A visible card of a rank is unavailable to private hands, so '
            'matching-rank combinations become fewer across boards.',
        incorrectFeedback: <String, String>{
          'visible_rank_increases_matching_rank_combos':
              'Visible cards are already used, so they reduce matching-rank '
              'private hand combinations.',
          'only_board_low_cards_matter':
              'High visible cards also change available combinations.',
          'visible_cards_show_exact_hand':
              'Visible cards change counts; they do not reveal one exact hand.',
        },
        practiceCtaAllowed: false,
        mapperNoTargetReason: 'w7_route_locked_no_safe_practice_target_v1',
      ),
    ];
