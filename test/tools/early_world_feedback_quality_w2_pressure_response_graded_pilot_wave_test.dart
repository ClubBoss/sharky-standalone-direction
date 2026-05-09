import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 pressure-response graded pilot adds acceptable-but-weaker feedback across the admitted corridor',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_open_price_ok.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'price is good enough',
            'keeps more value in play',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_turn_bet.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'turn price still supports a call',
            'keeps the line alive',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_open_isolation.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'isolating weaker continues',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_turn_pressure.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'stronger counter',
            'absorbing',
          ],
        },
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final feedbackCorrect = (json['feedback_correct_v1'] as String?)?.trim();
        final feedbackIncorrect =
            (json['feedback_incorrect_v1'] as String?)?.trim();
        final feedbackAcceptable =
            (json['feedback_acceptable_v1'] as String?)?.trim();

        expect(feedbackCorrect, isNotNull, reason: '${entry.key} should keep feedback_correct_v1.');
        expect(
          feedbackIncorrect,
          isNotNull,
          reason: '${entry.key} should keep feedback_incorrect_v1.',
        );
        expect(
          feedbackAcceptable,
          isNotNull,
          reason: '${entry.key} should add feedback_acceptable_v1.',
        );
        expect(
          feedbackAcceptable,
          isNot(feedbackCorrect),
          reason: '${entry.key} acceptable feedback should differ from positive feedback.',
        );
        expect(
          feedbackAcceptable,
          isNot(feedbackIncorrect),
          reason: '${entry.key} acceptable feedback should differ from corrective feedback.',
        );

        for (final fieldEntry in entry.value.entries) {
          final value = json[fieldEntry.key] as String?;
          for (final snippet in fieldEntry.value) {
            expect(
              value,
              contains(snippet),
              reason: '${entry.key} ${fieldEntry.key} should express the graded teaching reason.',
            );
          }
        }
      }
    },
  );
}
