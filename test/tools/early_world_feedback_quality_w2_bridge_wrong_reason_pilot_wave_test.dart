import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 bridge wrong-reason pilot differentiates fold and raise drifts across the admitted corridor subset',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_showdown.json':
            {
              'feedback_incorrect_by_action_v1.fold': <String>[
                'showdown often enough',
                'cheaper showdown path',
              ],
              'feedback_incorrect_by_action_v1.raise': <String>[
                'thin bluff',
                'preserves showdown value',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_fold_bridge_pressure_release.json':
            {
              'feedback_incorrect_by_action_v1.call': <String>[
                'Calling pays',
                'cleaner release',
              ],
              'feedback_incorrect_by_action_v1.raise': <String>[
                'Raising forces even more money',
                'should just release',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_fold_bridge_tocall_price_bad.json':
            {
              'feedback_incorrect_by_action_v1.call': <String>[
                'Calling pays a bad price',
                'continue price gets this poor',
              ],
              'feedback_incorrect_by_action_v1.raise': <String>[
                'bad-price continue',
                'cleaner choice is to fold',
              ],
            },
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final incorrectByAction =
            json['feedback_incorrect_by_action_v1'] as Map<String, dynamic>?;
        final genericIncorrect = (json['feedback_incorrect_v1'] as String?)
            ?.trim();

        expect(
          incorrectByAction,
          isNotNull,
          reason: '${entry.key} should add feedback_incorrect_by_action_v1.',
        );
        expect(
          genericIncorrect,
          isNotNull,
          reason:
              '${entry.key} should keep generic fallback feedback_incorrect_v1.',
        );

        for (final fieldEntry in entry.value.entries) {
          final parts = fieldEntry.key.split('.');
          final actionId = parts.last;
          final value = (incorrectByAction?[actionId] as String?)?.trim();
          expect(
            value,
            isNotNull,
            reason:
                '${entry.key} should author a wrong-reason message for $actionId.',
          );
          expect(
            value,
            isNot(genericIncorrect),
            reason:
                '${entry.key} $actionId wrong-reason text should not duplicate generic fallback.',
          );
          for (final snippet in fieldEntry.value) {
            expect(
              value,
              contains(snippet),
              reason:
                  '${entry.key} $actionId wrong-reason text should stay action-specific and scenario-first.',
            );
          }
        }
      }
    },
  );
}
