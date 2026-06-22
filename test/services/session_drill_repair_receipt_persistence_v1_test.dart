import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const store = SessionDrillRepairReceiptPersistenceV1();

  Future<SessionDrillRepairReceiptCandidateV1> candidate() async {
    final drills = await runtime.loadSessionDrills('w6.s01');
    final source = drills.firstWhere(
      (item) => item.drillId == 'classify_missed_fold',
    );
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice('raise'),
    );
    final candidate = buildSessionDrillRepairReceiptCandidateV1(
      sourceSessionId: 'w6.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: 'raise',
    );
    return candidate!;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists eligible range-bucket receipt payloads', () async {
    final receipt = await candidate();

    await store.saveCandidate(receipt);

    final loaded = await store.loadCandidates();
    expect(loaded, hasLength(1));
    expect(loaded.single.sourceSessionId, 'w6.s01');
    expect(loaded.single.sourceDrillId, 'classify_missed_fold');
    expect(loaded.single.drillFamilyId, 'range_bucket_classifier_v1');
    expect(loaded.single.missedSignalId, 'range_bucket_missed');
    expect(loaded.single.targetDrillId, 'classify_missed_fold_recheck');
    expect(loaded.single.targetKind, 'same_signal_recheck');
  });

  test(
    'eligible adapter candidates can be persisted from result inputs',
    () async {
      final drills = await runtime.loadSessionDrills('w6.s01');
      final source = drills.firstWhere(
        (item) => item.drillId == 'classify_missed_fold',
      );
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('raise'),
      );

      final persisted =
          await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
            sourceSessionId: 'w6.s01',
            sourceDrill: source,
            evaluation: evaluation,
            chosenActionId: 'raise',
          );

      expect(persisted, isNotNull);
      final loaded = await store.loadCandidates();
      expect(loaded, hasLength(1));
      expect(loaded.single.sourceDrillId, 'classify_missed_fold');
      expect(loaded.single.targetDrillId, 'classify_missed_fold_recheck');
    },
  );

  test('ineligible result inputs do not write receipts', () async {
    final drills = await runtime.loadSessionDrills('w6.s01');
    final source = drills.firstWhere(
      (item) => item.drillId == 'classify_missed_fold',
    );
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
    expect(await store.loadCandidates(), isEmpty);
  });

  test('replaces the same source drill instead of duplicating it', () async {
    final receipt = await candidate();

    await store.saveCandidate(receipt);
    await store.saveCandidate(receipt);

    final loaded = await store.loadCandidates();
    expect(loaded, hasLength(1));
    expect(loaded.single.sourceDrillId, 'classify_missed_fold');
  });

  test('ignores invalid or legacy stored payloads', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kSessionDrillRepairReceiptsPrefsKeyV1: '[{"schemaVersion":0}, null]',
    });

    final loaded = await store.loadCandidates();

    expect(loaded, isEmpty);
  });
}
