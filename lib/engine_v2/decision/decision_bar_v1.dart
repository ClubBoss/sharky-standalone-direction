import 'package:poker_analyzer/engine_v2/interop/action_sizing_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/engine_v2/model/money_state_v1.dart';

enum DecisionActionKindV1 { fold, check, call, bet, raiseTo }

enum DecisionActionGroupV1 { left, middle, right }

enum DecisionLegalKindV1 { fold, callCheck, betRaise }

class DecisionActionOptionV1 {
  const DecisionActionOptionV1({
    required this.group,
    required this.kind,
    required this.label,
    required this.enabled,
    required this.action,
    this.pilotBetSizingPresetId,
  });

  final DecisionActionGroupV1 group;
  final DecisionActionKindV1 kind;
  final String label;
  final bool enabled;
  final ActionV1 action;
  final String? pilotBetSizingPresetId;

  bool get supportsPilotBetSizingChoiceV1 => pilotBetSizingPresetId != null;
}

class DecisionBarModelV1 {
  const DecisionBarModelV1({required this.options, required this.debugContext});

  final List<DecisionActionOptionV1> options;
  final Map<String, Object?> debugContext;
}

class DecisionBarV1 {
  const DecisionBarV1._();

  static const List<String> pilotBetSizingPresetIdsV1 = <String>[
    'one_third_pot',
    'half_pot',
    'pot',
    'min_raise',
  ];

  static String? pilotBetSizingDecisionLabelForPresetIdV1(String presetId) {
    switch (presetId.trim().toLowerCase()) {
      case 'one_third_pot':
        return 'BET 1/3';
      case 'half_pot':
        return 'BET 1/2';
      case 'pot':
        return 'BET POT';
      case 'min_raise':
        return 'RAISE MIN';
    }
    return null;
  }

  static DecisionBarModelV1 buildFromSnapshot({
    required PlayerIdV1 heroId,
    required int toCall,
    required int currentBet,
    required int minRaiseTo,
    required int pot,
    required int heroStack,
    required int heroCommitted,
    Set<DecisionLegalKindV1>? legalActions,
  }) {
    final legal = legalActions ?? const <DecisionLegalKindV1>{};
    final hasFold = legal.isEmpty || legal.contains(DecisionLegalKindV1.fold);
    final hasCallCheck =
        legal.isEmpty || legal.contains(DecisionLegalKindV1.callCheck);
    final hasBetRaise =
        legal.isEmpty || legal.contains(DecisionLegalKindV1.betRaise);

    final canCheck = hasCallCheck && toCall == 0;
    final canCall = hasCallCheck && toCall > 0 && heroStack >= toCall;
    final canFold = hasFold;

    final betThird = ActionSizingV1.deterministicBetThirdPot(
      pot: pot,
      stack: heroStack,
    );
    final betHalf = ActionSizingV1.deterministicBetHalfPot(
      pot: pot,
      stack: heroStack,
    );
    final betPot = ActionSizingV1.deterministicBetPot(
      pot: pot,
      stack: heroStack,
    );

    final raiseMin = ActionSizingV1.deterministicRaiseTo(
      minRaiseTo: minRaiseTo,
      currentBet: currentBet,
      toCall: toCall,
      stack: heroStack,
      committed: heroCommitted,
    );
    final raiseDouble = ActionSizingV1.deterministicRaiseToDoubleCurrentBet(
      currentBet: currentBet,
      stack: heroStack,
      committed: heroCommitted,
    );
    final raisePot = ActionSizingV1.deterministicRaiseToPot(
      currentBet: currentBet,
      toCall: toCall,
      pot: pot,
      stack: heroStack,
      committed: heroCommitted,
    );

    final canBet = hasBetRaise && toCall == 0 && heroStack > 0;
    final canRaise =
        hasBetRaise && toCall > 0 && (heroStack + heroCommitted) > currentBet;

    bool raiseIsLegal(int raiseTo) {
      if (!canRaise) return false;
      if (raiseTo <= currentBet) return false;
      final delta = raiseTo - heroCommitted;
      return delta > 0 && delta <= heroStack;
    }

    final options = <DecisionActionOptionV1>[
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.left,
        kind: DecisionActionKindV1.fold,
        label: 'FOLD',
        enabled: canFold,
        action: ActionV1(actorId: heroId, kind: ActionKindV1.fold),
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.middle,
        kind: DecisionActionKindV1.check,
        label: 'CHECK',
        enabled: canCheck,
        action: ActionV1(actorId: heroId, kind: ActionKindV1.check),
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.middle,
        kind: DecisionActionKindV1.call,
        label: 'CALL',
        enabled: canCall,
        action: ActionV1(actorId: heroId, kind: ActionKindV1.call),
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.right,
        kind: DecisionActionKindV1.bet,
        label: 'BET 1/3',
        enabled: canBet && betThird > 0,
        action: ActionV1(
          actorId: heroId,
          kind: ActionKindV1.bet,
          amount: betThird,
        ),
        pilotBetSizingPresetId: 'one_third_pot',
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.right,
        kind: DecisionActionKindV1.bet,
        label: 'BET 1/2',
        enabled: canBet && betHalf > 0,
        action: ActionV1(
          actorId: heroId,
          kind: ActionKindV1.bet,
          amount: betHalf,
        ),
        pilotBetSizingPresetId: 'half_pot',
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.right,
        kind: DecisionActionKindV1.bet,
        label: 'BET POT',
        enabled: canBet && betPot > 0,
        action: ActionV1(
          actorId: heroId,
          kind: ActionKindV1.bet,
          amount: betPot,
        ),
        pilotBetSizingPresetId: 'pot',
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.right,
        kind: DecisionActionKindV1.raiseTo,
        label: 'RAISE MIN',
        enabled: raiseIsLegal(raiseMin),
        action: ActionV1(
          actorId: heroId,
          kind: ActionKindV1.raise,
          amount: raiseMin,
        ),
        pilotBetSizingPresetId: 'min_raise',
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.right,
        kind: DecisionActionKindV1.raiseTo,
        label: 'RAISE 2X',
        enabled: raiseIsLegal(raiseDouble),
        action: ActionV1(
          actorId: heroId,
          kind: ActionKindV1.raise,
          amount: raiseDouble,
        ),
      ),
      DecisionActionOptionV1(
        group: DecisionActionGroupV1.right,
        kind: DecisionActionKindV1.raiseTo,
        label: 'RAISE POT',
        enabled: raiseIsLegal(raisePot),
        action: ActionV1(
          actorId: heroId,
          kind: ActionKindV1.raise,
          amount: raisePot,
        ),
      ),
    ];

    return DecisionBarModelV1(
      options: List<DecisionActionOptionV1>.unmodifiable(options),
      debugContext: <String, Object?>{
        'to_call': toCall,
        'current_bet': currentBet,
        'min_raise_to': minRaiseTo,
        'pot': pot,
        'hero_stack': heroStack,
        'hero_committed': heroCommitted,
      },
    );
  }
}
