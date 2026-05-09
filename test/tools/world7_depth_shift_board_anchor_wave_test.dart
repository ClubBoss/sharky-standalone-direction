import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w7.s05 depth-shift family teaches plain poker reasons instead of shallow or system-shaped feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefix = 'content/worlds/world7/v1/sessions/w7.s05/drills/';
      const admittedFiles = <String>[
        'd.choose_call_after_shift.json',
        'd.choose_fold_after_shift.json',
        'd.find_bb_shift_turn.json',
        'd.find_sb_shift_turn.json',
        'd.tap_flop_reference_shift.json',
        'd.tap_hole_right_shift.json',
        'd.tap_river_depth_shift.json',
        'd.tap_turn_depth_shift.json',
      ];

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where((item) => item.filePath.startsWith(familyPrefix))
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason:
            'The admitted w7.s05 family should no longer emit audit findings.',
      );

      const actionSnippets = <String, List<String>>{
        'd.choose_call_after_shift.json': <String>[
          'Call fits',
          'still playable',
        ],
        'd.choose_fold_after_shift.json': <String>[
          'Fold fits',
          'spot turns bad',
        ],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_bb_shift_turn.json': <String>[
          'Start at the big blind',
          'pressure first',
        ],
        'd.find_sb_shift_turn.json': <String>[
          'Start at the small blind',
          'act first',
        ],
        'd.tap_flop_reference_shift.json': <String>[
          'Use the left flop card',
          'board story',
        ],
        'd.tap_hole_right_shift.json': <String>[
          'Use the right hole card',
          'keep pressure on',
        ],
        'd.tap_turn_depth_shift.json': <String>[
          'Use the turn',
          'pressure spot changes',
        ],
        'd.tap_river_depth_shift.json': <String>[
          'Use the river',
          'pressure still works',
        ],
      };

      const bannedFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
        'anchor',
        'context',
        'coverage',
        'upgrade',
        'flattening',
        'verify',
      ];

      for (final fileName in admittedFiles) {
        final file = File('$repoRoot/$familyPrefix$fileName');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final prompt = json['prompt'] as String;
        final why = json['why_v1'] as String;
        final feedbackCorrect = json['feedback_correct_v1'] as String;
        final feedbackIncorrect = json['feedback_incorrect_v1'] as String;

        for (final fragment in bannedFragments) {
          expect(
            prompt.toLowerCase(),
            isNot(contains(fragment)),
            reason:
                '${file.path} prompt should stay in plain learner language.',
          );
          expect(
            why.toLowerCase(),
            isNot(contains(fragment)),
            reason:
                '${file.path} why_v1 should stay in plain learner language.',
          );
          expect(
            feedbackCorrect.toLowerCase(),
            isNot(contains(fragment)),
            reason:
                '${file.path} feedback_correct_v1 should not regress to shallow or system-shaped language.',
          );
          expect(
            feedbackIncorrect.toLowerCase(),
            isNot(contains(fragment)),
            reason:
                '${file.path} feedback_incorrect_v1 should not regress to shallow or system-shaped language.',
          );
        }

        if (actionSnippets.containsKey(fileName)) {
          for (final snippet in actionSnippets[fileName]!) {
            expect(
              feedbackCorrect,
              contains(snippet),
              reason: '${file.path} should explain why the action fits.',
            );
          }
        }

        if (correctSnippetsByFile.containsKey(fileName)) {
          for (final snippet in correctSnippetsByFile[fileName]!) {
            expect(
              feedbackCorrect,
              contains(snippet),
              reason: '${file.path} should explain why the cue matters.',
            );
          }
        }

        expect(
          prompt.trim().endsWith('.'),
          isTrue,
          reason: '${file.path} should keep prompts short and plain.',
        );
        expect(
          why.trim().endsWith('.'),
          isTrue,
          reason: '${file.path} should keep why_v1 to one plain sentence.',
        );
        expect(
          feedbackIncorrect,
          startsWith('Incorrect.'),
          reason: '${file.path} should keep direct learner-facing correction.',
        );
      }
    },
  );
}
