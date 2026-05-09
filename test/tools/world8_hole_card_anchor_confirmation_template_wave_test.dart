import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'World8 hole-card anchor confirmations teach why the exact private-card cue matters instead of shallow confirmation',
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
                  return json['kind'] == 'hole_cards_tap';
                })
                .toList(growable: false)
              ..sort((a, b) => a.path.compareTo(b.path));

        expect(
          files,
          isNotEmpty,
          reason: '$session should keep a bounded hole-card anchor slice.',
        );

        for (final file in files) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final feedback = json['feedback_correct_v1'] as String;

          expect(
            feedback,
            isNot(contains('Correct. Hole-card anchor is confirmed.')),
            reason:
                '${file.path} should not regress to shallow hole-card confirmation.',
          );

          final expected = json['expected'] as Map<String, dynamic>;
          final cardId = expected['cardId'] as String?;
          final cardSlot = expected['cardSlot'] as String;

          if (cardId == 'As') {
            expect(
              feedback,
              contains('As is the hole-card anchor'),
              reason: '${file.path} should name the ace blocker cue.',
            );
            expect(
              feedback,
              contains('blocker cue'),
              reason: '${file.path} should explain why As matters.',
            );
          } else if (cardId == 'Ks') {
            expect(
              feedback,
              contains('Ks is the hole-card anchor'),
              reason: '${file.path} should name the king high-card cue.',
            );
            expect(
              feedback,
              contains('pressure balance honest'),
              reason: '${file.path} should explain why Ks matters.',
            );
          } else if (cardSlot == 'p0') {
            expect(
              feedback,
              contains('left hole card is the anchor'),
              reason: '${file.path} should explain why the left card matters.',
            );
            expect(
              feedback,
              contains('decision is built around first'),
              reason: '${file.path} should teach the left-card cue value.',
            );
          } else if (cardSlot == 'p1') {
            expect(
              feedback,
              contains('right hole card is the anchor'),
              reason: '${file.path} should explain why the right card matters.',
            );
            expect(
              feedback,
              contains('completes the tournament-pressure read'),
              reason: '${file.path} should teach the right-card cue value.',
            );
          } else {
            fail('Unexpected hole-card anchor shape in ${file.path}');
          }
        }
      }
    },
  );
}
