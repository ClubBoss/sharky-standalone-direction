import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 sequence action-choice family keeps why and feedback aligned across start control continue and finish states',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_flop_sequence_start.json':
            {
              'why_v1': <String>[
                'taking initiative',
                'free card',
                'passive call',
              ],
              'feedback_correct_v1': <String>[
                'taking initiative',
                'free card',
                'passive call',
              ],
              'feedback_incorrect_v1': <String>[
                'gives up the initiative',
                'apply pressure first',
                'raise',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_call_turn_sequence_control.json':
            {
              'why_v1': <String>['pot control', 'forcing extra pressure'],
              'feedback_correct_v1': <String>[
                'pot-control spot',
                'forcing another bet',
              ],
              'feedback_incorrect_v1': <String>[
                'pushes past the hand',
                'pot manageable',
                'turn',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_turn_sequence_continue.json':
            {
              'why_v1': <String>[
                'turn still favors pressure',
                'weaker continues under strain',
              ],
              'feedback_correct_v1': <String>[
                'turn still favors pressure',
                'weaker continues under strain',
              ],
              'feedback_incorrect_v1': <String>[
                'backs off too early',
                'another bet',
                'weaker continues under strain',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_call_river_sequence_showdown.json':
            {
              'why_v1': <String>['showdown value', 'turning it into a bluff'],
              'feedback_correct_v1': <String>[
                'showdown value',
                'cleaner than bluffing',
              ],
              'feedback_incorrect_v1': <String>[
                'turns showdown value into a bluff',
                'finished by checking',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_river_sequence_value.json':
            {
              'why_v1': <String>[
                'strong enough to value bet',
                'leave money behind',
                'worse calls',
              ],
              'feedback_correct_v1': <String>[
                'strong enough to value bet',
                'leave money behind',
                'worse calls',
              ],
              'feedback_incorrect_v1': <String>[
                'Checking leaves value behind',
                'bet',
                'worse hands',
              ],
            },
      };

      final bannedPhrases = <String>{
        'branch',
        'node',
        'expects raise',
        'expects raise.',
        'checks in this node',
        'value finish',
        'showdown finish',
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

        for (final fieldEntry in entry.value.entries) {
          final value = json[fieldEntry.key] as String?;
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
                  '${entry.key} ${fieldEntry.key} should avoid branch/node shorthand.',
            );
          }
        }
      }
    },
  );
}
