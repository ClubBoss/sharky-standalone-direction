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

  Future<void> seedW6Receipt({
    String sourceId = 'classify_missed_overcards_no_draw',
    String wrongChoice = 'strong',
  }) async {
    final source = await drill('w6.s01', sourceId);
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice(wrongChoice),
    );
    await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
      sourceSessionId: 'w6.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: wrongChoice,
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

  test(
    'all four W6 same-signal rechecks append current retained proof',
    () async {
      const cases =
          <
            ({
              String sourceId,
              String wrongChoice,
              String targetId,
              String expectedChoice,
              String signal,
            })
          >[
            (
              sourceId: 'classify_strong_clean_fit',
              wrongChoice: 'missed',
              targetId: 'classify_strong_overpair_fit',
              expectedChoice: 'strong',
              signal: 'range_bucket_strong',
            ),
            (
              sourceId: 'classify_strong_overpair_fit',
              wrongChoice: 'missed',
              targetId: 'classify_strong_clean_fit',
              expectedChoice: 'strong',
              signal: 'range_bucket_strong',
            ),
            (
              sourceId: 'classify_missed_overcards_no_draw',
              wrongChoice: 'strong',
              targetId: 'classify_missed_low_cards_no_draw',
              expectedChoice: 'missed',
              signal: 'range_bucket_missed',
            ),
            (
              sourceId: 'classify_missed_low_cards_no_draw',
              wrongChoice: 'strong',
              targetId: 'classify_missed_overcards_no_draw',
              expectedChoice: 'missed',
              signal: 'range_bucket_missed',
            ),
          ];

      for (final entry in cases) {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        await seedW6Receipt(
          sourceId: entry.sourceId,
          wrongChoice: entry.wrongChoice,
        );
        final target = await drill('w6.s01', entry.targetId);
        final evaluation = evaluator.evaluate(
          target.spec,
          DrillUserEventV1.actionChoice(entry.expectedChoice),
        );

        final event = await persistSessionDrillRetainedResultIfEligibleV1(
          isRecheckLaunchV1: true,
          initialDrillId: target.drillId,
          sourceSessionId: 'w6.s01',
          currentDrill: target,
          evaluation: evaluation,
          chosenActionId: entry.expectedChoice,
          receiptStore: receiptStore,
          resultStore: resultStore,
        );

        expect(event, isNotNull, reason: entry.sourceId);
        expect(event!.result, 'success');
        expect(event.context, 'recheck');
        expect(event.sourceFamily, 'w6_session_drill');
        expect(event.targetDrillId, entry.targetId);
        expect(event.signalFamilyId, entry.signal);
        expect(event.skillAtomId, isNull);
        expect(event.selectedActionId, entry.expectedChoice);
        expect(event.expectedActionId, entry.expectedChoice);
        expect(event.sourceReceiptKey, 'w6.s01:${entry.sourceId}');
        expect(event.isRetainedForMasteryEvidence, isTrue);
        expect(event.toPayload().containsKey('missedSignalLabel'), isFalse);
        expect(await resultStore.loadEvents(), <Object>[event]);
      }
    },
  );

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
    expect(
      event.sourceReceiptKey,
      'w5.s01:classify_texture_intro_dry_raise_v1',
    );
  });

  test(
    'launch, non-target answer, and receipt copy state create no result event',
    () async {
      await seedW6Receipt();
      final target = await drill('w6.s01', 'classify_missed_low_cards_no_draw');
      final evaluation = evaluator.evaluate(
        target.spec,
        DrillUserEventV1.actionChoice('missed'),
      );

      expect(
        await persistSessionDrillRetainedResultIfEligibleV1(
          isRecheckLaunchV1: false,
          initialDrillId: target.drillId,
          sourceSessionId: 'w6.s01',
          currentDrill: target,
          evaluation: evaluation,
          chosenActionId: 'missed',
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
          chosenActionId: 'missed',
          receiptStore: receiptStore,
          resultStore: resultStore,
        ),
        isNull,
      );
      expect(await resultStore.loadEvents(), isEmpty);
    },
  );

  test(
    'retained result leaves receipt and derived Review queue intact',
    () async {
      await seedW6Receipt();
      final target = await drill('w6.s01', 'classify_missed_low_cards_no_draw');
      final evaluation = evaluator.evaluate(
        target.spec,
        DrillUserEventV1.actionChoice('missed'),
      );

      await persistSessionDrillRetainedResultIfEligibleV1(
        isRecheckLaunchV1: true,
        initialDrillId: target.drillId,
        sourceSessionId: 'w6.s01',
        currentDrill: target,
        evaluation: evaluation,
        chosenActionId: 'missed',
        receiptStore: receiptStore,
        resultStore: resultStore,
      );

      expect(await receiptStore.loadCandidates(), hasLength(1));
      final queue = await const SessionDrillRecheckLaunchQueueV1()
          .loadRangeBucketLaunchQueueItems();
      expect(queue, hasLength(1));
    },
  );
}
