/// Stable, source-owned misconception identity for canonical Act0 decisions.
///
/// These ids are internal evidence values. They are never learner-visible and
/// intentionally do not encode answer position, copy, or an individual task.
class Act0ConceptErrorDefinitionV1 {
  const Act0ConceptErrorDefinitionV1({
    required this.id,
    required this.learnerInterpretation,
    required this.sourceConceptOwner,
    required this.eligibleRepairFamily,
    this.lessonKeys = const <String>{},
    this.taskKeys = const <String>{},
    this.legacyAliases = const <String>{},
  });

  final String id;
  final String learnerInterpretation;
  final String sourceConceptOwner;
  final String eligibleRepairFamily;
  final Set<String> lessonKeys;
  final Set<String> taskKeys;
  final Set<String> legacyAliases;

  bool get learnerVisible => false;
  bool get persisted => true;
  bool get emittedInTelemetry => true;
  String get telemetryCompatibility => 'existing_error_type_fields_v1';
  String get persistenceCompatibility =>
      'schema_unchanged_legacy_string_values_remain_readable';
}

const Set<String> act0LegacyGenericErrorTypesV1 = <String>{
  'missed_action_read',
  'missed_board_read',
  'missed_price_read',
  'missed_starting_hand_read',
  'missed_table_position_read',
  'missed_table_read',
  'thin_action_read',
  'thin_board_read',
  'thin_price_read',
  'thin_starting_hand_read',
  'thin_table_position_read',
  'thin_table_read',
  'unknown',
};

const List<Act0ConceptErrorDefinitionV1>
act0ConceptErrorDefinitionsV1 = <Act0ConceptErrorDefinitionV1>[
  Act0ConceptErrorDefinitionV1(
    id: 'confused_table_identity',
    learnerInterpretation:
        'Confused the learner seat, private cards, board, pot, or table role.',
    sourceConceptOwner: 'Act0ShellStateV1:first_table_identity',
    eligibleRepairFamily: 'table_identity',
    lessonKeys: <String>{'world_1/what_poker_is'},
    legacyAliases: <String>{'missed_table_read', 'thin_table_read'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_poker_win_condition',
    learnerInterpretation:
        'Confused folds, showdown, or the condition that awards the pot.',
    sourceConceptOwner: 'Act0ShellStateV1:what_poker_is_content',
    eligibleRepairFamily: 'poker_win_condition',
    lessonKeys: <String>{'world_1/what_poker_is_content'},
    legacyAliases: <String>{'missed_table_read', 'thin_table_read'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'confused_chip_commitment_eligibility',
    learnerInterpretation:
        'Confused pot versus stack, all-in commitment, or matched-pot eligibility.',
    sourceConceptOwner: 'Act0ShellStateV1:pot_stack_all_in_side_pot',
    eligibleRepairFamily: 'chip_commitment_eligibility',
    taskKeys: <String>{
      'world_1/what_poker_is_content/what_poker_is_pot_stack',
      'world_1/what_poker_is_content/what_poker_is_all_in_meaning',
      'world_1/what_poker_is_content/what_poker_is_matched_chips_transfer',
      'world_8/spr_and_commitment/what_poker_is_side_pot_intro',
    },
    legacyAliases: <String>{'missed_table_read', 'thin_table_read', 'unknown'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'confused_card_rank_suit',
    learnerInterpretation:
        'Confused a card rank, suit, or the basic rank ordering.',
    sourceConceptOwner: 'Act0ShellStateV1:cards_ranks_suits',
    eligibleRepairFamily: 'card_rank_suit_identity',
    lessonKeys: <String>{'world_1/cards_ranks_suits'},
    legacyAliases: <String>{'missed_board_read', 'unknown'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'confused_private_board_cards',
    learnerInterpretation:
        'Confused private cards with shared board cards or the board-card count.',
    sourceConceptOwner: 'Act0ShellStateV1:private_board_progression',
    eligibleRepairFamily: 'private_board_distinction',
    lessonKeys: <String>{'world_1/your_first_hand'},
    taskKeys: <String>{
      'world_1/cards_ranks_suits/cards_ranks_suits_private_board',
      'world_1/cards_ranks_suits/cards_ranks_suits_board_count',
    },
    legacyAliases: <String>{
      'missed_board_read',
      'thin_board_read',
      'missed_starting_hand_read',
      'thin_starting_hand_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_showdown_hand_strength',
    learnerInterpretation:
        'Misread the made hand, best-five comparison, or showdown winner.',
    sourceConceptOwner: 'Act0ShellStateV1:hand_rankings_showdown',
    eligibleRepairFamily: 'showdown_hand_strength',
    lessonKeys: <String>{
      'world_1/hand_rankings_table',
      'world_1/showdown_winning',
    },
    taskKeys: <String>{
      'world_1/cards_ranks_suits/cards_ranks_suits_best_five',
      'world_1/cards_ranks_suits/cards_ranks_suits_recap',
    },
    legacyAliases: <String>{'missed_board_read', 'thin_board_read'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_action_legality',
    learnerInterpretation:
        'Chose an action that did not match whether a bet or price was present.',
    sourceConceptOwner: 'Act0ShellStateV1:fold_check_call_raise',
    eligibleRepairFamily: 'action_legality',
    lessonKeys: <String>{'world_1/fold_check_call_raise'},
    legacyAliases: <String>{
      'missed_action_read',
      'thin_action_read',
      'missed_price_read',
      'thin_price_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_table_position',
    learnerInterpretation:
        'Misidentified a seat label or its location in the table order.',
    sourceConceptOwner: 'Act0ShellStateV1:position_identity',
    eligibleRepairFamily: 'table_position_identity',
    lessonKeys: <String>{'world_1/positions', 'world_3/position_six_seats'},
    legacyAliases: <String>{
      'missed_table_position_read',
      'thin_table_position_read',
      'missed_table_read',
      'thin_table_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_position_action_order',
    learnerInterpretation:
        'Misread who posts or acts, or how early and late position changes information.',
    sourceConceptOwner: 'Act0ShellStateV1:position_action_order',
    eligibleRepairFamily: 'position_action_order',
    lessonKeys: <String>{
      'world_1/blinds_action_order',
      'world_3/button_advantage',
      'world_3/early_vs_late',
      'world_3/same_hand_different_seat',
      'world_3/position_apply',
      'world_3/position_checkpoint',
    },
    legacyAliases: <String>{
      'missed_table_position_read',
      'thin_table_position_read',
      'missed_table_read',
      'thin_table_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_starting_hand_discipline',
    learnerInterpretation:
        'Misread hand bucket, domination risk, or the disciplined preflop action.',
    sourceConceptOwner: 'Act0ShellStateV1:world_2_hand_discipline',
    eligibleRepairFamily: 'starting_hand_discipline',
    lessonKeys: <String>{
      'world_2/hand_discipline_buckets',
      'world_2/fold_discipline',
      'world_2/weak_ace_warning',
      'world_2/continue_or_let_go',
      'world_2/hand_discipline_apply',
      'world_2/discipline_checkpoint',
    },
    legacyAliases: <String>{
      'missed_starting_hand_read',
      'thin_starting_hand_read',
      'missed_table_read',
      'thin_table_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_bet_price',
    learnerInterpretation:
        'Misread the call price, pot relationship, or bounded sizing example.',
    sourceConceptOwner: 'Act0ShellStateV1:world_4_price',
    eligibleRepairFamily: 'bet_price',
    lessonKeys: <String>{
      'world_4/call_price',
      'world_4/small_half_pot',
      'world_4/price_checkpoint',
    },
    legacyAliases: <String>{'missed_price_read', 'thin_price_read'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_bet_purpose',
    learnerInterpretation:
        'Confused value, bluff, protection, denial, or the purpose of betting.',
    sourceConceptOwner: 'Act0ShellStateV1:world_4_bet_purpose',
    eligibleRepairFamily: 'bet_purpose',
    lessonKeys: <String>{
      'world_4/why_bets_happen',
      'world_4/value_bets',
      'world_4/bluff_pressure',
      'world_4/protection_and_denial',
    },
    legacyAliases: <String>{
      'missed_table_read',
      'thin_table_read',
      'missed_board_read',
      'thin_board_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_board_texture',
    learnerInterpretation:
        'Misread board texture, connectivity, or a street-change clue.',
    sourceConceptOwner: 'Act0ShellStateV1:world_5_board_texture',
    eligibleRepairFamily: 'board_texture_awareness',
    lessonKeys: <String>{
      'world_5/board_texture_basics',
      'world_5/connected_boards',
      'world_5/turn_river_changes',
    },
    legacyAliases: <String>{'missed_board_read', 'thin_board_read'},
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_draw_outs',
    learnerInterpretation:
        'Misread a draw family, improvement card, or outs count.',
    sourceConceptOwner: 'Act0ShellStateV1:world_5_draw_outs',
    eligibleRepairFamily: 'draw_outs_awareness',
    lessonKeys: <String>{
      'world_5/flush_draws',
      'world_5/straight_draws',
      'world_5/outs_improvement',
    },
    legacyAliases: <String>{
      'missed_board_read',
      'thin_board_read',
      'missed_price_read',
      'thin_price_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_range_card_removal',
    learnerInterpretation:
        'Misread range width, board fit, combinations, or visible-card removal.',
    sourceConceptOwner: 'Act0ShellStateV1:world_6_world_7_range_reasoning',
    eligibleRepairFamily: 'range_card_removal_reasoning',
    lessonKeys: <String>{
      'world_6/range_bucket_basics',
      'world_6/range_board_fit',
      'world_6/range_combo_counts',
      'world_6/range_pressure_lines',
      'world_6/range_thinking_checkpoint',
      'world_7/range_thinking_lite_combo_density',
    },
    legacyAliases: <String>{
      'missed_board_read',
      'thin_board_read',
      'missed_table_read',
      'thin_table_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_stack_depth_risk',
    learnerInterpretation:
        'Misread effective stack, SPR, commitment, or depth-driven risk.',
    sourceConceptOwner: 'Act0ShellStateV1:world_8_stack_depth',
    eligibleRepairFamily: 'stack_depth_risk',
    lessonKeys: <String>{
      'world_8/effective_stack_basics',
      'world_8/spr_and_commitment',
      'world_8/same_hand_different_depth',
      'world_8/format_pressure',
    },
    legacyAliases: <String>{
      'missed_table_read',
      'thin_table_read',
      'missed_board_read',
      'thin_board_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_tournament_pressure',
    learnerInterpretation:
        'Misread survival pressure, risk premium, M-zone, or ladder pressure.',
    sourceConceptOwner: 'Act0ShellStateV1:world_9_tournament_pressure',
    eligibleRepairFamily: 'tournament_pressure_reasoning',
    lessonKeys: <String>{
      'world_9/survival_pressure_basics',
      'world_9/bubble_risk_premium',
      'world_9/m_ratio_zones_lite',
      'world_9/tournament_pressure_checkpoint',
    },
    legacyAliases: <String>{
      'missed_table_read',
      'thin_table_read',
      'missed_board_read',
      'thin_board_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_player_adjustment',
    learnerInterpretation:
        'Misread a player tendency, the one permitted adjustment, or its guardrail.',
    sourceConceptOwner: 'Act0ShellStateV1:world_10_player_adjustment',
    eligibleRepairFamily: 'player_adjustment_reasoning',
    lessonKeys: <String>{
      'world_10/player_type_basics',
      'world_10/adjust_one_lever',
      'world_10/exploit_guardrails',
      'world_10/player_adjustment_checkpoint',
    },
    legacyAliases: <String>{
      'missed_table_read',
      'thin_table_read',
      'missed_board_read',
      'thin_board_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_real_play_process',
    learnerInterpretation:
        'Misread session focus, table trigger, post-session review, or transfer process.',
    sourceConceptOwner: 'Act0ShellStateV1:world_11_real_play_process',
    eligibleRepairFamily: 'real_play_process_transfer',
    lessonKeys: <String>{
      'world_11/session_plan_basics',
      'world_11/table_trigger_reads',
      'world_11/post_session_review_loop',
      'world_11/real_play_transfer_checkpoint',
    },
    legacyAliases: <String>{
      'missed_table_read',
      'thin_table_read',
      'missed_board_read',
      'thin_board_read',
    },
  ),
  Act0ConceptErrorDefinitionV1(
    id: 'misread_mindset_discipline',
    learnerInterpretation:
        'Confused decision quality with outcome, or missed the reset and discipline process.',
    sourceConceptOwner: 'Act0ShellStateV1:world_12_mindset_process',
    eligibleRepairFamily: 'mindset_process_discipline',
    lessonKeys: <String>{
      'world_12/tilt_reset_protocol',
      'world_12/decision_over_outcome',
      'world_12/confidence_and_discipline',
      'world_12/mindset_bridge_checkpoint',
    },
    legacyAliases: <String>{
      'missed_table_read',
      'thin_table_read',
      'missed_board_read',
      'thin_board_read',
    },
  ),
];

Act0ConceptErrorDefinitionV1? act0ConceptErrorDefinitionForTaskV1({
  required String worldId,
  required String lessonId,
  required String taskId,
}) {
  final lessonKey = '${worldId.trim()}/${lessonId.trim()}';
  final taskKey = '$lessonKey/${taskId.trim()}';
  for (final definition in act0ConceptErrorDefinitionsV1) {
    if (definition.taskKeys.contains(taskKey)) {
      return definition;
    }
  }
  for (final definition in act0ConceptErrorDefinitionsV1) {
    if (definition.lessonKeys.contains(lessonKey)) {
      return definition;
    }
  }
  return null;
}

String act0ConceptErrorTypeForDecisionV1({
  required String result,
  required String worldId,
  required String lessonId,
  required String taskId,
}) {
  if (result == 'correct') {
    return 'none';
  }
  return act0ConceptErrorDefinitionForTaskV1(
        worldId: worldId,
        lessonId: lessonId,
        taskId: taskId,
      )?.id ??
      'unknown';
}

bool act0IsReadableErrorTypeV1(String raw) {
  final value = raw.trim();
  if (value == 'none' || act0LegacyGenericErrorTypesV1.contains(value)) {
    return true;
  }
  return act0ConceptErrorDefinitionsV1.any(
    (definition) => definition.id == value,
  );
}
