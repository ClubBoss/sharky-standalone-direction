import 'dart:convert';

import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kSessionDrillRepairReceiptsPrefsKeyV1 =
    'session_drill_repair_receipts_v1';

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
  final candidate = buildSessionDrillRepairReceiptCandidateV1(
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
