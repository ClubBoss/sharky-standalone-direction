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
  "spaced_review_w15_texture_and_frequency_texture_cbet_frequency_v1":
      Act0DecisionReasoningV1(
        taskId:
            "spaced_review_w15_texture_and_frequency_texture_cbet_frequency_v1",
        kind: Act0DecisionKindV1.table,
        principleId: "texture_cbet_frequency",
        bestAlternativeOptionId: "choice_0",
        edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
        opponentRead:
            "BB checks on this connected flop. In the stated model, a 3 BB continuation bet is called 85% of the time. Your showdown share against calls is 12%, or 20% against the full range if you check. No further bets.",
        preChoiceAssumption:
            "BB checks on this connected flop. In the stated model, a 3 BB continuation bet is called 85% of the time. Your showdown share against calls is 12%, or 20% against the full range if you check. No further bets.",
        stackMatters: false,
        edgeBb: 1.444,
      ),
  "spaced_review_w15_w15_protection_and_denial_deny_equity_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w15_w15_protection_and_denial_deny_equity_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "deny_equity",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.deniesEquity,
    opponentRead:
        "BB checks. In this model BB has only two overcards; you win 75% of showdowns if you check through. BB folds every hand to a 3 BB bet.",
    preChoiceAssumption:
        "BB checks. In this model BB has only two overcards; you win 75% of showdowns if you check through. BB folds every hand to a 3 BB bet.",
    stackMatters: false,
    edgeBb: 2.5,
  ),
  "spaced_review_w15_check_back_and_slowplay_earned_slowplay_v1":
      Act0DecisionReasoningV1(
        taskId: "spaced_review_w15_check_back_and_slowplay_earned_slowplay_v1",
        kind: Act0DecisionKindV1.table,
        principleId: "earned_slowplay",
        bestAlternativeOptionId: "choice_1",
        edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
        opponentRead:
            "BB checks. BB folds to a flop bet but, if you check behind, bets 4 BB on the turn 50% of the time. You call that bet. Your full house has 98% showdown equity in both check branches; no more bets.",
        preChoiceAssumption:
            "BB checks. BB folds to a flop bet but, if you check behind, bets 4 BB on the turn 50% of the time. You call that bet. Your full house has 98% showdown equity in both check branches; no more bets.",
        stackMatters: false,
        edgeBb: 1.71,
      ),
  "spaced_review_w15_monotone_and_paired_flop_texture_coverage_v1":
      Act0DecisionReasoningV1(
        taskId:
            "spaced_review_w15_monotone_and_paired_flop_texture_coverage_v1",
        kind: Act0DecisionKindV1.table,
        principleId: "flop_texture_coverage",
        bestAlternativeOptionId: "choice_0",
        edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
        opponentRead:
            "BB checks on a three-diamond flop. BB calls a 4 BB bet with flushes and strong draws 80% of the time. Your showdown share is 10% against calls and 22% against the full range if you check. No further bets.",
        preChoiceAssumption:
            "BB checks on a three-diamond flop. BB calls a 4 BB bet with flushes and strong draws 80% of the time. Your showdown share is 10% against calls and 22% against the full range if you check. No further bets.",
        stackMatters: false,
        edgeBb: 1.9,
      ),
  "spaced_review_w15_leads_and_stabs_lead_and_stab_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w15_leads_and_stabs_lead_and_stab_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "lead_and_stab",
    bestAlternativeOptionId: "choice_0",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "HJ raised preflop and you act first. In this model HJ folds to a 4 BB lead 50% of the time and calls otherwise. Your straight draw has 30% showdown equity against calls; no more betting. If you check, HJ bets and you fold.",
    preChoiceAssumption:
        "HJ raised preflop and you act first. In this model HJ folds to a 4 BB lead 50% of the time and calls otherwise. Your straight draw has 30% showdown equity against calls; no more betting. If you check, HJ bets and you fold.",
    stackMatters: false,
    edgeBb: 6.35,
  ),
  "spaced_review_w15_check_raise_and_checkpoint_flop_raise_shape_v1":
      Act0DecisionReasoningV1(
        taskId:
            "spaced_review_w15_check_raise_and_checkpoint_flop_raise_shape_v1",
        kind: Act0DecisionKindV1.table,
        principleId: "flop_raise_shape",
        bestAlternativeOptionId: "call",
        edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
        opponentRead:
            "HJ bets 4 BB after your check. HJ calls a raise to 12 BB 60% of the time and folds otherwise. Your set has 80% showdown equity against the full betting range and 75% against the calls. No further betting.",
        preChoiceAssumption:
            "HJ bets 4 BB after your check. HJ calls a raise to 12 BB 60% of the time and folds otherwise. Your set has 80% showdown equity against the full betting range and 75% against the calls. No further betting.",
        stackMatters: false,
        edgeBb: 3.4,
      ),
  // B141: use the authored runner choice IDs; h5 tasks audit their flop decision.
  "w15_6_read_polar_on_two_tone": Act0DecisionReasoningV1(
    taskId: "w15_6_read_polar_on_two_tone",
    kind: Act0DecisionKindV1.table,
    principleId: "flop_raise_shape",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "On Qh 7c 2h, BB can raise sets for value and the two candidate heart draws as semibluffs. Raising sets and strong top pairs instead omits the bluff end of the policy; the model calls top pair. BTN’s 2 BB bet triggers this policy; no BTN range or fold rate is specified.",
    stackMatters: false,
  ),
  "w16_1_guided_barrel_worse_kings": Act0DecisionReasoningV1(
    taskId: "w16_1_guided_barrel_worse_kings",
    kind: Act0DecisionKindV1.table,
    principleId: "barrel_on_range_shift",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls 4 BB with weaker kings and underpairs as well as sets on the 3h turn. Bet 4 BB for a modeled 8.58 BB rather than check for 7.14 BB; the 9 BB size drops too many worse calls.",
    stackMatters: false,
  ),
  "w16_1_transfer_give_up_on_third_heart": Act0DecisionReasoningV1(
    taskId: "w16_1_transfer_give_up_on_third_heart",
    kind: Act0DecisionKindV1.table,
    principleId: "barrel_on_range_shift",
    bestAlternativeOptionId: "bet_4",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB’s stipulated 4 BB calling range contains made flushes, sets and kings on the third heart. Check back for modeled 1.93 BB rather than bluff 4 BB for −0.62 BB; the folds do not pay for the losing calls.",
    stackMatters: false,
  ),
  "w16_2_guided_bluff_catch_price": Act0DecisionReasoningV1(
    taskId: "w16_2_guided_bluff_catch_price",
    kind: Act0DecisionKindV1.table,
    principleId: "commitment_by_price",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB’s stated 4 BB river range gives A-J 45.5% equity, above the 29.6% call price. Calling earns a modeled 2.14 BB instead of folding for zero.",
    stackMatters: false,
  ),
  "w16_2_transfer_short_shove": Act0DecisionReasoningV1(
    taskId: "w16_2_transfer_short_shove",
    kind: Act0DecisionKindV1.table,
    principleId: "commitment_by_price",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB shoves the stated range for 12 BB. A-J has 36.8% equity, above the 27.0% price; call for modeled 4.39 BB rather than fold for zero.",
    stackMatters: true,
    stackNote:
        "At the matched 100 BB start, the 90 BB shove requires 44.9% equity against the same range; calling loses 16.13 BB on average.",
  ),
  "w16_2_day7_fold_despite_investment": Act0DecisionReasoningV1(
    taskId: "w16_2_day7_fold_despite_investment",
    kind: Act0DecisionKindV1.table,
    principleId: "commitment_by_price",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB’s 13 BB betting range leaves Q-J only 14.3% equity against a 34.7% price. Fold for zero additional loss rather than call and lose 7.64 BB on average; the flop investment is sunk.",
    stackMatters: false,
  ),
  "w16_3_guided_thin_third_street": Act0DecisionReasoningV1(
    taskId: "w16_3_guided_thin_third_street",
    kind: Act0DecisionKindV1.table,
    principleId: "street_value_budget",
    bestAlternativeOptionId: "bet_8",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls 3 BB on the blank river with more weak jacks than sets, and the wider call group supplies value. Bet 3 BB for a modeled 14.42 BB rather than 8 BB for 13.36 BB; checking earns only 12.92 BB.",
    stackMatters: false,
  ),
  "w16_3_transfer_jam_nut_straight": Act0DecisionReasoningV1(
    taskId: "w16_3_transfer_jam_nut_straight",
    kind: Act0DecisionKindV1.table,
    principleId: "street_value_budget",
    bestAlternativeOptionId: "bet_18",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB still calls the 44 BB jam with sets and two pair; another 8-7 splits. Jam for modeled 125.11 BB rather than bet 18 BB for 119.43 BB, since the larger payments outweigh lost calls.",
    stackMatters: false,
  ),
  "w16_3_day7_one_street_only": Act0DecisionReasoningV1(
    taskId: "w16_3_day7_one_street_only",
    kind: Act0DecisionKindV1.table,
    principleId: "street_value_budget",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB folds hands worse than K-T and calls with better hands on this river by assumption. Check back rather than bet small for another street: the bet gets no extra money from worse and loses more against better.",
    stackMatters: false,
  ),
  "w16_4_guided_delayed_value": Act0DecisionReasoningV1(
    taskId: "w16_4_guided_delayed_value",
    kind: Act0DecisionKindV1.table,
    principleId: "delayed_attack",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB checks the turn queen and calls 3 BB with weaker queens, lower pairs and a draw as well as sets. The improved A-Q earns 4.54 BB by betting 3 BB versus 3.60 BB by checking in this model.",
    stackMatters: false,
  ),
  "w16_4_transfer_float_or_free_card": Act0DecisionReasoningV1(
    taskId: "w16_4_transfer_float_or_free_card",
    kind: Act0DecisionKindV1.table,
    principleId: "delayed_attack",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.realizesPosition,
    opponentRead:
        "CO checks after BTN called the flop. CO never folds a pair here in the stated range, and BTN acts last. Check behind to see the river for no additional chips rather than bet to complete a float.",
    stackMatters: false,
  ),
  "w16_5_guided_turn_overbet_nuts": Act0DecisionReasoningV1(
    taskId: "w16_5_guided_turn_overbet_nuts",
    kind: Act0DecisionKindV1.table,
    principleId: "pressure_or_price",
    bestAlternativeOptionId: "bet_7",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls the 25 BB overbet with sets, two pair and other listed hands. The nut straight earns modeled 27.36 BB at 25 BB versus 21.87 BB at 7 BB; the larger payments outweigh the extra calls at the smaller size.",
    stackMatters: false,
  ),
  "w16_5_transfer_block_price": Act0DecisionReasoningV1(
    taskId: "w16_5_transfer_block_price",
    kind: Act0DecisionKindV1.table,
    principleId: "pressure_or_price",
    bestAlternativeOptionId: "check_fold",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BTN calls 1 BB with all 14 legal combinations: eight worse kings and six better kings. Lead for modeled 3.29 BB rather than check and fold to 5 BB for 3.14 BB; the weaker kings check back otherwise.",
    stackMatters: false,
  ),
  "w16_6_guided_scare_card_call": Act0DecisionReasoningV1(
    taskId: "w16_6_guided_scare_card_call",
    kind: Act0DecisionKindV1.table,
    principleId: "commitment_recheck",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets 5 BB with flushes and weaker hands in the stated range. A-Q has 66.7% equity versus a 19.6% call price, so call for modeled 12 BB rather than fold for zero.",
    stackMatters: false,
  ),
  "w16_6_checkpoint_match_the_price": Act0DecisionReasoningV1(
    taskId: "w16_6_checkpoint_match_the_price",
    kind: Act0DecisionKindV1.table,
    principleId: "commitment_recheck",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB’s 15 BB river betting range gives A-J 62.5% equity against a 33.0% price. Call for modeled 13.44 BB instead of folding for zero; earlier payments do not set the current price.",
    stackMatters: false,
  ),
  "w16_6_day7_last_bet_independent": Act0DecisionReasoningV1(
    taskId: "w16_6_day7_last_bet_independent",
    kind: Act0DecisionKindV1.table,
    principleId: "commitment_recheck",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB’s stated 12 BB river betting range includes made flushes and sets. K-Q has 18.2% equity versus a 30.4% call price, so fold rather than call for a modeled 4.82 BB loss regardless of past bets.",
    stackMatters: false,
  ),
  "h5_w16_3_guided_thin_third_street": Act0DecisionReasoningV1(
    taskId: "h5_w16_3_guided_thin_third_street",
    kind: Act0DecisionKindV1.table,
    principleId: "pot_geometry",
    bestAlternativeOptionId: "flop_check",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB has checked and the flop exercise assumes BB calls any offered bet. Bet 2 BB to build the 5.5 BB pot to 9.5 BB; checking leaves 5.5 BB and misses the sizing goal. This compares pot targets, not showdown EV.",
    stackMatters: false,
  ),
  "h5_w16_3_transfer_jam_nut_straight": Act0DecisionReasoningV1(
    taskId: "h5_w16_3_transfer_jam_nut_straight",
    kind: Act0DecisionKindV1.table,
    principleId: "pot_geometry",
    bestAlternativeOptionId: "flop_check",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB has checked and the flop exercise assumes BB calls any offered bet. Bet 16 BB into 20.5 BB to reach 52.5 BB after the matching call; checking leaves 20.5 BB. This is the specified sizing goal, not a comparison of showdown EV.",
    stackMatters: false,
  ),
  "h5_w16_6_day7_last_bet_independent": Act0DecisionReasoningV1(
    taskId: "h5_w16_6_day7_last_bet_independent",
    kind: Act0DecisionKindV1.table,
    principleId: "pot_geometry",
    bestAlternativeOptionId: "flop_check",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB has checked and the flop exercise assumes BB calls any offered bet. Bet 2 BB to reach the 9.5 BB target from 5.5 BB; checking leaves the pot unchanged. Reassess the river decision separately, rather than treating this flop bet as a commitment to call.",
    stackMatters: false,
  ),
};
