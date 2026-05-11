import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World 2 gold-spine short-feedback residue stays scenario-first across the admitted subset',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_hero_top_pair_showdown.json':
            <String>['ace on the board', 'pocket sevens', 'higher pair wins'],
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_villain_straight_showdown.json':
            <String>['Q8', 'straight', 'outranks two pair'],
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json':
            <String>[
              'small blind',
              'acts before the big blind preflop',
              'earliest pressure',
            ],
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_btn.json':
            <String>['button', 'acts last after the flop', 'in-position edge'],
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s0.json':
            <String>['seat S0', 'exact player', 'open-or-fold answer changes'],
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.find_bb.json':
            <String>['big blind', 'defends wider', 'act first after the flop'],
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.find_sb.json':
            <String>['small blind', 'out of position', 'partly committed'],
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_right_context.json':
            <String>[
              'right flop card',
              'all three flop cards',
              'dry or coordinated',
            ],
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.find_btn_turn_anchor.json':
            <String>[
              'button',
              'acts last on the turn',
              'checking back makes sense',
            ],
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_showdown_hero_top_pair.json':
            <String>[
              'ace on the board',
              'pocket sevens',
              'stronger made hand remains ahead',
            ],
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.tap_turn_context.json':
            <String>[
              'fourth board card',
              'second barrel or checkback',
              'add draws',
            ],
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.find_bb_river_anchor.json':
            <String>['big blind', 'forced defender', 'final-street choice'],
        'content/worlds/world2/v1/sessions/w2.s06/drills/d.tap_river_context.json':
            <String>['last board card', 'draws missed', 'final action'],
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.find_btn_pressure_anchor.json':
            <String>['button', 'late-acting seat', 'most information'],
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.find_seat_s3_pressure_anchor.json':
            <String>['seat S3', 'different price', 'pressure decision'],
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.find_bb_bridge_anchor.json':
            <String>[
              'big blind',
              "forced defender's view",
              'late-position aggressor',
            ],
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.find_seat_s5_bridge_anchor.json':
            <String>['seat S5', 'exact player', 'lesson drifts'],
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_turn_checkpoint_anchor.json':
            <String>['turn', 'fourth board card', 'pressure still fits'],
      };

      final bannedPhrases = <String>{
        'Top pair beats an underpair here.',
        'Straight outranks two pair.',
        'Find small blind before deciding action flow.',
        'Position anchor must be set first.',
        'This rep starts with turn context lock.',
        'Identify button to anchor in-position choice.',
        'Seat context must be locked first.',
        'Big blind context must be identified first.',
        'Start with small blind anchor first.',
        'River line starts from seat anchor.',
        'River slot must be identified first.',
        'Set position anchor before pressure action.',
        'Pressure branch requires seat S3 context first.',
        'Bridge node requires big blind anchor first.',
        'Mixed-context branch needs seat S5 anchor.',
        'This rep requires the flop-right slot.',
        'Turn anchor must be set before action.',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_incorrect_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason: '${entry.key} should teach the poker reason explicitly.',
          );
        }

        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to short placeholder-style feedback.',
          );
        }
      }
    },
  );
}
