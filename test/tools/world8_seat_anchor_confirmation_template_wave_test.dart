import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World8 seat-anchor confirmations teach why the exact tournament seat matters instead of shallow confirmation',
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

      const roleSnippets = <String, List<String>>{
        'btn': <String>[
          'button is the right seat anchor',
          'late-acting seat that controls the pressure window',
        ],
        'bb': <String>[
          'big blind is the right seat anchor',
          'forced defender who has to absorb the pressure first',
        ],
        'sb': <String>[
          'small blind is the right seat anchor',
          'out-of-position blind who feels the pressure first',
        ],
        'co': <String>[
          'cutoff is the right seat anchor',
          'last pressure seat before the button takes over',
        ],
      };

      for (final session in sessions) {
        final files =
            Directory(
                  '$repoRoot/content/worlds/world8/v1/sessions/$session/drills',
                )
                .listSync()
                .whereType<File>()
                .where(
                  (file) => file.path.split('/').last.startsWith('d.find_'),
                )
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          hasLength(2),
          reason: '$session should keep one bounded 2-file seat-anchor slice.',
        );

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final feedback = json['feedback_correct_v1'] as String;

          expect(
            feedback,
            isNot(contains('Correct. Seat anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow seat-anchor confirmation.',
          );

          final role = json['expected']['role'] as String;
          for (final snippet in roleSnippets[role]!) {
            expect(
              feedback.toLowerCase(),
              contains(snippet.toLowerCase()),
              reason: '${file.path} should explain why $role matters.',
            );
          }
        }
      }
    },
  );
}
