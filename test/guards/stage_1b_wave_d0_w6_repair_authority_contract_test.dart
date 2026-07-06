import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const expectedMappings = <String, String>{
    'classify_strong_clean_fit': 'classify_strong_overpair_fit',
    'classify_strong_overpair_fit': 'classify_strong_clean_fit',
    'classify_missed_overcards_no_draw': 'classify_missed_low_cards_no_draw',
    'classify_missed_low_cards_no_draw': 'classify_missed_overcards_no_draw',
  };
  const ineligibleIds = <String>{
    'classify_medium_second_pair_fit',
    'classify_weak_bottom_pair_fit',
  };

  test('six active W6 s01 board-fit classifiers keep current IDs and kind', () {
    final directory = Directory(
      'content/worlds/world6/v1/sessions/w6.s01/drills',
    );
    final classifiers = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .map(
          (file) => jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
        )
        .where(
          (drill) => drill['kind'] == 'range_bucket_board_fit_classifier_v1',
        )
        .toList(growable: false);

    expect(classifiers, hasLength(6));
    expect(
      classifiers.map((drill) => drill['id']).toSet(),
      equals(<String>{...expectedMappings.keys, ...ineligibleIds}),
    );
    for (final drill in classifiers) {
      expect(drill['expected_action'], drill['range_bucket_v1']);
      expect(
        (drill['expected'] as Map<String, dynamic>)['actionId'],
        drill['range_bucket_v1'],
      );
      expect(
        DrillSpecV1.fromJson(drill).kind,
        DrillKindV1.actionChoice,
        reason: drill['id'] as String,
      );
    }
  });

  test('four eligible mappings are active distinct and same-signal', () async {
    final drills = await runtime.loadSessionDrills('w6.s01');
    final byId = <String, SessionDrillItemV1>{
      for (final drill in drills) drill.drillId: drill,
    };

    for (final entry in expectedMappings.entries) {
      final source = byId[entry.key]!;
      final target = byId[entry.value]!;
      final wrongChoice = source.spec.rangeBucketV1 == 'strong'
          ? 'missed'
          : 'strong';
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice(wrongChoice),
      );
      final receipt = buildSessionDrillRepairReceiptCandidateV1(
        sourceSessionId: 'w6.s01',
        sourceDrill: source,
        evaluation: evaluation,
        chosenActionId: wrongChoice,
      );

      expect(receipt, isNotNull, reason: entry.key);
      expect(receipt!.targetDrillId, entry.value);
      expect(receipt.targetDrillId, isNot(receipt.sourceDrillId));
      expect(target.spec.rangeBucketV1, source.spec.rangeBucketV1);
      expect(receipt.targetKind, 'same_signal_recheck');
      expect(receipt.drillFamilyId, 'range_bucket_board_fit_classifier_v1');
    }
  });

  test(
    'medium and weak remain ineligible without exact replay or fallback',
    () async {
      final drills = await runtime.loadSessionDrills('w6.s01');
      final byId = <String, SessionDrillItemV1>{
        for (final drill in drills) drill.drillId: drill,
      };

      for (final id in ineligibleIds) {
        final source = byId[id]!;
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
          reason: id,
        );
      }
    },
  );

  test(
    'active W6 repair production owns no obsolete IDs or family identity',
    () {
      const paths = <String>[
        'lib/services/session_drill_repair_receipt_adapter_v1.dart',
        'lib/services/session_drill_repair_receipt_consumer_v1.dart',
        'lib/services/session_drill_recheck_launch_queue_v1.dart',
        'lib/services/canonical_source_target_metadata_v1.dart',
      ];
      const obsoleteIds = <String>{
        'classify_strong_raise',
        'classify_strong_call_control',
        'classify_medium_call_control',
        'classify_weak_fold_pressure',
        'classify_missed_fold',
        'classify_missed_fold_recheck',
      };
      final source = paths
          .map((path) => File(path).readAsStringSync())
          .join('\n');

      for (final id in obsoleteIds) {
        expect(source, isNot(contains("'$id'")), reason: id);
      }
      expect(source, isNot(contains("'range_bucket_classifier_v1'")));
      expect(source, isNot(contains('DrillKindV1.rangeBucketClassifier')));
    },
  );
}
