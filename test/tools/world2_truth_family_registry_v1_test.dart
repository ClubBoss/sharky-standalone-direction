import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'World 2 truth family registry stays aligned with onboarded families',
    () {
      const registryPath = 'docs/plan/world2_truth_family_registry_v1.md';
      final content = File(registryPath).readAsStringSync();

      expect(File(registryPath).existsSync(), isTrue);

      expect(content, contains('`showdown_winner_choice_v1`'));
      expect(
        content,
        contains('`lib/services/world2_showdown_truth_validator_v1.dart`'),
      );
      expect(
        content,
        contains('`tools/validate_world2_showdown_truth_v1.dart`'),
      );
      expect(
        content,
        contains('`test/tools/world2_showdown_truth_validator_v1_test.dart`'),
      );

      expect(content, contains('`outs_count_choice_v1`'));
      expect(
        content,
        contains('`lib/services/world2_outs_truth_validator_v1.dart`'),
      );
      expect(content, contains('`tools/validate_world2_outs_truth_v1.dart`'));
      expect(
        content,
        contains('`test/tools/world2_outs_truth_validator_v1_test.dart`'),
      );

      expect(content, contains('`board_texture_classifier_v1`'));
    },
  );
}
