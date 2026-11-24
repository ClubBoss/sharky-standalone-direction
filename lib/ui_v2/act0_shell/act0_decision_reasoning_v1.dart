import 'act0_decision_reasoning_b19_v1.dart';
import 'act0_decision_reasoning_w10_w12_v1.dart';
import 'act0_decision_reasoning_w13_w14_v1.dart';
import 'act0_decision_reasoning_w15_w16_v1.dart';
import 'act0_decision_reasoning_w17_w18_v1.dart';
import 'act0_decision_reasoning_w19_w20_v1.dart';
import 'act0_decision_reasoning_w21_w22_v1.dart';
import 'act0_decision_reasoning_w23_w24_v1.dart';
import 'act0_curriculum_pilot_v1.dart';
import 'act0_decision_reasoning_w1_w3_v1.dart';
import 'act0_decision_reasoning_w4_w6_v1.dart';
import 'act0_decision_reasoning_w7_w9_v1.dart';

// Authored reasoning metadata for catalog validation and owner review.
enum Act0DecisionKindV1 { table, process }

enum Act0EdgeMechanismV1 {
  moreValueFromWorse,
  foldsBetter,
  cheaperSameResult,
  priceBeatsEquity,
  equityBelowPrice,
  realizesPosition,
  avoidsDomination,
  deniesEquity,
  keepsWorseIn,
  stackLimitsPayoff,
  riskPremium,
  processRule,
}

enum Act0SuboptimalKindV1 { wrongReason, clearlyWorse }

class Act0DecisionReasoningV1 {
  const Act0DecisionReasoningV1({
    required this.taskId,
    required this.kind,
    required this.principleId,
    required this.bestAlternativeOptionId,
    required this.edgeMechanism,
    this.secondaryPrincipleIds = const [],
    this.edgeBb,
    this.opponentRead,
    this.stackMatters,
    this.stackNote,
    this.preChoiceAssumption,
    this.suboptimalKinds = const {},
  });

  final String taskId;
  final Act0DecisionKindV1 kind;
  final String principleId;
  final List<String> secondaryPrincipleIds;
  final String bestAlternativeOptionId;
  final Act0EdgeMechanismV1 edgeMechanism;
  final double? edgeBb;
  final String? opponentRead;
  final bool? stackMatters;
  final String? stackNote;
  final String? preChoiceAssumption;
  final Map<String, Act0SuboptimalKindV1> suboptimalKinds;
}

/// The first world that introduces each principle.
const act0PrinciplesV1 = <String, int>{
  'value_vs_worse': 1,
  'fold_weak_starting': 2,
  'domination': 2,
  'narrow_3bet': 2,
  'position_realizes': 3,
  'blind_price_defense': 3,
  'folds_better': 4,
  'smallest_size_same_job': 4,
  'deny_equity': 4,
  'price_vs_equity': 4,
  'board_changes_strength': 5,
  'range_vs_board': 6,
  'combos_and_blockers': 6,
  'stack_depth_changes_play': 8,
  'implied_odds': 8,
  'risk_premium': 9,
  'm_zone_shove': 9,
  'one_adjustment': 10,
  'multiway_tighten': 11,
  'process_over_outcome': 12,
  'session_plan': 11,
  'bankroll_rule': 11,
  'tilt_reset': 12,
  if (act0CurriculumPilotEnabledV1) ...{
    "range_advantage": 13,
    "nut_advantage": 13,
    "equity_realization": 13,
    "backdoor_equity": 13,
    "initiative": 13,
    "merged_sizing": 14,
    "polarized_sizing": 14,
    "size_range_signal": 14,
    "spr_commitment": 14,
    "pot_geometry": 14,
    "induce_raise": 14,
    "texture_cbet_frequency": 15,
    "earned_slowplay": 15,
    "flop_texture_coverage": 15,
    "lead_and_stab": 15,
    "flop_raise_shape": 15,
    "barrel_on_range_shift": 16,
    "commitment_by_price": 16,
    "street_value_budget": 16,
    "delayed_attack": 16,
    "pressure_or_price": 16,
    "commitment_recheck": 16,
    "three_bet_jobs": 17,
    "squeeze_with_dead_money": 17,
    "defend_three_bet": 17,
    "four_bet_response": 17,
    "trap_requires_trigger": 17,
    "compressed_postflop": 17,
    "multiway_value_threshold": 18,
    "joint_multiway_folds": 18,
    "multiway_acts_last": 18,
    "eligible_side_pot": 18,
    "reopen_or_enter": 18,
    "multiway_showdown_plan": 18,
    "equilibrium_or_counter": 19,
    "population_by_node": 19,
    "scope_evidence": 19,
    "protect_against_adjustment": 19,
    "evidence_of_cap": 19,
    "audit_your_response": 19,
    "weight_tell_by_context": 20,
    "action_conditioned_read": 20,
    "observable_player_profiles": 20,
    "isolate_with_plan": 20,
    "ethical_metagame": 20,
    "calibrated_action_choice": 20,
    "decision_quality_signals": 21,
    "precommit_stop_conditions": 21,
    "assess_current_edge": 21,
    "compare_simple_line": 21,
    "tag_for_retrieval": 21,
    "session_plan_under_pressure": 21,
    "tree_node_actions": 22,
    "read_payoff_matrix": 22,
    "frequency_and_regret": 22,
    "solver_input_contract": 22,
    "test_heuristic_scope": 22,
    "future_branches_before_bet": 22,
    "position_qualified_chart": 23,
    "classify_playability": 23,
    "price_changes_bb_range": 23,
    "reraises_and_cap": 23,
    "sb_mix_as_model": 23,
    "combine_chart_role_and_model": 23,
    "polar_condensed_interaction": 24,
    "river_thresholds": 24,
    "bluff_share_and_combo_ratio": 24,
    "block_for_river_job": 24,
    "terminal_value_branch": 24,
    "river_raise_terminal": 24,
  },
};

const act0DecisionReasoningV1 = <String, Act0DecisionReasoningV1>{
  ...act0DecisionReasoningW1W3V1,
  ...act0DecisionReasoningW4W6V1,
  ...act0DecisionReasoningW7W9V1,
  ...act0DecisionReasoningW10W12V1,
  if (act0CurriculumPilotEnabledV1) ...{
    ...act0DecisionReasoningW13W14V1,
    ...act0DecisionReasoningW15W16V1,
    ...act0DecisionReasoningW17W18V1,
    ...act0DecisionReasoningW19W20V1,
    ...act0DecisionReasoningW21W22V1,
    ...act0DecisionReasoningW23W24V1,
    ...act0DecisionReasoningB19V1,
  },
};
