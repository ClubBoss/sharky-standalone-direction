import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_consumer_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const store = SessionDrillRepairReceiptPersistenceV1();
  const launchQueue = SessionDrillRecheckLaunchQueueV1();

  Future<SessionDrillItemV1> drill(String sessionId, String id) async {
    final drills = await runtime.loadSessionDrills(sessionId);
    return drills.firstWhere((item) => item.drillId == id);
  }

  Future<void> persistMissedFoldReceipt() async {
    final source = await drill('w6.s01', 'classify_missed_fold');
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
    await store.saveCandidate(receipt!);
  }

  Future<void> persistDryBoardTextureReceipt() async {
    final source = await drill('w5.s01', 'classify_texture_intro_dry_raise_v1');
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice('fold'),
    );
    final receipt = await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
      sourceSessionId: 'w5.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: 'fold',
    );
    expect(receipt, isNotNull);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'supported internal session-drill recheck candidate creates one launch queue item',
    () async {
      await persistMissedFoldReceipt();

      final items = await launchQueue.loadRangeBucketLaunchQueueItems();

      expect(items, hasLength(1));
      final item = items.single;
      expect(item.queueKind, 'session_drill_recheck');
      expect(
        item.jobId,
        'session_drill_recheck:w6.s01:classify_missed_fold_recheck',
      );
      expect(item.launchSessionId, 'w6.s01');
      expect(item.targetSessionId, 'w6.s01');
      expect(item.targetDrillId, 'classify_missed_fold_recheck');
      expect(item.sourceWorldId, 'world_6');
      expect(item.sourceSessionId, 'w6.s01');
      expect(item.sourceDrillId, 'classify_missed_fold');
      expect(item.missedSignalId, 'range_bucket_missed');
      expect(item.missedSignalLabel, 'Missed range bucket');
      expect(item.targetKind, 'same_signal_recheck');
    },
  );

  test(
    'supported launch queue includes range-bucket and board-texture families',
    () async {
      await persistMissedFoldReceipt();
      await persistDryBoardTextureReceipt();

      final items = await launchQueue.loadSupportedLaunchQueueItems();

      expect(items, hasLength(2));
      expect(
        items.map((item) => item.drillFamilyId),
        containsAll(<String>[
          'range_bucket_classifier_v1',
          'board_texture_classifier_v1',
        ]),
      );
      final boardItem = items.singleWhere(
        (item) => item.drillFamilyId == 'board_texture_classifier_v1',
      );
      expect(boardItem.launchSessionId, 'w5.s01');
      expect(boardItem.targetSessionId, 'w5.s01');
      expect(boardItem.targetDrillId, 'classify_texture_intro_dry_raise_v1');
      expect(boardItem.missedSignalLabel, 'Dry board texture');
    },
  );

  test(
    'unsupported internal candidates are ignored by the launch queue seam',
    () {
      final item = buildSessionDrillRecheckLaunchQueueItemV1(
        const SessionDrillRepairRecheckCandidateV1(
          schemaVersion: 1,
          consumerKind: 'unsupported',
          sourceWorldId: 'world_6',
          sourceSessionId: 'w6.s01',
          sourceDrillId: 'classify_missed_fold',
          drillFamilyId: 'range_bucket_classifier_v1',
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

      expect(item, isNull);
    },
  );

  test('correct answers do not create launch queue items', () async {
    final source = await drill('w6.s01', 'classify_missed_fold');
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
    expect(await launchQueue.loadRangeBucketLaunchQueueItems(), isEmpty);
  });
}
