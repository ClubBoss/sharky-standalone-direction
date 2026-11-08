import 'act0_assessment_summary_projection_v1.dart';
import 'act0_assessment_title_projection_v1.dart';
import 'act0_shell_state_v1.dart';

// ASM-04 pre-choice answer-cue policy (catalog-wide closure, 2026-11-08).
//
// Display-only. Authored titles, captions, table cues, task/choice IDs,
// grades, XP, assistance and history stay untouched; no projection reads an
// option's grade. Each set below is an adjudicated, exact list of English
// copy that states, verdicts or entails the correct choice before the learner
// decides (see test/ui_v2/act0_asm04_prechoice_answer_cue_closure_v1_test.dart).
// Hand-ranking titles and summaries keep the #421/#422 donor policies.

/// True when [task] opens on an independent, gradable choice.
bool act0IsPrechoiceAssessmentTaskV1(Act0LessonTaskV1 task) =>
    task.entryPhase != Act0LessonPhaseV1.theory &&
    task.runner.options.isNotEmpty;

/// Neutral English navigation titles for answer-bearing authored titles.
/// Extends the #374 J1 atoms catalog-wide; numbering keeps steps apart.
const Map<String, String> act0PrechoiceNeutralTitleByTaskIdV1 =
    <String, String>{
      'cards_ranks_suits_best_five': 'Hand size question',
      'actions_check_drill': 'Action choice 1',
      'actions_fold_drill': 'Action choice 2',
      'actions_call_drill': 'Action choice 3',
      'actions_raise_drill': 'Action choice 4',
      'showdown_best_hand_drill': 'Showdown question 1',
      'showdown_kicker_drill': 'Showdown question 2',
      'fold_discipline_early_fold': 'Discipline spot 1',
      'fold_discipline_discipline_stack_protect': 'Discipline spot 2',
      'weak_ace_warning_w3_dominated_fold': 'Facing an open 1',
      'weak_ace_warning_w3_strong_continue': 'Facing an open 2',
      'weak_ace_warning_weak_ace_pressure_fold': 'Facing an open 3',
      'continue_or_let_go_premium_continue': 'Hand decision 1',
      'continue_or_let_go_medium_open': 'Hand decision 2',
      'continue_or_let_go_weak_let_go': 'Hand decision 3',
      'apply_utg_fold': 'Seat and hand 1',
      'apply_btn_open': 'Seat and hand 2',
      'apply_hj_decision': 'Seat and hand 3',
      'discipline_checkpoint_checkpoint_premium': 'Checkpoint hand 1',
      'discipline_checkpoint_checkpoint_fold': 'Checkpoint hand 2',
      'discipline_checkpoint_checkpoint_borderline_continue':
          'Checkpoint hand 3',
      'button_advantage_button_open': 'Button spot',
      'button_advantage_button_vs_cutoff': 'Seat order question',
      'button_advantage_position_repair_btn_last_postflop': 'Seat order repair',
      'continue_or_let_go_continue_recap': 'Hand decision recap',
      'same_hand_different_seat_w3_same_hand_open': 'Seat frame 1',
      'same_hand_different_seat_w3_same_hand_call': 'Seat frame 2',
      'same_hand_different_seat_same_hand_early_fold': 'Seat frame 3',
      'same_hand_different_seat_same_hand_late_open': 'Seat frame 4',
      'position_apply_btn_open': 'Position spot 1',
      'position_apply_early_fold': 'Position spot 2',
      'position_apply_hj_fold': 'Position spot 3',
      'position_checkpoint_position_checkpoint_early_fold': 'Checkpoint seat 1',
      'position_checkpoint_position_checkpoint_btn_call': 'Checkpoint seat 2',
      'w4_value_purpose': 'Bet purpose 1',
      'w4_bluff_purpose': 'Bet purpose 2',
      'w4_value_bet': 'Flop choice 1',
      'w4_value_missed': 'Flop choice 2',
      'w4_bluff_pressure': 'Flop choice 3',
      'w4_bad_bluff': 'Flop choice 4',
      'w4_protection_check': 'After a check',
      'w4_cheap_price_marginal_call': 'Price decision 3',
      'w4_big_price_marginal_fold': 'Price decision 4',
      'w4_checkpoint_review': 'Bet recap',
      'board_texture_basics_w5_dry_board': 'Board texture 1',
      'board_texture_basics_w5_wet_board': 'Board texture 2',
      'connected_boards_w5_disconnected_board': 'Board shape 1',
      'connected_boards_w5_connected_board': 'Board shape 2',
      'flush_draws_w5_flush_draw_find': 'Draw check 1',
      'flush_draws_w5_no_flush_draw': 'Draw check 2',
      'straight_draws_w5_straight_draw_find': 'Draw check 3',
      'straight_draws_w5_gap_board': 'Draw check 4',
      'straight_draws_w5_gutshot_draw': 'Draw check 5',
      'outs_improvement_w5_table_outs_flush_transfer': 'Improvement cards 1',
      'outs_improvement_w5_table_outs_straight_transfer': 'Improvement cards 2',
      'turn_river_changes_w5_turn_hits': 'Runout read 1',
      'turn_river_changes_w5_river_misses': 'Runout read 2',
      'turn_river_changes_w5_turn_texture_shift_transfer': 'Runout read 3',
      'turn_river_changes_w5_river_draw_story_transfer': 'Runout read 4',
      'w6_value_dry_board': 'Dry-board read',
      'w6_wrong_board': 'Wet-board bucket 1',
      'w6_value_wet_board': 'Wet-board bucket 2',
      'w6_value_range_action': 'Range line 1',
      'w6_bluff_candidate': 'Range line 2',
      'w6_table_value_line_transfer': 'Range line 3',
      'range_checkpoint_value': 'Range checkpoint 1',
      'range_checkpoint_pressure': 'Range checkpoint 2',
      'w6_kicker_showdown_compare': 'Showdown compare 1',
      'w6_board_pair_strength_compare': 'Showdown compare 2',
      'w7_20bb_wider': 'Depth comparison',
      'w7_6max_wider': 'Table format 1',
      'w7_fullring_tighter': 'Table format 2',
      'w7_format_table_notice': 'Table format 3',
      'w9_m_ratio_green_zone': 'Green-zone decision',
      'w9_m_ratio_yellow_zone': 'Yellow-zone decision',
      'w9_medium_stack_tighten': 'Bubble stack 1',
      'w9_big_stack_leverage': 'Bubble stack 2',
      'w9_bubble_short_stack': 'Bubble stack 3',
      'w9_checkpoint_zone_line': 'Pressure checkpoint 1',
      'w9_checkpoint_bubble_line': 'Pressure checkpoint 2',
      'w10_nit_tag': 'Player profile 1',
      'w10_loose_passive_tag': 'Player profile 2',
      'w10_overaggressive_tag': 'Player profile 3',
      'w10_vs_nit_open_wider': 'Exploit lever 1',
      'w10_vs_caller_value_heavier': 'Exploit lever 2',
      'w10_vs_sticky_defender_tighten_steals': 'Exploit lever 3',
      'w10_table_value_vs_caller_transfer': 'Exploit lever 4',
      'w10_overbluff_punish': 'River adjustment 1',
      'w10_underbluff_fold_more': 'River adjustment 2',
      'w10_guardrail_sample_size': 'Sample read',
      'w10_checkpoint_tag_line': 'Adjustment checkpoint 1',
      'w10_checkpoint_lever_line': 'Adjustment checkpoint 2',
      'w11_plan_focus_choice': 'Session plan 1',
      'w11_plan_avoid_overload': 'Session plan 2',
      'w11_trigger_small_price_continue': 'Trigger spot',
      'w11_review_pick_leak': 'Review step',
      'w11_checkpoint_review_line': 'Closeout step',
      'w12_good_fold_bad_result': 'Result review 1',
      'w12_bad_call_good_result': 'Result review 2',
      'w12_assertive_not_ego': 'Mindset spot 1',
      'w12_pretty_hand_bad_price_fold': 'Mindset spot 2',
      'w12_checkpoint_process_line': 'Bridge checkpoint 1',
      'w12_checkpoint_reset_line': 'Bridge checkpoint 2',
    };

/// Neutral English lesson titles where the authored lesson name states the
/// answer of every assessed step it holds.
const Map<String, String> act0PrechoiceNeutralLessonTitleByIdV1 =
    <String, String>{'fold_discipline': 'Discipline spots'};

/// Neutral English question wording where the authored question gives the
/// answer away. The recap river scene stays and its step becomes an honest
/// table read; "continue" stems no longer name Call against Fold.
const Map<String, String>
act0PrechoiceNeutralQuestionByTaskIdV1 = <String, String>{
  'your_first_hand_recap': 'Which street is on the table now?',
  // "continue" names Call against Fold before the choice.
  'weak_ace_warning_w3_strong_continue': 'What is the simple response?',
  'discipline_checkpoint_checkpoint_borderline_continue':
      'What is the simple response?',
  'continue_or_let_go_continue_recap':
      'What is the cleaner response with this playable hand facing an open?',
};

/// Owner decision (2026-11-08): World 4's authored name 'Bet Purpose / Price'
/// equals the World 4 recap answer 'Purpose and price'. Learners see the
/// neutral display name below; the authored source name, IDs and contracts
/// stay unchanged.
const String act0World4AuthoredTitleV1 = 'Bet Purpose / Price';
const Map<String, String> act0NeutralWorldTitleByIdV1 = <String, String>{
  'world_4': 'Betting Decisions',
};

/// Display copy that embeds the authored World 4 name (unlock labels, module
/// title) shows the neutral name instead.
String act0DisplayWorldNameCopyV1(String text) => text.replaceAll(
  act0World4AuthoredTitleV1,
  act0NeutralWorldTitleByIdV1['world_4']!,
);

/// Known limitation, not a choice-discrimination proof: every assessed answer
/// in these lessons is the same action (all Fold). Kept as authored; it shows
/// recall of discipline, not choosing between different actions.
const Set<String> act0PrechoiceSingleAnswerLessonIdsV1 = <String>{
  'fold_discipline',
};

/// Academy pre-choice summaries whose authored caption states the answer.
const Set<String> act0PrechoiceAnswerBearingSummaryTaskIdsV1 = <String>{
  'what_poker_is_win_ways',
  'cards_ranks_suits_recap',
  // "purpose plus price" restates the recap answer "Purpose and price".
  'w4_checkpoint_review',
  'what_poker_is_showdown_win',
  'your_first_hand_showdown',
  'showdown_best_hand_drill',
  'cards_ranks_suits_board_count',
  'cards_ranks_suits_best_five',
  'cards_ranks_suits_suit_drill',
  'cards_ranks_suits_private_board',
  'your_first_hand_flop',
  'your_first_hand_turn',
  'your_first_hand_river',
  'actions_call_drill',
  'blinds_posts_drill',
  'blinds_postflop_button',
  'showdown_kicker_drill',
  'showdown_board_plays_drill',
  'showdown_tie_drill',
  'button_advantage_button_last',
  'button_advantage_button_vs_cutoff',
  'button_advantage_position_repair_btn_last_postflop',
  'early_vs_late_early_pressure_choice',
  'early_vs_late_position_repair_utg_players_behind',
  'position_checkpoint_position_checkpoint_table_notice',
  'w4_bad_bluff',
  'w4_protection_bet',
  'w4_value_bet',
  'w4_value_missed',
  'w4_bluff_pressure',
  'board_texture_basics_w5_dry_board',
  'board_texture_basics_w5_wet_board',
  'connected_boards_w5_disconnected_board',
  'connected_boards_w5_connected_board',
  'flush_draws_w5_no_flush_draw',
  'straight_draws_w5_gap_board',
  'outs_improvement_w5_flush_out',
  'outs_improvement_w5_straight_out',
  'turn_river_changes_w5_turn_hits',
  'turn_river_changes_w5_river_misses',
  'turn_river_changes_w5_street_repair',
  'turn_river_changes_w5_river_draw_story_transfer',
  'w6_value_range_action',
  'w6_wet_board_repair',
  'w7_20bb_wider',
  'w9_survival_stack_tradeoff',
};

/// Neutral pre-choice summary for answer-bearing captions.
const String act0PrechoiceNeutralSummaryV1 =
    'Read the table and choose before seeing the explanation.';

/// Runner table centre cues that state or verdict the answer before choice.
const Set<String> act0PrechoiceAnswerBearingTableCueTaskIdsV1 = <String>{
  'what_poker_is_showdown_win',
  'your_first_hand_showdown',
  'showdown_best_hand_drill',
  'showdown_review',
  'hand_rankings_full_house_drill',
  'hand_rankings_royal_flush_drill',
  'what_poker_is_side_pot_intro',
  'what_poker_is_all_in_meaning',
  'what_poker_is_matched_chips_transfer',
  'straight_draws_w5_straight_draw_find',
  'straight_draws_w5_gap_board',
  'straight_draws_w5_gutshot_contrast_transfer',
  'flush_draws_w5_no_flush_draw',
  'flush_draws_w5_flush_draw_recheck_transfer',
  'outs_improvement_w5_table_outs_flush_transfer',
  'outs_improvement_w5_table_outs_straight_transfer',
  'w4_good_price_call',
  'w4_bad_price_fold',
  'w4_checkpoint_price',
  'w4_cheap_price_marginal_call',
  'w4_big_price_marginal_fold',
  'w11_trigger_small_price_continue',
  'w12_pretty_hand_bad_price_fold',
  'w12_revenge_raise_trap',
  'w12_checkpoint_full_loop_line',
  'apply_utg_fold',
  'apply_btn_open',
  'position_checkpoint_position_checkpoint_early_fold',
  'continue_or_let_go_medium_open',
  'discipline_checkpoint_checkpoint_borderline_continue',
  'position_checkpoint_position_checkpoint_table_notice',
  'fold_discipline_discipline_stack_protect',
  'fold_discipline_fold_recap',
  'weak_ace_warning_w3_dominated_fold',
  'weak_ace_warning_w3_dominated_recap',
  'apply_recap',
  'discipline_checkpoint_checkpoint_fold',
};

/// Title shown before the current independent decision.
String act0PrechoiceDisplayTitleV1({
  required String taskId,
  required String authoredTitle,
  required bool isAssessment,
  required bool hasSubmittedCurrentDecision,
}) {
  return act0PrechoiceTaskTitleV1(
    taskId: taskId,
    authoredTitle: authoredTitle,
    isAssessment: isAssessment,
    hasSubmittedCurrentDecision: hasSubmittedCurrentDecision,
  );
}

/// Summary shown before the current independent decision.
String act0PrechoiceDisplaySummaryV1({
  required String taskId,
  required String authoredSummary,
  required bool isAssessment,
  required bool hasSubmittedCurrentDecision,
}) {
  final donor = act0PrechoiceTaskSummaryCopyV1(
    taskId: taskId,
    authoredSummary: authoredSummary,
    isAssessment: isAssessment,
    hasSubmittedCurrentDecision: hasSubmittedCurrentDecision,
  );
  if (donor != authoredSummary) return donor;
  if (isAssessment &&
      !hasSubmittedCurrentDecision &&
      act0PrechoiceAnswerBearingSummaryTaskIdsV1.contains(taskId)) {
    return act0PrechoiceNeutralSummaryV1;
  }
  return authoredSummary;
}

/// Current-proof lineage for a changed pre-choice presentation (same rule as
/// the #418 card-focus revision): answers saved while an answer cue was on
/// screen stay historical facts but cannot prove today's neutral read.
const String act0PrechoiceAnswerCueRevisionV1 = 'act0_prechoice_answer_cue_v1';

String? act0PrechoiceAnswerCueSourceRevisionV1(
  Act0LessonTaskV1 task, {
  String? lessonId,
}) {
  if (!act0IsPrechoiceAssessmentTaskV1(task)) return null;
  final id = task.taskId;
  final changed =
      id.startsWith('hand_rankings_') ||
      act0PrechoiceNeutralTitleByTaskIdV1.containsKey(id) ||
      act0PrechoiceAnswerBearingSummaryTaskIdsV1.contains(id) ||
      act0PrechoiceAnswerBearingTableCueTaskIdsV1.contains(id) ||
      act0PrechoiceNeutralQuestionByTaskIdV1.containsKey(id) ||
      act0PrechoiceNeutralLessonTitleByIdV1.containsKey(lessonId);
  return changed ? act0PrechoiceAnswerCueRevisionV1 : null;
}
