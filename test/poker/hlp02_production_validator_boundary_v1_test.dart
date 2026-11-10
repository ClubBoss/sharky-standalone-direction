// HLP-02 boundary checks using existing production parser / W2 showdown
// validator. This is NOT a second evaluator and it does not expand the
// validator's declared supported domain.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_showdown_truth_validator_v1.dart';

final Map<String, dynamic> _baseSpec = jsonDecode(File(
  'content/worlds/world2/v1/sessions/w2.s01/drills/'
  'd.choose_hero_top_pair_showdown.json',
).readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _quadsSpecJson() {
  final fixtures = jsonDecode(File(
    'test/poker/fixtures/hlp02_reference_golden_en_v1.json',
  ).readAsStringSync()) as Map<String, dynamic>;
  final spot = (fixtures['showdown_cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .singleWhere((row) => row['id'] == 'showdown.quads_over_full_house');
  final raw = jsonDecode(jsonEncode(_baseSpec)) as Map<String, dynamic>;
  // Reuse only the production schema, not its top-pair narrative. This is
  // test-only copy for the existing golden; the production donor is unchanged.
  raw['id'] = 'hlp02_quads_over_full_house';
  raw['hero_hole_cards_v1'] = spot['hero_hole'];
  raw['villain_hole_cards_v1'] = spot['villain_hole'];
  raw['board_cards_v1'] = spot['board'];
  raw['expected'] = <String, Object?>{
    'actionId': (spot['expected'] as Map<String, dynamic>)['winner'],
  };
  raw['prompt'] = 'Showdown check: Hero has four nines. '
      'Villain has nines full of sevens. Who wins?';
  raw['intro_v1'] = 'Compare the visible five-card hands.';
  raw['why_v1'] = 'Four nines outrank nines full of sevens.';
  raw['feedback_correct_v1'] = 'Correct. Hero wins with four nines.';
  raw['feedback_incorrect_v1'] = 'Incorrect. Four nines outrank '
      'nines full of sevens, so Hero wins.';
  raw['recap_v1'] = 'Four of a kind outranks a full house.';
  return raw;
}

DrillSpecV1 _spec({
  required Object? board,
  required Object? hero,
  required Object? villain,
  String expectedActionId = 'hero',
}) {
  final raw = jsonDecode(jsonEncode(_baseSpec)) as Map<String, dynamic>;
  raw['hero_hole_cards_v1'] = hero;
  raw['villain_hole_cards_v1'] = villain;
  raw['board_cards_v1'] = board;
  raw['expected'] = <String, Object?>{'actionId': expectedActionId};
  return DrillSpecV1.fromJson(raw);
}

bool _completeUniqueRiver(Object? board, Object? hero, Object? villain) {
  if (board is! List || hero is! List || villain is! List ||
      board.length != 5 || hero.length != 2 || villain.length != 2) {
    return false;
  }
  final all = <dynamic>[...board, ...hero, ...villain];
  final card = RegExp(r'^[2-9TJQKA][shdc]$');
  return all.length == 9 &&
      all.every((value) => value is String && card.hasMatch(value)) &&
      all.toSet().length == 9;
}

void main() {
  test('production W2 validator accepts consistent quads/full house spec', () {
    final spec = DrillSpecV1.fromJson(_quadsSpecJson());
    final result = deriveWorld2ShowdownTruthV1(spec);
    expect(result.winner, World2ShowdownWinnerTruthV1.hero);
    expect(
      validateWorld2ShowdownTruthSpecV1(
        spec: spec,
        source: 'hlp02.quads_fixture',
      ),
      isEmpty,
    );
  });

  test('production validator rejects an author-keyed wrong winner', () {
    final validRaw = _quadsSpecJson();
    final wrongRaw = jsonDecode(jsonEncode(validRaw)) as Map<String, dynamic>;
    wrongRaw['expected'] = <String, Object?>{'actionId': 'villain'};
    expect(
      Map<String, dynamic>.from(wrongRaw)..remove('expected'),
      Map<String, dynamic>.from(validRaw)..remove('expected'),
      reason: 'Only the expected winner differs from the positive case',
    );
    final issues = validateWorld2ShowdownTruthSpecV1(
      spec: DrillSpecV1.fromJson(wrongRaw),
      source: 'hlp02.quads_fixture',
    );
    expect(issues, hasLength(1));
    expect(issues.single, contains('expected winner'));
  });

  test('duplicate inside Hero seven cards is not accepted by the solver', () {
    final spec = _spec(
      board: const <String>['As', '4c', '5d', '6h', '7s'],
      hero: const <String>['As', 'Kd'],
      villain: const <String>['Qs', 'Jh'],
    );
    expect(
      () => deriveWorld2ShowdownTruthV1(spec),
      throwsA(anything),
    );
  });

  test('incomplete five-card showdown cannot produce a winner', () {
    final cases = <({Object? board, Object? hero, Object? villain})>[
      (
        board: const <String>['Ah', '3d', '4c', '8s', '2d'],
        hero: const <String>['As', 'Ks'],
        villain: null,
      ),
      (
        board: const <String>['8h', '9d', 'Tc', 'Jc'],
        hero: const <String>['As', 'Kd'],
        villain: const <String>['Qc', '3d'],
      ),
    ];
    for (final input in cases) {
      expect(
        _completeUniqueRiver(input.board, input.hero, input.villain),
        isFalse,
      );
      try {
        final spec = _spec(
          board: input.board,
          hero: input.hero,
          villain: input.villain,
        );
        // Production validator SKIPS unsupported shapes; empty issues must
        // never be interpreted as a successful showdown or acceptance.
        expect(
          validateWorld2ShowdownTruthSpecV1(
            spec: spec,
            source: 'hlp02.incomplete',
          ),
          isEmpty,
        );
        expect(() => deriveWorld2ShowdownTruthV1(spec), throwsStateError);
      } on FormatException {
        // Earlier parsing rejection is also safe: no derived verdict exists.
      }
    }
  });

  test('null private card fails production parsing', () {
    expect(
      () => _spec(
        board: const <String>['2c', '3d', '4h'],
        hero: <Object?>['As', null],
        villain: const <String>['Kd', 'Qd'],
      ),
      throwsFormatException,
    );
  });

  test('cross-player duplicate is OUTSIDE W2 validator deck preflight', () {
    // W2 derives hero and villain hands separately, so the production
    // validator does NOT certify uniqueness across both opponents' holes.
    // Fail closed at fixture/import input, do not claim W2 catches this case.
    expect(
      _completeUniqueRiver(
        const <String>['2c', '4d', '6h', '8s', 'Td'],
        const <String>['Ah', 'Kd'],
        const <String>['Ah', 'Qc'],
      ),
      isFalse,
    );
  });
}
