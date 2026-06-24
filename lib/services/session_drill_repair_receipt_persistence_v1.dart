import 'dart:convert';

import 'package:poker_analyzer/services/board_texture_repair_receipt_mapping_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kSessionDrillRepairReceiptsPrefsKeyV1 =
    'session_drill_repair_receipts_v1';
const String kSessionDrillRetainedResultEventsPrefsKeyV1 =
    'session_drill_retained_result_events_v1';

class SessionDrillRetainedResultEventV1 {
  const SessionDrillRetainedResultEventV1({
    required this.schemaVersion,
    required this.eventId,
    required this.worldId,
    required this.sourceSessionId,
    required this.targetDrillId,
    required this.signalFamilyId,
    required this.learnerFacingClueName,
    required this.targetKind,
    required this.selectedActionId,
    required this.expectedActionId,
    required this.result,
    required this.context,
    required this.sourceFamily,
    required this.isRetainedForMasteryEvidence,
    required this.sourceReceiptKey,
    this.createdAtSequence,
    this.skillAtomId,
  });

  final int schemaVersion;
  final String eventId;
  final int? createdAtSequence;
  final String worldId;
  final String sourceSessionId;
  final String targetDrillId;
  final String? skillAtomId;
  final String signalFamilyId;
  final String learnerFacingClueName;
  final String targetKind;
  final String selectedActionId;
  final String expectedActionId;
  final String result;
  final String context;
  final String sourceFamily;
  final bool isRetainedForMasteryEvidence;
  final String sourceReceiptKey;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'eventId': eventId,
    'createdAtSequence': createdAtSequence,
    'worldId': worldId,
    'sourceSessionId': sourceSessionId,
    'targetDrillId': targetDrillId,
    'skillAtomId': skillAtomId,
    'signalFamilyId': signalFamilyId,
    'learnerFacingClueName': learnerFacingClueName,
    'targetKind': targetKind,
    'selectedActionId': selectedActionId,
    'expectedActionId': expectedActionId,
    'result': result,
    'context': context,
    'sourceFamily': sourceFamily,
    'isRetainedForMasteryEvidence': isRetainedForMasteryEvidence,
    'sourceReceiptKey': sourceReceiptKey,
  };

  static SessionDrillRetainedResultEventV1? tryParse(Map raw) {
    final schemaVersion = raw['schemaVersion'];
    if (schemaVersion != 1) return null;
    final createdAtSequence = raw['createdAtSequence'];
    if (createdAtSequence != null &&
        (createdAtSequence is! int || createdAtSequence < 0)) {
      return null;
    }
    final event = SessionDrillRetainedResultEventV1(
      schemaVersion: 1,
      eventId: _stringValueV1(raw['eventId']),
      createdAtSequence: createdAtSequence as int?,
      worldId: _stringValueV1(raw['worldId']),
      sourceSessionId: _stringValueV1(raw['sourceSessionId']),
      targetDrillId: _stringValueV1(raw['targetDrillId']),
      skillAtomId: _optionalStringValueV1(raw['skillAtomId']),
      signalFamilyId: _stringValueV1(raw['signalFamilyId']),
      learnerFacingClueName: _stringValueV1(raw['learnerFacingClueName']),
      targetKind: _stringValueV1(raw['targetKind']),
      selectedActionId: _stringValueV1(raw['selectedActionId']),
      expectedActionId: _stringValueV1(raw['expectedActionId']),
      result: _stringValueV1(raw['result']),
      context: _stringValueV1(raw['context']),
      sourceFamily: _stringValueV1(raw['sourceFamily']),
      isRetainedForMasteryEvidence:
          raw['isRetainedForMasteryEvidence'] == true,
      sourceReceiptKey: _stringValueV1(raw['sourceReceiptKey']),
    );
    if (<String>[
      event.eventId,
      event.worldId,
      event.sourceSessionId,
      event.targetDrillId,
      event.signalFamilyId,
      event.learnerFacingClueName,
      event.targetKind,
      event.selectedActionId,
      event.expectedActionId,
      event.result,
      event.context,
      event.sourceFamily,
      event.sourceReceiptKey,
    ].any((value) => value.isEmpty) ||
        !<String>{'success', 'miss'}.contains(event.result) ||
        event.context != 'recheck' ||
        !<String>{'w5_session_drill', 'w6_session_drill'}
            .contains(event.sourceFamily) ||
        !event.isRetainedForMasteryEvidence) {
      return null;
    }
    return event;
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDrillRetainedResultEventV1 &&
        other.eventId == eventId &&
        other.result == result &&
        other.sourceReceiptKey == sourceReceiptKey;
  }

  @override
  int get hashCode => Object.hash(eventId, result, sourceReceiptKey);
}

class SessionDrillRetainedResultPersistenceV1 {
  const SessionDrillRetainedResultPersistenceV1();

  Future<List<SessionDrillRetainedResultEventV1>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kSessionDrillRetainedResultEventsPrefsKeyV1);
    if (raw == null || raw.trim().isEmpty) {
      return const <SessionDrillRetainedResultEventV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <SessionDrillRetainedResultEventV1>[];
      return decoded
          .whereType<Map>()
          .map(SessionDrillRetainedResultEventV1.tryParse)
          .whereType<SessionDrillRetainedResultEventV1>()
          .toList(growable: false);
    } catch (_) {
      return const <SessionDrillRetainedResultEventV1>[];
    }
  }

  Future<void> appendEvent(SessionDrillRetainedResultEventV1 event) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadEvents();
    await prefs.setString(
      kSessionDrillRetainedResultEventsPrefsKeyV1,
      jsonEncode(<Map<String, Object?>>[
        for (final item in existing) item.toPayload(),
        event.toPayload(),
      ]),
    );
  }
}

class SessionDrillRepairReceiptPersistenceV1 {
  const SessionDrillRepairReceiptPersistenceV1();

  Future<List<SessionDrillRepairReceiptCandidateV1>> loadCandidates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kSessionDrillRepairReceiptsPrefsKeyV1);
    if (raw == null || raw.trim().isEmpty) {
      return const <SessionDrillRepairReceiptCandidateV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <SessionDrillRepairReceiptCandidateV1>[];
      }
      return decoded
          .whereType<Map>()
          .map((item) => _candidateFromPayloadV1(item))
          .whereType<SessionDrillRepairReceiptCandidateV1>()
          .toList(growable: false);
    } catch (_) {
      return const <SessionDrillRepairReceiptCandidateV1>[];
    }
  }

  Future<void> saveCandidate(
    SessionDrillRepairReceiptCandidateV1 candidate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadCandidates();
    final next = <SessionDrillRepairReceiptCandidateV1>[
      for (final item in existing)
        if (!_sameSourceDrillV1(item, candidate)) item,
      candidate,
    ];
    await prefs.setString(
      kSessionDrillRepairReceiptsPrefsKeyV1,
      jsonEncode(next.map((item) => item.toPayload()).toList(growable: false)),
    );
  }
}

Future<SessionDrillRepairReceiptCandidateV1?>
persistSessionDrillRepairReceiptCandidateIfEligibleV1({
  required String sourceSessionId,
  required SessionDrillItemV1 sourceDrill,
  required DrillEvalResultV1 evaluation,
  required String chosenActionId,
  SessionDrillRepairReceiptPersistenceV1 store =
      const SessionDrillRepairReceiptPersistenceV1(),
}) async {
  final candidate =
      buildSessionDrillRepairReceiptCandidateV1(
        sourceSessionId: sourceSessionId,
        sourceDrill: sourceDrill,
        evaluation: evaluation,
        chosenActionId: chosenActionId,
      ) ??
      buildBoardTextureRepairReceiptCandidateV1(
        sourceSessionId: sourceSessionId,
        sourceDrill: sourceDrill,
        evaluation: evaluation,
        chosenActionId: chosenActionId,
      );
  if (candidate == null) {
    return null;
  }
  await store.saveCandidate(candidate);
  return candidate;
}

Future<SessionDrillRetainedResultEventV1?>
persistSessionDrillRetainedResultIfEligibleV1({
  required bool isRecheckLaunchV1,
  required String? initialDrillId,
  required String sourceSessionId,
  required SessionDrillItemV1 currentDrill,
  required DrillEvalResultV1 evaluation,
  required String chosenActionId,
  SessionDrillRepairReceiptPersistenceV1 receiptStore =
      const SessionDrillRepairReceiptPersistenceV1(),
  SessionDrillRetainedResultPersistenceV1 resultStore =
      const SessionDrillRetainedResultPersistenceV1(),
}) async {
  final sessionId = sourceSessionId.trim().toLowerCase();
  final targetDrillId = currentDrill.drillId.trim();
  final initialTargetId = initialDrillId?.trim() ?? '';
  final selectedActionId = chosenActionId.trim().toLowerCase();
  final expectedActionId =
      currentDrill.spec.expectedActionV1?.trim().toLowerCase() ?? '';
  if (!isRecheckLaunchV1 ||
      (sessionId != 'w5.s01' && sessionId != 'w6.s01') ||
      targetDrillId.isEmpty ||
      targetDrillId != initialTargetId ||
      selectedActionId.isEmpty ||
      expectedActionId.isEmpty) {
    return null;
  }
  final receipt = (await receiptStore.loadCandidates()).cast<
      SessionDrillRepairReceiptCandidateV1?>().firstWhere(
        (candidate) =>
            candidate?.targetSessionId == sessionId &&
            candidate?.targetDrillId == targetDrillId &&
            candidate?.sourceWorldId ==
                (sessionId == 'w5.s01' ? 'world_5' : 'world_6'),
        orElse: () => null,
      );
  if (receipt == null) return null;
  final sourceReceiptKey =
      '${receipt.sourceSessionId}:${receipt.sourceDrillId}';
  final existing = await resultStore.loadEvents();
  final attemptNumber = existing
          .where(
            (event) =>
                event.sourceReceiptKey == sourceReceiptKey &&
                event.targetDrillId == targetDrillId &&
                event.context == 'recheck',
          )
          .length +
      1;
  final event = SessionDrillRetainedResultEventV1(
    schemaVersion: 1,
    eventId: '$sourceReceiptKey:$targetDrillId:recheck:$attemptNumber',
    worldId: receipt.sourceWorldId,
    sourceSessionId: sessionId,
    targetDrillId: targetDrillId,
    skillAtomId: null,
    signalFamilyId: receipt.missedSignalId,
    learnerFacingClueName: receipt.missedSignalLabel,
    targetKind: receipt.targetKind,
    selectedActionId: selectedActionId,
    expectedActionId: expectedActionId,
    result: evaluation.isPass ? 'success' : 'miss',
    context: 'recheck',
    sourceFamily: sessionId == 'w5.s01'
        ? 'w5_session_drill'
        : 'w6_session_drill',
    isRetainedForMasteryEvidence: true,
    sourceReceiptKey: sourceReceiptKey,
  );
  await resultStore.appendEvent(event);
  return event;
}

bool _sameSourceDrillV1(
  SessionDrillRepairReceiptCandidateV1 a,
  SessionDrillRepairReceiptCandidateV1 b,
) {
  return a.sourceSessionId == b.sourceSessionId &&
      a.sourceDrillId == b.sourceDrillId;
}

SessionDrillRepairReceiptCandidateV1? _candidateFromPayloadV1(Map item) {
  final schemaVersion = item['schemaVersion'];
  if (schemaVersion != 1) {
    return null;
  }
  final sourceWorldId = _stringValueV1(item['sourceWorldId']);
  final sourceSessionId = _stringValueV1(item['sourceSessionId']);
  final sourceDrillId = _stringValueV1(item['sourceDrillId']);
  final drillFamilyId = _stringValueV1(item['drillFamilyId']);
  final missedSignalId = _stringValueV1(item['missedSignalId']);
  final missedSignalLabel = _stringValueV1(item['missedSignalLabel']);
  final chosenActionId = _stringValueV1(item['chosenActionId']);
  final expectedActionId = _stringValueV1(item['expectedActionId']);
  final targetSessionId = _stringValueV1(item['targetSessionId']);
  final targetDrillId = _stringValueV1(item['targetDrillId']);
  final targetKind = _stringValueV1(item['targetKind']);
  final errorClass = _stringValueV1(item['errorClass']);
  if (<String>[
    sourceWorldId,
    sourceSessionId,
    sourceDrillId,
    drillFamilyId,
    missedSignalId,
    missedSignalLabel,
    chosenActionId,
    expectedActionId,
    targetSessionId,
    targetDrillId,
    targetKind,
    errorClass,
  ].any((value) => value.isEmpty)) {
    return null;
  }
  return SessionDrillRepairReceiptCandidateV1(
    schemaVersion: 1,
    sourceWorldId: sourceWorldId,
    sourceSessionId: sourceSessionId,
    sourceDrillId: sourceDrillId,
    drillFamilyId: drillFamilyId,
    missedSignalId: missedSignalId,
    missedSignalLabel: missedSignalLabel,
    chosenActionId: chosenActionId,
    expectedActionId: expectedActionId,
    targetSessionId: targetSessionId,
    targetDrillId: targetDrillId,
    targetKind: targetKind,
    errorClass: errorClass,
  );
}

String _stringValueV1(Object? value) => value?.toString().trim() ?? '';

String? _optionalStringValueV1(Object? value) {
  final normalized = _stringValueV1(value);
  return normalized.isEmpty ? null : normalized;
}
