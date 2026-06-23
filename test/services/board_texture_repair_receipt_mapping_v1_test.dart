import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/board_texture_repair_receipt_mapping_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_consumer_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const store = SessionDrillRepairReceiptPersistenceV1();
  const consumer = SessionDrillRepairReceiptConsumerV1();
  const launchQueue = SessionDrillRecheckLaunchQueueV1();

  Future<SessionDrillItemV1> drill(String id) async {
    final drills = await runtime.loadSessionDrills('w5.s01');
    return drills.firstWhere((item) => item.drillId == id);
  }

  Future<void> persistBoardTextureMiss({
    required String sourceDrillId,
    required String wrongActionId,
  }) async {
    final source = await drill(sourceDrillId);
    final evaluation = evaluator.evaluate(
      source.spec,
      DrillUserEventV1.actionChoice(wrongActionId),
    );
    final receipt = buildBoardTextureRepairReceiptCandidateV1(
      sourceSessionId: 'w5.s01',
      sourceDrill: source,
      evaluation: evaluation,
      chosenActionId: wrongActionId,
    );
    await store.saveCandidate(receipt!);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'board texture miss creates a stable exact target receipt candidate',
    () async {
      final source = await drill('classify_texture_intro_dry_raise_v1');
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('fold'),
      );

      final candidate = buildBoardTextureRepairReceiptCandidateV1(
        sourceSessionId: 'w5.s01',
        sourceDrill: source,
        evaluation: evaluation,
        chosenActionId: 'fold',
      );

      expect(candidate, isNotNull);
      expect(candidate!.schemaVersion, 1);
      expect(candidate.sourceWorldId, 'world_5');
      expect(candidate.sourceSessionId, 'w5.s01');
      expect(candidate.sourceDrillId, 'classify_texture_intro_dry_raise_v1');
      expect(candidate.drillFamilyId, 'board_texture_classifier_v1');
      expect(candidate.missedSignalId, 'board_texture_dry');
      expect(candidate.missedSignalLabel, 'Dry board texture');
      expect(candidate.chosenActionId, 'fold');
      expect(candidate.expectedActionId, 'raise');
      expect(candidate.targetSessionId, 'w5.s01');
      expect(candidate.targetDrillId, 'classify_texture_intro_dry_raise_v1');
      expect(candidate.targetKind, 'exact_replay');
      expect(candidate.errorClass, 'expected_action_mismatch');
    },
  );

  test(
    'board texture target identity stays deterministic across the W5 s01 slice',
    () async {
      const expectedTargets = <String, ({String texture, String wrongAction})>{
        'classify_texture_intro_dry_raise_v1': (
          texture: 'dry',
          wrongAction: 'fold',
        ),
        'classify_texture_intro_wet_call_v1': (
          texture: 'wet',
          wrongAction: 'raise',
        ),
        'classify_texture_intro_paired_fold_v1': (
          texture: 'paired',
          wrongAction: 'raise',
        ),
      };

      for (final entry in expectedTargets.entries) {
        final source = await drill(entry.key);
        final evaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice(entry.value.wrongAction),
        );

        final candidate = buildBoardTextureRepairReceiptCandidateV1(
          sourceSessionId: 'w5.s01',
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: entry.value.wrongAction,
        );

        expect(candidate?.sourceWorldId, 'world_5');
        expect(candidate?.sourceSessionId, 'w5.s01');
        expect(candidate?.drillFamilyId, 'board_texture_classifier_v1');
        expect(
          candidate?.missedSignalId,
          'board_texture_${entry.value.texture}',
        );
        expect(candidate?.targetSessionId, 'w5.s01');
        expect(candidate?.targetDrillId, entry.key);
        expect(candidate?.targetKind, 'exact_replay');
      }
    },
  );

  test(
    'correct and soft-pass board texture answers do not create receipts',
    () async {
      final source = await drill('classify_texture_intro_dry_raise_v1');
      final correct = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('raise'),
      );
      final softPass = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('call'),
      );

      expect(
        buildBoardTextureRepairReceiptCandidateV1(
          sourceSessionId: 'w5.s01',
          sourceDrill: source,
          evaluation: correct,
          chosenActionId: 'raise',
        ),
        isNull,
      );
      expect(
        buildBoardTextureRepairReceiptCandidateV1(
          sourceSessionId: 'w5.s01',
          sourceDrill: source,
          evaluation: softPass,
          chosenActionId: 'call',
        ),
        isNull,
      );
    },
  );

  test(
    'persisted board texture receipt creates consumer and queue targets',
    () async {
      await persistBoardTextureMiss(
        sourceDrillId: 'classify_texture_intro_wet_call_v1',
        wrongActionId: 'raise',
      );

      final candidates = await consumer.loadBoardTextureRecheckCandidates();
      expect(candidates, hasLength(1));
      final candidate = candidates.single;
      expect(candidate.consumerKind, 'session_drill_recheck');
      expect(candidate.sourceWorldId, 'world_5');
      expect(candidate.sourceSessionId, 'w5.s01');
      expect(candidate.drillFamilyId, 'board_texture_classifier_v1');
      expect(candidate.missedSignalId, 'board_texture_wet');
      expect(candidate.missedSignalLabel, 'Wet board texture');
      expect(candidate.targetSessionId, 'w5.s01');
      expect(candidate.targetDrillId, 'classify_texture_intro_wet_call_v1');
      expect(candidate.targetKind, 'exact_replay');

      final items = await launchQueue.loadBoardTextureLaunchQueueItems();
      expect(items, hasLength(1));
      final item = items.single;
      expect(item.queueKind, 'session_drill_recheck');
      expect(
        item.jobId,
        'session_drill_recheck:w5.s01:classify_texture_intro_wet_call_v1',
      );
      expect(item.launchSessionId, 'w5.s01');
      expect(item.drillFamilyId, 'board_texture_classifier_v1');
      expect(item.missedSignalId, 'board_texture_wet');
      expect(item.targetDrillId, 'classify_texture_intro_wet_call_v1');
    },
  );

  test(
    'unmapped or non-board texture inputs do not enqueue fake targets',
    () async {
      final source = await drill('classify_texture_intro_dry_raise_v1');
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('fold'),
      );

      expect(
        buildBoardTextureRepairReceiptCandidateV1(
          sourceSessionId: 'w5.s02',
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: 'fold',
        ),
        isNull,
      );

      await store.saveCandidate(
        const SessionDrillRepairReceiptCandidateV1(
          schemaVersion: 1,
          sourceWorldId: 'world_5',
          sourceSessionId: 'w5.s01',
          sourceDrillId: 'classify_texture_intro_dry_raise_v1',
          drillFamilyId: 'action_choice',
          missedSignalId: 'board_texture_dry',
          missedSignalLabel: 'Dry board texture',
          chosenActionId: 'fold',
          expectedActionId: 'raise',
          targetSessionId: 'w5.s01',
          targetDrillId: 'classify_texture_intro_dry_raise_v1',
          targetKind: 'exact_replay',
          errorClass: 'expected_action_mismatch',
        ),
      );

      expect(await consumer.loadBoardTextureRecheckCandidates(), isEmpty);
      expect(await launchQueue.loadBoardTextureLaunchQueueItems(), isEmpty);
    },
  );
}
