import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World8 action confirmations teach why the tournament action fits instead of shallow confirmation',
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

      const actionSnippets = <String, List<String>>{
        'call': <String>[
          'Calling fits the tournament cue set',
          'preserves equity without risking more',
        ],
        'fold': <String>[
          'Folding fits the tournament cue set',
          'protects tournament life',
        ],
        'raise': <String>[
          'Raising fits the tournament cue set',
          'real leverage edge',
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
                  (file) => file.path.split('/').last.startsWith('d.choose_'),
                )
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          isNotEmpty,
          reason: '$session should keep a bounded action-confirmation slice.',
        );

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final feedback = json['feedback_correct_v1'] as String;

          expect(
            feedback,
            isNot(contains('Correct. Expected action is confirmed.')),
            reason:
                '${file.path} should not regress to shallow action confirmation.',
          );

          final actionId = json['expected']['actionId'] as String;
          for (final snippet in actionSnippets[actionId]!) {
            expect(
              feedback,
              contains(snippet),
              reason: '${file.path} should explain why $actionId matters.',
            );
          }
        }
      }
    },
  );
}
