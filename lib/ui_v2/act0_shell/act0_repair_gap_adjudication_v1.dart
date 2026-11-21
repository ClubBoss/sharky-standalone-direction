import 'act0_authored_source_proof_v1.dart';
import 'act0_shell_state_v1.dart';

enum Act0RepairGapOutcomeV1 {
  alternateSameSignalTarget,
  intentionalExactReplay,
  newBoundedRepairItem,
  unresolvedProductGap,
}

extension Act0RepairGapOutcomeLabelV1 on Act0RepairGapOutcomeV1 {
  String get label => switch (this) {
    Act0RepairGapOutcomeV1.alternateSameSignalTarget =>
      'ALTERNATE_SAME_SIGNAL_TARGET',
    Act0RepairGapOutcomeV1.intentionalExactReplay => 'INTENTIONAL_EXACT_REPLAY',
    Act0RepairGapOutcomeV1.newBoundedRepairItem => 'NEW_BOUNDED_REPAIR_ITEM',
    Act0RepairGapOutcomeV1.unresolvedProductGap => 'UNRESOLVED_PRODUCT_GAP',
  };
}

class Act0RepairGapAdjudicationV1 {
  const Act0RepairGapAdjudicationV1({
    required this.sourceWorldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
    required this.misconception,
    required this.conceptErrorId,
    required this.priorFallback,
    required this.candidateTargetIds,
    required this.outcome,
    this.targetWorldId,
    this.targetLessonId,
    this.targetTaskId,
    required this.learnerEquivalenceRationale,
    required this.difficultyRelationship,
    this.leaksOriginalAnswer = false,
    this.requiresFutureKnowledge = false,
    required this.recheckPath,
    required this.compatibilityImpact,
  });

  final String sourceWorldId;
  final String sourceLessonId;
  final String sourceTaskId;
  final String misconception;
  final String conceptErrorId;
  final String priorFallback;
  final List<String> candidateTargetIds;
  final Act0RepairGapOutcomeV1 outcome;
  final String? targetWorldId;
  final String? targetLessonId;
  final String? targetTaskId;
  final String learnerEquivalenceRationale;
  final String difficultyRelationship;
  final bool leaksOriginalAnswer;
  final bool requiresFutureKnowledge;
  final String recheckPath;
  final String compatibilityImpact;

  String get mappingType => switch (outcome) {
    Act0RepairGapOutcomeV1.alternateSameSignalTarget => 'repair',
    Act0RepairGapOutcomeV1.intentionalExactReplay => 'intentional_exact',
    Act0RepairGapOutcomeV1.newBoundedRepairItem => 'bounded_repair',
    Act0RepairGapOutcomeV1.unresolvedProductGap => 'unresolved_product_gap',
  };
}

const String _priorExact = 'unrecorded_exact_source_fallback';
const String _priorW1HeroButtonWrongSignal =
    'mapped_wrong_signal:world_3/position_checkpoint/'
    'position_checkpoint_position_checkpoint_table_notice:players_behind';
const String _same = 'same concept and signal; different authored decision';
const String _exact =
    'identity or definition check has no equivalent alternate';
const String _sameDifficulty =
    'same introduced knowledge; same or lower difficulty';
const String _recheck = 'repair target then original source task recheck';
const String _compat = 'schema and telemetry event names unchanged';

const List<Act0RepairGapAdjudicationV1>
act0RepairGapAdjudicationsV1 = <Act0RepairGapAdjudicationV1>[
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is',
    sourceTaskId: 'what_poker_is_find_hero',
    misconception: 'confusing your private cards with the shared board',
    conceptErrorId: 'confused_private_board_cards',
    priorFallback: _priorW1HeroButtonWrongSignal,
    candidateTargetIds: <String>['first_table_guide_shared_cards_repair'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'what_poker_is',
    targetTaskId: 'first_table_guide_shared_cards_repair',
    learnerEquivalenceRationale:
        'The source asks which cards belong only to you. The repair uses a '
        'different hand to identify which cards everyone can use.',
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_checkpoint',
    sourceTaskId: 'position_checkpoint_position_checkpoint_table_notice',
    misconception: 'CO has already acted last or late position is a free pass',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale:
        'no authored alternate preserves the CO frame and its three players '
        'behind; the available UTG repair changes both the seat and count',
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is',
    sourceTaskId: 'what_poker_is_table_read_recheck',
    misconception: 'private cards, board, and pot table scan',
    conceptErrorId: 'confused_table_identity',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['what_poker_is_table_read_transfer'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'what_poker_is',
    targetTaskId: 'what_poker_is_table_read_transfer',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is_content',
    sourceTaskId: 'what_poker_is_pot_stack',
    misconception: 'pot chips versus remaining stack chips',
    conceptErrorId: 'confused_chip_commitment_eligibility',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is_content',
    sourceTaskId: 'what_poker_is_win_ways',
    misconception: 'fold or showdown win path',
    conceptErrorId: 'misread_poker_win_condition',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['what_poker_is_live_win_transfer'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'what_poker_is_content',
    targetTaskId: 'what_poker_is_live_win_transfer',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is_content',
    sourceTaskId: 'what_poker_is_all_in_meaning',
    misconception: 'all-in chip commitment',
    conceptErrorId: 'confused_chip_commitment_eligibility',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is_content',
    sourceTaskId: 'what_poker_is_matched_chips_transfer',
    misconception: 'matched-chip pot eligibility',
    conceptErrorId: 'confused_chip_commitment_eligibility',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is_content',
    sourceTaskId: 'what_poker_is_live_win_transfer',
    misconception: 'live fold or showdown win path',
    conceptErrorId: 'misread_poker_win_condition',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['what_poker_is_win_ways'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'what_poker_is_content',
    targetTaskId: 'what_poker_is_win_ways',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is_content',
    sourceTaskId: 'what_poker_is_review',
    misconception: 'pot, folds, and showdown recap',
    conceptErrorId: 'misread_poker_win_condition',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['what_poker_is_live_win_transfer'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'what_poker_is_content',
    targetTaskId: 'what_poker_is_live_win_transfer',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'cards_ranks_suits',
    sourceTaskId: 'cards_ranks_suits_theory',
    misconception: 'deck rank and suit structure',
    conceptErrorId: 'confused_card_rank_suit',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'cards_ranks_suits',
    sourceTaskId: 'cards_ranks_suits_rank_drill',
    misconception: 'card rank identity',
    conceptErrorId: 'confused_card_rank_suit',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'cards_ranks_suits',
    sourceTaskId: 'cards_ranks_suits_suit_drill',
    misconception: 'card suit identity',
    conceptErrorId: 'confused_card_rank_suit',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'your_first_hand',
    sourceTaskId: 'your_first_hand_private_cards_recheck',
    misconception: 'private versus board cards',
    conceptErrorId: 'confused_private_board_cards',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['cards_ranks_suits_private_board'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'cards_ranks_suits',
    targetTaskId: 'cards_ranks_suits_private_board',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'fold_check_call_raise',
    sourceTaskId: 'actions_check_drill',
    misconception: 'check legality with no bet',
    conceptErrorId: 'misread_action_legality',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['actions_legal_context'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_legal_context',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'fold_check_call_raise',
    sourceTaskId: 'actions_call_drill',
    misconception: 'call meaning when facing a price',
    conceptErrorId: 'misread_action_legality',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'blinds_posts_drill',
    misconception: 'big blind forced-post amount',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'blinds_first_actor',
    misconception: 'first preflop actor',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'blinds_last_actor',
    misconception: 'last preflop actor',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'blinds_review',
    misconception: 'first preflop actor',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale:
        'the only earlier first-actor drill asks this exact UTG identity, so a different target would change the precise skill',
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'positions_utg',
    misconception: 'UTG seat identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'positions_cutoff',
    misconception: 'cutoff seat identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'positions',
    sourceTaskId: 'positions_early_late',
    misconception: 'early versus late seat location',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['positions_late_seat'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'positions',
    targetTaskId: 'positions_late_seat',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_2',
    sourceLessonId: 'hand_discipline_apply',
    sourceTaskId: 'apply_hj_decision',
    misconception: 'medium hand discipline facing action',
    conceptErrorId: 'misread_starting_hand_discipline',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['continue_or_let_go_medium_call_or_fold'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_2',
    targetLessonId: 'continue_or_let_go',
    targetTaskId: 'continue_or_let_go_medium_call_or_fold',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_positions_utg',
    misconception: 'UTG seat identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[
      'position_six_seats_position_repair_seat_id_utg',
    ],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_position_repair_seat_id_utg',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_hj_co_contrast',
    misconception: 'hijack versus cutoff identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['position_six_seats_positions_cutoff'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_positions_cutoff',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_positions_cutoff',
    misconception: 'cutoff versus hijack identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['position_six_seats_hj_co_contrast'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_hj_co_contrast',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_sb_recognition',
    misconception: 'small blind seat identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['position_six_seats_bb_recognition'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_bb_recognition',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_bb_recognition',
    misconception: 'big blind seat identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['position_six_seats_sb_recognition'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_sb_recognition',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_position_repair_seat_id_utg',
    misconception: 'UTG seat repair identity',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['position_six_seats_positions_utg'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_positions_utg',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'position_six_seats',
    sourceTaskId: 'position_six_seats_positions_review',
    misconception: 'six-seat position recap',
    conceptErrorId: 'misread_table_position',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale: _exact,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'early_vs_late',
    sourceTaskId: 'early_vs_late_w2_early_position',
    misconception: 'early-position information disadvantage',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['early_vs_late_early_pressure_choice'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'early_vs_late',
    targetTaskId: 'early_vs_late_early_pressure_choice',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'early_vs_late',
    sourceTaskId: 'early_vs_late_early_pressure_choice',
    misconception: 'early-position players-behind pressure',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[
      'early_vs_late_position_repair_utg_players_behind',
    ],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'early_vs_late',
    targetTaskId: 'early_vs_late_position_repair_utg_players_behind',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'early_vs_late',
    sourceTaskId: 'early_vs_late_position_repair_utg_players_behind',
    misconception: 'UTG players-behind repair',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['early_vs_late_early_pressure_choice'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'early_vs_late',
    targetTaskId: 'early_vs_late_early_pressure_choice',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'early_vs_late',
    sourceTaskId: 'early_vs_late_late_info_choice',
    misconception: 'late-position information advantage',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['early_vs_late_w2_late_position'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'early_vs_late',
    targetTaskId: 'early_vs_late_w2_late_position',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'same_hand_different_seat',
    sourceTaskId:
        'same_hand_different_seat_position_repair_same_hand_different_seat',
    misconception: 'same hand changes with seat',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: _priorExact,
    candidateTargetIds: <String>[
      'same_hand_different_seat_same_hand_early_fold',
    ],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_3',
    targetLessonId: 'same_hand_different_seat',
    targetTaskId: 'same_hand_different_seat_same_hand_early_fold',
    learnerEquivalenceRationale: _same,
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_8',
    sourceLessonId: 'spr_and_commitment',
    sourceTaskId: 'what_poker_is_side_pot_intro',
    misconception: 'matched-chip side-pot eligibility',
    conceptErrorId: 'confused_chip_commitment_eligibility',
    priorFallback: _priorExact,
    candidateTargetIds: <String>['what_poker_is_matched_chips_transfer'],
    outcome: Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    targetWorldId: 'world_1',
    targetLessonId: 'what_poker_is_content',
    targetTaskId: 'what_poker_is_matched_chips_transfer',
    learnerEquivalenceRationale:
        'same matched-chip eligibility concept at lower difficulty',
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'same_hand_different_seat',
    sourceTaskId: 'same_hand_different_seat_w3_same_hand_recap',
    misconception:
        'one fixed action per hand instead of bucket, seat and frame',
    conceptErrorId: 'misread_position_action_order',
    priorFallback:
        'mapped_wrong_signal:world_3/position_checkpoint/position_checkpoint_position_checkpoint_table_notice:hero_button',
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale:
        'This authored recap checks the bucket, seat and frame definition. No separate active equivalent is declared; repeat this definition without claiming unseen transfer.',
    difficultyRelationship: _sameDifficulty,
    recheckPath: 'context recap replay then original-source recheck',
    compatibilityImpact:
        'Historical seat-choice records remain intact; current context choices have a new source fingerprint.',
  ),
  // Explicit new F0 context: BTN is not Hero; no admitted alternate repair.
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'blinds_action_order',
    sourceTaskId: 'blinds_postflop_button',
    misconception: 'last eligible BTN in the stated initial postflop pass',
    conceptErrorId: 'misread_position_action_order',
    priorFallback:
        'new_context_revision: prior Hero-button receipt no longer applies',
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.unresolvedProductGap,
    learnerEquivalenceRationale:
        'Hero is explicitly CO. A Hero-button identity receipt does not establish a same-skill repair for this action-order context. No replacement relation is admitted.',
    difficultyRelationship: 'UNKNOWN: no alternate target admitted',
    recheckPath:
        'HOLD: retain the source occurrence until an independently reviewed relation is admitted',
    compatibilityImpact:
        'Raw history, source fingerprints and once-only XP retained; no new repair evidence or launch authority',
  ),
  // Explicit new F0 context: BTN is not Hero; no admitted alternate repair.
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'positions',
    sourceTaskId: 'positions_late_seat',
    misconception: 'last eligible BTN in the stated initial postflop pass',
    conceptErrorId: 'misread_table_position',
    priorFallback:
        'new_context_revision: prior Hero-button receipt no longer applies',
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.unresolvedProductGap,
    learnerEquivalenceRationale:
        'Hero is explicitly CO. A Hero-button identity receipt does not establish a same-skill repair for this action-order context. No replacement relation is admitted.',
    difficultyRelationship: 'UNKNOWN: no alternate target admitted',
    recheckPath:
        'HOLD: retain the source occurrence until an independently reviewed relation is admitted',
    compatibilityImpact:
        'Raw history, source fingerprints and once-only XP retained; no new repair evidence or launch authority',
  ),
  // Explicit new F0 context: BTN is not Hero; no admitted alternate repair.
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'positions',
    sourceTaskId: 'positions_review',
    misconception: 'last eligible BTN in the stated initial postflop pass',
    conceptErrorId: 'misread_table_position',
    priorFallback:
        'new_context_revision: prior Hero-button receipt no longer applies',
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.unresolvedProductGap,
    learnerEquivalenceRationale:
        'Hero is explicitly CO. A Hero-button identity receipt does not establish a same-skill repair for this action-order context. No replacement relation is admitted.',
    difficultyRelationship: 'UNKNOWN: no alternate target admitted',
    recheckPath:
        'HOLD: retain the source occurrence until an independently reviewed relation is admitted',
    compatibilityImpact:
        'Raw history, source fingerprints and once-only XP retained; no new repair evidence or launch authority',
  ),
  Act0RepairGapAdjudicationV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'same_hand_different_seat',
    sourceTaskId: 'same_hand_different_seat_w3_same_hand_intro',
    misconception: 'checking hand and position without reading earlier action',
    conceptErrorId: 'misread_position_action_order',
    priorFallback: 'unrecorded_exact_source_fallback',
    candidateTargetIds: <String>[],
    outcome: Act0RepairGapOutcomeV1.intentionalExactReplay,
    learnerEquivalenceRationale:
        'Retry the current context question and check what changed before acting.',
    difficultyRelationship: _sameDifficulty,
    recheckPath: _recheck,
    compatibilityImpact: _compat,
  ),
];

Act0RepairGapAdjudicationV1? act0RepairGapAdjudicationForSourceTaskV1(
  String sourceTaskId,
) {
  final normalized = sourceTaskId.trim();
  for (final row in act0RepairGapAdjudicationsV1) {
    if (row.sourceTaskId == normalized) return row;
  }
  return null;
}

/// Narrow source-owned semantic admission. Existing scene mappings are not
/// relation evidence. No new target/application is admitted by this registry.
class Act0RepairGoalContractV1 {
  const Act0RepairGoalContractV1({
    required this.sourceWorldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
    required this.sourceChoiceId,
    required this.sourceCorrectChoiceId,
    required this.sourceFingerprint,
    this.diagnosticVariantId = '',
    this.sourceContainerFingerprint = '',
    required this.sourceQuestion,
    required this.sourceChoiceReason,
    required this.sourceChoiceLabel,
    this.sourceChoiceQuality = 'wrong',
    required this.goalId,
    required this.misconceptionId,
    required this.relationId,
    this.relationRevision = 1,
    this.targetWorldId = '',
    this.targetLessonId = '',
    this.targetTaskId = '',
    this.targetFingerprint = '',
    this.targetCorrectChoiceId = '',
    this.targetChoiceIds = const <String>{},
    this.evidenceClass = 'no_validated_target',
    this.mappingType = 'unresolved_product_gap',
    this.requireCapturedGoalWitness = false,
  });
  final bool requireCapturedGoalWitness;
  final String sourceWorldId, sourceLessonId, sourceTaskId, sourceChoiceId;
  final String sourceCorrectChoiceId, sourceFingerprint;
  final String diagnosticVariantId, sourceContainerFingerprint;
  bool get isDiagnosticLearningEntry =>
      evidenceClass == 'diagnostic_learning_entry';
  final String sourceQuestion,
      sourceChoiceReason,
      sourceChoiceLabel,
      sourceChoiceQuality;
  final String goalId, misconceptionId, relationId;
  final int relationRevision;
  final String targetWorldId, targetLessonId, targetTaskId, targetFingerprint;
  final String targetCorrectChoiceId, evidenceClass, mappingType;
  final Set<String> targetChoiceIds;
  bool get hasValidatedTarget => targetTaskId.isNotEmpty;
  String get learnerGoalLabel => switch (goalId) {
    'player_identity_and_seat_role' => 'Player and seat role',
    'card_rank_order' => 'Card rank comparison',
    'starting_hand_premium_bucket' => 'Starting-hand bucket',
    'half_pot_fraction' => 'Half-pot sizing',
    'showdown_best_five' => 'Showdown hand comparison',
    'no_bet_free_continue' => 'Checking for free',
    'shared_board_vs_private_cards' => 'Private and shared cards',
    'preflop_bucket_seat_frame' => 'Hand, seat and action frame',
    'six_max_initial_preflop_first_actor' => 'First preflop actor here',
    'six_max_unraised_initial_pass_bb_option' => 'Big blind option here',
    'utg_seat_identity' => 'UTG seat',
    'dealer_button_seat' => 'Dealer button',
    'last_actor_after_flop' => 'Last seat after the flop',
    'big_blind_baseline' => 'The 1 BB blind',
    'early_seat_players_behind' => 'Players left to act',
    'same_hand_different_seat' => 'Same hand from two seats',
    'value_bet_purpose' => 'Why you bet',
    'read_straight_draw_shape' => 'Which ranks complete the draw',
    'turn_changes_board_threats' => 'What the turn changes',
    'bluff_needs_better_folds' => 'Which better hands might fold',
    'range_advantage_on_board' => 'Which range fits the board',
    'dry_or_wet_flop' => 'Dry or wet flop',
    'connected_flop_ranks' => 'Connected ranks on the flop',
    'recognize_flush_draw' => 'Count the cards in one suit',
    'one_card_draw_price' => 'Compare the chance to hit with the price',
    'recognize_range_bucket' => 'Which range bucket fits the hand',
    'two_rank_combo_count' => 'Count combinations of two ranks',
    'compare_combo_families' => 'Compare how many exact hands each family has',
    'compare_suited_combo_families' =>
      'Compare a suited hand with a pocket pair',
    'visible_cards_reduce_combos' => 'How visible cards narrow the range',
    'smaller_effective_stack' => 'Find the smaller stack',
    'first_position_by_table_size' => 'Count the players left to act',
    _ =>
      goalId.startsWith(_exerciseGoalPrefix)
          ? 'Same exercise'
          : 'Repair not confirmed',
  };
  // Neither familiar vocabulary practice nor definition replay is application.
  bool get canClaimIndependentApplication => false;
  bool get canClaimMatchedRecheck => false;
}

const act0RepairGoalContractsV1 = <Act0RepairGoalContractV1>[
  Act0RepairGoalContractV1(
    sourceWorldId: "world_5",
    sourceLessonId: "straight_draws",
    sourceTaskId: "straight_draws_w5_gutshot_contrast_transfer",
    sourceChoiceId: "gutshot",
    sourceCorrectChoiceId: "open_ended",
    sourceFingerprint:
        "d2a1a783662d59f4f0947c7f40ee75a338052bc4a7d4a267fcfd07da5714ac99",
    sourceQuestion: "Which straight draw do you have?",
    sourceChoiceReason:
        "A gutshot has one missing middle rank. Your 6-7-8-9 already run in order. A 5 or a ten completes the straight.",
    sourceChoiceLabel: "Gutshot straight draw",
    sourceChoiceQuality: "wrong",
    goalId: "read_straight_draw_shape",
    misconceptionId: "open_ended_seen_as_gutshot",
    relationId: "straight_draws_w5_gutshot_contrast_transfer_gutshot_l2_v1",
    targetWorldId: "world_5",
    targetLessonId: "straight_draws",
    targetTaskId: "straight_draws_w5_gutshot_draw",
    targetFingerprint:
        "ef6656a0c16e0997e40ecd8a6862386f4f376bf63c855a6dcf900d85af01dbfd",
    targetCorrectChoiceId: "gutshot",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"gutshot", "open_ended", "made_straight"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_5",
    sourceLessonId: "turn_river_changes",
    sourceTaskId: "turn_river_changes_w5_turn_texture_shift_transfer",
    sourceChoiceId: "nothing_changed",
    sourceCorrectChoiceId: "board_got_wetter",
    sourceFingerprint:
        "78d385632df419c307be28fdf2c53d111da1d4a2337c16f7f7ca80528a302449",
    sourceQuestion: "What new danger does the turn add?",
    sourceChoiceReason:
        "The turn adds a third heart. Two private hearts can now make a flush.",
    sourceChoiceLabel: "Nothing changed, so keep the same easy plan",
    sourceChoiceQuality: "wrong",
    goalId: "turn_changes_board_threats",
    misconceptionId: "turn_threat_ignored",
    relationId:
        "turn_river_changes_w5_turn_texture_shift_transfer_nothing_changed_l2_v1",
    targetWorldId: "world_5",
    targetLessonId: "turn_river_changes",
    targetTaskId: "turn_river_changes_w5_street_repair",
    targetFingerprint:
        "33411f6662ac97f4d4cd6bf37dae4e74c8a3d6f2c4a4df5558a9e22d55ad8071",
    targetCorrectChoiceId: "repair_story",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"repair_story", "same_story", "small_same_story"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_6",
    sourceLessonId: "range_pressure_lines",
    sourceTaskId: "w6_turn_pressure_shift_transfer",
    sourceChoiceId: "barrel_big",
    sourceCorrectChoiceId: "check_more",
    sourceFingerprint:
        "823635de5a9d3eb72907a3de7a7ff0f15e4bdadcef2c9006c01b1ff3b2e0952f",
    sourceQuestion:
        "Suppose fold pressure has dropped on this turn. What is the cleaner plan?",
    sourceChoiceReason:
        "BB is less likely to fold now. A bigger second bet does not make the old plan a better fit.",
    sourceChoiceLabel: "Make another big bet",
    sourceChoiceQuality: "suboptimal",
    goalId: "bluff_needs_better_folds",
    misconceptionId: "repeat_bluff_after_callers_change",
    relationId: "w6_turn_pressure_shift_transfer_barrel_big_l2_v1",
    targetWorldId: "world_6",
    targetLessonId: "range_pressure_lines",
    targetTaskId: "w6_wet_board_repair",
    targetFingerprint:
        "748afdf9b2df3715b7172e2f48157ea5289b6027c7a739ff014b413d506e1cbd",
    targetCorrectChoiceId: "respect_wetter_board",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{
      "respect_wetter_board",
      "nothing_changed",
      "smaller_same_story",
    },
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: 'world_6',
    sourceLessonId: 'range_board_fit',
    sourceTaskId: 'w6_board_fit_recap',
    sourceChoiceId: 'caller',
    sourceCorrectChoiceId: 'raiser',
    sourceFingerprint:
        '31f2937d21045d3ce2f8a34a06c3abda7fac3f8ea22384871d8a89e2a8dea0a1',
    sourceQuestion:
        'In these ranges, who has more hand types at two pair or better?',
    sourceChoiceReason:
        'BB’s pocket pairs stay one pair. Only the raiser has A-A, K-K, and A-K in this model.',
    sourceChoiceLabel: 'BB, the caller',
    goalId: 'range_advantage_on_board',
    misconceptionId: 'range_advantage_ignores_board',
    relationId: 'w6_board_fit_range_advantage_caller_v1',
    targetWorldId: 'world_6',
    targetLessonId: 'range_board_fit',
    targetTaskId: 'w6_value_wet_board',
    targetFingerprint:
        '356f20ef898de355700003f0cb7992f0476a133064e213ef0a09f42b34f71441',
    targetCorrectChoiceId: 'value',
    targetChoiceIds: <String>{'bluff', 'value', 'missed'},
    evidenceClass: 'familiar_rehearsal',
    mappingType: 'repair',
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: 'world_6',
    sourceLessonId: 'range_board_fit',
    sourceTaskId: 'w6_board_fit_recap',
    sourceChoiceId: 'same',
    sourceCorrectChoiceId: 'raiser',
    sourceFingerprint:
        '31f2937d21045d3ce2f8a34a06c3abda7fac3f8ea22384871d8a89e2a8dea0a1',
    sourceQuestion:
        'In these ranges, who has more hand types at two pair or better?',
    sourceChoiceReason:
        'The raiser has two sets and one two-pair hand type. The caller has zero hand types at that strength.',
    sourceChoiceLabel: 'They have the same number',
    goalId: 'range_advantage_on_board',
    misconceptionId: 'range_advantage_counts_weak_hands',
    relationId: 'w6_board_fit_range_advantage_same_v1',
    targetWorldId: 'world_6',
    targetLessonId: 'range_board_fit',
    targetTaskId: 'w6_value_wet_board',
    targetFingerprint:
        '356f20ef898de355700003f0cb7992f0476a133064e213ef0a09f42b34f71441',
    targetCorrectChoiceId: 'value',
    targetChoiceIds: <String>{'bluff', 'value', 'missed'},
    evidenceClass: 'familiar_rehearsal',
    mappingType: 'repair',
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: 'world_6',
    sourceLessonId: 'range_pressure_lines',
    sourceTaskId: 'w6_value_range_action',
    sourceChoiceId: 'bet_bluff',
    sourceCorrectChoiceId: 'bet',
    sourceFingerprint:
        'd45607470d96309daf38e7921b41056603c59834f0954fad325948327ba8bbb7',
    sourceQuestion: 'What is the purpose of a half-pot bet here?',
    sourceChoiceReason:
        'BB can call with a weaker pair, such as K-J or 7-6. You are betting to get called by worse hands.',
    sourceChoiceLabel: 'Bet as a bluff',
    goalId: 'value_bet_purpose',
    misconceptionId: 'value_bet_seen_as_bluff',
    relationId: 'w6_value_range_action_bet_bluff_v1',
    targetWorldId: 'world_6',
    targetLessonId: 'range_pressure_lines',
    targetTaskId: 'w6_value_range_action',
    targetFingerprint:
        'd45607470d96309daf38e7921b41056603c59834f0954fad325948327ba8bbb7',
    targetCorrectChoiceId: 'bet',
    targetChoiceIds: <String>{'bet', 'check', 'bet_bluff'},
    evidenceClass: 'intentional_exact_replay',
    mappingType: 'intentional_exact',
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_3",
    sourceLessonId: "same_hand_different_seat",
    sourceTaskId: "same_hand_different_seat_same_hand_early_fold",
    sourceChoiceId: "raise",
    sourceCorrectChoiceId: "fold",
    sourceFingerprint:
        "7ec0d17c371b896a3a79e0131cdfdbbbe49fe4d2ea19a0b076d6a66313d25216",
    sourceQuestion:
        "By the Sharky starting chart, what is the disciplined action?",
    sourceChoiceReason:
        "UTG is earlier than HJ, where the Sharky starting chart begins opening ATo.",
    sourceChoiceLabel: "Raise",
    sourceChoiceQuality: "wrong",
    goalId: "same_hand_different_seat",
    misconceptionId: "same_action_at_every_seat",
    relationId: "l1_chart_early_raise_v1",
    targetWorldId: "world_3",
    targetLessonId: "same_hand_different_seat",
    targetTaskId:
        "same_hand_different_seat_position_repair_same_hand_different_seat",
    targetFingerprint:
        "52fd3dfe161450705a5ec04250b5535e038aec3d418c6530685e6d03a0cc4310",
    targetCorrectChoiceId: "seat_context",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{
      "seat_context",
      "cards_changed",
      "position_unimportant",
    },
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_3",
    sourceLessonId: "early_vs_late",
    sourceTaskId: "early_vs_late_early_pressure_choice",
    sourceChoiceId: "same_as_btn",
    sourceCorrectChoiceId: "more_players_behind",
    sourceFingerprint:
        "f71593e6c5747f19148520c6468c66a3d0e399021169d5f9031c589b936e46a8",
    sourceQuestion: "Why does UTG need more discipline here?",
    sourceChoiceReason:
        "BTN is later and sees much more first. UTG is pressured because almost everyone still acts after it.",
    sourceChoiceLabel: "UTG gets the same information as BTN",
    sourceChoiceQuality: "wrong",
    goalId: "early_seat_players_behind",
    misconceptionId: "same_information_as_button",
    relationId: "l1_players_behind_utg_v1",
    targetWorldId: "world_3",
    targetLessonId: "early_vs_late",
    targetTaskId: "early_vs_late_position_repair_utg_players_behind",
    targetFingerprint:
        "a26d6368cbc9ea54100de527954b156d383211484fa256270d914d93d9c8c354",
    targetCorrectChoiceId: "five_players_behind",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"utg_has_late_info", "five_players_behind"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_3",
    sourceLessonId: "button_advantage",
    sourceTaskId: "button_advantage_button_last",
    sourceChoiceId: "utg",
    sourceCorrectChoiceId: "btn",
    sourceFingerprint:
        "86017c0b096c0aabbe90b1f51f1659c8c441496f570ed3c05d722d98a71b1adb",
    sourceQuestion: "Tap the seat that acts last after the flop.",
    sourceChoiceReason:
        "On this 5 BB flop (Ah 7c 2d), UTG acts before BTN rather than last, so tapping UTG misreads who gets to see everyone else act first.",
    sourceChoiceLabel: "UTG",
    sourceChoiceQuality: "wrong",
    goalId: "last_actor_after_flop",
    misconceptionId: "utg_as_last",
    relationId: "l1_flop_order_utg_v1",
    targetWorldId: "world_3",
    targetLessonId: "button_advantage",
    targetTaskId: "button_advantage_position_repair_btn_last_postflop",
    targetFingerprint:
        "5769e8d6e42bffc92cf883653d6a347f82fe17a649f75ac85ae79ca94a85c86b",
    targetCorrectChoiceId: "btn",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"btn", "utg"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_3",
    sourceLessonId: "position_six_seats",
    sourceTaskId: "position_six_seats_positions_utg",
    sourceChoiceId: "hj",
    sourceCorrectChoiceId: "utg",
    sourceFingerprint:
        "56ea0dcbc9ceeeff4fc47dbf709fb3172632f5a50fbee1521a68c96d38288097",
    sourceQuestion: "Tap UTG.",
    sourceChoiceReason: "HJ is close, but this drill is asking for UTG.",
    sourceChoiceLabel: "HJ",
    sourceChoiceQuality: "wrong",
    goalId: "utg_seat_identity",
    misconceptionId: "hijack_as_first_seat",
    relationId: "l1_first_seat_hj_v1",
    targetWorldId: "world_3",
    targetLessonId: "position_six_seats",
    targetTaskId: "position_six_seats_position_repair_seat_id_utg",
    targetFingerprint:
        "d5f5d80d40ba6c31def26693a49f1a8c055634dcb44bf3cb51aff3d4e687dc74",
    targetCorrectChoiceId: "utg",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"hj", "utg"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_3",
    sourceLessonId: "button_advantage",
    sourceTaskId: "button_advantage_find_button",
    sourceChoiceId: "co",
    sourceCorrectChoiceId: "btn",
    sourceFingerprint:
        "fbd51ee83e8b64301d1d51d23c2cf6a943a2a5a0a96670167d595df8ed7ed419",
    sourceQuestion:
        "Which seat has the dealer marker when you sit one seat earlier?",
    sourceChoiceReason:
        "Sitting at CO in this 1.5 BB pot puts you one seat earlier than BTN, so tapping CO misses which seat actually holds the dealer marker.",
    sourceChoiceLabel: "CO",
    sourceChoiceQuality: "wrong",
    goalId: "dealer_button_seat",
    misconceptionId: "own_seat_as_button",
    relationId: "l1_button_advantage_co_v1",
    targetWorldId: "world_3",
    targetLessonId: "position_six_seats",
    targetTaskId: "position_six_seats_position_repair_seat_id_btn",
    targetFingerprint:
        "e437b0d9291fbbf1cb57c81f0024ec4f88a6f4f81bba2b88cee95fa091c59273",
    targetCorrectChoiceId: "btn",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"btn", "co"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_3",
    sourceLessonId: "position_six_seats",
    sourceTaskId: "position_six_seats_positions_button",
    sourceChoiceId: "co",
    sourceCorrectChoiceId: "btn",
    sourceFingerprint:
        "3c87bb10325fdd7efc55d31d62c454b91729721cbe92a64048ad0dfd14ce00cc",
    sourceQuestion: "Tap BTN.",
    sourceChoiceReason: "CO is close, but this drill is asking for BTN.",
    sourceChoiceLabel: "CO",
    sourceChoiceQuality: "wrong",
    goalId: "dealer_button_seat",
    misconceptionId: "cutoff_as_button",
    relationId: "l1_dealer_marker_co_v1",
    targetWorldId: "world_3",
    targetLessonId: "position_six_seats",
    targetTaskId: "position_six_seats_position_repair_seat_id_btn",
    targetFingerprint:
        "e437b0d9291fbbf1cb57c81f0024ec4f88a6f4f81bba2b88cee95fa091c59273",
    targetCorrectChoiceId: "btn",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"btn", "co"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "what_poker_is",
    sourceTaskId: "what_poker_is_find_hero",
    sourceChoiceId: "top",
    sourceCorrectChoiceId: "bottom",
    sourceFingerprint:
        "126229140138e9a6819ac1697c01995d720bcb3704386cdaaa84f26eeec153c7",
    sourceQuestion: "Which cards belong to you alone?",
    sourceChoiceReason:
        "Everyone still playing can use the cards in the middle.",
    sourceChoiceLabel: "The shared cards in the middle",
    sourceChoiceQuality: "wrong",
    goalId: "shared_board_vs_private_cards",
    misconceptionId: "shared_board_as_private",
    relationId: "selected_w1_001_top_v1",
    targetWorldId: "world_1",
    targetLessonId: "what_poker_is",
    targetTaskId: "first_table_guide_shared_cards_repair",
    targetFingerprint:
        "73e8ebb06ab849488e3f1bb37768aec7b7682644116dede7703c674521e660e5",
    targetCorrectChoiceId: "board",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"private", "board"},
    requireCapturedGoalWitness: true,
    relationRevision: 3,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "what_poker_is",
    sourceTaskId: "what_poker_is_find_hero",
    sourceChoiceId: "random",
    sourceCorrectChoiceId: "bottom",
    sourceFingerprint:
        "126229140138e9a6819ac1697c01995d720bcb3704386cdaaa84f26eeec153c7",
    sourceQuestion:
        "Which label could change next hand while the player is still you?",
    sourceChoiceReason:
        "Your cards remain yours; BTN is the changing table role.",
    sourceChoiceLabel: "Your private cards",
    sourceChoiceQuality: "wrong",
    goalId: "player_identity_and_seat_role",
    misconceptionId: "seat_role_as_private_cards",
    relationId: "selected_w1_002_random_v1",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "cards_ranks_suits",
    sourceTaskId: "cards_ranks_suits_rank_drill",
    sourceChoiceId: "king",
    sourceCorrectChoiceId: "ace",
    sourceFingerprint:
        "88306fc7b5bf505b9dc226a5419d5c59d52bdfe84ed4dacad3fd47f419bf24bc",
    sourceQuestion: "Which rank is higher here?",
    sourceChoiceReason: "Ace is higher than king in this beginner drill.",
    sourceChoiceLabel: "King",
    goalId: "card_rank_order",
    misconceptionId: "king_above_ace",
    relationId: "selected_w1_023_king_v1",
    targetWorldId: "world_1",
    targetLessonId: "cards_ranks_suits",
    targetTaskId: "cards_ranks_suits_rank_drill",
    targetFingerprint:
        "88306fc7b5bf505b9dc226a5419d5c59d52bdfe84ed4dacad3fd47f419bf24bc",
    targetCorrectChoiceId: "ace",
    evidenceClass: "intentional_exact_replay",
    mappingType: "intentional_exact",
    targetChoiceIds: <String>{"king", "suit", "ace"},
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "cards_ranks_suits",
    sourceTaskId: "cards_ranks_suits_rank_drill",
    sourceChoiceId: "suit",
    sourceCorrectChoiceId: "ace",
    sourceFingerprint:
        "88306fc7b5bf505b9dc226a5419d5c59d52bdfe84ed4dacad3fd47f419bf24bc",
    sourceQuestion: "Which rank is higher here?",
    sourceChoiceReason: "Suit does not make one rank higher than another.",
    sourceChoiceLabel: "Suit decides",
    goalId: "card_rank_order",
    misconceptionId: "suit_overrides_rank",
    relationId: "selected_w1_024_suit_v1",
    targetWorldId: "world_1",
    targetLessonId: "cards_ranks_suits",
    targetTaskId: "cards_ranks_suits_rank_drill",
    targetFingerprint:
        "88306fc7b5bf505b9dc226a5419d5c59d52bdfe84ed4dacad3fd47f419bf24bc",
    targetCorrectChoiceId: "ace",
    evidenceClass: "intentional_exact_replay",
    mappingType: "intentional_exact",
    targetChoiceIds: <String>{"king", "suit", "ace"},
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "fold_check_call_raise",
    sourceTaskId: "actions_check_drill",
    sourceChoiceId: "fold",
    sourceCorrectChoiceId: "check",
    sourceFingerprint:
        "fd0c0733190724f0eb6676afa424ef4735fe28d294fcac8cc84f02b391b733f0",
    sourceQuestion: "What action keeps playing for free?",
    sourceChoiceReason: "Folding gives up the hand. Checking is free here.",
    sourceChoiceLabel: "Fold",
    goalId: "no_bet_free_continue",
    misconceptionId: "free_continue_as_fold",
    relationId: "selected_w1_044_fold_v1",
    relationRevision: 2,
    targetWorldId: "world_1",
    targetLessonId: "fold_check_call_raise",
    targetTaskId: "actions_legal_context",
    targetFingerprint:
        "14ef2cda9000242046e5abfa838e0958d70fcf0ce67be305bd8a65b49b2f67e3",
    targetCorrectChoiceId: "check",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"fold", "check", "call"},
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "fold_check_call_raise",
    sourceTaskId: "actions_check_drill",
    sourceChoiceId: "call",
    sourceCorrectChoiceId: "check",
    sourceFingerprint:
        "fd0c0733190724f0eb6676afa424ef4735fe28d294fcac8cc84f02b391b733f0",
    sourceQuestion: "What action keeps playing for free?",
    sourceChoiceReason: "Calling means matching a bet. There is no bet here.",
    sourceChoiceLabel: "Call",
    goalId: "no_bet_free_continue",
    misconceptionId: "free_continue_as_call",
    relationId: "selected_w1_045_call_v1",
    relationRevision: 2,
    targetWorldId: "world_1",
    targetLessonId: "fold_check_call_raise",
    targetTaskId: "actions_legal_context",
    targetFingerprint:
        "14ef2cda9000242046e5abfa838e0958d70fcf0ce67be305bd8a65b49b2f67e3",
    targetCorrectChoiceId: "check",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{"fold", "check", "call"},
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "your_first_hand",
    sourceTaskId: "your_first_hand_showdown",
    sourceChoiceId: "first_actor",
    sourceCorrectChoiceId: "best_hand",
    sourceFingerprint:
        "3e7d72d87ebdd5d55424ae24cd532a1f7fe1d61c338f4ba016d7fc56b3d00a91",
    goalId: "showdown_best_five",
    misconceptionId: "showdown_as_action_order",
    relationId: "selected_w1_038_first_actor_v1",
    sourceQuestion: "What decides a showdown?",
    sourceChoiceReason:
        "Seat order decides who acts first, not who wins at showdown. Once cards are revealed, players compare the best full hand they can make from private cards plus the shared board.",
    sourceChoiceLabel: "First actor",
    sourceChoiceQuality: "wrong",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "your_first_hand",
    sourceTaskId: "your_first_hand_showdown",
    sourceChoiceId: "hero_cards_only",
    sourceCorrectChoiceId: "best_hand",
    sourceFingerprint:
        "3e7d72d87ebdd5d55424ae24cd532a1f7fe1d61c338f4ba016d7fc56b3d00a91",
    goalId: "showdown_best_five",
    misconceptionId: "showdown_private_cards_only",
    relationId: "selected_w1_039_hero_cards_only_v1",
    sourceQuestion: "What decides a showdown?",
    sourceChoiceReason:
        "Private cards matter, but showdown uses the whole five-card result. The shared board can help both players, so the best full hand decides it.",
    sourceChoiceLabel: "Hero cards only",
    sourceChoiceQuality: "suboptimal",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_2",
    sourceLessonId: "hand_discipline_buckets",
    sourceTaskId: "hand_discipline_buckets_premium",
    sourceChoiceId: "medium",
    sourceCorrectChoiceId: "premium",
    sourceFingerprint:
        "220875ad0c22aacff61d7b30582949c2712bf20efd0c676fd03ff457fe0a930b",
    goalId: "starting_hand_premium_bucket",
    misconceptionId: "premium_as_medium",
    relationId: "selected_w2_01_medium_v1",
    sourceQuestion: "Which bucket is AA?",
    sourceChoiceReason: "AA is stronger than a medium hand.",
    sourceChoiceLabel: "Medium",
    sourceChoiceQuality: "wrong",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_2",
    sourceLessonId: "continue_or_let_go",
    sourceTaskId: "continue_or_let_go_premium_continue",
    sourceChoiceId: "medium",
    sourceCorrectChoiceId: "premium",
    sourceFingerprint:
        "6f195be8c845b100044566a9247e01fd18fa7ccbcdb71b49bc0ff460a28d9cf4",
    goalId: "starting_hand_premium_bucket",
    misconceptionId: "premium_as_medium",
    relationId: "selected_w2_01_medium_v1",
    sourceQuestion: "Which bucket is AA?",
    sourceChoiceReason: "AA is stronger than a medium hand.",
    sourceChoiceLabel: "Medium",
    sourceChoiceQuality: "wrong",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_2",
    sourceLessonId: "discipline_checkpoint",
    sourceTaskId: "discipline_checkpoint_checkpoint_premium",
    sourceChoiceId: "medium",
    sourceCorrectChoiceId: "premium",
    sourceFingerprint:
        "c91512639b27f565949516fcc222f6ce8524fea3c49852e77abc68665ba26c8a",
    goalId: "starting_hand_premium_bucket",
    misconceptionId: "premium_as_medium",
    relationId: "selected_w2_01_medium_v1",
    sourceQuestion: "Which bucket is AA?",
    sourceChoiceReason: "AA is stronger than a medium hand.",
    sourceChoiceLabel: "Medium",
    sourceChoiceQuality: "wrong",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_4",
    sourceLessonId: "small_half_pot",
    sourceTaskId: "w4_half_pot_bet",
    sourceChoiceId: "two",
    sourceCorrectChoiceId: "three",
    sourceFingerprint:
        "1cb07814c58ecb00f54b39c359df686e721d976392f6d1b8d0703ee4bcf7d35d",
    goalId: "half_pot_fraction",
    misconceptionId: "half_as_one_third",
    relationId: "selected_w4_16_two_v1",
    sourceQuestion: "Which size is half-pot?",
    sourceChoiceReason: "2 BB into 6 BB is one-third pot, not half-pot.",
    sourceChoiceLabel: "2 BB",
    sourceChoiceQuality: "wrong",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_4",
    sourceLessonId: "small_half_pot",
    sourceTaskId: "w4_half_pot_bet",
    sourceChoiceId: "six",
    sourceCorrectChoiceId: "three",
    sourceFingerprint:
        "1cb07814c58ecb00f54b39c359df686e721d976392f6d1b8d0703ee4bcf7d35d",
    goalId: "half_pot_fraction",
    misconceptionId: "half_as_whole",
    relationId: "selected_w4_17_six_v1",
    sourceQuestion: "Which size is half-pot?",
    sourceChoiceReason: "6 BB into 6 BB is pot-size, not half-pot.",
    sourceChoiceLabel: "6 BB",
    sourceChoiceQuality: "wrong",
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "fold_check_call_raise",
    sourceTaskId: "actions_legal_context",
    sourceChoiceId: "fold",
    sourceCorrectChoiceId: "check",
    sourceFingerprint:
        "14ef2cda9000242046e5abfa838e0958d70fcf0ce67be305bd8a65b49b2f67e3",
    goalId: "no_bet_free_continue",
    misconceptionId: "free_continue_as_fold",
    relationId: "selected_w1_042_fold_v1",
    relationRevision: 2,
    sourceQuestion:
        "No bet faces you. Which action keeps you in the hand without adding chips?",
    sourceChoiceReason: "Folding gives up the hand. Checking is free here.",
    sourceChoiceLabel: "Fold",
    sourceChoiceQuality: "wrong",
    targetWorldId: "world_1",
    targetLessonId: "fold_check_call_raise",
    targetTaskId: "actions_check_drill",
    targetFingerprint:
        "fd0c0733190724f0eb6676afa424ef4735fe28d294fcac8cc84f02b391b733f0",
    targetCorrectChoiceId: "check",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{'check', 'call', 'fold'},
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "fold_check_call_raise",
    sourceTaskId: "actions_legal_context",
    sourceChoiceId: "call",
    sourceCorrectChoiceId: "check",
    sourceFingerprint:
        "14ef2cda9000242046e5abfa838e0958d70fcf0ce67be305bd8a65b49b2f67e3",
    goalId: "no_bet_free_continue",
    misconceptionId: "free_continue_as_call",
    relationId: "selected_w1_043_call_v1",
    relationRevision: 2,
    sourceQuestion:
        "No bet faces you. Which action keeps you in the hand without adding chips?",
    sourceChoiceReason: "Calling means matching a bet. There is no bet here.",
    sourceChoiceLabel: "Call",
    sourceChoiceQuality: "wrong",
    targetWorldId: "world_1",
    targetLessonId: "fold_check_call_raise",
    targetTaskId: "actions_check_drill",
    targetFingerprint:
        "fd0c0733190724f0eb6676afa424ef4735fe28d294fcac8cc84f02b391b733f0",
    targetCorrectChoiceId: "check",
    evidenceClass: "familiar_rehearsal",
    mappingType: "repair",
    targetChoiceIds: <String>{'check', 'call', 'fold'},
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: 'world_3',
    sourceLessonId: 'same_hand_different_seat',
    sourceTaskId: 'same_hand_different_seat_w3_same_hand_recap',
    sourceChoiceId: 'one_answer',
    sourceCorrectChoiceId: 'framework',
    sourceQuestion: 'What prevents one-hand-one-answer thinking?',
    sourceChoiceReason:
        'One hand can change action when position or action frame changes.',
    sourceChoiceLabel: 'One answer per hand',
    sourceFingerprint:
        '513ba09211a8d65162883b8c6d4de7645806bf652090e0927b7dc93b8a3015e1',
    goalId: 'preflop_bucket_seat_frame',
    misconceptionId: 'one_hand_one_answer',
    relationId: 'w24_context_familiar_replay_v1',
    targetWorldId: 'world_3',
    targetLessonId: 'same_hand_different_seat',
    targetTaskId: 'same_hand_different_seat_w3_same_hand_recap',
    targetFingerprint:
        '513ba09211a8d65162883b8c6d4de7645806bf652090e0927b7dc93b8a3015e1',
    targetCorrectChoiceId: 'framework',
    targetChoiceIds: <String>{'framework', 'one_answer'},
    evidenceClass: 'intentional_exact_replay',
    mappingType: 'intentional_exact',
  ),
  // Navigation-only placement teaching entries. Neither is repair proof.
  Act0RepairGoalContractV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is',
    sourceTaskId: 'what_poker_is_table_read_transfer',
    sourceChoiceId: 'hero_private_cards',
    sourceCorrectChoiceId: 'board_cards',
    sourceFingerprint: '', // Captured full variant witness, never base-only.
    sourceContainerFingerprint:
        '004cc7da3d67627764b31439a3f62b056b9d5b62b1c4e361cf7bbea86d2e0163',
    diagnosticVariantId: 'board_private_cards',
    sourceQuestion: 'Which cards can everyone use?',
    sourceChoiceReason:
        'Hero’s private cards belong only to Hero. Board cards are shared.',
    sourceChoiceLabel: 'Hero’s private cards',
    sourceChoiceQuality: 'wrong',
    goalId: 'shared_board_vs_private_cards',
    misconceptionId: 'shared_cards_as_hero_private',
    relationId: 'placement_shared_cards_learning_entry_v1',
    targetWorldId: 'world_1',
    targetLessonId: 'cards_ranks_suits',
    targetTaskId: 'cards_ranks_suits_private_board',
    targetFingerprint:
        'fa4595ef7ba62cb0ec2e2eec9ea7f2b1b6fbd8d593a79e844904373920fc60ff',
    targetCorrectChoiceId: 'board',
    targetChoiceIds: <String>{'board', 'private'},
    evidenceClass: 'diagnostic_learning_entry',
    mappingType: 'diagnostic_learning_entry',
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'what_poker_is',
    sourceTaskId: 'what_poker_is_table_read_transfer',
    sourceChoiceId: 'not_sure_yet',
    sourceCorrectChoiceId: 'check',
    sourceFingerprint: '', // Captured full variant witness, never base-only.
    sourceContainerFingerprint:
        '004cc7da3d67627764b31439a3f62b056b9d5b62b1c4e361cf7bbea86d2e0163',
    diagnosticVariantId: 'action_basics',
    sourceQuestion: 'No bet faces Hero. Which action is free?',
    sourceChoiceReason: 'Sharky will start simple.',
    sourceChoiceLabel: 'Not sure yet',
    sourceChoiceQuality: 'suboptimal',
    goalId: 'no_bet_free_continue',
    misconceptionId: 'free_action_unsure',
    relationId: 'placement_free_check_learning_entry_v1',
    relationRevision: 2,
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    targetFingerprint:
        'fd0c0733190724f0eb6676afa424ef4735fe28d294fcac8cc84f02b391b733f0',
    targetCorrectChoiceId: 'check',
    targetChoiceIds: <String>{'check', 'call', 'fold'},
    evidenceClass: 'diagnostic_learning_entry',
    mappingType: 'diagnostic_learning_entry',
  ),
  // New source-owned familiar retries. A pre-declaration intent cannot be
  // promoted into one of these relations by current lookup alone.
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "blinds_action_order",
    sourceTaskId: "blinds_first_actor",
    sourceChoiceId: "btn",
    sourceCorrectChoiceId: "utg",
    sourceFingerprint:
        "f9f8f3cc3b387f501e7461bbaad74e749c598f8efb4d12d39334997e25f2c0cb",
    sourceQuestion: "Who acts first preflop in this frame?",
    sourceChoiceReason: "The Button acts late, not first preflop.",
    sourceChoiceLabel: "BTN",
    goalId: "six_max_initial_preflop_first_actor",
    misconceptionId: "first_preflop_actor_read_as_button",
    relationId: "w01_blinds_first_actor_btn_intentional_exact_r1",
    targetWorldId: "world_1",
    targetLessonId: "blinds_action_order",
    targetTaskId: "blinds_first_actor",
    targetFingerprint:
        "f9f8f3cc3b387f501e7461bbaad74e749c598f8efb4d12d39334997e25f2c0cb",
    targetCorrectChoiceId: "utg",
    evidenceClass: "intentional_exact_replay",
    mappingType: "intentional_exact",
    targetChoiceIds: <String>{"utg", "btn"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "blinds_action_order",
    sourceTaskId: "blinds_last_actor",
    sourceChoiceId: "sb",
    sourceCorrectChoiceId: "bb",
    sourceFingerprint:
        "b8e7b5cbdcab6a10bf5fe9f7483b384f94c1249d49dddf86345a445ee7c12c98",
    sourceQuestion: "Who has the next option before the flop here?",
    sourceChoiceReason: "The small blind acts before the big blind preflop.",
    sourceChoiceLabel: "SB",
    goalId: "six_max_unraised_initial_pass_bb_option",
    misconceptionId: "matched_initial_bb_option_read_as_sb",
    relationId: "w01_blinds_last_actor_sb_intentional_exact_r1",
    targetWorldId: "world_1",
    targetLessonId: "blinds_action_order",
    targetTaskId: "blinds_last_actor",
    targetFingerprint:
        "b8e7b5cbdcab6a10bf5fe9f7483b384f94c1249d49dddf86345a445ee7c12c98",
    targetCorrectChoiceId: "bb",
    evidenceClass: "intentional_exact_replay",
    mappingType: "intentional_exact",
    targetChoiceIds: <String>{"sb", "bb"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "blinds_action_order",
    sourceTaskId: "blinds_review",
    sourceChoiceId: "btn",
    sourceCorrectChoiceId: "utg",
    sourceFingerprint:
        "0877b8a9cd70bcf04f609062ffdc672e8d47cab704d48df3ed512bd657cc46ee",
    sourceQuestion: "Who acts first preflop?",
    sourceChoiceReason:
        "In this 1.5 BB preflop pot, BTN waits behind UTG, HJ, and CO, so picking BTN misses that UTG faces the first voluntary decision.",
    sourceChoiceLabel: "BTN",
    goalId: "six_max_initial_preflop_first_actor",
    misconceptionId: "first_preflop_actor_read_as_button",
    relationId: "w01_blinds_review_btn_intentional_exact_r1",
    targetWorldId: "world_1",
    targetLessonId: "blinds_action_order",
    targetTaskId: "blinds_review",
    targetFingerprint:
        "0877b8a9cd70bcf04f609062ffdc672e8d47cab704d48df3ed512bd657cc46ee",
    targetCorrectChoiceId: "utg",
    evidenceClass: "intentional_exact_replay",
    mappingType: "intentional_exact",
    targetChoiceIds: <String>{"utg", "btn"},
    requireCapturedGoalWitness: true,
  ),
  Act0RepairGoalContractV1(
    sourceWorldId: "world_1",
    sourceLessonId: "blinds_action_order",
    sourceTaskId: "positions_utg",
    sourceChoiceId: "hj",
    sourceCorrectChoiceId: "utg",
    sourceFingerprint:
        "0e7879637ce83e3f17de92b4cbf992d935f767a5d2902c03b9a6926a42486b2a",
    sourceQuestion: "Tap UTG.",
    sourceChoiceReason: "HJ is after UTG in this order.",
    sourceChoiceLabel: "HJ",
    goalId: "utg_seat_identity",
    misconceptionId: "utg_seat_read_as_hj",
    relationId: "w01_positions_utg_hj_intentional_exact_r1",
    targetWorldId: "world_1",
    targetLessonId: "blinds_action_order",
    targetTaskId: "positions_utg",
    targetFingerprint:
        "0e7879637ce83e3f17de92b4cbf992d935f767a5d2902c03b9a6926a42486b2a",
    targetCorrectChoiceId: "utg",
    evidenceClass: "intentional_exact_replay",
    mappingType: "intentional_exact",
    targetChoiceIds: <String>{"hj", "utg"},
    requireCapturedGoalWitness: true,
  ),
];

Act0RepairGoalContractV1? act0RepairGoalContractForSourceV1({
  required String worldId,
  required String lessonId,
  required String taskId,
  required String choiceId,
  String diagnosticVariantId = '',
}) {
  final fallback = diagnosticVariantId.isEmpty
      ? _foundationRepairDefaults[(worldId, lessonId, taskId, choiceId)]
      : null;
  for (final row in act0RepairGoalContractsV1) {
    if (row.sourceWorldId == worldId &&
        row.sourceLessonId == lessonId &&
        row.sourceTaskId == taskId &&
        row.sourceChoiceId == choiceId &&
        row.diagnosticVariantId == diagnosticVariantId) {
      return row.hasValidatedTarget || row.isDiagnosticLearningEntry
          ? row
          : fallback ?? row;
    }
  }
  return fallback;
}

const _exerciseGoalPrefix = 'exercise/';
const act0SameGoalReplayThroughWorldV1 = 12;

// These are task-level goals shared by more than one exercise. A single
// exercise with no equivalent keeps its own goal and supports familiar replay.
const _foundationSharedRepairGoals = <String, String>{
  'what_poker_is_find_hero': 'shared_board_vs_private_cards',
  'cards_ranks_suits_private_board': 'shared_board_vs_private_cards',
  'cards_ranks_suits_rank_drill': 'card_rank_order',
  'blinds_first_actor': 'six_max_initial_preflop_first_actor',
  'blinds_review': 'six_max_initial_preflop_first_actor',
  'blinds_postflop_button': 'last_actor_after_flop',
  'positions_review': 'last_actor_after_flop',
  'blinds_last_actor': 'six_max_unraised_initial_pass_bb_option',
  'blinds_theory': 'big_blind_baseline',
  'blinds_posts_drill': 'big_blind_baseline',
  'actions_legal_context': 'no_bet_free_continue',
  'actions_check_drill': 'no_bet_free_continue',
  'your_first_hand_showdown': 'showdown_best_five',
  'showdown_best_hand_drill': 'showdown_best_five',
  'hand_discipline_buckets_premium': 'starting_hand_premium_bucket',
  'continue_or_let_go_premium_continue': 'starting_hand_premium_bucket',
  'discipline_checkpoint_checkpoint_premium': 'starting_hand_premium_bucket',
  'w4_half_pot_bet': 'half_pot_fraction',
  'board_texture_basics_w5_dry_board': 'dry_or_wet_flop',
  'board_texture_basics_w5_wet_board': 'dry_or_wet_flop',
  'connected_boards_w5_disconnected_board': 'connected_flop_ranks',
  'connected_boards_w5_connected_board': 'connected_flop_ranks',
  'flush_draws_w5_flush_draw_find': 'recognize_flush_draw',
  'flush_draws_w5_no_flush_draw': 'recognize_flush_draw',
  'flush_draws_w5_flush_draw_recheck_transfer': 'recognize_flush_draw',
  'straight_draws_w5_gutshot_draw': 'read_straight_draw_shape',
  'straight_draws_w5_gutshot_contrast_transfer': 'read_straight_draw_shape',
  'outs_improvement_w5_table_outs_flush_transfer': 'one_card_draw_price',
  'outs_improvement_w5_table_outs_straight_transfer': 'one_card_draw_price',
  'turn_river_changes_w5_board_checkpoint': 'one_card_draw_price',
  'w6_value_dry_board': 'recognize_range_bucket',
  'w6_missed_dry_board': 'recognize_range_bucket',
  'w6_wrong_board': 'recognize_range_bucket',
  'w6_value_wet_board': 'range_advantage_on_board',
  'w6_board_fit_recap': 'range_advantage_on_board',
  'w6_board_pair_strength_compare': 'range_advantage_on_board',
  'w6_ak_combos': 'two_rank_combo_count',
  'range_checkpoint_combos': 'two_rank_combo_count',
  'w6_combo_weight_compare': 'compare_combo_families',
  'w6_pair_vs_suited_weight_compare': 'compare_suited_combo_families',
  'w6_checkpoint_table_combo_weight': 'compare_combo_families',
  'w6_checkpoint_table_best_five': 'compare_suited_combo_families',
  'visible_king_combo_reduction_intro': 'visible_cards_reduce_combos',
  'visible_card_combo_density_transfer_check': 'visible_cards_reduce_combos',
  'w7_effective_stack_30bb': 'smaller_effective_stack',
  'w7_effective_stack_100bb': 'smaller_effective_stack',
  'w7_6max_wider': 'first_position_by_table_size',
  'w7_fullring_tighter': 'first_position_by_table_size',
  'w9_cash_vs_tournament': 'tournament_elimination_vs_reload',
  'w9_survival_stack_tradeoff': 'tournament_elimination_vs_reload',
  'w9_short_stack_survival': 'short_stack_action_window',
  'w9_checkpoint_survival_line': 'short_stack_action_window',
  'w9_m_ratio_yellow_zone': 'yellow_zone_action_window',
  'w9_m_ratio_table_window_transfer': 'yellow_zone_action_window',
  'w9_medium_stack_tighten': 'medium_stack_bubble_risk',
  'w9_checkpoint_bubble_line': 'medium_stack_bubble_risk',
  'w10_vs_nit_open_wider': 'widen_late_steals_against_overfolding',
  'w10_checkpoint_lever_line': 'widen_late_steals_against_overfolding',
  'w10_checkpoint_table_notice': 'widen_late_steals_against_overfolding',
  'w10_vs_caller_value_heavier': 'value_heavier_against_overcalling',
  'w10_table_value_vs_caller_transfer': 'value_heavier_against_overcalling',
  'w10_guardrail_sample_size': 'keep_adjustments_small_on_thin_evidence',
  'w10_checkpoint_guardrail_line': 'keep_adjustments_small_on_thin_evidence',
  'w11_plan_focus_choice': 'choose_one_measurable_session_focus',
  'w11_plan_table_focus_transfer': 'choose_one_measurable_session_focus',
  'w11_checkpoint_plan_line': 'choose_one_measurable_session_focus',
  'w11_review_pick_leak': 'choose_one_review_leak',
  'w11_checkpoint_review_line': 'choose_one_review_leak',
  'w12_good_fold_bad_result': 'review_process_before_outcome',
  'w12_checkpoint_process_line': 'review_process_before_outcome',
  'w12_after_bad_beat_reset': 'reset_before_the_next_tilt_decision',
  'w12_checkpoint_reset_line': 'reset_before_the_next_tilt_decision',
  'w12_assertive_not_ego': 'choose_evidence_over_ego_pressure',
  'w12_checkpoint_discipline_line': 'choose_evidence_over_ego_pressure',
};

String act0FoundationRepairGoalForTaskV1(String taskId) =>
    _foundationSharedRepairGoals[taskId] ?? '$_exerciseGoalPrefix$taskId';

typedef _FoundationRepairExercise = ({
  String worldId,
  String lessonId,
  Act0LessonTaskV1 task,
  Act0RunnerOptionV1 correct,
  String fingerprint,
});

final _foundationRepairDefaults = _buildFoundationRepairDefaults();

Map<(String, String, String, String), Act0RepairGoalContractV1>
_buildFoundationRepairDefaults() {
  final earliest = <String, _FoundationRepairExercise>{};
  final contracts =
      <(String, String, String, String), Act0RepairGoalContractV1>{};
  for (final world in Act0ShellStateV1.sample.worlds.take(
    act0SameGoalReplayThroughWorldV1,
  )) {
    final requireEarlierExercise = world.worldNumber >= 5;
    for (final lesson in world.lessons) {
      final sameLesson = <String, _FoundationRepairExercise>{};
      final exercises = <_FoundationRepairExercise>[];
      for (final task in lesson.courseTaskList) {
        final correct = task.runner.options.where(
          act0RunnerOptionIsAuthoredCorrectV1,
        );
        if (correct.length != 1) continue;
        final exercise = (
          worldId: world.worldId,
          lessonId: lesson.lessonId,
          task: task,
          correct: correct.single,
          fingerprint: act0AuthoredSourceFingerprintV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
          )!,
        );
        exercises.add(exercise);
        // Prefer the first choice in this lesson. For theory or a summary
        // with choices, use its own frame unless there is a drill to launch.
        if (task.phase == Act0LessonPhaseV1.drill) {
          final goal = act0FoundationRepairGoalForTaskV1(task.taskId);
          sameLesson.putIfAbsent(goal, () => exercise);
        }
      }
      for (final source in exercises) {
        final task = source.task;
        final goal = act0FoundationRepairGoalForTaskV1(task.taskId);
        final target = requireEarlierExercise
            ? earliest[goal] ?? source
            : sameLesson[goal] ?? earliest[goal] ?? source;
        final exact = identical(target.task, task);
        for (final choice in task.runner.options.where(
          (choice) => !choice.isCorrect,
        )) {
          contracts[(
            world.worldId,
            lesson.lessonId,
            task.taskId,
            choice.id,
          )] = Act0RepairGoalContractV1(
            sourceWorldId: source.worldId,
            sourceLessonId: source.lessonId,
            sourceTaskId: task.taskId,
            sourceChoiceId: choice.id,
            sourceCorrectChoiceId: source.correct.id,
            sourceFingerprint: source.fingerprint,
            sourceQuestion: task.runner.question,
            sourceChoiceReason: choice.feedbackReason,
            sourceChoiceLabel: choice.label,
            sourceChoiceQuality: choice.quality.name,
            goalId: goal,
            misconceptionId: choice.id,
            relationId: 'foundation_replay/${task.taskId}/${choice.id}',
            targetWorldId: target.worldId,
            targetLessonId: target.lessonId,
            targetTaskId: target.task.taskId,
            targetFingerprint: target.fingerprint,
            targetCorrectChoiceId: target.correct.id,
            targetChoiceIds: target.task.runner.options
                .map((option) => option.id)
                .toSet(),
            evidenceClass: exact
                ? 'intentional_exact_replay'
                : 'familiar_rehearsal',
            mappingType: exact ? 'intentional_exact' : 'repair',
            requireCapturedGoalWitness: true,
          );
        }
        if (requireEarlierExercise && task.phase == Act0LessonPhaseV1.drill) {
          earliest.putIfAbsent(goal, () => source);
        }
      }
      for (final entry in sameLesson.entries) {
        earliest.putIfAbsent(entry.key, () => entry.value);
      }
    }
  }
  return contracts;
}
