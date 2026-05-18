import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Active Act0 EN surfaces contain no banned alpha residue', () {
    const files = <String>[
      'lib/ui_v2/screens/modern_table_screen_v1.dart',
      'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
    ];

    const bannedPhrases = <String>[
      'Scenario Loader',
      'Clarity: tactical focus',
      'Scenario:',
      'Resume route',
      'Best next from Learn',
      'Keep the route moving',
      'Keep the route warm',
      'Recent gains',
    ];

    final hits = <String>[];

    for (final path in files) {
      final lines = File(path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final phrase in bannedPhrases) {
          if (line.contains(phrase)) {
            hits.add('$path:${i + 1}: $phrase');
          }
        }
      }
    }

    expect(
      hits,
      isEmpty,
      reason: hits.isEmpty
          ? null
          : 'Found banned EN alpha residue:\n${hits.join('\n')}',
    );
  });
}
