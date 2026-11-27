import 'act0_decision_reasoning_v1.dart';

// B146c: definitions from the accepted spec; catalog registers introduction in W10.
// value_vs_frequent_caller: Value bet when enough worse hands tend to call; check or choose a smaller size when the continuing range makes that better.
// respect_rare_raise: A rare raise may be value-heavy; compare the modeled winning share with the actual call price rather than assuming every raise is strong.
const act0DecisionReasoningOpponentTypesV1 = <String, Act0DecisionReasoningV1>{
  "opponent_types_p01_loose_passive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p01_loose_passive",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_frequent_caller",
    bestAlternativeOptionId: "bet_4",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 1.21739,
    opponentRead:
        "BB’s check can conceal stronger hands, but this frequent caller tends to pay with weaker kings and eights.",
    preChoiceAssumption:
        "Loose-passive: this player tends to call river bets with weaker pairs, even fairly large bets. BB has checked the river (pot 11.5 BB, nothing to call). In this study model, BB can have any legal combo of KQ KT K9 88 44 87 76s, all equally weighted. A check ends the hand. Against 4 BB, BB calls KQ KT K9 88 44 87; against 8 BB, BB calls KQ KT K9 88 44 87. Other listed hands fold; no raises are modeled. This is a simplified range model, not a guarantee about a real player.",
    stackMatters: false,
    stackNote:
        "Both offered bets fit the 100 BB starting stacks; there is no later street.",
    suboptimalKinds: {
      "check": Act0SuboptimalKindV1.clearlyWorse,
      "bet_4": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "opponent_types_p01_tight_passive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p01_tight_passive",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_frequent_caller",
    bestAlternativeOptionId: "bet_4",
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    edgeBb: 1.21739,
    opponentRead:
        "BB’s check need not mean weakness; this selective caller may still hold a stronger king or set.",
    preChoiceAssumption:
        "Tight-passive: this player tends to check and give up weaker pairs against river bets. BB has checked the river (pot 11.5 BB, nothing to call). In this study model, BB can have any legal combo of KQ KT K9 88 44 87 76s, all equally weighted. A check ends the hand. Against 4 BB, BB calls KQ 88 44; against 8 BB, BB calls KQ 88 44. Other listed hands fold; no raises are modeled. This is a simplified range model, not a guarantee about a real player.",
    stackMatters: false,
    stackNote:
        "Both offered bets fit the 100 BB starting stacks; there is no later street.",
    suboptimalKinds: {
      "bet_4": Act0SuboptimalKindV1.clearlyWorse,
      "bet_8": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "opponent_types_p02_loose_passive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p02_loose_passive",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_frequent_caller",
    bestAlternativeOptionId: "bet_5",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 1.05263,
    opponentRead:
        "BB’s check leaves weaker queens and nines that may pay even a larger bet.",
    preChoiceAssumption:
        "Loose-passive: this player tends to call down with marginal pairs. BB has checked the river (pot 15.5 BB, nothing to call). In this study model, BB can have any legal combo of AQ KQ QT Q8 Q7 Q5 99 96 98 87s, all equally weighted. A check ends the hand. Against 5 BB, BB calls AQ KQ QT Q8 Q7 Q5 99 96 98; against 10 BB, BB calls AQ KQ QT Q8 Q7 Q5 99 96 98. Other listed hands fold; no raises are modeled. This is a simplified range model, not a guarantee about a real player.",
    stackMatters: false,
    stackNote:
        "Both offered bets fit the 100 BB starting stacks; there is no later street.",
    suboptimalKinds: {
      "check": Act0SuboptimalKindV1.clearlyWorse,
      "bet_5": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "opponent_types_p02_tight_aggressive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p02_tight_aggressive",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_frequent_caller",
    bestAlternativeOptionId: "bet_5",
    edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
    edgeBb: 1.84211,
    opponentRead:
        "BB can check stronger queens or two pair; the tighter continuing range gives worse queens little weight.",
    preChoiceAssumption:
        "Tight-aggressive: this player tends to release marginal pairs when facing a river bet after checking. BB has checked the river (pot 15.5 BB, nothing to call). In this study model, BB can have any legal combo of AQ KQ QT Q8 Q7 Q5 99 96 98 87s, all equally weighted. A check ends the hand. Against 5 BB, BB calls AQ KQ 99 96; against 10 BB, BB calls AQ KQ 99 96. Other listed hands fold; no raises are modeled. This is a simplified range model, not a guarantee about a real player.",
    stackMatters: false,
    stackNote:
        "Both offered bets fit the 100 BB starting stacks; there is no later street.",
    suboptimalKinds: {
      "bet_5": Act0SuboptimalKindV1.clearlyWorse,
      "bet_10": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "opponent_types_p03_loose_passive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p03_loose_passive",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_frequent_caller",
    bestAlternativeOptionId: "bet_4",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 3.51852,
    opponentRead:
        "BB may hold a set, but frequent calls with weaker tens can make a larger value bet worthwhile.",
    preChoiceAssumption:
        "Loose-passive: this player tends to stick with top pair even against larger river bets. BB has checked the river (pot 15.5 BB, nothing to call). In this study model, BB can have any legal combo of KT QT JT T9 77 55 76 86s, all equally weighted. A check ends the hand. Against 4 BB, BB calls KT QT JT T9 77 55 76; against 9 BB, BB calls KT QT JT T9 77 55 76. Other listed hands fold; no raises are modeled. This is a simplified range model, not a guarantee about a real player.",
    stackMatters: false,
    stackNote:
        "Both offered bets fit the 100 BB starting stacks; there is no later street.",
    suboptimalKinds: {
      "check": Act0SuboptimalKindV1.clearlyWorse,
      "bet_4": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "opponent_types_p03_tight_aggressive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p03_tight_aggressive",
    kind: Act0DecisionKindV1.table,
    principleId: "value_vs_frequent_caller",
    bestAlternativeOptionId: "bet_9",
    edgeMechanism: Act0EdgeMechanismV1.moreValueFromWorse,
    edgeBb: 1.59259,
    opponentRead:
        "BB may pay a modest size with weaker tens, but the larger-size callers are more concentrated around strong hands.",
    preChoiceAssumption:
        "Tight-aggressive: this player tends to defend top pair against a modest river bet but release weaker kickers against larger bets. BB has checked the river (pot 15.5 BB, nothing to call). In this study model, BB can have any legal combo of KT QT JT T9 77 55 76 86s, all equally weighted. A check ends the hand. Against 4 BB, BB calls KT QT JT T9 77 55; against 9 BB, BB calls KT 77 55. Other listed hands fold; no raises are modeled. This is a simplified range model, not a guarantee about a real player.",
    stackMatters: false,
    stackNote:
        "Both offered bets fit the 100 BB starting stacks; there is no later street.",
    suboptimalKinds: {
      "check": Act0SuboptimalKindV1.clearlyWorse,
      "bet_9": Act0SuboptimalKindV1.clearlyWorse,
    },
  ),
  "opponent_types_p04_tight_passive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p04_tight_passive",
    kind: Act0DecisionKindV1.table,
    principleId: "respect_rare_raise",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    edgeBb: 6.45,
    opponentRead:
        "BB’s rare check-raise tends to be weighted toward sets; a missed draw remains possible.",
    preChoiceAssumption:
        "Tight-passive: this player rarely check-raises with anything weaker than two pair; occasional bluffs are possible. BB checks, then raises all-in to 14.5 BB total after your 4 BB bet. For this study model, the raising range is 99 55 33 8s7s, with each legal combo equally weighted. The model includes only the stated possibilities, not a certain read of BB’s cards. The pot is 30 BB; calling 10.5 BB costs 25.9% of the final pot. Calling ends betting.",
    stackMatters: true,
    stackNote:
        "Both players started with the same short stack. The raise is all-in, so no further raise is possible; a deeper stack can change the options.",
  ),
  "opponent_types_p04_loose_aggressive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p04_loose_aggressive",
    kind: Act0DecisionKindV1.table,
    principleId: "respect_rare_raise",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    edgeBb: 12.64286,
    opponentRead:
        "BB’s check-raise can include sets and missed draws; the latter have meaningful weight.",
    preChoiceAssumption:
        "Loose-aggressive: this player tends to check-raise both strong hands and many missed draws. BB checks, then raises all-in to 14.5 BB total after your 4 BB bet. For this study model, the raising range is 99 55 33 87s 76s T8s, with each legal combo equally weighted. The model includes only the stated possibilities, not a certain read of BB’s cards. The pot is 30 BB; calling 10.5 BB costs 25.9% of the final pot. Calling ends betting.",
    stackMatters: true,
    stackNote:
        "Both players started with the same short stack. The raise is all-in, so no further raise is possible; a deeper stack can change the options.",
  ),
  "opponent_types_p05_tight_aggressive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p05_tight_aggressive",
    kind: Act0DecisionKindV1.table,
    principleId: "respect_rare_raise",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    edgeBb: 9.61538,
    opponentRead:
        "BB’s large raise tends to represent sets or two pair, though a busted draw is still possible.",
    preChoiceAssumption:
        "Tight-aggressive: this player tends to make large river check-raises mostly with strong value hands, with a few missed draws. BB checks, then raises all-in to 18.5 BB total after your 5 BB bet. For this study model, the raising range is TT 77 KT AdJd, with each legal combo equally weighted. The model includes only the stated possibilities, not a certain read of BB’s cards. The pot is 37 BB; calling 13.5 BB costs 26.7% of the final pot. Calling ends betting.",
    stackMatters: true,
    stackNote:
        "Both players started with the same short stack. The raise is all-in, so no further raise is possible; a deeper stack can change the options.",
  ),
  "opponent_types_p05_very_loose_aggressive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p05_very_loose_aggressive",
    kind: Act0DecisionKindV1.table,
    principleId: "respect_rare_raise",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    edgeBb: 23.22727,
    opponentRead:
        "BB’s raise can represent sets, two pair or a broad set of weaker missed hands.",
    preChoiceAssumption:
        "Very loose-aggressive: this player tends to make large river check-raises with many missed draws as well as strong hands. BB checks, then raises all-in to 18.5 BB total after your 5 BB bet. For this study model, the raising range is TT 77 KT AJ QJ J9s, with each legal combo equally weighted. The model includes only the stated possibilities, not a certain read of BB’s cards. The pot is 37 BB; calling 13.5 BB costs 26.7% of the final pot. Calling ends betting.",
    stackMatters: true,
    stackNote:
        "Both players started with the same short stack. The raise is all-in, so no further raise is possible; a deeper stack can change the options.",
  ),
  "opponent_types_p06_loose_passive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p06_loose_passive",
    kind: Act0DecisionKindV1.table,
    principleId: "respect_rare_raise",
    bestAlternativeOptionId: "call",
    edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
    edgeBb: 6.61538,
    opponentRead:
        "BB’s change from calling to raising is more consistent with sets or two pair than missed draws in this model.",
    preChoiceAssumption:
        "Loose-passive: this player tends to call with weaker hands and rarely check-raises without strong value. An occasional bluff is possible. BB checks, then raises all-in to 16.5 BB total after your 6 BB bet. For this study model, the raising range is 88 66 98 Js7s, with each legal combo equally weighted. The model includes only the stated possibilities, not a certain read of BB’s cards. The pot is 40 BB; calling 10.5 BB costs 20.8% of the final pot. Calling ends betting.",
    stackMatters: true,
    stackNote:
        "Both players started with the same short stack. The raise is all-in, so no further raise is possible; a deeper stack can change the options.",
  ),
  "opponent_types_p06_loose_aggressive": Act0DecisionReasoningV1(
    taskId: "opponent_types_p06_loose_aggressive",
    kind: Act0DecisionKindV1.table,
    principleId: "respect_rare_raise",
    bestAlternativeOptionId: "fold",
    edgeMechanism: Act0EdgeMechanismV1.priceBeatsEquity,
    edgeBb: 23.16667,
    opponentRead:
        "BB’s check-raise may contain sets or two pair, but plenty of missed draws can also take this line.",
    preChoiceAssumption:
        "Loose-aggressive: this player tends to turn missed draws into river check-raises more often. BB checks, then raises all-in to 16.5 BB total after your 6 BB bet. For this study model, the raising range is 88 66 98 J7s JT Q7s, with each legal combo equally weighted. The model includes only the stated possibilities, not a certain read of BB’s cards. The pot is 40 BB; calling 10.5 BB costs 20.8% of the final pot. Calling ends betting.",
    stackMatters: true,
    stackNote:
        "Both players started with the same short stack. The raise is all-in, so no further raise is possible; a deeper stack can change the options.",
  ),
};
