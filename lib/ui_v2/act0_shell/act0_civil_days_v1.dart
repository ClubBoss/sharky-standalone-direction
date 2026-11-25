/// Difference between local calendar keys, independent of DST elapsed hours.
int? act0CivilDayGapV1(String previousDay, String today, {bool strict = true}) {
  DateTime? civil(String key) {
    final date = DateTime.tryParse(strict ? '${key}T00:00:00Z' : key);
    if (date == null) return null;
    if (strict &&
        (key.length != 10 || date.toIso8601String().substring(0, 10) != key))
      return null;
    return DateTime.utc(date.year, date.month, date.day);
  }

  final previous = civil(previousDay);
  final current = civil(today);
  if (previous == null || current == null) return null;
  return current.difference(previous).inDays;
}

bool act0AreConsecutiveCivilDaysV1(String previousDay, String today) =>
    // Preserve legacy streak handling, including permissive stored date parsing.
    act0CivilDayGapV1(previousDay, today, strict: false) == 1;
