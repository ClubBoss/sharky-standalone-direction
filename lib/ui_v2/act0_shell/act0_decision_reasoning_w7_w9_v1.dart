import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningW7W9V1 = <String, Act0DecisionReasoningV1>{
  'w7_flop_bluff_one_player': Act0DecisionReasoningV1(
    taskId: 'w7_flop_bluff_one_player',
    kind: Act0DecisionKindV1.table,
    principleId: 'folds_better',
    bestAlternativeOptionId: 'choice_2',
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    edgeBb: 0.8,
    stackMatters: false,
    preChoiceAssumption: "Everyone folds to a 3 BB bet 40% of the time.",
  ),
  'w7_flop_bluff_two_players': Act0DecisionReasoningV1(
    taskId: 'w7_flop_bluff_two_players',
    kind: Act0DecisionKindV1.table,
    principleId: 'folds_better',
    bestAlternativeOptionId: 'choice_1',
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    edgeBb: 1.08,
    stackMatters: false,
    preChoiceAssumption: "Everyone folds to a 3 BB bet 16% of the time.",
  ),
  'w7_clean_outs_lower_price': Act0DecisionReasoningV1(
    taskId: 'w7_clean_outs_lower_price',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'choice_2',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead: "BB is all-in with king-queen by assumption.",
    edgeBb: 0.8181818182,
    stackMatters: false,
    preChoiceAssumption: "Suppose BB holds K♣ Q♠.",
  ),
  'w7_clean_outs_higher_price': Act0DecisionReasoningV1(
    taskId: 'w7_clean_outs_higher_price',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'choice_1',
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead: "BB is all-in with king-queen by assumption.",
    edgeBb: 0.5454545455,
    stackMatters: false,
    preChoiceAssumption: "Suppose BB holds K♣ Q♠.",
  ),
  'w7_river_one_bluff_of_six': Act0DecisionReasoningV1(
    taskId: 'w7_river_one_bluff_of_six',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'choice_1',
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead: "BB bets five better queens and one jack-ten bluff.",
    edgeBb: 1.33333,
    stackMatters: false,
    preChoiceAssumption: "could have any of these equally likely hands",
  ),
  'w7_river_two_bluffs_of_six': Act0DecisionReasoningV1(
    taskId: 'w7_river_two_bluffs_of_six',
    kind: Act0DecisionKindV1.table,
    principleId: 'price_vs_equity',
    bestAlternativeOptionId: 'choice_2',
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead: "BB bets four better queens and two bluffs.",
    edgeBb: 1.33333,
    stackMatters: true,
    stackNote:
        "BB has no chips behind. With a larger bet, the same range would stop being a call at a price above one third.",
    preChoiceAssumption: "could have any of these equally likely hands",
  ),
  'w7_checkpoint_river_card_excludes_hand': Act0DecisionReasoningV1(
    taskId: 'w7_checkpoint_river_card_excludes_hand',
    kind: Act0DecisionKindV1.table,
    principleId: 'combos_and_blockers',
    bestAlternativeOptionId: 'choice_1',
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB bets three straights and a lower set once the board removes the listed pair of twos.",
    edgeBb: 0.5,
    stackMatters: false,
    preChoiceAssumption: "Give all hands that are still possible equal weight.",
  ),
  'spaced_review_w7_w7_visible_cards_and_price_board_cards_v1':
      Act0DecisionReasoningV1(
        taskId: 'spaced_review_w7_w7_visible_cards_and_price_board_cards_v1',
        kind: Act0DecisionKindV1.table,
        principleId: 'folds_better',
        bestAlternativeOptionId: 'choice_1',
        edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
        edgeBb: 1.2,
        stackMatters: false,
        preChoiceAssumption: "BB folds 40% to a 2 BB bet.",
      ),
  'spaced_review_w7_w7_visible_cards_and_price_pot_to_call_v1':
      Act0DecisionReasoningV1(
        taskId: 'spaced_review_w7_w7_visible_cards_and_price_pot_to_call_v1',
        kind: Act0DecisionKindV1.table,
        principleId: 'price_vs_equity',
        bestAlternativeOptionId: 'call',
        edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
        opponentRead:
            "HJ bets two pair and can make a full house on one heart.",
        edgeBb: 0.181818,
        stackMatters: false,
        preChoiceAssumption:
            "Assume HJ holds a king and a queen, neither a heart.",
      ),
  'spaced_review_w7_w7_visible_cards_range_checkpoint_hero_cards_board_pot_v1':
      Act0DecisionReasoningV1(
        taskId:
            'spaced_review_w7_w7_visible_cards_range_checkpoint_hero_cards_board_pot_v1',
        kind: Act0DecisionKindV1.table,
        principleId: 'price_vs_equity',
        bestAlternativeOptionId: 'fold',
        edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
        opponentRead:
            "HJ bets two stronger queens and ten-nine high at equal weights.",
        edgeBb: 0.666667,
        stackMatters: false,
        preChoiceAssumption: "king-queen, ace-queen or ten-nine",
      ),
  "w7_read_visible_card_guided": Act0DecisionReasoningV1(
    taskId: "w7_read_visible_card_guided",
    kind: Act0DecisionKindV1.table,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "choice_0",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    opponentRead:
        "BB can bet the straight or a lower set once the river excludes the specified twos.",
    stackMatters: false,
    preChoiceAssumption:
        "BB can bet T♣8♣, 9♥9♦ or 2♠2♦ if the cards are available.",
  ),
  "w7_read_visible_card_call": Act0DecisionReasoningV1(
    taskId: "w7_read_visible_card_call",
    kind: Act0DecisionKindV1.table,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets king-queen, queen-ten and missed ten-eight at equal weights after the ace removes the listed ace-queen.",
    edgeBb: 6.6666666667,
    stackMatters: false,
    preChoiceAssumption:
        "Before the river, BB could bet A♣ Q♦, K♥ Q♦, Q♣ T♦ or T♥ 8♥. Give all hands still possible equal weight.",
  ),
  "spaced_review_w7_visible_card_call_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w7_visible_card_call_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BB bets queen-ten, ten-seven and missed jack-nine at equal weights after the king removes the listed king-ten.",
    edgeBb: 6.6666666667,
    stackMatters: false,
    preChoiceAssumption:
        "Before the river, BB could bet K♣ T♦, Q♥ T♦, T♣ 7♦ or J♥ 9♥. Give all hands still possible equal weight.",
  ),
};
