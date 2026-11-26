import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningW13W14V1 = <String, Act0DecisionReasoningV1>{
  "w13_1_guided_top_pair_value": Act0DecisionReasoningV1(
    taskId: "w13_1_guided_top_pair_value",
    kind: Act0DecisionKindV1.table,
    principleId: "range_advantage",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check can include sets and weaker pairs. The stated call group includes K-Q, Q-J, Q-T, J-J and T-T as well as sets.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a uniformly weighted combo from KQs QJs QTs 77 22 JJ TT 98s 65s. Against the listed bet, BB calls only KQs QJs QTs 77 22 JJ TT and folds all other groups. After a check or a call, both check through with no further bets.",
    edgeBb: 0.87958,
  ),
  "w13_1_transfer_high_board_check": Act0DecisionReasoningV1(
    taskId: "w13_1_transfer_high_board_check",
    kind: Act0DecisionKindV1.table,
    principleId: "range_advantage",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check keeps weaker kings, sets and low draws in the full range. K-J and K-T call 2 BB and fold to 6 BB under the stated model.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a uniformly weighted combo from KQs KJs KTs 88 33 99 76s 54s. Against 2 BB, BB calls KQs KJs KTs 88 33. Against 6 BB, BB calls KQs 88 33. BB folds all other groups to each size. After a check or a call, both check through with no further bets.",
    edgeBb: 0.1438,
  ),
  "w13_2_guided_top_straight_size": Act0DecisionReasoningV1(
    taskId: "w13_2_guided_top_straight_size",
    kind: Act0DecisionKindV1.table,
    principleId: "nut_advantage",
    bestAlternativeOptionId: "bet_3",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB checks a mix of lower straights, sets, two pair and weaker made hands. The stated lower straights, sets and T-9 call both tested sizes.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a uniformly weighted combo from J7s 76s TT 99 88 T9s A9s K8s Q7s 55. Against either listed size, BB calls only J7s 76s TT 99 88 T9s and folds all other groups. After a check or a call, both check through with no further bets.",
    edgeBb: 1.22032,
  ),
  "w13_2_transfer_second_straight": Act0DecisionReasoningV1(
    taskId: "w13_2_transfer_second_straight",
    kind: Act0DecisionKindV1.table,
    principleId: "nut_advantage",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "The BB turn bet includes Q-T for the nut straight plus lower hands and equal straights. Treat the groups as explicit possibilities.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 3 BB with a uniformly weighted combo from QTs QTo TT 99 88 76s. Compare call with fold in this exercise. If you call, there is no more betting.",
    edgeBb: 1.1046,
  ),
  "w13_3_guided_flush_draw_turn": Act0DecisionReasoningV1(
    taskId: "w13_3_guided_flush_draw_turn",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "The BB lead can come from kings, sets and the stated suited draws and weaker hands. No one hand is assigned to BB.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 2 BB with a uniformly weighted combo from KQs KQo KJs 99 66 QJs JTs 87s. Compare call with fold in this exercise. If you call, there is no more betting.",
    edgeBb: 2.30329,
  ),
  "w13_3_transfer_pair_against_value": Act0DecisionReasoningV1(
    taskId: "w13_3_transfer_pair_against_value",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "The BB turn bet is weighted toward stronger queens and sets in the stated model, with some A-J and J-T still possible.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 4 BB with a uniformly weighted combo from AQs AQo KQs KQo 99 66 AJs JTs. Compare call with fold in this exercise. If you call, there is no more betting.",
    edgeBb: 0.94278,
  ),
  "w13_3_day7_river_pair_against_range": Act0DecisionReasoningV1(
    taskId: "w13_3_day7_river_pair_against_range",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB’s river lead can include stronger kings and two pair, but the model also retains missed and weaker hands.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 3 BB with a uniformly weighted combo from KQs KQo KTs 77 T9s QJs J9s. Compare call with fold in this exercise. If you call, there is no more betting.",
    edgeBb: 1.70455,
  ),
  "w13_4_guided_payment_tree": Act0DecisionReasoningV1(
    taskId: "w13_4_guided_payment_tree",
    kind: Act0DecisionKindV1.table,
    principleId: "equity_realization",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.realizesPosition,
    opponentRead:
        "BTN’s turn bet includes ace pairs, sets and draws. Its stated river bet on non-hearts is made with every surviving combination.",
    stackMatters: false,
    preChoiceAssumption:
        "BTN bets 2 BB with AKo AQs A9s ATs TT 66 QJs J9s 98s, equal weight by legal combo. If you call, use this river rule. On a heart river you both check. On any other river, BB checks and BTN bets 20 BB with every combo still possible. BB can call or fold on the river.",
    edgeBb: 1.73864,
  ),
  "w13_4_transfer_short_stack_flip": Act0DecisionReasoningV1(
    taskId: "w13_4_transfer_short_stack_flip",
    kind: Act0DecisionKindV1.table,
    principleId: "equity_realization",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    opponentRead:
        "BTN’s bet includes queens, sets and weaker holdings from the given list. At this depth, BTN cannot charge BB on the river after a call.",
    stackMatters: true,
    preChoiceAssumption:
        "BTN bets 6 BB with KQs KQo QJs 88 33 AKo KJs JTs 76s, equal weight by legal combo. You have only 6 BB behind. If you call, there are no further bets. For the 100 BB comparison only, apply this river rule. On a heart river you both check. On any other river, BB checks and BTN bets 40 BB with every combo still possible. BB can call or fold on the river.",
    edgeBb: 1.23048,
    stackNote:
        "At 100 BB the BTN’s river option lowers turn call EV to -0.73 BB, so BB folds. With 6 BB left, calling ends the betting and earns 1.23 BB.",
  ),
  "w13_4_day7_check_behind_midpair": Act0DecisionReasoningV1(
    taskId: "w13_4_day7_check_behind_midpair",
    kind: Act0DecisionKindV1.table,
    principleId: "equity_realization",
    bestAlternativeOptionId: "bet_3",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BB checks the turn with the stated mix. The 3 BB bet filters out weaker holdings and is called by kings and sets only.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a uniformly weighted combo from KQs KQo KJs 88 44 TT 99 76s 65s. Against the listed bet, BB calls only KQs KQo KJs 88 44 and folds all other groups. After a check or a call, both check through with no further bets.",
    edgeBb: 1.14545,
  ),
  "w13_5_guided_pair_plus_backdoor": Act0DecisionReasoningV1(
    taskId: "w13_5_guided_pair_plus_backdoor",
    kind: Act0DecisionKindV1.table,
    principleId: "backdoor_equity",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB’s small lead includes worse queens and unpaired holdings as well as sets. Your top pair and backdoor both enter the full equity count.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 2 BB with a uniformly weighted combo from KQs KQo QJs 99 44 AJs KJs JTs T8s. Compare call with fold in this exercise. If you call, there is no more betting.",
    edgeBb: 4.23521,
  ),
  "w13_5_transfer_backdoor_not_a_call": Act0DecisionReasoningV1(
    taskId: "w13_5_transfer_backdoor_not_a_call",
    kind: Act0DecisionKindV1.table,
    principleId: "backdoor_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "The BB bet includes kings, sets and two pair. An ace or a runner-runner flush can win against some combinations, not all.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 3 BB with a uniformly weighted combo from AKs AKo KQs KQo 99 33 K9s. Compare call with fold in this exercise. If you call, there is no more betting.",
    edgeBb: 1.98098,
  ),
  "w13_6_guided_small_cbet": Act0DecisionReasoningV1(
    taskId: "w13_6_guided_small_cbet",
    kind: Act0DecisionKindV1.table,
    principleId: "initiative",
    bestAlternativeOptionId: "bet_2",
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    opponentRead:
        "After the BB check, air and the pocket sevens and fives fold to both sizes. K-Q, K-J and sets continue with the same frequency.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a uniformly weighted combo from KQs KJs 88 33 QTs JTs 76s 65s 77 55. Against either listed size, BB calls only KQs KJs 88 33 and folds all other groups. After a check or a call, both check through with no further bets.",
    edgeBb: 0.23089,
  ),
  "w13_6_checkpoint_connected_flop": Act0DecisionReasoningV1(
    taskId: "w13_6_checkpoint_connected_flop",
    kind: Act0DecisionKindV1.table,
    principleId: "initiative",
    bestAlternativeOptionId: "bet_4",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BTN called in position and can hold the Q-9 nut straight, other straights and sets. The modeled 4 BB bet loses the lowest pair group and keeps the stronger parts.",
    stackMatters: false,
    preChoiceAssumption:
        "BTN holds a uniformly weighted combo from Q9s 97s JJ TT 88 JTs AJs KJs QJs 55. Against the listed bet, BTN calls only Q9s 97s JJ TT 88 JTs AJs KJs QJs and folds all other groups. After a check or a call, both check through with no further bets.",
    edgeBb: 0.73486,
  ),
  "w13_6_day7_cbet_for_value": Act0DecisionReasoningV1(
    taskId: "w13_6_day7_cbet_for_value",
    kind: Act0DecisionKindV1.table,
    principleId: "initiative",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check keeps worse queens and strong sets in the range. The stated calling group contains both.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a uniformly weighted combo from KQs KQo QJs QTs 77 33 88 76s 65s. Against the listed bet, BB calls only KQs KQo QJs QTs 77 33 and folds all other groups. After a check or a call, both check through with no further bets.",
    edgeBb: 0.63315,
  ),
  "w14_1_read_underbet": Act0DecisionReasoningV1(
    taskId: "w14_1_read_underbet",
    kind: Act0DecisionKindV1.table,
    principleId: "merged_sizing",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "The current flop pot is 5.5 BB. Classify each proposed amount as below, equal to or above the pot.",
  ),
  "w14_1_guided_smaller_gets_paid": Act0DecisionReasoningV1(
    taskId: "w14_1_guided_smaller_gets_paid",
    kind: Act0DecisionKindV1.table,
    principleId: "merged_sizing",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check allows both weaker queens and sets. The model keeps more middling hands in at 2 BB.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is KQs KQo QJs QTs 77 22 99 88 AJs T9s, with equal weight per legal combo. Against 2 BB, BB calls with KQs KQo QJs QTs 77 22 99 88. The other hands fold. Against 6 BB, BB calls with 77 22. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 0.75536,
    suboptimalKinds: {
      "check": Act0SuboptimalKindV1.clearlyWorse,
      "bet_6": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "w14_1_transfer_medium_showdown": Act0DecisionReasoningV1(
    taskId: "w14_1_transfer_medium_showdown",
    kind: Act0DecisionKindV1.table,
    principleId: "merged_sizing",
    bestAlternativeOptionId: "bet_1.5",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BB retains underpairs and missed suited hands after checking. Sevens and three diamond draws pay 1.5 BB. Both sizes keep the aces and sets.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is AQs AJo ATo 99 55 77 66 QcJc QdJd QhJh QsJs KcJc KdJd KhJh KsJs 8c7c 8d7d 8h7h 8s7s, with equal weight per legal combo. Against 1.5 BB, BB calls with AQs AJo ATo 99 55 77 QdJd KdJd 8d7d. The other hands fold. Against 5 BB, BB calls with AQs AJo ATo 99 55. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 0.47310,
  ),
  "w14_1_day7_keep_weaker_pairs": Act0DecisionReasoningV1(
    taskId: "w14_1_day7_keep_weaker_pairs",
    kind: Act0DecisionKindV1.table,
    principleId: "merged_sizing",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls 2 BB with worse jacks, lower pairs and sets. Against 7 BB only the sets call.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is QJs QJo JTs J9s 88 55 77 66 A9s T9s, with equal weight per legal combo. Against 2 BB, BB calls with QJs QJo JTs J9s 88 55 77 66. The other hands fold. Against 7 BB, BB calls with 88 55. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 0.94737,
    suboptimalKinds: {"check": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w14_2_guided_make_better_fold": Act0DecisionReasoningV1(
    taskId: "w14_2_guided_make_better_fold",
    kind: Act0DecisionKindV1.table,
    principleId: "polarized_sizing",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB’s small-size caller group contains more kings and several pocket pairs that fold to 6 BB.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is KQs KJs KTs 99 77 88 66 55 54s 65s, with equal weight per legal combo. This BB has shown a willingness to fold some one-pair hands to large river bets. In this model KJs KTs 88 66 55 call 2 BB and fold to 6 BB. Against 2 BB, BB calls with KQs KJs KTs 99 77 88 66 55. The other hands fold. Against 6 BB, BB calls with KQs 99 77. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 1.95,
  ),
  "w14_2_transfer_nut_value": Act0DecisionReasoningV1(
    taskId: "w14_2_transfer_nut_value",
    kind: Act0DecisionKindV1.table,
    principleId: "polarized_sizing",
    bestAlternativeOptionId: "bet_3",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB checks two pair, sets and one pair in this model. The 8 BB size keeps sets and the stronger two-pair groups.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is J9s J8s JTs 88 33 TT AJo QJs, with equal weight per legal combo. Against 3 BB, BB calls with J9s J8s JTs 88 33 TT AJo QJs. The other hands fold. Against 8 BB, BB calls with J8s JTs 88 33 TT. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 1.30769,
    suboptimalKinds: {"bet_3": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w14_2_day7_size_for_bluff": Act0DecisionReasoningV1(
    taskId: "w14_2_day7_size_for_bluff",
    kind: Act0DecisionKindV1.table,
    principleId: "polarized_sizing",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "The 7 BB calls are limited to the stated strong group. At 2 BB the middle pairs also continue.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is AQs KQs QJs JJ 88 77 66 55 KTs 65s, with equal weight per legal combo. This BB has shown a willingness to fold some one-pair hands to large river bets. In this model KQs 77 66 55 call 2 BB and fold to 7 BB. Against 2 BB, BB calls with AQs KQs QJs JJ 88 77 66 55. The other hands fold. Against 7 BB, BB calls with AQs QJs JJ 88. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 1.1,
  ),
  "w14_3_guided_compare_size_plans": Act0DecisionReasoningV1(
    taskId: "w14_3_guided_compare_size_plans",
    kind: Act0DecisionKindV1.table,
    principleId: "size_range_signal",
    bestAlternativeOptionId: "only_7",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check precedes the split in calling ranges by size. Those ranges are declared and are re-filtered for each known hero hand.",
    stackMatters: false,
    preChoiceAssumption:
        "Practice hand cases Ac Qh and Jh Tc occur equally often. BB holds a legal combo from KQs KQo Q9s QJs QTs 99 44 A9s 77 65s Q8s Q7s, equally weighted separately for each case. At 2 BB, BB calls KQs KQo Q9s QJs QTs 99 44 A9s 77 Q8s Q7s. At 7 BB, BB calls Q9s 99 44. The other hands fold. After check or call, go to showdown. Both hand cases use the same rules.",
    edgeBb: 1.22222,
  ),
  "w14_3_transfer_small_value_signal": Act0DecisionReasoningV1(
    taskId: "w14_3_transfer_small_value_signal",
    kind: Act0DecisionKindV1.table,
    principleId: "size_range_signal",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "The observed underbet is value-heavy in the stated model. Size by itself is weaker evidence than the actual range attached to it.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 2 BB with a legal combo from AKs AKo KTs 88 66 QJs, weighted equally. Compare call with fold. If you call, no more money goes in.",
    edgeBb: 0.5,
  ),
  "w14_3_day7_read_opponent_size": Act0DecisionReasoningV1(
    taskId: "w14_3_day7_read_opponent_size",
    kind: Act0DecisionKindV1.table,
    principleId: "size_range_signal",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB’s small size is mixed here. The range includes stronger queens and sets plus the stated weaker and missed groups.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 2.5 BB with a legal combo from AQs KQs QJs 99 77 JTs T8s 86s, weighted equally. Compare call with fold. If you call, no more money goes in.",
    edgeBb: 0.36364,
  ),
  "w14_4_guided_spr_price": Act0DecisionReasoningV1(
    taskId: "w14_4_guided_spr_price",
    kind: Act0DecisionKindV1.table,
    principleId: "spr_commitment",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "The 12 BB lead includes stronger made hands and draws. The listed shape, not the SPR alone, supports the calculation.",
    stackMatters: false,
    preChoiceAssumption:
        "BB bets 12 BB with a legal combo from AKs KQs KJs JJ 66 AQs QTs T9s, weighted equally. Compare call with fold. If you call, no more money goes in.",
    edgeBb: 11.8549,
  ),
  "w14_4_transfer_effective_shove": Act0DecisionReasoningV1(
    taskId: "w14_4_transfer_effective_shove",
    kind: Act0DecisionKindV1.table,
    principleId: "spr_commitment",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB’s effective shove covers the shorter stack. Hold the stated range fixed in the 100 BB counterfactual so the comparison measures the change in price.",
    stackMatters: true,
    preChoiceAssumption:
        "BB bets 25.5 BB with a legal combo from AA KK QQ 99 44 KQs QJs AJs T9s, weighted equally. Compare call with fold. If you call, no more money goes in. You have 25.5 BB behind. Compare a 100 BB start with the same BB range going all-in for the 90 BB available after the same preflop contributions.",
    edgeBb: 3.98333,
    stackNote:
        "At 35.5 BB start the call earns 3.98 BB. At 100 BB start the otherwise identical effective shove needs 44.9% equity and calling loses 7.32 BB.",
  ),
  "w14_4_day7_low_spr_fold": Act0DecisionReasoningV1(
    taskId: "w14_4_day7_low_spr_fold",
    kind: Act0DecisionKindV1.table,
    principleId: "spr_commitment",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BTN opened to 2.5 BB, BB raised to 10 BB, BTN 4-bet to 25 BB, and BB called. The premium call group shoves the flop.",
    stackMatters: false,
    preChoiceAssumption:
        "BTN opened to 2.5 BB. BB 3-bet to 10 BB. BTN 4-bet to 25 BB and BB called. BB bets 75 BB with a legal combo from AA KK QQ JJ AKs, weighted equally. Compare call with fold. If you call, no more money goes in.",
    edgeBb: 20.39051,
  ),
  "w14_6_guided_bet_to_induce": Act0DecisionReasoningV1(
    taskId: "w14_6_guided_bet_to_induce",
    kind: Act0DecisionKindV1.table,
    principleId: "induce_raise",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB raises both straight groups at either size. At 2 BB the set and bluff groups can also raise. Strong raises at 5 BB are easier to fold to.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is TT 88 55 KTs QTs 99 77 76s 64s A4s J9s Q9s 97s, with equal weight per legal combo. Against 2 BB, BB calls with KTs QTs 99 77 and raises to 8 BB with TT 88 55 64s A4s 76s J9s Q9s. The other hands fold. Against 5 BB, BB calls with TT 88 55 KTs QTs and raises to 14 BB with 64s A4s. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 0.34783,
  ),
  "w14_6_checkpoint_size_and_raise": Act0DecisionReasoningV1(
    taskId: "w14_6_checkpoint_size_and_raise",
    kind: Act0DecisionKindV1.table,
    principleId: "induce_raise",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "At 3 BB, BB pays with several jacks and raises a mixed group. The 8 BB response loses most worse calls and all modeled raises.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is AJs QJs JTs 99 66 TT 88 KTs T8s 87s, with equal weight per legal combo. Against 3 BB, BB calls with AJs QJs JTs TT 88 and raises to 10 BB with 99 66 KTs T8s. The other hands fold. Against 8 BB, BB calls with AJs 99 66. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 1.7027,
  ),
  "w14_6_day7_decline_induce": Act0DecisionReasoningV1(
    taskId: "w14_6_day7_decline_induce",
    kind: Act0DecisionKindV1.table,
    principleId: "induce_raise",
    bestAlternativeOptionId: "bet_5",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "After checking the flop and turn, BB can have numerous weaker jacks. In this model the 3 BB raise range contains only sets. At 5 BB, the same sets raise to 14 BB. Both suited and offsuit K-J and Q-J call.",
    stackMatters: false,
    preChoiceAssumption:
        "BB’s range is KJs KJo QJs QJo JTs JTo J8s 99 55 44 87s T8s 76s, with equal weight per legal combo. Against 3 BB, BB calls with KJs KJo QJs QJo JTs JTo J8s and raises to 10 BB with 99 55 44. The other hands fold. Against 5 BB, BB calls with KJs KJo QJs QJo and raises to 14 BB with 99 55 44. The other hands fold. After a check, a call without a raise, or a called raise, there is no more betting. You may call or fold if BB raises.",
    edgeBb: 0.34043,
  ),
};
