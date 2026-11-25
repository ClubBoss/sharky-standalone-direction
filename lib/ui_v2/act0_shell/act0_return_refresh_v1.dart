import 'act0_civil_days_v1.dart';
import 'act0_daily_practice_coverage_v1.dart';

/// Only the caller's finished, playable authored drills belong in [finishedDrills].
/// Unknown observation dates are treated as unseen, just as in daily practice.
List<String>? act0ReturnRefreshPlanV1({
  required String lastActiveDay,
  required String today,
  required Map<String, Iterable<String>> finishedDrills,
  Map<String, DateTime> lastSeenByDrill = const {},
}) {
  if ((act0CivilDayGapV1(lastActiveDay, today) ?? -1) < 7 ||
      finishedDrills.length < 3)
    return null;
  return act0ReturnRefreshDrillsV1(finishedDrills, lastSeenByDrill);
}

/// Also used to rebuild a still-pending offer after a same-day restart.
List<String>? act0ReturnRefreshDrillsV1(
  Map<String, Iterable<String>> finishedDrills,
  Map<String, DateTime> lastSeenByDrill,
) {
  final skills = finishedDrills.values.expand((skills) => skills).toSet();
  final coverage = dailyPracticeCoverageV1(
    finishedDrills,
    lastSeenByDrill,
    skills,
  );
  final skillHistory = {
    for (final entry in coverage.entries)
      if (entry.value.lastSeen case final seen?) entry.key: seen,
  };
  final orderedDrills = act0OldestSeenIdsV1(
    finishedDrills.keys,
    lastSeenByDrill,
  );
  final selected = <String>[];
  final coveredSkills = <String>{};
  for (final skill in act0OldestSeenIdsV1(skills, skillHistory)) {
    if (coveredSkills.contains(skill)) continue;
    final candidate = orderedDrills
        .where(
          (id) =>
              finishedDrills[id]!.contains(skill) &&
              !finishedDrills[id]!.any(coveredSkills.contains),
        )
        .firstOrNull;
    if (candidate == null) continue;
    selected.add(candidate);
    coveredSkills.addAll(finishedDrills[candidate]!);
    if (selected.length == 5) break;
  }
  return selected.length < 3 ? null : List.unmodifiable(selected);
}
