import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'W2 anchor prerequisite corrective feedback stays poker-specific across the admitted subset',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_btn.json':
            <String>['button', 'acts last after the flop', 'in-position edge'],
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s0.json':
            <String>['seat S0', 'exact player', 'open-or-fold answer changes'],
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.find_bb.json':
            <String>['big blind', 'defends wider', 'act first after the flop'],
        'content/worlds/world2/v1/sessions/w2.s03/drills/d.find_sb.json':
            <String>['small blind', 'out of position', 'partly committed'],
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.find_btn_turn_anchor.json':
            <String>[
              'button',
              'acts last on the turn',
              'checking back makes sense',
            ],
        'content/worlds/world2/v1/sessions/w2.s05/drills/d.tap_turn_context.json':
            <String>[
              'fourth board card',
              'add draws',
              'second barrel or checkback',
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
            <String>['turn', 'fourth board card', 'draw pressure still fits'],
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.find_seat_s6_checkpoint_anchor.json':
            <String>[
              'button against an early-position opener',
              'early seat',
              'decision makes sense',
            ],
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.find_btn_checkpoint_anchor.json':
            <String>[
              'button tells you who acts last',
              'patient in-position value',
            ],
        'content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_flop_mid_checkpoint_anchor.json':
            <String>['middle flop card', 'full board texture', 'branch action'],
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_btn.json':
            <String>['button acts last preflop', 'late-position control'],
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_bb.json':
            <String>[
              'big blind',
              'acts after the small blind preflop',
              'defend-or-fold decision',
            ],
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json':
            <String>[
              'small blind',
              'acts before the big blind preflop',
              'earliest pressure',
            ],
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json':
            <String>['left flop card', 'board texture', 'c-bet or a check'],
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_right_context.json':
            <String>[
              'right flop card',
              'full flop picture',
              'dry enough for a c-bet',
            ],
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_flop_sequence_anchor.json':
            <String>['first board read', 'texture and pressure'],
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_turn_sequence_anchor.json':
            <String>[
              'turn changes draws and pressure',
              'board development shifts the action',
            ],
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_river_sequence_anchor.json':
            <String>[
              'river finalizes',
              'value, showdown, or release',
              'last action',
            ],
      };
      final bannedPhrases = <String>{
        'This checkpoint node requires seat S6.',
        'Set button anchor before choosing action.',
        'This node starts with flop-mid anchor.',
        'Find button first to anchor acting order.',
        'Lock flop context first, then choose action.',
        'Sequence line starts from flop anchor.',
        'Turn anchor must be set before action.',
        'River anchor is required before final action.',
        'Find the button first because',
        'Tap seat S0 first because',
        'Find the big blind first because',
        'Find the small blind first because',
        'Tap the turn first because',
        'Tap the river first because',
        'Tap seat S3 first because',
        'Tap seat S5 first because',
        'checkpoint branch changes',
        'Big blind must be identified before action choice.',
        'Tap the right flop card first because',
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
                '${entry.key} should not regress to generic anchor wording.',
          );
        }
      }
    },
  );

  test(
    'W2 s08 positive anchor feedback teaches board-sequence value instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_flop_sequence_anchor.json':
            <String>[
              'first texture read',
              'sequence starts',
              'pressure already on board',
            ],
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_river_sequence_anchor.json':
            <String>[
              'value, showdown, or release',
              'last action',
              'final card',
            ],
      };
      final bannedPhrases = <String>{
        'Correct. Flop anchor is set for sequence line.',
        'Correct. River anchor is set for line finish.',
        'anchor is set',
        'confirmed.',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s10 positive anchor feedback teaches denial value instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s10/drills/d.find_bb_focus.json':
            <String>['forced defender', 'continue first'],
        'content/worlds/world4/v1/sessions/w4.s10/drills/d.find_btn_focus.json':
            <String>['late-position edge', 'apply pressure last'],
        'content/worlds/world4/v1/sessions/w4.s10/drills/d.find_seat_s6_focus.json':
            <String>['acting player', 'exact range applying the pressure'],
        'content/worlds/world4/v1/sessions/w4.s10/drills/d.tap_flop_mid_focus.json':
            <String>['completes the texture read', 'keeps draws alive'],
        'content/worlds/world4/v1/sessions/w4.s10/drills/d.tap_river_focus.json':
            <String>['locks the last street', 'folds worse hands now'],
      };
      final bannedPhrases = <String>{
        'Correct. Big blind anchor is confirmed.',
        'Correct. Button anchor is confirmed.',
        'Correct. Seat S6 anchor is set.',
        'Correct. Middle flop anchor is set.',
        'Correct. River anchor is confirmed.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s07 positive anchor feedback teaches value-line reasons instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s07/drills/d.find_co_focus.json':
            <String>['earlier value seat', 'before the button acts'],
        'content/worlds/world4/v1/sessions/w4.s07/drills/d.find_btn_focus.json':
            <String>['late-position value edge', 'most information'],
        'content/worlds/world4/v1/sessions/w4.s07/drills/d.find_seat_s3_focus.json':
            <String>['acting player', 'exact range that is betting now'],
        'content/worlds/world4/v1/sessions/w4.s07/drills/d.tap_flop_left_focus.json':
            <String>['starts the board read', 'weaker hands keep calling'],
        'content/worlds/world4/v1/sessions/w4.s07/drills/d.tap_turn_focus.json':
            <String>['value is still ahead', 'charging worse continues'],
      };
      final bannedPhrases = <String>{
        'Correct. Cutoff anchor is confirmed.',
        'Correct. Button anchor is confirmed.',
        'Correct. Seat S3 anchor is set.',
        'Correct. Left flop anchor is set.',
        'Correct. Turn anchor is confirmed.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s08 positive anchor feedback teaches protection-line reasons instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s08/drills/d.find_hj_focus.json':
            <String>['earlier pressure seat', 'called by worse hands behind'],
        'content/worlds/world4/v1/sessions/w4.s08/drills/d.find_sb_focus.json':
            <String>['out-of-position defender', 'overcards and draws first'],
        'content/worlds/world4/v1/sessions/w4.s08/drills/d.find_seat_s4_focus.json':
            <String>['acting player', 'betting for denial now'],
        'content/worlds/world4/v1/sessions/w4.s08/drills/d.tap_turn_focus.json':
            <String>[
              'draws gained real equity',
              'free cards become more expensive',
            ],
        'content/worlds/world4/v1/sessions/w4.s08/drills/d.tap_river_focus.json':
            <String>['ends the protection window', 'worse hands can still pay'],
      };
      final bannedPhrases = <String>{
        'Correct. Hijack anchor is confirmed.',
        'Correct. Small blind anchor is confirmed.',
        'Correct. Seat S4 anchor is set.',
        'Correct. Turn anchor is set.',
        'Correct. River anchor is confirmed.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s09 positive anchor feedback teaches bluff-line reasons instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s09/drills/d.find_bb_focus.json':
            <String>['defending seat', 'fold under late pressure'],
        'content/worlds/world4/v1/sessions/w4.s09/drills/d.find_utg_focus.json':
            <String>['earliest seat', 'without late-position safety'],
        'content/worlds/world4/v1/sessions/w4.s09/drills/d.find_seat_s5_focus.json':
            <String>['acting player', 'range that is pressuring now'],
        'content/worlds/world4/v1/sessions/w4.s09/drills/d.tap_flop_right_focus.json':
            <String>[
              'finishes the first texture read',
              'push weaker hands out',
            ],
        'content/worlds/world4/v1/sessions/w4.s09/drills/d.tap_river_focus.json':
            <String>['last pressure street', 'weaker hands can still fold'],
      };
      final bannedPhrases = <String>{
        'Correct. Big blind anchor is confirmed.',
        'Correct. Under-the-gun anchor is confirmed.',
        'Correct. Seat S5 anchor is set.',
        'Correct. Right flop anchor is confirmed.',
        'Correct. River anchor is set.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s04 positive anchor feedback teaches value-repeat reasons instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s04/drills/d.find_co_repeat.json':
            <String>['earlier value seat', 'before later seats react'],
        'content/worlds/world4/v1/sessions/w4.s04/drills/d.find_btn_repeat.json':
            <String>['late-position edge', 'most information'],
        'content/worlds/world4/v1/sessions/w4.s04/drills/d.tap_hole_left_repeat.json':
            <String>['hero\'s exact hand', 'worse hands'],
        'content/worlds/world4/v1/sessions/w4.s04/drills/d.tap_flop_left_repeat.json':
            <String>['starts the board read', 'continues in the pot'],
      };
      final bannedPhrases = <String>{
        'Correct. Cutoff anchor is confirmed.',
        'Correct. Button anchor is confirmed.',
        'Correct. Left hole-card anchor is set.',
        'Correct. Left flop anchor is set.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s05 positive anchor feedback teaches protection-repeat reasons instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s05/drills/d.find_bb_repeat.json':
            <String>['forced defender', 'protection bets against first'],
        'content/worlds/world4/v1/sessions/w4.s05/drills/d.find_sb_repeat.json':
            <String>['early defender', 'before free cards arrive'],
        'content/worlds/world4/v1/sessions/w4.s05/drills/d.tap_hole_right_repeat.json':
            <String>['hero\'s exact hand', 'deny equity now'],
        'content/worlds/world4/v1/sessions/w4.s05/drills/d.tap_turn_repeat.json':
            <String>['extra equity appears', 'protection gets more urgent'],
      };
      final bannedPhrases = <String>{
        'Correct. Big blind anchor is confirmed.',
        'Correct. Small blind anchor is confirmed.',
        'Correct. Right hole-card anchor is set.',
        'Correct. Turn anchor is set.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );

  test(
    'W4 s06 positive anchor feedback teaches denial-repeat reasons instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, List<String>>{
        'content/worlds/world4/v1/sessions/w4.s06/drills/d.find_bb_repeat.json':
            <String>['forced defender', 'must continue first'],
        'content/worlds/world4/v1/sessions/w4.s06/drills/d.find_btn_repeat.json':
            <String>['late-position edge', 'press last'],
        'content/worlds/world4/v1/sessions/w4.s06/drills/d.tap_flop_mid_repeat.json':
            <String>['first texture read', 'keeps draws alive'],
        'content/worlds/world4/v1/sessions/w4.s06/drills/d.tap_river_repeat.json':
            <String>['last street', 'charging draws has to end'],
      };
      final bannedPhrases = <String>{
        'Correct. Big blind anchor is confirmed.',
        'Correct. Button anchor is confirmed.',
        'Correct. Middle flop anchor is set.',
        'Correct. River anchor is set.',
        'anchor is confirmed',
        'anchor is set',
      };

      for (final entry in expectations.entries) {
        final file = File('$repoRoot/${entry.key}');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_correct_v1'] as String;

        for (final snippet in entry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${entry.key} should explain why the correct anchor matters.',
          );
        }
        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${entry.key} should not regress to shallow positive confirmation.',
          );
        }
      }
    },
  );
}
