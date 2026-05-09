import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 pressure-response family keeps poker-first positive feedback across the admitted subset',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_open_price_ok.json': {
          'why_v1': <String>[
            'playable hand',
            'fair price',
            'forcing extra aggression',
          ],
          'feedback_correct_v1': <String>[
            'fair price',
            'keeps the hand in play',
            'forcing extra aggression',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_turn_bet.json': {
          'why_v1': <String>[
            'turn price is still acceptable',
            'overstretching into a raise',
          ],
          'feedback_correct_v1': <String>[
            'turn bet is still worth continuing against',
            'overstretching into a raise',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_fold_facing_turn_bet.json': {
          'why_v1': <String>[
            'turn price gets too poor',
            'too little value',
          ],
          'feedback_correct_v1': <String>[
            'turn price',
            'no longer earns a continue',
            'disciplined choice',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_open_isolation.json': {
          'why_v1': <String>[
            'Facing one open',
            'isolates weaker continues',
            'fight back now',
          ],
          'feedback_correct_v1': <String>[
            'isolates weaker ranges',
            'applies pressure better than a flat call',
          ],
        },
      };

      final bannedPhrases = <String>{
        'expected in this',
        'expected in this node',
        'expected in this spot',
        'branch is represented',
        'in this set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final feedbackCorrect = json['feedback_correct_v1'] as String?;
        final feedbackIncorrect = json['feedback_incorrect_v1'] as String?;

        expect(
          feedbackCorrect,
          isNotNull,
          reason: '${entry.key} should keep authored positive feedback.',
        );
        expect(
          feedbackIncorrect,
          isNotNull,
          reason: '${entry.key} should keep authored corrective feedback.',
        );
        expect(
          feedbackCorrect,
          isNot('Correct.'),
          reason: '${entry.key} should not regress to generic positive feedback.',
        );
        expect(
          feedbackIncorrect,
          isNot('Incorrect.'),
          reason: '${entry.key} should not regress to generic corrective feedback.',
        );

        for (final fieldEntry in entry.value.entries) {
          final value = json[fieldEntry.key] as String?;
          expect(
            value,
            isNotNull,
            reason: '${entry.key} should include ${fieldEntry.key}.',
          );
          for (final snippet in fieldEntry.value) {
            expect(
              value,
              contains(snippet),
              reason: '${entry.key} ${fieldEntry.key} should teach the poker reason explicitly.',
            );
          }
          for (final banned in bannedPhrases) {
            expect(
              value,
              isNot(contains(banned)),
              reason: '${entry.key} ${fieldEntry.key} should avoid weak family wording.',
            );
          }
        }
      }
    },
  );
}
