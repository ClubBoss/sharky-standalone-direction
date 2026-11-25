import 'act0_decision_reasoning_v1.dart';

const act0DecisionReasoningB19V1 = <String, Act0DecisionReasoningV1>{
  "mistake_half_pot": Act0DecisionReasoningV1(
    taskId: "mistake_half_pot",
    kind: Act0DecisionKindV1.process,
    principleId: "smallest_size_same_job",
    bestAlternativeOptionId: "open",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "You told a study partner you would bet half the river pot. Review these annotated actions. BTN opens to 2.75 BB and BB calls. The flop and turn then check through.",
  ),
  "mistake_minimum_raise": Act0DecisionReasoningV1(
    taskId: "mistake_minimum_raise",
    kind: Act0DecisionKindV1.process,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "lead",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "Review the actions with enough chips for a full raise. BB led on the turn. Only one annotation breaks the betting rule.",
  ),
  "mistake_already_committed": Act0DecisionReasoningV1(
    taskId: "mistake_already_committed",
    kind: Act0DecisionKindV1.process,
    principleId: "blind_price_defense",
    bestAlternativeOptionId: "first_bet",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "The replay pauses before BTN responds to the flop raise. Both players can afford the full match. The three annotations include one claimed amount.",
  ),
  "mistake_turn_straight_call": Act0DecisionReasoningV1(
    taskId: "mistake_turn_straight_call",
    kind: Act0DecisionKindV1.process,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "check",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "Replay stops before the river. Under the teaching model the legal winning rivers are the four fives and four tens. You know your cards and the turn board, no ties or later chips. BB led 4 BB on the turn.",
  ),
  "mistake_turn_flush_fold": Act0DecisionReasoningV1(
    taskId: "mistake_turn_flush_fold",
    kind: Act0DecisionKindV1.process,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "count",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "The study model counts all nine unseen hearts as winning rivers and the other rivers as losses. There are no ties, raises or later betting. BB leads 1 BB on the turn.",
  ),
  "mistake_worse_calls": Act0DecisionReasoningV1(
    taskId: "mistake_worse_calls",
    kind: Act0DecisionKindV1.process,
    principleId: "value_vs_worse",
    bestAlternativeOptionId: "flop",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "For this replay only, BB calls a 3 BB river bet with K-J or K-T and folds Q-J. Weight every legal combination equally. The earlier checks are given history.",
  ),
  "mistake_bluff_calls": Act0DecisionReasoningV1(
    taskId: "mistake_bluff_calls",
    kind: Act0DecisionKindV1.process,
    principleId: "folds_better",
    bestAlternativeOptionId: "price",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB checks the river. At 3 BB and 7 BB the equally weighted teaching roster calls KcQd 8h9h 7h7c 4s5s KcJc 8hTc and folds Ah7h Qs7s Qd9d As9s. Your hand loses to every holding on a showdown. Review BTN’s proposed line.",
  ),
  "mistake_known_blocker": Act0DecisionReasoningV1(
    taskId: "mistake_known_blocker",
    kind: Act0DecisionKindV1.process,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "board",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "The river review compares all K-Q combinations without suit restrictions. Ks is on the board and Kh is in your hand. No queen is visible. These are notes made before a choice; there is no result shown.",
  ),
  "mistake_matched_amount": Act0DecisionReasoningV1(
    taskId: "mistake_matched_amount",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "dead_sb",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "After preflop BTN and BB each contributed 2.5 BB. On the river BB pushes its last 15 BB. BTN has 6 BB behind. The action line includes the full announced wager. The displayed pot caps the wager at the 6 BB you can match.",
  ),
  "mistake_implied_cap": Act0DecisionReasoningV1(
    taskId: "mistake_implied_cap",
    kind: Act0DecisionKindV1.process,
    principleId: "implied_odds",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "Study replay: BB leads 3 BB on the turn. After a matching call, BB has 3 BB left. BTN has at least that much. The model treats nine rivers as clean and lets BB pay its whole remaining stack on each hit.",
  ),
  "turn_heart_completes": Act0DecisionReasoningV1(
    taskId: "turn_heart_completes",
    kind: Act0DecisionKindV1.process,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is KsKd KcKd 8s8d, with equal weight per legal combo on each street. Compare a 2c turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_heart_pairs_board": Act0DecisionReasoningV1(
    taskId: "turn_heart_pairs_board",
    kind: Act0DecisionKindV1.process,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is KsKd KcKd 8s8d, with equal weight per legal combo on each street. Compare a Qh turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_straight_completes": Act0DecisionReasoningV1(
    taskId: "turn_straight_completes",
    kind: Act0DecisionKindV1.process,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is AsAd AcAs QhQc, with equal weight per legal combo on each street. Compare a 2d turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_overcard_beats_pair": Act0DecisionReasoningV1(
    taskId: "turn_overcard_beats_pair",
    kind: Act0DecisionKindV1.process,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is AcKc AdKd AcTd, with equal weight per legal combo on each street. Compare a 2c turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_remove_high_draw": Act0DecisionReasoningV1(
    taskId: "turn_remove_high_draw",
    kind: Act0DecisionKindV1.process,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is AhKc AhJc ThTc Ah9h, with equal weight per legal combo on each street. Compare a As turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_counterfeit_two_pair": Act0DecisionReasoningV1(
    taskId: "turn_counterfeit_two_pair",
    kind: Act0DecisionKindV1.process,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is AcAd AsAh QcQd, with equal weight per legal combo on each street. Compare a 2c turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_redraw_good": Act0DecisionReasoningV1(
    taskId: "turn_redraw_good",
    kind: Act0DecisionKindV1.process,
    principleId: "stack_depth_changes_play",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is AhJh AhTh QhJh, with equal weight per legal combo on each street. Compare a 2h turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_board_four_to_straight": Act0DecisionReasoningV1(
    taskId: "turn_board_four_to_straight",
    kind: Act0DecisionKindV1.process,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is JdTd JcTh Tc5c, with equal weight per legal combo on each street. Compare a 2c turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_dead_draw": Act0DecisionReasoningV1(
    taskId: "turn_dead_draw",
    kind: Act0DecisionKindV1.process,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "good",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is Js8s JsTs Js9s, with equal weight per legal combo on each street. Compare a 3c turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "turn_turn_makes_set": Act0DecisionReasoningV1(
    taskId: "turn_turn_makes_set",
    kind: Act0DecisionKindV1.process,
    principleId: "implied_odds",
    bestAlternativeOptionId: "unchanged",
    edgeMechanism: Act0EdgeMechanismV1.processRule,
    preChoiceAssumption:
        "BB’s study range is AhQh AsKd AcJd, with equal weight per legal combo on each street. Compare a 2c turn with the offered alternatives at the stated pot-sized bet. After a call there is no further betting; ties earn half.",
  ),
  "harder_dirty_flush": Act0DecisionReasoningV1(
    taskId: "harder_dirty_flush",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    preChoiceAssumption:
        "Assume BB holds Ks Kd. After a call, see any remaining river and go directly to showdown without more bets. Compare call and fold under this study model.",
    edgeBb: 0.21591,
    opponentRead: "Assume BB holds Ks Kd.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
  ),
  "harder_straight_price_rises": Act0DecisionReasoningV1(
    taskId: "harder_straight_price_rises",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    preChoiceAssumption:
        "Assume BB holds Qh Qs. After a call, see any remaining river and go directly to showdown without more bets. Compare call and fold under this study model.",
    edgeBb: 2.04545,
    opponentRead: "Assume BB holds Qh Qs.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "harder_remove_missed_hearts": Act0DecisionReasoningV1(
    taskId: "harder_remove_missed_hearts",
    kind: Act0DecisionKindV1.table,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    preChoiceAssumption:
        "BB bets each legal combination of 88 44 AhJh AhTh QhJh QhTh with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model.",
    edgeBb: 0.625,
    opponentRead:
        "BB bets each legal combination of 88 44 AhJh AhTh QhJh QhTh with equal weight.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "harder_leave_misses_unblocked": Act0DecisionReasoningV1(
    taskId: "harder_leave_misses_unblocked",
    kind: Act0DecisionKindV1.table,
    principleId: "price_vs_equity",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    preChoiceAssumption:
        "BB bets each legal combination of 99 55 AcKc KcJc QcJc KcTc with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model.",
    edgeBb: 0.25,
    opponentRead:
        "BB bets each legal combination of 99 55 AcKc KcJc QcJc KcTc with equal weight.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
  ),
  "harder_river_value_added": Act0DecisionReasoningV1(
    taskId: "harder_river_value_added",
    kind: Act0DecisionKindV1.table,
    principleId: "range_vs_board",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    preChoiceAssumption:
        "BB bets each legal combination of 88 44 KJ JTs 76s with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model.",
    edgeBb: 12.45455,
    opponentRead:
        "BB bets each legal combination of 88 44 KJ JTs 76s with equal weight.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
  ),
  "harder_paired_river_boats": Act0DecisionReasoningV1(
    taskId: "harder_paired_river_boats",
    kind: Act0DecisionKindV1.table,
    principleId: "board_changes_strength",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    preChoiceAssumption:
        "BB bets each legal combination of 99 44 Q9s JTs 76s with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model.",
    edgeBb: 9.38462,
    opponentRead:
        "BB bets each legal combination of 99 44 Q9s JTs 76s with equal weight.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
  ),
  "harder_worse_calls_larger": Act0DecisionReasoningV1(
    taskId: "harder_worse_calls_larger",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_worse",
    bestAlternativeOptionId: "bet_10",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    preChoiceAssumption:
        "BB has one equally weighted legal combination from KQ QJ QT 99 55 JTs. Checking goes to showdown. At 4 BB BB calls KQ QJ QT 99 55 and folds the rest.  At 10 BB BB calls KQ 99 55 and folds the rest.",
    edgeBb: 1.52942,
    opponentRead: "Compare the listed response groups at each offered size.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
    suboptimalKinds: {
      "bet_10": Act0SuboptimalKindV1.clearlyWorse,
      "check": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "harder_overbet_passes_value": Act0DecisionReasoningV1(
    taskId: "harder_overbet_passes_value",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_worse",
    bestAlternativeOptionId: "bet_5",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    preChoiceAssumption:
        "BB has one equally weighted legal combination from JhTh Th8h 8h6h 99 KK KQ. Checking goes to showdown. At 5 BB BB calls JhTh Th8h 8h6h 99 KK KQ and folds the rest.  At 15 BB BB calls JhTh Th8h 8h6h 99 KK and folds the rest.",
    edgeBb: 2.5,
    opponentRead: "Compare the listed response groups at each offered size.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
    suboptimalKinds: {"bet_5": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "harder_block_weaker_flushes": Act0DecisionReasoningV1(
    taskId: "harder_block_weaker_flushes",
    kind: Act0DecisionKindV1.table,
    principleId: "combos_and_blockers",
    bestAlternativeOptionId: "bet_18",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    preChoiceAssumption:
        "BB has one equally weighted legal combination from QhJh JhTh Th8h 8h6h 99 44 KQ KJ. Checking goes to showdown. At 5 BB BB calls QhJh JhTh Th8h 8h6h 99 44 KQ KJ and folds the rest.  At 18 BB BB calls QhJh JhTh Th8h 8h6h 99 44 and folds the rest.",
    edgeBb: 0.5,
    opponentRead: "Compare the listed response groups at each offered size.",
    stackMatters: false,
    stackNote: "The stated sizes fit both players’ remaining stacks.",
    suboptimalKinds: {"check": Act0SuboptimalKindV1.clearlyWorse},
  ),
  "harder_shorter_implied_payment": Act0DecisionReasoningV1(
    taskId: "harder_shorter_implied_payment",
    kind: Act0DecisionKindV1.table,
    principleId: "implied_odds",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.stackLimitsPayoff,
    preChoiceAssumption:
        "Assume BB holds Ks Kd and starts with 13 BB. If you call and an unpaired heart comes, BB checks and pays a river bet up to 12 BB, capped by its stack. Other rivers check through. Compare call and fold.",
    edgeBb: 0.76136,
    opponentRead:
        "BB holds Ks Kd in this teaching replay. The set pays only on clean hearts and is capped by the remaining effective stack.",
    stackMatters: true,
    stackNote:
        "At 22 BB the opponent can pay 12 extra BB and the call is best; at 13 BB it can pay only 3.",
    suboptimalKinds: {"call": Act0SuboptimalKindV1.clearlyWorse},
  ),
};
