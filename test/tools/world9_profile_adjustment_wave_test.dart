import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w9.s01 profile-adjustment family teaches exploit cues instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world9/v1/sessions/w9.s01/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w9.s01 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'tight profile'],
        'fold': <String>['Folding fits', 'trap line'],
        'raise': <String>['Raising fits', 'exploit lever'],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn_profile.json': <String>[
          'Button is the seat anchor',
          'in-position seat',
        ],
        'd.find_seat_s1.json': <String>[
          'Seat S1 is the seat anchor',
          'target the exploit is built around',
        ],
        'd.tap_flop_left.json': <String>[
          'flop_left is the board anchor',
          'first flop cue',
        ],
        'd.tap_hole_left_as.json': <String>[
          'As is the hole-card anchor',
          'ace blocker',
        ],
        'd.tap_turn_profile.json': <String>[
          'turn is the board anchor',
          'fourth card',
        ],
      };

      const incorrectSnippetsByFile = <String, List<String>>{
        'd.tap_flop_left.json': <String>[
          'left flop card is the correct board cue',
          'first public card',
        ],
      };

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];

      const bannedIncorrectFragments = <String>[
        'Tap the left flop card because',
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
