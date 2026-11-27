import 'act0_repair_gap_adjudication_v1.dart';
import 'act0_position_personalization_v1.dart';
import 'act0_shell_state_v1.dart';

typedef Act0VerifiedTransferTargetV1 = ({
  String worldId,
  String lessonId,
  String taskId,
  String mappingType,
});

/// Content-only admission. The caller must additionally establish that the
/// target has been completed and is currently launchable. B58 exactReplay
/// requires identical IDs and snapshots; rejecting identical IDs is stronger.
Act0VerifiedTransferTargetV1? act0VerifiedTransferTargetV1(
  String sourceTaskId,
) {
  sourceTaskId = sourceTaskId.trim();
  final adjudication = act0RepairGapAdjudicationForSourceTaskV1(sourceTaskId);
  if (adjudication?.leaksOriginalAnswer == true ||
      adjudication?.requiresFutureKnowledge == true)
    return null;
  final target =
      adjudication?.outcome == Act0RepairGapOutcomeV1.alternateSameSignalTarget
      ? (
          worldId: adjudication!.targetWorldId!,
          lessonId: adjudication.targetLessonId!,
          taskId: adjudication.targetTaskId!,
          mappingType: adjudication.mappingType,
        )
      : act0FirstValueSameSignalRepMappingV1(
          nextRepId: '',
          skillAtomId: '',
          sourceSignalId: '',
          sourceTaskId: sourceTaskId,
          receiptOutcome: 'needs_rep',
          explicitOnly: true,
        );
  return target == null || target.taskId == sourceTaskId ? null : target;
}

/// Learner-specific admission; never use skipped completion or a locked
/// lesson to open a target before its ordinary course prerequisites.
Act0VerifiedTransferTargetV1? act0CompletedTransferTargetV1(
  String sourceTaskId,
  List<Act0WorldCardV1> worlds,
  Set<String> completedTaskIds,
) {
  final target = act0VerifiedTransferTargetV1(sourceTaskId);
  if (target == null || !completedTaskIds.contains(target.taskId)) return null;
  final world = worlds.where((w) => w.worldId == target.worldId).firstOrNull;
  if (world == null || !world.isSelectable || world.isLocked) return null;
  final lesson = world.lessons
      .where((l) => l.lessonId == target.lessonId)
      .firstOrNull;
  if (lesson == null || !lesson.isSelectable || lesson.isLocked) return null;
  final task = lesson.courseTaskList
      .where((t) => t.taskId == target.taskId)
      .firstOrNull;
  if (task == null ||
      task.phase != Act0LessonPhaseV1.drill ||
      task.multiStreet != null ||
      task.runner.options.isEmpty)
    return null;
  return target;
}

({String worldId, String lessonId, String taskId, String mappingType})?
act0FirstValueSameSignalRepMappingV1({
  required String nextRepId,
  required String skillAtomId,
  required String sourceSignalId,
  required String sourceTaskId,
  required String receiptOutcome,
  bool explicitOnly = false,
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
  if (!explicitOnly &&
      adjudication != null &&
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
  if (explicitOnly ||
      (nextRepId == 'repeat_range_bucket_reasoning' &&
          skillAtomId == 'range_bucket_reasoning' &&
          sourceSignalId == 'range_bucket_shift')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_board_texture_reasoning' &&
          skillAtomId == 'board_texture_reasoning' &&
          sourceSignalId == 'board_texture_change')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_mindset_process_discipline' &&
          skillAtomId == 'mindset_process_discipline' &&
          sourceSignalId == 'process_over_outcome')) {
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
      // The checkpoint's outgoing pair is authored by B153 adjudication.
      // Do not retain a competing explicit target here.
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

  if (explicitOnly ||
      (nextRepId == 'repeat_table_read' &&
          skillAtomId == 'table_read' &&
          sourceSignalId == 'stack_depth')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_table_read' &&
          skillAtomId == 'table_read' &&
          sourceSignalId == 'tournament_pressure')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_table_read' &&
          skillAtomId == 'table_read' &&
          sourceSignalId == 'player_tendency')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_table_read' &&
          skillAtomId == 'table_read' &&
          sourceSignalId == 'session_plan')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_table_read' &&
          skillAtomId == 'table_read' &&
          sourceSignalId == 'tilt_reset')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_starting_hand_read' &&
          skillAtomId == 'starting_hand_read' &&
          sourceSignalId == 'hero_cards')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_table_read' &&
          skillAtomId == 'table_read' &&
          sourceSignalId == 'hero_cards_board_pot')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_board_read' &&
          skillAtomId == 'board_read' &&
          sourceSignalId == 'board_cards')) {
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

  if (explicitOnly ||
      (nextRepId == 'repeat_price_read' &&
          skillAtomId == 'price_read' &&
          sourceSignalId == 'pot_to_call')) {
    switch (sourceTask) {
      case 'w4_good_price_call':
      case 'w4_cheap_price_marginal_call':
        return target('world_4', 'call_price', 'w4_bad_price_fold');
      case 'w4_bad_price_fold':
      case 'w4_big_price_marginal_fold':
        return target('world_4', 'call_price', 'w4_good_price_call');
    }
  }

  if (explicitOnly ||
      (nextRepId == 'repeat_action_read' &&
          skillAtomId == 'action_read' &&
          sourceSignalId == 'no_bet_yet')) {
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

  if (explicitOnly) return null;

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
      lessonId: 'first_table_guide',
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
