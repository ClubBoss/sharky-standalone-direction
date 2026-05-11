import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'admitted early-world bridge checkpoint review subset keeps scenario-first explanation depth',
    () {
      final repoRoot = Directory.current.path;
      final bannedPhrases = <String>[
        'bridge node',
        'bridge nodes',
        'checkpoint node',
        'checkpoint nodes',
        'World 3 checkpoint',
        'World 3 live bridge',
        'in this set',
      ];

      final expectations = <String, Map<String, List<String>>>{
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json':
            {
              'why_v1': ['A-7-2 rainbow', 'draw paths'],
              'feedback_correct_v1': ['A-7-2 rainbow', 'immediate draw paths'],
              'feedback_incorrect_v1': ['calmer board', 'dry and stable'],
            },
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json':
            {
              'why_v1': ['raised last preflop', 'pressure on the flop'],
              'feedback_correct_v1': ['Hero raised last', 'initiative'],
              'feedback_incorrect_v1': [
                'last aggressor preflop',
                'pressure first',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_showdown.json':
            {
              'why_v1': ['medium-strength hand', 'thin bluff'],
              'feedback_correct_v1': [
                'showdown often enough',
                'turning it into a bluff',
              ],
              'feedback_incorrect_v1': [
                'showdown often enough',
                'cleaner than bluffing',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_tocall_price_ok.json':
            {
              'why_v1': ['price is manageable', 'stretching into a raise'],
              'feedback_correct_v1': [
                'price is manageable',
                'stretching into a raise',
              ],
              'feedback_incorrect_v1': [
                'manageable price',
                'keeps the hand in play',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_fold_bridge_pressure_release.json':
            {
              'why_v1': ['runs out of room', 'forcing more money in'],
              'feedback_correct_v1': [
                'run out of room',
                'forcing more money in',
              ],
              'feedback_incorrect_v1': [
                'run out of room',
                'folding is cleaner',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_fold_bridge_tocall_price_bad.json':
            {
              'why_v1': ['price is too poor', 'bad call'],
              'feedback_correct_v1': ['price is too poor', 'bad call'],
              'feedback_incorrect_v1': ['price is too poor', 'bad call'],
            },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_raise_bridge_value.json':
            {
              'why_v1': ['value-heavy hand', 'passive line'],
              'feedback_correct_v1': [
                'strong enough to bet now',
                'passive line',
              ],
              'feedback_incorrect_v1': [
                'strong enough to bet',
                'gives up value',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_call_checkpoint_showdown_branch.json':
            {
              'why_v1': ['medium-strength hand', 'bluffing thinly'],
              'feedback_correct_v1': ['showdown shape', 'thin bluff'],
              'feedback_incorrect_v1': [
                'medium-strength hand',
                'cheaper value path',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_call_checkpoint_tocall_price_ok.json':
            {
              'why_v1': [
                'price is still manageable',
                'forcing a bigger action',
              ],
              'feedback_correct_v1': [
                'price is still acceptable',
                'forcing a bigger action',
              ],
              'feedback_incorrect_v1': [
                'price still acceptable',
                'forcing a bigger action',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_fold_checkpoint_tocall_price_bad.json':
            {
              'why_v1': ['price is too poor', 'losing pressure spot'],
              'feedback_correct_v1': [
                'price gets too poor',
                'paying off anyway',
              ],
              'feedback_incorrect_v1': [
                'price gets too poor',
                'release with a fold',
              ],
            },
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_raise_checkpoint_value_branch.json':
            {
              'why_v1': ['value-heavy hand', 'weaker continues'],
              'feedback_correct_v1': [
                'Position plus value',
                'money-winning line',
              ],
              'feedback_incorrect_v1': [
                'value-heavy',
                'raising is the clearer line',
              ],
            },
        'content/worlds/world3/v1/sessions/w3.s03/drills/d.choose_call_preflop_checkpoint_v1.json':
            {
              'why_v1': ['cutoff open', 'calling in position'],
              'feedback_correct_v1': [
                'cutoff open',
                'without bloating the pot',
              ],
              'feedback_incorrect_v1': [
                'in-position call',
                'stronger opening ranges',
              ],
            },
        'content/worlds/world3/v1/sessions/w3.s06/drills/d.choose_raise_mixed_context_checkpoint_v1.json':
            {
              'why_v1': ['button', 'take the initiative'],
              'feedback_correct_v1': ['button', 'take the initiative'],
              'feedback_incorrect_v1': [
                'button with ATo',
                'right compact action is to raise',
              ],
            },
        'content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_fold_final_preflop_checkpoint_v1.json':
            {
              'why_v1': ['J8o in the cutoff', 'players behind'],
              'feedback_correct_v1': [
                'J8o in the cutoff',
                'disciplined preflop play',
              ],
              'feedback_incorrect_v1': [
                'J8o',
                'disciplined compact action is to fold',
              ],
            },
        'content/worlds/world3/v1/sessions/w3.s14/drills/d.choose_raise_late_position_leverage_v1.json':
            {
              'why_v1': ['button', 'late-position leverage'],
              'feedback_correct_v1': ['button', 'late-position leverage'],
              'feedback_incorrect_v1': ['button', 'late-position leverage'],
            },
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final feedbackCorrect = json['feedback_correct_v1'] as String?;
        final feedbackIncorrect = json['feedback_incorrect_v1'] as String?;

        expect(
          feedbackCorrect,
          isNotNull,
          reason: '${entry.key} should author positive feedback.',
        );
        expect(
          feedbackIncorrect,
          isNotNull,
          reason: '${entry.key} should author corrective feedback.',
        );
        expect(
          feedbackCorrect,
          isNot('Correct.'),
          reason: '${entry.key} should not use generic positive feedback.',
        );
        expect(
          feedbackIncorrect,
          isNot('Incorrect.'),
          reason: '${entry.key} should not use generic corrective feedback.',
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
                  '${entry.key} ${fieldEntry.key} should teach the poker reason explicitly.',
            );
          }
          for (final banned in bannedPhrases) {
            expect(
              value,
              isNot(contains(banned)),
              reason:
                  '${entry.key} ${fieldEntry.key} should avoid internal curriculum labels.',
            );
          }
        }
      }
    },
  );
}
