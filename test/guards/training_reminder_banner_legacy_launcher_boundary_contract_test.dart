import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'training reminder banner cluster keeps legacy launcher entrypoints isolated',
    () {
      final engine = File(
        'lib/services/training_reminder_banner_engine.dart',
      ).readAsStringSync();
      final goalReminder = File(
        'lib/widgets/goal_reminder_banner.dart',
      ).readAsStringSync();
      final brokenStreak = File(
        'lib/widgets/broken_streak_banner.dart',
      ).readAsStringSync();

      expect(
        engine.contains('ReminderBanner build() => const ReminderBanner(GoalReminderBanner());'),
        isTrue,
        reason:
            'Daily goal reminder should remain an explicit reminder-engine banner source.',
      );
      expect(
        engine.contains('ReminderBanner build() => const ReminderBanner(BrokenStreakBanner());'),
        isTrue,
        reason:
            'Broken streak reminder should remain an explicit reminder-engine banner source.',
      );

      expect(
        goalReminder.contains('await TrainingSessionLauncher().launch(pack);'),
        isTrue,
        reason:
            'Goal reminder banner still intentionally reaches the legacy launcher.',
      );
      expect(
        brokenStreak.contains('await TrainingSessionLauncher().launch(tpl);'),
        isTrue,
        reason:
            'Broken streak banner still intentionally reaches the legacy launcher.',
      );

      expect(
        goalReminder.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Reminder banners should not directly own canonical runner launching in this seam.',
      );
      expect(
        brokenStreak.contains('pushWorld1FoundationsRunnerV1'),
        isFalse,
        reason:
            'Reminder banners should stay outside canonical runner ownership in this seam.',
      );
      expect(
        goalReminder.contains('world1_foundations_microtask_runner_screen.dart'),
        isFalse,
        reason:
            'Goal reminder banner should not import canonical runner implementation directly.',
      );
      expect(
        brokenStreak.contains('world1_foundations_microtask_runner_screen.dart'),
        isFalse,
        reason:
            'Broken streak banner should not import canonical runner implementation directly.',
      );
    },
  );
}
