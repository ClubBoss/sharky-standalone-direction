// Existing channel values are retained for compatibility; the selected
// local time is no longer restricted to the evening.
enum Act0PracticeReminderScheduleV1 { none, nextEvening, tomorrowEvening }

/// No reminder without an actionable count. A single practice answer is enough
/// to suppress today's reminder, irrespective of correctness or daily goal.
({Act0PracticeReminderScheduleV1 schedule, String? body})
act0PracticeReminderPlanV1({
  required bool practicedToday,
  required int dueRepeats,
  required int warmupCount,
}) {
  final body = dueRepeats > 0
      ? '$dueRepeats ${dueRepeats == 1 ? 'repeat' : 'repeats'} ready in Review.'
      : warmupCount > 0
      ? '$warmupCount warm-up ${warmupCount == 1 ? 'drill' : 'drills'} ready.'
      : null;
  return (
    schedule: body == null
        ? Act0PracticeReminderScheduleV1.none
        : practicedToday
        ? Act0PracticeReminderScheduleV1.tomorrowEvening
        : Act0PracticeReminderScheduleV1.nextEvening,
    body: body,
  );
}
