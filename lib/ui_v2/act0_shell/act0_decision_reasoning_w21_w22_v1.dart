import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningW21W22V1 = <String, Act0DecisionReasoningV1>{
  "w21_1_teach": Act0DecisionReasoningV1(
    taskId: "w21_1_teach",
    kind: Act0DecisionKindV1.process,
    principleId: "decision_quality_signals",
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "A skipped range or price check is observable evidence of a process change. Losing one large hand can happen after a sound decision and does not establish any change in the opponent's play.",
  ),
  "w21_4_day7_take_worse_pair_payment": Act0DecisionReasoningV1(
    taskId: "w21_4_day7_take_worse_pair_payment",
    kind: Act0DecisionKindV1.table,
    principleId: "compare_simple_line",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "bet_7",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls all 34 legal combinations at 2 BB but only 14 at 7 BB, including six sets at both sizes. Bet 2 BB to collect enough extra payments from worse kings and underpairs to earn 5.82 BB rather than 4.94 BB at 7 BB.",
    stackMatters: false,
    edgeBb: 0.88235,
  ),
  "w21_4_guided_simple_value_over_disguise": Act0DecisionReasoningV1(
    taskId: "w21_4_guided_simple_value_over_disguise",
    kind: Act0DecisionKindV1.table,
    principleId: "compare_simple_line",
    secondaryPrincipleIds: ["value_vs_worse"],
    bestAlternativeOptionId: "bet_8",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "BB calls 30 of 36 legal combinations at 3 BB but only 14 at 8 BB, including six sets at both sizes. Bet 3 BB because the extra calls from weaker queens and nines make 6.08 BB in expected return versus 5.03 BB at 8 BB.",
    stackMatters: false,
    edgeBb: 1.05556,
  ),
  "w21_4_transfer_short_stack_limits_call": Act0DecisionReasoningV1(
    taskId: "w21_4_transfer_short_stack_limits_call",
    kind: Act0DecisionKindV1.table,
    principleId: "compare_simple_line",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB shoves the stipulated range, with seven of 19 legal combinations losing to K-J. Call 12 BB because 36.8% equity exceeds the 27.0% price; folding gives up 4.39 BB of expected gain.",
    stackMatters: true,
    stackNote:
        "Both players start with 22 BB. In the matched 100 BB model the 90 BB shove raises the price to 44.9% with the same range, so the call loses value.",
    edgeBb: 4.39474,
  ),
  "w22_2_transfer_best_response_not_equilibrium": Act0DecisionReasoningV1(
    taskId: "w22_2_transfer_best_response_not_equilibrium",
    kind: Act0DecisionKindV1.table,
    principleId: "read_payoff_matrix",
    secondaryPrincipleIds: ["equilibrium_or_counter"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    opponentRead:
        "BB's fixed policy folds in eight of ten equally weighted events. Bet 4 BB into 5.5 BB for 3.6 BB average gain instead of checking for zero. This best response to a fixed policy does not establish equilibrium.",
    stackMatters: false,
    edgeBb: 3.6,
  ),
  "w22_4_transfer_short_tree_price": Act0DecisionReasoningV1(
    taskId: "w22_4_transfer_short_tree_price",
    kind: Act0DecisionKindV1.table,
    principleId: "solver_input_contract",
    secondaryPrincipleIds: ["stack_depth_changes_play", "price_vs_equity"],
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB shoves the same modeled range at either depth. A-T beats eight of 20 legal combinations. Call 12 BB because 40.0% equity clears the 27.0% price, rather than fold for zero EV.",
    stackMatters: true,
    stackNote:
        "Both players start with 22 BB. In the matched 100 BB model the 90 BB shove needs 44.9% equity against the same range, so calling loses 9.80 BB on average.",
    edgeBb: 5.8,
  ),
  "w22_6_guided_compare_branch_plans": Act0DecisionReasoningV1(
    taskId: "w22_6_guided_compare_branch_plans",
    kind: Act0DecisionKindV1.table,
    principleId: "future_branches_before_bet",
    secondaryPrincipleIds: ["read_payoff_matrix"],
    bestAlternativeOptionId: "alternative",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "No separate opponent range or response frequencies are given beyond the equally weighted terminal branches. Check plan averages 1.50 BB versus -0.125 BB for the bet plan because the latter's negative branches outweigh its higher peak payoff.",
    stackMatters: false,
    edgeBb: 1.625,
  ),
};
