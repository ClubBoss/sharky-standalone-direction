import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'shared learner top-level shell contract defines scaffold and safe-area ownership above the shared consumer path',
    () {
      final shellSource = File(
        'lib/ui_v2/runner/shared_learner_top_level_shell_v1.dart',
      ).readAsStringSync();
      final consumerSource = File(
        'lib/ui_v2/runner/shared_learner_canonical_consumer_path_v1.dart',
      ).readAsStringSync();

      expect(
        shellSource.contains('class SharedLearnerTopLevelShellContractV1'),
        isTrue,
      );
      expect(
        shellSource.contains('class SharedLearnerTopLevelShellV1'),
        isTrue,
      );
      expect(shellSource.contains('return Scaffold('), isTrue);
      expect(shellSource.contains('SafeArea('), isTrue);
      expect(
        consumerSource.contains(
          'SharedLearnerTopLevelShellContractV1? topLevelShellContract',
        ),
        isTrue,
      );
      expect(
        consumerSource.contains('return SharedLearnerTopLevelShellV1('),
        isTrue,
      );
    },
  );
}
