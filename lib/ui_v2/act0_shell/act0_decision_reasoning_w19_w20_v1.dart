import 'act0_decision_reasoning_v1.dart';

// Use processRule for evidence-based bluff abstention and stated objectives
// without an exact edge-mechanism enum. Leave edgeBb unset without a common
// payoff model for both options.
const act0DecisionReasoningW19W20V1 = <String, Act0DecisionReasoningV1>{
  "w19_1_day7_counter_changes_with_strategy": Act0DecisionReasoningV1(
    taskId: "w19_1_day7_counter_changes_with_strategy",
    kind: Act0DecisionKindV1.table,
    principleId: "equilibrium_or_counter",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "With the same 5 BB price, A adds enough misses to make a call profitable, while B bets no hands you beat. Call A and fold B rather than calling both and losing the call against B.",
    stackMatters: false,
  ),
  "w19_1_guided_respond_to_extra_bluffs": Act0DecisionReasoningV1(
    taskId: "w19_1_guided_respond_to_extra_bluffs",
    kind: Act0DecisionKindV1.table,
    principleId: "equilibrium_or_counter",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 16 missed combinations and six sets in the stated range. A-T wins often enough to call 5 BB at a 32.3% price; folding forfeits the positive call EV.",
    stackMatters: false,
    edgeBb: 6.27273,
  ),
  "w19_1_read_information_value": Act0DecisionReasoningV1(
    taskId: "w19_1_read_information_value",
    kind: Act0DecisionKindV1.table,
    principleId: "equilibrium_or_counter",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "The two hypothetical BB holdings use the same 4 BB river bet. An oracle can call the missed K-J and fold to the set of nines; calling both loses chips in the set branch. In real play the bet does not reveal which holding is present.",
    stackMatters: false,
  ),
  "w19_2_day7_pool_overbluffs_size": Act0DecisionReasoningV1(
    taskId: "w19_2_day7_pool_overbluffs_size",
    kind: Act0DecisionKindV1.table,
    principleId: "population_by_node",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB's modeled 8 BB range has 22 combinations A-J beats and six sets. The 78.6% equity exceeds the 30.2% price, so calling earns more than folding.",
    stackMatters: false,
    edgeBb: 12.82143,
  ),
  "w19_2_guided_bluff_pool_overfold": Act0DecisionReasoningV1(
    taskId: "w19_2_guided_bluff_pool_overfold",
    kind: Act0DecisionKindV1.table,
    principleId: "population_by_node",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB folds in 15 of 20 matched responses, above the 56% break-even fold share for 7 BB into 5.5 BB. Betting makes 2.38 BB on average versus zero for checking.",
    stackMatters: false,
    edgeBb: 2.375,
  ),
  "w19_2_transfer_pool_underfold": Act0DecisionReasoningV1(
    taskId: "w19_2_transfer_pool_underfold",
    kind: Act0DecisionKindV1.table,
    principleId: "population_by_node",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB folds only six of 20 matched responses, below the 52.2% pure-bluff threshold for 6 BB. Check for zero EV rather than losing 2.55 BB on average by betting.",
    stackMatters: false,
    edgeBb: 2.55,
  ),
  "w19_4_guided_adaptation_before": Act0DecisionReasoningV1(
    taskId: "w19_4_guided_adaptation_before",
    kind: Act0DecisionKindV1.table,
    principleId: "protect_against_adjustment",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB folds in ten of 15 matched cases, above the 47.6% threshold for the 5 BB bluff. Bet for 2 BB average gain instead of checking for zero, while this response persists.",
    stackMatters: false,
    edgeBb: 2,
  ),
  "w19_4_read_predictable_single_size": Act0DecisionReasoningV1(
    taskId: "w19_4_read_predictable_single_size",
    kind: Act0DecisionKindV1.table,
    principleId: "protect_against_adjustment",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "In the stipulated model BB knows your largest river size contains only missed draws and holds a hand beating all of them. From BB's perspective calling wins every time; folding more often gives up profitable terminal calls.",
    stackMatters: false,
  ),
  "w19_4_transfer_adaptation_after": Act0DecisionReasoningV1(
    taskId: "w19_4_transfer_adaptation_after",
    kind: Act0DecisionKindV1.table,
    principleId: "protect_against_adjustment",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB now folds only four of 15 matched cases, below the 47.6% threshold. Check for zero EV rather than repeat the 5 BB bluff that now loses 2.20 BB on average.",
    stackMatters: false,
    edgeBb: 2.2,
  ),
  "w19_5_guided_attack_a_proven_cap": Act0DecisionReasoningV1(
    taskId: "w19_5_guided_attack_a_proven_cap",
    kind: Act0DecisionKindV1.table,
    principleId: "evidence_of_cap",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB calls all 37 legal combinations for 2 BB, but only ten for 7 BB, including full houses. The larger bluff wins enough folds to earn 2.12 BB versus zero for checking with no showdown equity.",
    stackMatters: false,
    edgeBb: 2.12162,
  ),
  "w19_6_checkpoint_which_data_controls": Act0DecisionReasoningV1(
    taskId: "w19_6_checkpoint_which_data_controls",
    kind: Act0DecisionKindV1.table,
    principleId: "audit_your_response",
    secondaryPrincipleIds: ["scope_evidence"],
    bestAlternativeOptionId: "other",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB folds in 14 of 20 matched responses to the proposed size. The 60-event pooled report does not identify that response rate. Bet 6 BB for a modeled 4.15 BB gain rather than check based on the pooled report.",
    stackMatters: false,
    edgeBb: 4.15,
  ),
  "w19_6_guided_depth_changes_counter": Act0DecisionReasoningV1(
    taskId: "w19_6_guided_depth_changes_counter",
    kind: Act0DecisionKindV1.table,
    principleId: "audit_your_response",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB shoves the same modeled range at either depth: seven of 19 legal combinations lose to A-J. Call 12 BB because 36.8% equity clears the 27.0% price, unlike folding for zero EV.",
    stackMatters: true,
    stackNote:
        "Both players start with 22 BB here. At the matched 100 BB start the 90 BB shove raises the price to 44.9% with the same range, making a call lose value.",
    edgeBb: 4.39474,
  ),
  "w20_2_day7_unfamiliar_size_fold": Act0DecisionReasoningV1(
    taskId: "w20_2_day7_unfamiliar_size_fold",
    kind: Act0DecisionKindV1.table,
    principleId: "action_conditioned_read",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB's stated 12 BB betting range contains only three of 21 legal combinations Q-J beats. The 14.3% equity is below the 33.8% price; fold rather than lose 6.93 BB on the average call.",
    stackMatters: false,
    edgeBb: 6.92857,
  ),
  "w20_2_guided_value_heavy_size": Act0DecisionReasoningV1(
    taskId: "w20_2_guided_value_heavy_size",
    kind: Act0DecisionKindV1.table,
    principleId: "action_conditioned_read",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB's stated 8 BB range contains many sets and two pair; A-Q beats only two of 17 legal combinations. Fold at the 31.4% price because 11.8% equity is insufficient, saving 5 BB of expected loss versus calling.",
    stackMatters: false,
    edgeBb: 5,
  ),
  "w20_2_transfer_large_size_polar": Act0DecisionReasoningV1(
    taskId: "w20_2_transfer_large_size_polar",
    kind: Act0DecisionKindV1.table,
    principleId: "action_conditioned_read",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB's 9 BB range includes six sets and 12 missed combinations. A-J's 66.7% equity clears the 30.5% price, so call rather than fold based on the large size alone.",
    stackMatters: false,
    edgeBb: 10.66667,
  ),
  "w20_3_guided_raise_larger_inelastic": Act0DecisionReasoningV1(
    taskId: "w20_3_guided_raise_larger_inelastic",
    kind: Act0DecisionKindV1.table,
    principleId: "observable_player_profiles",
    bestAlternativeOptionId: "bet_3",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls the same 14 of 26 legal combinations at either size and your set of aces beats them all. Bet 8 BB instead of 3 BB to collect five more BB on each call.",
    stackMatters: false,
    edgeBb: 2.69231,
  ),
  "w20_4_day7_value_adjust_to_sticky": Act0DecisionReasoningV1(
    taskId: "w20_4_day7_value_adjust_to_sticky",
    kind: Act0DecisionKindV1.table,
    principleId: "isolate_with_plan",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls every listed combination at both raise sizes and never re-raises. K-Q beats 16 of 22 combinations and loses to six sets. Raise to 12 BB instead of 7 BB because extra payments from worse kings outweigh extra losses.",
    stackMatters: false,
    edgeBb: 2.27273,
  ),
  "w20_4_guided_isolation_two_sizes": Act0DecisionReasoningV1(
    taskId: "w20_4_guided_isolation_two_sizes",
    kind: Act0DecisionKindV1.table,
    principleId: "isolate_with_plan",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "HJ and CO have limped. In the stated response paths the 6 BB raise leaves CO as sole caller seven of ten times, versus three of ten at 4 BB. Choose 6 BB for the isolation objective; this does not establish higher overall EV.",
    stackMatters: false,
  ),
  "w20_4_transfer_skip_marginal_isolation": Act0DecisionReasoningV1(
    taskId: "w20_4_transfer_skip_marginal_isolation",
    kind: Act0DecisionKindV1.table,
    principleId: "isolate_with_plan",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "HJ, CO, BTN and SB have matched your blind, and CO and BTN have repeatedly re-raised loose isolation attempts. Check to close preflop for no extra chips rather than raise and invite that response.",
    stackMatters: false,
  ),
  "w20_6_checkpoint_filter_then_call": Act0DecisionReasoningV1(
    taskId: "w20_6_checkpoint_filter_then_call",
    kind: Act0DecisionKindV1.table,
    principleId: "calibrated_action_choice",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 8 BB with nine sets and 12 combinations your A-Q beats in the stated model. Call because 57.1% equity exceeds the 29.1% price; folding gives up a modeled 7.71 BB.",
    stackMatters: false,
    edgeBb: 7.71429,
  ),
  "w20_6_day7_late_sizing_update": Act0DecisionReasoningV1(
    taskId: "w20_6_day7_late_sizing_update",
    kind: Act0DecisionKindV1.table,
    principleId: "calibrated_action_choice",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB's stated 8 BB range contains 18 legal combinations that beat K-J and only four that lose. Fold because 18.2% equity falls short of the 29.1% price; calling loses 3 BB on average.",
    stackMatters: false,
    edgeBb: 3,
  ),
  "w20_6_guided_short_price_with_read": Act0DecisionReasoningV1(
    taskId: "w20_6_guided_short_price_with_read",
    kind: Act0DecisionKindV1.table,
    principleId: "calibrated_action_choice",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB shoves the same modeled range at both depths. Q-J beats six of 18 legal combinations; call 12 BB because 33.3% equity clears the 27.0% price, rather than fold for zero EV.",
    stackMatters: true,
    stackNote:
        "Both players start with 22 BB here. With the matched 100 BB start the 90 BB shove needs 44.9% equity against the same range, so the call is no longer profitable.",
    edgeBb: 2.83333,
  ),
};
