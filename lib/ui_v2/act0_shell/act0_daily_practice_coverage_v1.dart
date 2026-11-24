enum Act0DailyPracticeCoverageStatusV1 { covered, thin, missing }

typedef Act0DailyPracticeSkillCoverageV1 = ({
  int eligibleDrillCount,
  DateTime? lastSeen,
  Act0DailyPracticeCoverageStatusV1 status,
});

/// [pool] maps each eligible drill ID to its existing projection skill IDs.
/// [completedDrills] maps drill IDs to their latest practice completion.
Map<String, Act0DailyPracticeSkillCoverageV1> dailyPracticeCoverageV1(
  Map<String, Iterable<String>> pool,
  Map<String, DateTime> completedDrills,
  Iterable<String> keySkills,
) {
  final counts = {for (final skill in keySkills) skill: 0};
  final lastSeen = <String, DateTime>{};
  for (final drill in pool.entries) {
    final completedAt = completedDrills[drill.key];
    for (final skill in drill.value.toSet()) {
      final count = counts[skill];
      if (count == null) continue;
      counts[skill] = count + 1;
      final previous = lastSeen[skill];
      if (completedAt != null &&
          (previous == null || completedAt.isAfter(previous))) {
        lastSeen[skill] = completedAt;
      }
    }
  }

  return {
    for (final entry in counts.entries)
      entry.key: (
        eligibleDrillCount: entry.value,
        lastSeen: lastSeen[entry.key],
        status: switch (entry.value) {
          0 => Act0DailyPracticeCoverageStatusV1.missing,
          < 3 => Act0DailyPracticeCoverageStatusV1.thin,
          _ => Act0DailyPracticeCoverageStatusV1.covered,
        },
      ),
  };
}

enum Act0DailyPracticeExhaustionStatusV1 { fresh, recycling, exhausted }

typedef Act0DailyPracticeExhaustionV1 = ({
  Act0DailyPracticeExhaustionStatusV1 status,
  List<String> recommendedDrillIds,
});

/// [recentHistory] contains the latest practice completion per drill in the
/// caller's recent-day window, including the current practice day.
/// [todayStartedAt] is the start of that day in the caller's practice calendar.
///
/// A pool is fresh if any drill is unseen in the window, recycling if every
/// drill was seen in the window, and exhausted if it is empty or every drill
/// was already seen today. Even on an exhausted day, the oldest drills can
/// be replayed. Equal timestamps and unseen drills are ordered by ID.
Act0DailyPracticeExhaustionV1 exhaustionV1(
  Iterable<String> pool,
  Map<String, DateTime> recentHistory, {
  required DateTime todayStartedAt,
}) {
  final ids = pool.toSet().toList();
  final status = ids.any((id) => !recentHistory.containsKey(id))
      ? Act0DailyPracticeExhaustionStatusV1.fresh
      : ids.every((id) => !recentHistory[id]!.isBefore(todayStartedAt))
      ? Act0DailyPracticeExhaustionStatusV1.exhausted
      : Act0DailyPracticeExhaustionStatusV1.recycling;

  ids.sort((left, right) {
    final leftSeen = recentHistory[left];
    final rightSeen = recentHistory[right];
    if (leftSeen == null && rightSeen != null) return -1;
    if (leftSeen != null && rightSeen == null) return 1;
    if (leftSeen != null && rightSeen != null) {
      final byTime = leftSeen.compareTo(rightSeen);
      if (byTime != 0) return byTime;
    }
    return left.compareTo(right);
  });

  return (status: status, recommendedDrillIds: ids.take(3).toList());
}
