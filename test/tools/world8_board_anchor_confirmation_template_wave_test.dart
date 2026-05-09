import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World8 board-anchor confirmations teach why the exact board cue matters instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final sessions = <String>[
        'w8.s01',
        'w8.s02',
        'w8.s03',
        'w8.s04',
        'w8.s05',
        'w8.s06',
        'w8.s07',
        'w8.s08',
        'w8.s09',
        'w8.s10',
      ];

      const slotSnippets = <String, List<String>>{
        'flop_left': <String>[
          'flop_left is the board anchor',
          'first card that frames the flop texture',
        ],
        'flop_mid': <String>[
          'flop_mid is the board anchor',
          'shapes the flop texture',
        ],
        'flop_right': <String>[
          'flop_right is the board anchor',
          'completes the flop texture',
        ],
        'turn': <String>[
          'turn is the board anchor',
          'pressure often changes shape',
        ],
        'river': <String>[
          'river is the board anchor',
          'decides the final pressure state',
        ],
      };

      for (final session in sessions) {
        final files =
            Directory(
                  '$repoRoot/content/worlds/world8/v1/sessions/$session/drills',
                )
                .listSync()
                .whereType<File>()
                .where((file) => file.path.split('/').last.startsWith('d.tap_'))
                .where((file) {
                  final json =
                      jsonDecode(file.readAsStringSync())
                          as Map<String, dynamic>;
                  return json['kind'] == 'board_tap';
                })
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          isNotEmpty,
          reason: '$session should keep a bounded board-anchor slice.',
        );

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final feedback = json['feedback_correct_v1'] as String;

          expect(
            feedback,
            isNot(contains('Correct. Board anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow board-anchor confirmation.',
          );

          final boardSlot = json['expected']['boardSlot'] as String;
          for (final snippet in slotSnippets[boardSlot]!) {
            expect(
              feedback,
              contains(snippet),
              reason: '${file.path} should explain why $boardSlot matters.',
            );
          }
        }
      }
    },
  );
}
