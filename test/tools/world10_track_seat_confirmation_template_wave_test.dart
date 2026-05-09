import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World10 track seat confirmations teach why the exact role or seat matters instead of shallow confirmation',
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

      const roleSnippets = <String, List<String>>{
        'co': <String>[
          'cutoff is the right seat anchor',
          'before the button takes over',
        ],
        'btn': <String>[
          'button is the right seat anchor',
          'late-acting seat controlling the pressure window',
        ],
        'hj': <String>[
          'hijack is the right seat anchor',
          'earlier late-position seat that starts the pressure line',
        ],
        'utg': <String>[
          'Under the gun is the right seat anchor',
          'earliest seat that has to act without late-position cover',
        ],
        'sb': <String>[
          'small blind is the right seat anchor',
          'out-of-position blind that feels the pressure first',
        ],
      };

      for (final entry in admittedSessions.entries) {
        final root = entry.key;

        for (final sessionId in entry.value) {
          final session = Directory('$repoRoot/$root/$sessionId');
          final files =
              session
                  .listSync()
                  .whereType<Directory>()
                  .where((dir) => dir.path.endsWith('/drills'))
                  .expand((dir) => dir.listSync().whereType<File>())
                  .where((file) {
                    final name = file.path.split('/').last;
                    return name == 'd.find_role_anchor.json' ||
                        name == 'd.find_seat_anchor.json';
                  })
                  .toList(growable: false)
                ..sort((a, b) => a.path.compareTo(b.path));

          expect(
            files,
            hasLength(2),
            reason: '${session.path} should keep a bounded 2-file seat slice.',
          );

          for (final file in files) {
            final json =
                jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
            final feedback = json['feedback_correct_v1'] as String;

            expect(
              feedback,
              isNot(contains('Correct. Expected seat is confirmed.')),
              reason:
                  '${file.path} should not regress to shallow seat confirmation.',
            );

            final expected = json['expected'] as Map<String, dynamic>;
            final role = expected['role'] as String?;
            final seatId = expected['seatId'] as String?;

            if (role != null) {
              for (final snippet in roleSnippets[role]!) {
                expect(
                  feedback.toLowerCase(),
                  contains(snippet.toLowerCase()),
                  reason: '${file.path} should explain why $role matters.',
                );
              }
            } else {
              expect(
                seatId,
                'S2',
                reason: '${file.path} should remain the admitted seat owner.',
              );
              expect(
                feedback,
                contains('Seat S2 is the right seat anchor'),
                reason: '${file.path} should name the exact seat anchor.',
              );
              expect(
                feedback,
                contains(
                  'exact player slot this track decision is built around',
                ),
                reason: '${file.path} should explain why S2 matters.',
              );
            }
          }
        }
      }
    },
  );
}
