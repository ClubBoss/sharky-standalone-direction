import 'dart:convert';

import 'package:test/test.dart';

import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui/session_player/spot_specs.dart' as specs;

UiSpot _spotFromSaved(Map<String, Object?> json) {
  final kindIndex = json['k'] as int;
  return UiSpot(
    kind: SpotKind.values[kindIndex],
    hand: json['h'] as String,
    pos: json['p'] as String,
    stack: json['s'] as String,
    action: json['a'] as String,
    vsPos: json['v'] as String?,
    limpers: json['l'] as String?,
    explain: json['e'] as String?,
  );
}

UiAnswer _answerFromSaved(Map<String, Object?> json) => UiAnswer(
  correct: json['correct'] as bool,
  expected: json['expected'] as String,
  chosen: json['chosen'] as String,
  elapsed: Duration(milliseconds: json['elapsedMs'] as int),
);

void main() {
  group('MVS player smoke', () {
    test('round-trips saved jam-vs session payload', () {
      final savedSpots = [
        {
          'k': SpotKind.l3_flop_jam_vs_raise.index,
          'h': 'AKs',
          'p': 'BTN',
          's': '25bb',
          'a': 'jam',
          'v': 'BB',
        },
        {
          'k': SpotKind.l3_turn_jam_vs_raise.index,
          'h': 'QQ',
          'p': 'CO',
          's': '30bb',
          'a': 'fold',
          'v': 'BTN',
        },
      ];
      final savedAnswers = [
        {
          'correct': true,
          'expected': 'jam',
          'chosen': 'jam',
          'elapsedMs': 1400,
        },
        {
          'correct': false,
          'expected': 'jam',
          'chosen': 'fold',
          'elapsedMs': 2200,
        },
      ];

      final encoded = jsonEncode({
        'spots': savedSpots,
        'answers': savedAnswers,
      });
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final spots = (decoded['spots'] as List)
          .cast<Map<String, Object?>>()
          .map(_spotFromSaved)
          .toList();
      final answers = (decoded['answers'] as List)
          .cast<Map<String, Object?>>()
          .map(_answerFromSaved)
          .toList();

      expect(spots, hasLength(savedSpots.length));
      expect(answers, hasLength(savedAnswers.length));

      final usedKinds = spots.map((s) => s.kind).toSet();
      expect(
        usedKinds.every(specs.actionsMap.containsKey),
        isTrue,
        reason: 'Saved session kinds should be present in actionsMap',
      );
      final dedupKeys = spots.map(specs.jamDedupKey).toSet();
      expect(
        dedupKeys.length,
        spots.length,
        reason: 'jamDedupKey should de-duplicate identical jam flows',
      );

      final outcome = specs.computeLadderOutcome(answers);
      expect(outcome.total, answers.length);
      expect(outcome.accPct, greaterThanOrEqualTo(0));
      expect(outcome.avgMs, greaterThan(0));
    });

    test('auto replay guard toggles only for failing jam/fold spots', () {
      final jamKind = SpotKind.l3_river_jam_vs_raise;
      final nonJamKind = SpotKind.l2_threebet_push;

      expect(
        specs.shouldAutoReplay(
          correct: false,
          autoWhy: true,
          kind: jamKind,
          alreadyReplayed: false,
        ),
        isTrue,
      );
      expect(
        specs.shouldAutoReplay(
          correct: true,
          autoWhy: true,
          kind: jamKind,
          alreadyReplayed: false,
        ),
        isFalse,
      );
      expect(
        specs.shouldAutoReplay(
          correct: false,
          autoWhy: true,
          kind: nonJamKind,
          alreadyReplayed: false,
        ),
        isFalse,
      );
    });
  });
}
