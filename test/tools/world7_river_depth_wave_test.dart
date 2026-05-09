import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w7.s09 river-depth family teaches closure cues without curriculum labels or shallow confirmations',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world7/v1/sessions/w7.s09/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w7.s09 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'closure threshold is still medium'],
        'raise': <String>['Raising fits', 'favors leverage'],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn_river_depth.json': <String>[
          'Button is the seat anchor',
          'acting last',
        ],
        'd.find_co_river_depth.json': <String>[
          'Cutoff is the seat anchor',
          'before the button takes over',
        ],
        'd.tap_flop_river_depth.json': <String>[
          'flop_right is the board anchor',
          'original texture',
        ],
        'd.tap_hole_right_river_depth.json': <String>[
          'Right hole card is the hole-card anchor',
          'real hand cue',
        ],
        'd.tap_river_depth_close.json': <String>[
          'river is the board anchor',
          'last card locks',
        ],
        'd.tap_turn_river_reference.json': <String>[
          'turn is the board anchor',
          'comparison point',
        ],
      };

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];

      final files =
          Directory('$repoRoot/$familyPrefix')
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList(growable: false)
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final fileName = file.uri.pathSegments.last;

        if (json['feedback_correct_v1'] case final String feedbackCorrect) {
          for (final fragment in bannedCorrectFragments) {
            expect(
              feedbackCorrect,
              isNot(contains(fragment)),
              reason: '${file.path} should not regress to shallow feedback.',
            );
          }

          if (fileName.startsWith('d.choose_')) {
            final actionId =
                (json['expected'] as Map<String, dynamic>)['actionId']
                    as String;
            for (final snippet in actionSnippets[actionId]!) {
              expect(
                feedbackCorrect,
                contains(snippet),
                reason: '${file.path} should explain why $actionId fits.',
              );
            }
          } else if (correctSnippetsByFile.containsKey(fileName)) {
            for (final snippet in correctSnippetsByFile[fileName]!) {
              expect(
                feedbackCorrect,
                contains(snippet),
                reason: '${file.path} should explain why the cue matters.',
              );
            }
          }
        }
      }

      final recapPath =
          '$repoRoot/content/worlds/world7/v1/sessions/w7.s09/drills/'
          'd.chain_world7_river_depth_recap_v1.json';
      final recapJson =
          jsonDecode(File(recapPath).readAsStringSync())
              as Map<String, dynamic>;
      final steps = recapJson['steps'] as List<dynamic>;
      final stepTwo = steps[1] as Map<String, dynamic>;

      expect(
        stepTwo['feedback_incorrect_v1'] as String,
        contains('the line should push harder'),
      );
      expect(
        stepTwo['feedback_incorrect_v1'] as String,
        isNot(contains('World 7 should')),
      );
    },
  );
}
