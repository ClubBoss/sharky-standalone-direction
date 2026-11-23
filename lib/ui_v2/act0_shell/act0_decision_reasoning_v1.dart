import 'act0_decision_reasoning_w10_w12_v1.dart';
import 'act0_decision_reasoning_w13_w14_v1.dart';
import 'act0_decision_reasoning_w15_w16_v1.dart';
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
  },
};

const act0DecisionReasoningV1 = <String, Act0DecisionReasoningV1>{
  ...act0DecisionReasoningW1W3V1,
  ...act0DecisionReasoningW4W6V1,
  ...act0DecisionReasoningW7W9V1,
  ...act0DecisionReasoningW10W12V1,
  if (act0CurriculumPilotEnabledV1) ...act0DecisionReasoningW13W14V1,
  if (act0CurriculumPilotEnabledV1) ...act0DecisionReasoningW15W16V1,
};
