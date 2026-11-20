import 'package:flutter/semantics.dart';
import 'act0_accessibility_semantics_v1.dart';
import 'act0_w14_skill_state_v1.dart';
import 'act0_daily_practice_queue_v1.dart';
import 'act0_path_progress_v1.dart';
import 'act0_w1_rules_check_v1.dart';
import 'dart:async';
import 'act0_local_data_deletion_v1.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'dart:convert';
import 'act0_academy_runtime_adapter_v1.dart';
import 'act0_beta_metrics_v1.dart';
import 'act0_observability_projection_v1.dart';
import 'academy_leaves/act0_academy_home_leaf_v1.dart';
import 'academy_leaves/act0_academy_leaf_style_v1.dart';

import 'package:flutter/foundation.dart'
    show kDebugMode, kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_cross_session_profile_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_first_start_preferences_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_receipt_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_same_session_learning_delta_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_last_session_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_premium_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_identity_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_price_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_board_texture_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_hand_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_improvement_observation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_preferences_service.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_user_launch_consumer_v1.dart';

import 'act0_practice_reminder_v1.dart';

part 'act0_shell_preview_telemetry_v1.dart';
part 'act0_shell_preview_copy_v1.dart';
part 'act0_shell_preview_debug_surfaces_v1.dart';
part 'act0_shell_preview_persistence_v1.dart';
part 'act0_shell_preview_learning_run_v1.dart';
part 'act0_shell_preview_home_v1.dart';
part 'act0_shell_preview_launch_v1.dart';
part 'act0_shell_preview_placement_v1.dart';
part 'act0_shell_preview_w1_rules_v1.dart';
part 'act0_shell_preview_answer_v1.dart';
part 'act0_shell_preview_profile_v1.dart';
part 'act0_shell_preview_flow_v1.dart';

@visibleForTesting
bool act0DevMenuEnabledV1({required bool isReleaseMode}) => !isReleaseMode;

/// Consecutive *local calendar* days, independent of elapsed UTC hours.
///
/// Both inputs are local YYYY-MM-DD keys produced by _todayDateString().
/// Normalizing civil dates to UTC prevents a 23-hour spring DST day from
/// incorrectly breaking a completed daily-practice streak.
@visibleForTesting
bool act0AreConsecutiveCivilDaysV1(String previousDay, String today) {
  if (previousDay.isEmpty) return false;
  try {
    final previous = DateTime.parse(previousDay);
    final current = DateTime.parse(today);
    final previousCivil = DateTime.utc(
      previous.year,
      previous.month,
      previous.day,
    );
    final currentCivil = DateTime.utc(current.year, current.month, current.day);
    return currentCivil.difference(previousCivil) == const Duration(days: 1);
  } catch (_) {
    return false;
  }
}

Act0RepairIntentV1 _migratePersistedW1HeroButtonIntentV1(
  Act0RepairIntentV1 intent,
) {
  if (intent.sourceWorldId != 'world_1' ||
      intent.sourceLessonId != 'what_poker_is' ||
      intent.sourceTaskId != 'what_poker_is_find_hero' ||
      intent.result != 'incorrect' ||
      intent.errorType != 'confused_table_identity' ||
      intent.missedSignalId != 'hero_button' ||
      intent.skillAtomId != 'table_position_read' ||
      intent.mappingType != 'repair' ||
      intent.reasonCode != 'same_signal_table_position_read_hero_button' ||
      intent.targetWorldId != 'world_3' ||
      intent.targetLessonId != 'position_checkpoint' ||
      intent.targetTaskId !=
          'position_checkpoint_position_checkpoint_table_notice') {
    return intent;
  }
  return Act0RepairIntentV1(
    schemaVersion: intent.schemaVersion,
    repairOccurrenceId: intent.repairOccurrenceId,
    goalId: intent.goalId,
    relationId: intent.relationId,
    relationRevision: intent.relationRevision,
    sourceFingerprint: intent.sourceFingerprint,
    targetFingerprint: intent.targetFingerprint,
    sourceWorldId: intent.sourceWorldId,
    sourceLessonId: intent.sourceLessonId,
    sourceTaskId: intent.sourceTaskId,
    choiceId: intent.choiceId,
    result: intent.result,
    errorType: intent.errorType,
    missedSignalId: intent.missedSignalId,
    missedSignalLabel: intent.missedSignalLabel,
    skillAtomId: intent.skillAtomId,
    skillLabel: intent.skillLabel,
    targetWorldId: 'world_3',
    targetLessonId: 'position_six_seats',
    targetTaskId: 'position_six_seats_position_repair_seat_id_btn',
    mappingType: intent.mappingType,
    reasonCode: intent.reasonCode,
  );
}

({String worldId, String lessonId, String taskId, String mappingType})?
act0FirstValueSameSignalRepMappingV1({
  required String nextRepId,
  required String skillAtomId,
  required String sourceSignalId,
  required String sourceTaskId,
  required String receiptOutcome,
}) {
  final isRepair =
      receiptOutcome == 'repair_started' || receiptOutcome == 'needs_rep';
  final sourceTask = sourceTaskId.trim();

  ({String worldId, String lessonId, String taskId, String mappingType}) target(
    String worldId,
    String lessonId,
    String taskId,
  ) {
    return (
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      mappingType: isRepair ? 'repair' : 'reinforcement',
    );
  }

  final adjudication = act0RepairGapAdjudicationForSourceTaskV1(sourceTask);
  // This W1 correction applies to repair receipts only. Preserve its existing
  // learned-receipt reinforcement route and all other adjudication behavior.
  if (adjudication != null &&
      (sourceTask != 'what_poker_is_find_hero' || isRepair)) {
    return switch (adjudication.outcome) {
      Act0RepairGapOutcomeV1.alternateSameSignalTarget ||
      Act0RepairGapOutcomeV1.newBoundedRepairItem => (
        worldId: adjudication.targetWorldId!,
        lessonId: adjudication.targetLessonId!,
        taskId: adjudication.targetTaskId!,
        mappingType: adjudication.mappingType,
      ),
      Act0RepairGapOutcomeV1.intentionalExactReplay ||
      Act0RepairGapOutcomeV1.unresolvedProductGap => (
        worldId: adjudication.sourceWorldId,
        lessonId: adjudication.sourceLessonId,
        taskId: adjudication.sourceTaskId,
        mappingType: adjudication.mappingType,
      ),
    };
  }

  // The corrected theory and the existing drill both teach the full 1 BB post.
  if (sourceTask == 'blinds_theory' &&
      nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'big_blind') {
    return target('world_1', 'blinds_action_order', 'blinds_posts_drill');
  }

  // Explicitly admitted concept pairs share their actual receipt semantics.
  if (nextRepId == 'repeat_range_bucket_reasoning' &&
      skillAtomId == 'range_bucket_reasoning' &&
      sourceSignalId == 'range_bucket_shift') {
    switch (sourceTask) {
      case 'w6_turn_shift_bucket':
        return target(
          'world_6',
          'range_pressure_lines',
          'w6_turn_pressure_shift_transfer',
        );
      case 'w6_turn_pressure_shift_transfer':
        return target('world_6', 'range_board_fit', 'w6_turn_shift_bucket');
    }
  }

  if (nextRepId == 'repeat_board_texture_reasoning' &&
      skillAtomId == 'board_texture_reasoning' &&
      sourceSignalId == 'board_texture_change') {
    switch (sourceTask) {
      case 'w6_wet_board_repair':
        return target(
          'world_5',
          'turn_river_changes',
          'turn_river_changes_w5_turn_texture_shift_transfer',
        );
      case 'turn_river_changes_w5_turn_texture_shift_transfer':
        return target('world_6', 'range_pressure_lines', 'w6_wet_board_repair');
    }
  }

  if (nextRepId == 'repeat_mindset_process_discipline' &&
      skillAtomId == 'mindset_process_discipline' &&
      sourceSignalId == 'process_over_outcome') {
    switch (sourceTask) {
      // These fixed-price authored cases share the same process skill.
      // Admit only repair; preserve existing learned-reinforcement behavior.
      case 'asm05_new_known_holes_turn_call_10':
        if (!isRepair) return null;
        return target(
          'world_12',
          'decision_over_outcome',
          'asm05_new_known_holes_turn_call_40',
        );
      case 'asm05_new_known_holes_turn_call_40':
        if (!isRepair) return null;
        return target(
          'world_12',
          'decision_over_outcome',
          'asm05_new_known_holes_turn_call_10',
        );
      case 'w12_bad_call_good_result':
        return target(
          'world_12',
          'mindset_bridge_checkpoint',
          'w12_checkpoint_process_line',
        );
      case 'w12_checkpoint_process_line':
        return target(
          'world_12',
          'decision_over_outcome',
          'w12_bad_call_good_result',
        );
    }
  }

  if (sourceTask == Act0PositionPersonalizationV1.sourceTaskId &&
      nextRepId == 'repeat_table_position_read' &&
      skillAtomId == 'table_position_read' &&
      sourceSignalId == 'hero_button') {
    return target(
      Act0PositionPersonalizationV1.worldId,
      Act0PositionPersonalizationV1.lessonId,
      Act0PositionPersonalizationV1.repairTaskId,
    );
  }

  if (nextRepId == 'repeat_board_read' &&
      skillAtomId == 'board_read' &&
      sourceSignalId == 'board_cards') {
    switch (sourceTask) {
      case 'visible_king_combo_reduction_intro':
        return target(
          'world_7',
          'range_thinking_lite_combo_density',
          'paired_board_texture_lite_intro',
        );
      case 'paired_board_texture_lite_intro':
        return target(
          'world_7',
          'range_thinking_lite_combo_density',
          'visible_card_combo_density_transfer_check',
        );
      case 'visible_card_combo_density_transfer_check':
        return target(
          'world_7',
          'range_thinking_lite_combo_density',
          'visible_king_combo_reduction_intro',
        );
    }
  }

  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'stack_depth') {
    switch (sourceTask) {
      case 'short_stack_all_in_pressure_intro':
        return target('world_8', 'spr_and_commitment', 'w7_low_spr_commit');
      case 'deep_stack_postflop_room_intro':
        return target('world_8', 'spr_and_commitment', 'w7_high_spr_room');
      case 'stack_to_pot_commitment_lite':
        return target('world_8', 'spr_and_commitment', 'w7_spr4_middle');
      case 'all_in_threshold_transfer_check':
        return target('world_8', 'same_hand_different_depth', 'w7_20bb_wider');
    }
  }

  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'tournament_pressure') {
    switch (sourceTask) {
      case 'bubble_survival_pressure_intro':
        return target(
          'world_9',
          'survival_pressure_basics',
          'w9_short_stack_survival',
        );
      case 'risk_premium_medium_stack_intro':
        return target(
          'world_9',
          'bubble_risk_premium',
          'w9_medium_stack_tighten',
        );
      case 'short_stack_ladder_pressure_lite':
        return target(
          'world_9',
          'bubble_risk_premium',
          'w9_bubble_short_stack',
        );
      case 'pressure_transfer_check':
        return target(
          'world_9',
          'tournament_pressure_checkpoint',
          'w9_checkpoint_table_notice',
        );
    }
  }

  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'player_tendency') {
    switch (sourceTask) {
      case 'w10_nit_tag':
        return target(
          'world_10',
          'player_type_basics',
          'w10_loose_passive_tag',
        );
      case 'w10_loose_passive_tag':
        return target(
          'world_10',
          'player_type_basics',
          'w10_overaggressive_tag',
        );
      case 'w10_vs_nit_open_wider':
        return target(
          'world_10',
          'adjust_one_lever',
          'w10_vs_caller_value_heavier',
        );
      case 'w10_guardrail_sample_size':
        return target(
          'world_10',
          'player_adjustment_checkpoint',
          'w10_checkpoint_guardrail_line',
        );
    }
  }

  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'session_plan') {
    switch (sourceTask) {
      case 'w11_plan_focus_choice':
        return target(
          'world_11',
          'session_plan_basics',
          'w11_plan_avoid_overload',
        );
      case 'w11_trigger_overfold_blinds':
        return target(
          'world_11',
          'table_trigger_reads',
          'w11_trigger_overcall_flop',
        );
      case 'w11_review_pick_leak':
        return target(
          'world_11',
          'post_session_review_loop',
          'w11_review_define_fix',
        );
    }
  }

  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'tilt_reset') {
    switch (sourceTask) {
      case 'w12_after_bad_beat_reset':
        return target(
          'world_12',
          'tilt_reset_protocol',
          'w12_after_mistake_reset',
        );
      case 'w12_good_fold_bad_result':
        return target(
          'world_12',
          'decision_over_outcome',
          'w12_bad_call_good_result',
        );
      case 'w12_assertive_not_ego':
        return target(
          'world_12',
          'confidence_and_discipline',
          'w12_discipline_under_pressure',
        );
    }
  }

  if (nextRepId == 'repeat_starting_hand_read' &&
      skillAtomId == 'starting_hand_read' &&
      sourceSignalId == 'hero_cards') {
    switch (sourceTask) {
      case 'hand_discipline_buckets_premium':
        return target(
          'world_2',
          'hand_discipline_buckets',
          'hand_discipline_buckets_strong',
        );
      case 'hand_discipline_buckets_strong':
        return target(
          'world_2',
          'hand_discipline_buckets',
          'hand_discipline_buckets_medium',
        );
      case 'hand_discipline_buckets_medium':
      case 'hand_discipline_buckets_trash':
        return target(
          'world_2',
          'hand_discipline_buckets',
          'hand_discipline_buckets_borderline',
        );
      case 'hand_discipline_buckets_borderline':
        return target(
          'world_2',
          'hand_discipline_buckets',
          'hand_discipline_buckets_medium',
        );
    }
  }

  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'hero_cards_board_pot') {
    switch (sourceTask) {
      case 'w4_value_purpose':
        return target('world_4', 'why_bets_happen', 'w4_bluff_purpose');
      case 'w4_bluff_purpose':
        return target('world_4', 'why_bets_happen', 'w4_value_purpose');
      case 'w6_value_dry_board':
        return target('world_6', 'range_bucket_basics', 'w6_missed_dry_board');
      case 'w6_missed_dry_board':
      case 'w6_table_bucket_notice':
        return target('world_6', 'range_bucket_basics', 'w6_value_dry_board');
      case 'w6_wrong_board':
        return target('world_6', 'range_pressure_lines', 'w6_wet_board_repair');
      case 'w6_value_wet_board':
      case 'w6_turn_shift_bucket':
        return target('world_6', 'range_board_fit', 'w6_wrong_board');
    }
  }

  if (nextRepId == 'repeat_board_read' &&
      skillAtomId == 'board_read' &&
      sourceSignalId == 'board_cards') {
    switch (sourceTask) {
      case 'w4_protection_bet':
        return target(
          'world_4',
          'protection_and_denial',
          'w4_protection_check',
        );
      case 'w4_protection_check':
        return target('world_4', 'protection_and_denial', 'w4_protection_bet');
      case 'board_texture_basics_w5_dry_board':
        return target(
          'world_5',
          'board_texture_basics',
          'board_texture_basics_w5_wet_board',
        );
      case 'board_texture_basics_w5_wet_board':
        return target(
          'world_5',
          'board_texture_basics',
          'board_texture_basics_w5_dry_board',
        );
      case 'connected_boards_w5_disconnected_board':
        return target(
          'world_5',
          'connected_boards',
          'connected_boards_w5_connected_board',
        );
      case 'connected_boards_w5_connected_board':
        return target(
          'world_5',
          'connected_boards',
          'connected_boards_w5_disconnected_board',
        );
    }
  }

  if (nextRepId == 'repeat_price_read' &&
      skillAtomId == 'price_read' &&
      sourceSignalId == 'pot_to_call') {
    switch (sourceTask) {
      case 'w4_good_price_call':
      case 'w4_cheap_price_marginal_call':
        return target('world_4', 'call_price', 'w4_bad_price_fold');
      case 'w4_bad_price_fold':
      case 'w4_big_price_marginal_fold':
        return target('world_4', 'call_price', 'w4_good_price_call');
    }
  }

  if (nextRepId == 'repeat_action_read' &&
      skillAtomId == 'action_read' &&
      sourceSignalId == 'no_bet_yet') {
    switch (sourceTask) {
      case 'w6_value_range_action':
        return target('world_6', 'range_pressure_lines', 'w6_bluff_candidate');
      case 'w6_bluff_candidate':
        return target(
          'world_6',
          'range_pressure_lines',
          'w6_missed_hand_action',
        );
      case 'w6_missed_hand_action':
        return target(
          'world_6',
          'range_pressure_lines',
          'w6_value_range_action',
        );
    }
  }

  if (nextRepId == 'repeat_action_read' &&
      skillAtomId == 'action_read' &&
      sourceSignalId == 'no_bet_yet' &&
      sourceTask != 'actions_check_drill') {
    return (
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_check_drill',
      mappingType: isRepair ? 'repair' : 'reinforcement',
    );
  }
  if (nextRepId == 'repeat_board_read' &&
      skillAtomId == 'board_read' &&
      sourceSignalId == 'board_cards') {
    if (sourceTask == 'your_first_hand_flop') {
      return (
        worldId: 'world_1',
        lessonId: 'your_first_hand',
        taskId: 'your_first_hand_turn',
        mappingType: isRepair ? 'repair' : 'reinforcement',
      );
    }
    if (sourceTask != 'cards_ranks_suits_board_count' &&
        sourceTask != 'your_first_hand_turn') {
      return (
        worldId: 'world_1',
        lessonId: 'cards_ranks_suits',
        taskId: 'cards_ranks_suits_board_count',
        mappingType: isRepair ? 'repair' : 'reinforcement',
      );
    }
  }
  if (nextRepId == 'repeat_price_read' &&
      skillAtomId == 'price_read' &&
      sourceSignalId == 'pot_to_call' &&
      sourceTask != 'actions_call_drill') {
    return (
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_call_drill',
      mappingType: isRepair ? 'repair' : 'reinforcement',
    );
  }
  if (nextRepId == 'repeat_starting_hand_read' &&
      skillAtomId == 'starting_hand_read' &&
      sourceSignalId == 'hero_cards' &&
      sourceTask != 'your_first_hand_private_cards_recheck') {
    return (
      worldId: 'world_1',
      lessonId: 'your_first_hand',
      taskId: 'your_first_hand_private_cards_recheck',
      mappingType: isRepair ? 'repair' : 'reinforcement',
    );
  }
  if (nextRepId == 'repeat_table_read' &&
      skillAtomId == 'table_read' &&
      sourceSignalId == 'hero_cards_board_pot' &&
      sourceTask != 'what_poker_is_table_read_recheck') {
    return (
      worldId: 'world_1',
      lessonId: 'what_poker_is',
      taskId: 'what_poker_is_table_read_recheck',
      mappingType: isRepair ? 'repair' : 'reinforcement',
    );
  }
  if (nextRepId == 'repeat_table_position_read' &&
      skillAtomId == 'table_position_read' &&
      sourceSignalId == 'hero_button' &&
      sourceTask != 'position_checkpoint_position_checkpoint_table_notice') {
    return (
      worldId: 'world_3',
      lessonId: 'position_checkpoint',
      taskId: 'position_checkpoint_position_checkpoint_table_notice',
      mappingType: isRepair ? 'repair' : 'reinforcement',
    );
  }
  return null;
}

Act0RunnerStateV1 normalizeAct0SeatTapRunnerV1(Act0RunnerStateV1 runner) {
  final seatOptions = runner.options
      .where((option) => (option.seatId ?? '').trim().isNotEmpty)
      .toList(growable: false);
  if (seatOptions.isEmpty) {
    return runner;
  }

  Act0RunnerOptionV1? correctOption;
  for (final option in seatOptions) {
    if (option.isCorrect) {
      correctOption = option;
      break;
    }
  }
  if (correctOption == null) {
    return runner;
  }

  final visibleSeats = runner.table.seats
      .where((seat) {
        final seatId = seat.seatId.trim();
        return seatId.isNotEmpty && (seat.isOccupied || seat.isHero);
      })
      .toList(growable: false);
  if (visibleSeats.isEmpty) {
    return runner;
  }

  final optionsBySeatId = <String, Act0RunnerOptionV1>{
    for (final option in seatOptions) option.seatId!.trim(): option,
  };
  final correctSeatId = correctOption.seatId!.trim();
  final expandedOptions = <Act0RunnerOptionV1>[
    for (final seat in visibleSeats)
      optionsBySeatId[seat.seatId.trim()] ??
          Act0RunnerOptionV1(
            id: '__seat_tap__${runner.lessonId}_${seat.seatId.trim()}',
            label: seat.seatLabel,
            seatId: seat.seatId.trim(),
            isCorrect: false,
            preferredLabel: correctOption.preferredLabel,
            betterAnswerLabel: correctOption.betterAnswerLabel,
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Not quite.',
            feedbackReason:
                '${seat.seatLabel} is not the target seat in this spot.',
            repairFocusSeatIds: <String>[seat.seatId.trim(), correctSeatId],
            repairFocusLabels: <String>[
              seat.seatLabel,
              correctOption.preferredLabel,
            ],
          ),
  ];

  return runner.copyWith(
    options: expandedOptions,
    table: runner.table.copyWith(
      selectableSeatIds: visibleSeats
          .map((seat) => seat.seatId.trim())
          .toList(growable: false),
    ),
  );
}

Act0RunnerStateV1 normalizeAct0DrillSeatHighlightPolicyV1(
  Act0RunnerStateV1 runner,
) {
  if (runner.phase != Act0LessonPhaseV1.drill) {
    return runner;
  }
  final activeSeatId = (runner.table.activeSeatId ?? '').trim();
  return runner.copyWith(
    table: runner.table.copyWith(
      activeSeatId: activeSeatId,
      highlightedSeatIds: activeSeatId.isEmpty
          ? const <String>[]
          : <String>[activeSeatId],
    ),
  );
}

Act0RunnerOptionV1 _placementCorrectOptionV1({
  required String id,
  required String label,
  required String feedbackTitle,
  required String feedbackReason,
  List<String> repairFocusSeatIds = const <String>[],
  List<String> repairFocusCardIds = const <String>[],
  List<String> repairFocusLabels = const <String>[],
}) {
  return Act0RunnerOptionV1(
    id: id,
    label: label,
    isCorrect: true,
    preferredLabel: label,
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: feedbackTitle,
    feedbackReason: feedbackReason,
    repairFocusSeatIds: repairFocusSeatIds,
    repairFocusCardIds: repairFocusCardIds,
    repairFocusLabels: repairFocusLabels,
  );
}

Act0RunnerOptionV1 _placementWrongOptionV1({
  required String id,
  required String label,
  required String preferredLabel,
  required String feedbackReason,
  List<String> repairFocusSeatIds = const <String>[],
  List<String> repairFocusCardIds = const <String>[],
  List<String> repairFocusLabels = const <String>[],
}) {
  return Act0RunnerOptionV1(
    id: id,
    label: label,
    isCorrect: false,
    preferredLabel: preferredLabel,
    betterAnswerLabel: preferredLabel,
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Good check.',
    feedbackReason: feedbackReason,
    repairFocusSeatIds: repairFocusSeatIds,
    repairFocusCardIds: repairFocusCardIds,
    repairFocusLabels: repairFocusLabels,
  );
}

Act0RunnerOptionV1 _placementUnsureOptionV1({
  required String preferredLabel,
  required bool isRu,
  List<String> repairFocusSeatIds = const <String>[],
  List<String> repairFocusCardIds = const <String>[],
  List<String> repairFocusLabels = const <String>[],
}) {
  return Act0RunnerOptionV1(
    id: 'not_sure_yet',
    label: isRu ? 'Пока не уверен' : 'Not sure yet',
    isCorrect: false,
    preferredLabel: preferredLabel,
    betterAnswerLabel: preferredLabel,
    quality: Act0FeedbackQualityV1.suboptimal,
    feedbackTitle: isRu ? 'Ничего страшного.' : 'No problem.',
    feedbackReason: isRu ? 'Шарки начнёт проще.' : 'Sharky will start simple.',
    repairFocusSeatIds: repairFocusSeatIds,
    repairFocusCardIds: repairFocusCardIds,
    repairFocusLabels: repairFocusLabels,
  );
}

List<Act0RunnerOptionV1> _placementDiagnosticOptionsV1(
  String signalId, {
  required bool isRu,
}) {
  return switch (signalId) {
    'table_read' => <Act0RunnerOptionV1>[
      _placementCorrectOptionV1(
        id: 'two_three_six',
        label: isRu
            ? '2 личные · 3 общие · Банк 6 BB'
            : '2 private · 3 board · Pot 6 BB',
        feedbackTitle: isRu ? 'Хорошее чтение.' : 'Clean read.',
        feedbackReason: isRu
            ? 'Верно: две личные карты, три общие карты и банк 6 BB.'
            : 'Right: two private cards, three board cards, and a 6 BB pot.',
        repairFocusCardIds: const <String>[
          'hero_0',
          'hero_1',
          'board_0',
          'board_1',
          'board_2',
        ],
        repairFocusLabels: const <String>['Hero cards', 'Board cards', 'Pot'],
      ),
      _placementWrongOptionV1(
        id: 'two_five_six',
        label: isRu
            ? '2 личные · 5 общих · Банк 6 BB'
            : '2 private · 5 board · Pot 6 BB',
        preferredLabel: isRu
            ? '2 личные · 3 общие · Банк 6 BB'
            : '2 private · 3 board · Pot 6 BB',
        feedbackReason: isRu
            ? 'Сейчас на борде только три общие карты: это флоп.'
            : 'Only three board cards are out: this is the flop.',
        repairFocusCardIds: const <String>[
          'hero_0',
          'hero_1',
          'board_0',
          'board_1',
          'board_2',
        ],
        repairFocusLabels: const <String>['Hero cards', 'Board cards', 'Pot'],
      ),
      _placementWrongOptionV1(
        id: 'two_three_four',
        label: isRu
            ? '2 личные · 3 общие · Банк 4 BB'
            : '2 private · 3 board · Pot 4 BB',
        preferredLabel: isRu
            ? '2 личные · 3 общие · Банк 6 BB'
            : '2 private · 3 board · Pot 6 BB',
        feedbackReason: isRu
            ? 'Карт посчитано верно, но в центре лежит банк 6 BB.'
            : 'The card counts are right, but the pot in the center is 6 BB.',
        repairFocusCardIds: const <String>[
          'hero_0',
          'hero_1',
          'board_0',
          'board_1',
          'board_2',
        ],
        repairFocusLabels: const <String>['Hero cards', 'Board cards', 'Pot'],
      ),
      _placementUnsureOptionV1(
        preferredLabel: isRu
            ? '2 личные · 3 общие · Банк 6 BB'
            : '2 private · 3 board · Pot 6 BB',
        isRu: isRu,
        repairFocusCardIds: const <String>[
          'hero_0',
          'hero_1',
          'board_0',
          'board_1',
          'board_2',
        ],
        repairFocusLabels: const <String>['Hero cards', 'Board cards', 'Pot'],
      ),
    ],
    'board_private_cards' => <Act0RunnerOptionV1>[
      _placementCorrectOptionV1(
        id: 'board_cards',
        label: isRu ? 'Карты борда' : 'Board cards',
        feedbackTitle: isRu ? 'Хорошее чтение.' : 'Clean read.',
        feedbackReason: isRu
            ? 'Карты борда доступны всем, кто ещё в раздаче.'
            : 'Board cards are shared by everyone still in the hand.',
        repairFocusCardIds: const <String>['board_0', 'board_1', 'board_2'],
        repairFocusLabels: const <String>['Board cards'],
      ),
      _placementWrongOptionV1(
        id: 'hero_private_cards',
        label: isRu ? 'Личные карты Hero' : 'Hero’s private cards',
        preferredLabel: isRu ? 'Карты борда' : 'Board cards',
        feedbackReason: isRu
            ? 'Личные карты Hero видит только Hero. Общие карты лежат на борде.'
            : 'Hero’s private cards belong only to Hero. Board cards are shared.',
        repairFocusCardIds: const <String>['board_0', 'board_1', 'board_2'],
        repairFocusLabels: const <String>['Board cards'],
      ),
      _placementWrongOptionV1(
        id: 'dealer_button',
        label: isRu ? 'Кнопка дилера' : 'Dealer button',
        preferredLabel: isRu ? 'Карты борда' : 'Board cards',
        feedbackReason: isRu
            ? 'Кнопка показывает позицию. Общие карты — это карты борда.'
            : 'The button marks position. Shared cards are the board cards.',
        repairFocusCardIds: const <String>['board_0', 'board_1', 'board_2'],
        repairFocusLabels: const <String>['Board cards'],
      ),
      _placementUnsureOptionV1(
        preferredLabel: isRu ? 'Карты борда' : 'Board cards',
        isRu: isRu,
        repairFocusCardIds: const <String>['board_0', 'board_1', 'board_2'],
        repairFocusLabels: const <String>['Board cards'],
      ),
    ],
    'action_basics' => <Act0RunnerOptionV1>[
      _placementCorrectOptionV1(
        id: 'check',
        label: isRu ? 'Чек' : 'Check',
        feedbackTitle: isRu ? 'Хорошее чтение.' : 'Clean read.',
        feedbackReason: isRu
            ? 'Перед Hero нет ставки, значит чек — бесплатное действие.'
            : 'No bet faces Hero, so checking is the free action.',
        repairFocusLabels: const <String>['No bet yet'],
      ),
      _placementWrongOptionV1(
        id: 'call',
        label: isRu ? 'Колл' : 'Call',
        preferredLabel: isRu ? 'Чек' : 'Check',
        feedbackReason: isRu
            ? 'Колл отвечает на ставку. Здесь перед Hero ставки нет, поэтому чек бесплатный.'
            : 'Calling matches a bet. Here no bet faces Hero, so checking is free.',
        repairFocusLabels: const <String>['No bet yet'],
      ),
      _placementWrongOptionV1(
        id: 'raise',
        label: isRu ? 'Рейз' : 'Raise',
        preferredLabel: isRu ? 'Чек' : 'Check',
        feedbackReason: isRu
            ? 'Рейз добавляет давление. Когда перед Hero нет ставки, бесплатное действие — чек.'
            : 'Raising adds pressure. With no bet facing Hero, the free action is check.',
        repairFocusLabels: const <String>['No bet yet'],
      ),
      _placementUnsureOptionV1(
        preferredLabel: isRu ? 'Чек' : 'Check',
        isRu: isRu,
        repairFocusLabels: const <String>['No bet yet'],
      ),
    ],
    _ => <Act0RunnerOptionV1>[
      _placementUnsureOptionV1(
        preferredLabel: isRu ? 'Начать проще' : 'Start simple',
        isRu: isRu,
      ),
    ],
  };
}

String _placementDiagnosticQuestionV1(String signalId, {required bool isRu}) {
  return switch (signalId) {
    'board_private_cards' =>
      isRu ? 'Какие карты доступны всем?' : 'Which cards can everyone use?',
    'action_basics' =>
      isRu
          ? 'Перед Hero нет ставки. Какое действие бесплатно?'
          : 'No bet faces Hero. Which action is free?',
    _ => isRu ? 'Что показывает этот стол?' : 'What does this table show?',
  };
}

String _placementDiagnosticHintV1(String signalId, {required bool isRu}) {
  return switch (signalId) {
    'board_private_cards' =>
      isRu
          ? 'Общие карты лежат на борде.'
          : 'Shared cards belong to the board.',
    'action_basics' =>
      isRu
          ? 'Без ставки Hero может передать ход.'
          : 'No bet means Hero can pass the action.',
    _ =>
      isRu
          ? 'Сначала посчитай личные карты, общие карты и банк.'
          : 'Count private cards, board cards, then the pot.',
  };
}

String _placementDiagnosticCaptionV1(String signalId, {required bool isRu}) {
  return switch (signalId) {
    'board_private_cards' =>
      isRu ? 'Найди общие карты.' : 'Read which cards are shared.',
    'action_basics' =>
      isRu
          ? 'В этом споте перед Hero нет ставки.'
          : 'No bet faces Hero in this spot.',
    _ =>
      isRu
          ? 'Один раз посчитай личные карты, общие карты и банк.'
          : 'Count private cards, board cards, and pot once.',
  };
}

Act0RunnerStateV1 placementQuickCheckRunnerV1(
  Act0RunnerStateV1 runner, {
  required String signalId,
  required int checkIndex,
  required int checkCount,
  bool isRu = false,
}) {
  return runner.copyWith(
    lessonTitle: isRu ? 'Быстрая проверка стола' : 'Quick table check',
    lessonSubtitle: isRu
        ? 'Три короткие проверки перед первой раздачей.'
        : 'Three short checks before your first hand.',
    beatIndex: checkIndex,
    beatCount: checkCount,
    caption: _placementDiagnosticCaptionV1(signalId, isRu: isRu),
    hint: _placementDiagnosticHintV1(signalId, isRu: isRu),
    question: _placementDiagnosticQuestionV1(signalId, isRu: isRu),
    options: _placementDiagnosticOptionsV1(signalId, isRu: isRu),
    feedbackTitle: isRu ? 'Хорошее чтение.' : 'Clean read.',
    feedbackReason: isRu
        ? 'Ты точно прочитал личные карты, общие карты и банк.'
        : 'You read the private cards, board cards, and pot exactly.',
    primaryCtaLabel: isRu ? 'Продолжить' : 'Continue',
    teachingSteps: const <Act0TeachingStepV1>[],
    teachingStepIndex: 0,
  );
}

Act0RunnerFramingProfileV1 placementQuickCheckFramingProfileV1(
  String signalId,
) {
  return switch (signalId) {
    'table_read' ||
    'board_private_cards' => Act0RunnerFramingProfileV1.boardHeroPot,
    'action_basics' => Act0RunnerFramingProfileV1.heroAction,
    _ => Act0RunnerFramingProfileV1.neutral,
  };
}

Act0RunnerFramingProfileV1 _runnerFramingProfileForTaskV1({
  required Act0LessonTaskV1? task,
  required Act0RunnerStateV1? runner,
  required bool placementDiagnosticActive,
  required String? placementSignalId,
}) {
  if (placementDiagnosticActive && placementSignalId != null) {
    return placementQuickCheckFramingProfileV1(placementSignalId);
  }
  if (task == null || runner == null) {
    return Act0RunnerFramingProfileV1.neutral;
  }
  if (runner.options.any((option) => option.seatId != null)) {
    return Act0RunnerFramingProfileV1.seatFocus;
  }
  switch (task.resolvedTaskFamily) {
    case Act0TaskFamilyV1.decision:
    case Act0TaskFamilyV1.sizing:
    case Act0TaskFamilyV1.repair:
      return Act0RunnerFramingProfileV1.heroAction;
    case Act0TaskFamilyV1.transfer:
      final table = runner.table;
      if (table.heroCards.isNotEmpty &&
          table.boardCards.isNotEmpty &&
          table.potLabel.trim().isNotEmpty) {
        return Act0RunnerFramingProfileV1.boardHeroPot;
      }
      if (table.boardCards.isNotEmpty) {
        return Act0RunnerFramingProfileV1.boardOnly;
      }
      return Act0RunnerFramingProfileV1.neutral;
    case Act0TaskFamilyV1.learn:
    case Act0TaskFamilyV1.recognition:
    case Act0TaskFamilyV1.compare:
    case Act0TaskFamilyV1.counting:
    case Act0TaskFamilyV1.review:
      return Act0RunnerFramingProfileV1.neutral;
  }
}

enum _Act0LearningNextActionKindV1 {
  repairDeepLeak,
  repairWeakSpot,
  reviewQuickFix,
  continueLesson,
  dailyDrill,
  categoryPractice,
  dailyDone,
}

const Set<String> _kPracticePrimaryGroupIdsV1 = <String>{'daily', 'weak_spots'};

class _Act0LearningRecommendationV1 {
  const _Act0LearningRecommendationV1({
    required this.kind,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.hint,
    required this.outcome,
    this.mistake,
    this.lessonId,
    this.taskId,
    this.practiceGroupId,
  });

  final _Act0LearningNextActionKindV1 kind;
  final String label;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String hint;
  final String outcome;
  final Act0MistakeCardV1? mistake;
  final String? lessonId;
  final String? taskId;
  final String? practiceGroupId;
}

class _Act0PracticeSurfaceRecommendationV1 {
  const _Act0PracticeSurfaceRecommendationV1({
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.reasonLabel,
    required this.outcomeLead,
    required this.outcome,
    required this.masteryLabel,
    required this.screenSubtitle,
  });

  final String groupId;
  final String title;
  final String subtitle;
  final String reasonLabel;
  final String outcomeLead;
  final String outcome;
  final String masteryLabel;
  final String screenSubtitle;
}

enum Act0ControlledDemoCaptureModeV1 { walkthrough, directState }

enum _Act0DebugRepairProofOutcomeV1 { correct, wrong }

enum _Act0ProgressSaveStatusV1 { idle, saving, unconfirmed }

enum Act0ControlledDemoCaptureSurfaceV1 {
  placement,
  welcome,
  home,
  learn,
  runnerTheory,
  runnerDrill,
  runnerFeedback,
  review,
  practice,
  profile,
  worldCompletion,
  w12Terminal,
  sessionSummary,
  runnerFirstCorrectFeedback,
  firstWeekHome,
  reviewEmpty,
  firstWeekReview,
  firstWeekLearn,
  firstWeekProfile,
  runnerFirstWrongFeedback,
  repairFocus,
  repairResult,
  sessionRepair,
  day2ReturnHome,
  day2PracticeRepairTarget,
  day2ReviewContinuation,
  day2ProfileActiveRepair,
  profileEvidence,
  wave2HomeFresh,
  wave2HomeProgressed,
  wave2HomeRepairReturn,
  wave2LearnFresh,
  wave2LearnProgressed,
  wave2PracticeNoRepair,
  wave2PracticeActiveRepairHub,
  wave2ReviewEmpty,
  wave2ReviewMiss,
  wave2ProfileFresh,
  wave2ProfileProgressed,
}

class Act0ShellDebugHarnessEntryV1 {
  const Act0ShellDebugHarnessEntryV1({
    required this.mode,
    required this.surface,
    this.worldId,
    this.lessonId,
    this.taskId,
    this.feedbackCorrect = false,
  });

  final Act0ControlledDemoCaptureModeV1 mode;
  final Act0ControlledDemoCaptureSurfaceV1 surface;
  final String? worldId;
  final String? lessonId;
  final String? taskId;
  final bool feedbackCorrect;
}

class Act0ShellPreviewScreenV1 extends StatefulWidget {
  const Act0ShellPreviewScreenV1({
    super.key,
    this.initialTab = Act0ShellTabV1.home,
    this.initialPhase = Act0LessonPhaseV1.theory,
    this.state,
    this.showPlacementOnStart = true,
    this.debugLegacyPlacementOnStart = false,
    this.enableBetaMetrics = act0BetaMetricsEnabledV1,
    this.debugHarnessEntry,
    this.telemetrySink,
    this.debugSessionDrillRecheckQueueItemsV1,
    this.debugLoadSessionDrillRecheckQueueItemsV1,
    this.clock = const Act0SystemUtcClockV1(),
    // Dev2 is now the canonical detached Act0 shell. The classic variant stays
    // available for explicit fallback comparisons.
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
  });

  final Act0ShellTabV1 initialTab;
  final Act0LessonPhaseV1 initialPhase;
  final Act0ShellStateV1? state;
  final bool showPlacementOnStart;
  final bool debugLegacyPlacementOnStart;
  final bool enableBetaMetrics;
  final Act0ShellDebugHarnessEntryV1? debugHarnessEntry;
  final Act0TelemetrySinkV1? telemetrySink;
  final List<SessionDrillRecheckLaunchQueueItemV1>?
  debugSessionDrillRecheckQueueItemsV1;
  final Future<List<SessionDrillRecheckLaunchQueueItemV1>> Function()?
  debugLoadSessionDrillRecheckQueueItemsV1;
  final Act0UtcClockV1 clock;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;

  @override
  State<Act0ShellPreviewScreenV1> createState() =>
      _Act0ShellPreviewScreenV1State();
}

class _Act0ShellPreviewScreenV1State extends State<Act0ShellPreviewScreenV1> {
  // Extensions cannot call the protected setState directly.
  void _setStateV1(VoidCallback fn) => setState(fn);

  String? _accessibilityPrototypeTaskId;
  Act0AccessibilityPrototypeStepV1? _accessibilityPrototypeStep;
  Act0CompletedDecisionV1? _latestCompletedDecisionV1;
  // The runner sends this synchronously BEFORE onChooseOption/onChooseSeat.
  // Those callbacks own repair receipts and run before onCompletedDecision.
  Act0DecisionAssistanceV1 _choiceAssistanceV1 = Act0DecisionAssistanceV1.none;
  final Map<String, _Act0PendingDecisionAssistanceV1>
  _pendingDecisionAssistanceV1 = {};
  int _sourceEvidenceBoundaryV1(
    String worldId,
    String lessonId,
    String taskId,
  ) => _learningEvidenceHistoryV1.provenanceRecords
      .where(
        (r) =>
            r.worldId == worldId &&
            r.lessonId == lessonId &&
            r.taskId == taskId,
      )
      .fold<int>(
        0,
        (latest, r) => r.createdOrder > latest ? r.createdOrder : latest,
      );

  Act0DecisionAssistanceV1 _pendingAssistanceForV1(
    String worldId,
    String lessonId,
    String taskId,
  ) {
    final pending =
        _pendingDecisionAssistanceV1[jsonEncode([worldId, lessonId, taskId])];
    if (pending == null) return Act0DecisionAssistanceV1.none;
    final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
    );
    if (fingerprint == null ||
        fingerprint.isEmpty ||
        pending.fingerprint != fingerprint ||
        pending.afterSourceOrder !=
            _sourceEvidenceBoundaryV1(worldId, lessonId, taskId)) {
      return Act0DecisionAssistanceV1.legacyUnknown;
    }
    return pending.kind;
  }

  void _retainChoiceAssistanceV1(
    Act0DecisionAssistanceV1 value, {
    required String worldId,
    required String lessonId,
    required String taskId,
    Completer<bool>? acknowledgement,
  }) {
    final kind = act0MergeDecisionAssistanceV1(
      _pendingAssistanceForV1(worldId, lessonId, taskId),
      value,
    );
    _choiceAssistanceV1 = kind;
    if (kind == Act0DecisionAssistanceV1.none ||
        _phase != Act0LessonPhaseV1.drill ||
        _selectedOptionId != null) {
      acknowledgement?.complete(false);
      return;
    }
    final receipt = _Act0PendingDecisionAssistanceV1(
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      fingerprint:
          act0CurrentAuthoredSourceFingerprintForIdentityV1(
            worldId: worldId,
            lessonId: lessonId,
            taskId: taskId,
          ) ??
          '',
      afterSourceOrder: _sourceEvidenceBoundaryV1(worldId, lessonId, taskId),
      kind: kind,
    );
    _pendingDecisionAssistanceV1[receipt.key] = receipt;
    _persistProgress(acknowledgement: acknowledgement);
  }

  bool get _choiceHasIndependentProvenanceV1 =>
      _choiceAssistanceV1 == Act0DecisionAssistanceV1.none;
  bool get _choiceWasAssistedV1 =>
      _choiceAssistanceV1 == Act0DecisionAssistanceV1.quickHint ||
      _choiceAssistanceV1 == Act0DecisionAssistanceV1.theoryRecall;
  List<Act0StudyObservationV1> _studyObservationsV1 = const [];
  List<String> _savedPracticeDaysV1 = const [];
  Act0LearningEvidenceHistoryV1 _learningEvidenceHistoryV1 =
      const Act0LearningEvidenceHistoryV1();
  Act0DurableRetentionHistoryV1 _durableRetentionHistoryV1 =
      const Act0DurableRetentionHistoryV1();
  Act0ReviewKindV1? _pendingReviewKindV1;
  ({String worldId, String lessonId, String taskId})? _spacedReviewReturnV1;
  Act0LessonTaskV1? _activeSpacedReviewTaskV1;
  final _openedSpacedReviewTaskIdsV1 = <String>{};
  bool _newSpacedReviewSavePendingV1 = false;
  late final AppLifecycleListener _reviewLifecycleV1;
  bool _betaWentToBackground = false;
  Act0ReviewMistakeHistoryV1 _reviewMistakeHistoryV1 =
      const Act0ReviewMistakeHistoryV1();
  Act0ReviewResolutionReceiptHistoryV1 _reviewResolutionReceiptHistoryV1 =
      const Act0ReviewResolutionReceiptHistoryV1();
  Act0ConceptFamilyStateHistoryV1 _conceptFamilyStateHistoryV1 =
      const Act0ConceptFamilyStateHistoryV1();
  Act0EvidenceRunKeyV1? _activeLearningEvidenceRunKeyV1;
  int _learningEvidenceRunOrdinalV1 = 0;
  Act0SessionIdentityStateV1 _sessionIdentityStateV1 =
      const Act0SessionIdentityStateV1();
  Act0LearningRunStateV1? _learningRunV1;
  Act0LearningRunPayoffV1? _pendingLearningRunPayoffV1;
  bool _learningRunLearnVisitActiveV1 = false;
  bool _learningRunProductionLearnVisitV1 = false;
  int _learningRunOrdinalV1 = 0;
  int _learningRunEventOrderV1 = 0;
  final Set<String> _learningRunOutcomeTelemetryKeysV1 = <String>{};
  final Set<String> _sameSessionLearningDeltaViewedIdsV1 = <String>{};
  final Set<String> _sameSessionLearningDeltaCompletedIdsV1 = <String>{};
  final Set<String> _personalizedNextStepShownTelemetryKeysV1 = <String>{};
  bool _debugReviewEmptyV1 = false;
  bool _debugFreshLearnerV1 = false;
  static const String _progressPrefsKey = 'act0_shell_progress_v1';
  Act0ProgressStoreV1 _progressStore = _makeProgressStoreV1();
  final _progressSaveStatusV1 = ValueNotifier(_Act0ProgressSaveStatusV1.idle);
  bool _progressSaveStatusDisposedV1 = false;
  int _recoveryEpochV1 = 0;
  bool _recoveryBusyV1 = false;
  bool _privacyDeletionStarted = false;
  bool _privacyDeletionFailed = false;
  // A canonical reset severs all legacy SessionDrill projections. Their raw
  // preferences are retained; current Act0 repair/evidence remains supported.
  bool _suppressLegacyRecheckAfterRecoveryV1 = false;
  String? _recoveryMessageV1;

  static Act0ProgressStoreV1 _makeProgressStoreV1() => Act0ProgressStoreV1(
    key: _progressPrefsKey,
    isValidPayload: (raw) => _Act0PersistedProgressV1.tryParse(raw) != null,
    debugRecoveryBoundary:
        kDebugMode &&
            const bool.fromEnvironment('SHARKY_DAT06_PAUSE_AFTER_INTENT')
        ? (stage) async {
            if (stage == 'intent_verified') {
              debugPrint('DAT06_NATIVE_BOUNDARY intent_verified');
              await Future<void>.delayed(const Duration(minutes: 5));
            }
          }
        : null,
  );

  bool _acceptRecoveryCallbackV1(int epoch) =>
      mounted &&
      epoch == _recoveryEpochV1 &&
      !_recoveryBusyV1 &&
      (!_usesPersistedProgress || _progressStore.isWriteLeaseCurrent);

  void _setStateForRecoveryV1(int epoch, VoidCallback callback) {
    if (_acceptRecoveryCallbackV1(epoch)) setState(callback);
  }

  bool _progressLoadFailed = false;
  // Set only after a successful load; until then in-memory state is defaults and
  // must never be written over acknowledged saved progress (e.g. from dispose).
  bool _progressRestoredV1 = false;
  static const int _homeHandoffDismissDays = 7;
  static const Set<String> _w5SizingDrillTaskIds = <String>{
    'w4_small_bet',
    'w4_half_pot_bet',
    'w4_pot_bet',
  };

  late Act0ShellTabV1 _tab;
  late Act0LessonPhaseV1 _phase;
  late String _selectedWorldId;
  late String _selectedLessonId;
  late String _selectedTaskId;
  String? _learnPopupTaskId;
  late Set<String> _completedLessonIds;
  late Set<String> _completedTaskIds;
  final Set<String> _skippedTaskIds = <String>{};
  final Set<String> _visibleSkippedTaskIds = <String>{};
  bool _showWorldMenu = false;
  String? _learnDetailWorldId;
  String? _learnDetailLessonId;
  String? _selectedOptionId;
  String? _selectedPresetId;
  String? _selectedPresetTaskId;
  String? _reviewConfidence;
  int _teachingStepIndex = 0;
  int _earnedXp = 0;
  int _lessonRunXp = 0;
  bool _showPlayHub = true;
  bool _returnToPlayHubOnBack = false;
  final Map<String, _Act0MistakeRecordV1> _mistakeRecords =
      <String, _Act0MistakeRecordV1>{};
  final Map<String, Act0RepairIntentV1> _openRepairIntentBySourceTaskId =
      <String, Act0RepairIntentV1>{};
  Act0MultiRepairQueueV1 _multiRepairQueueV1 = const Act0MultiRepairQueueV1();
  int _multiRepairQueueOrderV1 = 0;
  final List<_Act0RepairIntentAuditEntryV1> _repairIntentAuditTrailV1 =
      <_Act0RepairIntentAuditEntryV1>[];
  final Set<String> _resolvedMistakeTaskIds = <String>{};
  final Set<String> _cleanTaskIds = <String>{};
  final Set<String> _lessonRunMistakeTaskIds = <String>{};
  final Set<String> _lessonRunAssistedTaskIds = <String>{};
  // Boundary only: assistance truth remains in the persisted evidence history.
  // Null means legacy/incomplete provenance, never verified independence.
  String _lessonRunEvidenceLessonIdV1 = '';
  int? _lessonRunEvidenceStartOrderV1 = 0;
  // Bookmarks for unfinished lessons; source evidence remains learningEvidenceHistory.
  final Map<String, int?> _lessonRunEvidenceBoundariesV1 = <String, int?>{};
  final Set<String> _lessonRunPendingRetryTaskIds = <String>{};
  final Set<String> _lessonRunRetriedTaskIds = <String>{};
  final Set<String> _lessonRunWrapUpCompletedTaskIds = <String>{};
  final Set<String> _lessonRunQuickFixTaskIds = <String>{};
  final Set<String> _lessonRunDeepLeakTaskIds = <String>{};
  final Map<String, int> _lessonRunSkillGainCounts = <String, int>{};
  final Set<String> _dailyCompletedTaskIds = <String>{};
  Act0DailyPracticeQueueV1 _dailyPracticeQueue =
      const Act0DailyPracticeQueueV1();
  int _dailyCompletedRepCount = 0;
  bool _rapidPracticeLoop = false;
  int _persistedStreakDays = 0;
  // Date of the last earned 3/3 set, never merely the last app save.
  String _lastDailyDate = '';
  // Date owning the in-memory 0–3 daily counter.
  late String _dailyRepCountDay = _todayDateString();
  int _retentionSequence = 0;
  final Map<String, _Act0RetentionMemoryEntryV1> _retentionMemoryByTaskId =
      <String, _Act0RetentionMemoryEntryV1>{};
  static const int _agedRecheckSequenceThresholdV1 = 6;
  String? _activePracticeGroupId;
  String? _activeRepairTaskId;
  bool _activeSameSignalFeedbackRepairV1 = false;
  String? _pendingFeedbackRepairSourceTaskIdV1;
  String? _pendingFeedbackRepairTaskIdV1;
  String? _activeSameSignalRecheckTaskId;
  String? _activeSameSignalRecheckSourceTaskId;
  Act0ActionSequenceStageV1? _activeActionSequenceStageV1;
  Act0ActionSequenceLearnerStateV1 _actionPersonalizationStateV1 =
      Act0ActionSequencePersonalizationPolicyV1.initialState();
  String? _activeRepairSourceTaskId;
  Act0PracticeRepairQueueLaunchRequestV1? _activePracticeRepairQueueRequestV1;
  Act0RepairIntentV1? _activeRepairObligationV1;
  Act0RepairOutcomeProjectionV1 _repairOutcomeProjectionV1 =
      const Act0RepairOutcomeProjectionV1();
  int _repairOutcomeSequenceV1 = 0;
  Act0LastSessionLearnerStateV1? _lastSessionLearnerStateV1;
  Act0DiagnosticLearningEntryV1? _diagnosticLearningEntryV1;
  ({String worldId, String lessonId, String taskId})?
  _diagnosticLearningReturnV1;

  bool _acceptDiagnosticRunnerCallbackV1(
    Act0DiagnosticLearningEntryV1? entry,
    String? runId,
  ) {
    if (entry == null) return _diagnosticLearningEntryV1 == null;
    return identical(entry, _diagnosticLearningEntryV1) &&
        runId != null &&
        runId == _activeLearningEvidenceRunKeyV1?.runId &&
        _activeLearningEvidenceRunKeyV1?.runKind ==
            act0DiagnosticLearningEntryRunKindV1 &&
        _selectedWorldId == entry.targetWorldId &&
        _selectedLessonId == entry.targetLessonId &&
        _selectedTaskId == entry.targetTaskId;
  }

  void _setStateForRunnerCallbackV1(
    int epoch,
    Act0DiagnosticLearningEntryV1? entry,
    String? runId,
    VoidCallback callback,
  ) {
    if (!_acceptDiagnosticRunnerCallbackV1(entry, runId)) return;
    _setStateForRecoveryV1(epoch, callback);
  }

  String? _activeRepairResultReceiptLine;
  List<String> _activeRepairSessionSummaryLines = const <String>[];
  _Act0FirstValueReceiptCarryV1? _firstValueReceiptCarry;
  String _firstValueTodayShownTelemetryKey = '';
  final Set<String> _repairItemShownTelemetryKeys = <String>{};
  final Set<String> _actionTheoryCompletedTelemetryKeysV1 = <String>{};
  List<SessionDrillRecheckLaunchQueueItemV1> _sessionDrillRecheckQueueItemsV1 =
      const <SessionDrillRecheckLaunchQueueItemV1>[];

  @visibleForTesting
  Map<String, Object?>? debugOpenRepairIntentPayloadForSourceTaskV1(
    String sourceTaskId,
  ) {
    final intent = _openRepairIntentBySourceTaskId[sourceTaskId.trim()];
    if (intent == null) {
      return null;
    }
    return Map<String, Object?>.unmodifiable(intent.toPayload());
  }

  @visibleForTesting
  int debugOpenRepairIntentCountV1() => _openRepairIntentBySourceTaskId.length;

  @visibleForTesting
  String debugSelectedTaskIdV1() => _selectedTaskId;

  @visibleForTesting
  String debugSelectedWorldIdV1() => _selectedWorldId;

  @visibleForTesting
  String debugSelectedLessonIdV1() => _selectedLessonId;

  @visibleForTesting
  String debugPhaseV1() => _phase.name;

  @visibleForTesting
  String? debugSelectedOptionIdV1() => _selectedOptionId;

  @visibleForTesting
  Map<String, Object?> debugActiveRepairContextPayloadV1() {
    return <String, Object?>{
      if (_activeRepairSourceTaskId != null)
        'sourceTaskId': _activeRepairSourceTaskId,
      if (_activeRepairTaskId != null) 'repairTaskId': _activeRepairTaskId,
      if (_activePracticeGroupId != null)
        'practiceGroupId': _activePracticeGroupId,
    };
  }

  @visibleForTesting
  List<Map<String, Object?>> debugRepairOutcomeProjectionPayloadV1() {
    return List<Map<String, Object?>>.unmodifiable(
      _repairOutcomeProjectionV1.toPayload(),
    );
  }

  @visibleForTesting
  List<Map<String, Object?>> debugConceptFamilyStatePayloadV1() {
    return List<Map<String, Object?>>.unmodifiable(
      _conceptFamilyStateHistoryV1.toPayload(),
    );
  }

  @visibleForTesting
  List<Map<String, Object?>> debugDurableRetentionPayloadV1() {
    return List<Map<String, Object?>>.unmodifiable(
      _durableRetentionHistoryV1.refreshedAt(widget.clock.nowUtc()).toPayload(),
    );
  }

  @visibleForTesting
  Future<void> debugReloadProgressV1() => _bootstrapFirstStartRouteV1();

  @visibleForTesting
  void debugPersistProgressV1() => _persistProgress();

  @visibleForTesting
  Future<void> debugInvalidatePersistedProgressWritesV1() =>
      _invalidatePersistedProgressWrites();

  @visibleForTesting
  Map<String, Object?> debugSessionIdentityStatePayloadV1() {
    return _sessionIdentityStateV1.toPayload();
  }

  @visibleForTesting
  Map<String, Object?>? debugLastSessionReturnStatePayloadV1() {
    return _lastSessionLearnerStateV1?.toJson();
  }

  @visibleForTesting
  List<Map<String, Object?>> debugRepairIntentAuditTrailPayloadV1() {
    return List<Map<String, Object?>>.unmodifiable(
      _repairIntentAuditTrailV1.map((entry) => entry.toPayload()),
    );
  }

  @visibleForTesting
  Map<String, Object?>? debugNextUsefulHandTargetPayloadV1() {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final receipt = _nextUsefulHandReasonReceiptV1(
      recommendation: recommendation,
      selectedWorld: selectedWorld,
      state: state,
    );
    _recordRepairIntentAuditTransitionV1(
      _auditTransitionForReceiptV1(receipt),
      receipt: receipt,
    );
    return receipt.toPayload();
  }

  @visibleForTesting
  Map<String, Object?> debugNextUsefulHandCopyBridgePayloadV1() {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final receipt = _nextUsefulHandReasonReceiptV1(
      recommendation: recommendation,
      selectedWorld: selectedWorld,
      state: state,
    );
    return _Act0NextUsefulHandCopyBridgeV1.fromReceipt(receipt).toPayload();
  }

  @visibleForTesting
  String? debugHomeNextUsefulHandReasonLineV1() {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _homeNextUsefulHandReasonLine(selectedWorld, selectedLesson);
  }

  @visibleForTesting
  String? debugHomePersonalizedReturnReasonLineV1() {
    return _homePersonalizedReturnReasonLine();
  }

  @visibleForTesting
  Map<String, Object?>? debugReviewSupportCopySnapshotV1() {
    final mistake = _topOpenMistake();
    if (mistake == null) {
      return null;
    }
    final target = _openRepairIntentTargetForSourceTaskV1(
      mistake.taskId,
      includeOwed: true,
    );
    if (target == null) {
      return null;
    }
    final receipt = _Act0NextUsefulHandReasonReceiptV1.forRepairIntent(
      sourceTaskId: mistake.taskId,
      target: target,
      repeatedMissCount: mistake.attempts,
    );
    final bridge = _Act0NextUsefulHandCopyBridgeV1.fromReceipt(receipt);
    final renderedLine = bridge.renderedCopyLine.trim();
    if (renderedLine.isEmpty) {
      return null;
    }
    return bridge.toReviewSupportCopySnapshotPayload(
      renderedLine: renderedLine,
    );
  }

  String? _activeLessonWrapUpTaskId;
  String? _lessonRunWrapUpAnchorTaskId;
  String? _practiceCompletionTitle;
  String? _practiceCompletionBody;
  Act0BlockCompletionSummaryV1? _blockCompletionSummary;
  bool _showPlacement = false;
  bool _placementDiagnosticActive = false;
  bool _placementIntroVisible = true;
  int _placementQuestionIndex = 0;
  int _placementDiagnosticIndex = 0;
  int _placementDiagnosticCorrect = 0;
  int _placementDiagnosticScore = 0;
  bool _isRuLocaleV1 = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs after initState and again when MaterialApp changes locale.
    _isRuLocaleV1 = Localizations.localeOf(context).languageCode == 'ru';
  }

  Act0PlacementQuestionV1 _localizePlacementQuestionV1(
    Act0PlacementQuestionV1 question,
  ) {
    return Act0PlacementQuestionV1(
      questionId: question.questionId,
      eyebrow: _localizedPlacementQuestionEyebrowV1(question),
      title: _localizedPlacementQuestionTitleV1(question),
      subtitle: _localizedPlacementQuestionSubtitleV1(question),
      helper: _localizedPlacementQuestionHelperV1(question),
      icon: question.icon,
      allowsMultiple: question.allowsMultiple,
      minSelections: question.minSelections,
      maxSelections: question.maxSelections,
      options: question.options
          .map(
            (option) => _localizePlacementOptionV1(question.questionId, option),
          )
          .toList(growable: false),
    );
  }

  String _localizedPlacementSignalLineV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementHighlightV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementPlanStepV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementTrialPointV1(String line) =>
      _localizedPlacementAtomV1(line);

  String _localizedPlacementAtomV1(String value) {
    return switch (value) {
      'Table read' => 'Чтение стола',
      'Board read' => 'Чтение борда',
      'Action order' => 'Порядок действий',
      'Position pressure' => 'Давление позиции',
      'Fresh start' => 'Чистый старт',
      'Clear path' => 'Понятный маршрут',
      'Motivation' => 'Мотивация',
      'Some table language' => 'Немного языка стола',
      'Experience' => 'Опыт',
      'Decision comfort' => 'Комфорт в решениях',
      'Table' => 'Стол',
      'Pot' => 'Банк',
      'Blinds' => 'Блайнды',
      'Streets' => 'Улицы',
      'Actions' => 'Действия',
      'Positions' => 'Позиции',
      'Hand flow' => 'Ход раздачи',
      'Action decisions' => 'Решения по действиям',
      'Board tracking' => 'Чтение борда',
      'Pressure control' => 'Контроль давления',
      _ => value,
    };
  }

  bool _placementHandoffActive = false;
  // True only while placement was opened from Profile on an existing learner.
  // A retake re-measures skills; it must never erase earned completion.
  bool _placementRetakeV1 = false;
  final Map<String, Set<String>> _placementAnswerIds = <String, Set<String>>{};
  final Set<String> _placementDiagnosticHitSignals = <String>{};
  final Set<String> _placementDiagnosticMissSignals = <String>{};
  final Map<String, int> _profileSkillValues = <String, int>{};
  final List<Act0SkillGainV1> _recentSkillGains = <Act0SkillGainV1>[];
  Act0PlacementResultV1? _placementResult;
  int _progressPersistGeneration = 0;
  String _dismissedHomeHandoffKey = '';
  String _dismissedHomeHandoffDay = '';
  int _learnLessonOpenSequenceV1 = 0;
  bool _showWelcome = false;
  bool _showW1StartV1 = false;
  bool _w1StartChosenV1 = false;
  int _w1RulesBestScoreV1 = 0;
  Set<String> _w1RulesFocusTaskIdsV1 = const {};
  List<int>? _w1RulesAnswersV1;
  Act0W1RulesResultV1? _w1RulesResultV1;
  bool _bootSurfaceReady = true;
  bool _welcomeCompletedV1 = false;
  bool _introductionSkippedV1 = false;
  bool _skipIntroductionSavingV1 = false;
  bool _welcomeCompletionSavingV1 = false;
  int _welcomeCompletionEpochV1 = 0;
  bool _welcomeHandoffStartsRecommendedTaskV1 = false;
  Act0ShellTabV1? _welcomeReturnTabV1;

  Set<String> get _pathClosedTaskIds => <String>{
    ..._completedTaskIds,
    ..._skippedTaskIds,
  };

  bool get _usesPersistedProgress =>
      widget.state == null && widget.debugHarnessEntry == null;

  @override
  void initState() {
    super.initState();
    _reviewLifecycleV1 = AppLifecycleListener(
      onHide: () => _betaWentToBackground = true,
      onResume: () {
        if (mounted) {
          setState(() {});
          if (_bootSurfaceReady && !_recoveryBusyV1) {
            _syncPracticeReminderV1();
            if (_betaWentToBackground) _recordBetaVisitV1();
          }
        }
        _betaWentToBackground = false;
      },
    );
    _tab = widget.initialTab;
    _learningRunLearnVisitActiveV1 = widget.initialTab == Act0ShellTabV1.learn;
    _phase = widget.initialPhase;
    _showPlacement = widget.showPlacementOnStart;
    _showWelcome = false;
    _welcomeHandoffStartsRecommendedTaskV1 = false;
    _bootSurfaceReady = false;
    _showPlayHub = widget.initialTab != Act0ShellTabV1.play;
    final state = widget.state ?? Act0ShellStateV1.sample;
    _selectedWorldId = state.selectedWorldId;
    _selectedLessonId = state.currentLesson.lessonId;
    _learnDetailLessonId = null;
    _completedLessonIds = {
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed) lesson.lessonId,
    };
    _completedTaskIds = {
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed)
            for (final task in lesson.taskList) task.taskId,
    };
    _selectedTaskId = _firstIncompleteTask(state.currentLesson).taskId;
    _learnPopupTaskId = null;
    _resetLessonRunMetrics();
    final debugRecheckItems = widget.debugSessionDrillRecheckQueueItemsV1;
    if (debugRecheckItems != null) {
      _sessionDrillRecheckQueueItemsV1 = List.unmodifiable(debugRecheckItems);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadSessionDrillRecheckQueueItemsV1());
      });
    }
    if (widget.debugHarnessEntry case final entry?) {
      _applyDebugHarnessEntry(entry, state);
      return;
    }
    unawaited(_bootstrapFirstStartRouteV1());
  }

  Future<void> _loadSessionDrillRecheckQueueItemsV1() async {
    final epoch = _recoveryEpochV1;
    final List<SessionDrillRecheckLaunchQueueItemV1> items;
    try {
      items = widget.debugLoadSessionDrillRecheckQueueItemsV1 == null
          ? await const SessionDrillRecheckLaunchQueueV1()
                .loadSupportedLaunchQueueItems()
          : await widget.debugLoadSessionDrillRecheckQueueItemsV1!();
    } catch (_) {
      return;
    }
    if (!mounted ||
        epoch != _recoveryEpochV1 ||
        _suppressLegacyRecheckAfterRecoveryV1) {
      return;
    }
    setState(() {
      _sessionDrillRecheckQueueItemsV1 = items;
    });
  }

  @override
  void dispose() {
    _reviewLifecycleV1.dispose();
    _recoveryEpochV1++;
    _learnLessonOpenSequenceV1++;
    _persistProgress();
    _progressSaveStatusDisposedV1 = true;
    _progressSaveStatusV1.dispose();
    super.dispose();
  }

  void _syncPracticeReminderV1() {
    if (!Act0PracticeReminderV1.isSupported) return;
    _ensureDailyCountDayV1();
    final canPractice = _dailyDeckEntries(
      widget.state ?? Act0ShellStateV1.sample,
    ).isNotEmpty;
    final done =
        _dailyCompletedRepCount >= 3 ||
        (_dailyPracticeQueue.taskIds.isNotEmpty &&
            _dailyPracticeQueue.nextTaskId == null);
    final schedule = !canPractice
        ? Act0PracticeReminderScheduleV1.none
        : done
        ? Act0PracticeReminderScheduleV1.tomorrowEvening
        : Act0PracticeReminderScheduleV1.nextEvening;
    unawaited(
      Act0PracticeReminderV1.sync(
        schedule,
      ).then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
  }

  void _recordBetaVisitV1() {
    if (!widget.enableBetaMetrics ||
        !_usesPersistedProgress ||
        !_progressRestoredV1 ||
        _progressLoadFailed) {
      return;
    }
    unawaited(
      Act0BetaMetricsStoreV1.recordVisit(
        widget.clock.nowUtc(),
      ).then<void>((_) {}, onError: (Object _) {}),
    );
  }

  Future<void> _bootstrapFirstStartRouteV1() async {
    final epoch = ++_recoveryEpochV1;
    _progressRestoredV1 = false;
    _progressStore = _makeProgressStoreV1();
    _progressSaveStatusV1.value = _Act0ProgressSaveStatusV1.idle;
    if (_usesPersistedProgress) {
      try {
        await _restorePersistedProgress();
      } catch (_) {
        if (mounted && epoch == _recoveryEpochV1)
          setState(() {
            _progressLoadFailed = true;
            _bootSurfaceReady = true;
          });
        return;
      }
      if (!mounted || epoch != _recoveryEpochV1) return;
    }
    if (!mounted || epoch != _recoveryEpochV1) return;
    _progressRestoredV1 = true;
    _recordBetaVisitV1();
    if (_usesPersistedProgress && !_progressLoadFailed)
      _syncPracticeReminderV1();
    if (!widget.showPlacementOnStart) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPlacement = false;
        _showWelcome = false;
        _bootSurfaceReady = true;
      });
      return;
    }
    final intakeCompleted = await ProgressService.isIntakeCompleted();
    final welcomeCompleted =
        await Act0FirstStartPreferencesV1.hasCompletedWelcome();
    final introductionSkipped =
        await Act0FirstStartPreferencesV1.hasSkippedIntroduction();
    if (!mounted || epoch != _recoveryEpochV1) {
      return;
    }
    setState(() {
      _welcomeCompletedV1 = welcomeCompleted;
      _introductionSkippedV1 = introductionSkipped;
      final legacyPreview = kDebugMode && widget.debugLegacyPlacementOnStart;
      _showPlacement =
          legacyPreview && !intakeCompleted && !introductionSkipped;
      _showWelcome =
          legacyPreview &&
          intakeCompleted &&
          !welcomeCompleted &&
          !introductionSkipped;
      if (_showWelcome) _tab = Act0ShellTabV1.home;
      _showW1StartV1 =
          !legacyPreview &&
          !_w1StartChosenV1 &&
          !intakeCompleted &&
          !welcomeCompleted &&
          !introductionSkipped &&
          _completedTaskIds.isEmpty &&
          _earnedXp == 0;
      _bootSurfaceReady = true;
    });
  }

  void _handleLearnLessonOpenAfterScrollV1(String lessonId) {
    if (!mounted) return;
  }

  String? _repairFingerprintForIdentityV1({
    required String worldId,
    required String lessonId,
    required String taskId,
  }) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    for (final world in state.worlds) {
      if (world.worldId != worldId) continue;
      for (final lesson in world.lessons) {
        if (lesson.lessonId != lessonId) continue;
        for (final task in lesson.taskList) {
          if (task.taskId == taskId) {
            return act0AuthoredSourceFingerprintV1(
              worldId: worldId,
              lessonId: lessonId,
              task: task,
            );
          }
        }
      }
    }
    return null;
  }

  String? _diagnosticVariantFingerprintForIdentityV1({
    required String worldId,
    required String lessonId,
    required String taskId,
    required String diagnosticVariantId,
  }) {
    final source = _diagnosticSourceForIdentityV1(
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      diagnosticVariantId: diagnosticVariantId,
    );
    if (source == null) return null;
    return act0PlacementDiagnosticFingerprintV1(
      worldId: worldId,
      lessonId: lessonId,
      diagnosticVariantId: diagnosticVariantId,
      sourceTask: source.task,
      diagnosticRunner: source.runner,
    );
  }

  @visibleForTesting
  String? debugCurrentDiagnosticVariantFingerprintV1() {
    if (!_placementDiagnosticActive) return null;
    final spot = _placementDiagnosticSpotsV1[_placementDiagnosticIndex];
    return _diagnosticVariantFingerprintForIdentityV1(
      worldId: spot.worldId,
      lessonId: spot.lessonId,
      taskId: spot.taskId,
      diagnosticVariantId: spot.signalId,
    );
  }

  @visibleForTesting
  Map<String, String> debugDiagnosticLearningEntryPayloadV1() {
    final entry = _diagnosticLearningEntryV1;
    return entry == null
        ? const {}
        : {
            'sourceOccurrenceId': entry.sourceOccurrenceId,
            'sourceTaskId': entry.contract.sourceTaskId,
            'targetWorldId': entry.targetWorldId,
            'targetLessonId': entry.targetLessonId,
            'targetTaskId': entry.targetTaskId,
            'goalId': entry.contract.goalId,
            'evidenceClass': act0DiagnosticLearningEntryRunKindV1,
          };
  }

  String _todayDateString() {
    final now = widget.clock.nowUtc().toLocal();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  void _completeLearningRunPayoffV1() {
    final run = _learningRunV1;
    final focus = _pendingLearningRunPayoffV1?.focus;
    if (run != null) {
      _recordTelemetryEventV1('session_payoff_completed', <String, Object?>{
        'schemaVersion': 1,
        'run_id': run.runId,
        'meaningful_outcome_count': run.meaningfulAttemptCount,
      });
    }
    _learningRunV1 = null;
    _pendingLearningRunPayoffV1 = null;
    _learningRunLearnVisitActiveV1 = false;
    _learningRunProductionLearnVisitV1 = false;
    _learningRunOutcomeTelemetryKeysV1.clear();
    if (!_startLearningRunPayoffFocusV1(focus)) {
      _tab = Act0ShellTabV1.home;
    }
  }

  Future<void> _openRecoveryOptionsV1() async {
    Act0RecoveryProposalV1? proposal;
    Act0RecoveryCopyV1? copy;
    try {
      copy = await _progressStore.inspectRecoveryCopy();
      if (_progressLoadFailed && !copy.pending)
        proposal = await _progressStore.inspectRecovery();
    } catch (_) {
      /* no unsafe fallback */
    }
    if (!mounted) return;
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recovery options'),
        content: Text(
          _progressLoadFailed
              ? proposal == null
                    ? 'Replacement is unavailable because saved progress may be readable again or could not be safely verified. Cancel and choose Try again to load current progress.'
                    : 'Preserve a separate local copy, then start new learning progress. Current learning progress will be replaced. The copy may not be restorable. Settings and intro choices stay.'
              : 'Recovery copies stay on this device and may not be restorable. Deleting a copy does not reset current learning progress.',
        ),
        actions: [
          TextButton(
            key: const Key('act0_recovery_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          if (copy?.exists == true)
            TextButton(
              key: const Key('act0_recovery_delete_copy'),
              onPressed: copy!.pending
                  ? null
                  : () => Navigator.of(dialogContext).pop('delete'),
              child: const Text('Delete recovery copy'),
            ),
          if (_progressLoadFailed)
            TextButton(
              key: const Key('act0_recovery_confirm'),
              onPressed: proposal == null
                  ? null
                  : () => Navigator.of(dialogContext).pop('reset'),
              child: const Text('Preserve copy and start again'),
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'delete' && copy != null) {
      final consent = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete recovery copy?'),
          content: const Text(
            'Only the separate local copy will be deleted. Current learning progress and settings stay.',
          ),
          actions: [
            TextButton(
              key: const Key('act0_recovery_delete_cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep copy'),
            ),
            TextButton(
              key: const Key('act0_recovery_delete_confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete copy'),
            ),
          ],
        ),
      );
      if (consent != true || !mounted) return;
      final removed = await _progressStore.deleteRecoveryCopy(copy);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              removed
                  ? 'Recovery copy deleted.'
                  : 'The copy could not be safely deleted. Try again.',
            ),
          ),
        );
      return;
    }
    if (action != 'reset' || proposal == null) return;
    _recoveryEpochV1++;
    _learnLessonOpenSequenceV1++;
    _progressPersistGeneration++;
    setState(() {
      _recoveryBusyV1 = true;
      _progressRestoredV1 = false;
      _recoveryMessageV1 = null;
    });
    final outcome = await _progressStore.confirmRecoveryOutcome(proposal);
    if (!mounted) return;
    if (outcome != Act0RecoveryConfirmationOutcomeV1.completed) {
      setState(() {
        _recoveryBusyV1 = false;
        _progressLoadFailed = true;
        _recoveryMessageV1 =
            outcome == Act0RecoveryConfirmationOutcomeV1.existingCopyConflict
            ? 'A different recovery copy is already saved. It has been kept, and current progress was not replaced. Open recovery options to keep it, or delete the copy with separate confirmation before starting again.'
            : 'Recovery could not be completely verified. Any preserved copy is kept. Try again to resume safely.';
      });
      return;
    }
    _restorePreviewToFreshStart(showPlacement: false);
    _progressStore = _makeProgressStoreV1();
    setState(() {
      _recoveryBusyV1 = false;
      _progressLoadFailed = false;
      _bootSurfaceReady = false;
    });
    await _bootstrapFirstStartRouteV1();
  }

  void _openPlacementFlow() {
    setState(() {
      _placementRetakeV1 = true;
      _showPlacement = true;
      _showWelcome = false;
      _welcomeHandoffStartsRecommendedTaskV1 = false;
      _welcomeReturnTabV1 = null;
      _endPlacementAssessmentRunV1();
      _placementDiagnosticActive = false;
      _placementIntroVisible = true;
      _placementQuestionIndex = 0;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementDiagnosticScore = 0;
      _placementHandoffActive = false;
      _placementAnswerIds.clear();
      _placementDiagnosticHitSignals.clear();
      _placementDiagnosticMissSignals.clear();
      _profileSkillValues.clear();
      _recentSkillGains.clear();
      _placementResult = null;
      _selectedOptionId = null;
      _phase = Act0LessonPhaseV1.theory;
      _teachingStepIndex = 0;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _activePracticeGroupId = null;
      _clearActiveRepairLaunchV1();
      _activeRepairSourceTaskId = null;
      _activeRepairResultReceiptLine = null;
      _activeRepairSessionSummaryLines = const <String>[];
      _blockCompletionSummary = null;
    });
  }

  Future<void> _requestDeleteLocalDataV1() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Act0AcademyLeafPaletteV1.inkRaised,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Delete local data?',
                style: TextStyle(
                  color: Act0AcademyLeafPaletteV1.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This permanently erases your learning progress, answers, XP, '
                'practice history, recovery copies and preferences on this device. '
                'You will start again. It cannot be undone. '
                'Apple backups and TestFlight feedback are managed separately by Apple.',
                style: TextStyle(
                  color: Act0AcademyLeafPaletteV1.textMuted,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                key: const Key('act0_delete_data_cancel'),
                onPressed: () => Navigator.pop(sheetContext, false),
                style: TextButton.styleFrom(
                  foregroundColor: Act0AcademyLeafPaletteV1.aquaSoft,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const Key('act0_delete_data_confirm'),
                onPressed: () => Navigator.pop(sheetContext, true),
                style: FilledButton.styleFrom(
                  foregroundColor: Act0AcademyLeafPaletteV1.ink,
                  backgroundColor: Act0ShellTokensV1.danger,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) await _deleteLocalDataV1();
  }

  Future<void> _deleteLocalDataV1() async {
    _recoveryEpochV1++;
    _learnLessonOpenSequenceV1++;
    _progressPersistGeneration++;
    setState(() {
      _privacyDeletionStarted = true;
      _privacyDeletionFailed = false;
      _recoveryBusyV1 = true;
      _progressRestoredV1 = false;
    });
    Act0LocalDataDeletionV1.blockOldWriters();
    final language = Provider.of<AppLanguageController?>(
      context,
      listen: false,
    );
    try {
      await _progressStore.flush();
      await Act0BetaMetricsStoreV1.flush();
      await Act0FirstStartPreferencesV1.flush();
      await AppSettingsService.instance.flush();
      await language?.flush();
      await widget.telemetrySink?.stopForLocalDeletion();
      await Act0LocalDataDeletionV1.erase();
      await AppSettingsService.instance.load();
      await language?.resetAfterLocalDeletion();
      if (!mounted) return;
      _restorePreviewToFreshStart(showPlacement: true);
      _progressStore = _makeProgressStoreV1();
      setState(() {
        _privacyDeletionStarted = false;
        _recoveryBusyV1 = false;
        _progressLoadFailed = false;
        _bootSurfaceReady = true;
        _progressRestoredV1 = true;
      });
    } catch (_) {
      if (mounted) setState(() => _privacyDeletionFailed = true);
    }
  }

  Future<void> _openDevMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Act0ShellTokensV1.surface,
      builder: (context) {
        final languageController = Provider.of<AppLanguageController?>(
          context,
          listen: false,
        );
        final currentLanguageCode = languageController?.languageCode;
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (languageController != null) ...[
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(
                      _copyV1(en: 'Preview language', ru: 'Язык предпросмотра'),
                    ),
                    subtitle: Text(
                      currentLanguageCode == 'ru'
                          ? 'Русский'
                          : AppLanguageController.getLanguageName(
                              currentLanguageCode ?? 'en',
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            key: const Key('act0_shell_dev_menu_lang_ru'),
                            onPressed: currentLanguageCode == 'ru'
                                ? null
                                : () async {
                                    await languageController.setLanguage('ru');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  },
                            child: const Text('Русский'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonal(
                            key: const Key('act0_shell_dev_menu_lang_en'),
                            onPressed: currentLanguageCode == 'en'
                                ? null
                                : () async {
                                    await languageController.setLanguage('en');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  },
                            child: const Text('English'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  key: const Key('act0_shell_dev_menu_reset_progress'),
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(
                    _copyV1(
                      en: 'Reset app progress',
                      ru: 'Сбросить прогресс приложения',
                    ),
                  ),
                  subtitle: Text(
                    _copyV1(
                      en: 'Clear app prefs and return to Today.',
                      ru: 'Очистить настройки приложения и вернуться на главный экран.',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleResetAppProgress();
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_placement'),
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(
                    _copyV1(en: 'Open placement', ru: 'Открыть плейсмент'),
                  ),
                  subtitle: Text(
                    _copyV1(
                      en: 'Jump into the placement flow manually.',
                      ru: 'Войти в поток плейсмента вручную.',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openPlacementFlow();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_home'),
                  leading: const Icon(Icons.home_outlined),
                  title: Text(
                    _copyV1(en: 'Open Today', ru: 'Открыть главный экран'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.home);
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_map'),
                  leading: const Icon(Icons.map_outlined),
                  title: Text(
                    _copyV1(en: 'Open Learn map', ru: 'Открыть карту обучения'),
                  ),
                  subtitle: Text(
                    _copyV1(
                      en: 'Jump to Learn and skip placement.',
                      ru: 'Перейти в обучение и пропустить плейсмент.',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevMapSkippingPlacement();
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_play_hub'),
                  leading: const Icon(Icons.sports_esports_outlined),
                  title: Text(
                    _copyV1(en: 'Open Play hub', ru: 'Открыть хаб практики'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(
                      tab: Act0ShellTabV1.play,
                      showPlayHub: true,
                    );
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_runner'),
                  leading: const Icon(Icons.play_circle_outline_rounded),
                  title: Text(
                    _copyV1(
                      en: 'Open current runner',
                      ru: 'Открыть текущий раннер',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(
                      tab: Act0ShellTabV1.play,
                      showPlayHub: false,
                    );
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_review'),
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(_copyV1(en: 'Open Review', ru: 'Открыть разбор')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.review);
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_profile'),
                  leading: const Icon(Icons.person_outline_rounded),
                  title: Text(
                    _copyV1(en: 'Open Profile', ru: 'Открыть профиль'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _previewLockedWorldPremium(Act0WorldCardV1 world) {
    final worldTitle = act0LocalizedWorldTitleV1(context, world);
    final worldSubtitle = act0LocalizedWorldSubtitleV1(context, world);
    final valuePoints = <String>[
      'More table-clue reps after the free route proves useful.',
      'Extra practice around $worldTitle when you are ready.',
      'Deeper review of the same kinds of table reads.',
    ];
    unawaited(
      _openPremiumPreviewSheet(
        eyebrow: 'Premium preview',
        title: '$worldTitle gets deeper, not louder.',
        summary:
            '$worldSubtitle Premium stays optional and adds extra practice after this world opens naturally.',
        valuePoints: valuePoints,
        trustLine:
            '${act0DisplayWorldNameCopyV1(world.unlockLabel)} The first useful hand stays free, and the route still opens in order.',
        footerLine:
            'This is a preview, not a gate. Stay on the free route until you want more practice.',
      ),
    );
  }

  void _openCompletedDailyPremiumPreviewSheet() {
    unawaited(
      _openPremiumPreviewSheet(
        eyebrow: 'Premium preview',
        title: 'Want more reps like this?',
        summary:
            'Premium adds more practice after the free foundation, without changing today\'s free route.',
        valuePoints: const <String>[
          'more table-clue practice after the free foundation.',
          'Extra reps when one useful read feels worth sharpening.',
          'deeper review of missed decisions if it helps you.',
          'Longer route depth when you are ready.',
        ],
        trustLine:
            'The free route stays open. Premium is optional extra practice for later.',
        footerLine:
            'No pressure. Keep using Sharky free until you want more depth.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_privacyDeletionStarted) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _privacyDeletionFailed
                        ? 'Data deletion unfinished'
                        : 'Deleting local data…',
                  ),
                  if (_privacyDeletionFailed) ...[
                    const Text(
                      'Keep Sharky open and retry. Your learning route stays closed until deletion finishes.',
                    ),
                    TextButton(
                      key: const Key('act0_retry_data_deletion'),
                      onPressed: _deleteLocalDataV1,
                      child: const Text('Retry deletion'),
                    ),
                  ] else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final callbackEpochV1 = _recoveryEpochV1;
    final callbackDiagnosticEntryV1 = _diagnosticLearningEntryV1;
    final callbackDiagnosticRunIdV1 = _activeLearningEvidenceRunKeyV1?.runId;
    final openedAsSpacedReview = _spacedReviewReturnV1 != null;
    if (_progressLoadFailed) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your saved progress could not be read.'),
                if (_recoveryMessageV1 != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _recoveryMessageV1!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_recoveryBusyV1) ...[
                  const CircularProgressIndicator(),
                  const Text('Recovery in progress. Keep this screen open.'),
                ],
                TextButton(
                  key: const Key('act0_recovery_retry'),
                  onPressed: _recoveryBusyV1
                      ? null
                      : () {
                          setState(() {
                            _progressLoadFailed = false;
                            _bootSurfaceReady = false;
                          });
                          unawaited(_bootstrapFirstStartRouteV1());
                        },
                  child: const Text('Try again'),
                ),
                TextButton(
                  key: const Key('act0_recovery_options'),
                  onPressed: _recoveryBusyV1 ? null : _openRecoveryOptionsV1,
                  child: const Text('Recovery options'),
                ),
                TextButton(
                  onPressed: _recoveryBusyV1 ? null : _requestDeleteLocalDataV1,
                  child: const Text('Delete local data'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (!_bootSurfaceReady) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Act0AcademyLeafPaletteV1.ink,
          body: SafeArea(
            child: Center(
              child: CircularProgressIndicator(
                color: Act0AcademyLeafPaletteV1.aqua,
              ),
            ),
          ),
        ),
      );
    }
    _ensureDailyCountDayV1();
    if (_bootSurfaceReady &&
        (_showW1StartV1 ||
            _w1RulesAnswersV1 != null ||
            _w1RulesResultV1 != null)) {
      return _buildW1RulesFlowV1();
    }
    final baseState = widget.state ?? Act0ShellStateV1.sample;
    final progress = _progressSnapshot(baseState);
    final state = _stateWithProgress(baseState, progress);
    final reviewState = _reviewState(state.review);
    late final reviewCoaching = _reviewPatternCoachingProjectionV1();
    final personalizedNextStep = _personalizedNextStepV1(reviewState);
    // Home's NoPersonal reason falls back to the lesson card, never a review.
    final homeDueReview =
        personalizedNextStep.reasonType ==
            act0ReturnReasonNoPersonalReasonAvailableV1
        ? null
        : _launchableDueReviewV1(personalizedNextStep);
    final homeDueReviewTitle = homeDueReview == null
        ? null
        : _localizedLessonTitleV1(
            _lessonById(
              _worldById(
                _progressedWorlds(state),
                homeDueReview.worldId,
              ).lessons,
              homeDueReview.lessonId,
            ),
          );
    if ((_tab == Act0ShellTabV1.home || _tab == Act0ShellTabV1.review) &&
        !_showPlacement &&
        !_showWelcome) {
      _schedulePersonalizedNextStepExposureV1(
        personalizedNextStep,
        surface: _tab == Act0ShellTabV1.home ? 'home' : 'review',
      );
    }
    final profileState = _profileState(state.profile, progress);
    final currentProfileEvidenceProjection = _tab == Act0ShellTabV1.profile
        ? Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
            _learningEvidenceHistoryV1,
            nowUtc: widget.clock.nowUtc(),
            studyObservations: _studyObservationsV1,
          )
        : const Act0ProfileEvidenceProjectionV1();
    if ((_tab == Act0ShellTabV1.home || _tab == Act0ShellTabV1.review) &&
        reviewState.mistakes.isNotEmpty &&
        !_showPlacement &&
        !_showWelcome) {
      _emitRepairItemShownTelemetryV1(reviewState.mistakes.first);
    }
    final reviewNavHasDot = reviewState.mistakes.isNotEmpty;
    final worlds = _progressWorlds(baseState);
    _normalizeSelection(worlds);
    final selectedWorld = _worldById(worlds, _selectedWorldId);
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final practiceGroups = _practiceGroups(
      state: state,
      world: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final dailyGroup = practiceGroups.firstWhere(
      (group) => group.groupId == 'daily',
    );
    final practiceSurfaceRecommendation = _practiceSurfaceRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
      groups: practiceGroups,
    );
    final isPlayTab = _tab == Act0ShellTabV1.play;
    final isPlayRunner =
        isPlayTab && !_showPlayHub && _blockCompletionSummary == null;
    final playSelectedTask = isPlayTab
        ? _taskById(selectedLesson, _selectedTaskId)
        : null;
    final inlineRepairSource =
        _activeSameSignalFeedbackRepairV1 &&
            _activeRepairTaskId == playSelectedTask?.taskId
        ? _mistakeRecords[_pendingFeedbackRepairSourceTaskIdV1]
        : null;
    ({int step, int total})? extraPracticeProgress;
    if (inlineRepairSource != null) {
      final sourceLesson = _lessonById(
        _worldById(worlds, inlineRepairSource.worldId).lessons,
        inlineRepairSource.lessonId,
      );
      extraPracticeProgress = (
        step: _taskIndex(sourceLesson, inlineRepairSource.taskId) + 1,
        total: sourceLesson.courseTaskList.length,
      );
    }
    final sameSessionLearningDelta =
        playSelectedTask != null &&
            _activeRepairTaskId != playSelectedTask.taskId
        ? _sameSessionLearningDeltaForTaskV1(playSelectedTask.taskId)
        : null;
    if (sameSessionLearningDelta != null) {
      final deltaToEmit = sameSessionLearningDelta;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _emitSameSessionLearningDeltaViewedV1(deltaToEmit);
      });
    }
    final playTaskAlreadyCompleted =
        playSelectedTask != null &&
        _completedTaskIds.contains(playSelectedTask.taskId);
    final playTaskAwardXp =
        openedAsSpacedReview ||
            _diagnosticLearningEntryV1 != null ||
            playSelectedTask == null ||
            playTaskAlreadyCompleted
        ? 0
        : playSelectedTask.rewardXp;
    final playRunner = isPlayRunner
        ? normalizeAct0DrillSeatHighlightPolicyV1(
            normalizeAct0SeatTapRunnerV1(
              _actionSequenceRunnerForStageV1(
                _repairRunnerForTask(playSelectedTask!).copyWith(
                  lessonId: selectedLesson.lessonId,
                  lessonTitle: _localizedLessonTitleV1(selectedLesson),
                  lessonSubtitle: _localizedLessonSubtitleV1(selectedLesson),
                  beatIndex:
                      _taskIndex(selectedLesson, playSelectedTask.taskId) + 1,
                  beatCount: selectedLesson.courseTaskList.length,
                  phase: _phase,
                  selectedOptionId: _selectedOptionId,
                  sizingConfig: _activeSizingConfigV1(
                    selectedLesson,
                    playSelectedTask,
                  ),
                  selectedPresetId: _activeSelectedPresetIdV1(playSelectedTask),
                  teachingStepIndex: _teachingStepIndex,
                  nextLessonId: _nextLessonId(
                    selectedWorld.lessons,
                    selectedLesson.lessonId,
                  ),
                ),
                taskId: playSelectedTask.taskId,
              ),
            ),
          )
        : null;
    final placementDiagnosticSignalId = _placementDiagnosticActive
        ? _placementDiagnosticSpotsV1[_placementDiagnosticIndex].signalId
        : null;
    final placementForwardCtaLabel = _placementDiagnosticActive
        ? _placementDiagnosticIndex + 1 < _placementDiagnosticSpotsV1.length
              ? 'Next check'
              : 'See my start'
        : null;
    final placementSource = playRunner != null && _placementDiagnosticActive
        ? _diagnosticSourceForIdentityV1(
            worldId: selectedWorld.worldId,
            lessonId: selectedLesson.lessonId,
            taskId: playSelectedTask!.taskId,
            diagnosticVariantId: placementDiagnosticSignalId!,
          )
        : null;
    final dailyQueueIndex =
        isPlayRunner && _activePracticeGroupId == 'daily' && _rapidPracticeLoop
        ? _dailyPracticeQueue.taskIds.indexOf(_selectedTaskId)
        : -1;
    final activePlayRunner = placementSource != null
        ? placementSource.runner.copyWith(
            phase: _phase,
            selectedOptionId: _selectedOptionId,
          )
        : dailyQueueIndex >= 0
        ? playRunner?.copyWith(
            beatIndex: dailyQueueIndex + 1,
            beatCount: _dailyPracticeQueue.taskIds.length,
          )
        : playRunner;
    final accessibilityPrototypeStep =
        activePlayRunner != null &&
            activePlayRunner.phase != Act0LessonPhaseV1.theory &&
            (activePlayRunner.phase == Act0LessonPhaseV1.review ||
                activePlayRunner.activeTeachingStep == null) &&
            act0ShouldActivateCompactAccessibilityPrototypeV1(
              context,
              question: activePlayRunner.question,
              options: activePlayRunner.options,
              tableCriticalLabels: <String>[
                activePlayRunner.table.potLabel,
                activePlayRunner.table.toCallLabel,
              ],
            )
        ? _accessibilityPrototypeTaskId == playSelectedTask?.taskId
              ? _accessibilityPrototypeStep ??
                    Act0AccessibilityPrototypeStepV1.evidence
              : Act0AccessibilityPrototypeStepV1.evidence
        : null;
    final runnerFramingProfile = _runnerFramingProfileForTaskV1(
      task: playSelectedTask,
      runner: activePlayRunner,
      placementDiagnosticActive: _placementDiagnosticActive,
      placementSignalId: placementDiagnosticSignalId,
    );
    final suppressTaskCompletionToast =
        isPlayRunner &&
        playSelectedTask != null &&
        _isTaskCompletingLessonMilestoneV1(
          lesson: selectedLesson,
          taskId: playSelectedTask.taskId,
        );
    final completionSummary =
        isPlayRunner &&
            widget.tableVisualVariant ==
                Act0ShellTableVisualVariantV1.refinedDev2 &&
            playTaskAwardXp > 0 &&
            _cleanTaskIds.contains(playSelectedTask?.taskId) &&
            _choiceHasIndependentProvenanceV1 &&
            !suppressTaskCompletionToast
        ? Act0RunnerCompletionSummaryV1(
            xpGain: playTaskAwardXp,
            startLevel: progress.level,
            endLevel: _progressSnapshot(
              baseState,
              earnedXpDelta: _earnedXp + playTaskAwardXp,
            ).level,
            startXp: progress.xp,
            endXp: _progressSnapshot(
              baseState,
              earnedXpDelta: _earnedXp + playTaskAwardXp,
            ).xp,
            xpTarget: baseState.xpTarget,
            skillGains: _skillGainsFromMapV1(
              _skillDeltaForAnswer(selectedLesson, playSelectedTask!),
              source: playSelectedTask.title,
            ),
          )
        : null;
    final showTheoryRecallAffordance =
        isPlayRunner &&
        playSelectedTask != null &&
        _phase == Act0LessonPhaseV1.drill &&
        _selectedOptionId == null &&
        !_rapidPracticeLoop &&
        !_placementDiagnosticActive &&
        playRunner!.teachingSteps.isNotEmpty &&
        _teachingStepIndex >= playRunner.teachingSteps.length;
    final theoryRecallStep = showTheoryRecallAffordance
        ? playRunner.teachingSteps.last
        : null;
    final premiumAcademy =
        !_showPlacement &&
        !_showWelcome &&
        !isPlayRunner &&
        _blockCompletionSummary == null &&
        act0AcademyRuntimeEnabledV1(context, _tab);
    final showTopBar =
        !premiumAcademy &&
        _bootSurfaceReady &&
        !_showPlacement &&
        !_showWelcome &&
        !isPlayRunner &&
        _blockCompletionSummary == null;
    final firstValueTodayCarry =
        _tab == Act0ShellTabV1.home &&
            !_showPlacement &&
            !_showWelcome &&
            _bootSurfaceReady
        ? _actionableFirstValueReceiptCarryV1
        : null;
    if (firstValueTodayCarry != null) {
      _emitFirstValueTodayShownTelemetryV1(firstValueTodayCarry);
    }
    final effectiveLearnDetailLessonId = _learnDetailLessonId;
    final academySurface =
        !_bootSurfaceReady ||
        (_showPlacement && !_placementDiagnosticActive) ||
        _showWelcome ||
        !isPlayRunner;
    final shell = Scaffold(
      key: const Key('act0_shell_preview_screen'),
      backgroundColor: premiumAcademy || _showWelcome || _showPlacement
          ? Act0AcademyLeafPaletteV1.ink
          : academySurface
          ? Act0AcademyDesignTokensV1.pageSurface
          : Act0ShellTokensV1.background,
      body: SafeArea(
        bottom: !isPlayRunner,
        child: Column(
          children: [
            _progressSaveNoticeV1(),
            if (showTopBar)
              _TopBarV1(
                academy: academySurface,
                state: state,
                goalLabel: _compactDailyLabel(),
                goalProgress: _dailyGoalProgressValueV1(),
              ),
            Expanded(
              child: !_bootSurfaceReady
                  ? const Center(child: CircularProgressIndicator())
                  : _showPlacement && !_placementDiagnosticActive
                  ? Act0PlacementShellV1(
                      questions: _localizedPlacementQuestionsV1(),
                      showIntro: _placementIntroVisible,
                      currentQuestionIndex: _placementQuestionIndex,
                      selectedOptionIds: _placementAnswerIds,
                      result: _placementResult == null
                          ? null
                          : _localizedPlacementResultV1(_placementResult!),
                      onSelectOption: (question, optionId) => setState(() {
                        _togglePlacementOption(question, optionId);
                      }),
                      onStartPlacement: () {
                        if (_skipIntroductionSavingV1) return;
                        setState(() {
                          _placementIntroVisible = false;
                          _placementQuestionIndex = 0;
                        });
                      },
                      onBack: () => setState(() {
                        if (_placementQuestionIndex > 0) {
                          _placementQuestionIndex -= 1;
                        } else {
                          _placementIntroVisible = true;
                        }
                      }),
                      onNext: () => setState(() {
                        _placementIntroVisible = false;
                        if (_placementQuestionIndex <
                            _placementQuestionsV1.length) {
                          _placementQuestionIndex += 1;
                        }
                      }),
                      onStartDiagnostic: () => setState(() {
                        _startPlacementDiagnostic(_progressWorlds(baseState));
                      }),
                      onStartRecommended: () {
                        setState(() {
                          unawaited(
                            _startPlacementRecommendation(
                              _progressWorlds(baseState),
                              fromZero: false,
                              directRunner: true,
                            ),
                          );
                        });
                      },
                      onSkipIntroduction:
                          _placementRetakeV1 || _skipIntroductionSavingV1
                          ? null
                          : () => unawaited(_skipIntroductionV1()),
                      onStartFromZero: () {
                        setState(() {
                          unawaited(
                            _startPlacementRecommendation(
                              _progressWorlds(baseState),
                              fromZero: true,
                            ),
                          );
                        });
                      },
                    )
                  : _showWelcome
                  ? Act0WelcomeShellV1(
                      replayMode: _welcomeReturnTabV1 != null,
                      handoffStartsRecommendedTask:
                          _welcomeHandoffStartsRecommendedTaskV1,
                      onCompleted: _welcomeCompletionSavingV1
                          ? null
                          : () {
                              unawaited(_completeWelcomeV1());
                            },
                      onClose: _welcomeReturnTabV1 != null
                          ? _closeWelcomeReplayV1
                          : null,
                      tableVisualVariant: widget.tableVisualVariant,
                    )
                  : switch (_tab) {
                      Act0ShellTabV1.home => act0AcademyHomeRuntimeV1(
                        context,
                        isCurrent: () =>
                            _acceptRecoveryCallbackV1(callbackEpochV1),
                        courseTitle: act0AcademyWorldTitleV1(
                          context,
                          selectedWorld,
                        ),
                        earnedLessons:
                            selectedWorld.status == Act0WorldStateV1.locked
                            ? 0
                            : selectedWorld.lessons
                                  .where(
                                    (lesson) => _lessonCompleteWithTaskIds(
                                      lesson,
                                      _completedTaskIds,
                                    ),
                                  )
                                  .length,
                        totalLessons: selectedWorld.lessons.length,
                        phase: homeDueReview != null
                            ? Act0AcademyHomePhaseV1.recall
                            : switch (personalizedNextStep.recommendedAction) {
                                'repair' ||
                                'retry_repair' ||
                                'reinforce' => Act0AcademyHomePhaseV1.apply,
                                _ => Act0AcademyHomePhaseV1.learn,
                              },
                        legacy: Act0HomeShellV1(
                          state: state,
                          showChecklist: _showHomeChecklistV1(),
                          currentLesson: _firstPlayableLesson(selectedWorld),
                          pathProgressLabel: selectedWorld.progressLabel,
                          nextActionLabel: homeDueReview != null
                              ? _copyV1(en: 'Review', ru: 'Разбор')
                              : _homeNextActionLabel(),
                          nextActionTitle:
                              homeDueReviewTitle ??
                              _homeNextActionTitle(
                                _firstPlayableLesson(selectedWorld),
                              ),
                          nextActionSubtitle:
                              homeDueReview != null &&
                                  (personalizedNextStep.copyLine ?? '')
                                      .trim()
                                      .isNotEmpty
                              ? personalizedNextStep.copyLine!
                              : _homeNextActionSubtitle(
                                  _firstPlayableLesson(selectedWorld),
                                ),
                          nextActionCtaLabel: homeDueReview != null
                              ? _copyV1(
                                  en: 'Review now',
                                  ru: 'Повторить сейчас',
                                )
                              : _homeNextActionCtaLabel(),
                          nextActionHint: homeDueReview != null
                              ? null
                              : _homeCtaHint(
                                  selectedWorld,
                                  _firstPlayableLesson(selectedWorld),
                                ),
                          repairLabel: _homeRepairLabel(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          repairHeadline: _homeRepairHeadline(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          repairDetail: _homeRepairDetail(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          repairOutcome: _homeRepairOutcome(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          repairCtaLabel: _homeRepairCtaLabel(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          showRepairPanel: _showHomeRepairPanel(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          onStartRepair: () => setState(() {
                            _startHomeRepairAction(
                              selectedWorld,
                              _firstPlayableLesson(selectedWorld),
                            );
                          }),
                          dailyGoalValue: _dailyGoalValueLabel(),
                          dailyGoalCtaLabel: _homeDailyGoalCtaLabel(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          dailyPlanTitle: _homeDailyPlanTitle(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          nextUsefulHandReasonLine:
                              _homeNextUsefulHandReasonLine(
                                selectedWorld,
                                _firstPlayableLesson(selectedWorld),
                              ),
                          personalizedReturnReasonLine:
                              personalizedNextStep.copyLine,
                          weeklyFocus: _showHomeChecklistV1()
                              ? _homeWeeklyFocus(
                                  selectedWorld,
                                  _firstPlayableLesson(selectedWorld),
                                )
                              : null,
                          dailyPlanJobs: _homeDailyPlanJobs(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          ),
                          onOpenDailyPlanJob: (jobId) => setState(() {
                            _startHomeDailyPlanJob(
                              selectedWorld,
                              _firstPlayableLesson(selectedWorld),
                              jobId,
                            );
                          }),
                          onOpenLearnContext: () => setState(() {
                            final lesson = _firstPlayableLesson(selectedWorld);
                            _activateLearnVisitEligibilityV1();
                            _tab = Act0ShellTabV1.learn;
                            _showPlayHub = true;
                            _returnToPlayHubOnBack = false;
                            _showWorldMenu = false;
                            _blockCompletionSummary = null;
                            _seedLearnRouteFocusV1(
                              lessonId: lesson.lessonId,
                              taskId: _firstIncompleteTask(lesson).taskId,
                            );
                          }),
                          onOpenPracticeContext: () =>
                              setState(_openPracticeHubV1),
                          onOpenReviewContext: () => setState(() {
                            _tab = Act0ShellTabV1.review;
                            _showPlayHub = true;
                            _returnToPlayHubOnBack = false;
                            _learnDetailLessonId = null;
                            _learnDetailWorldId = null;
                            _showWorldMenu = false;
                            _blockCompletionSummary = null;
                          }),
                          sharkyOverride: _homeSharkyOverride(),
                          onOpenDevMenu:
                              act0DevMenuEnabledV1(isReleaseMode: kReleaseMode)
                              ? _openDevMenu
                              : null,
                          onStartDailyDrill:
                              dailyGroup.isEnabled &&
                                  _dailyCompletedRepCount < 3 &&
                                  (_dailyPracticeQueue.taskIds.isEmpty ||
                                      _dailyPracticeQueue.nextTaskId != null)
                              ? () => setState(
                                  () => _startPracticeGroup(
                                    dailyGroup,
                                    selectedWorld,
                                  ),
                                )
                              : null,
                          onContinue: () => setState(() {
                            _openPersonalizedNextStepV1(
                              personalizedNextStep,
                              surface: 'home',
                              selectedWorld: selectedWorld,
                              reviewState: reviewState,
                            );
                          }),
                        ),
                      ),
                      Act0ShellTabV1.learn => Act0LearnPathShellV1(
                        moduleTitle: act0DisplayWorldNameCopyV1(
                          selectedWorld.title,
                        ),
                        moduleProgressLabel: selectedWorld.progressLabel,
                        sharkyGuideTitle: _learnGuideTitle(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideLine: _learnGuideLine(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideDetail: _learnGuideDetail(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideMood: _learnGuideMood(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        worlds: worlds,
                        selectedWorldId: _selectedWorldId,
                        showWorldMenu: _showWorldMenu,
                        onW1RulesCheck:
                            selectedWorld.worldId == 'world_1' &&
                                _canTakeW1RulesCheckV1
                            ? _beginW1RulesCheckV1
                            : null,
                        worldDetailId: _learnDetailWorldId,
                        lessons: selectedWorld.lessons,
                        selectedLessonId: _selectedLessonId,
                        selectedTaskId: _selectedTaskId,
                        activePopupTaskId: _learnPopupTaskId,
                        completedTaskIds: _completedTaskIds,
                        perfectTaskIds: _perfectTaskIds(),
                        skippedTaskIds: _visibleSkippedTaskIds,
                        pathClosedTaskIds: _pathClosedTaskIds,
                        detailLessonId: effectiveLearnDetailLessonId,
                        lessonOutcomeLabels: {
                          for (final question in act0W1RulesQuestionsV1)
                            if (_w1RulesFocusTaskIdsV1.contains(
                              question.taskId,
                            ))
                              question.lessonId: 'Worth revisiting',
                          ..._lessonOutcomeLabels(selectedWorld.lessons),
                        },
                        onSelectWorld: (worldId) {
                          final world = _worldById(worlds, worldId);
                          setState(() {
                            if (world.isSelectable) {
                              final lesson = _firstPlayableLesson(world);
                              final selectedTaskId = _firstIncompleteTask(
                                lesson,
                              ).taskId;
                              _selectedWorldId = worldId;
                              _phase = _taskById(
                                lesson,
                                selectedTaskId,
                              ).entryPhase;
                              _selectedOptionId = null;
                              _teachingStepIndex = 0;
                              _showWorldMenu = false;
                              _learnDetailWorldId = null;
                              _seedLearnRouteFocusV1(
                                lessonId: lesson.lessonId,
                                taskId: selectedTaskId,
                              );
                            } else {
                              _learnDetailWorldId = worldId;
                              _learnDetailLessonId = null;
                            }
                          });
                        },
                        onOpenWorldMenu: () => setState(() {
                          _showWorldMenu = true;
                          _learnDetailLessonId = null;
                          _learnPopupTaskId = null;
                        }),
                        onCloseWorldMenu: () => setState(() {
                          _showWorldMenu = false;
                          _learnDetailWorldId = null;
                          _learnPopupTaskId = null;
                        }),
                        onDismissWorldDetail: () => setState(() {
                          _learnDetailWorldId = null;
                          _learnPopupTaskId = null;
                        }),
                        onPreviewPremiumWorld: _previewLockedWorldPremium,
                        onSelectLesson: (lessonId) {
                          final lesson = selectedWorld.lessons
                              .cast<Act0LessonCardV1?>()
                              .firstWhere(
                                (candidate) => candidate?.lessonId == lessonId,
                                orElse: () => null,
                              );
                          if (lesson == null) {
                            return false;
                          }
                          return _handleLearnLessonSelectV1(
                            lesson: lesson,
                            lessonId: lessonId,
                          );
                        },
                        onOpenLessonAfterScroll:
                            _handleLearnLessonOpenAfterScrollV1,
                        onDismissDetail: () => setState(() {
                          _learnDetailLessonId = null;
                          _learnPopupTaskId = null;
                        }),
                        onSelectTask: (lessonId, taskId) {
                          final lesson = _lessonById(
                            selectedWorld.lessons,
                            lessonId,
                          );
                          if (!lesson.taskList.any(
                            (task) => task.taskId == taskId,
                          )) {
                            return;
                          }
                          final isSamePopupTask =
                              _learnDetailLessonId == lessonId &&
                              _learnPopupTaskId == taskId;
                          if (isSamePopupTask) {
                            setState(() {
                              _learnPopupTaskId = null;
                            });
                            return;
                          }
                          final taskAvailable = _taskAvailable(lesson, taskId);
                          setState(() {
                            if (lesson.isSelectable && taskAvailable) {
                              _selectedLessonId = lessonId;
                              _selectedTaskId = taskId;
                              _selectedOptionId = null;
                              _teachingStepIndex = 0;
                              _resetLessonRunMetrics();
                            }
                            _learnPopupTaskId = taskId;
                          });
                        },
                        onDismissTaskPopup: () => setState(() {
                          _learnPopupTaskId = null;
                        }),
                        onStartTask: (lessonId, taskId) {
                          final lesson = _lessonById(
                            selectedWorld.lessons,
                            lessonId,
                          );
                          if (!lesson.isSelectable ||
                              !_taskAvailable(lesson, taskId)) {
                            return;
                          }
                          _emitLessonStartedTelemetryV1(
                            lessonId: lessonId,
                            taskId: taskId,
                          );
                          _startLearningEvidenceRunV1(
                            worldId: selectedWorld.worldId,
                            lessonId: lesson.lessonId,
                            runKind: 'lesson',
                            startedBy: 'learn_route',
                          );
                          setState(() {
                            _selectedLessonId = lessonId;
                            _selectedTaskId = taskId;
                            _tab = Act0ShellTabV1.play;
                            _showPlayHub = false;
                            _returnToPlayHubOnBack = false;
                            _phase = _taskById(lesson, taskId).entryPhase;
                            _selectedOptionId = null;
                            _teachingStepIndex = 0;
                            _resetLessonRunMetrics();
                            _activePracticeGroupId = null;
                            _clearActiveRepairLaunchV1();
                            final actionSequence =
                                act0ActionLearningSequenceForTaskV1(taskId);
                            _activeActionSequenceStageV1 = actionSequence
                                ?.stageForTask(taskId);
                            _learnDetailLessonId = null;
                            _learnPopupTaskId = null;
                            _learnDetailWorldId = null;
                          });
                        },
                      ),
                      Act0ShellTabV1.play =>
                        _showPlayHub && _blockCompletionSummary == null
                            ? act0AcademyPracticeRuntimeV1(
                                context,
                                isCurrent: () =>
                                    _acceptRecoveryCallbackV1(callbackEpochV1),
                                legacy: Act0PlayShellV1(
                                  groups: practiceGroups,
                                  recommendedGroupId:
                                      practiceSurfaceRecommendation.groupId,
                                  recommendedTitle:
                                      practiceSurfaceRecommendation.title,
                                  recommendedSubtitle:
                                      practiceSurfaceRecommendation.subtitle,
                                  recommendedReasonLabel:
                                      practiceSurfaceRecommendation.reasonLabel,
                                  recommendedOutcome:
                                      practiceSurfaceRecommendation.outcome,
                                  recommendedOutcomeLead:
                                      practiceSurfaceRecommendation.outcomeLead,
                                  masteryLabel: practiceSurfaceRecommendation
                                      .masteryLabel,
                                  screenSubtitle: practiceSurfaceRecommendation
                                      .screenSubtitle,
                                  repairQueueConsumer:
                                      Act0PracticeRepairQueueConsumerV1.fromProjection(
                                        Act0PracticeRepairQueueProjectionV1.fromSources(
                                          learningEvidenceHistory:
                                              _learningEvidenceHistoryV1,
                                          currentFingerprintForIdentity:
                                              _repairFingerprintForIdentityV1,
                                          activeRepairIntents:
                                              _activeRepairIntentsV1(),
                                          reviewMistakeHistory:
                                              _reviewMistakeHistoryV1,
                                          repairOutcomeProjection:
                                              _repairOutcomeProjectionV1,
                                        ),
                                      ),
                                  completionTitle: _practiceCompletionTitle,
                                  completionBody: _practiceCompletionBody,
                                  onOpenPremiumPreview:
                                      _practiceCompletionTitle ==
                                          _copyV1(
                                            en: 'Session complete',
                                            ru: 'Дневная серия закрыта',
                                          )
                                      ? _openCompletedDailyPremiumPreviewSheet
                                      : null,
                                  onStartGroup: (group) => setState(() {
                                    _startPracticeGroup(group, selectedWorld);
                                  }),
                                  onLaunchRepairQueueTarget: (target) =>
                                      setState(() {
                                        _startPracticeRepairQueueTarget(target);
                                      }),
                                ),
                              )
                            : _blockCompletionSummary != null
                            ? Act0BlockCompletionShellV1(
                                summary: _blockCompletionSummary!,
                                firstCorrectEarnedThisRun:
                                    _firstCorrectReadEarnedInCurrentLessonRunV1(),
                                nextUsefulHand: _summaryHomeHandoffV1(
                                  selectedWorld,
                                ),
                                onNextUsefulHand: () => setState(() {
                                  _startHomeRepairAction(
                                    selectedWorld,
                                    _firstPlayableLesson(selectedWorld),
                                  );
                                }),
                                evidenceSummary:
                                    Act0SessionSummaryEvidenceViewModelV1.fromHistory(
                                      _learningEvidenceHistoryV1,
                                      repairFocusLabelsById:
                                          _sessionSummaryRepairFocusLabelsByIdV1(),
                                    ),
                                earnedMomentConsumer:
                                    Act0AchievementSeedConsumerV1.fromProjection(
                                      Act0AchievementSeedProjectionV1.fromSources(
                                        learningEvidenceHistory:
                                            _learningEvidenceHistoryV1,
                                        repairIntents:
                                            _openRepairIntentBySourceTaskId
                                                .values
                                                .toList(growable: false),
                                        reviewMistakeHistory:
                                            _reviewMistakeHistoryV1,
                                        profileStreakDays:
                                            profileState.streakDays,
                                      ),
                                    ),
                                repairOutcomeConsumer:
                                    Act0RepairOutcomeConsumerV1.fromProjection(
                                      _repairOutcomeProjectionV1,
                                      learningEvidenceHistory:
                                          _learningEvidenceHistoryV1,
                                      currentFingerprintForIdentity:
                                          _repairFingerprintForIdentityV1,
                                      repairIntents: _activeRepairIntentsV1(),
                                      fixProofProjection:
                                          _fixProofProjectionV1(),
                                      improvementObservationProjection:
                                          _sharkyImprovementObservationProjectionV1(),
                                    ),
                                onLaunchPracticeRepairQueueTarget: (target) =>
                                    setState(() {
                                      _startPracticeRepairQueueTarget(
                                        target,
                                        evidenceStartedBy:
                                            'session_summary_practice_cta',
                                      );
                                    }),
                                onReplay: () => setState(() {
                                  _showPlayHub = false;
                                  _selectedTaskId = selectedLesson
                                      .courseTaskList
                                      .first
                                      .taskId;
                                  _phase = _taskById(
                                    selectedLesson,
                                    _selectedTaskId,
                                  ).entryPhase;
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                  _resetLessonRunMetrics();
                                }),
                                onOpenReview: () => setState(() {
                                  _tab = Act0ShellTabV1.review;
                                  _showPlayHub = true;
                                  _returnToPlayHubOnBack = false;
                                  _learnDetailLessonId = null;
                                  _learnDetailWorldId = null;
                                  _showWorldMenu = false;
                                  _blockCompletionSummary = null;
                                }),
                                onBackToMap: () => setState(() {
                                  _tab = Act0ShellTabV1.learn;
                                  final currentPlayableLesson =
                                      _firstPlayableLesson(selectedWorld);
                                  _seedLearnRouteFocusV1(
                                    lessonId: currentPlayableLesson.lessonId,
                                    taskId: _firstIncompleteTask(
                                      currentPlayableLesson,
                                    ).taskId,
                                  );
                                  _showWorldMenu = false;
                                  _blockCompletionSummary = null;
                                }),
                                onContinue: () => setState(() {
                                  final progressedWorlds = _progressWorlds(
                                    baseState,
                                  );
                                  final nextLessonId = _nextLessonId(
                                    selectedWorld.lessons,
                                    selectedLesson.lessonId,
                                  );
                                  if (nextLessonId == null) {
                                    final nextWorld = _nextSelectableWorld(
                                      progressedWorlds,
                                      _selectedWorldId,
                                    );
                                    if (nextWorld == null) {
                                      _tab = Act0ShellTabV1.learn;
                                      _showPlayHub = true;
                                      final currentPlayableLesson =
                                          _firstPlayableLesson(selectedWorld);
                                      _seedLearnRouteFocusV1(
                                        lessonId:
                                            currentPlayableLesson.lessonId,
                                        taskId: _firstIncompleteTask(
                                          currentPlayableLesson,
                                        ).taskId,
                                      );
                                      _showWorldMenu = false;
                                      _blockCompletionSummary = null;
                                      return;
                                    }
                                    final nextLesson = _firstPlayableLesson(
                                      nextWorld,
                                    );
                                    _selectedWorldId = nextWorld.worldId;
                                    _selectedLessonId = nextLesson.lessonId;
                                    _selectedTaskId = _firstIncompleteTask(
                                      nextLesson,
                                    ).taskId;
                                    _phase = _taskById(
                                      nextLesson,
                                      _selectedTaskId,
                                    ).entryPhase;
                                    _showPlayHub = false;
                                    _selectedOptionId = null;
                                    _teachingStepIndex = 0;
                                    _learnDetailLessonId = null;
                                    _learnDetailWorldId = null;
                                    _showWorldMenu = false;
                                    _blockCompletionSummary = null;
                                    _resetLessonRunMetrics();
                                    return;
                                  }
                                  final progressedWorld = _worldById(
                                    progressedWorlds,
                                    _selectedWorldId,
                                  );
                                  final nextLesson = _lessonById(
                                    progressedWorld.lessons,
                                    nextLessonId,
                                  );
                                  _selectedLessonId = nextLesson.lessonId;
                                  _selectedTaskId = _firstIncompleteTask(
                                    nextLesson,
                                  ).taskId;
                                  _phase = _taskById(
                                    nextLesson,
                                    _selectedTaskId,
                                  ).entryPhase;
                                  _showPlayHub = false;
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                  _blockCompletionSummary = null;
                                  _resetLessonRunMetrics();
                                }),
                              )
                            : Act0LessonRunnerShellV1(
                                // B5 view metadata. `_activeActionSequenceStageV1`
                                // is the existing typed owner of the canonical
                                // wrong-feedback -> repair -> recheck transition
                                // (`_advanceActionSequenceReviewV1`). Passing it
                                // to the renderer exposes a stage the product
                                // already computes; it drives no progression.
                                learningLoopStage: _activeActionSequenceStageV1,
                                runner: activePlayRunner!,
                                preserveSourceOwnedQuestion:
                                    _placementDiagnosticActive,
                                worldNumber: selectedWorld.worldNumber,
                                selectedWorldId: selectedWorld.worldId,
                                selectedLessonId: selectedLesson.lessonId,
                                selectedTaskId: playSelectedTask?.taskId,
                                selectedTaskTitle: playSelectedTask == null
                                    ? null
                                    : _localizedTaskTitleV1(playSelectedTask),
                                selectedTaskFamily:
                                    playSelectedTask?.resolvedTaskFamily,
                                compositionFamily:
                                    playSelectedTask
                                        ?.resolvedCompositionFamily ??
                                    Act0RunnerCompositionFamilyV1.f2AnswerList,
                                tablePresentation:
                                    playSelectedTask?.tablePresentation ??
                                    Act0TaskTablePresentationV1.legacy,
                                accessibilityPrototypeStep:
                                    accessibilityPrototypeStep,
                                onAccessibilityPrototypeStepChanged: (next) {
                                  if (!(_acceptRecoveryCallbackV1(
                                        callbackEpochV1,
                                      ) &&
                                      _acceptDiagnosticRunnerCallbackV1(
                                        callbackDiagnosticEntryV1,
                                        callbackDiagnosticRunIdV1,
                                      )))
                                    return;

                                  setState(() {
                                    _accessibilityPrototypeTaskId =
                                        playSelectedTask.taskId;
                                    _accessibilityPrototypeStep = next;
                                  });
                                },
                                telemetrySink: _sessionAwareTelemetrySinkV1(),
                                evidenceRunId:
                                    _activeLearningEvidenceRunKeyV1?.runId ??
                                    '',
                                evidenceNextOrder: _latestEvidenceOrderV1() + 1,
                                reviewKindId: _routeReviewKindForTaskIdV1(
                                  playSelectedTask?.taskId ?? '',
                                ).name,
                                theoryRecallStep: theoryRecallStep,
                                framingProfile: runnerFramingProfile,
                                tableVisualVariant: widget.tableVisualVariant,
                                completionSummary: completionSummary,
                                isAssistedDecision: _choiceWasAssistedV1,
                                firstValueReceiptLine:
                                    _diagnosticLearningEntryV1 == null &&
                                        _placementHandoffActive &&
                                        !_placementDiagnosticActive
                                    ? _firstValueReceiptLineV1(playSelectedTask)
                                    : null,
                                repairReasonLine:
                                    _diagnosticLearningEntryV1 != null
                                    ? 'Guided review. Your saved check stays open.'
                                    : _repairReasonLineForFeedbackV1(
                                        playSelectedTask,
                                      ),
                                repairResultReceiptLine:
                                    _activeRepairTaskId ==
                                        playSelectedTask?.taskId
                                    ? _activeRepairResultReceiptLine
                                    : null,
                                repairOutcomeProofLine:
                                    _activeRepairTaskId ==
                                        playSelectedTask?.taskId
                                    ? _repairOutcomeProofLineV1()
                                    : sameSessionLearningDelta?.line,
                                forceShowRepairOutcomeProof:
                                    sameSessionLearningDelta != null,
                                extraPracticeProgress: extraPracticeProgress,
                                repairContinuesToSourceRecheck:
                                    _activeRepairTaskId ==
                                        playSelectedTask?.taskId &&
                                    _activeSameSignalFeedbackRepairV1,
                                isSourceRecheckAttempt:
                                    _activeSameSignalRecheckTaskId ==
                                    playSelectedTask?.taskId,
                                repairSessionSummaryLines:
                                    _activeRepairTaskId ==
                                        playSelectedTask?.taskId
                                    ? _activeRepairSessionSummaryLines
                                    : const <String>[],
                                feedbackForwardCtaLabel:
                                    _diagnosticLearningEntryV1 != null ||
                                        _spacedReviewReturnV1 != null
                                    ? 'Back to Review'
                                    : placementForwardCtaLabel ??
                                          (_activeRepairTaskId ==
                                                      playSelectedTask
                                                          ?.taskId &&
                                                  (!_activeSameSignalFeedbackRepairV1 ||
                                                      !act0IndependentRepairProofV1(
                                                        isCorrect:
                                                            playRunner
                                                                ?.selectedOption
                                                                ?.isCorrect ??
                                                            false,
                                                        assistanceKind:
                                                            _choiceAssistanceV1,
                                                      ))
                                              ? 'Continue to Review'
                                              : null),
                                suppressFeedbackRepairFocus:
                                    _placementDiagnosticActive,
                                relaxTheoryAdvanceLock: _completedTaskIds
                                    .contains(playSelectedTask!.taskId),
                                showLearningRailFocusLabels:
                                    _activeRepairTaskId ==
                                    playSelectedTask.taskId,
                                onBack: () => _setStateForRunnerCallbackV1(
                                  callbackEpochV1,
                                  callbackDiagnosticEntryV1,
                                  callbackDiagnosticRunIdV1,
                                  () {
                                    if (openedAsSpacedReview) {
                                      _returnFromSpacedReviewV1(
                                        callbackDiagnosticRunIdV1,
                                      );
                                      return;
                                    }
                                    _pendingReviewKindV1 = null;
                                    if (_diagnosticLearningEntryV1 != null) {
                                      _returnFromDiagnosticLearningEntryV1();
                                      return;
                                    }
                                    if (_placementDiagnosticActive) {
                                      _endPlacementAssessmentRunV1();
                                      _placementDiagnosticActive = false;
                                      _showPlacement = true;
                                      _showPlayHub = true;
                                      _placementDiagnosticIndex = 0;
                                      _placementDiagnosticCorrect = 0;
                                      _placementDiagnosticScore = 0;
                                      _placementDiagnosticHitSignals.clear();
                                      _placementDiagnosticMissSignals.clear();
                                      _selectedOptionId = null;
                                      _phase = Act0LessonPhaseV1.theory;
                                      _teachingStepIndex = 0;
                                      return;
                                    }
                                    if (_activeRepairTaskId != null) {
                                      _tab = Act0ShellTabV1.review;
                                      _showPlayHub = true;
                                      _returnToPlayHubOnBack = false;
                                      _clearActiveRepairLaunchV1();
                                      _activeRepairSourceTaskId = null;
                                      _activeRepairResultReceiptLine = null;
                                      _activeRepairSessionSummaryLines =
                                          const <String>[];
                                      _selectedOptionId = null;
                                      _phase = Act0LessonPhaseV1.theory;
                                      _teachingStepIndex = 0;
                                      return;
                                    }
                                    if (_returnToPlayHubOnBack) {
                                      _showPlayHub = true;
                                    } else {
                                      _emitSessionExitedTelemetryV1(
                                        sourceSurface: 'act0_runner_back',
                                      );
                                      _activateLearnVisitEligibilityV1();
                                      _tab = Act0ShellTabV1.learn;
                                    }
                                  },
                                ),
                                onPreviousTheory: () =>
                                    _setStateForRunnerCallbackV1(
                                      callbackEpochV1,
                                      callbackDiagnosticEntryV1,
                                      callbackDiagnosticRunIdV1,
                                      () {
                                        if (_teachingStepIndex > 0) {
                                          _teachingStepIndex -= 1;
                                        }
                                      },
                                    ),
                                onUndoInteraction: _spacedReviewReturnV1 != null
                                    ? null
                                    : () => _setStateForRunnerCallbackV1(
                                        callbackEpochV1,
                                        callbackDiagnosticEntryV1,
                                        callbackDiagnosticRunIdV1,
                                        () {
                                          if (_phase ==
                                              Act0LessonPhaseV1.review) {
                                            _selectedOptionId = null;
                                            _phase = Act0LessonPhaseV1.drill;
                                            _teachingStepIndex =
                                                activePlayRunner
                                                    .teachingSteps
                                                    .length;
                                            return;
                                          }
                                          if (_phase ==
                                                  Act0LessonPhaseV1.drill &&
                                              activePlayRunner
                                                  .teachingSteps
                                                  .isNotEmpty) {
                                            _selectedOptionId = null;
                                            _teachingStepIndex =
                                                activePlayRunner
                                                    .teachingSteps
                                                    .length -
                                                1;
                                          }
                                        },
                                      ),
                                onContinueTheory: () => _setStateForRunnerCallbackV1(
                                  callbackEpochV1,
                                  callbackDiagnosticEntryV1,
                                  callbackDiagnosticRunIdV1,
                                  () {
                                    // A queued Continue belongs to its original
                                    // task, even if another tap already advanced.
                                    if (_selectedWorldId !=
                                            selectedWorld.worldId ||
                                        _selectedLessonId !=
                                            selectedLesson.lessonId ||
                                        _selectedTaskId !=
                                            playSelectedTask.taskId)
                                      return;
                                    if (_advanceTeachingStep(playRunner!)) {
                                      return;
                                    }
                                    if (playSelectedTask.phase !=
                                        Act0LessonPhaseV1.theory) {
                                      // Drill-phase teaching preamble (e.g. a
                                      // theory recall ahead of the real drill
                                      // options): exiting it only dismisses the
                                      // preamble. The task itself is not done
                                      // yet, so it must not run task-completion
                                      // side effects.
                                      return;
                                    }
                                    _recordCompletedStudyV1(playSelectedTask);
                                    _emitActionTheoryCompletedTelemetryV1(
                                      playSelectedTask,
                                    );
                                    _completeCurrentTask(playSelectedTask);
                                    if (_maybeStartLessonWrapUpRetry(
                                      selectedLesson,
                                    )) {
                                      return;
                                    }
                                    if (_maybeShowBlockCompletionSummary(
                                      selectedWorld: selectedWorld,
                                      selectedLesson: selectedLesson,
                                      selectedTask: playSelectedTask,
                                    )) {
                                      return;
                                    }
                                    if (_advanceActionTheoryToDecisionV1(
                                      selectedLesson: selectedLesson,
                                      selectedTask: playSelectedTask,
                                    )) {
                                      return;
                                    }
                                    _advanceAfterTask(
                                      selectedWorld,
                                      selectedLesson,
                                    );
                                  },
                                ),
                                onChooseOption: (option) => _setStateForRunnerCallbackV1(
                                  callbackEpochV1,
                                  callbackDiagnosticEntryV1,
                                  callbackDiagnosticRunIdV1,
                                  () {
                                    _fireAnswerEffects(option);
                                    if (_isPracticeQueueRepairAnswerV1(
                                      playSelectedTask,
                                    )) {
                                      _activeRepairResultReceiptLine = null;
                                      _activeRepairSessionSummaryLines =
                                          const <String>[];
                                    } else {
                                      _activeRepairResultReceiptLine =
                                          _repairResultReceiptLineForOptionV1(
                                            selectedTask: playSelectedTask,
                                            option: option,
                                          );
                                      _activeRepairSessionSummaryLines =
                                          _repairSessionSummaryLinesForOptionV1(
                                            selectedTask: playSelectedTask,
                                            option: option,
                                          );
                                    }
                                    _captureFirstValueReceiptCarryV1(
                                      runner: activePlayRunner,
                                      sourceWorldId: selectedWorld.worldId,
                                      sourceLessonId: selectedLesson.lessonId,
                                      task: playSelectedTask,
                                      option: option,
                                    );
                                    if (!_placementDiagnosticActive) {
                                      _recordAnswer(
                                        selectedLesson,
                                        playSelectedTask,
                                        option,
                                      );
                                    } else {
                                      _recordPlacementDiagnosticMissForRepairV1(
                                        selectedWorld: selectedWorld,
                                        selectedLesson: selectedLesson,
                                        selectedTask: playSelectedTask,
                                        runner: activePlayRunner,
                                        option: option,
                                      );
                                    }
                                    _selectedOptionId = option.id;
                                    _selectedPresetId = null;
                                    _selectedPresetTaskId = null;
                                    _phase = Act0LessonPhaseV1.review;
                                    _teachingStepIndex = 0;
                                  },
                                ),
                                onSelectSizingPreset: (preset) =>
                                    _setStateForRunnerCallbackV1(
                                      callbackEpochV1,
                                      callbackDiagnosticEntryV1,
                                      callbackDiagnosticRunIdV1,
                                      () {
                                        _selectedPresetId = preset.id;
                                        _selectedPresetTaskId =
                                            playSelectedTask.taskId;
                                      },
                                    ),
                                onConfirmSizingPreset: () =>
                                    _setStateForRunnerCallbackV1(
                                      callbackEpochV1,
                                      callbackDiagnosticEntryV1,
                                      callbackDiagnosticRunIdV1,
                                      () {
                                        _confirmSizingPresetAnswerV1(
                                          selectedLesson: selectedLesson,
                                          selectedTask: playSelectedTask,
                                        );
                                      },
                                    ),
                                initialChoiceAssistance:
                                    _pendingAssistanceForV1(
                                      selectedWorld.worldId,
                                      selectedLesson.lessonId,
                                      playSelectedTask.taskId,
                                    ),
                                onAssistanceExposureRequested: (_) async {
                                  if (!(_acceptRecoveryCallbackV1(
                                        callbackEpochV1,
                                      ) &&
                                      _acceptDiagnosticRunnerCallbackV1(
                                        callbackDiagnosticEntryV1,
                                        callbackDiagnosticRunIdV1,
                                      )))
                                    return false;
                                  final ack = Completer<bool>();
                                  _retainChoiceAssistanceV1(
                                    Act0DecisionAssistanceV1.legacyUnknown,
                                    worldId: selectedWorld.worldId,
                                    lessonId: selectedLesson.lessonId,
                                    taskId: playSelectedTask.taskId,
                                    acknowledgement: ack,
                                  );
                                  final key = jsonEncode([
                                    selectedWorld.worldId,
                                    selectedLesson.lessonId,
                                    playSelectedTask.taskId,
                                  ]);
                                  final receipt =
                                      _pendingDecisionAssistanceV1[key];
                                  final saved = await ack.future;
                                  return saved &&
                                      (_acceptRecoveryCallbackV1(
                                            callbackEpochV1,
                                          ) &&
                                          _acceptDiagnosticRunnerCallbackV1(
                                            callbackDiagnosticEntryV1,
                                            callbackDiagnosticRunIdV1,
                                          )) &&
                                      _tab == Act0ShellTabV1.play &&
                                      !_showPlayHub &&
                                      _phase == Act0LessonPhaseV1.drill &&
                                      _selectedOptionId == null &&
                                      _selectedWorldId ==
                                          selectedWorld.worldId &&
                                      _selectedLessonId ==
                                          selectedLesson.lessonId &&
                                      _selectedTaskId ==
                                          playSelectedTask.taskId &&
                                      receipt != null &&
                                      identical(
                                        _pendingDecisionAssistanceV1[key],
                                        receipt,
                                      );
                                },
                                onChoiceAssistance: (value) {
                                  if (!(_acceptRecoveryCallbackV1(
                                        callbackEpochV1,
                                      ) &&
                                      _acceptDiagnosticRunnerCallbackV1(
                                        callbackDiagnosticEntryV1,
                                        callbackDiagnosticRunIdV1,
                                      )))
                                    return;

                                  _retainChoiceAssistanceV1(
                                    value,
                                    worldId: selectedWorld.worldId,
                                    lessonId: selectedLesson.lessonId,
                                    taskId: playSelectedTask.taskId,
                                  );
                                },
                                onCompletedDecision: (decision) {
                                  if (!(_acceptRecoveryCallbackV1(
                                        callbackEpochV1,
                                      ) &&
                                      _acceptDiagnosticRunnerCallbackV1(
                                        callbackDiagnosticEntryV1,
                                        callbackDiagnosticRunIdV1,
                                      )))
                                    return;

                                  setState(() {
                                    if (_activeSpacedReviewTaskV1 != null) {
                                      _appendLearningEvidenceV1(decision);
                                      return;
                                    }
                                    if (_diagnosticLearningEntryV1 != null) {
                                      _appendLearningEvidenceV1(decision);
                                      return;
                                    }
                                    _latestCompletedDecisionV1 = decision;
                                    _recordCanonicalRepairDecisionV1(
                                      decision,
                                      selectedTask: playSelectedTask,
                                    );
                                    _deriveActionPersonalizationV1(decision);
                                    _recordLearningRunDecisionV1(decision);
                                  });
                                  _persistProgress();
                                },
                                onChooseSeat: (seatId) => _setStateForRunnerCallbackV1(
                                  callbackEpochV1,
                                  callbackDiagnosticEntryV1,
                                  callbackDiagnosticRunIdV1,
                                  () {
                                    for (final option
                                        in activePlayRunner.options) {
                                      if (option.seatId == seatId) {
                                        _fireAnswerEffects(option);
                                        if (_isPracticeQueueRepairAnswerV1(
                                          playSelectedTask,
                                        )) {
                                          _activeRepairResultReceiptLine = null;
                                          _activeRepairSessionSummaryLines =
                                              const <String>[];
                                        } else {
                                          _activeRepairResultReceiptLine =
                                              _repairResultReceiptLineForOptionV1(
                                                selectedTask: playSelectedTask,
                                                option: option,
                                              );
                                          _activeRepairSessionSummaryLines =
                                              _repairSessionSummaryLinesForOptionV1(
                                                selectedTask: playSelectedTask,
                                                option: option,
                                              );
                                        }
                                        _captureFirstValueReceiptCarryV1(
                                          runner: activePlayRunner,
                                          sourceWorldId: selectedWorld.worldId,
                                          sourceLessonId:
                                              selectedLesson.lessonId,
                                          task: playSelectedTask,
                                          option: option,
                                        );
                                        if (!_placementDiagnosticActive) {
                                          _recordAnswer(
                                            selectedLesson,
                                            playSelectedTask,
                                            option,
                                          );
                                        } else {
                                          _recordPlacementDiagnosticMissForRepairV1(
                                            selectedWorld: selectedWorld,
                                            selectedLesson: selectedLesson,
                                            selectedTask: playSelectedTask,
                                            runner: activePlayRunner,
                                            option: option,
                                          );
                                        }
                                        _selectedOptionId = option.id;
                                        _selectedPresetId = null;
                                        _selectedPresetTaskId = null;
                                        _phase = Act0LessonPhaseV1.review;
                                        _teachingStepIndex = 0;
                                        return;
                                      }
                                    }
                                  },
                                ),
                                rapidReviewMode: _rapidPracticeLoop,
                                actionRecommendation:
                                    _actionRecommendationForActiveSequenceV1(),
                                actionPayoff:
                                    _actionPayoffForActiveSequenceV1(),
                                onContinueReview: () => _setStateForRunnerCallbackV1(
                                  callbackEpochV1,
                                  callbackDiagnosticEntryV1,
                                  callbackDiagnosticRunIdV1,
                                  () {
                                    if (_diagnosticLearningEntryV1 != null) {
                                      _returnFromDiagnosticLearningEntryV1();
                                      return;
                                    }
                                    if (openedAsSpacedReview) {
                                      _returnFromSpacedReviewV1(
                                        callbackDiagnosticRunIdV1,
                                      );
                                      return;
                                    }
                                    if (sameSessionLearningDelta != null) {
                                      _emitSameSessionLearningDeltaCompletedV1(
                                        sameSessionLearningDelta,
                                      );
                                    }
                                    _recordActionRecommendationAcceptedV1();
                                    if (_placementDiagnosticActive) {
                                      final spot = _placementDiagnosticSpotsV1
                                          .elementAt(_placementDiagnosticIndex);
                                      if (activePlayRunner
                                              .selectedOption
                                              ?.isCorrect ??
                                          false) {
                                        _placementDiagnosticCorrect += 1;
                                        _placementDiagnosticScore += 1;
                                        _placementDiagnosticHitSignals.add(
                                          spot.signalId,
                                        );
                                      } else {
                                        _placementDiagnosticMissSignals.add(
                                          spot.signalId,
                                        );
                                      }
                                      if (_startNextPlacementDiagnostic(
                                        _progressWorlds(baseState),
                                      )) {
                                        return;
                                      }
                                      _placementResult =
                                          _buildPlacementResult();
                                      _seedProfileSkillStats(
                                        _placementResult!.skillStats,
                                      );
                                      _endPlacementAssessmentRunV1();
                                      _placementDiagnosticActive = false;
                                      _showPlacement = true;
                                      _showPlayHub = true;
                                      _selectedOptionId = null;
                                      _phase = Act0LessonPhaseV1.theory;
                                      _teachingStepIndex = 0;
                                      return;
                                    }
                                    if (_advanceActionSequenceReviewV1(
                                      selectedWorld: selectedWorld,
                                      selectedTask: playSelectedTask,
                                      runner: playRunner!,
                                    )) {
                                      return;
                                    }
                                    if (_completeSameSignalRecheckV1(
                                      selectedWorld: selectedWorld,
                                      selectedLesson: selectedLesson,
                                      selectedTask: playSelectedTask,
                                      runner: playRunner,
                                    )) {
                                      return;
                                    }
                                    if (_activeRepairTaskId ==
                                        playSelectedTask.taskId) {
                                      final repaired =
                                          act0IndependentRepairProofV1(
                                            isCorrect:
                                                playRunner
                                                    .selectedOption
                                                    ?.isCorrect ??
                                                false,
                                            assistanceKind: _choiceAssistanceV1,
                                          );
                                      final repairSourceTaskId =
                                          _activeRepairSourceTaskId ??
                                          playSelectedTask.taskId;
                                      final repairSourceRecord =
                                          _mistakeRecords[repairSourceTaskId];
                                      // Practice Queue owns independent
                                      // answer telemetry at decision time.
                                      // Assisted answers bypass that owner, so
                                      // keep the truthful non-success event here.
                                      if (!_isPracticeQueueRepairAnswerV1(
                                            playSelectedTask,
                                          ) ||
                                          _choiceWasAssistedV1) {
                                        _emitRepairCompletedTelemetryV1(
                                          sourceTaskId: repairSourceTaskId,
                                          repairTaskId: playSelectedTask.taskId,
                                          repaired: repaired,
                                        );
                                      }
                                      _emitRepairItemCompletedTelemetryV1(
                                        sourceTaskId: repairSourceTaskId,
                                        targetTaskId: playSelectedTask.taskId,
                                        repaired: repaired,
                                        record: repairSourceRecord,
                                      );
                                      // Practice Queue closure is owned by its
                                      // exact queue outcome; inline recheck is
                                      // reserved for the same-signal feedback path.
                                      final startsSourceRecheck =
                                          _activeSameSignalFeedbackRepairV1;
                                      if (repaired) {
                                        _clearMatchedOpenRepairIntentV1(
                                          sourceTaskId: repairSourceTaskId,
                                          completedTaskId:
                                              playSelectedTask.taskId,
                                        );
                                        _clearOpenRepairIntentsForCompletedTaskV1(
                                          completedTaskId:
                                              playSelectedTask.taskId,
                                        );
                                        // A directed repair can rehearse a locked
                                        // curriculum task. Its independent proof
                                        // closes the repair, but cannot grant the
                                        // future lesson's completion or normal XP.
                                        final curriculumWorld = _worldById(
                                          _progressedWorlds(
                                            widget.state ??
                                                Act0ShellStateV1.sample,
                                          ),
                                          _selectedWorldId,
                                        );
                                        final curriculumLesson = _lessonById(
                                          curriculumWorld.lessons,
                                          _selectedLessonId,
                                        );
                                        if (curriculumWorld.isSelectable &&
                                            curriculumLesson.isSelectable &&
                                            _taskAvailable(
                                              curriculumLesson,
                                              playSelectedTask.taskId,
                                            )) {
                                          _completeCurrentTask(
                                            playSelectedTask,
                                          );
                                        } else {
                                          _refreshRetentionMemoryStatusesV1();
                                          _persistProgress();
                                        }
                                        if (startsSourceRecheck &&
                                            _startSameSignalRecheckV1(
                                              selectedWorld: selectedWorld,
                                              sourceTaskId: repairSourceTaskId,
                                            )) {
                                          _clearActiveRepairLaunchV1();
                                          _activeRepairSourceTaskId = null;
                                          _activeSameSignalFeedbackRepairV1 =
                                              false;
                                          _pendingFeedbackRepairSourceTaskIdV1 =
                                              null;
                                          _pendingFeedbackRepairTaskIdV1 = null;
                                          _activeRepairResultReceiptLine = null;
                                          _activeRepairSessionSummaryLines =
                                              const <String>[];
                                          _selectedOptionId = null;
                                          _phase = Act0LessonPhaseV1.drill;
                                          // Preserve the source recheck launcher's skipTeaching sentinel.
                                          _rapidPracticeLoop = false;
                                          return;
                                        }
                                      }
                                      _tab = Act0ShellTabV1.review;
                                      _showPlayHub = true;
                                      _returnToPlayHubOnBack = false;
                                      _clearActiveRepairLaunchV1();
                                      _activeRepairSourceTaskId = null;
                                      _activeSameSignalFeedbackRepairV1 = false;
                                      _pendingFeedbackRepairSourceTaskIdV1 =
                                          null;
                                      _pendingFeedbackRepairTaskIdV1 = null;
                                      _activeRepairResultReceiptLine = null;
                                      _activeRepairSessionSummaryLines =
                                          const <String>[];
                                      _selectedOptionId = null;
                                      _phase = Act0LessonPhaseV1.theory;
                                      _teachingStepIndex = 0;
                                      _rapidPracticeLoop = false;
                                      return;
                                    }
                                    if (_rapidPracticeLoop &&
                                        _activePracticeGroupId == 'daily') {
                                      _completeCurrentTask(playSelectedTask);
                                      if (_launchDailyPracticeQueueTaskV1())
                                        return;
                                      _syncPracticeReminderV1();
                                      if (_dailyPracticeQueue.taskIds.isEmpty) {
                                        _showPlayHub = true;
                                        _rapidPracticeLoop = false;
                                        _activePracticeGroupId = null;
                                        _selectedOptionId = null;
                                        _persistProgress();
                                        return;
                                      }
                                      _finishRapidPracticeLoopToHub(
                                        completedLessonId:
                                            selectedLesson.lessonId,
                                        completedRepCount: _dailyPracticeQueue
                                            .answeredTaskIds
                                            .length,
                                        cleanRepCount: _dailyPracticeQueue
                                            .cleanTaskIds
                                            .length,
                                        resultSummary:
                                            _dailyPracticeQueue
                                                    .cleanTaskIds
                                                    .length ==
                                                _dailyPracticeQueue
                                                    .answeredTaskIds
                                                    .length
                                            ? 'daily_clean_set_complete'
                                            : 'daily_set_complete',
                                      );
                                      return;
                                    }
                                    if (_rapidPracticeLoop) {
                                      _completeCurrentTask(playSelectedTask);
                                      final singleCleanRep =
                                          (playRunner
                                                  .selectedOption
                                                  ?.isCorrect ??
                                              false) &&
                                          _choiceHasIndependentProvenanceV1;
                                      _finishRapidPracticeLoopToHub(
                                        completedLessonId:
                                            selectedLesson.lessonId,
                                        completedRepCount: 1,
                                        cleanRepCount: singleCleanRep ? 1 : 0,
                                        resultSummary: singleCleanRep
                                            ? 'single_clean_rep_complete'
                                            : 'single_rep_complete',
                                      );
                                      return;
                                    }
                                    if (_activeLessonWrapUpTaskId ==
                                        playSelectedTask.taskId) {
                                      final wrappedCorrect =
                                          playRunner
                                              .selectedOption
                                              ?.isCorrect ??
                                          false;
                                      if (wrappedCorrect) {
                                        _completeCurrentTask(playSelectedTask);
                                      }
                                      _lessonRunWrapUpCompletedTaskIds.add(
                                        playSelectedTask.taskId,
                                      );
                                      _activeLessonWrapUpTaskId = null;
                                      _selectedOptionId = null;
                                      _phase = Act0LessonPhaseV1.theory;
                                      _teachingStepIndex = 0;
                                      if (_maybeStartLessonWrapUpRetry(
                                        selectedLesson,
                                      )) {
                                        return;
                                      }
                                      _restoreWrapUpAnchorTaskId(
                                        selectedLesson,
                                      );
                                      if (_maybeShowBlockCompletionSummary(
                                        selectedWorld: selectedWorld,
                                        selectedLesson: selectedLesson,
                                        selectedTask: playSelectedTask,
                                      )) {
                                        return;
                                      }
                                      _advanceAfterTask(
                                        selectedWorld,
                                        selectedLesson,
                                      );
                                      return;
                                    }
                                    if (_startSameSignalRepairFromFeedbackV1(
                                      selectedWorld: selectedWorld,
                                      selectedTask: playSelectedTask,
                                      runner: playRunner,
                                    )) {
                                      return;
                                    }
                                    if (_shouldRetryInsideLesson(
                                      playSelectedTask,
                                      playRunner,
                                    )) {
                                      _placementHandoffActive = false;
                                      _startInsideLessonRetry(
                                        playSelectedTask,
                                        playRunner,
                                      );
                                      return;
                                    }
                                    _placementHandoffActive = false;
                                    _completeCurrentTask(playSelectedTask);
                                    if (_maybeStartLessonWrapUpRetry(
                                      selectedLesson,
                                    )) {
                                      return;
                                    }
                                    if (_maybeShowBlockCompletionSummary(
                                      selectedWorld: selectedWorld,
                                      selectedLesson: selectedLesson,
                                      selectedTask: playSelectedTask,
                                    )) {
                                      _selectedOptionId = null;
                                      _teachingStepIndex = 0;
                                      return;
                                    }
                                    _advanceAfterTask(
                                      selectedWorld,
                                      selectedLesson,
                                    );
                                    _selectedOptionId = null;
                                    _teachingStepIndex = 0;
                                  },
                                ),
                              ),
                      Act0ShellTabV1.review => act0AcademyReviewRuntimeV1(
                        context,
                        isCurrent: () =>
                            _acceptRecoveryCallbackV1(callbackEpochV1),
                        legacy: Act0ReviewShellV1(
                          review: reviewState,
                          selected: _reviewConfidence,
                          onSelected: (value) => setState(() {
                            _reviewConfidence = value;
                          }),
                          repeatedMistake: _repeatedMistakeForReviewV1(
                            reviewState,
                            reviewCoaching,
                          ),
                          onFixMistake: (mistake) => setState(() {
                            _startMistakeRepair(
                              selectedWorld,
                              mistake,
                              returnToPlayHub: false,
                            );
                          }),
                          onReplayFixedMistake: (mistake) => setState(() {
                            _startMistakeRepair(
                              selectedWorld,
                              mistake,
                              returnToPlayHub: false,
                              practiceGroupId: 'weak_spots',
                              familiarReplayOnly: true,
                            );
                          }),
                          sessionDrillRecheckQueueItems:
                              _suppressLegacyRecheckAfterRecoveryV1
                              ? const []
                              : _sessionDrillRecheckQueueItemsV1,
                          mistakeHistoryItems:
                              Act0ReviewMistakeHistoryConsumerV1.fromHistory(
                                _reviewMistakeHistoryV1,
                                sourceState: state,
                                localeIsRu:
                                    act0AcademyLanguageV1(context) == 'ru',
                                localizeOptionLabel: (label) =>
                                    act0AcademyW1OptionLabelV1(
                                      context,
                                      act0RuntimeLocalizedOptionLabelV1(
                                        context,
                                        label,
                                      ),
                                    ),
                                activeRepairSourceTaskIds: <String>{
                                  for (final mistake in reviewState.mistakes)
                                    mistake.taskId,
                                },
                                reviewResolutionState:
                                    _reviewResolutionStateV1(),
                                patternCoachingProjection: reviewCoaching,
                              ).items,
                          dueReviewItems: _dueReviewItemsV1(),
                          nextStep: personalizedNextStep,
                          onOpenRecommendedAction: () => setState(() {
                            _openPersonalizedNextStepV1(
                              personalizedNextStep,
                              surface: 'review',
                              selectedWorld: selectedWorld,
                              reviewState: reviewState,
                            );
                          }),
                          onStartDueReview: (item) {
                            if (!_acceptRecoveryCallbackV1(callbackEpochV1))
                              return;
                            setState(() => _startDueReviewItemV1(item));
                          },
                          onStartSessionDrillRecheck: (item) {
                            if (!_acceptRecoveryCallbackV1(callbackEpochV1))
                              return;

                            if (_suppressLegacyRecheckAfterRecoveryV1) return;
                            unawaited(
                              pushSessionDrillRecheckLaunchV1(context, item),
                            );
                          },
                          onOpenLearn: () => setState(() {
                            _restoreSelectableLearnFocusV1();
                            _tab = Act0ShellTabV1.learn;
                          }),
                        ),
                      ),
                      Act0ShellTabV1.profile => act0AcademyYouRuntimeV1(
                        context,
                        passedW1RulesCheck:
                            _w1RulesBestScoreV1 >=
                            Act0W1RulesResultV1.passingScore,
                        betaLearningMetrics:
                            widget.enableBetaMetrics && _usesPersistedProgress
                            ? () => Act0BetaLearningMetricsV1.fromProgress(
                                firstWorld: baseState.worldById('world_1'),
                                completedTaskIds: _completedTaskIds,
                                correctedMistakes:
                                    _fixProofProjectionV1().proofs.length,
                              )
                            : null,
                        nowUtc: widget.clock.nowUtc,
                        onDeleteLocalData: _usesPersistedProgress
                            ? _requestDeleteLocalDataV1
                            : null,
                        skills: act0W14SkillStatesV1(
                          worlds: state.worlds,
                          history: _learningEvidenceHistoryV1,
                        ),
                        isCurrent: () =>
                            _acceptRecoveryCallbackV1(callbackEpochV1),
                        completedTasks: _completedTaskIds.length,
                        practiceDaysLastWeek: _practiceDaysLastWeekV1(
                          profileState,
                        ),
                        openRepairs: reviewState.mistakes.length,
                        dueReviews: _dueReviewItemsV1().length,
                        earnedProjection:
                            Act0AchievementSeedProjectionV1.fromSources(
                              learningEvidenceHistory:
                                  _learningEvidenceHistoryV1,
                              repairIntents: _activeRepairIntentsV1(),
                              reviewMistakeHistory: _reviewMistakeHistoryV1,
                              profileEvidenceProjection:
                                  currentProfileEvidenceProjection,
                              profileStreakDays: profileState.streakDays,
                            ),
                        onOpenReview: () =>
                            setState(() => _tab = Act0ShellTabV1.review),
                        onOpenLearn: () => setState(() {
                          _restoreSelectableLearnFocusV1();
                          _tab = Act0ShellTabV1.learn;
                        }),
                        legacy: Act0ProfileShellV1(
                          profile: profileState,
                          crossSessionProof:
                              Act0CrossSessionProfileProofV1.fromFixProof(
                                _fixProofProjectionV1(),
                              ),
                          learningRecord: currentProfileEvidenceProjection,
                          onOpenPractice: () {
                            if (_acceptRecoveryCallbackV1(callbackEpochV1)) {
                              setState(_openPracticeHubV1);
                            }
                          },
                          evidenceSignal:
                              Act0ProfileEvidenceConsumerV1.fromProjection(
                                currentProfileEvidenceProjection,
                              ).signal,
                          achievementSeedConsumer:
                              Act0AchievementSeedConsumerV1.fromProjection(
                                Act0AchievementSeedProjectionV1.fromSources(
                                  learningEvidenceHistory:
                                      _learningEvidenceHistoryV1,
                                  repairIntents: _activeRepairIntentsV1(),
                                  reviewMistakeHistory: _reviewMistakeHistoryV1,
                                  profileEvidenceProjection:
                                      currentProfileEvidenceProjection,
                                  profileStreakDays: profileState.streakDays,
                                ),
                              ),
                          onRecoveryOptions: _usesPersistedProgress
                              ? _openRecoveryOptionsV1
                              : null,
                          onRetakePlacement:
                              kDebugMode && widget.debugLegacyPlacementOnStart
                              ? _openPlacementFlow
                              : _canTakeW1RulesCheckV1
                              ? _beginW1RulesCheckV1
                              : null,
                          onReplayWelcome:
                              kDebugMode && widget.debugLegacyPlacementOnStart
                              ? _openWelcomeReplayV1
                              : null,
                          onGoToHome: () =>
                              setState(() => _tab = Act0ShellTabV1.home),
                        ),
                      ),
                    },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          !_bootSurfaceReady ||
              _showWelcome ||
              (_showPlacement && !_placementDiagnosticActive) ||
              (_tab == Act0ShellTabV1.play && !_showPlayHub)
          ? null
          : _BottomNavV1(
              current: _tab,
              premium: premiumAcademy,
              academy: academySurface,
              reviewHasDot: reviewNavHasDot,
              onSelected: (tab) => setState(() {
                if (_diagnosticLearningEntryV1 != null) {
                  _returnFromDiagnosticLearningEntryV1();
                }
                final preserveRepairBridge =
                    _shouldPreserveLearningRunForRepairBridgeV1(
                      currentTab: _tab,
                      requestedTab: tab,
                    );
                final leavingLearningRunSurface =
                    (_tab == Act0ShellTabV1.learn &&
                        tab != Act0ShellTabV1.learn) ||
                    (_tab == Act0ShellTabV1.play &&
                        _showPlayHub &&
                        tab != Act0ShellTabV1.play);
                if (leavingLearningRunSurface && !preserveRepairBridge) {
                  _closeLearningRunForLearnExitV1();
                }
                _tab = tab;
                if (tab == Act0ShellTabV1.play) {
                  _showPlayHub = true;
                  _blockCompletionSummary = null;
                  _placementHandoffActive = false;
                }
                if (tab != Act0ShellTabV1.play) {
                  _practiceCompletionTitle = null;
                  _practiceCompletionBody = null;
                  _phase = Act0LessonPhaseV1.theory;
                  _selectedOptionId = null;
                  _teachingStepIndex = 0;
                  _blockCompletionSummary = null;
                  _showPlayHub = true;
                  _clearActiveRepairLaunchV1();
                  _activeRepairSourceTaskId = null;
                  _activeRepairResultReceiptLine = null;
                  _activeRepairSessionSummaryLines = const <String>[];
                }
                if (tab != Act0ShellTabV1.home) {
                  _placementHandoffActive = false;
                }
                if (tab == Act0ShellTabV1.learn) {
                  _activateLearnVisitEligibilityV1();
                  _restoreSelectableLearnFocusV1();
                }
                if (tab == Act0ShellTabV1.home && !selectedWorld.isSelectable) {
                  _restoreSelectableLearnFocusV1();
                }
                if (tab != Act0ShellTabV1.learn) {
                  _learnDetailLessonId = null;
                  _learnDetailWorldId = null;
                  _showWorldMenu = false;
                }
              }),
            ),
    );
    // The task UI scales up to 1.3. Physical table labels keep their own
    // fixed text scale inside the runner.
    if (academySurface) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: premiumAcademy || _showWelcome || _showPlacement
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: shell,
      );
    }
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.3,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: shell,
      ),
    );
  }

  @visibleForTesting
  Map<String, String> debugSummaryHomeHandoffPayloadV1() {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final world = _worldById(_progressedWorlds(state), _selectedWorldId);
    return _summaryHomeHandoffV1(world).toPayload();
  }

  void _openPersonalizedNextStepV1(
    Act0PersonalizedReturnReasonV1 nextStep, {
    required String surface,
    required Act0WorldCardV1 selectedWorld,
    required Act0ReviewStateV1 reviewState,
  }) {
    final truthful = _personalizedNextStepV1(reviewState);
    if (truthful.reasonType == act0ReturnReasonNoPersonalReasonAvailableV1 &&
        surface == 'home') {
      _startHomeNextAction(selectedWorld);
      return;
    }
    final due = _launchableDueReviewV1(truthful);
    if (due != null) {
      _recordPersonalizedNextStepOpenedV1(truthful, surface);
      _startDueReviewItemV1(due);
      return;
    }
    if (truthful.recommendedAction == 'repair' ||
        truthful.recommendedAction == 'retry_repair') {
      final mistake = reviewState.mistakes
          .cast<Act0MistakeCardV1?>()
          .firstWhere(
            (item) => item?.taskId == truthful.sourceTaskId,
            orElse: () => null,
          );
      if (mistake != null) {
        _recordPersonalizedNextStepOpenedV1(truthful, surface);
        _startMistakeRepair(selectedWorld, mistake, returnToPlayHub: false);
        return;
      }
    }
    if (truthful.reasonType != act0ReturnReasonNoPersonalReasonAvailableV1) {
      _recordPersonalizedNextStepOpenedV1(truthful, surface);
    }
    if (surface == 'home') {
      _startHomeNextAction(selectedWorld);
      return;
    }
    _restoreSelectableLearnFocusV1();
    _tab = Act0ShellTabV1.learn;
  }

  void _openWelcomeReplayV1() {
    setState(() {
      _welcomeCompletionEpochV1 += 1;
      _welcomeCompletionSavingV1 = false;
      _welcomeReturnTabV1 = _tab;
      _showWelcome = true;
      _showPlacement = false;
      _placementDiagnosticActive = false;
      _placementHandoffActive = false;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _blockCompletionSummary = null;
      _selectedOptionId = null;
      _phase = Act0LessonPhaseV1.theory;
      _teachingStepIndex = 0;
    });
  }

  void _closeWelcomeReplayV1() {
    final returnTab = _welcomeReturnTabV1 ?? Act0ShellTabV1.profile;
    setState(() {
      _welcomeCompletionEpochV1 += 1;
      _welcomeCompletionSavingV1 = false;
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _tab = returnTab;
    });
  }

  /// Action policy chooses its initial next action; the existing shared
  /// repair/recheck owners execute and record the actual canonical tasks.
  bool _advanceActionSequenceReviewV1({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerStateV1 runner,
  }) {
    final sequence = act0ActionLearningSequenceForTaskV1(selectedTask.taskId);
    if (sequence == null ||
        selectedTask.taskId != sequence.practiceTaskId ||
        _activeRepairTaskId != null ||
        _activeSameSignalRecheckTaskId != null) {
      return false;
    }
    final stage =
        _activeActionSequenceStageV1 ?? Act0ActionSequenceStageV1.decision;
    final correct = runner.selectedOption?.isCorrect ?? false;
    if (stage == Act0ActionSequenceStageV1.decision && !correct) {
      if (!_startSameSignalRepairFromFeedbackV1(
        selectedWorld: selectedWorld,
        selectedTask: selectedTask,
        runner: runner,
      ))
        return false;
      _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.repair;
      _recordTelemetryEventV1('action_sequence_repair_entry', <String, Object?>{
        'schemaVersion': 1,
        'sequenceId': sequence.sequenceId,
        'sourceTaskId': selectedTask.taskId,
        'errorType': sequence.repairErrorType,
        'repairTaskId': _activeRepairTaskId,
      });
      return true;
    }
    if (stage == Act0ActionSequenceStageV1.decision && correct) {
      _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.complete;
      _recordTelemetryEventV1('action_sequence_completed', <String, Object?>{
        'schemaVersion': 1,
        'sequenceId': sequence.sequenceId,
        'completionTaskId': selectedTask.taskId,
      });
    }
    return false;
  }
}

class _Act0ProgressSnapshotV1 {
  const _Act0ProgressSnapshotV1({required this.level, required this.xp});

  final int level;
  final int xp;
}

class _Act0FirstValueReceiptCarryV1 {
  const _Act0FirstValueReceiptCarryV1({
    required this.skillReceiptId,
    required this.skillAtomId,
    required this.skillLabel,
    required this.sourceSignalId,
    required this.sourceSignalLabel,
    required this.outcomeId,
    required this.nextRepId,
    required this.nextRepLabel,
    required this.sourceWorldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
  });

  final String skillReceiptId;
  final String skillAtomId;
  final String skillLabel;
  final String sourceSignalId;
  final String sourceSignalLabel;
  final String outcomeId;
  final String nextRepId;
  final String nextRepLabel;
  final String sourceWorldId;
  final String sourceLessonId;
  final String sourceTaskId;

  bool get isRepair =>
      outcomeId == 'repair_started' || outcomeId == 'needs_rep';

  String get focusTitle => 'Focus: $skillLabel';

  String get homeTitle =>
      isRepair ? 'Repair: $skillLabel' : 'Next: one more $_repSkillLabel rep';

  String get homeSubtitle => isRepair
      ? 'The $sourceSignalLabel clue is waiting. One repair rep makes it easier next time.'
      : 'You started with $sourceSignalLabel. One more rep makes it stick.';

  String get _repSkillLabel =>
      skillLabel.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  Map<String, Object> toJson() {
    return <String, Object>{
      'skillReceiptId': skillReceiptId,
      'skillAtomId': skillAtomId,
      'skillLabel': skillLabel,
      'sourceSignalId': sourceSignalId,
      'sourceSignalLabel': sourceSignalLabel,
      'outcomeId': outcomeId,
      'nextRepId': nextRepId,
      'nextRepLabel': nextRepLabel,
      'sourceWorldId': sourceWorldId,
      'sourceLessonId': sourceLessonId,
      'sourceTaskId': sourceTaskId,
    };
  }

  static _Act0FirstValueReceiptCarryV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    final skillReceiptId = (map['skillReceiptId'] ?? '').toString();
    final skillAtomId = (map['skillAtomId'] ?? '').toString();
    final skillLabel = (map['skillLabel'] ?? '').toString();
    final sourceSignalId = (map['sourceSignalId'] ?? '').toString();
    final sourceSignalLabel = (map['sourceSignalLabel'] ?? '').toString();
    final outcomeId = (map['outcomeId'] ?? '').toString();
    final nextRepId = (map['nextRepId'] ?? '').toString();
    final nextRepLabel = (map['nextRepLabel'] ?? '').toString();
    final sourceWorldId = (map['sourceWorldId'] ?? '').toString();
    final sourceLessonId = (map['sourceLessonId'] ?? '').toString();
    final sourceTaskId = (map['sourceTaskId'] ?? '').toString();
    if (skillReceiptId.isEmpty ||
        skillAtomId.isEmpty ||
        skillLabel.isEmpty ||
        sourceSignalId.isEmpty ||
        sourceSignalLabel.isEmpty ||
        outcomeId.isEmpty ||
        nextRepId.isEmpty ||
        sourceWorldId.isEmpty ||
        sourceLessonId.isEmpty ||
        sourceTaskId.isEmpty) {
      return null;
    }
    return _Act0FirstValueReceiptCarryV1(
      skillReceiptId: skillReceiptId,
      skillAtomId: skillAtomId,
      skillLabel: skillLabel,
      sourceSignalId: sourceSignalId,
      sourceSignalLabel: sourceSignalLabel,
      outcomeId: outcomeId,
      nextRepId: nextRepId,
      nextRepLabel: nextRepLabel,
      sourceWorldId: sourceWorldId,
      sourceLessonId: sourceLessonId,
      sourceTaskId: sourceTaskId,
    );
  }
}

class _Act0FirstValueDailyRepTargetV1 {
  const _Act0FirstValueDailyRepTargetV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.mappingType,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final String mappingType;
}

class _Act0OpenRepairIntentTargetV1 {
  const _Act0OpenRepairIntentTargetV1({
    required this.intent,
    required this.target,
  });

  final Act0RepairIntentV1 intent;
  final _Act0FirstValueDailyRepTargetV1 target;
}

class _Act0NextUsefulHandReasonReceiptV1 {
  const _Act0NextUsefulHandReasonReceiptV1({
    required this.source,
    required this.selectionSource,
    required this.sourceTaskId,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.missedSignalId,
    required this.missedSignalLabel,
    required this.skillAtomId,
    required this.skillLabel,
    required this.mappingType,
    required this.reasonCode,
    required this.practiceGroupId,
    required this.repairDecision,
  });

  factory _Act0NextUsefulHandReasonReceiptV1.forRepairIntent({
    required String sourceTaskId,
    required _Act0OpenRepairIntentTargetV1 target,
    String? practiceGroupId,
    int repeatedMissCount = 1,
  }) {
    final isExactReplay = act0IsExactRepairMappingTypeV1(
      target.target.mappingType,
    );
    final reasonCode = isExactReplay
        ? 'exact_replay_${target.intent.skillAtomId}_${target.intent.missedSignalId}'
        : target.intent.reasonCode;
    final repairDecision = buildAct0RuleBasedRepairDecisionV1(
      openRepairIntent: target.intent,
      isOpen: true,
      repeatedMissCount: repeatedMissCount,
      resolvedTargetWorldId: target.target.worldId,
      resolvedTargetLessonId: target.target.lessonId,
      resolvedTargetTaskId: target.target.taskId,
      resolvedMappingType: target.target.mappingType,
      resolvedReasonCode: reasonCode,
    );
    return _Act0NextUsefulHandReasonReceiptV1(
      source: 'repair_intent',
      selectionSource: isExactReplay
          ? 'repair_intent_exact_replay'
          : 'repair_intent_mapped',
      sourceTaskId: sourceTaskId,
      targetWorldId: target.target.worldId,
      targetLessonId: target.target.lessonId,
      targetTaskId: target.target.taskId,
      missedSignalId: target.intent.missedSignalId,
      missedSignalLabel: target.intent.missedSignalLabel,
      skillAtomId: target.intent.skillAtomId,
      skillLabel: target.intent.skillLabel,
      mappingType: target.target.mappingType,
      reasonCode: reasonCode,
      practiceGroupId: practiceGroupId,
      repairDecision: repairDecision,
    );
  }

  factory _Act0NextUsefulHandReasonReceiptV1.existingFallback({
    required String sourceTaskId,
    required String targetWorldId,
    required String targetLessonId,
    required String targetTaskId,
    String? practiceGroupId,
  }) {
    return _Act0NextUsefulHandReasonReceiptV1(
      source: 'recommendation',
      selectionSource: 'existing_fallback',
      sourceTaskId: sourceTaskId,
      targetWorldId: targetWorldId,
      targetLessonId: targetLessonId,
      targetTaskId: targetTaskId,
      missedSignalId: '',
      missedSignalLabel: '',
      skillAtomId: '',
      skillLabel: '',
      mappingType: '',
      reasonCode: '',
      practiceGroupId: practiceGroupId,
      repairDecision: null,
    );
  }

  static const int schemaVersion = 1;
  final String source;
  final String selectionSource;
  final String sourceTaskId;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String missedSignalId;
  final String missedSignalLabel;
  final String skillAtomId;
  final String skillLabel;
  final String mappingType;
  final String reasonCode;
  final String? practiceGroupId;
  final Act0RuleBasedRepairDecisionV1? repairDecision;

  Map<String, Object?> toPayload() {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'source': source,
      'selectionSource': selectionSource,
      'sourceTaskId': sourceTaskId,
      'targetWorldId': targetWorldId,
      'targetLessonId': targetLessonId,
      'targetTaskId': targetTaskId,
      'missedSignalId': missedSignalId,
      'missedSignalLabel': missedSignalLabel,
      'skillAtomId': skillAtomId,
      'skillLabel': skillLabel,
      'mappingType': mappingType,
      'reasonCode': reasonCode,
      'practiceGroupId': practiceGroupId,
      if (repairDecision != null) 'repairDecision': repairDecision!.toPayload(),
    };
  }
}

class _Act0RepairIntentAuditEntryV1 {
  const _Act0RepairIntentAuditEntryV1({
    required this.transition,
    required this.sourceTaskId,
    required this.targetTaskId,
    required this.selectionSource,
    required this.reasonCode,
    required this.mappingType,
  });

  final String transition;
  final String sourceTaskId;
  final String targetTaskId;
  final String selectionSource;
  final String reasonCode;
  final String mappingType;

  bool hasSamePayload(_Act0RepairIntentAuditEntryV1 other) {
    return transition == other.transition &&
        sourceTaskId == other.sourceTaskId &&
        targetTaskId == other.targetTaskId &&
        selectionSource == other.selectionSource &&
        reasonCode == other.reasonCode &&
        mappingType == other.mappingType;
  }

  Map<String, Object?> toPayload() {
    return <String, Object?>{
      'transition': transition,
      'sourceTaskId': sourceTaskId,
      'targetTaskId': targetTaskId,
      'selectionSource': selectionSource,
      'reasonCode': reasonCode,
      'mappingType': mappingType,
    };
  }
}

class _Act0NextUsefulHandCopyBridgeV1 {
  const _Act0NextUsefulHandCopyBridgeV1({
    required this.lineKind,
    required this.safeTemplateId,
    required this.clueKey,
    required this.clueLabel,
    required this.skillKey,
    required this.skillLabel,
    required this.sourceTaskId,
    required this.targetTaskId,
    required this.selectionSource,
    required this.reasonCode,
  });

  factory _Act0NextUsefulHandCopyBridgeV1.fromReceipt(
    _Act0NextUsefulHandReasonReceiptV1 receipt,
  ) {
    final lineKind = switch (receipt.selectionSource) {
      'repair_intent_mapped' => 'missed_clue_repair_same_signal',
      'repair_intent_exact_replay' => 'exact_replay_repair',
      _ => 'existing_fallback',
    };
    final safeTemplateId = switch (lineKind) {
      'missed_clue_repair_same_signal' => 'repair_same_clue_v1',
      'exact_replay_repair' => 'repair_exact_replay_v1',
      _ => 'fallback_next_hand_v1',
    };
    return _Act0NextUsefulHandCopyBridgeV1(
      lineKind: lineKind,
      safeTemplateId: safeTemplateId,
      clueKey: receipt.missedSignalId,
      clueLabel: receipt.missedSignalLabel,
      skillKey: receipt.skillAtomId,
      skillLabel: receipt.skillLabel,
      sourceTaskId: receipt.sourceTaskId,
      targetTaskId: receipt.targetTaskId,
      selectionSource: receipt.selectionSource,
      reasonCode: receipt.reasonCode,
    );
  }

  static const int schemaVersion = 1;
  final String lineKind;
  final String safeTemplateId;
  final String clueKey;
  final String clueLabel;
  final String skillKey;
  final String skillLabel;
  final String sourceTaskId;
  final String targetTaskId;
  final String selectionSource;
  final String reasonCode;

  String get renderedCopyLine {
    return act0RepairIntentCopyGuardLineV1(
          safeTemplateId: safeTemplateId,
          clueLabel: clueLabel,
          skillLabel: skillLabel,
        ) ??
        '';
  }

  Map<String, Object?> toPayload() {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'lineKind': lineKind,
      'safeTemplateId': safeTemplateId,
      'clueKey': clueKey,
      'clueLabel': clueLabel,
      'skillKey': skillKey,
      'skillLabel': skillLabel,
      'sourceTaskId': sourceTaskId,
      'targetTaskId': targetTaskId,
      'selectionSource': selectionSource,
      'reasonCode': reasonCode,
    };
  }

  Map<String, Object?> toReviewSupportCopySnapshotPayload({
    required String renderedLine,
  }) {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'safeTemplateId': safeTemplateId,
      'renderedLine': renderedLine,
      'lineKind': lineKind,
      'selectionSource': selectionSource,
      'sourceTaskId': sourceTaskId,
      'targetTaskId': targetTaskId,
      'reasonCode': reasonCode,
    };
  }
}

class _Act0WorldRetentionSeedResultV1 {
  const _Act0WorldRetentionSeedResultV1({
    this.recheckCount = 0,
    this.proveCount = 0,
    this.changed = false,
  });

  final int recheckCount;
  final int proveCount;
  final bool changed;
}

class _Act0DailyDeckEntryV1 {
  const _Act0DailyDeckEntryV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.isSpaced,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final bool isSpaced;
}

class _Act0PracticeLaunchTargetV1 {
  const _Act0PracticeLaunchTargetV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
}

class _Act0TopicPackSpecV1 {
  const _Act0TopicPackSpecV1({
    required this.groupId,
    required this.lessonId,
    required this.taskId,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.sessionLabel,
    required this.durationLabel,
  });

  final String groupId;
  final String lessonId;
  final String taskId;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final String sessionLabel;
  final String durationLabel;
}

const _taskSkillDeltasV1 = <String, Map<String, int>>{
  'what_poker_is_table_read_transfer': <String, int>{
    'Table sense': 4,
    'Board reading': 1,
  },
  'what_poker_is_table_read_recheck': <String, int>{
    'Table sense': 4,
    'Board reading': 1,
  },
  'cards_ranks_suits_private_board': <String, int>{
    'Board reading': 3,
    'Hand reading': 2,
  },
  'your_first_hand_action_trail': <String, int>{
    'Table sense': 2,
    'Board reading': 2,
    'Betting decisions': 1,
  },
  'actions_legal_context': <String, int>{
    'Betting decisions': 4,
    'Table sense': 1,
  },
  'blinds_first_actor': <String, int>{'Blind play': 4, 'Table sense': 2},
  'positions_early_late': <String, int>{'Position play': 4, 'Table sense': 2},
  'hand_rankings_best_five_drill': <String, int>{
    'Hand reading': 3,
    'Board reading': 2,
  },
  'showdown_best_hand_drill': <String, int>{
    'Hand reading': 3,
    'Board reading': 2,
  },
};

const _topicPackSpecsV1 = <_Act0TopicPackSpecV1>[
  _Act0TopicPackSpecV1(
    groupId: 'actions',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    title: 'Actions',
    subtitle: 'Read the price and choose the legal action fast.',
    categoryLabel: 'Action',
    sessionLabel: 'Action drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'blinds',
    lessonId: 'blinds_action_order',
    taskId: 'blinds_first_actor',
    title: 'Blinds',
    subtitle: 'Track the blinds and who acts first preflop.',
    categoryLabel: 'Preflop',
    sessionLabel: 'Blind drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'positions',
    lessonId: 'positions',
    taskId: 'positions_early_late',
    title: 'Positions',
    subtitle: 'Separate early seats from late seats at a glance.',
    categoryLabel: 'Seats',
    sessionLabel: 'Seat drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'streets',
    lessonId: 'your_first_hand',
    taskId: 'your_first_hand_action_trail',
    title: 'Streets',
    subtitle: 'Follow the hand in order instead of losing the street.',
    categoryLabel: 'Hand flow',
    sessionLabel: 'Street drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'rankings',
    lessonId: 'hand_rankings_upper',
    taskId: 'hand_rankings_best_five_drill',
    title: 'Hand rankings',
    subtitle: 'Choose the best five cards on a real board.',
    categoryLabel: 'Cards',
    sessionLabel: 'Card drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'showdown',
    lessonId: 'showdown_winning',
    taskId: 'showdown_best_hand_drill',
    title: 'Showdown',
    subtitle: 'Compare the final hands and settle the pot cleanly.',
    categoryLabel: 'Winning',
    sessionLabel: 'Finish drill',
    durationLabel: '~2 min',
  ),
];

class _Act0PlacementSkipPlanV1 {
  const _Act0PlacementSkipPlanV1({
    required this.taskIds,
    required this.orderedTaskIds,
  });

  final Set<String> taskIds;
  final List<String> orderedTaskIds;
}

class _Act0SessionTelemetrySinkV1 implements Act0TelemetrySinkV1 {
  const _Act0SessionTelemetrySinkV1(this.delegate, this.sessionId);

  final Act0TelemetrySinkV1 delegate;
  final String Function() sessionId;

  @override
  void record(Act0TelemetryEventV1 event) {
    if (event.fields.containsKey('review_kind')) {
      final fields = Map<String, Object?>.from(event.fields)
        ..remove('review_kind');
      event = Act0TelemetryEventV1(
        name: event.name,
        fields: {
          ...fields,
          'schemaVersion': 2,
          // Route intent is not the accepted completed-evidence classification.
          'route_review_kind': event.fields['review_kind'],
        },
      );
    }
    final id = sessionId().trim();
    if (id.isEmpty ||
        event.fields.containsKey('sessionId') ||
        event.fields.containsKey('session_id') ||
        !_runnerSessionTelemetryEventsV1.contains(event.name)) {
      delegate.record(event);
      return;
    }
    delegate.record(
      Act0TelemetryEventV1(
        name: event.name,
        fields: <String, Object?>{
          ...event.fields,
          'sessionId': id,
          'session_id': id,
        },
      ),
    );
  }
}

const Set<String> _runnerSessionTelemetryEventsV1 = <String>{'decision_made'};

class _Act0PendingDecisionAssistanceV1 {
  const _Act0PendingDecisionAssistanceV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.fingerprint,
    required this.afterSourceOrder,
    required this.kind,
  });
  final String worldId;
  final String lessonId;
  final String taskId;
  final String fingerprint;
  final int afterSourceOrder;
  final Act0DecisionAssistanceV1 kind;
  String get key => jsonEncode([worldId, lessonId, taskId]);
  Map<String, Object> toJson() => {
    'schemaVersion': 1,
    'worldId': worldId,
    'lessonId': lessonId,
    'taskId': taskId,
    'fingerprint': fingerprint,
    'afterSourceOrder': afterSourceOrder,
    'assistanceKind': kind.name,
  };
  static _Act0PendingDecisionAssistanceV1? tryParse(Object? raw) {
    if (raw is! Map ||
        raw['schemaVersion'] != 1 ||
        raw['worldId'] is! String ||
        (raw['worldId'] as String).isEmpty ||
        raw['lessonId'] is! String ||
        (raw['lessonId'] as String).isEmpty ||
        raw['taskId'] is! String ||
        (raw['taskId'] as String).isEmpty ||
        raw['fingerprint'] is! String ||
        raw['afterSourceOrder'] is! int ||
        (raw['afterSourceOrder'] as int) < 0)
      return null;
    final kind = switch (raw['assistanceKind']) {
      'quickHint' => Act0DecisionAssistanceV1.quickHint,
      'theoryRecall' => Act0DecisionAssistanceV1.theoryRecall,
      'legacyUnknown' => Act0DecisionAssistanceV1.legacyUnknown,
      _ => null,
    };
    if (kind == null) return null;
    return _Act0PendingDecisionAssistanceV1(
      worldId: raw['worldId'] as String,
      lessonId: raw['lessonId'] as String,
      taskId: raw['taskId'] as String,
      fingerprint: raw['fingerprint'] as String,
      afterSourceOrder: raw['afterSourceOrder'] as int,
      kind: kind,
    );
  }
}

class _Act0PersistedProgressV1 {
  const _Act0PersistedProgressV1({
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.completedLessonIds,
    required this.selectedWorldId,
    required this.selectedLessonId,
    required this.selectedTaskId,
    required this.earnedXp,
    this.schemaVersion = 20,
    this.w1StartChosen = false,
    this.w1RulesBestScore = 0,
    this.w1RulesFocusTaskIds = const {},
    this.suppressLegacyRecheckAfterRecovery = false,
    this.profileSkillValues = const <String, int>{},
    this.recentSkillGains = const <Act0SkillGainV1>[],
    this.lastActiveDay = '',
    this.lastEarnedDailyDay = '',
    this.hasEarnedDailyDayField = false,
    this.dailyCompletedRepCount = 0,
    this.dailyPracticeQueue = const Act0DailyPracticeQueueV1(),
    this.dailyCompletedTaskIds = const {},
    this.persistedStreakDays = 0,
    this.retentionSequence = 0,
    this.retentionMemory = const <_Act0RetentionMemoryEntryV1>[],
    this.openRepairIntents = const <Act0RepairIntentV1>[],
    this.multiRepairQueue = const Act0MultiRepairQueueV1(),
    this.multiRepairQueueOrder = 0,
    this.resumeInRunner = false,
    this.resumePhase = '',
    this.resumeTeachingStepIndex = 0,
    this.resumeSelectedOptionId,
    this.dismissedHomeHandoffKey = '',
    this.dismissedHomeHandoffDay = '',
    this.firstValueReturnCarry,
    this.learningEvidenceHistory = const Act0LearningEvidenceHistoryV1(),
    this.studyObservations = const [],
    this.practiceDayKeys,
    this.pendingDecisionAssistance = const [],
    this.hasPendingAssistanceProvenance = true,
    this.lessonRunEvidenceBoundaries = const <String, int?>{},
    this.durableRetentionHistory = const Act0DurableRetentionHistoryV1(),
    this.openedSpacedReviewTaskIds = const {},
    this.reviewMistakeHistory = const Act0ReviewMistakeHistoryV1(),
    this.reviewResolutionReceiptHistory =
        const Act0ReviewResolutionReceiptHistoryV1(),
    this.conceptFamilyStateHistory = const Act0ConceptFamilyStateHistoryV1(),
    this.sessionIdentityState = const Act0SessionIdentityStateV1(),
    this.repairOutcomeProjection = const Act0RepairOutcomeProjectionV1(),
    this.lastSessionLearnerState,
  });

  final int schemaVersion;
  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> completedLessonIds;
  final String selectedWorldId;
  final String selectedLessonId;
  final String selectedTaskId;
  final int earnedXp;
  final bool w1StartChosen;
  final int w1RulesBestScore;
  final Set<String> w1RulesFocusTaskIds;
  final bool suppressLegacyRecheckAfterRecovery;
  final Map<String, int> profileSkillValues;
  final List<Act0SkillGainV1> recentSkillGains;
  final String lastActiveDay;
  final String lastEarnedDailyDay;
  // Whether the incoming stored payload carried the new provenance key.
  final bool hasEarnedDailyDayField;
  final int dailyCompletedRepCount;
  final Act0DailyPracticeQueueV1 dailyPracticeQueue;
  final Set<String> dailyCompletedTaskIds;
  final int persistedStreakDays;
  final int retentionSequence;
  final List<_Act0RetentionMemoryEntryV1> retentionMemory;
  final List<Act0RepairIntentV1> openRepairIntents;
  final Act0MultiRepairQueueV1 multiRepairQueue;
  final int multiRepairQueueOrder;
  final bool resumeInRunner;
  final String resumePhase;
  final int resumeTeachingStepIndex;
  final String? resumeSelectedOptionId;
  final String dismissedHomeHandoffKey;
  final String dismissedHomeHandoffDay;
  final _Act0FirstValueReceiptCarryV1? firstValueReturnCarry;
  final Act0LearningEvidenceHistoryV1 learningEvidenceHistory;
  final List<Act0StudyObservationV1> studyObservations;
  final List<String>? practiceDayKeys;
  final List<_Act0PendingDecisionAssistanceV1> pendingDecisionAssistance;
  final bool hasPendingAssistanceProvenance;
  final Map<String, int?> lessonRunEvidenceBoundaries;
  final Act0DurableRetentionHistoryV1 durableRetentionHistory;
  final Set<String> openedSpacedReviewTaskIds;
  final Act0ReviewMistakeHistoryV1 reviewMistakeHistory;
  final Act0ReviewResolutionReceiptHistoryV1 reviewResolutionReceiptHistory;
  final Act0ConceptFamilyStateHistoryV1 conceptFamilyStateHistory;
  final Act0SessionIdentityStateV1 sessionIdentityState;
  final Act0RepairOutcomeProjectionV1 repairOutcomeProjection;
  final Act0LastSessionLearnerStateV1? lastSessionLearnerState;

  String toStorageString() {
    final sortedTaskIds = completedTaskIds.toList(growable: false)..sort();
    final sortedSkippedTaskIds = skippedTaskIds.toList(growable: false)..sort();
    final sortedLessonIds = completedLessonIds.toList(growable: false)..sort();
    final sortedSkillKeys = profileSkillValues.keys.toList(growable: false)
      ..sort();
    final sortedRetentionMemory = retentionMemory.toList(growable: false)
      ..sort((a, b) => a.taskId.compareTo(b.taskId));
    final sortedOpenRepairIntents = openRepairIntents.toList(growable: false)
      ..sort((a, b) => a.sourceTaskId.compareTo(b.sourceTaskId));
    return jsonEncode(<String, Object>{
      'schemaVersion': 20,
      if (suppressLegacyRecheckAfterRecovery)
        'suppressLegacyRecheckAfterRecovery': true,
      'completedTaskIds': sortedTaskIds,
      if (openedSpacedReviewTaskIds.isNotEmpty)
        'openedSpacedReviewTaskIds': openedSpacedReviewTaskIds.toList()..sort(),
      'skippedTaskIds': sortedSkippedTaskIds,
      'completedLessonIds': sortedLessonIds,
      'selectedWorldId': selectedWorldId,
      'selectedLessonId': selectedLessonId,
      'selectedTaskId': selectedTaskId,
      'earnedXp': earnedXp,
      if (w1StartChosen) 'w1StartChosen': true,
      if (w1RulesBestScore > 0) 'w1RulesBestScore': w1RulesBestScore,
      if (w1RulesFocusTaskIds.isNotEmpty)
        'w1RulesFocusTaskIds': w1RulesFocusTaskIds.toList(),
      'profileSkillValues': <String, int>{
        for (final key in sortedSkillKeys) key: profileSkillValues[key]!,
      },
      'recentSkillGains': <Map<String, Object>>[
        for (final gain in recentSkillGains.take(6))
          <String, Object>{
            'label': gain.label,
            'gain': gain.gain,
            'source': gain.source,
          },
      ],
      'lastActiveDay': lastActiveDay,
      'lastEarnedDailyDay': lastEarnedDailyDay,
      'dailyCompletedRepCount': dailyCompletedRepCount,
      'dailyPracticeQueue': dailyPracticeQueue.toPayload(),
      'dailyCompletedTaskIds': dailyCompletedTaskIds.toList()..sort(),
      'persistedStreakDays': persistedStreakDays,
      'retentionSequence': retentionSequence,
      'retentionMemory': <Map<String, Object>>[
        for (final entry in sortedRetentionMemory) entry.toJson(),
      ],
      'openRepairIntents': <Map<String, Object>>[
        for (final intent in sortedOpenRepairIntents) intent.toPayload(),
      ],
      'multiRepairQueue': multiRepairQueue.toPayload(),
      'multiRepairQueueOrder': multiRepairQueueOrder,
      'resumeInRunner': resumeInRunner,
      'resumePhase': resumePhase,
      'resumeTeachingStepIndex': resumeTeachingStepIndex,
      'dismissedHomeHandoffKey': dismissedHomeHandoffKey,
      'dismissedHomeHandoffDay': dismissedHomeHandoffDay,
      'pendingDecisionAssistance': [
        for (final receipt
            in (pendingDecisionAssistance.toList()
              ..sort((a, b) => a.key.compareTo(b.key))))
          receipt.toJson(),
      ],
      'learningEvidenceHistory': learningEvidenceHistory.toPayload(),
      'studyObservations': [
        for (final observation in studyObservations) observation.toPayload(),
      ],
      'learningEvidenceLineage': learningEvidenceHistory.lineagePayload(),
      if (practiceDayKeys case final keys?) 'practiceDayKeys': keys,
      'lessonRunEvidenceBoundaries': <String, int?>{
        for (final entry in lessonRunEvidenceBoundaries.entries)
          entry.key: entry.value,
      },
      'durableRetentionHistory': durableRetentionHistory.toPayload(),
      'reviewMistakeHistory': reviewMistakeHistory.toPayload(),
      'reviewResolutionReceipts': reviewResolutionReceiptHistory.toPayload(),
      'conceptFamilyStateHistory': conceptFamilyStateHistory.toPayload(),
      'sessionIdentityState': sessionIdentityState.toPayload(),
      'repairOutcomeProjection': repairOutcomeProjection.toPayload(),
      if (lastSessionLearnerState != null)
        'lastSessionLearnerState': lastSessionLearnerState!.toJson(),
      if (firstValueReturnCarry != null)
        'firstValueReturnCarry': firstValueReturnCarry!.toJson(),
      if (resumeSelectedOptionId != null)
        'resumeSelectedOptionId': resumeSelectedOptionId!,
    });
  }

  static _Act0PersistedProgressV1? tryParse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) {
      return null;
    }
    final map = decoded.cast<String, Object?>();
    if (map.containsKey('suppressLegacyRecheckAfterRecovery') &&
        map['suppressLegacyRecheckAfterRecovery'] is! bool)
      return null;
    final schemaVersion = map['schemaVersion'];
    // Accept v1-v20 as the shell snapshot evolves.
    if (schemaVersion is! int || schemaVersion < 1 || schemaVersion > 20) {
      return null;
    }
    final pendingRaw = map['pendingDecisionAssistance'];
    final pendingDecisionAssistance = <_Act0PendingDecisionAssistanceV1>[];
    final pendingKeys = <String>{};
    if (schemaVersion == 20 || map.containsKey('pendingDecisionAssistance')) {
      if (pendingRaw is! List) return null;
      for (final value in pendingRaw) {
        final receipt = _Act0PendingDecisionAssistanceV1.tryParse(value);
        if (receipt == null || !pendingKeys.add(receipt.key)) return null;
        pendingDecisionAssistance.add(receipt);
      }
    }
    final openedReviewsRaw = map['openedSpacedReviewTaskIds'];
    if (map.containsKey('openedSpacedReviewTaskIds') &&
        (openedReviewsRaw is! List ||
            openedReviewsRaw.any((id) => id is! String || id.isEmpty))) {
      return null;
    }
    final openedSpacedReviewTaskIds = _stringSet(openedReviewsRaw);
    final completedTaskIds = _stringSet(map['completedTaskIds']);
    final skippedTaskIds = _stringSet(map['skippedTaskIds']);
    final completedLessonIds = _stringSet(map['completedLessonIds']);
    final selectedWorldId = (map['selectedWorldId'] ?? '').toString();
    final selectedLessonId = (map['selectedLessonId'] ?? '').toString();
    final selectedTaskId = (map['selectedTaskId'] ?? '').toString();
    final earnedXpRaw = map['earnedXp'];
    final earnedXp = earnedXpRaw is int
        ? earnedXpRaw
        : int.tryParse(earnedXpRaw?.toString() ?? '') ?? 0;
    final profileSkillValues = _intMap(map['profileSkillValues']);
    final recentSkillGains = _skillGainList(map['recentSkillGains']);
    // v2 fields — gracefully default for v1 records
    final lastActiveDay = (map['lastActiveDay'] ?? '').toString();
    final lastEarnedDailyDay = (map['lastEarnedDailyDay'] ?? '').toString();
    final dailyCompletedRepCountRaw = map['dailyCompletedRepCount'];
    final dailyCompletedRepCount = dailyCompletedRepCountRaw is int
        ? dailyCompletedRepCountRaw
        : int.tryParse(dailyCompletedRepCountRaw?.toString() ?? '') ??
              completedTaskIds.length.clamp(0, 3);
    final streakRaw = map['persistedStreakDays'];
    final persistedStreakDays = streakRaw is int
        ? streakRaw
        : int.tryParse(streakRaw?.toString() ?? '') ?? 0;
    final retentionSequenceRaw = map['retentionSequence'];
    final retentionSequence = retentionSequenceRaw is int
        ? retentionSequenceRaw
        : int.tryParse(retentionSequenceRaw?.toString() ?? '') ??
              completedTaskIds.length;
    final retentionMemory = _retentionMemoryList(map['retentionMemory']);
    final openRepairIntents = _openRepairIntentList(map['openRepairIntents']);
    final multiRepairQueue = Act0MultiRepairQueueV1.tryParse(
      map['multiRepairQueue'],
      legacyOpenRepairIntents: openRepairIntents,
    );
    final multiRepairQueueOrderRaw = map['multiRepairQueueOrder'];
    final multiRepairQueueOrder = multiRepairQueueOrderRaw is int
        ? multiRepairQueueOrderRaw
        : int.tryParse(multiRepairQueueOrderRaw?.toString() ?? '') ??
              _maxMultiRepairQueueOrder(multiRepairQueue);
    final resumeInRunner = map['resumeInRunner'] == true;
    final resumePhase = (map['resumePhase'] ?? '').toString();
    final resumeTeachingStepRaw = map['resumeTeachingStepIndex'];
    final resumeTeachingStepIndex = resumeTeachingStepRaw is int
        ? resumeTeachingStepRaw
        : int.tryParse(resumeTeachingStepRaw?.toString() ?? '') ?? 0;
    final resumeSelectedOptionIdRaw = map['resumeSelectedOptionId'];
    final resumeSelectedOptionId = resumeSelectedOptionIdRaw == null
        ? null
        : resumeSelectedOptionIdRaw.toString();
    final dismissedHomeHandoffKey = (map['dismissedHomeHandoffKey'] ?? '')
        .toString();
    final dismissedHomeHandoffDay = (map['dismissedHomeHandoffDay'] ?? '')
        .toString();
    final firstValueReturnCarry = _Act0FirstValueReceiptCarryV1.tryParse(
      map['firstValueReturnCarry'],
    );
    final lessonRunEvidenceLessonId = (map['lessonRunEvidenceLessonId'] ?? '')
        .toString();
    final evidenceStartRaw = map['lessonRunEvidenceStartOrder'];
    final parsedEvidenceStart = evidenceStartRaw is int
        ? evidenceStartRaw
        : int.tryParse(evidenceStartRaw?.toString() ?? '');
    final lessonRunEvidenceStartOrder =
        parsedEvidenceStart != null && parsedEvidenceStart >= 0
        ? parsedEvidenceStart
        : null;
    final lessonRunEvidenceBoundaries = <String, int?>{};
    final boundariesRaw = map['lessonRunEvidenceBoundaries'];
    if (boundariesRaw is Map) {
      for (final entry in boundariesRaw.entries) {
        final lessonId = entry.key.toString().trim();
        if (lessonId.isEmpty) continue;
        final value = entry.value;
        final order = value is int
            ? value
            : int.tryParse(value?.toString() ?? '');
        lessonRunEvidenceBoundaries[lessonId] = order != null && order >= 0
            ? order
            : null;
      }
    } else if (lessonRunEvidenceLessonId.isNotEmpty) {
      // Migrate the prior single-lesson schema-18 bookmark without dropping it.
      lessonRunEvidenceBoundaries[lessonRunEvidenceLessonId] =
          lessonRunEvidenceStartOrder;
    }
    final studyObservations = map.containsKey('studyObservations')
        ? Act0StudyObservationV1.restore(map['studyObservations'])
        : const <Act0StudyObservationV1>[];
    if (studyObservations == null) return null;
    final restoredEvidence = Act0LearningEvidenceHistoryV1.restore(
      map['learningEvidenceHistory'],
      map['learningEvidenceLineage'],
    );
    if ((schemaVersion == 19 || schemaVersion == 20) &&
        (restoredEvidence == null ||
            map['learningEvidenceLineage'] is! Map ||
            map['earnedXp'] is! int ||
            (map['earnedXp'] as int) < 0))
      return null;
    final learningEvidenceHistory =
        restoredEvidence ??
        const Act0LearningEvidenceHistoryV1(hasCompleteLineage: false);
    final durableRetentionHistory =
        Act0DurableRetentionHistoryV1.tryParseStrict(
          map['durableRetentionHistory'],
        );
    if (durableRetentionHistory == null) return null;
    final reviewMistakeHistory =
        Act0ReviewMistakeHistoryV1.tryParse(map['reviewMistakeHistory']) ??
        const Act0ReviewMistakeHistoryV1();
    final reviewResolutionReceiptHistory =
        Act0ReviewResolutionReceiptHistoryV1.tryParse(
          map['reviewResolutionReceipts'],
        );
    final conceptFamilyStateHistory = Act0ConceptFamilyStateHistoryV1.tryParse(
      map['conceptFamilyStateHistory'],
    );
    final sessionIdentityState = Act0SessionIdentityStateV1.tryParse(
      map['sessionIdentityState'],
    );
    final repairOutcomeProjection = Act0RepairOutcomeProjectionV1.tryParse(
      map['repairOutcomeProjection'],
    );
    final lastSessionLearnerState = Act0LastSessionLearnerStateV1.tryParse(
      map['lastSessionLearnerState'],
    );
    if (selectedWorldId.isEmpty ||
        selectedLessonId.isEmpty ||
        selectedTaskId.isEmpty) {
      return null;
    }
    return _Act0PersistedProgressV1(
      schemaVersion: schemaVersion,
      suppressLegacyRecheckAfterRecovery:
          map['suppressLegacyRecheckAfterRecovery'] == true,
      completedTaskIds: completedTaskIds,
      skippedTaskIds: skippedTaskIds,
      completedLessonIds: completedLessonIds,
      selectedWorldId: selectedWorldId,
      selectedLessonId: selectedLessonId,
      selectedTaskId: selectedTaskId,
      earnedXp: earnedXp < 0 ? 0 : earnedXp,
      w1StartChosen: map['w1StartChosen'] == true,
      w1RulesBestScore: switch (map['w1RulesBestScore']) {
        final int score
            when score >= 0 && score <= act0W1RulesQuestionsV1.length =>
          score,
        _ => 0,
      },
      w1RulesFocusTaskIds: switch (map['w1RulesFocusTaskIds']) {
        final List<Object?> ids => {
          for (final question in act0W1RulesQuestionsV1)
            if (ids.contains(question.taskId)) question.taskId,
        },
        _ => const {},
      },
      profileSkillValues: profileSkillValues,
      recentSkillGains: recentSkillGains,
      lastActiveDay: lastActiveDay,
      lastEarnedDailyDay: lastEarnedDailyDay,
      hasEarnedDailyDayField: map.containsKey('lastEarnedDailyDay'),
      dailyCompletedRepCount: dailyCompletedRepCount.clamp(0, 3),
      dailyPracticeQueue:
          Act0DailyPracticeQueueV1.tryParse(map['dailyPracticeQueue']) ??
          const Act0DailyPracticeQueueV1(),
      dailyCompletedTaskIds: _stringSet(map['dailyCompletedTaskIds']),
      persistedStreakDays: persistedStreakDays < 0 ? 0 : persistedStreakDays,
      retentionSequence: retentionSequence < 0 ? 0 : retentionSequence,
      retentionMemory: retentionMemory,
      openRepairIntents: multiRepairQueue.activeRepairIntents(),
      multiRepairQueue: multiRepairQueue,
      multiRepairQueueOrder: multiRepairQueueOrder < 0
          ? 0
          : multiRepairQueueOrder,
      resumeInRunner: resumeInRunner,
      resumePhase: resumePhase,
      resumeTeachingStepIndex: resumeTeachingStepIndex < 0
          ? 0
          : resumeTeachingStepIndex,
      resumeSelectedOptionId: resumeSelectedOptionId,
      dismissedHomeHandoffKey: dismissedHomeHandoffKey,
      dismissedHomeHandoffDay: dismissedHomeHandoffDay,
      firstValueReturnCarry: firstValueReturnCarry,
      learningEvidenceHistory: learningEvidenceHistory,
      studyObservations: studyObservations,
      practiceDayKeys: switch (map['practiceDayKeys']) {
        final List<Object?> days =>
          days
              .whereType<String>()
              .take(Act0LearningEvidenceHistoryV1.maxStoredPracticeDays)
              .toList(growable: false),
        _ => null,
      },
      pendingDecisionAssistance: pendingDecisionAssistance,
      hasPendingAssistanceProvenance: map.containsKey(
        'pendingDecisionAssistance',
      ),
      lessonRunEvidenceBoundaries: lessonRunEvidenceBoundaries,
      durableRetentionHistory: durableRetentionHistory,
      openedSpacedReviewTaskIds: openedSpacedReviewTaskIds,
      reviewMistakeHistory: reviewMistakeHistory,
      reviewResolutionReceiptHistory: reviewResolutionReceiptHistory,
      conceptFamilyStateHistory: conceptFamilyStateHistory,
      sessionIdentityState: sessionIdentityState,
      repairOutcomeProjection: repairOutcomeProjection,
      lastSessionLearnerState: lastSessionLearnerState,
    );
  }

  static Set<String> _stringSet(Object? raw) {
    if (raw is! List) {
      return <String>{};
    }
    return raw
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  static Map<String, int> _intMap(Object? raw) {
    if (raw is! Map) {
      return <String, int>{};
    }
    final map = <String, int>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty) continue;
      final value = entry.value;
      final parsed = value is int
          ? value
          : int.tryParse(value?.toString() ?? '');
      if (parsed == null || parsed < 0) continue;
      map[key] = parsed;
    }
    return map;
  }

  static List<Act0SkillGainV1> _skillGainList(Object? raw) {
    if (raw is! List) {
      return const <Act0SkillGainV1>[];
    }
    final gains = <Act0SkillGainV1>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final label = (item['label'] ?? '').toString().trim();
      final source = (item['source'] ?? '').toString().trim();
      final gainRaw = item['gain'];
      final gain = gainRaw is int
          ? gainRaw
          : int.tryParse(gainRaw?.toString() ?? '');
      if (label.isEmpty || source.isEmpty || gain == null || gain <= 0) {
        continue;
      }
      gains.add(Act0SkillGainV1(label: label, gain: gain, source: source));
    }
    return gains;
  }

  static List<_Act0RetentionMemoryEntryV1> _retentionMemoryList(Object? raw) {
    if (raw is! List) {
      return const <_Act0RetentionMemoryEntryV1>[];
    }
    final entries = <_Act0RetentionMemoryEntryV1>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final parsed = _Act0RetentionMemoryEntryV1.tryParse(item);
      if (parsed != null) {
        entries.add(parsed);
      }
    }
    entries.sort((a, b) => a.taskId.compareTo(b.taskId));
    return entries;
  }

  static List<Act0RepairIntentV1> _openRepairIntentList(Object? raw) {
    if (raw is! List) {
      return const <Act0RepairIntentV1>[];
    }
    final intentsByIdentity = <String, Act0RepairIntentV1>{};
    for (final item in raw) {
      final parsed = Act0RepairIntentV1.tryParse(item);
      if (parsed != null) {
        final key = repairQueueIdentityKeyForAct0RepairIntentV1(parsed);
        if (key.isNotEmpty) {
          intentsByIdentity[key] = parsed;
        }
      }
    }
    final intents = intentsByIdentity.values.toList(growable: false)
      ..sort(
        (a, b) => repairQueueIdentityKeyForAct0RepairIntentV1(
          a,
        ).compareTo(repairQueueIdentityKeyForAct0RepairIntentV1(b)),
      );
    return intents;
  }

  static int _maxMultiRepairQueueOrder(Act0MultiRepairQueueV1 queue) {
    var maxOrder = 0;
    for (final entry in queue.entries) {
      if (entry.lastUpdatedAtOrder > maxOrder) {
        maxOrder = entry.lastUpdatedAtOrder;
      }
    }
    return maxOrder;
  }
}

class _Act0RetentionMemoryStatusV1 {
  static const String openRepair = 'openRepair';
  static const String fixedRecent = 'fixedRecent';
  static const String agedRecheck = 'agedRecheck';
  static const String ownedCandidate = 'ownedCandidate';

  static bool isKnown(String value) {
    return value == openRepair ||
        value == fixedRecent ||
        value == agedRecheck ||
        value == ownedCandidate;
  }
}

class _Act0RetentionMemoryEntryV1 {
  const _Act0RetentionMemoryEntryV1({
    required this.taskId,
    required this.lessonId,
    required this.worldId,
    required this.status,
    required this.attempts,
    required this.fixedAtSequence,
    required this.lastRecheckSequence,
    required this.successfulRecheckCount,
  });

  final String taskId;
  final String lessonId;
  final String worldId;
  final String status;
  final int attempts;
  final int fixedAtSequence;
  final int lastRecheckSequence;
  final int successfulRecheckCount;

  _Act0RetentionMemoryEntryV1 copyWith({
    String? taskId,
    String? lessonId,
    String? worldId,
    String? status,
    int? attempts,
    int? fixedAtSequence,
    int? lastRecheckSequence,
    int? successfulRecheckCount,
  }) {
    return _Act0RetentionMemoryEntryV1(
      taskId: taskId ?? this.taskId,
      lessonId: lessonId ?? this.lessonId,
      worldId: worldId ?? this.worldId,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      fixedAtSequence: fixedAtSequence ?? this.fixedAtSequence,
      lastRecheckSequence: lastRecheckSequence ?? this.lastRecheckSequence,
      successfulRecheckCount:
          successfulRecheckCount ?? this.successfulRecheckCount,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'taskId': taskId,
      'lessonId': lessonId,
      'worldId': worldId,
      'status': status,
      'attempts': attempts,
      'fixedAtSequence': fixedAtSequence,
      'lastRecheckSequence': lastRecheckSequence,
      'successfulRecheckCount': successfulRecheckCount,
    };
  }

  static _Act0RetentionMemoryEntryV1? tryParse(Map raw) {
    final taskId = (raw['taskId'] ?? '').toString().trim();
    final lessonId = (raw['lessonId'] ?? '').toString().trim();
    final worldId = (raw['worldId'] ?? '').toString().trim();
    final status = (raw['status'] ?? '').toString().trim();
    final attempts = _nonNegativeInt(raw['attempts']);
    final fixedAtSequence = _nonNegativeInt(raw['fixedAtSequence']);
    final lastRecheckSequence = _nonNegativeInt(raw['lastRecheckSequence']);
    final successfulRecheckCount = _nonNegativeInt(
      raw['successfulRecheckCount'],
    );
    if (taskId.isEmpty ||
        lessonId.isEmpty ||
        worldId.isEmpty ||
        !_Act0RetentionMemoryStatusV1.isKnown(status) ||
        attempts == null ||
        fixedAtSequence == null ||
        lastRecheckSequence == null ||
        successfulRecheckCount == null) {
      return null;
    }
    return _Act0RetentionMemoryEntryV1(
      taskId: taskId,
      lessonId: lessonId,
      worldId: worldId,
      status: status,
      attempts: attempts,
      fixedAtSequence: fixedAtSequence,
      lastRecheckSequence: lastRecheckSequence,
      successfulRecheckCount: successfulRecheckCount,
    );
  }

  static int? _nonNegativeInt(Object? raw) {
    final parsed = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    if (parsed == null || parsed < 0) {
      return null;
    }
    return parsed;
  }
}

class _Act0RepairTargetV1 {
  const _Act0RepairTargetV1({required this.lessonId, required this.taskId});

  final String lessonId;
  final String taskId;
}

class _Act0MistakeRecordV1 {
  const _Act0MistakeRecordV1({
    required this.taskId,
    required this.lessonId,
    required this.worldId,
    required this.title,
    required this.weaknessLabel,
    required this.selectedOptionId,
    required this.selectedLabel,
    required this.betterLabel,
    required this.reason,
    required this.contextLabels,
    required this.repairActionLabel,
    required this.attempts,
  });

  final String taskId;
  final String lessonId;
  final String worldId;
  final String title;
  final String weaknessLabel;
  final String selectedOptionId;
  final String selectedLabel;
  final String betterLabel;
  final String reason;
  final List<String> contextLabels;
  final String repairActionLabel;
  final int attempts;

  Act0MistakeCardV1 toCard({
    bool resolved = false,
    Act0CompletionDisplayStateV1? completionState,
    String qualityLine = '',
    String? repairActionLabelOverride,
    bool sourceRetriedCorrectly = false,
  }) {
    return Act0MistakeCardV1(
      taskId: taskId,
      lessonId: lessonId,
      worldId: worldId,
      title: title,
      weaknessLabel: weaknessLabel,
      selectedOptionId: selectedOptionId,
      selectedLabel: selectedLabel,
      betterLabel: betterLabel,
      reason: reason,
      attempts: attempts,
      severityLabel: resolved
          ? attempts <= 1
                ? 'Quick fix'
                : 'Clear'
          : attempts >= 2
          ? 'Deep repair'
          : 'Needs repair',
      contextLabels: contextLabels,
      repairActionLabel: repairActionLabelOverride ?? repairActionLabel,
      resolved: resolved,
      completionState: completionState,
      qualityLine: qualityLine,
      sourceRetriedCorrectly: sourceRetriedCorrectly,
    );
  }
}

class _TopBarV1 extends StatelessWidget {
  const _TopBarV1({
    required this.state,
    required this.goalLabel,
    required this.goalProgress,
    this.academy = false,
  });

  final Act0ShellStateV1 state;
  final String goalLabel;
  final double goalProgress;
  final bool academy;

  @override
  Widget build(BuildContext context) {
    final streakTone = state.streakDays > 0
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.textDim;
    return Container(
      key: const Key('act0_shell_top_bar'),
      height: academy ? null : 50,
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: Act0ShellTokensV1.pageX),
      decoration: academy
          ? const BoxDecoration(
              color: Act0AcademyDesignTokensV1.pageSurface,
              border: Border(
                bottom: BorderSide(color: Act0AcademyDesignTokensV1.rule),
              ),
            )
          : Act0ShellTokensV1.glassDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goalLabel,

                        style:
                            (academy
                                    ? Act0AcademyDesignTokensV1.body
                                    : Act0ShellTokensV1.body)
                                .copyWith(
                                  color: academy
                                      ? Act0AcademyDesignTokensV1.ink
                                      : Act0ShellTokensV1.text,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  child: LinearProgressIndicator(
                    minHeight: Act0ShellTokensV1.progressHeight,
                    value: goalProgress,
                    backgroundColor: academy
                        ? Act0AcademyDesignTokensV1.rule
                        : Act0ShellTokensV1.surface3,
                    color: academy
                        ? Act0AcademyDesignTokensV1.focus
                        : Act0ShellTokensV1.actionBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: streakTone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(color: streakTone.withValues(alpha: 0.28)),
            ),
            child: Text(
              academy && Localizations.localeOf(context).languageCode == 'ru'
                  ? '${state.streakDays} \u0434.'
                  : '${state.streakDays}d',
              style: Act0ShellTokensV1.muted.copyWith(
                color: academy
                    ? Act0AcademyDesignTokensV1.inkMuted
                    : streakTone,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavV1 extends StatelessWidget {
  const _BottomNavV1({
    required this.current,
    required this.onSelected,
    this.reviewHasDot = false,
    this.academy = false,
    this.premium = false,
  });

  final Act0ShellTabV1 current;
  final ValueChanged<Act0ShellTabV1> onSelected;
  final bool reviewHasDot;
  final bool academy;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: academy,
      child: IntrinsicHeight(
        child: SizedBox(
          key: const Key('act0_shell_bottom_nav'),
          height: academy ? null : Act0ShellTokensV1.bottomNavHeight,

          child: DecoratedBox(
            decoration: premium
                ? const BoxDecoration(
                    color: Act0AcademyLeafPaletteV1.ink,
                    border: Border(
                      top: BorderSide(color: Act0AcademyLeafPaletteV1.rule),
                    ),
                  )
                : academy
                ? const BoxDecoration(
                    color: Act0AcademyDesignTokensV1.pageSurface,
                    border: Border(
                      top: BorderSide(color: Act0AcademyDesignTokensV1.rule),
                    ),
                  )
                : Act0ShellTokensV1.glassDecoration(top: true),
            child: Row(
              crossAxisAlignment: academy
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              children: [
                _NavItemV1(
                  tab: Act0ShellTabV1.home,
                  current: current,
                  icon: academy ? Icons.home_outlined : Icons.home_rounded,
                  label: act0AcademyNavLabelV1(context, Act0ShellTabV1.home),
                  academy: academy,
                  premium: premium,
                  onSelected: onSelected,
                ),
                _NavItemV1(
                  tab: Act0ShellTabV1.learn,
                  current: current,
                  icon: academy
                      ? Icons.menu_book_outlined
                      : Icons.menu_book_rounded,
                  label: act0AcademyNavLabelV1(context, Act0ShellTabV1.learn),
                  academy: academy,
                  premium: premium,
                  onSelected: onSelected,
                ),
                _NavItemV1(
                  tab: Act0ShellTabV1.play,
                  current: current,
                  icon: academy ? Icons.spa_outlined : Icons.spa_rounded,
                  label: act0AcademyNavLabelV1(context, Act0ShellTabV1.play),
                  academy: academy,
                  premium: premium,
                  onSelected: onSelected,
                ),
                _NavItemV1(
                  tab: Act0ShellTabV1.review,
                  current: current,
                  icon: Icons.refresh_rounded,
                  label: act0AcademyNavLabelV1(context, Act0ShellTabV1.review),
                  academy: academy,
                  premium: premium,
                  showDot: reviewHasDot,
                  onSelected: onSelected,
                ),
                _NavItemV1(
                  tab: Act0ShellTabV1.profile,
                  current: current,
                  icon: academy ? Icons.person_outline : Icons.person_rounded,
                  label: act0AcademyNavLabelV1(context, Act0ShellTabV1.profile),
                  academy: academy,
                  premium: premium,
                  onSelected: onSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemV1 extends StatelessWidget {
  const _NavItemV1({
    required this.tab,
    required this.current,
    required this.icon,
    required this.label,
    required this.onSelected,
    this.showDot = false,
    this.academy = false,
    this.premium = false,
  });

  final Act0ShellTabV1 tab;
  final Act0ShellTabV1 current;
  final IconData icon;
  final String label;
  final ValueChanged<Act0ShellTabV1> onSelected;
  final bool showDot;
  final bool academy;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final color = premium
        ? (selected
              ? Act0AcademyLeafPaletteV1.aqua
              : Act0AcademyLeafPaletteV1.textMuted)
        : academy
        ? (selected
              ? Act0AcademyDesignTokensV1.focus
              : Act0AcademyDesignTokensV1.inkMuted)
        : (selected
              ? Act0VisualCanonV1.bluePrimary
              : Act0ShellTokensV1.textMuted);
    final hasBadge = showDot;
    return Expanded(
      child: Act0SemanticActionV1(
        label: label,
        selected: selected,
        value: hasBadge ? 'Items to review' : null,
        sortKey: OrdinalSortKey(tab.index.toDouble(), name: 'act0_navigation'),
        onTap: () => onSelected(tab),
        child: InkWell(
          onTap: () => onSelected(tab),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: academy ? 60 : 0,
              minWidth: 44,
            ),
            child: Container(
              decoration: academy && selected
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: color, width: 2),
                      ),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(icon, size: 21, color: color),
                      if (hasBadge)
                        Positioned(
                          top: -3,
                          right: -6,
                          child: Container(
                            key: Key(
                              'act0_shell_nav_badge_${_navItemKeyLabelV1(tab)}',
                            ),
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: Act0ShellTokensV1.gold,
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusPill,
                              ),
                              border: Border.all(
                                color: Act0ShellTokensV1.surface,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: academy ? 4 : 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style:
                        (academy
                                ? Act0AcademyDesignTokensV1.supporting
                                : const TextStyle())
                            .copyWith(
                              color: color,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _navItemKeyLabelV1(Act0ShellTabV1 tab) {
  return switch (tab) {
    Act0ShellTabV1.home => 'home',
    Act0ShellTabV1.learn => 'learn',
    Act0ShellTabV1.play => 'play',
    Act0ShellTabV1.review => 'review',
    Act0ShellTabV1.profile => 'profile',
  };
}

const _placementQuestionExperienceV1 = Act0PlacementQuestionV1(
  questionId: 'experience',
  eyebrow: 'Starting point',
  title: 'Where are you starting from?',
  subtitle: 'Be honest. This only changes where Sharky should begin.',
  helper:
      'The goal is not to rank you. The goal is to avoid wasting your first sessions.',
  icon: Icons.flag_rounded,
  options: <Act0PlacementOptionV1>[
    Act0PlacementOptionV1(
      optionId: 'new',
      label: 'I have not really played yet',
      score: 0,
      profileTag: 'New',
      subtitle: 'Start from zero and build the table language cleanly.',
      icon: Icons.school_rounded,
      badge: 'Best for zero',
    ),
    Act0PlacementOptionV1(
      optionId: 'friends',
      label: 'I played casually, mostly guessing with friends',
      score: 1,
      profileTag: 'Casual',
      subtitle:
          'You know some words, but the structure still needs tightening.',
      icon: Icons.groups_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'watching',
      label: 'I watch poker content, but real decisions still freeze me',
      score: 1,
      profileTag: 'Watching',
      subtitle:
          'Translate passive knowledge into something usable at the table.',
      icon: Icons.live_tv_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'online',
      label: 'I have played online or live and want sharper structure',
      score: 3,
      profileTag: 'Played',
      subtitle: 'Skip part of the intro and move faster into action language.',
      icon: Icons.insights_rounded,
      badge: 'Faster start',
    ),
  ],
);

const _placementQuestionFormatV1 = Act0PlacementQuestionV1(
  questionId: 'format',
  eyebrow: 'Your use case',
  title: 'What do you want poker for?',
  subtitle:
      'This shapes examples, language, and the kind of situations Sharky shows first.',
  helper:
      'Choose everything that feels true right now. Sharky will look for the dominant pattern, not force a single lane.',
  icon: Icons.route_rounded,
  allowsMultiple: true,
  options: <Act0PlacementOptionV1>[
    Act0PlacementOptionV1(
      optionId: 'basics',
      label: 'I want the game to finally make sense',
      score: 0,
      profileTag: 'Basics',
      subtitle: 'Start with table literacy before strategy words and jargon.',
      icon: Icons.menu_book_rounded,
      badge: 'Core',
    ),
    Act0PlacementOptionV1(
      optionId: 'cash',
      label: 'I want to feel confident in cash-game spots',
      score: 2,
      profileTag: 'Cash',
      subtitle:
          'Bias examples toward chips, pressure, and practical decisions.',
      icon: Icons.attach_money_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'tournaments',
      label: 'I care more about tournament decisions',
      score: 2,
      profileTag: 'Tournament',
      subtitle:
          'Bias examples toward survival, pressure, and changing leverage.',
      icon: Icons.emoji_events_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'home_games',
      label: 'I do not want to feel lost in home games',
      score: 1,
      profileTag: 'HomeGames',
      subtitle:
          'Focus on hand flow, confidence, and keeping up with the table.',
      icon: Icons.table_restaurant_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'content',
      label: 'I want poker videos and hand talk to stop sounding cryptic',
      score: 1,
      profileTag: 'Content',
      subtitle:
          'Use examples that decode table language instead of assuming it.',
      icon: Icons.subscriptions_rounded,
    ),
  ],
);

const _placementQuestionConfidenceV1 = Act0PlacementQuestionV1(
  questionId: 'confidence',
  eyebrow: 'Where to help first',
  title: 'What feels most confusing?',
  subtitle: 'Pick the part that makes you hesitate most.',
  helper:
      'Sharky will use this to bias your first explanations, review hints, and early repair spots.',
  icon: Icons.lightbulb_rounded,
  options: <Act0PlacementOptionV1>[
    Act0PlacementOptionV1(
      optionId: 'rules',
      label: 'Knowing whose turn it is and how a hand even moves',
      score: 0,
      profileTag: 'Rules',
      subtitle:
          'You want the table flow, blinds, and action order to stop feeling fuzzy.',
      icon: Icons.account_tree_rounded,
      badge: 'Foundation',
    ),
    Act0PlacementOptionV1(
      optionId: 'cards',
      label: 'Reading cards, pairs, and hand strength fast enough',
      score: 1,
      profileTag: 'Cards',
      subtitle:
          'You want stronger recognition and more confidence at showdown.',
      icon: Icons.style_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'decisions',
      label: 'Knowing when to fold, call, or raise without second-guessing',
      score: 2,
      profileTag: 'Decisions',
      subtitle:
          'You mostly want help making the right action at the right time.',
      icon: Icons.touch_app_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'board',
      label: 'Seeing what changed on the flop, turn, or river',
      score: 1,
      profileTag: 'Board',
      subtitle: 'You want the board to feel readable instead of noisy.',
      icon: Icons.view_module_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'pressure',
      label: 'Staying clear when people bet and pressure starts building',
      score: 2,
      profileTag: 'Pressure',
      subtitle:
          'You want calmer decisions when the table stops feeling passive.',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

const _placementQuestionGoalV1 = Act0PlacementQuestionV1(
  questionId: 'goal',
  eyebrow: 'Coaching style',
  title: 'How should Sharky coach you?',
  subtitle: 'Choose the style that would keep you coming back.',
  helper:
      'Choose everything that sounds motivating. Sharky should feel like the right kind of pressure, not the wrong kind.',
  icon: Icons.favorite_rounded,
  allowsMultiple: true,
  options: <Act0PlacementOptionV1>[
    Act0PlacementOptionV1(
      optionId: 'guided',
      label: 'Keep me calm and guided at the start',
      score: 0,
      profileTag: 'Guided',
      subtitle:
          'Short explanations first, then gentle practice that makes sense.',
      icon: Icons.explore_rounded,
      badge: 'Calm start',
    ),
    Act0PlacementOptionV1(
      optionId: 'practice',
      label: 'Let me learn mostly by doing',
      score: 1,
      profileTag: 'Practice',
      subtitle: 'Less talking, more repetition once the concept is visible.',
      icon: Icons.fitness_center_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'diagnose',
      label: 'Show me my weak spots',
      score: 2,
      profileTag: 'Diagnostic',
      subtitle: 'Surface weak spots quickly and keep repair close by.',
      icon: Icons.search_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'daily_plan',
      label: 'Give me a short plan I can actually stick to',
      score: 1,
      profileTag: 'DailyPlan',
      subtitle: 'A compact habit loop with one clear next step each day.',
      icon: Icons.today_rounded,
    ),
    Act0PlacementOptionV1(
      optionId: 'honest',
      label: 'Be direct with me when I am guessing',
      score: 1,
      profileTag: 'Direct',
      subtitle: 'More clarity and sharper feedback, without turning harsh.',
      icon: Icons.record_voice_over_rounded,
    ),
  ],
);

const _placementQuestionBankV1 = <Act0PlacementQuestionV1>[
  _placementQuestionExperienceV1,
  _placementQuestionFormatV1,
  _placementQuestionConfidenceV1,
  _placementQuestionGoalV1,
];

const _placementQuestionsV1 = <Act0PlacementQuestionV1>[
  _placementQuestionExperienceV1,
  _placementQuestionConfidenceV1,
];

class _Act0PlacementDiagnosticSpotV1 {
  const _Act0PlacementDiagnosticSpotV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.signalId,
    this.isFoundation = false,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final String signalId;
  final bool isFoundation;
}

const _placementDiagnosticSpotsV1 = <_Act0PlacementDiagnosticSpotV1>[
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'what_poker_is',
    taskId: 'what_poker_is_table_read_transfer',
    signalId: 'table_read',
    isFoundation: true,
  ),
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'what_poker_is',
    taskId: 'what_poker_is_table_read_transfer',
    signalId: 'board_private_cards',
    isFoundation: true,
  ),
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'what_poker_is',
    taskId: 'what_poker_is_table_read_transfer',
    signalId: 'action_basics',
  ),
];

// fromBeatV1 later: map BeatV1.caption/hint/options/feedback/table adapter
// into Act0RunnerStateV1, then replace Act0ShellStateV1.sample at the preview
// boundary without changing production Today, Map, Runner, or Result routes.

/// REP-02/REP-03: copy shown before and during an attempt that is recorded as
/// unassisted. It may name the learner's own earlier choice and point at the
/// table clue, but never the better action, or the recheck stops being the
/// learner's own choice. (Native finding on 3c83f85d: "Better: Check" was
/// shown and the following answer still closed the repair as independent.)
String act0RepairPracticeIntroBodyV1({
  required String selectedLabel,
  required bool sameTask,
}) => sameTask
    ? 'You chose $selectedLabel. Find the table clue first, then choose again.'
    : 'Same idea, new frame. You chose $selectedLabel. Find the table clue first, then choose.';

String act0RepairFocusCalloutV1({required String selectedLabel}) =>
    'Repair: $selectedLabel misses this clue.';
