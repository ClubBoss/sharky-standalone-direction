import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 bridge action-choice family keeps why and feedback aligned across showdown price pressure and value branches',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_showdown.json':
            {
              'why_v1': <String>['showdown', 'thin bluff'],
              'feedback_correct_v1': <String>['showdown value', 'thin bluff'],
              'feedback_incorrect_v1': <String>[
                'showdown value',
                'cheaper value path',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_tocall_price_ok.json':
            {
              'why_v1': <String>['manageable', 'extra aggression'],
              'feedback_correct_v1': <String>['manageable', 'extra aggression'],
              'feedback_incorrect_v1': <String>[
                'manageable continue price',
                'extra aggression',
                'cleaner line is to call',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_fold_bridge_pressure_release.json':
            {
              'why_v1': <String>['runs out of room', 'losing spot'],
              'feedback_correct_v1': <String>['run out of room', 'losing spot'],
              'feedback_incorrect_v1': <String>[
                'run out of room',
                'cleaner release',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_raise_bridge_pressure_counter.json':
            {
              'why_v1': <String>['push back now', 'passive line'],
              'feedback_correct_v1': <String>['push back now', 'passive line'],
              'feedback_incorrect_v1': <String>[
                'absorbs pressure',
                'pushes back now',
                'stronger counter',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_raise_bridge_value.json':
            {
              'why_v1': <String>['value-heavy', 'passive line'],
              'feedback_correct_v1': <String>['value-heavy', 'passive line'],
              'feedback_incorrect_v1': <String>[
                'value behind',
                'weaker continues',
              ],
            },
      };

      final bannedPhrases = <String>{
        'bridge spot',
        'bridge pressure line',
        'bridge pressure counter node',
        'works by',
        'expects raise',
        'branch is represented',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final why = json['why_v1'] as String?;
        final feedbackCorrect = json['feedback_correct_v1'] as String?;
        final feedbackIncorrect = json['feedback_incorrect_v1'] as String?;

        expect(why, isNotNull, reason: '${entry.key} should keep why_v1.');
        expect(
          feedbackCorrect,
          isNotNull,
          reason: '${entry.key} should keep positive feedback.',
        );
        expect(
          feedbackIncorrect,
          isNotNull,
          reason: '${entry.key} should keep corrective feedback.',
        );
        expect(
          feedbackCorrect,
          isNot('Correct.'),
          reason: '${entry.key} should avoid generic positive feedback.',
        );
        expect(
          feedbackIncorrect,
          isNot('Incorrect.'),
          reason: '${entry.key} should avoid generic corrective feedback.',
        );
        expect(
          feedbackIncorrect,
          isNot(feedbackCorrect),
          reason:
              '${entry.key} corrective feedback should not duplicate positive feedback.',
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
              reason:
                  '${entry.key} ${fieldEntry.key} should express the same poker reason.',
            );
          }
          for (final banned in bannedPhrases) {
            expect(
              value,
              isNot(contains(banned)),
              reason:
                  '${entry.key} ${fieldEntry.key} should avoid corridor-internal shorthand.',
            );
          }
        }
      }
    },
  );
}
