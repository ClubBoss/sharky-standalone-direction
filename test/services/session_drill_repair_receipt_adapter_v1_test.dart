import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';

void main() {
  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();

  Future<SessionDrillItemV1> drill(String id) async {
    final drills = await runtime.loadSessionDrills('w6.s01');
    return drills.firstWhere((item) => item.drillId == id);
  }

  test(
    'range-bucket miss creates a stable authored recheck candidate',
    () async {
      final source = await drill('classify_missed_fold');
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

      expect(candidate, isNotNull);
      expect(candidate!.schemaVersion, 1);
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
    },
  );

  test(
    'range-bucket targets stay deterministic across the W6 family',
    () async {
      const expectedTargets = <String, ({String targetId, String wrongAction})>{
        'classify_strong_raise': (
          targetId: 'classify_strong_call_control',
          wrongAction: 'fold',
        ),
        'classify_strong_call_control': (
          targetId: 'classify_strong_raise',
          wrongAction: 'fold',
        ),
        'classify_medium_call_control': (
          targetId: 'classify_medium_call_control',
          wrongAction: 'raise',
        ),
        'classify_weak_fold_pressure': (
          targetId: 'classify_weak_fold_pressure',
          wrongAction: 'raise',
        ),
        'classify_missed_fold': (
          targetId: 'classify_missed_fold_recheck',
          wrongAction: 'raise',
        ),
        'classify_missed_fold_recheck': (
          targetId: 'classify_missed_fold',
          wrongAction: 'raise',
        ),
      };

      for (final entry in expectedTargets.entries) {
        final source = await drill(entry.key);
        final evaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice(entry.value.wrongAction),
        );
        final candidate = buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: entry.value.wrongAction,
        );

        expect(candidate?.targetDrillId, entry.value.targetId);
        expect(candidate?.targetSessionId, 'w6.s01');
      }
    },
  );

  test(
    'correct or soft-pass range-bucket answers do not create miss receipts',
    () async {
      final source = await drill('classify_missed_fold');
      final correct = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('fold'),
      );
      final softPass = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('call'),
      );

      expect(
        buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: source,
          evaluation: correct,
          chosenActionId: 'fold',
        ),
        isNull,
      );
      expect(
        buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: source,
          evaluation: softPass,
          chosenActionId: 'call',
        ),
        isNull,
      );
    },
  );
}
