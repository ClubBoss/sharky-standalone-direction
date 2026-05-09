import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'generic-template corrective feedback in the admitted early-world subset stays poker-reasoned',
    () {
      final repoRoot = Directory.current.path;
      final singleFile = File(
        '$repoRoot/content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_call_checkpoint_showdown_branch.json',
      );
      final singleJson =
          jsonDecode(singleFile.readAsStringSync()) as Map<String, dynamic>;
      final singleFeedback = singleJson['feedback_incorrect_v1'] as String;

      expect(singleFeedback, contains('medium-strength hand'));
      expect(singleFeedback, contains('thin bluff'));
      expect(singleFeedback, contains('cheaper value path'));
      expect(
        singleFeedback,
        isNot(contains('This showdown-intent node should not bluff.')),
      );

      final chainFile = File(
        '$repoRoot/content/worlds/world3/v1/sessions/w3.s09/drills/d.chain_preflop_same_hand_different_action_v1.json',
      );
      final chainJson =
          jsonDecode(chainFile.readAsStringSync()) as Map<String, dynamic>;
      final steps = chainJson['steps'] as List<dynamic>;

      final expectations = <int, List<String>>{
        0: <String>['button', 'initiative', 'late position'],
        1: <String>['cutoff opens first', 'calling keeps position', 'marginal raise spot'],
        2: <String>['earlier position', 'players behind', 'button advantage'],
      };
      final bannedPhrases = <String>{
        'This first frame wants an unopened raise.',
        'This step is about seeing that the same hand no longer wants the same first action.',
        'This final step checks whether the learner really changes the action when the seat changes.',
      };

      for (final entry in expectations.entries) {
        final feedback =
            (steps[entry.key] as Map<String, dynamic>)['feedback_incorrect_v1']
                as String;
        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason: 'Step ${entry.key + 1} should teach the poker reason explicitly.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason: 'Step ${entry.key + 1} should not regress to generic template wording.',
          );
        }
      }
    },
  );
}
