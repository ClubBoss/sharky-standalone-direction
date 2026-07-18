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
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  return parsed?.toUtc();
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
