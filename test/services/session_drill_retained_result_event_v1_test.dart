import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const receiptStore = SessionDrillRepairReceiptPersistenceV1();
  const resultStore = SessionDrillRetainedResultPersistenceV1();

  Future<SessionDrillItemV1> drill(String sessionId, String drillId) async {
    final drills = await runtime.loadSessionDrills(sessionId);
    return drills.firstWhere((item) => item.drillId == drillId);
  }

  Future<void> seedW6Receipt() async {
    final source = await drill('w6.s01', 'classify_missed_fold');
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice('raise'),
    );
    await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
      sourceSessionId: 'w6.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: 'raise',
      store: receiptStore,
    );
  }

  Future<void> seedW5Receipt() async {
    final source = await drill('w5.s01', 'classify_texture_intro_dry_raise_v1');
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice('fold'),
    );
    await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
      sourceSessionId: 'w5.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: 'fold',
      store: receiptStore,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('W6 exact recheck success appends immutable retained result evidence', () async {
    await seedW6Receipt();
    final target = await drill('w6.s01', 'classify_missed_fold_recheck');
    final evaluation = evaluator.evaluate(
      target.spec,
      DrillUserEventV1.actionChoice('fold'),
    );

    final event = await persistSessionDrillRetainedResultIfEligibleV1(
      isRecheckLaunchV1: true,
      initialDrillId: target.drillId,
      sourceSessionId: 'w6.s01',
      currentDrill: target,
      evaluation: evaluation,
      chosenActionId: 'fold',
      receiptStore: receiptStore,
      resultStore: resultStore,
    );

    expect(event, isNotNull);
    expect(event!.result, 'success');
    expect(event.context, 'recheck');
    expect(event.sourceFamily, 'w6_session_drill');
    expect(event.targetDrillId, 'classify_missed_fold_recheck');
    expect(event.signalFamilyId, 'range_bucket_missed');
    expect(event.skillAtomId, isNull);
    expect(event.selectedActionId, 'fold');
    expect(event.expectedActionId, 'fold');
    expect(event.isRetainedForMasteryEvidence, isTrue);
    expect(event.toPayload().containsKey('missedSignalLabel'), isFalse);
    expect(await resultStore.loadEvents(), <Object>[event]);
  });

  test('W5 exact recheck miss appends retained miss evidence', () async {
    await seedW5Receipt();
    final target = await drill('w5.s01', 'classify_texture_intro_dry_raise_v1');
    final evaluation = evaluator.evaluate(
      target.spec,
      DrillUserEventV1.actionChoice('fold'),
    );

    final event = await persistSessionDrillRetainedResultIfEligibleV1(
      isRecheckLaunchV1: true,
      initialDrillId: target.drillId,
      sourceSessionId: 'w5.s01',
      currentDrill: target,
      evaluation: evaluation,
      chosenActionId: 'fold',
      receiptStore: receiptStore,
      resultStore: resultStore,
    );

    expect(event, isNotNull);
    expect(event!.result, 'miss');
    expect(event.sourceFamily, 'w5_session_drill');
    expect(event.targetKind, 'exact_replay');
    expect(event.sourceReceiptKey, 'w5.s01:classify_texture_intro_dry_raise_v1');
  });

  test('launch, non-target answer, and receipt copy state create no result event', () async {
    await seedW6Receipt();
    final target = await drill('w6.s01', 'classify_missed_fold_recheck');
    final evaluation = evaluator.evaluate(
      target.spec,
      DrillUserEventV1.actionChoice('fold'),
    );

    expect(
      await persistSessionDrillRetainedResultIfEligibleV1(
        isRecheckLaunchV1: false,
        initialDrillId: target.drillId,
        sourceSessionId: 'w6.s01',
        currentDrill: target,
        evaluation: evaluation,
        chosenActionId: 'fold',
        receiptStore: receiptStore,
        resultStore: resultStore,
      ),
      isNull,
    );
    expect(
      await persistSessionDrillRetainedResultIfEligibleV1(
        isRecheckLaunchV1: true,
        initialDrillId: 'other_target',
        sourceSessionId: 'w6.s01',
        currentDrill: target,
        evaluation: evaluation,
        chosenActionId: 'fold',
        receiptStore: receiptStore,
        resultStore: resultStore,
      ),
      isNull,
    );
    expect(await resultStore.loadEvents(), isEmpty);
  });

  test('retained result leaves receipt and derived Review queue intact', () async {
    await seedW6Receipt();
    final target = await drill('w6.s01', 'classify_missed_fold_recheck');
    final evaluation = evaluator.evaluate(
      target.spec,
      DrillUserEventV1.actionChoice('fold'),
    );

    await persistSessionDrillRetainedResultIfEligibleV1(
      isRecheckLaunchV1: true,
      initialDrillId: target.drillId,
      sourceSessionId: 'w6.s01',
      currentDrill: target,
      evaluation: evaluation,
      chosenActionId: 'fold',
      receiptStore: receiptStore,
      resultStore: resultStore,
    );

    expect(await receiptStore.loadCandidates(), hasLength(1));
    final queue = await const SessionDrillRecheckLaunchQueueV1()
        .loadRangeBucketLaunchQueueItems();
    expect(queue, hasLength(1));
  });
}
