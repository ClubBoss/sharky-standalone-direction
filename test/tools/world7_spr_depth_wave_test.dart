import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w7.s02 SPR and depth family teaches why each cue matters instead of shallow confirmations',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world7/v1/sessions/w7.s02/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w7.s02 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>[
          'Calling fits',
          'deep stacks keep both ranges playable',
        ],
        'raise': <String>[
          'Raising fits',
          'stack-to-pot ratio creates enough leverage',
        ],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn.json': <String>['Button is the seat anchor', 'acting last'],
        'd.find_co_spr.json': <String>[
          'Cutoff is the seat anchor',
          'range the SPR pressure is aimed at',
        ],
        'd.tap_flop_spr.json': <String>[
          'flop_mid is the board anchor',
          'original board texture',
        ],
        'd.tap_hole_left_as.json': <String>[
          'As is the hole-card anchor',
          'blocker changes how credible',
        ],
        'd.tap_river_trap.json': <String>[
          'river is the board anchor',
          'deep-stack trap',
        ],
        'd.tap_turn.json': <String>[
          'turn is the board anchor',
          'second board change',
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
    },
  );
}
