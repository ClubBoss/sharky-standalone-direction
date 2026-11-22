import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningW4W6V1 = <String, Act0DecisionReasoningV1>{
  'w4_purpose_collect_value': Act0DecisionReasoningV1(
    taskId: 'w4_purpose_collect_value',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'bet_four',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    preChoiceAssumption:
        "BB checks with Q-8 and will call 2 BB or fold to 4 BB.",
  ),
  'w4_min_raise_preflop': Act0DecisionReasoningV1(
    taskId: 'w4_min_raise_preflop',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'six_bb',
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "HJ’s raise size governs the minimum regardless of whether HJ opens a pair or unpaired high cards.",
    stackMatters: false,
  ),
  'w4_good_price_call': Act0DecisionReasoningV1(
    taskId: 'w4_good_price_call',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "HJ’s modeled turn range can bet made hands and draws. The question supplies the win rate.",
    stackMatters: false,
    preChoiceAssumption:
        "Two players, no ties or more bets. If you call, you win 1 time in 4 (25%).",
    suboptimalKinds: {'call_ignore_price': Act0SuboptimalKindV1.wrongReason},
  ),
  'w4_bad_price_fold': Act0DecisionReasoningV1(
    taskId: 'w4_bad_price_fold',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'call',
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "HJ’s turn range can include made hands and draws. Its stated win rate with this hand is 25%.",
    stackMatters: false,
    preChoiceAssumption:
        "Two players, no ties or more bets. If you call, you win 1 time in 4 (25%).",
    suboptimalKinds: {'fold_ignore_price': Act0SuboptimalKindV1.wrongReason},
  ),
  'w4_cheap_price_marginal_call': Act0DecisionReasoningV1(
    taskId: 'w4_cheap_price_marginal_call',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "HJ’s bet can come from made hands or draws. The model supplies the chance against them.",
    stackMatters: false,
    preChoiceAssumption:
        "If you call, you win 3 times in 20, about 1 in 7 (15%).",
    suboptimalKinds: {'call_ignore_price': Act0SuboptimalKindV1.wrongReason},
  ),
  'w4_value_bet': Act0DecisionReasoningV1(
    taskId: 'w4_value_bet',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'bet_pot',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    preChoiceAssumption: "BB calls 3 BB and folds to 6 BB with a weaker ace.",
  ),
  'w4_value_missed': Act0DecisionReasoningV1(
    taskId: 'w4_value_missed',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'bet_pot',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    preChoiceAssumption:
        "BB checks a weaker ace and calls 3 BB but folds to 6 BB.",
  ),
  'w4_bluff_pressure': Act0DecisionReasoningV1(
    taskId: 'w4_bluff_pressure',
    kind: Act0DecisionKindV1.table,
    principleId: 'smallest_size_same_job',
    bestAlternativeOptionId: 'bet_pot',
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    stackMatters: false,
    preChoiceAssumption: "BB folds the target hands to either bet size.",
  ),
  'w4_bad_bluff': Act0DecisionReasoningV1(
    taskId: 'w4_bad_bluff',
    kind: Act0DecisionKindV1.table,
    principleId: 'folds_better',
    bestAlternativeOptionId: 'bet_small',
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    stackMatters: false,
    preChoiceAssumption:
        "BB calls both offered bet sizes with better hands and folds worse hands.",
  ),
  'w4_protection_bet': Act0DecisionReasoningV1(
    taskId: 'w4_protection_bet',
    kind: Act0DecisionKindV1.table,
    principleId: 'deny_equity',
    bestAlternativeOptionId: 'bet_pot',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    preChoiceAssumption:
        "BB has ace-king, will call 3 BB and will fold to 6 BB.",
    suboptimalKinds: {'bet_pot': Act0SuboptimalKindV1.clearlyWorse},
  ),
  'w4_protection_small_denial': Act0DecisionReasoningV1(
    taskId: 'w4_protection_small_denial',
    kind: Act0DecisionKindV1.table,
    principleId: 'smallest_size_same_job',
    bestAlternativeOptionId: 'bet_four',
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    stackMatters: false,
    preChoiceAssumption:
        "BB’s overcards (A-K, A-Q, K-Q) fold to either bet. If BB has a set, it calls and wins.",
    suboptimalKinds: {'bet_four': Act0SuboptimalKindV1.clearlyWorse},
  ),
  'w4_checkpoint_price': Act0DecisionReasoningV1(
    taskId: 'w4_checkpoint_price',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "HJ’s turn range can include pairs and draws. The question supplies the win rate.",
    stackMatters: false,
    preChoiceAssumption:
        "Two players, no ties or more bets. If you call, you win 1 time in 4 (25%).",
    suboptimalKinds: {'call_ignore_price': Act0SuboptimalKindV1.wrongReason},
  ),
  'w4_checkpoint_table_price': Act0DecisionReasoningV1(
    taskId: 'w4_checkpoint_table_price',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB can bet made hands or draws on this turn. The model supplies the chance of winning.",
    stackMatters: false,
    preChoiceAssumption:
        "If you call, you win 3 times in 10, about 1 in 3 (30%).",
    suboptimalKinds: {'call_ignore_price': Act0SuboptimalKindV1.wrongReason},
  ),
  'w4_checkpoint_review': Act0DecisionReasoningV1(
    taskId: 'w4_checkpoint_review',
    kind: Act0DecisionKindV1.process,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'size_only',
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    suboptimalKinds: {'size_only': Act0SuboptimalKindV1.wrongReason},
  ),
  'spaced_review_w4_why_bets_happen_board_cards_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w4_why_bets_happen_board_cards_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'choice_1',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    preChoiceAssumption: "BB checks with A-7, calls 2 BB and folds to 4 BB.",
  ),
  'spaced_review_w4_call_price_pot_to_call_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w4_call_price_pot_to_call_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "HJ can bet a range of made hands and bluffs. The question provides the win frequency.",
    stackMatters: false,
    preChoiceAssumption: "assume you win 1 time in 4 if you call.",
  ),
  'spaced_review_w4_value_bets_board_cards_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w4_value_bets_board_cards_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'choice_1',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    stackMatters: false,
    preChoiceAssumption: "BB calls 3 BB with K-J and K-T.",
  ),
  'spaced_review_w4_bluff_pressure_board_cards_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w4_bluff_pressure_board_cards_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'folds_better',
    bestAlternativeOptionId: 'check',
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    stackMatters: false,
    preChoiceAssumption: "BB has a pair of sevens and folds it to a 3 BB bet.",
  ),
  'spaced_review_w4_protection_and_denial_board_cards_v1':
      Act0DecisionReasoningV1(
        taskId: 'spaced_review_w4_protection_and_denial_board_cards_v1',
        kind: Act0DecisionKindV1.table,
        principleId: 'deny_equity',
        bestAlternativeOptionId: 'check',
        edgeMechanism: Act0EdgeMechanismV1.deniesEquity,
        stackMatters: false,
        preChoiceAssumption:
            "Assume BB has A-K and can pair either card on the turn.",
      ),
  'spaced_review_w4_price_checkpoint_pot_to_call_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w4_price_checkpoint_pot_to_call_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'call',
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "HJ can bet made hands and bluffs. The question sets the combined win rate against that range.",
    stackMatters: false,
    preChoiceAssumption:
        "Assume one win in five against this opponent's range.",
  ),
  'w4_protection_guided_raise_read': Act0DecisionReasoningV1(
    taskId: 'w4_protection_guided_raise_read',
    kind: Act0DecisionKindV1.table,
    principleId: 'deny_equity',
    bestAlternativeOptionId: 'choice_0',
    edgeMechanism: Act0EdgeMechanismV1.avoidsDomination,
    opponentRead:
        'The model puts sets in the raise range. One-pair hands usually call.',
    stackMatters: false,
    preChoiceAssumption:
        'Hand reading means using the action to see which hands are more likely. This BB usually calls with one pair and seldom raises a weak hand.',
  ),
  'w4_protection_short_shove_price': Act0DecisionReasoningV1(
    taskId: 'w4_protection_short_shove_price',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        'The all-in range combines strong made hands and weaker hands. The stated 40% is the combined win rate.',
    stackMatters: true,
    stackNote:
        'The short all-in costs 6 BB and needs one win in three. An all-in at 100 BB starting depth needs about 48.5%, so the same 40% would fold.',
    preChoiceAssumption: 'Assume you win 40% and never tie.',
    edgeBb: 1.2,
  ),
  'spaced_review_w4_protection_and_denial_pot_to_call_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w4_protection_and_denial_pot_to_call_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'call',
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        'BB can shove strong pairs or draws in this model. The combined range gives the stated 20%.',
    stackMatters: false,
    preChoiceAssumption:
        'Assume 20% wins and no ties against this all-in range.',
    edgeBb: 0.6,
  ),
};
