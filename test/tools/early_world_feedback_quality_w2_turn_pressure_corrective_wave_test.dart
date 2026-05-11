import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('w2 turn-pressure trio keeps corrective misses distinct and action-guiding', () {
    final repoRoot = Directory.current.path;
    final expectations = <String, List<String>>{
      'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_turn_bet.json':
          <String>['Folding gives up too much', 'raising overstates'],
      'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_fold_facing_turn_bet.json':
          <String>['Calling pays too much', 'should simply release'],
      'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_turn_pressure.json':
          <String>['raising back now', 'absorbs pressure', 'fold equity'],
    };

    final bannedPhrases = <String>{
      'works by',
      'approved pressure counter',
      'this turn pressure branch',
    };

    for (final entry in expectations.entries) {
      final file = File('$repoRoot/${entry.key}');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final feedbackCorrect = json['feedback_correct_v1'] as String?;
      final feedbackIncorrect = json['feedback_incorrect_v1'] as String?;

      expect(
        feedbackIncorrect,
        isNotNull,
        reason: '${entry.key} should keep authored corrective feedback.',
      );
      expect(
        feedbackIncorrect,
        isNot('Incorrect.'),
        reason:
            '${entry.key} should not regress to generic corrective feedback.',
      );
      expect(
        feedbackIncorrect,
        isNot(equals(feedbackCorrect)),
        reason:
            '${entry.key} incorrect feedback should not duplicate the positive line.',
      );

      for (final snippet in entry.value) {
        expect(
          feedbackIncorrect,
          contains(snippet),
          reason: '${entry.key} should teach the corrective reason explicitly.',
        );
      }
      for (final banned in bannedPhrases) {
        expect(
          feedbackIncorrect,
          isNot(contains(banned)),
          reason:
              '${entry.key} should avoid weak branch-like corrective wording.',
        );
      }
    }
  });
}
