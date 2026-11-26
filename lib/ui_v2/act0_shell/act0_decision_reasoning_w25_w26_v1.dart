import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningW25W26V1 = <String, Act0DecisionReasoningV1>{
  "w25_1_guided_set_value": Act0DecisionReasoningV1(
    taskId: "w25_1_guided_set_value",
    kind: Act0DecisionKindV1.table,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "bet_6",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    opponentRead:
        "This opponent calls top pair broadly at the small size and retains only the best listed kicker and sets at the larger one.",
    preChoiceAssumption:
        "BB has one equally weighted legal combination from KQ KJ KT 55 33 76s JTs. Checking goes to showdown. At 3 BB BB calls KQ KJ KT 55 33 and folds the rest.  At 6 BB BB calls KQ 55 33 and folds the rest.",
    edgeBb: 0.36,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
    suboptimalKinds: {"check": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w25_1_transfer_response_denominator": Act0DecisionReasoningV1(
    taskId: "w25_1_transfer_response_denominator",
    kind: Act0DecisionKindV1.process,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "On study board Kh 9h 4h 7c 2s, a defender’s recorded range has AhQh, AhJh, QhJh, JhTh, KsQc and KdJd. The kings fold to the proposed bet. Compare Ac5s with Ah5s.",
  ),
  "w25_1_day7_paired_card_count": Act0DecisionReasoningV1(
    taskId: "w25_1_day7_paired_card_count",
    kind: Act0DecisionKindV1.process,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Board Qc Qd 8s 4c 2h. Compare the legal Q8 combinations with and without Qh in your hand. No other queen or eight is known.",
  ),
  "w25_2_guided_nut_flush_blocker": Act0DecisionReasoningV1(
    taskId: "w25_2_guided_nut_flush_blocker",
    kind: Act0DecisionKindV1.table,
    principleId: "folds_better",
    bestAlternativeOptionId: "bet_19",
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    stackMatters: false,
    opponentRead:
        "Both bet sizes fold the modeled one-pair kings. The set class needs the larger size and every surviving flush calls.",
    preChoiceAssumption:
        "BB has one equally weighted legal combination from QhJh JhTh Th8h 8h6h AhQh AhJh KQ KJ 99. Checking goes to showdown. At 5 BB BB calls QhJh JhTh Th8h 8h6h AhQh AhJh 99 and folds the rest.  At 19 BB BB calls QhJh JhTh Th8h 8h6h AhQh AhJh and folds the rest.",
    edgeBb: 0.20968,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
  ),
  "w25_2_transfer_without_heart": Act0DecisionReasoningV1(
    taskId: "w25_2_transfer_without_heart",
    kind: Act0DecisionKindV1.table,
    principleId: "folds_better",
    bestAlternativeOptionId: "bet_19",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    stackMatters: false,
    opponentRead:
        "The nut flushes are back in the range. Use the newly counted calling frequency before paying for any extra folds.",
    preChoiceAssumption:
        "BB has one equally weighted legal combination from QhJh JhTh Th8h 8h6h AhQh AhJh KQ KJ 99. Checking goes to showdown. At 5 BB BB calls QhJh JhTh Th8h 8h6h AhQh AhJh 99 and folds the rest.  At 19 BB BB calls QhJh JhTh Th8h 8h6h AhQh AhJh and folds the rest.",
    edgeBb: 1.04545,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
    suboptimalKinds: {"bet_19": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w25_2_day7_threshold_blocker": Act0DecisionReasoningV1(
    taskId: "w25_2_day7_threshold_blocker",
    kind: Act0DecisionKindV1.process,
    principleId: "folds_better",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "In a river exercise where your bluff always loses when called, you risk 8 BB to win 8 BB. After removal, only JsTc and QsJd fold from a six-combo roster.",
  ),
  "w25_3_guided_preserve_missed_hearts": Act0DecisionReasoningV1(
    taskId: "w25_3_guided_preserve_missed_hearts",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    stackMatters: false,
    opponentRead:
        "The bet includes sets and selected missed heart draws. One pair beats the misses and loses to the sets.",
    preChoiceAssumption:
        "BB bets 7 BB with every legal combination of 88 44 AhJh AhTh QhJh QhTh, equally weighted. A call ends the hand.",
    edgeBb: 3.2,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
    suboptimalKinds: {"fold": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w25_3_transfer_remove_the_misses": Act0DecisionReasoningV1(
    taskId: "w25_3_transfer_remove_the_misses",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    stackMatters: false,
    opponentRead:
        "Two modeled bluffs share the queen of hearts. Card removal increases the value share of the river bet.",
    preChoiceAssumption:
        "BB bets 7 BB with every legal combination of 88 44 AhJh AhTh QhJh QhTh, equally weighted. A call ends the hand.",
    edgeBb: 0.625,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w25_3_day7_turn_miss_suit": Act0DecisionReasoningV1(
    taskId: "w25_3_day7_turn_miss_suit",
    kind: Act0DecisionKindV1.process,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Board As 9c 6c 3d 2s. Your ace always beats the bluffs and loses to the value. Value is untouched by your kicker. Missed clubs include KcQc and KcJc.",
  ),
  "w25_4_guided_boat_removal": Act0DecisionReasoningV1(
    taskId: "w25_4_guided_boat_removal",
    kind: Act0DecisionKindV1.table,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    stackMatters: false,
    opponentRead:
        "The strong branch contains quads or full houses; the unpaired branch consists of misses.",
    preChoiceAssumption:
        "BB bets 14 BB with every legal combination of QQ 88 44 76s KJs, equally weighted. A call ends the hand.",
    edgeBb: 10.30769,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
  ),
  "w25_4_transfer_full_house_contrast": Act0DecisionReasoningV1(
    taskId: "w25_4_transfer_full_house_contrast",
    kind: Act0DecisionKindV1.process,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Board Ts Td 6s 4c 2h. BB’s modeled value holds T6 and 66 with all legal suits. Compare holding ThAd and 6cAd.",
  ),
  "w25_4_day7_four_flush_rank": Act0DecisionReasoningV1(
    taskId: "w25_4_day7_four_flush_rank",
    kind: Act0DecisionKindV1.process,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Board Qh 9h 6h 4h 2c. Compare holding Ah and holding As with an offsuit non-heart kicker.",
  ),
  "w25_5_guided_suit_value_3bet": Act0DecisionReasoningV1(
    taskId: "w25_5_guided_suit_value_3bet",
    kind: Act0DecisionKindV1.table,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "bet_27",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    opponentRead:
        "On this completed board, the broad small-size response includes kings. The large plan retains only flushes and sets.",
    preChoiceAssumption:
        "BB has one equally weighted legal combination from JhTh Th8h 8h6h 99 KK KQ KJ. Checking goes to showdown. At 9 BB BB calls JhTh Th8h 8h6h 99 KK KQ KJ and folds the rest.  At 27 BB BB calls JhTh Th8h 8h6h 99 KK and folds the rest.",
    edgeBb: 0.9,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
    suboptimalKinds: {"check": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w25_5_transfer_bluff_vs_live_flushes": Act0DecisionReasoningV1(
    taskId: "w25_5_transfer_bluff_vs_live_flushes",
    kind: Act0DecisionKindV1.process,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "In a three-bet-pot river model with three clubs showing, only AcQc, AcJc, KcQc, QcJc and AsKd bet. The first four call a raise; AsKd folds. You have Ac5s with zero showdown wins.",
  ),
  "w25_5_day7_suit_coverage_before_flop": Act0DecisionReasoningV1(
    taskId: "w25_5_day7_suit_coverage_before_flop",
    kind: Act0DecisionKindV1.process,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "After a late-position three-bet, the model contains all legal AQs and AJs. Board 9d 7d 2d. You hold Ad and an off-suit five.",
  ),
  "w25_6_guided_change_the_distribution": Act0DecisionReasoningV1(
    taskId: "w25_6_guided_change_the_distribution",
    kind: Act0DecisionKindV1.process,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Board Kh 9h 4h 7c 2s. Range A mixes Ah5d and Ac5d. Range B has AhJh, QhJh and KdJc, with equal joint weight per legal pair.",
  ),
  "w25_6_transfer_weighted_coverage": Act0DecisionReasoningV1(
    taskId: "w25_6_transfer_weighted_coverage",
    kind: Act0DecisionKindV1.table,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    stackMatters: false,
    opponentRead:
        "This opponent can bet worse made hands as well as completed flushes and straights. Count actual wins rather than labeling every non-nut hand a bluff.",
    preChoiceAssumption:
        "BB bets 8 BB with every legal combination of AcQc AcJc KcQc QcTc 75s 76s 99, equally weighted. A call ends the hand.",
    edgeBb: 11.85294,
    stackNote: "The stated terminal wager and range stand at 100 BB.",
  ),
  "w25_6_day7_negative_blocker": Act0DecisionReasoningV1(
    taskId: "w25_6_day7_negative_blocker",
    kind: Act0DecisionKindV1.process,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "On Js Tc 9d 4s 2c, your arbitrary rank-matched river bluff candidates are Qs5h and Qh5h. The modeled calls are KcQs and KdQd. The modeled folds are Qh6h and Ah7h. All survivor combos are equal weight.",
  ),
  "w26_1_guided_positive_chips_negative_prize": Act0DecisionReasoningV1(
    taskId: "w26_1_guided_positive_chips_negative_prize",
    kind: Act0DecisionKindV1.table,
    principleId: "risk_premium",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.riskPremium,
    stackMatters: true,
    opponentRead:
        "The covering BB’s range contains sets and misses. The short SB folded and affects the payouts.",
    preChoiceAssumption:
        "Three players remain. Prizes from first to third are 50/30/0 prize units. BB covers BTN and shoves an effective 24.5 BB with the legal combinations of 99 44 JTs 76s, equally weighted. The uncalled excess is not shown. Maximize static ICM prize EV with no future-hand or deal effects.",
    stackNote:
        "The BTN can be eliminated while BB survives a losing call branch; changing who covers changes the tree.",
  ),
  "w26_1_transfer_winner_take_all": Act0DecisionReasoningV1(
    taskId: "w26_1_transfer_winner_take_all",
    kind: Act0DecisionKindV1.table,
    principleId: "risk_premium",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.riskPremium,
    stackMatters: true,
    opponentRead:
        "The covering BB’s range contains sets and misses. The short SB folded and affects the payouts.",
    preChoiceAssumption:
        "Three players remain. Prizes from first to third are 80/0/0 prize units. BB covers BTN and shoves an effective 24.5 BB with the legal combinations of 88 55 QJs QTs, equally weighted. The uncalled excess is not shown. Maximize static ICM prize EV with no future-hand or deal effects.",
    stackNote:
        "The BTN can be eliminated while BB survives a losing call branch; changing who covers changes the tree.",
  ),
  "w26_1_day7_deal_or_chop": Act0DecisionReasoningV1(
    taskId: "w26_1_day7_deal_or_chop",
    kind: Act0DecisionKindV1.process,
    principleId: "risk_premium",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Three players have stacks 6, 3 and 1. Prizes remaining for the top three are 60, 30 and 10 units. The offered chip chop first reserves 10 units per player, then splits the remaining pool by chip share.",
  ),
  "w26_2_guided_compare_ten_bb": Act0DecisionReasoningV1(
    taskId: "w26_2_guided_compare_ten_bb",
    kind: Act0DecisionKindV1.process,
    principleId: "m_zone_shove",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "You are BTN with 10 BB, blinds and ante total 2.5 BB, and effective stacks cover you. This worksheet compares terminal net-BB outcomes in ten equally weighted scenarios. Jam: four folds win 2.5, three called wins gain 12.5, three called losses cost 10. Minraise/fold: four folds win 2.5 and six jams cost 2. Fold returns zero.",
  ),
  "w26_2_transfer_twenty_bb_minraise": Act0DecisionReasoningV1(
    taskId: "w26_2_transfer_twenty_bb_minraise",
    kind: Act0DecisionKindV1.process,
    principleId: "m_zone_shove",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "You started with 20 BB, minraised to 2 BB and face a covering jam. The pot with the effective jam is 23.5 BB. In the finite showdown model four outcomes are wins and six are losses with equal weight. Prize pressure is omitted.",
  ),
  "w26_2_day7_plan_the_call": Act0DecisionReasoningV1(
    taskId: "w26_2_day7_plan_the_call",
    kind: Act0DecisionKindV1.process,
    principleId: "m_zone_shove",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "You start with 20 BB, minraise to 2 BB and face the same 23.5 BB pot before calling. This fixture gives six wins and four losses in ten equal-weight showdowns, with no prize pressure.",
  ),
  "w26_3_guided_registration_window": Act0DecisionReasoningV1(
    taskId: "w26_3_guided_registration_window",
    kind: Act0DecisionKindV1.process,
    principleId: "process_over_outcome",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "An event allows late entry or re-entry for 50 units now. The same 18 BB starting stack is estimated to return 45 gross prize units under your model. A separate optional add-on for active entries is available later under different terms.",
  ),
  "w26_3_transfer_addon_terms": Act0DecisionReasoningV1(
    taskId: "w26_3_transfer_addon_terms",
    kind: Act0DecisionKindV1.process,
    principleId: "process_over_outcome",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "In this worksheet an add-on costs 15 units. It changes your modeled gross prize EV from 46 to 65 units. The original entry fee was paid earlier.",
  ),
  "w26_3_day7_draw_and_hand_for_hand": Act0DecisionReasoningV1(
    taskId: "w26_3_day7_draw_and_hand_for_hand",
    kind: Act0DecisionKindV1.process,
    principleId: "process_over_outcome",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Your seat breaks on the bubble. The director seats you immediately to the right of a covering active stack and announces synchronized hands under house procedure.",
  ),
  "w26_4_guided_medium_leverage": Act0DecisionReasoningV1(
    taskId: "w26_4_guided_medium_leverage",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "You are the medium stack. In the first candidate spot the only defender is a shorter stack you cover; in the second it is the leader, who covers you. Both will call and win in the branch you are comparing.",
  ),
  "w26_4_transfer_future_blinds": Act0DecisionReasoningV1(
    taskId: "w26_4_transfer_future_blinds",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Two static ICM nodes have identical stacks and payouts. At one table the short stack posts the big blind next; at the other they are on BTN next.",
  ),
  "w26_4_day7_equilibrium_claim": Act0DecisionReasoningV1(
    taskId: "w26_4_day7_equilibrium_claim",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Two final-table studies use the same stack vector, but one pays just first place and the other has a flat prize schedule across several places. Each asks for equilibrium responses.",
  ),
  "w26_5_guided_satellite_seat_lock": Act0DecisionReasoningV1(
    taskId: "w26_5_guided_satellite_seat_lock",
    kind: Act0DecisionKindV1.process,
    principleId: "risk_premium",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Four players remain for three identical seats. The worksheet explicitly gives a guaranteed seat if you fold, and two outcomes if you call a covering river shove: three winning samples qualify, one losing sample busts.",
  ),
  "w26_5_transfer_bounty_reversal": Act0DecisionReasoningV1(
    taskId: "w26_5_transfer_bounty_reversal",
    kind: Act0DecisionKindV1.process,
    principleId: "risk_premium",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "Without bounties the prize model values calling at 18 units and folding at 23. In five equally weighted call outcomes, two eliminate a covered opponent for 15 immediate units each. Other bounty effects are excluded.",
  ),
  "w26_5_day7_mystery_phase": Act0DecisionReasoningV1(
    taskId: "w26_5_day7_mystery_phase",
    kind: Act0DecisionKindV1.process,
    principleId: "risk_premium",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "An event starts awarding mystery prizes only after the money bubble. An elimination now is before that phase. You are choosing between two actions whose regular payout EV is already known.",
  ),
  "w26_6_guided_compare_reshove": Act0DecisionReasoningV1(
    taskId: "w26_6_guided_compare_reshove",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "A 16 BB effective reshove worksheet has open, blinds and ante forming a net 4 BB reward on a fold. In ten equal outcomes there are five folds, two called wins earning 18 net BB each, and three called losses of 16 net BB each. Fold now is zero.",
  ),
  "w26_6_transfer_checkout_payjump": Act0DecisionReasoningV1(
    taskId: "w26_6_transfer_checkout_payjump",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "At the final three tables, a short stack will face the next blind. Your river model near a pay jump assigns fold prize EV 27 units and call outcomes 38, 38, 38, 0 and 0. The call wins chips on average. You can fold or close the action with a call.",
  ),
  "w26_6_day7_stopgo_counter": Act0DecisionReasoningV1(
    taskId: "w26_6_day7_stopgo_counter",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    stackMatters: false,
    preChoiceAssumption:
        "A short-stack study compares two complete trees from the same decision. Jam payoffs over five equal-weight cases are 3, 3, 11, −9 and −9 BB. Flat then flop shove payoffs are 3, 3, 3, −9 and −9 BB. Fold yields zero.",
  ),
};
