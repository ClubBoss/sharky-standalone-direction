import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w6.s01 range intro family teaches anchor and action value instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world6/v1/sessions/w6.s01/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w6.s01 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'build a bigger pot cleanly'],
        'fold': <String>['Folding fits', 'one strong card is not enough'],
        'raise': <String>['Raising fits', 'real pressure advantage'],
      };
      const correctSnippetsByFile = <String, List<String>>{
        'd.classify_missed_fold.json': <String>[
          'Fold fits this missed bucket',
          'weak range under pressure',
        ],
        'd.classify_strong_raise.json': <String>[
          'Raise fits this strong bucket',
          'build the pot before weaker continues shut down',
        ],
        'd.find_btn.json': <String>[
          'Button is the seat anchor',
          'clearest positional edge',
        ],
        'd.find_co_range.json': <String>[
          'Cutoff is the seat anchor',
          'applying pressure first',
        ],
        'd.tap_flop_mid.json': <String>[
          'flop_mid is the board anchor',
          'range story stays connected or starts to miss',
        ],
        'd.tap_hole_left_as.json': <String>[
          'As is the hole-card anchor',
          'blocker cue',
        ],
        'd.tap_turn_range.json': <String>[
          'turn is the board anchor',
          'range pressure is growing or flattening',
        ],
      };
      const incorrectSnippetsByFile = <String, List<String>>{
        'd.classify_missed_fold.json': <String>[
          'weak range under pressure has too little clean equity',
        ],
        'd.classify_strong_raise.json': <String>[
          'in-position value range should build the pot',
        ],
        'd.find_btn.json': <String>[
          'button is the correct anchor',
          'acting last gives this range setup the clearest positional edge',
        ],
        'd.find_co_range.json': <String>[
          'cutoff is the correct anchor',
          'earlier late-position seat',
        ],
        'd.tap_flop_mid.json': <String>[
          'flop_mid is the correct board cue',
          'texture anchor',
        ],
        'd.tap_hole_left_as.json': <String>[
          'As is the correct hole-card cue',
          'upgrade or weaken the range read',
        ],
        'd.tap_turn_range.json': <String>[
          'turn is the correct board cue',
          'second street change',
        ],
      };

      final files =
          Directory('$repoRoot/content/worlds/world6/v1/sessions/w6.s01/drills')
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList(growable: false)
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        if (json['feedback_correct_v1'] case final String feedbackCorrect) {
          expect(
            feedbackCorrect,
            isNot(contains('Correct. Expected action is confirmed.')),
            reason:
                '${file.path} should not regress to shallow action confirmation.',
          );
          expect(
            feedbackCorrect,
            isNot(contains('Correct. Seat anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow seat confirmation.',
          );
          expect(
            feedbackCorrect,
            isNot(contains('Correct. Board anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow board confirmation.',
          );
          expect(
            feedbackCorrect,
            isNot(contains('Correct. Hole-card anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow hole-card confirmation.',
          );

          final name = file.uri.pathSegments.last;
          if (name.startsWith('d.choose_')) {
            final actionId = json['expected']['actionId'] as String;
            for (final snippet in actionSnippets[actionId]!) {
              expect(
                feedbackCorrect,
                contains(snippet),
                reason: '${file.path} should explain why $actionId fits.',
              );
            }
          } else if (correctSnippetsByFile.containsKey(name)) {
            for (final snippet in correctSnippetsByFile[name]!) {
              expect(
                feedbackCorrect,
                contains(snippet),
                reason: '${file.path} should explain why the cue matters.',
              );
            }
          }
        }

        if (json['feedback_incorrect_v1'] case final String feedbackIncorrect) {
          final name = file.uri.pathSegments.last;
          if (incorrectSnippetsByFile.containsKey(name)) {
            for (final snippet in incorrectSnippetsByFile[name]!) {
              expect(
                feedbackIncorrect,
                contains(snippet),
                reason:
                    '${file.path} should keep the incorrect guidance concrete.',
              );
            }
          }
        }
      }
    },
  );
}
