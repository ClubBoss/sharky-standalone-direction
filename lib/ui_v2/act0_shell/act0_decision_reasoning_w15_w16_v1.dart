import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningW15W16V1 = <String, Act0DecisionReasoningV1>{
  "w15_1_guided_compare_cbet_frequency": Act0DecisionReasoningV1(
    taskId: "w15_1_guided_compare_cbet_frequency",
    kind: Act0DecisionKindV1.table,
    principleId: "texture_cbet_frequency",
    bestAlternativeOptionId: "value_only",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB checks this dry flop with a mix of aces, pairs and misses. In these cases the listed call group gives value to A-Q and leaves profitable folds for J-T.",
    stackMatters: false,
    preChoiceAssumption:
        "Compare two equally frequent BTN hand cases, Ad Qd and Jh Ts. BB’s legal range is AJs ATo A8s 66 22 77 55 87s KQs QJs J9s. If you bet 2 BB, BB calls AJs ATo A8s 66 22 77 and folds the rest. Both players otherwise check through.",
    edgeBb: 0.31942,
  ),
  "w15_1_transfer_connected_select": Act0DecisionReasoningV1(
    taskId: "w15_1_transfer_connected_select",
    kind: Act0DecisionKindV1.table,
    principleId: "texture_cbet_frequency",
    bestAlternativeOptionId: "bet",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BB can continue with straights, sets and pair-plus-draw hands. The check does not make this connected board safe for a broad bluff.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from J8s T9s 99 77 T8s JTs QJs 88 6c5c 6d5d 6h5h 6s5s KcQc KdQd KhQh KsQs. If you bet 3 BB, BB calls with J8s T9s 99 77 T8s JTs QJs 88 6d5d KdQd and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 1.36901,
  ),
  "w15_1_day7_king_low_low": Act0DecisionReasoningV1(
    taskId: "w15_1_day7_king_low_low",
    kind: Act0DecisionKindV1.table,
    principleId: "texture_cbet_frequency",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check leaves lower kickers in the calling range at this small size.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from KJs KTs K9s 44 22 88 77 65s 54s QJs. If you bet 2 BB, BB calls with KJs KTs K9s 44 22 88 77 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.76264,
  ),
  "w15_2_guided_protect_overpair": Act0DecisionReasoningV1(
    taskId: "w15_2_guided_protect_overpair",
    kind: Act0DecisionKindV1.table,
    principleId: "deny_equity",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB pays with lower pairs as well as sets. The small size keeps the double gutshot while folding some unpaired overcards.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from QTs JTs T9s 88 44 AQs KQs 76s 99 77. If you bet 2.5 BB, BB calls with QTs JTs T9s 88 44 99 77 76s and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 1.01862,
  ),
  "w15_2_transfer_value_or_denial": Act0DecisionReasoningV1(
    taskId: "w15_2_transfer_value_or_denial",
    kind: Act0DecisionKindV1.table,
    principleId: "deny_equity",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.deniesEquity,
    opponentRead:
        "Observed profile: BB often releases two overcards even to a small bet. This exercise isolates that response.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has repeatedly folded missed overcards to small bets. BB has an equally weighted legal combo from AJs AJo KQs KQo QJs 99 55 22 88. If you bet 1 BB, BB calls with 99 55 22 88 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.79039,
  ),
  "w15_2_day7_protect_top_pair": Act0DecisionReasoningV1(
    taskId: "w15_2_day7_protect_top_pair",
    kind: Act0DecisionKindV1.table,
    principleId: "deny_equity",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check contains weaker jacks and underpairs, and a small bet gets both calls and folds.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from KJs QJs JTs 77 33 KQs KQo 65s 55 44. If you bet 2 BB, BB calls with KJs QJs JTs 77 33 55 44 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.97367,
  ),
  "w15_3_guided_trap_dry_set": Act0DecisionReasoningV1(
    taskId: "w15_3_guided_trap_dry_set",
    kind: Act0DecisionKindV1.table,
    principleId: "earned_slowplay",
    bestAlternativeOptionId: "bet",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BB’s flop check keeps air in range. The stated delayed lead includes hands such as A-J that fold to immediate pressure.",
    stackMatters: false,
    preChoiceAssumption:
        "BB holds a legal combo from KQs KJs KTs 77 22 AQs AJs AJo QJs 98s 65s. If you bet 2 BB now, BB calls KQs KJs KTs 77 22, folds the rest and checks through after a call. If you check, BB leads 4 BB on every turn with KQs KJs KTs 77 22 AQs AJs AJo QJs and checks through with the rest. You can call or fold. There is no river betting.",
    edgeBb: 2.44324,
  ),
  "w15_3_transfer_bet_wet_set": Act0DecisionReasoningV1(
    taskId: "w15_3_transfer_bet_wet_set",
    kind: Act0DecisionKindV1.table,
    principleId: "earned_slowplay",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB’s check can include a straight. Many worse made hands and draws still pay 4 BB, including AhQh, AhJh and KhTh.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from T7s 75s 98s 86s 88 66 AcQc AdQd AhQh AsQs AcJc AdJd AhJh AsJs KcTc KdTd KhTh KsTs 77 65s. If you bet 4 BB, BB calls with T7s 75s 98s 86s 88 66 77 65s AhQh AhJh KhTh and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 1.34732,
  ),
  "w15_3_day7_take_value": Act0DecisionReasoningV1(
    taskId: "w15_3_day7_take_value",
    kind: Act0DecisionKindV1.table,
    principleId: "earned_slowplay",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB is passive after a check in this exercise. Its stated callers already supply value on the flop.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from AcJc AdJd AhJh AsJs AJo KcJc KdJd KhJh KsJs Tc8c Td8d Th8h Ts8s 99 22 QJs QTs 98s 8c7c 8d7d 8h7h 8s7s. If you bet 3 BB, BB calls with 99 22 QJs QTs 98s AsJs KsJs Ts8s 8s7s and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 1.09793,
  ),
  "w15_4_guided_check_monotone": Act0DecisionReasoningV1(
    taskId: "w15_4_guided_check_monotone",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_texture_coverage",
    bestAlternativeOptionId: "bet",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BB’s check can hide a flush, set or lower pair. At the stated 5 BB size, this call group makes an unpaired hand prefer checking.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from AcKc AdKd AhKh AsKs AcTc AdTd AhTh AsTs KJs QJs 88 33 QcTc QdTd QhTh QsTs Tc9c Td9d Th9h Ts9s 7c6c 7d6d 7h6h 7s6s. If you bet 5 BB, BB calls with AhKh AhTh KJs QJs 88 33 QhTh Th9h 7h6h and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 1.4329,
  ),
  "w15_4_transfer_paired_high": Act0DecisionReasoningV1(
    taskId: "w15_4_transfer_paired_high",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_texture_coverage",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB can hold trips after checking. The small bet still gets calls from T-T, 9-9 and 8-8.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from KQs KJs KTs 44 TT 99 88 AQo QJs 76s. If you bet 2 BB, BB calls with KQs KJs KTs 44 TT 99 88 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.47262,
  ),
  "w15_4_day7_paired_low": Act0DecisionReasoningV1(
    taskId: "w15_4_day7_paired_low",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_texture_coverage",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB can have quads or a full house, but will also call the smaller bet with several lower pairs.",
    stackMatters: false,
    preChoiceAssumption:
        "BB has an equally weighted legal combo from AJs AJo KQs KQo 44 22 66 55 33 QJs 65s. If you bet 2 BB, BB calls with 44 22 66 55 33 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 1.23904,
  ),
  "w15_5_guided_lead_two_pair": Act0DecisionReasoningV1(
    taskId: "w15_5_guided_lead_two_pair",
    kind: Act0DecisionKindV1.table,
    principleId: "lead_and_stab",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "The preflop raiser still has strong made hands such as straights and sets. The listed overpair calls supply the benefit of leading.",
    stackMatters: false,
    preChoiceAssumption:
        "BTN has an equally weighted legal combo from AA KK QQ JJ TT AKo AQo KQs 88 77 44 65s. If you lead 3 BB, BTN calls with AA KK QQ JJ TT 88 77 44 65s and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.43235,
  ),
  "w15_5_transfer_stab_after_check": Act0DecisionReasoningV1(
    taskId: "w15_5_transfer_stab_after_check",
    kind: Act0DecisionKindV1.table,
    principleId: "lead_and_stab",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "CO’s check precedes the possible stab. In this exercise A-J and the sevens fold, while stronger queens and sets continue.",
    stackMatters: false,
    preChoiceAssumption:
        "CO has an equally weighted legal combo from AQs KQs QJs 88 44 JJ 99 77 AJs KTs 65s. If you bet 2 BB, CO calls with AQs KQs QJs 88 44 JJ 99 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.48779,
  ),
  "w15_5_day7_check_before_raiser": Act0DecisionReasoningV1(
    taskId: "w15_5_day7_check_before_raiser",
    kind: Act0DecisionKindV1.table,
    principleId: "lead_and_stab",
    bestAlternativeOptionId: "bet",
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "BTN can have lower pocket pairs as well as better aces. The response keeps the stronger group in.",
    stackMatters: false,
    preChoiceAssumption:
        "BTN has an equally weighted legal combo from AKo AQo AJs 66 33 99 88 77 KQs QJs. If you lead 3 BB, BTN calls with AKo AQo AJs 66 33 and folds the rest. After check or call, both players check through to showdown.",
    edgeBb: 0.88915,
  ),
  "w15_6_guided_wet_check_raise": Act0DecisionReasoningV1(
    taskId: "w15_6_guided_wet_check_raise",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_raise_shape",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BTN can c-bet several overpairs, sets and unpaired groups. The stated raise response retains a narrower set of overpairs and sets.",
    stackMatters: false,
    preChoiceAssumption:
        "After you check, BTN bets 2 BB with an equal-weight legal combo from AA KK QQ JJ TT 99 88 33 AKo AQo AcJc AdJd AhJh AsJs KcQc KdQd KhQh KsQs 77 66. Against the offered check-raise, BTN calls AA KK QQ 99 88 33 JJ TT KhQh and folds other hands. After a call or a called raise, check through.",
    edgeBb: 1.75423,
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w15_6_checkpoint_short_check_raise": Act0DecisionReasoningV1(
    taskId: "w15_6_checkpoint_short_check_raise",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_raise_shape",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BTN c-bets a mix of pairs and draws. Against the short raise it only keeps the stated overpairs, strong top pair and sets.",
    stackMatters: true,
    preChoiceAssumption:
        "After you check, BTN bets 3 BB with an equal-weight legal combo from AA KK QQ AJs KJs QJs 88 33 T9s 7c6c 7d6d 7h6h 7s6s 99 66. Against the offered check-raise, BTN calls AA KK QQ AJs 88 33 KJs QJs 7h6h and folds other hands. After a call or a called raise, check through. Your 10 BB check-raise is all-in. In the 100 BB contrast, compare the same call with a 97.5 BB all-in check-raise, where BTN calls only AA KK QQ AJs 88 33. This is an all-in comparison; other deep raises are outside these two lines.",
    edgeBb: 1.04297,
    stackNote:
        "The all-in raise earns 4.29 BB at the short stack. At 100 BB it earns -0.31 BB and calling earns 3.25 BB.",
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "w15_6_day7_merged_raise_dry": Act0DecisionReasoningV1(
    taskId: "w15_6_day7_merged_raise_dry",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_raise_shape",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "This dry-board response pays a modest raise with worse jacks and underpairs. That supports including strong top pair in a merged raise.",
    stackMatters: false,
    preChoiceAssumption:
        "After you check, BTN bets 2 BB with an equal-weight legal combo from KJs QJs JTs 77 22 KK QQ 99 88 AKo KQs. Against the offered check-raise, BTN calls KJs QJs JTs 77 22 KK QQ 99 88 and folds other hands. After a call or a called raise, check through.",
    edgeBb: 0.52189,
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
};
