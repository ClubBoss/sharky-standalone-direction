import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w9.s05 position-control family teaches exploit anchor and action value instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world9/v1/sessions/w9.s05/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w9.s05 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'because'],
        'raise': <String>['Raising fits', 'because'],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn_position.json': <String>[
          'Button is the seat anchor',
          'position edge',
        ],
        'd.find_seat_s2_position.json': <String>[
          'Seat S2 is the seat anchor',
          'target of the position exploit',
        ],
        'd.tap_flop_position.json': <String>[
          'flop_left is the board anchor',
          'position-based exploit texture',
        ],
        'd.tap_hole_right_position.json': <String>[
          'Right hole card is the exploit anchor',
          'actual hand',
        ],
        'd.tap_river_position.json': <String>[
          'river is the board anchor',
          'value or pressure',
        ],
        'd.tap_turn_position.json': <String>[
          'turn is the board anchor',
          'before river closure',
        ],
      };

      const incorrectSnippetsByFile = <String, List<String>>{
        'd.find_seat_s2_position.json': <String>[
          'Seat S2 is the correct seat anchor',
          'exact player',
        ],
        'd.tap_flop_position.json': <String>[
          'left flop card is the correct board cue',
          'first public texture signal',
        ],
      };

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];

      const bannedIncorrectFragments = <String>[
        'Tap seat S2 because',
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
