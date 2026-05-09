import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w7.s10 depth synthesis family teaches anchor and action value instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world7/v1/sessions/w7.s10/drills/';

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason: 'w7.s10 should no longer emit audit findings after this wave.',
      );

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'not enough leverage'],
        'fold': <String>['Folding fits', 'preserving chips'],
        'raise': <String>['Raising fits', 'real pressure edge'],
      };
      const correctSnippetsByFile = <String, List<String>>{
        'd.find_btn_depth_synth.json': <String>[
          'Button is the seat anchor',
          'last acting seat',
        ],
        'd.find_co_depth_synth.json': <String>[
          'Cutoff is the seat anchor',
          'before the button takes over',
        ],
        'd.tap_flop_depth_synth.json': <String>[
          'flop_right is the first board anchor',
          'opening texture',
        ],
        'd.tap_hole_left_depth_synth.json': <String>[
          'As is the first hole-card anchor',
          'private-card cue',
        ],
        'd.tap_hole_right_depth_synth.json': <String>[
          'Ks is the second hole-card anchor',
          'full two-card structure',
        ],
        'd.tap_turn_depth_synth.json': <String>[
          'turn is the next board anchor',
          'leverage picture can strengthen, flatten, or disappear',
        ],
        'd.tap_river_depth_synth.json': <String>[
          'river is the final board anchor',
          'finished leverage picture',
        ],
      };
      const incorrectSnippetsByFile = <String, List<String>>{
        'd.find_co_depth_synth.json': <String>[
          'cutoff anchor comes before the button',
          'earlier late-position range',
        ],
        'd.tap_flop_depth_synth.json': <String>[
          'correct board cue is flop_right',
          'opening texture',
        ],
        'd.tap_hole_left_depth_synth.json': <String>[
          'correct private-card cue is As',
          'ace blocker',
        ],
        'd.tap_hole_right_depth_synth.json': <String>[
          'correct second card is Ks',
          'king completes the hole-card anchor',
        ],
      };

      final files =
          Directory('$repoRoot/content/worlds/world7/v1/sessions/w7.s10/drills')
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
                reason: '${file.path} should explain why the anchor matters.',
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
                    '${file.path} should keep the anchor explanation concrete.',
              );
            }
          }
        }
      }
    },
  );
}
