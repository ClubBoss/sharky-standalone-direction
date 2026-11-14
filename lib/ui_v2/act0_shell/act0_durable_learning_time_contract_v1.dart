/// Centralized UTC/time and evidence-kind contract for durable learning v1.
abstract interface class Act0UtcClockV1 {
  DateTime nowUtc();
}

class Act0SystemUtcClockV1 implements Act0UtcClockV1 {
  const Act0SystemUtcClockV1();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class Act0FixedUtcClockV1 implements Act0UtcClockV1 {
  const Act0FixedUtcClockV1(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value.toUtc();
}

/// Versioned spacing and recent-evidence thresholds. Do not scatter literals.
abstract final class Act0DurableLearningTimingV1 {
  static const Duration recoveryToFirstReview = Duration(hours: 24);
  static const Duration firstToSecondReview = Duration(hours: 72);
  static const Duration durableMaintenance = Duration(days: 7);
  static const Duration lapseToReview = Duration(hours: 24);
  static const Duration minimumTransferSeparation = Duration(hours: 24);
  static const int durableSpacedSuccesses = 2;
  static const int recentEvidenceWindow = 4;
}

/// Append-only stable evidence identities. Learner-facing copy must not use
/// enum names directly.
enum Act0ReviewKindV1 {
  legacyUnspaced,
  initialAssessment,
  immediateRepair,
  exactReplay,
  alternateSameSignal,
  originalSourceRecheck,
  spacedReview,
  unseenTransfer,
}

enum Act0RetentionStateV1 {
  unseen,
  needsRepair,
  recoveredPendingSpacedReview,
  due,
  durable,
  lapsed,
}

enum Act0TransferVerdictV1 {
  insufficientEvidence,
  recoveredNotDurable,
  improving,
  stable,
  regressing,
  mixed,
}

String act0UtcStorageStringV1(DateTime value) =>
    value.toUtc().toIso8601String();

DateTime? act0TryParseUtcV1(Object? raw) {
  if (raw is! String) return null;
  final match = RegExp(
    r'^([+-]?\d{4,6})-(\d{2})-(\d{2})[Tt](\d{2}):(\d{2}):(\d{2})(?:\.(\d{1,6}))?(?:[Zz]|([+-])(\d{2}):?(\d{2}))$',
  ).firstMatch(raw.trim());
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final hour = int.parse(match[4]!);
  final minute = int.parse(match[5]!);
  final second = int.parse(match[6]!);
  final offsetHours = int.parse(match[9] ?? '0');
  final offsetMinutes = int.parse(match[10] ?? '0');
  if (month < 1 ||
      month > 12 ||
      day < 1 ||
      hour > 23 ||
      minute > 59 ||
      second > 59 ||
      offsetHours > 23 ||
      offsetMinutes > 59) {
    return null;
  }
  try {
    // DateTime.tryParse normalizes invalid civil values (Feb 31, hour 25).
    // Validate the original local date before applying a legitimate offset.
    const monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    final leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    final days = month == 2 && leap ? 29 : monthDays[month - 1];
    if (day > days) return null;
    final micros = int.parse((match[7] ?? '').padRight(6, '0'));
    final local = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      micros ~/ 1000,
      micros % 1000,
    );
    final offset = Duration(minutes: offsetHours * 60 + offsetMinutes);
    return match[8] == '-' ? local.add(offset) : local.subtract(offset);
  } on ArgumentError {
    return null;
  }
}

T? act0EnumByNameV1<T extends Enum>(Iterable<T> values, Object? raw) {
  final name = raw?.toString().trim() ?? '';
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}
