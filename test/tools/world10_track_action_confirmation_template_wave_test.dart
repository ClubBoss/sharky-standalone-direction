import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World10 track action confirmations teach why the action fits instead of shallow confirmation',
    () {
      final repoRoot = Directory.current.path;
      final admittedFiles = <String, Map<String, List<String>>>{
        'content/worlds/world10/v1/tracks/cash/sessions':
            <String, List<String>>{
              'cash.s01': <String>['d.call.json', 'd.raise.json'],
              'cash.s02': <String>['d.bet.json', 'd.check.json'],
              'cash.s03': <String>['d.call.json', 'd.fold.json'],
              'cash.s04': <String>['d.call.json', 'd.raise.json'],
              'cash.s05': <String>['d.bet.json', 'd.check.json'],
              'cash.s08': <String>['d.bet.json', 'd.check.json'],
              'cash.s09': <String>['d.call.json', 'd.fold.json'],
              'cash.s10': <String>['d.call.json', 'd.raise.json'],
            },
        'content/worlds/world10/v1/tracks/tournament/sessions':
            <String, List<String>>{
              'tournament.s01': <String>['d.fold.json', 'd.raise.json'],
              'tournament.s02': <String>['d.check.json', 'd.fold.json'],
              'tournament.s03': <String>['d.call.json', 'd.fold.json'],
              'tournament.s04': <String>['d.fold.json', 'd.raise.json'],
              'tournament.s05': <String>['d.check.json', 'd.fold.json'],
              'tournament.s06': <String>['d.call.json', 'd.fold.json'],
              'tournament.s07': <String>['d.fold.json', 'd.raise.json'],
              'tournament.s08': <String>['d.check.json', 'd.fold.json'],
              'tournament.s09': <String>['d.call.json', 'd.fold.json'],
              'tournament.s10': <String>['d.fold.json', 'd.raise.json'],
            },
        'content/worlds/world10/v1/tracks/mixed/sessions':
            <String, List<String>>{
              'mixed.s01': <String>['d.call.json', 'd.raise.json'],
              'mixed.s02': <String>['d.bet.json', 'd.check.json'],
              'mixed.s03': <String>['d.call.json', 'd.fold.json'],
              'mixed.s04': <String>['d.call.json', 'd.raise.json'],
              'mixed.s05': <String>['d.bet.json', 'd.check.json'],
              'mixed.s06': <String>['d.call.json', 'd.fold.json'],
              'mixed.s07': <String>['d.call.json', 'd.raise.json'],
              'mixed.s08': <String>['d.bet.json', 'd.check.json'],
              'mixed.s09': <String>['d.call.json', 'd.fold.json'],
              'mixed.s10': <String>['d.call.json', 'd.raise.json'],
            },
      };

      const actionSnippets = <String, List<String>>{
        'call': <String>[
          'Calling fits the track cue set',
          'controlled continue',
        ],
        'raise': <String>[
          'Raising fits the track cue set',
          'real leverage edge',
        ],
        'fold': <String>['Folding fits the track cue set', 'avoids paying off'],
        'bet': <String>[
          'Betting fits the track cue set',
          'presses value or denial',
        ],
        'check': <String>[
          'Checking fits the track cue set',
          'keeps the pot controlled',
        ],
      };

      for (final entry in admittedFiles.entries) {
        final root = entry.key;

        for (final sessionEntry in entry.value.entries) {
          final sessionId = sessionEntry.key;
          final files = sessionEntry.value
              .map((name) => File('$repoRoot/$root/$sessionId/drills/$name'))
              .toList(growable: false);

          expect(
            files,
            hasLength(2),
            reason:
                '$root/$sessionId should keep a bounded 2-file action slice.',
          );

          for (final file in files) {
            expect(
              file.existsSync(),
              isTrue,
              reason: '${file.path} should exist in the admitted owner slice.',
            );

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
                reason: '${file.path} should explain why $actionId fits.',
              );
            }
          }
        }
      }
    },
  );
}
