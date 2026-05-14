import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Act0 RU surface strings contain no unapproved latin residue', () {
    const files = <String>[
      'lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart',
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
      'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      'lib/ui_v2/act0_shell/act0_placement_shell_v1.dart',
    ];

    const allowedTokens = <String>{
      'Sharky',
      'Hero',
      'BTN',
      'SB',
      'BB',
      'CO',
      'HJ',
      'XP',
      'A-K',
      'I',
    };

    final latinToken = RegExp(r'[A-Za-z]+(?:-[A-Za-z]+)?');
    final bad = <String>[];

    for (final path in files) {
      final lines = File(path).readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        final match = RegExp(
          r"(?:ru:\s*'([^']*)'|text:\s*'([^']*)')",
        ).firstMatch(line);
        if (match == null) {
          continue;
        }
        final value = match.group(1) ?? match.group(2) ?? '';
        if (value.contains(r'${') ||
            value.contains(r'$') ||
            value.contains(r'\u')) {
          continue;
        }
        final tokens = latinToken
            .allMatches(value)
            .map((m) => m.group(0)!)
            .where((token) => !allowedTokens.contains(token))
            .toList();
        if (tokens.isNotEmpty) {
          bad.add('$path:${index + 1}: ${tokens.join(", ")} :: $value');
        }
      }
    }

    expect(
      bad,
      isEmpty,
      reason: bad.isEmpty
          ? null
          : 'Unapproved latin residue in RU strings:\n${bad.join('\n')}',
    );
  });
}
