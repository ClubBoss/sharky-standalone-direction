import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Targeted Content Repairs v1', () {
    test(
      'W5 texture repairs keep texture observational, not deterministic',
      () {
        for (final path in _w5TextureSourcePaths) {
          final json = _readJson(path);
          final prompt = json['prompt'] as String;
          final why = json['why_v1'] as String;
          final feedback =
              '${json['feedback_correct_v1']} '
              '${json['feedback_incorrect_v1']}';
          final copy = '$prompt $why $feedback'.toLowerCase();

          expect(copy, isNot(contains('choose the best action')));
          expect(copy, isNot(contains('should lead to a raise')));
          expect(copy, isNot(contains('let the wetter turn texture lead')));
          expect(copy, contains('texture'));
          expect(copy, anyOf(contains('cue'), contains('source-backed')));
        }

        final fixtureText = _readText(
          'test/fixtures/content_factory_mvp/'
          'w5_board_texture_classification_canonical_pilot_v1.json',
        );
        expect(fixtureText, isNot(contains('should lead to a raise')));
        expect(fixtureText, isNot(contains('best action')));
      },
    );

    test('W4 sizing repairs scope sizes as examples, not unique truth', () {
      for (final path in _w4SizingSourcePaths) {
        final json = _readJson(path);
        final copy = '${json['prompt']} ${json['why_v1']}'.toLowerCase();
        expect(copy, anyOf(contains('reasonable'), contains('practical')));
        expect(copy, contains('beginner'));
        expect(copy, isNot(contains('pot is right')));
        expect(copy, isNot(contains('correct size')));
        expect(copy, isNot(contains('optimal')));
      }
    });

    test('W4 raise-purpose repairs are scoped to purpose recognition', () {
      for (final path in _w4RaisePurposeSourcePaths) {
        final json = _readJson(path);
        final copy =
            '${json['prompt']} ${json['why_v1']} ${json['feedback_correct_v1']} '
                    '${json['feedback_incorrect_v1']}'
                .toLowerCase();
        expect(copy, contains('purpose'));
        expect(copy, contains('simplified'));
        expect(copy, isNot(contains('raise is expected')));
        expect(copy, isNot(contains('the bluff action')));
      }
    });

    test('W11 and W10 route copy avoid overcertain taxonomy or EV claims', () {
      final w11 = _readText(
        'content/worlds/world11/v1/sessions/w11.s01/'
        'w11.s01_deterministic_source_packet_v1.md',
      ).toLowerCase();
      expect(w11, isNot(contains('gives up value')));
      expect(w11, isNot(contains('too tight here')));
      expect(w11, contains('one-focus'));

      final w10 = _readText(
        'lib/ui_v2/act0_shell/'
        'act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart',
      ).toLowerCase();
      expect(w10, contains('among the beginner purposes taught here'));
      expect(w10, isNot(contains('first purpose question is whether')));
      expect(w10, isNot(contains('all bets fit only')));
    });

    test('final review and capsules close the bounded ledger', () {
      final review = _readText('docs/_reviews/targeted_content_repairs_v1.md');
      expect(
        review,
        contains('targeted_content_repairs_landed_with_explicit_deferrals'),
      );
      for (final id in <String>[
        'PC-001',
        'PC-002',
        'PC-003',
        'PC-004',
        'PC-005',
        'PC-006',
        'PC-007',
        'PC-008',
        'PC-009',
        'PC-010',
        'PC-011',
        'SLCR-001',
        'SLCR-002',
        'SLCR-003',
        'SLCR-004',
        'SLCR-005',
        'SLCR-006',
        'SLCR-007',
        'SLCR-008',
      ]) {
        expect(review, contains(id));
      }
      expect(review, contains('close_targeted_content_repairs'));
      expect(review, contains('Phase 7 Closure Audit v1'));

      final activeRoute = _readText('docs/context/ACTIVE_ROUTE_CAPSULE_v1.md');
      expect(activeRoute, contains('Targeted Content Repairs - CLOSED'));
      expect(activeRoute, contains('Phase 7 Closure Audit - ACTIVE'));

      final learning = _readText('docs/context/LEARNING_REPAIR_CAPSULE_v1.md');
      expect(learning, contains('no unresolved actionable P1-P4'));
      expect(learning, contains('W13+ remains closed'));
      expect(learning, contains('Practice mapping remains blocked'));
    });
  });
}

Map<String, Object?> _readJson(String path) {
  return jsonDecode(_readText(path)) as Map<String, Object?>;
}

String _readText(String path) => File(path).readAsStringSync();

const _w5TextureSourcePaths = <String>[
  'content/worlds/world5/v1/sessions/w5.s01/drills/'
      'd.classify_texture_intro_dry_raise_v1.json',
  'content/worlds/world5/v1/sessions/w5.s01/drills/'
      'd.classify_texture_intro_wet_call_v1.json',
  'content/worlds/world5/v1/sessions/w5.s01/drills/'
      'd.classify_texture_intro_paired_fold_v1.json',
  'content/worlds/world5/v1/sessions/w5.s03/drills/'
      'd.classify_wet_protection_connected_call_v1.json',
  'content/worlds/world5/v1/sessions/w5.s04/drills/'
      'd.classify_turn_shift_connected_raise_v1.json',
  'content/worlds/world5/v1/sessions/w5.s04/drills/'
      'd.classify_turn_shift_wet_call_v1.json',
  'content/worlds/world5/v1/sessions/w5.s04/drills/'
      'd.classify_turn_shift_paired_fold_v1.json',
  'content/worlds/world5/v1/sessions/w5.s05/drills/'
      'd.classify_river_closure_connected_call_v1.json',
  'content/worlds/world5/v1/sessions/w5.s05/drills/'
      'd.classify_river_closure_dry_fold_v1.json',
  'content/worlds/world5/v1/sessions/w5.s05/drills/'
      'd.classify_river_closure_wet_raise_v1.json',
  'content/worlds/world5/v1/sessions/w5.s10/drills/'
      'd.classify_texture_synthesis_dry_raise_v1.json',
];

const _w4SizingSourcePaths = <String>[
  'content/worlds/world4/v1/sessions/w4.s01/drills/'
      'd.choose_half_pot_value.json',
  'content/worlds/world4/v1/sessions/w4.s03/drills/'
      'd.choose_half_pot_value_checkpoint.json',
  'content/worlds/world4/v1/sessions/w4.s04/drills/'
      'd.choose_half_pot_value_stability.json',
  'content/worlds/world4/v1/sessions/w4.s07/drills/'
      'd.choose_half_pot_value_followthrough.json',
  'content/worlds/world4/v1/sessions/w4.s07/drills/'
      'd.choose_pot_value_pressure_finish.json',
];

const _w4RaisePurposeSourcePaths = <String>[
  'content/worlds/world4/v1/sessions/w4.s01/drills/'
      'd.choose_raise_protection.json',
  'content/worlds/world4/v1/sessions/w4.s02/drills/'
      'd.choose_raise_bluff.json',
  'content/worlds/world4/v1/sessions/w4.s02/drills/'
      'd.choose_raise_denial.json',
  'content/worlds/world4/v1/sessions/w4.s03/drills/'
      'd.choose_raise_bluff.json',
  'content/worlds/world4/v1/sessions/w4.s05/drills/'
      'd.choose_raise_repeat.json',
];
