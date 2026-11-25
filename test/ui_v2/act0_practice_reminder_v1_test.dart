import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_reminder_plan_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_warmup_v1.dart';

void main() {
  test('one practice answer suppresses reminders for today', () {
    for (final practicedToday in [false, true]) {
      final plan = act0PracticeReminderPlanV1(
        practicedToday: practicedToday,
        dueRepeats: 2,
        warmupCount: 5,
      );
      expect(
        plan.schedule,
        practicedToday
            ? Act0PracticeReminderScheduleV1.tomorrowEvening
            : Act0PracticeReminderScheduleV1.nextEvening,
      );
      expect(plan.body, '2 repeats ready in Review.');
    }
  });

  test(
    'uses actual warm-up selector counts and no fabricated availability',
    () {
      final drill = (
        worldId: 'w',
        lessonId: 'l',
        taskId: 't',
        repairSourceTaskId: 'miss',
        skills: ['skill'],
      );
      final warmup = selectAct0WarmupV1(
        misses: [
          (at: null, skills: ['skill'], repair: drill),
        ],
        practicePool: [],
      );
      final plan = act0PracticeReminderPlanV1(
        practicedToday: false,
        dueRepeats: 0,
        warmupCount: warmup.drills.length,
      );
      expect(plan.body, '1 warm-up drill ready.');
      final empty = act0PracticeReminderPlanV1(
        practicedToday: false,
        dueRepeats: 0,
        warmupCount: 0,
      );
      expect(empty.schedule, Act0PracticeReminderScheduleV1.none);
      expect(empty.body, isNull);
    },
  );
}
