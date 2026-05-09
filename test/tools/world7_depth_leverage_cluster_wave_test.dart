import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w7.s01-w7.s04 depth leverage cluster uses plain learner language instead of shallow confirmations',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefixes = <String>[
        'content/worlds/world7/v1/sessions/w7.s01/drills/',
        'content/worlds/world7/v1/sessions/w7.s03/drills/',
        'content/worlds/world7/v1/sessions/w7.s04/drills/',
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
            'w7.s01-w7.s04 should no longer emit audit findings after this wave.',
      );

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
        'context',
        'coverage',
        'upgrade',
        'flattening',
        'depth-pressure',
      ];

      const snippetsByFile = <String, List<String>>{
        'd.choose_fold_trap.json': <String>['Fold fits', 'dangerous'],
        'd.choose_raise_shallow.json': <String>['Raise fits', 'pressure'],
        'd.find_btn_depth.json': <String>['button', 'acting last'],
        'd.find_sb.json': <String>['small blind', 'vulnerable seat'],
        'd.tap_flop_left.json': <String>['left flop card', 'betting is safe'],
        'd.tap_hole_right_ks.json': <String>['Ks matters', 'more playable'],
        'd.tap_turn_depth.json': <String>['Use the turn', 'getting worse'],
        'd.choose_call_deep.json': <String>['Call fits', 'playable'],
        'd.choose_raise_pressure.json': <String>['Raise fits', 'real pressure'],
        'd.find_bb.json': <String>['big blind', 'forced defender'],
        'd.find_btn_medium.json': <String>['button', 'easier to play'],
        'd.tap_flop_right.json': <String>['right flop card', 'safe to attack'],
        'd.tap_hole_right.json': <String>['right hole card', 'still playable'],
        'd.tap_turn_medium.json': <String>['keep betting or slow down'],
        'd.choose_raise_deep_leverage.json': <String>[
          'Raise fits',
          'keep pressing',
        ],
        'd.find_btn_deep.json': <String>['button', 'deep pressure stronger'],
        'd.find_hj_deep.json': <String>['hijack', 'range you are pressing'],
        'd.tap_flop_mid_deep.json': <String>[
          'middle flop card',
          'first board read',
        ],
        'd.tap_hole_left_deep.json': <String>[
          'left hole card',
          'playable enough',
        ],
        'd.tap_river_deep.json': <String>['Use the river', 'safe finish'],
        'd.tap_turn_deep.json': <String>['Use the turn', 'getting stronger'],
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

          if (snippetsByFile.containsKey(fileName)) {
            final feedbackCorrect = json['feedback_correct_v1'] as String;
            for (final fragment in bannedCorrectFragments) {
              expect(
                feedbackCorrect,
                isNot(contains(fragment)),
                reason:
                    '${file.path} should not regress to shallow or system-shaped feedback.',
              );
            }
            for (final snippet in snippetsByFile[fileName]!) {
              expect(
                feedbackCorrect,
                contains(snippet),
                reason:
                    '${file.path} should explain the poker reason in plain language.',
              );
            }
          }
        }
      }
    },
  );
}
