import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 sequence graded expansion adds acceptable-but-weaker feedback across the admitted subset',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_flop_sequence_start.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'takes initiative now',
            'free card',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_turn_sequence_continue.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'turn still favors pressure',
            'betting again',
          ],
        },
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_river_sequence_value.json': {
          'feedback_acceptable_v1': <String>[
            'Acceptable.',
            'strong enough to value bet',
            'worse calls',
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
