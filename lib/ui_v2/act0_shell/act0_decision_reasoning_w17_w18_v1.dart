import 'act0_decision_reasoning_v1.dart';

// Use processRule for stated objectives and models without an exact edge
// mechanism. Only attach a BB edge when both options have a common EV model.
const act0DecisionReasoningW17W18V1 = <String, Act0DecisionReasoningV1>{
  "w17_1_guided_choose_value_job": Act0DecisionReasoningV1(
    taskId: "w17_1_guided_choose_value_job",
    kind: Act0DecisionKindV1.table,
    principleId: "three_bet_jobs",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "CO calls an 8 BB re-raise with the listed pairs and weaker broadways, all behind your kings preflop. Re-raise to collect 5.5 BB more per such call instead of flat-calling 2.5 BB; AA re-raises and needs a separate decision.",
    stackMatters: false,
  ),
  "w17_2_guided_size_oop": Act0DecisionReasoningV1(
    taskId: "w17_2_guided_size_oop",
    kind: Act0DecisionKindV1.table,
    principleId: "squeeze_with_dead_money",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "CO has opened 2.5 BB and would need 8.5 BB more to match an 11 BB re-raise, or 5.5 BB more against 8 BB. With the dead small blind, the larger size charges 37.8% rather than 33.3%. This compares prices, not overall EV or an assumed fold rate.",
    stackMatters: false,
  ),
  "w17_3_transfer_defend_dry_3bet": Act0DecisionReasoningV1(
    taskId: "w17_3_transfer_defend_dry_3bet",
    kind: Act0DecisionKindV1.table,
    principleId: "defend_three_bet",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 6 BB with the stated mixture of overpairs, sets and ace-high hands. Queens have 40.8% equity in this model, above the 18.5% call price. Calling earns a modeled 7.25 BB rather than folding for zero.",
    stackMatters: false,
    edgeBb: 7.25,
  ),
  "w17_3_day7_coverage_still_prices_call": Act0DecisionReasoningV1(
    taskId: "w17_3_day7_coverage_still_prices_call",
    kind: Act0DecisionKindV1.table,
    principleId: "defend_three_bet",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB's 23 BB river range includes straights and strong pairs as well as hands that your pair of jacks beats. Your stated 53.6% equity exceeds the 34.6% price; call rather than fold and give up 12.62 BB of modeled gain.",
    stackMatters: false,
    edgeBb: 12.62,
  ),
  "w17_4_guided_four_bet_bluff_model": Act0DecisionReasoningV1(
    taskId: "w17_4_guided_four_bet_bluff_model",
    kind: Act0DecisionKindV1.table,
    principleId: "four_bet_response",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BTN folds to the 21 BB 4-bet in 13 of 20 equally weighted outcomes and shoves in seven. Winning 12 BB in each fold branch covers losing the new 18.5 BB investment in each shove branch. Four-bet and fold to the shove for 1.325 BB average gain rather than fold now for zero.",
    stackMatters: false,
    edgeBb: 1.325,
  ),
  "w17_4_transfer_short_three_bet_shove": Act0DecisionReasoningV1(
    taskId: "w17_4_transfer_short_three_bet_shove",
    kind: Act0DecisionKindV1.table,
    principleId: "four_bet_response",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB's stated shove range includes stronger aces and missed broadways. Your 40% equity clears the 27% price, so calling 12 BB earns 5.80 BB on average instead of folding for zero.",
    stackMatters: true,
    stackNote:
        "Both players start with 22 BB here. At the matched 100 BB start, the same range shoves 90 BB. The price rises to 44.9%, above your 40% equity, so the call loses value.",
    edgeBb: 5.80,
  ),
  "w17_5_transfer_trap_not_triggered": Act0DecisionReasoningV1(
    taskId: "w17_5_transfer_trap_not_triggered",
    kind: Act0DecisionKindV1.table,
    principleId: "trap_requires_trigger",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "In the stated model BB checks every completion but calls a 3 BB raise with worse holdings. Raise kings to start a 6 BB pot rather than complete for a 2 BB pot with no opportunity to re-raise.",
    stackMatters: false,
  ),
  "w17_6_guided_small_cbet_three_bet": Act0DecisionReasoningV1(
    taskId: "w17_6_guided_small_cbet_three_bet",
    kind: Act0DecisionKindV1.table,
    principleId: "compressed_postflop",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "bet_16",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "CO calls 6 BB with 28 of 31 legal combos but calls 16 BB with only 12, including the sets. The smaller bet retains weaker aces and pairs; it earns 17.13 BB versus 15.42 BB for 16 BB and 14.86 BB for checking in this model.",
    stackMatters: false,
    edgeBb: 1.71,
  ),
  "w17_6_checkpoint_four_bet_shove": Act0DecisionReasoningV1(
    taskId: "w17_6_checkpoint_four_bet_shove",
    kind: Act0DecisionKindV1.table,
    principleId: "compressed_postflop",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB shoves 75 BB with the listed premium pairs and suited ace-king. Your 27.2% equity falls short of the 37.4% price even at low SPR. Fold to avoid the modeled 20.39 BB expected loss of calling.",
    stackMatters: false,
    edgeBb: 20.39,
  ),
  "w17_6_day7_narrow_range_small_call": Act0DecisionReasoningV1(
    taskId: "w17_6_day7_narrow_range_small_call",
    kind: Act0DecisionKindV1.table,
    principleId: "compressed_postflop",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 15 BB with the stated kings, queens and ace-high range. Your aces have 83.2% equity, above the 19.1% price. Call for 50.30 BB of modeled gain rather than fold for zero.",
    stackMatters: false,
    edgeBb: 50.30,
  ),
  "w18_1_guided_check_top_pair": Act0DecisionReasoningV1(
    taskId: "w18_1_guided_check_top_pair",
    kind: Act0DecisionKindV1.table,
    principleId: "multiway_value_threshold",
    bestAlternativeOptionId: "bet",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "At 5 BB, CO calls some worse queens and sets while BB calls only sets. Checking keeps the wider showdown share without paying extra in the set branches: 2.86 BB versus 0.05 BB for betting under the joint-deal model.",
    stackMatters: false,
    edgeBb: 2.81,
  ),
  "w18_1_transfer_set_value_two_callers": Act0DecisionReasoningV1(
    taskId: "w18_1_transfer_set_value_two_callers",
    kind: Act0DecisionKindV1.table,
    principleId: "multiway_value_threshold",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "CO calls 4 BB with overpairs and smaller full houses; BB also pays with weaker nines, smaller full houses and the quads branch. Your full house earns more from those weaker calls than it loses to quads: bet for 11.71 BB versus check for 7.47 BB in the model.",
    stackMatters: false,
    edgeBb: 4.24,
  ),
  "w18_2_guided_joint_folds_price": Act0DecisionReasoningV1(
    taskId: "w18_2_guided_joint_folds_price",
    kind: Act0DecisionKindV1.table,
    principleId: "joint_multiway_folds",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "CO folds in nine of 12 paths, but BB folds in only four of those nine. Joint folds of 33.3% fall below the 42.9% break-even rate for 6 BB into 8 BB. Check for zero rather than bet for an average loss of 1.33 BB.",
    stackMatters: false,
    edgeBb: 1.33,
  ),
  "w18_2_transfer_profitable_joint_bluff": Act0DecisionReasoningV1(
    taskId: "w18_2_transfer_profitable_joint_bluff",
    kind: Act0DecisionKindV1.table,
    principleId: "joint_multiway_folds",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "Both opponents fold in six of ten paths, above the 33.3% joint-fold threshold. Bet 4 BB into 8 BB to earn 3.20 BB on average; checking loses every showdown and earns zero.",
    stackMatters: false,
    edgeBb: 3.20,
  ),
  "w18_2_day7_conditional_fold_count": Act0DecisionReasoningV1(
    taskId: "w18_2_day7_conditional_fold_count",
    kind: Act0DecisionKindV1.table,
    principleId: "joint_multiway_folds",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "CO folds in 12 of 16 events, but BB folds in only six of those 12. The 37.5% joint-fold share falls below the 46.7% threshold. Check for zero rather than bluff 7 BB into 8 BB and lose 1.375 BB on average.",
    stackMatters: false,
    edgeBb: 1.375,
  ),
  "w18_3_guided_check_closes": Act0DecisionReasoningV1(
    taskId: "w18_3_guided_check_closes",
    kind: Act0DecisionKindV1.table,
    principleId: "multiway_acts_last",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.realizesPosition,
    opponentRead:
        "BB and CO have already checked and BTN acts last. Check behind to see the turn without investing another chip, rather than bet 2 BB and give both opponents a chance to respond. Their checks do not establish their holdings.",
    stackMatters: false,
  ),
  "w18_4_transfer_call_only_eligible_pot": Act0DecisionReasoningV1(
    taskId: "w18_4_transfer_call_only_eligible_pot",
    kind: Act0DecisionKindV1.table,
    principleId: "eligible_side_pot",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 15 BB and CO calls with the stated ranges, which include sets as well as weaker queens. Your 19% showdown share clears the 14.3% price for the eligible 35 BB main pot. Call 5 BB for 1.67 BB average gain rather than fold using the deeper price; the 20 BB side pot is not yours to win.",
    stackMatters: true,
    stackNote:
        "With 100 BB instead, calling requires 15 BB to contest all 65 BB. The price becomes 23.1%, above the same showdown share, making the deeper call lose 2.62 BB on average.",
    edgeBb: 1.67,
  ),
  "w18_6_guided_value_on_blank": Act0DecisionReasoningV1(
    taskId: "w18_6_guided_value_on_blank",
    kind: Act0DecisionKindV1.table,
    principleId: "multiway_showdown_plan",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "CO and BB call 5 BB with the stated weaker hands, including two pair and lower sets. Your set of aces wins the modeled showdowns. Bet for 15.97 BB rather than check for 8 BB; both opponents pay in 114 of 192 legal joint deals.",
    stackMatters: false,
    edgeBb: 7.97,
  ),
  "w18_6_checkpoint_two_caller_check": Act0DecisionReasoningV1(
    taskId: "w18_6_checkpoint_two_caller_check",
    kind: Act0DecisionKindV1.table,
    principleId: "multiway_showdown_plan",
    bestAlternativeOptionId: "bet",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "CO and BB have weaker jacks and middle pairs in the original ranges, but their 5 BB call ranges include straights, sets and two pair. Check to preserve showdown value for 1.44 BB on average instead of betting for a modeled loss of 2.54 BB.",
    stackMatters: false,
    edgeBb: 3.98,
  ),
};
