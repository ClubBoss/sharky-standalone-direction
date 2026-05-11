import 'package:poker_analyzer/engine_v2/decision/decision_bar_v1.dart';
import 'package:poker_analyzer/engine_v2/model/money_state_v1.dart';
import 'package:test/test.dart';

void main() {
  const hero = PlayerIdV1('hero');

  test('toCall==0 enables CHECK and disables CALL', () {
    final model = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: 0,
      currentBet: 0,
      minRaiseTo: 10,
      pot: 30,
      heroStack: 100,
      heroCommitted: 0,
      legalActions: const <DecisionLegalKindV1>{
        DecisionLegalKindV1.fold,
        DecisionLegalKindV1.callCheck,
        DecisionLegalKindV1.betRaise,
      },
    );
    final check = model.options.firstWhere((o) => o.label == 'CHECK');
    final call = model.options.firstWhere((o) => o.label == 'CALL');
    expect(check.enabled, isTrue);
    expect(call.enabled, isFalse);
  });

  test('toCall>0 and stack>=toCall enables CALL and disables CHECK', () {
    final model = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: 15,
      currentBet: 15,
      minRaiseTo: 30,
      pot: 45,
      heroStack: 100,
      heroCommitted: 0,
      legalActions: const <DecisionLegalKindV1>{
        DecisionLegalKindV1.fold,
        DecisionLegalKindV1.callCheck,
        DecisionLegalKindV1.betRaise,
      },
    );
    final check = model.options.firstWhere((o) => o.label == 'CHECK');
    final call = model.options.firstWhere((o) => o.label == 'CALL');
    expect(check.enabled, isFalse);
    expect(call.enabled, isTrue);
  });

  test('BET sizes are deterministic and capped by stack', () {
    final model = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: 0,
      currentBet: 0,
      minRaiseTo: 10,
      pot: 90,
      heroStack: 20,
      heroCommitted: 0,
      legalActions: const <DecisionLegalKindV1>{DecisionLegalKindV1.betRaise},
    );
    final betThird = model.options.firstWhere((o) => o.label == 'BET 1/3');
    final betHalf = model.options.firstWhere((o) => o.label == 'BET 1/2');
    final betPot = model.options.firstWhere((o) => o.label == 'BET POT');
    expect(betThird.action.amount, 20);
    expect(betHalf.action.amount, 20);
    expect(betPot.action.amount, 20);
    expect(betThird.enabled, isTrue);
    expect(betHalf.enabled, isTrue);
    expect(betPot.enabled, isTrue);
  });

  test('RAISE_TO respects minRaiseTo and deterministic ordering', () {
    final model = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: 10,
      currentBet: 10,
      minRaiseTo: 24,
      pot: 40,
      heroStack: 100,
      heroCommitted: 0,
      legalActions: const <DecisionLegalKindV1>{DecisionLegalKindV1.betRaise},
    );
    final raiseMin = model.options.firstWhere((o) => o.label == 'RAISE MIN');
    expect(raiseMin.action.amount, 24);
    expect(raiseMin.enabled, isTrue);
  });

  test('options ordering is stable', () {
    final model = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: 5,
      currentBet: 5,
      minRaiseTo: 12,
      pot: 20,
      heroStack: 40,
      heroCommitted: 0,
      legalActions: const <DecisionLegalKindV1>{
        DecisionLegalKindV1.fold,
        DecisionLegalKindV1.callCheck,
        DecisionLegalKindV1.betRaise,
      },
    );
    expect(
      model.options.map((o) => o.label).toList(),
      equals(const <String>[
        'FOLD',
        'CHECK',
        'CALL',
        'BET 1/3',
        'BET 1/2',
        'BET POT',
        'RAISE MIN',
        'RAISE 2X',
        'RAISE POT',
      ]),
    );
  });

  test('pilot bet-sizing preset ids map only supported sizing options', () {
    final model = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: 10,
      currentBet: 10,
      minRaiseTo: 24,
      pot: 60,
      heroStack: 100,
      heroCommitted: 0,
      legalActions: const <DecisionLegalKindV1>{
        DecisionLegalKindV1.fold,
        DecisionLegalKindV1.callCheck,
        DecisionLegalKindV1.betRaise,
      },
    );

    String? presetFor(String label) => model.options
        .firstWhere((o) => o.label == label)
        .pilotBetSizingPresetId;

    expect(presetFor('BET 1/3'), 'one_third_pot');
    expect(presetFor('BET 1/2'), 'half_pot');
    expect(presetFor('BET POT'), 'pot');
    expect(presetFor('RAISE MIN'), 'min_raise');
    expect(presetFor('FOLD'), isNull);
    expect(presetFor('CHECK'), isNull);
    expect(presetFor('CALL'), isNull);
    expect(presetFor('RAISE 2X'), isNull);
    expect(presetFor('RAISE POT'), isNull);
    expect(
      model.options
          .where((option) => option.supportsPilotBetSizingChoiceV1)
          .map((option) => option.label)
          .toList(),
      equals(const <String>['BET 1/3', 'BET 1/2', 'BET POT', 'RAISE MIN']),
    );
  });
}
