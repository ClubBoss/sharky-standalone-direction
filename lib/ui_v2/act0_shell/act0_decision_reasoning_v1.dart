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
};

const act0DecisionReasoningV1 = <String, Act0DecisionReasoningV1>{
  ...act0DecisionReasoningW1W3V1,
  ...act0DecisionReasoningW4W6V1,
  ...act0DecisionReasoningW7W9V1,
};
