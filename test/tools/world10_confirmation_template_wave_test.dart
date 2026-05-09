import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World10 core session confirmation templates teach action and seat value instead of shallow confirmation',
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

      final actionSnippets = <String, List<String>>{
        'call': <String>['Calling fits the cue set', 'controlled continue'],
        'raise': <String>['Raising fits the cue set', 'applies pressure'],
        'fold': <String>['Folding fits the cue set', 'avoids paying off'],
      };
      final roleSnippets = <String, List<String>>{
        'btn': <String>['button', 'positional edge'],
        'co': <String>['cutoff', 'before the button takes over'],
        'sb': <String>['small blind', 'out-of-position seat'],
        'bb': <String>['big blind', 'forced defender'],
        'hj': <String>['hijack', 'earlier late-position range'],
      };
      const bannedPhrases = <String>{
        'Correct. Expected action is confirmed.',
        'Correct. Expected seat is confirmed.',
        'Correct. Seat anchor is confirmed.',
      };

      for (final session in sessions) {
        final files =
            Directory(
                  '$repoRoot/content/worlds/world10/v1/sessions/$session/drills',
                )
                .listSync()
                .whereType<File>()
                .where((file) {
                  final name = file.path.split('/').last;
                  return name.startsWith('d.choose_') ||
                      name.startsWith('d.find_role_') ||
                      name.startsWith('d.find_seat_');
                })
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          hasLength(4),
          reason: '$session should keep one bounded 4-file confirmation slice.',
        );

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final feedback = json['feedback_correct_v1'] as String;

          for (final banned in bannedPhrases) {
            expect(
              feedback,
              isNot(contains(banned)),
              reason:
                  '${file.path} should not regress to shallow confirmation.',
            );
          }

          final kind = json['kind'] as String;
          if (kind == 'action_choice') {
            final actionId = json['expected']['actionId'] as String;
            for (final snippet in actionSnippets[actionId]!) {
              expect(
                feedback,
                contains(snippet),
                reason: '${file.path} should explain why $actionId fits.',
              );
            }
          } else if (json['expected']['role'] != null) {
            final role = json['expected']['role'] as String;
            for (final snippet in roleSnippets[role]!) {
              expect(
                feedback.toLowerCase(),
                contains(snippet.toLowerCase()),
                reason: '${file.path} should explain why $role is the anchor.',
              );
            }
          } else {
            final seatId = json['expected']['seatId'] as String;
            expect(
              feedback,
              contains('Seat $seatId'),
              reason: '${file.path} should name the exact player seat.',
            );
            expect(
              feedback,
              contains('exact seat this plan is built around'),
              reason: '${file.path} should explain why the seat matters.',
            );
          }
        }
      }
    },
  );
}
