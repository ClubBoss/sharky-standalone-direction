import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'w2 checkpoint action-choice family keeps why and feedback aligned across showdown price and value branches',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_call_checkpoint_showdown_branch.json': {
          'why_v1': <String>['medium-strength hand', 'showdown', 'thin bluff'],
          'feedback_correct_v1': <String>['showdown shape', 'thin bluff'],
          'feedback_incorrect_v1': <String>['turns this medium-strength hand into a thin bluff', 'showdown value intact'],
        },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_call_checkpoint_tocall_price_ok.json': {
          'why_v1': <String>['price is still manageable', 'forcing a bigger action'],
          'feedback_correct_v1': <String>['price is still acceptable', 'continues cleanly', 'bigger action'],
          'feedback_incorrect_v1': <String>['Folding gives up too much', 'manageable price', 'continues more cleanly as a call'],
        },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_fold_checkpoint_tocall_price_bad.json': {
          'why_v1': <String>['price is too poor', 'losing pressure spot'],
          'feedback_correct_v1': <String>['price gets too poor', 'paying off anyway'],
          'feedback_incorrect_v1': <String>['Calling pays too much', 'should simply release'],
        },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_raise_checkpoint_value_branch.json': {
          'why_v1': <String>['value-heavy hand', 'weaker continues'],
          'feedback_correct_v1': <String>['Position plus value', 'money-winning line'],
          'feedback_incorrect_v1': <String>['Calling leaves value behind', 'wins more from weaker continues'],
        },
      };

      final bannedPhrases = <String>{
        'this pressure spot should',
        'when the hand is value-heavy and position is helping',
        'better handled by taking the cheaper value path',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        for (final fieldEntry in entry.value.entries) {
          final value = json[fieldEntry.key] as String?;
          expect(value, isNotNull, reason: '${entry.key} should include ${fieldEntry.key}.');
          for (final snippet in fieldEntry.value) {
            expect(
              value,
              contains(snippet),
              reason: '${entry.key} ${fieldEntry.key} should teach the same poker reason.',
            );
          }
          for (final banned in bannedPhrases) {
            expect(
              value,
              isNot(contains(banned)),
              reason: '${entry.key} ${fieldEntry.key} should avoid older misaligned family wording.',
            );
          }
        }
      }
    },
  );
}
