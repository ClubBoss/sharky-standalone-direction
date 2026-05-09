import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w7.s06-w7.s08 depth cluster teaches why each cue matters instead of shallow confirmations',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefixes = <String>[
        'content/worlds/world7/v1/sessions/w7.s06/drills/',
        'content/worlds/world7/v1/sessions/w7.s07/drills/',
        'content/worlds/world7/v1/sessions/w7.s08/drills/',
      ];

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final clusterFindings = report.findings
          .where(
            (item) => familyPrefixes.any(
              (prefix) => item.filePath.startsWith(prefix),
            ),
          )
          .toList(growable: false);

      expect(
        clusterFindings,
        isEmpty,
        reason:
            'w7.s06-w7.s08 should no longer emit audit findings after this wave.',
      );

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];

      const snippetsByFile = <String, List<String>>{
        'd.choose_call_ip_depth.json': <String>[
          'Calling fits',
          'realize medium-depth equity',
        ],
        'd.choose_raise_ip_depth.json': <String>[
          'Raising fits',
          'position plus depth gives you enough leverage',
        ],
        'd.find_btn_ip_depth.json': <String>[
          'Button is the seat anchor',
          'acting last',
        ],
        'd.find_co_ip_depth.json': <String>[
          'Cutoff is the seat anchor',
          'earlier late-position range',
        ],
        'd.tap_flop_ip_depth.json': <String>[
          'flop_right is the board anchor',
          'full flop texture',
        ],
        'd.tap_hole_left_ip_depth.json': <String>[
          'left hole card is the anchor',
          'blocker or playability value',
        ],
        'd.tap_river_ip_depth.json': <String>[
          'river is the board anchor',
          'value, pressure, or a check-back',
        ],
        'd.tap_turn_ip_depth.json': <String>[
          'turn is the board anchor',
          'leverage is growing or flattening',
        ],
        'd.choose_call_oop_depth.json': <String>[
          'Calling fits',
          'realize equity out of position',
        ],
        'd.choose_fold_oop_depth.json': <String>[
          'Folding fits',
          'acting first with this much exposure',
        ],
        'd.find_bb_oop_depth.json': <String>[
          'Big blind is the seat anchor',
          'widest and most pressured range',
        ],
        'd.find_sb_oop_depth.json': <String>[
          'Small blind is the seat anchor',
          'partly committed seat',
        ],
        'd.tap_flop_oop_depth.json': <String>[
          'flop_left is the board anchor',
          'first texture cue',
        ],
        'd.tap_hole_right_oop_depth.json': <String>[
          'right hole card is the anchor',
          'survive acting first',
        ],
        'd.tap_river_oop_depth.json': <String>[
          'river is the board anchor',
          'value, bluff catcher, or fold',
        ],
        'd.tap_turn_oop_depth.json': <String>[
          'turn is the board anchor',
          'stabilizing or becoming too vulnerable',
        ],
        'd.choose_call_blocker_depth.json': <String>[
          'Calling fits',
          'blocker adds protection',
        ],
        'd.choose_raise_blocker_depth.json': <String>[
          'Raising fits',
          'blocker and stack depth align',
        ],
        'd.find_btn_blocker_depth.json': <String>[
          'Button is the seat anchor',
          'apply blocker pressure',
        ],
        'd.find_sb_blocker_depth.json': <String>[
          'Small blind is the seat anchor',
          'blocker pressure can force into trouble',
        ],
        'd.tap_flop_blocker_depth.json': <String>[
          'flop_mid is the board anchor',
          'blocker only matters after the flop texture',
        ],
        'd.tap_hole_left_blocker_depth.json': <String>[
          'As is the hole-card anchor',
          'removes strong continues',
        ],
        'd.tap_river_blocker_depth.json': <String>[
          'river is the board anchor',
          'supports pressure or should settle for showdown',
        ],
        'd.tap_turn_blocker_depth.json': <String>[
          'turn is the board anchor',
          'gaining leverage or losing value',
        ],
      };

      for (final prefix in familyPrefixes) {
        final files =
            Directory('$repoRoot/$prefix')
                .listSync()
                .whereType<File>()
                .where((file) => file.path.endsWith('.json'))
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final fileName = file.uri.pathSegments.last;
          final feedbackCorrect = json['feedback_correct_v1'] as String;

          for (final fragment in bannedCorrectFragments) {
            expect(
              feedbackCorrect,
              isNot(contains(fragment)),
              reason: '${file.path} should not regress to shallow feedback.',
            );
          }

          for (final snippet in snippetsByFile[fileName]!) {
            expect(
              feedbackCorrect,
              contains(snippet),
              reason: '${file.path} should explain why the cue matters.',
            );
          }
        }
      }
    },
  );
}
