import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();

  Future<SessionDrillItemV1> drill(String id) async {
    final drills = await runtime.loadSessionDrills('w6.s01');
    return drills.firstWhere((item) => item.drillId == id);
  }

  test(
    'board-fit bucket miss creates a current-family authored recheck candidate',
    () async {
      final source = await drill('classify_missed_overcards_no_draw');
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('strong'),
      );

      final candidate = buildSessionDrillRepairReceiptCandidateV1(
        sourceSessionId: 'w6.s01',
        sourceDrill: source,
        evaluation: evaluation,
        chosenActionId: 'strong',
      );

      expect(candidate, isNotNull);
      expect(candidate!.schemaVersion, 1);
      expect(candidate.sourceWorldId, 'world_6');
      expect(candidate.sourceSessionId, 'w6.s01');
      expect(candidate.sourceDrillId, 'classify_missed_overcards_no_draw');
      expect(candidate.drillFamilyId, 'range_bucket_board_fit_classifier_v1');
      expect(candidate.missedSignalId, 'range_bucket_missed');
      expect(candidate.missedSignalLabel, 'Missed range bucket');
      expect(candidate.chosenActionId, 'strong');
      expect(candidate.expectedActionId, 'missed');
      expect(candidate.targetSessionId, 'w6.s01');
      expect(candidate.targetDrillId, 'classify_missed_low_cards_no_draw');
      expect(candidate.targetKind, 'same_signal_recheck');
      expect(candidate.errorClass, 'range_bucket_mismatch');
    },
  );

  test(
    'exactly four current strong and missed sources resolve distinct same-signal targets',
    () async {
      const expectedTargets = <String, ({String targetId, String wrongAction})>{
        'classify_strong_clean_fit': (
          targetId: 'classify_strong_overpair_fit',
          wrongAction: 'missed',
        ),
        'classify_strong_overpair_fit': (
          targetId: 'classify_strong_clean_fit',
          wrongAction: 'missed',
        ),
        'classify_missed_overcards_no_draw': (
          targetId: 'classify_missed_low_cards_no_draw',
          wrongAction: 'strong',
        ),
        'classify_missed_low_cards_no_draw': (
          targetId: 'classify_missed_overcards_no_draw',
          wrongAction: 'strong',
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
        expect(candidate?.targetDrillId, isNot(entry.key));
        expect(candidate?.targetKind, 'same_signal_recheck');
      }
    },
  );

  test('medium and weak misses stay explicitly repair-ineligible', () async {
    for (final id in <String>{
      'classify_medium_second_pair_fit',
      'classify_weak_bottom_pair_fit',
    }) {
      final source = await drill(id);
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('missed'),
      );

      expect(evaluation.isPass, isFalse, reason: id);
      expect(
        buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: 'missed',
        ),
        isNull,
        reason: '$id must not fall back to exact replay or another bucket',
      );
    }
  });

  test(
    'correct board-fit bucket answers and obsolete synthetic IDs emit no receipt',
    () async {
      final source = await drill('classify_missed_overcards_no_draw');
      final correct = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('missed'),
      );
      expect(
        buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: source,
          evaluation: correct,
          chosenActionId: 'missed',
        ),
        isNull,
      );

      final obsoleteSource = SessionDrillItemV1(
        drillId: 'classify_missed_fold',
        spec: DrillSpecV1.fromJsonString(
          '{"id":"classify_missed_fold","kind":"range_bucket_classifier_v1",'
          '"prompt":"Obsolete source","range_bucket_v1":"missed",'
          '"expected_action":"fold","error_class":"expected_action_mismatch"}',
        ),
      );
      final obsoleteFailure = evaluator.evaluate(
        obsoleteSource.spec,
        DrillUserEventV1.actionChoice('raise'),
      );
      expect(
        buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s01',
          sourceDrill: obsoleteSource,
          evaluation: obsoleteFailure,
          chosenActionId: 'raise',
        ),
        isNull,
      );
    },
  );
}
