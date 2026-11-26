import 'act0_decision_reasoning_v1.dart';

// Chart exercises and abstention without a specific EV mechanism use
// processRule. Do not infer a range or quantify an edge from chart coverage alone.
const act0DecisionReasoningW23W24V1 = <String, Act0DecisionReasoningV1>{
  "w23_1_read_utg_medium_hj": Act0DecisionReasoningV1(
    taskId: "w23_1_read_utg_medium_hj",
    kind: Act0DecisionKindV1.table,
    principleId: "position_qualified_chart",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "Only the blinds have posted and five players remain to act. Fold AQo rather than open-raise from UTG because the specified mediumHj chart begins at HJ; no opponent-specific range is given.",
    stackMatters: false,
  ),
  "w23_1_guided_hj_opens_medium": Act0DecisionReasoningV1(
    taskId: "w23_1_guided_hj_opens_medium",
    kind: Act0DecisionKindV1.table,
    principleId: "position_qualified_chart",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "UTG has folded, leaving CO, BTN and the blinds to respond. Open-raise AJo rather than fold because HJ is the first opening seat covered for mediumHj.",
    stackMatters: false,
  ),
  "w23_1_transfer_co_opens_sevens": Act0DecisionReasoningV1(
    taskId: "w23_1_transfer_co_opens_sevens",
    kind: Act0DecisionKindV1.table,
    principleId: "position_qualified_chart",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "UTG and HJ have folded; BTN, SB and BB remain to respond. Open-raise sevens rather than fold because CO meets the mediumCo opening threshold in the specified chart.",
    stackMatters: false,
  ),
  "w23_1_day7_btn_medium_queen": Act0DecisionReasoningV1(
    taskId: "w23_1_day7_btn_medium_queen",
    kind: Act0DecisionKindV1.table,
    principleId: "position_qualified_chart",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "UTG, HJ and CO have folded, so only the blinds can respond. Open-raise QJo rather than fold because BTN is later than the mediumCo chart threshold.",
    stackMatters: false,
  ),
  "w23_3_day7_different_prices_different_calls": Act0DecisionReasoningV1(
    taskId: "w23_3_day7_different_prices_different_calls",
    kind: Act0DecisionKindV1.table,
    principleId: "price_changes_bb_range",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BTN opens to 3 BB and SB folds. The fixed 27% terminal winning share misses the 30.8% price, so fold rather than call and lose 0.245 BB. At the modeled 2 BB open, calling instead gains 0.215 BB.",
    stackMatters: false,
  ),
  "w23_4_transfer_five_bet_price_flips": Act0DecisionReasoningV1(
    taskId: "w23_4_transfer_five_bet_price_flips",
    kind: Act0DecisionKindV1.table,
    principleId: "reraises_and_cap",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BTN shoves the stated AA, KK and AKo range. Jacks have 37.8% equity, clearing the 18.2% price for the remaining 13 BB, so call rather than fold because of chips already invested.",
    stackMatters: true,
    stackNote:
        "Both players start with 35 BB; the matched 100 BB shove instead costs 78 BB after the same 22 BB contribution, requiring about 38.7% equity and making a call unprofitable.",
  ),
  "w23_4_day7_four_bet_value_response": Act0DecisionReasoningV1(
    taskId: "w23_4_day7_four_bet_value_response",
    kind: Act0DecisionKindV1.table,
    principleId: "reraises_and_cap",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BTN has raised to 8 BB and matches a 21 BB 4-bet with the stated KK, QQ and AKo hands. Raise aces rather than flat call to collect 13 BB more from each named weaker hand; no future calls are guaranteed.",
    stackMatters: false,
  ),
  "w23_6_day7_choose_chart_only_matching_line": Act0DecisionReasoningV1(
    taskId: "w23_6_day7_choose_chart_only_matching_line",
    kind: Act0DecisionKindV1.table,
    principleId: "combine_chart_role_and_model",
    bestAlternativeOptionId: "other",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "CO has opened to 2.5 BB without limpers and the blinds have yet to act. Call QJs rather than fold using the unrelated UTG opening row because the specified BTN-versus-CO chart covers this call.",
    stackMatters: false,
  ),
  "w24_1_guided_condensed_bluff_catcher": Act0DecisionReasoningV1(
    taskId: "w24_1_guided_condensed_bluff_catcher",
    kind: Act0DecisionKindV1.table,
    principleId: "polar_condensed_interaction",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 8 BB with seven legal value combinations and eight missed combinations in the supplied range. A-Q wins against the misses, so call at 53.3% equity versus a 29.1% price instead of folding for zero EV.",
    stackMatters: false,
    edgeBb: 6.66667,
  ),
  "w24_1_transfer_keep_middle_check": Act0DecisionReasoningV1(
    taskId: "w24_1_transfer_keep_middle_check",
    kind: Act0DecisionKindV1.table,
    principleId: "polar_condensed_interaction",
    bestAlternativeOptionId: "bet_2",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB calls 2 BB with 26 of 35 combinations, of which only eight lose to K-J. Check to realize the existing showdown share: 2.67 BB modeled EV versus 2.10 BB for the small bet. The 7 BB bet retains only better callers.",
    stackMatters: false,
  ),
  "w24_2_transfer_bluff_threshold_overpot": Act0DecisionReasoningV1(
    taskId: "w24_2_transfer_bluff_threshold_overpot",
    kind: Act0DecisionKindV1.table,
    principleId: "river_thresholds",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB folds five of ten times, below the 54.9% break-even fold share for 14 BB into 11.5 BB. Check for zero EV rather than bet and lose 1.25 BB on average.",
    stackMatters: false,
    edgeBb: 1.25,
  ),
  "w24_2_day7_call_price_vs_range_mdf": Act0DecisionReasoningV1(
    taskId: "w24_2_day7_call_price_vs_range_mdf",
    kind: Act0DecisionKindV1.table,
    principleId: "river_thresholds",
    secondaryPrincipleIds: ["price_vs_equity"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB bets 15 BB into 20.5 BB with two bluffs in ten modeled events. Fold because this hand has only 20% equity against a 29.7% call price; calling based on MDF loses 4.90 BB on average.",
    stackMatters: false,
    edgeBb: 4.9,
  ),
  "w24_3_transfer_indifferent_range_blocks": Act0DecisionReasoningV1(
    taskId: "w24_3_transfer_indifferent_range_blocks",
    kind: Act0DecisionKindV1.table,
    principleId: "bluff_share_and_combo_ratio",
    secondaryPrincipleIds: ["combos_and_blockers", "price_vs_equity"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB bets pot, but the blockers remove two of the four modeled bluff units and no value units. Fold because the remaining 20% winning share is below a one-third price; calling based on the unfiltered ratio loses 2.20 BB.",
    stackMatters: false,
    edgeBb: 2.2,
  ),
  "w24_4_guided_overbet_collect_nut_value": Act0DecisionReasoningV1(
    taskId: "w24_4_guided_overbet_collect_nut_value",
    kind: Act0DecisionKindV1.table,
    principleId: "block_for_river_job",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "bet_3",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls 3 BB with all 23 legal combinations and 9 BB with 11, all beaten by your nut flush. Bet 9 BB: the average extra payment is 99/23 BB versus 3 BB at the smaller size.",
    stackMatters: false,
    edgeBb: 1.30435,
  ),
  "w24_4_transfer_effective_price_river": Act0DecisionReasoningV1(
    taskId: "w24_4_transfer_effective_price_river",
    kind: Act0DecisionKindV1.table,
    principleId: "block_for_river_job",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB shoves 9 BB with the supplied 24 legal combinations. A-J has 25% equity and the call needs only 20.2%, so call for a modeled 2.125 BB gain rather than fold.",
    stackMatters: true,
    stackNote:
        "Both players start with 22 BB. The matched 100 BB starting-stack case makes the 87 BB shove require 43.4% equity against the same range, turning the call into a loss.",
    edgeBb: 2.125,
  ),
  "w24_5_guided_thin_value_raise": Act0DecisionReasoningV1(
    taskId: "w24_5_guided_thin_value_raise",
    kind: Act0DecisionKindV1.table,
    principleId: "terminal_value_branch",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "raise_11",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls the 6 BB raise with 18 worse queens and six sets. Raise to 6 BB for modeled EV of 7.18 BB rather than 11 BB for 6.11 BB, since the larger raise loses Q-J and Q-T calls.",
    stackMatters: false,
  ),
  "w24_5_transfer_thin_raise_becomes_call": Act0DecisionReasoningV1(
    taskId: "w24_5_transfer_thin_raise_becomes_call",
    kind: Act0DecisionKindV1.table,
    principleId: "terminal_value_branch",
    bestAlternativeOptionId: "raise_6",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BB bets misses and weaker kings but calls the 6 BB raise with 14 better combinations and just two worse kings. Call 2 BB for 2.38 BB modeled EV rather than raise to 6 BB for 0.54 BB; larger raises lose all worse calls.",
    stackMatters: false,
  ),
  "w24_5_day7_check_marginal_showdown": Act0DecisionReasoningV1(
    taskId: "w24_5_day7_check_marginal_showdown",
    kind: Act0DecisionKindV1.table,
    principleId: "terminal_value_branch",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB checks and calls either bet only with stronger holdings, while every weaker holding folds. Check K-T rather than bet small: no river card remains to deny, and betting only adds losses against better hands.",
    stackMatters: false,
  ),
  "w24_6_guided_raise_blocker_bluff": Act0DecisionReasoningV1(
    taskId: "w24_6_guided_raise_blocker_bluff",
    kind: Act0DecisionKindV1.table,
    principleId: "river_raise_terminal",
    secondaryPrincipleIds: ["block_for_river_job", "folds_better"],
    bestAlternativeOptionId: "raise_24",
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    opponentRead:
        "BTN folds 15 of 24 combinations and calls the same nine better hands at either raise size. With 15.5 BB available to win, raise to 13 BB rather than 24 BB for the same folds and 11 BB less risk when called.",
    stackMatters: false,
    edgeBb: 4.125,
  ),
  "w24_6_checkpoint_value_check_raise": Act0DecisionReasoningV1(
    taskId: "w24_6_checkpoint_value_check_raise",
    kind: Act0DecisionKindV1.table,
    principleId: "river_raise_terminal",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "raise_18",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BTN calls 12 BB with 14 combinations including worse aces and lower sets, but calls 18 BB with only six lower-set combinations. Check-raise top set to 12 BB rather than 18 BB: 20.59 BB modeled EV exceeds 19.32 BB.",
    stackMatters: false,
  ),
  "w24_6_day7_no_bluff_without_folds": Act0DecisionReasoningV1(
    taskId: "w24_6_day7_no_bluff_without_folds",
    kind: Act0DecisionKindV1.table,
    principleId: "river_raise_terminal",
    secondaryPrincipleIds: ["combos_and_blockers"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BTN bets 8 BB with made flushes only and never folds to either raise. Your single heart blocks some flushes but makes no flush, so fold instead of calling and losing 8 BB or bluffing without fold equity.",
    stackMatters: false,
    edgeBb: 8,
  ),
};
