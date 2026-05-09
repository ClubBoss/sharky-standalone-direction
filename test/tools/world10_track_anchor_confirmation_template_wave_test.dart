import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World10 track anchor confirmations teach why the anchor matters instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final admittedSessions = <String, List<String>>{
        'content/worlds/world10/v1/tracks/cash/sessions': <String>[
          'cash.s01',
          'cash.s02',
          'cash.s03',
          'cash.s04',
          'cash.s05',
          'cash.s08',
          'cash.s09',
          'cash.s10',
        ],
        'content/worlds/world10/v1/tracks/tournament/sessions': <String>[
          'tournament.s01',
          'tournament.s02',
          'tournament.s03',
          'tournament.s04',
          'tournament.s05',
          'tournament.s06',
          'tournament.s07',
          'tournament.s08',
          'tournament.s09',
          'tournament.s10',
        ],
        'content/worlds/world10/v1/tracks/mixed/sessions': <String>[
          'mixed.s01',
          'mixed.s02',
          'mixed.s03',
          'mixed.s04',
          'mixed.s05',
          'mixed.s06',
          'mixed.s07',
          'mixed.s08',
          'mixed.s09',
          'mixed.s10',
        ],
      };

      const boardSnippets = <String, List<String>>{
        'flop_left': <String>[
          'flop_left is the first board anchor',
          'first public cue',
        ],
        'turn': <String>[
          'turn is the next board anchor',
          'middle street can change which pressure plan still fits',
        ],
        'river': <String>[
          'river is the final board anchor',
          'last public cue that decides whether pressure or control makes sense',
        ],
      };
      const cardSnippets = <String, List<String>>{
        'hole_left': <String>[
          'hole_left is the private-card anchor',
          'first hand cue that decides how much pressure this track can carry',
        ],
      };

      for (final entry in admittedSessions.entries) {
        final root = entry.key;

        for (final sessionId in entry.value) {
          final session = Directory('$repoRoot/$root/$sessionId/drills');
          final files =
              session
                  .listSync()
                  .whereType<File>()
                  .where((file) {
                    final name = file.path.split('/').last;
                    return name == 'd.tap_flop_left_anchor.json' ||
                        name == 'd.tap_hole_left_anchor.json' ||
                        name == 'd.tap_turn_anchor.json' ||
                        name == 'd.tap_river_anchor.json';
                  })
                  .toList(growable: false)
                ..sort((a, b) => a.path.compareTo(b.path));

          expect(
            files,
            hasLength(4),
            reason:
                '$root/$sessionId should keep a bounded 4-file anchor slice.',
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

            final kind = json['kind'] as String;
            if (kind == 'board_tap') {
              final boardSlot = json['expected']['boardSlot'] as String;
              for (final snippet in boardSnippets[boardSlot]!) {
                expect(
                  feedback,
                  contains(snippet),
                  reason: '${file.path} should explain why $boardSlot matters.',
                );
              }
            } else if (kind == 'card_tap') {
              final cardSlot = json['expected']['cardSlot'] as String;
              for (final snippet in cardSnippets[cardSlot]!) {
                expect(
                  feedback,
                  contains(snippet),
                  reason: '${file.path} should explain why $cardSlot matters.',
                );
              }
            } else {
              fail('Unhandled drill kind $kind for ${file.path}');
            }
          }
        }
      }
    },
  );
}
