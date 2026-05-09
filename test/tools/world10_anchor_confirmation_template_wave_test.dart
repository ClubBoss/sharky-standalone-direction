import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World10 core session anchor confirmations teach why the anchor matters instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final sessions = <String>[
        'w10.s01',
        'w10.s02',
        'w10.s03',
        'w10.s04',
        'w10.s05',
        'w10.s06',
        'w10.s07',
        'w10.s08',
        'w10.s09',
        'w10.s10',
      ];

      const boardSnippets = <String, List<String>>{
        'flop_left': <String>[
          'flop_left is the first board anchor',
          'sets the flop pattern',
        ],
        'flop_mid': <String>[
          'flop_mid is the first board anchor',
          'shapes the flop pattern',
        ],
        'flop_right': <String>[
          'flop_right is the first board anchor',
          'completes the flop pattern',
        ],
        'turn': <String>[
          'turn is the next board anchor',
          'late-street pressure gets exaggerated',
        ],
        'river': <String>[
          'river is the final board anchor',
          'decides the full texture',
        ],
      };

      for (final session in sessions) {
        final files =
            Directory(
                  '$repoRoot/content/worlds/world10/v1/sessions/$session/drills',
                )
                .listSync()
                .whereType<File>()
                .where((file) => file.path.split('/').last.startsWith('d.tap_'))
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          hasLength(4),
          reason: '$session should keep one bounded 4-file anchor slice.',
        );

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final feedback = json['feedback_correct_v1'] as String;

          expect(
            feedback,
            isNot(contains('Correct. Expected anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow anchor confirmation.',
          );
          expect(
            feedback,
            isNot(contains('Correct. Seat anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow seat-anchor confirmation.',
          );

          final kind = json['kind'] as String;
          if (kind == 'hole_cards_tap') {
            final cardId = json['expected']['cardId'] as String;
            expect(
              feedback,
              contains('$cardId is the anchor card'),
              reason: '${file.path} should name the exact hole-card anchor.',
            );
            expect(
              feedback,
              contains('exact hole-card cue this line is built on'),
              reason:
                  '${file.path} should explain why the hole-card anchor matters.',
            );
          } else {
            final boardSlot = json['expected']['boardSlot'] as String;
            for (final snippet in boardSnippets[boardSlot]!) {
              expect(
                feedback,
                contains(snippet),
                reason: '${file.path} should explain why $boardSlot matters.',
              );
            }
          }
        }
      }
    },
  );
}
