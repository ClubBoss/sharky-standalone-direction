import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_durable_retention_contract_v1.dart';

const String act0SpacedRepStateDueNowV1 = 'due_now';
const String act0SpacedRepStateNotDueV1 = 'not_due';
const String act0SpacedRepStateInsufficientEvidenceV1 = 'insufficient_evidence';

/// Read-only time-based schedule projection. Immediate repair remains owned by
/// the repair queue; this projection contains only concept-level spaced debt.
class Act0SpacedRepetitionScheduleV1 {
  const Act0SpacedRepetitionScheduleV1({
    this.schedules = const <Act0SpacedRepetitionFamilyScheduleV1>[],
  });

  factory Act0SpacedRepetitionScheduleV1.fromRetention({
    required DateTime nowUtc,
    required Act0DurableRetentionHistoryV1 retentionHistory,
  }) {
    final now = nowUtc.toUtc();
    final schedules = <Act0SpacedRepetitionFamilyScheduleV1>[];
    for (final family in retentionHistory.families) {
      final refreshed = family.refreshedAt(now);
      if (refreshed.nextDueAtUtc == null) {
        schedules.add(
          Act0SpacedRepetitionFamilyScheduleV1(
            conceptFamilyId: refreshed.conceptFamilyId,
            scheduleState: act0SpacedRepStateInsufficientEvidenceV1,
            retentionState: refreshed.retentionState,
            nextDueAtUtc: null,
            sourceTaskId: refreshed.sourceTaskId,
            repeatedMissCount: refreshed.incorrectCount,
            lapseCount: refreshed.lapseCount,
          ),
        );
        continue;
      }
      schedules.add(
        Act0SpacedRepetitionFamilyScheduleV1(
          conceptFamilyId: refreshed.conceptFamilyId,
          scheduleState: refreshed.retentionState == Act0RetentionStateV1.due
              ? act0SpacedRepStateDueNowV1
              : act0SpacedRepStateNotDueV1,
          retentionState: refreshed.retentionState,
          nextDueAtUtc: refreshed.nextDueAtUtc,
          sourceTaskId: refreshed.sourceTaskId,
          repeatedMissCount: refreshed.incorrectCount,
          lapseCount: refreshed.lapseCount,
        ),
      );
    }
    schedules.sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0SpacedRepetitionScheduleV1(
      schedules: List<Act0SpacedRepetitionFamilyScheduleV1>.unmodifiable(
        schedules,
      ),
    );
  }

  final List<Act0SpacedRepetitionFamilyScheduleV1> schedules;

  List<Act0SpacedRepetitionFamilyScheduleV1> get dueFamilies {
    final due = schedules.where((schedule) => schedule.isDueNow).toList()
      ..sort(_compareDueFamily);
    return List<Act0SpacedRepetitionFamilyScheduleV1>.unmodifiable(due);
  }

  Act0SpacedRepetitionFamilyScheduleV1? get nextDueFamily =>
      dueFamilies.isEmpty ? null : dueFamilies.first;

  Act0SpacedRepetitionFamilyScheduleV1? scheduleForConceptFamily(String id) {
    final normalized = id.trim();
    for (final schedule in schedules) {
      if (schedule.conceptFamilyId == normalized) {
        return schedule;
      }
    }
    return null;
  }

  List<Map<String, Object?>> toPayload() =>
      schedules.map((schedule) => schedule.toPayload()).toList(growable: false);

  static Act0SpacedRepetitionScheduleV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0SpacedRepetitionScheduleV1();
    }
    final byConcept = <String, Act0SpacedRepetitionFamilyScheduleV1>{};
    for (final value in raw) {
      final schedule = Act0SpacedRepetitionFamilyScheduleV1.tryParse(value);
      if (schedule != null) {
        byConcept[schedule.conceptFamilyId] = schedule;
      }
    }
    final schedules = byConcept.values.toList()
      ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0SpacedRepetitionScheduleV1(
      schedules: List<Act0SpacedRepetitionFamilyScheduleV1>.unmodifiable(
        schedules,
      ),
    );
  }
}

class Act0SpacedRepetitionFamilyScheduleV1 {
  const Act0SpacedRepetitionFamilyScheduleV1({
    this.schemaVersion = 2,
    required this.conceptFamilyId,
    required this.scheduleState,
    required this.retentionState,
    required this.nextDueAtUtc,
    required this.sourceTaskId,
    required this.repeatedMissCount,
    required this.lapseCount,
  });

  final int schemaVersion;
  final String conceptFamilyId;
  final String scheduleState;
  final Act0RetentionStateV1 retentionState;
  final DateTime? nextDueAtUtc;
  final String sourceTaskId;
  final int repeatedMissCount;
  final int lapseCount;

  bool get isDueNow => scheduleState == act0SpacedRepStateDueNowV1;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'conceptFamilyId': conceptFamilyId,
    'scheduleState': scheduleState,
    'retentionState': retentionState.name,
    if (nextDueAtUtc != null)
      'nextDueAtUtc': act0UtcStorageStringV1(nextDueAtUtc!),
    'sourceTaskId': sourceTaskId,
    'repeatedMissCount': repeatedMissCount,
    'lapseCount': lapseCount,
  };

  static Act0SpacedRepetitionFamilyScheduleV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _int(map['schemaVersion']);
    final conceptFamilyId = map['conceptFamilyId']?.toString().trim() ?? '';
    final scheduleState = map['scheduleState']?.toString().trim() ?? '';
    final retentionState = act0EnumByNameV1(
      Act0RetentionStateV1.values,
      map['retentionState'],
    );
    final repeatedMissCount = _int(map['repeatedMissCount']);
    final lapseCount = _int(map['lapseCount']);
    if (schemaVersion != 2 ||
        conceptFamilyId.isEmpty ||
        retentionState == null ||
        repeatedMissCount == null ||
        lapseCount == null ||
        !_states.contains(scheduleState)) {
      return null;
    }
    return Act0SpacedRepetitionFamilyScheduleV1(
      conceptFamilyId: conceptFamilyId,
      scheduleState: scheduleState,
      retentionState: retentionState,
      nextDueAtUtc: act0TryParseUtcV1(map['nextDueAtUtc']),
      sourceTaskId: map['sourceTaskId']?.toString().trim() ?? '',
      repeatedMissCount: repeatedMissCount,
      lapseCount: lapseCount,
    );
  }
}

int _compareDueFamily(
  Act0SpacedRepetitionFamilyScheduleV1 a,
  Act0SpacedRepetitionFamilyScheduleV1 b,
) {
  final due = a.nextDueAtUtc!.compareTo(b.nextDueAtUtc!);
  if (due != 0) {
    return due;
  }
  final severity = (b.repeatedMissCount + b.lapseCount).compareTo(
    a.repeatedMissCount + a.lapseCount,
  );
  if (severity != 0) {
    return severity;
  }
  final concept = a.conceptFamilyId.compareTo(b.conceptFamilyId);
  return concept != 0 ? concept : a.sourceTaskId.compareTo(b.sourceTaskId);
}

int? _int(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

const Set<String> _states = <String>{
  act0SpacedRepStateDueNowV1,
  act0SpacedRepStateNotDueV1,
  act0SpacedRepStateInsufficientEvidenceV1,
};
