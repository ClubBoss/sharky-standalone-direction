import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/world_intents_ssot_v1.dart';

void main() {
  test('world4 bet sizing family uses canonical allowed intents only', () {
    final repoRoot = Directory.current.path;
    final sessionIds = <String>[
      'w4.s01',
      'w4.s02',
      'w4.s03',
      'w4.s04',
      'w4.s05',
      'w4.s06',
      'w4.s07',
      'w4.s08',
      'w4.s09',
      'w4.s10',
    ];

    var admittedFiles = 0;
    for (final sessionId in sessionIds) {
      final allowed = allowedIntentsV1ForSessionId(sessionId);
      final sessionDir = Directory(
        '$repoRoot/content/worlds/world4/v1/sessions/$sessionId/drills',
      );
      final files =
          sessionDir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList(growable: false)
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
        final kind = json['kind'] as String?;
        if (kind != 'bet_sizing_choice_v1') {
          continue;
        }

        admittedFiles++;
        final intent = json['intent_v1'] as String?;
        expect(
          intent,
          isNotNull,
          reason: '${file.path} should keep intent_v1.',
        );
        expect(
          allowed.contains(intent),
          isTrue,
          reason: '${file.path} should use a canonical World 4 intent.',
        );
        expect(
          intent!.startsWith('world4_'),
          isFalse,
          reason:
              '${file.path} should not keep session-specific legacy intent labels.',
        );
      }
    }

    expect(
      admittedFiles,
      40,
      reason: 'World 4 should keep the admitted 40-file bet sizing family.',
    );
  });
}
