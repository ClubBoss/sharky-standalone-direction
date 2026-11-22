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
  'w7_table_effective_notice': Act0DecisionReasoningV1(
    taskId: 'w7_table_effective_notice',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: 'your_120',
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    stackMatters: false,
    suboptimalKinds: {'total_138': Act0SuboptimalKindV1.clearlyWorse},
  ),
  'w7_20bb_wider': Act0DecisionReasoningV1(
    taskId: 'w7_20bb_wider',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: '100bb',
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    stackMatters: true,
    stackNote:
        "The 20 BB stack makes a 4 BB bet leave just 16 BB, so the size must shrink to preserve 18 BB for later bets.",
    preChoiceAssumption: "keep at least 18 BB for later streets",
  ),
  'w7_ajs_btn_25bb_transfer': Act0DecisionReasoningV1(
    taskId: 'w7_ajs_btn_25bb_transfer',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: 'too_fragile_now',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    opponentRead:
        "CO opens A-T suited in the model and pays 7.5 BB but folds the weaker ace to an all-in.",
    stackMatters: true,
    stackNote:
        "From 25 BB, the 7.5 BB raise leaves 17.5 BB behind while the all-in loses the weaker call. This comparison is specific to the given stack and response.",
    preChoiceAssumption:
        "CO calls a raise to 7.5 BB with A-T suited, but folds A-T suited to an all-in.",
  ),
  'w7_ajs_btn_100bb_transfer': Act0DecisionReasoningV1(
    taskId: 'w7_ajs_btn_100bb_transfer',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: 'same_clean_call',
    edgeMechanism: Act0EdgeMechanismV1.keepsWorseIn,
    opponentRead:
        "CO opens weaker aces but folds them to any raise; A-Q and A-K reraise a small raise.",
    stackMatters: false,
    preChoiceAssumption: "CO folds weaker aces to any raise.",
  ),
  'w8_spr_value_size': Act0DecisionReasoningV1(
    taskId: 'w8_spr_value_size',
    kind: Act0DecisionKindV1.table,
    principleId: 'value_vs_worse',
    bestAlternativeOptionId: 'two',
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 2,
    stackMatters: false,
    preChoiceAssumption: "BB calls up to 4 BB with weaker kings",
    suboptimalKinds: {'two': Act0SuboptimalKindV1.clearlyWorse},
  ),
  'w7_top_pair_spr2_transfer': Act0DecisionReasoningV1(
    taskId: 'w7_top_pair_spr2_transfer',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: 'same_as_spr8',
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    stackMatters: false,
    suboptimalKinds: {
      'ignore_stack_pressure': Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  'w7_top_pair_spr8_transfer': Act0DecisionReasoningV1(
    taskId: 'w7_top_pair_spr8_transfer',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: 'stack_irrelevant',
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    stackMatters: false,
    suboptimalKinds: {'stack_irrelevant': Act0SuboptimalKindV1.clearlyWorse},
  ),
  'w7_6max_wider': Act0DecisionReasoningV1(
    taskId: 'w7_6max_wider',
    kind: Act0DecisionKindV1.table,
    principleId: 'position_realizes',
    bestAlternativeOptionId: 'fullring',
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    stackMatters: false,
    preChoiceAssumption:
        "raise to 2.5 BB with at most five players still to act",
  ),
  'w7_fullring_tighter': Act0DecisionReasoningV1(
    taskId: 'w7_fullring_tighter',
    kind: Act0DecisionKindV1.table,
    principleId: 'position_realizes',
    bestAlternativeOptionId: 'wider',
    edgeMechanism: Act0EdgeMechanismV1.avoidsDomination,
    stackMatters: false,
    preChoiceAssumption: "Open A-J suited for 2.5 BB with at most five to act",
  ),
  'w7_format_table_notice': Act0DecisionReasoningV1(
    taskId: 'w7_format_table_notice',
    kind: Act0DecisionKindV1.table,
    principleId: 'stack_depth_changes_play',
    bestAlternativeOptionId: 'open_same',
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    stackMatters: true,
    stackNote:
        "With 18 BB against 42 BB, the shorter stack can bet only 9 BB while holding 9 BB back.",
    preChoiceAssumption: "leaves both players at least 9 BB",
  ),
  'spaced_review_w8_same_hand_different_depth_pot_to_call_v1':
      Act0DecisionReasoningV1(
        taskId: 'spaced_review_w8_same_hand_different_depth_pot_to_call_v1',
        kind: Act0DecisionKindV1.table,
        principleId: 'stack_depth_changes_play',
        bestAlternativeOptionId: 'choice_0',
        edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
        opponentRead:
            "HJ calls with A-T suited at 9 BB, but folds it to all-in.",
        stackMatters: false,
        preChoiceAssumption: "HJ calls a reraise to 9 BB with ATs",
      ),
  'spaced_review_w8_format_pressure_pot_to_call_v1': Act0DecisionReasoningV1(
    taskId: 'spaced_review_w8_format_pressure_pot_to_call_v1',
    kind: Act0DecisionKindV1.table,
    principleId: 'position_realizes',
    bestAlternativeOptionId: 'fold',
    edgeMechanism: Act0EdgeMechanismV1.foldsBetter,
    stackMatters: false,
    preChoiceAssumption:
        "raise JJ to 2.5 BB in an unopened pot if five or fewer players remain behind",
  ),
  'spaced_review_w8_format_pressure_hero_cards_board_pot_v1':
      Act0DecisionReasoningV1(
        taskId: 'spaced_review_w8_format_pressure_hero_cards_board_pot_v1',
        kind: Act0DecisionKindV1.table,
        principleId: 'stack_depth_changes_play',
        bestAlternativeOptionId: 'choice_2',
        edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
        stackMatters: true,
        stackNote:
            "BB can call at most 12 BB. A 2 BB bet gets paid while going all-in for 12 BB gets no weaker calls under the model.",
        preChoiceAssumption: "will call 2 BB and fold to an all-in",
      ),
  "short_stack_spots_draw_deep": Act0DecisionReasoningV1(
    taskId: "short_stack_spots_draw_deep",
    kind: Act0DecisionKindV1.table,
    principleId: "implied_odds",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "HJ bets made hands, such as a king, and the example pays 6 BB more against the completed draw.",
    edgeBb: 0.3043478261,
    stackMatters: true,
    stackNote:
        "HJ has 60 BB left, enough to pay a 6 BB river bet on a hit. Reducing the available payment to 3 BB makes the call lose chips.",
    preChoiceAssumption:
        "The bettor has 60 BB left after betting. Count nine winning rivers out of 46. Assume you win only by hitting, pay nothing more on a miss, and the bettor pays another 6 BB on a hit.",
  ),
  "short_stack_spots_draw_shallow": Act0DecisionReasoningV1(
    taskId: "short_stack_spots_draw_shallow",
    kind: Act0DecisionKindV1.table,
    principleId: "implied_odds",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    opponentRead:
        "HJ bets made hands, calls an all-in, and can pay only 3 BB more when the draw hits.",
    edgeBb: 0.2826086957,
    stackMatters: true,
    stackNote:
        "HJ has 3 BB left, below the roughly 4.44 BB of extra payoff the call needs. The otherwise identical 60 BB spot pays 6 BB and makes a call profitable.",
    preChoiceAssumption:
        "The bettor has 3 BB left after betting. Count nine winning rivers out of 46. You win only by hitting, pay nothing more on a miss after calling, and collect the final 3 BB on a hit. The bettor calls a raise to put the rest in.",
  ),
  "short_stack_spots_set_mine": Act0DecisionReasoningV1(
    taskId: "short_stack_spots_set_mine",
    kind: Act0DecisionKindV1.table,
    principleId: "implied_odds",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    opponentRead:
        "CO opens and pays the modeled amount on a flopped set, up to its remaining stack.",
    edgeBb: 0.2665306122,
    stackMatters: true,
    stackNote:
        "CO has 12.5 BB behind after opening 2.5 BB. A deeper CO can pay the full modeled 18 BB on a hit, reversing the decision.",
    preChoiceAssumption:
        "CO starts with 15 BB. Assume your pair wins only if at least one of the two remaining fours flops, about 11.8%. You pay nothing else on a miss. On a hit CO pays 18 BB more if deep enough, or the rest of a shorter stack.",
  ),
  "short_stack_spots_value_cap": Act0DecisionReasoningV1(
    taskId: "short_stack_spots_value_cap",
    kind: Act0DecisionKindV1.table,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "choice_1",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 3,
    stackMatters: true,
    stackNote:
        "The BB river stack is 6 BB, capping the extra value. At a greater depth the profitable size would depend on what second pair still calls.",
    preChoiceAssumption:
        "BB checks with just a pair of jacks in this example and calls any amount up to the 6 BB left.",
    suboptimalKinds: {"choice_1": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "short_stack_spots_all_in_price": Act0DecisionReasoningV1(
    taskId: "short_stack_spots_all_in_price",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    opponentRead:
        "BTN goes all-in with jacks or ace-jack suited, with all legal combos equally weighted.",
    edgeBb: 2.1098993423,
    stackMatters: true,
    stackNote:
        "BTN has a 10 BB starting stack and no chips left. The price includes the already-posted big blind and there is no possible later payment.",
    preChoiceAssumption:
        "The button only goes all-in with JJ or ace-jack suited here. Each available two-card hand is equally likely. A♥Q♥ has 54.19% equity, counting a tie as half a win.",
  ),
  "w8_big_hand_turn_fold": Act0DecisionReasoningV1(
    taskId: "w8_big_hand_turn_fold",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB checks and raises with sets only. An ace on the river puts the overpair ahead.",
    edgeBb: 4.8181818182,
    stackMatters: false,
    preChoiceAssumption:
        "BB check-raises the turn only with three of a kind made from a pocket pair. Assume no bets on the river.",
  ),
  "w8_big_hand_river_fold": Act0DecisionReasoningV1(
    taskId: "w8_big_hand_river_fold",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead: "BB bets mostly sets and sometimes a missed spade draw.",
    edgeBb: 8.8,
    stackMatters: false,
    preChoiceAssumption:
        "BB bets sets for value 90% of the time and missed spade draws 10% of the time. Top pair beats every bluff and loses to every value hand.",
  ),
  "w8_unguided_short_read": Act0DecisionReasoningV1(
    taskId: "w8_unguided_short_read",
    kind: Act0DecisionKindV1.table,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "choice_0",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 2,
    stackMatters: true,
    stackNote:
        "The BB river stack has 4 BB left. That is the most its weaker pair can pay even if you have much more.",
    preChoiceAssumption:
        "BB has 4 BB left and calls with a pair of nines at any size. In this example you always win when called.",
  ),
  "spaced_review_w8_short_draw_cap_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w8_short_draw_cap_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "implied_odds",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    opponentRead:
        "HJ bets made hands and pays a maximum of 2 BB more on a hit.",
    edgeBb: 0.4782608696,
    stackMatters: true,
    stackNote:
        "The 2 BB left caps the implied payment, below the 4.44 BB needed to make this call profitable.",
    preChoiceAssumption:
        "The bettor has 2 BB left after betting. Of 46 rivers, nine win. Assume you lose on a miss, pay no more on a miss, and collect HJ’s last 2 BB on a hit.",
  ),
  "spaced_review_w8_short_all_in_price_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w8_short_all_in_price_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead: "BTN goes all-in with high pairs and strong aces.",
    edgeBb: 2.45,
    stackMatters: true,
    stackNote:
        "BTN has only its 9 BB starting stack to wager. No later payoff can make up for a call below the direct price.",
    preChoiceAssumption:
        "In this example BTN goes all-in with a range of high pairs and stronger aces. Your stated equity is 30%.",
  ),
  "spaced_review_w8_effective_stack_fold_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w8_effective_stack_fold_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead: "BB checks and raises with sets only.",
    edgeBb: 5.7272727273,
    stackMatters: false,
    preChoiceAssumption:
        "BB check-raises the turn only with sets. Assume no further betting.",
  ),
  "spaced_review_w8_depth_fold_v1": Act0DecisionReasoningV1(
    taskId: "spaced_review_w8_depth_fold_v1",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    opponentRead:
        "BB bets two pair or better for value and missed spade draws as bluffs.",
    edgeBb: 5.1,
    stackMatters: false,
    preChoiceAssumption:
        "BB bets two pair or better 85% of the time and missed spade draws 15% of the time. Your ace beats only the bluffs.",
  ),
};
