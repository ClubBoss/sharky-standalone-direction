import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test(
    'w6.s02-w6.s05 range cluster teaches anchor and action value instead of generic or shallow feedback',
    () {
      final repoRoot = Directory.current.path;
      final admittedPrefixes = <String>[
        'content/worlds/world6/v1/sessions/w6.s02/drills/',
        'content/worlds/world6/v1/sessions/w6.s03/drills/',
        'content/worlds/world6/v1/sessions/w6.s04/drills/',
        'content/worlds/world6/v1/sessions/w6.s05/drills/',
      ];

      final report = buildFeedbackQualityAuditReportV2(rootPath: repoRoot);
      final clusterFindings = report.findings
          .where(
            (item) => admittedPrefixes.any(
              (prefix) => item.filePath.startsWith(prefix),
            ),
          )
          .toList(growable: false);

      expect(
        clusterFindings,
        isEmpty,
        reason:
            'w6.s02-w6.s05 should no longer emit audit findings after this wave.',
      );

      const admittedFiles = <String, List<String>>{
        'content/worlds/world6/v1/sessions/w6.s02/drills/': <String>[
          'd.choose_call_realize.json',
          'd.choose_raise_blocker.json',
          'd.find_bb.json',
          'd.find_btn_realize.json',
          'd.tap_flop_realize.json',
          'd.tap_hole_right_ks.json',
          'd.tap_river_trap.json',
          'd.tap_turn.json',
        ],
        'content/worlds/world6/v1/sessions/w6.s03/drills/': <String>[
          'd.choose_call_realize.json',
          'd.choose_fold_trap.json',
          'd.choose_raise_range.json',
          'd.find_bb_advantage.json',
          'd.find_sb.json',
          'd.tap_flop_left.json',
          'd.tap_hole_left.json',
          'd.tap_turn_advantage.json',
        ],
        'content/worlds/world6/v1/sessions/w6.s04/drills/': <String>[
          'd.choose_call_turn_compress.json',
          'd.choose_raise_turn_edge.json',
          'd.find_btn_turn_compress.json',
          'd.find_hj_turn_compress.json',
          'd.tap_flop_reference.json',
          'd.tap_hole_left_turn.json',
          'd.tap_river_turn_compress.json',
          'd.tap_turn_compress.json',
        ],
        'content/worlds/world6/v1/sessions/w6.s05/drills/': <String>[
          'd.choose_fold_merged.json',
          'd.choose_raise_polar.json',
          'd.find_bb_river_polar.json',
          'd.find_sb_river_polar.json',
          'd.tap_flop_river_polar.json',
          'd.tap_hole_right_polar.json',
          'd.tap_river_polar.json',
          'd.tap_turn_reference.json',
        ],
      };

      const actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits', 'because'],
        'fold': <String>['Folding fits', 'because'],
        'raise': <String>['Raising fits', 'because'],
      };

      const correctSnippetsByFile = <String, List<String>>{
        'd.find_bb.json': <String>[
          'continuing big blind range is narrower',
          'facing an early open',
        ],
        'd.find_btn_realize.json': <String>[
          'button range is wider',
          'late position',
        ],
        'd.tap_flop_realize.json': <String>[
          'UTG is stronger on average',
          'fewer, stronger hands',
        ],
        'd.tap_hole_right_ks.json': <String>[
          'Ks is the hole-card anchor',
          'raise story credible',
        ],
        'd.tap_river_trap.json': <String>[
          'river is the board anchor',
          'trap line ends',
        ],
        'd.tap_turn.json': <String>[
          'Late position is wider',
          'cutoff and button ranges',
        ],
        'd.choose_call_realize.json': <String>[
          'continuing range is narrower',
          'facing an open',
        ],
        'd.choose_raise_blocker.json': <String>[
          'button range is less constrained',
          'more varied set of hands',
        ],
        'd.choose_fold_trap.json': <String>[
          'Folding fits',
          'tempting hand fragment',
        ],
        'd.choose_raise_range.json': <String>[
          'Raising fits',
          'cleaner advantage',
        ],
        'd.find_bb_advantage.json': <String>[
          'Big blind is the seat anchor',
          'advantage battle',
        ],
        'd.find_sb.json': <String>[
          'Small blind is the seat anchor',
          'pressured in-between seat',
        ],
        'd.tap_flop_left.json': <String>[
          'flop_left is the board anchor',
          'first flop card',
        ],
        'd.tap_hole_left.json': <String>[
          'Left hole card is the hole-card anchor',
          'real hand edge',
        ],
        'd.tap_turn_advantage.json': <String>[
          'turn is the board anchor',
          'advantage still holds or breaks down',
        ],
        'd.choose_call_turn_compress.json': <String>[
          'Calling fits',
          'compressed turn',
        ],
        'd.choose_raise_turn_edge.json': <String>[
          'Raising fits',
          'pressure edge',
        ],
        'd.find_btn_turn_compress.json': <String>[
          'Button is the seat anchor',
          'information edge',
        ],
        'd.find_hj_turn_compress.json': <String>[
          'Hijack is the seat anchor',
          'compressed turn',
        ],
        'd.tap_flop_reference.json': <String>[
          'flop_mid is the board anchor',
          'original flop texture',
        ],
        'd.tap_hole_left_turn.json': <String>[
          'Left hole card is the hole-card anchor',
          'compressed turn can still pressure',
        ],
        'd.tap_river_turn_compress.json': <String>[
          'river is the board anchor',
          'compressed line stayed close',
        ],
        'd.tap_turn_compress.json': <String>[
          'turn is the board anchor',
          'compresses the ranges',
        ],
        'd.choose_fold_merged.json': <String>['Folding fits', 'merged river'],
        'd.choose_raise_polar.json': <String>[
          'Raising fits',
          'polarized enough',
        ],
        'd.find_bb_river_polar.json': <String>[
          'Big blind is the seat anchor',
          'capped bluff-catching range',
        ],
        'd.find_sb_river_polar.json': <String>[
          'Small blind is the seat anchor',
          'polarized river line is attacking',
        ],
        'd.tap_flop_river_polar.json': <String>[
          'flop_right is the board anchor',
          'polarized river',
        ],
        'd.tap_hole_right_polar.json': <String>[
          'Right hole card is the hole-card anchor',
          'polarize credibly',
        ],
        'd.tap_river_polar.json': <String>[
          'river is the board anchor',
          'merged or polarized pressure',
        ],
        'd.tap_turn_reference.json': <String>[
          'turn is the board anchor',
          'board tightened or stretched',
        ],
      };

      const incorrectSnippetsByFile = <String, List<String>>{
        'd.find_btn_realize.json': <String>[
          'button range is wider',
          'more hands can fit',
        ],
        'd.find_bb.json': <String>[
          'continuing range is narrower',
          'not every possible hand remains',
        ],
        'd.choose_raise_blocker.json': <String>[
          'button range is less constrained',
          'fewer players remain behind',
        ],
        'd.tap_flop_realize.json': <String>[
          'UTG is stronger on average',
          'range starts tighter',
        ],
        'd.tap_hole_right_ks.json': <String>[
          'Ks is the correct hole-card cue',
          'apply real pressure',
        ],
        'd.find_sb.json': <String>[
          'small blind is the right seat anchor',
          'range structure grounded',
        ],
        'd.tap_hole_left.json': <String>[
          'left hole card is the right hand cue',
          'range pressure is real',
        ],
        'd.find_hj_turn_compress.json': <String>[
          'hijack is the right seat anchor',
          'compressed turn is squeezing',
        ],
        'd.tap_hole_left_turn.json': <String>[
          'left hole card is the right hand cue',
          'should pressure or stay controlled',
        ],
        'd.find_sb_river_polar.json': <String>[
          'small blind is the right seat anchor',
          'earlier defending range',
        ],
        'd.tap_hole_right_polar.json': <String>[
          'right hole card is the correct hand cue',
          'polarized raise is credible',
        ],
      };

      const bannedCorrectFragments = <String>[
        'Correct. Expected action is confirmed.',
        'Correct. Seat anchor is confirmed.',
        'Correct. Board anchor is confirmed.',
        'Correct. Hole-card anchor is confirmed.',
      ];
      const bannedIncorrectFragments = <String>[
        'Find the button first so',
        'Find the small blind first so',
        'Find the hijack first so',
        'Tap the king of spades first because',
        'Tap the left hole card first so',
        'Tap the right hole card first so',
      ];

      for (final entry in admittedFiles.entries) {
        for (final fileName in entry.value) {
          final file = File('$repoRoot/${entry.key}$fileName');
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

          if (json['feedback_correct_v1'] case final String feedbackCorrect) {
            for (final fragment in bannedCorrectFragments) {
              expect(
                feedbackCorrect,
                isNot(contains(fragment)),
                reason: '${file.path} should not regress to shallow feedback.',
              );
            }
            if (json['kind'] == 'action_choice') {
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

          if (json['feedback_incorrect_v1']
              case final String feedbackIncorrect) {
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
                reason:
                    '${file.path} should not reuse generic anchor phrasing.',
              );
            }
          }
        }
      }
    },
  );
}
