import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w9.s04 frequency-control family teaches exploit cues instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world9/v1/sessions/w9.s04/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w9.s04 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'frequency control'],
        'raise': <String>['Raising fits', 'frequency band'],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn_freq_control.json': <String>[
          'Button is the seat anchor',
          'controls how often',
        ],
        'd.find_sb_freq_control.json': <String>[
          'Small blind is the seat anchor',
          'pressure source',
        ],
        'd.tap_flop_freq_control.json': <String>[
          'flop_mid is the board anchor',
          'central flop texture',
        ],
        'd.tap_hole_left_freq_control.json': <String>[
          'As is the hole-card anchor',
          'ace blocker',
        ],
        'd.tap_river_freq_control.json': <String>[
          'river is the board anchor',
          'finished board',
        ],
        'd.tap_turn_freq_control.json': <String>[
          'turn is the board anchor',
          'fourth street',
        ],
      };

      const incorrectSnippetsByFile = <String, List<String>>{
        'd.tap_river_freq_control.json': <String>[
          'river is the correct board cue',
          'finished board decides',
        ],
      };

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];

      const bannedIncorrectFragments = <String>['Tap the river card because'];

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
