import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'booster and review launcher facades keep legacy launcher ownership explicit',
    () {
      final boosterPackLauncher = File(
        'lib/services/booster_pack_launcher.dart',
      ).readAsStringSync();
      final theoryBoosterLauncher = File(
        'lib/services/theory_booster_launcher.dart',
      ).readAsStringSync();
      final mistakeDrillLauncher = File(
        'lib/services/mistake_drill_launcher_service.dart',
      ).readAsStringSync();
      final decayBoosterLauncher = File(
        'lib/services/decay_booster_training_launcher.dart',
      ).readAsStringSync();
      final autoRetry = File(
        'lib/services/booster_auto_retry_suggester.dart',
      ).readAsStringSync();

      expect(
        boosterPackLauncher.contains(
          'launcher = launcher ?? TrainingSessionLauncher()',
        ),
        isTrue,
        reason:
            'Booster pack launcher should remain an explicit wrapper over TrainingSessionLauncher.',
      );
      expect(
        theoryBoosterLauncher.contains(
          'launcher = launcher ?? TrainingSessionLauncher()',
        ),
        isTrue,
        reason:
            'Theory booster launcher should remain an explicit wrapper over TrainingSessionLauncher.',
      );
      expect(
        mistakeDrillLauncher.contains(
          'launcher = launcher ?? TrainingSessionLauncher()',
        ),
        isTrue,
        reason:
            'Mistake drill launcher should remain an explicit wrapper over TrainingSessionLauncher.',
      );
      expect(
        decayBoosterLauncher.contains(
          'launcher = launcher ?? TrainingSessionLauncher()',
        ),
        isTrue,
        reason:
            'Decay booster launcher should remain an explicit wrapper over TrainingSessionLauncher.',
      );
      expect(
        autoRetry.contains('await TrainingSessionLauncher().launch(booster);'),
        isTrue,
        reason:
            'Booster auto-retry suggester should remain an explicit direct legacy launcher call.',
      );

      expect(
        boosterPackLauncher.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Booster pack launcher should not directly own canonical runner launching in this seam.',
      );
      expect(
        theoryBoosterLauncher.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Theory booster launcher should not directly own canonical runner launching in this seam.',
      );
      expect(
        mistakeDrillLauncher.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Mistake drill launcher should not directly own canonical runner launching in this seam.',
      );
      expect(
        decayBoosterLauncher.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Decay booster launcher should not directly own canonical runner launching in this seam.',
      );
      expect(
        autoRetry.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Booster auto-retry suggester should not directly own canonical runner launching in this seam.',
      );

      expect(
        boosterPackLauncher.contains(
          'world1_foundations_microtask_runner_screen.dart',
        ),
        isFalse,
        reason:
            'Booster pack launcher should not import canonical runner implementation directly.',
      );
      expect(
        theoryBoosterLauncher.contains(
          'world1_foundations_microtask_runner_screen.dart',
        ),
        isFalse,
        reason:
            'Theory booster launcher should not import canonical runner implementation directly.',
      );
      expect(
        mistakeDrillLauncher.contains(
          'world1_foundations_microtask_runner_screen.dart',
        ),
        isFalse,
        reason:
            'Mistake drill launcher should not import canonical runner implementation directly.',
      );
      expect(
        decayBoosterLauncher.contains(
          'world1_foundations_microtask_runner_screen.dart',
        ),
        isFalse,
        reason:
            'Decay booster launcher should not import canonical runner implementation directly.',
      );
      expect(
        autoRetry.contains('world1_foundations_microtask_runner_screen.dart'),
        isFalse,
        reason:
            'Booster auto-retry suggester should not import canonical runner implementation directly.',
      );
    },
  );
}
