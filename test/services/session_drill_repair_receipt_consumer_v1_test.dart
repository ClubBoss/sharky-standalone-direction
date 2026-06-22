import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_consumer_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const store = SessionDrillRepairReceiptPersistenceV1();
  const consumer = SessionDrillRepairReceiptConsumerV1();

  Future<SessionDrillItemV1> drill(String id) async {
    final drills = await runtime.loadSessionDrills('w6.s01');
    return drills.firstWhere((item) => item.drillId == id);
  }

  Future<SessionDrillRepairReceiptCandidateV1> missedReceipt() async {
    final source = await drill('classify_missed_fold');
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice('raise'),
    );
    final receipt = buildSessionDrillRepairReceiptCandidateV1(
      sourceSessionId: 'w6.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: 'raise',
    );
    return receipt!;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'persisted range-bucket receipt creates one internal recheck candidate',
    () async {
      await store.saveCandidate(await missedReceipt());

      final candidates = await consumer.loadRangeBucketRecheckCandidates();

      expect(candidates, hasLength(1));
      final candidate = candidates.single;
      expect(candidate.schemaVersion, 1);
      expect(candidate.consumerKind, 'session_drill_recheck');
      expect(candidate.sourceWorldId, 'world_6');
      expect(candidate.sourceSessionId, 'w6.s01');
      expect(candidate.sourceDrillId, 'classify_missed_fold');
      expect(candidate.drillFamilyId, 'range_bucket_classifier_v1');
      expect(candidate.missedSignalId, 'range_bucket_missed');
      expect(candidate.missedSignalLabel, 'Missed range bucket');
      expect(candidate.chosenActionId, 'raise');
      expect(candidate.expectedActionId, 'fold');
      expect(candidate.targetSessionId, 'w6.s01');
      expect(candidate.targetDrillId, 'classify_missed_fold_recheck');
      expect(candidate.targetKind, 'same_signal_recheck');
      expect(candidate.errorClass, 'expected_action_mismatch');
    },
  );

  test('unsupported persisted receipts are ignored', () async {
    await store.saveCandidate(
      const SessionDrillRepairReceiptCandidateV1(
        schemaVersion: 1,
        sourceWorldId: 'world_6',
        sourceSessionId: 'w6.s01',
        sourceDrillId: 'classify_missed_fold',
        drillFamilyId: 'other_family_v1',
        missedSignalId: 'range_bucket_missed',
        missedSignalLabel: 'Missed range bucket',
        chosenActionId: 'raise',
        expectedActionId: 'fold',
        targetSessionId: 'w6.s01',
        targetDrillId: 'classify_missed_fold_recheck',
        targetKind: 'same_signal_recheck',
        errorClass: 'expected_action_mismatch',
      ),
    );

    expect(await consumer.loadRangeBucketRecheckCandidates(), isEmpty);
  });

  test('correct answers do not create consumer candidates', () async {
    final source = await drill('classify_missed_fold');
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice('fold'),
    );

    final persisted =
        await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: 'fold',
        );

    expect(persisted, isNull);
    expect(await consumer.loadRangeBucketRecheckCandidates(), isEmpty);
  });
}
