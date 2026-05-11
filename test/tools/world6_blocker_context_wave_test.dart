import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w6.s08 blocker-context family teaches range and blocker cues instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world6/v1/sessions/w6.s08/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w6.s08 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>[
          'The blocker refines the range read',
          'does not override',
        ],
        'raise': <String>['Raising fits', 'range edge'],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn_blocker_context.json': <String>[
          'Button is the seat anchor',
          'acting last',
        ],
        'd.find_co_blocker_context.json': <String>[
          'Cutoff is the seat anchor',
          'earlier late-position seat',
        ],
        'd.tap_flop_blocker_context.json': <String>[
          'flop_mid is the board anchor',
          'central flop card',
        ],
        'd.tap_hole_left_blocker.json': <String>[
          'As is the hole-card anchor',
          'blocker removes',
        ],
        'd.tap_river_blocker_context.json': <String>[
          'river is the board anchor',
          'last card decides',
        ],
        'd.tap_turn_blocker_context.json': <String>[
          'turn is the board anchor',
          'second board change',
        ],
      };

      const incorrectSnippetsByFile = <String, List<String>>{
        'd.tap_flop_blocker_context.json': <String>[
          'middle flop card is the correct board cue',
          'sits between both ranges',
        ],
      };

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];

      const bannedIncorrectFragments = <String>[
        'Tap the middle flop card because',
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
          } else {
            for (final snippet in correctSnippetsByFile[fileName]!) {
              expect(
                feedbackCorrect,
                contains(snippet),
                reason: '${file.path} should explain why the cue matters.',
              );
            }
          }
        }

        if (json['feedback_incorrect_v1'] case final String feedbackIncorrect) {
          if (incorrectSnippetsByFile.containsKey(fileName)) {
            for (final snippet in incorrectSnippetsByFile[fileName]!) {
              expect(
                feedbackIncorrect,
                contains(snippet),
                reason:
                    '${file.path} should keep the incorrect guidance concrete.',
              );
            }
          }
          for (final fragment in bannedIncorrectFragments) {
            expect(
              feedbackIncorrect,
              isNot(contains(fragment)),
              reason: '${file.path} should not reuse generic anchor phrasing.',
            );
          }
        }
      }
    },
  );
}
