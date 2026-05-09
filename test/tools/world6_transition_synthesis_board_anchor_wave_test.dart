import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w6 transition+synthesis lane teaches plain poker reasons instead of shallow or system-shaped feedback',
    () {
      final repoRoot = Directory.current.path;
      const familyPrefixes = <String>[
        'content/worlds/world6/v1/sessions/w6.s09/drills/',
        'content/worlds/world6/v1/sessions/w6.s10/drills/',
      ];
      const admittedFiles = <String>[
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.choose_call_flop_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.choose_raise_river_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.find_bb_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.find_btn_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.tap_flop_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.tap_hole_right_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.tap_river_transition.json',
        'content/worlds/world6/v1/sessions/w6.s09/drills/d.tap_turn_transition.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.choose_call_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.choose_raise_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.find_btn_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.find_co_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.tap_flop_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.tap_hole_left_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.tap_river_synthesis.json',
        'content/worlds/world6/v1/sessions/w6.s10/drills/d.tap_turn_synthesis.json',
      ];

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final familyFindings = report.findings
          .where(
            (item) => familyPrefixes.any(
              (prefix) => item.filePath.startsWith(prefix),
            ),
          )
          .toList(growable: false);

      expect(
        familyFindings,
        isEmpty,
        reason:
            'The admitted w6.s09/w6.s10 lane should no longer emit audit findings.',
      );

      const actionSnippets = <String, List<String>>{
        'd.choose_call_flop_transition.json': <String>[
          'Call fits',
          'flop is still close',
        ],
        'd.choose_raise_river_transition.json': <String>[
          'Raise fits',
          'strong enough to keep betting',
        ],
        'd.choose_call_synthesis.json': <String>[
          'Call fits',
          'full picture is still mixed',
        ],
        'd.choose_raise_synthesis.json': <String>[
          'Raise fits',
          'full picture lines up',
        ],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_bb_transition.json': <String>[
          'Start at the big blind',
          'defender',
        ],
        'd.find_btn_transition.json': <String>[
          'Start at the button',
          'acting last',
        ],
        'd.tap_turn_transition.json': <String>[
          'Use the turn',
          'turn against you',
        ],
        'd.find_btn_synthesis.json': <String>[
          'Start at the button',
          'acting last',
        ],
        'd.find_co_synthesis.json': <String>[
          'Start at the cutoff',
          'shapes the spot',
        ],
        'd.tap_river_synthesis.json': <String>[
          'Use the river',
          'value bet, keep betting, or slow down',
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
        'transition',
        'synthesis',
        'range edge',
        'board-anchor',
      ];

      for (final relativePath in admittedFiles) {
        final file = File('$repoRoot/$relativePath');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final fileName = file.uri.pathSegments.last;
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
