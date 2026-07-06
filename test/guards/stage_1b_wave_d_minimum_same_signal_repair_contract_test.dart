import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/board_texture_repair_receipt_mapping_v1.dart';
import 'package:poker_analyzer/services/canonical_atom_mapping_registry_v1.dart';
import 'package:poker_analyzer/services/canonical_source_target_metadata_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_consumer_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runtime = DrillRuntimeAdapterV1();
  const evaluator = DrillEvaluatorV1();
  const receiptStore = SessionDrillRepairReceiptPersistenceV1();
  const resultStore = SessionDrillRetainedResultPersistenceV1();
  const launchQueue = SessionDrillRecheckLaunchQueueV1();

  Future<SessionDrillItemV1> drill(String sessionId, String drillId) async {
    final drills = await runtime.loadSessionDrills(sessionId);
    return drills.firstWhere((item) => item.drillId == drillId);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'later W5 dry-texture sources use distinct active same-signal targets',
    () async {
      const mappings =
          <
            String,
            ({String sourceSession, String targetSession, String targetId})
          >{
            'classify_in_position_dry_raise_v1': (
              sourceSession: 'w5.s06',
              targetSession: 'w5.s10',
              targetId: 'classify_texture_synthesis_dry_raise_v1',
            ),
            'classify_texture_synthesis_dry_raise_v1': (
              sourceSession: 'w5.s10',
              targetSession: 'w5.s06',
              targetId: 'classify_in_position_dry_raise_v1',
            ),
          };

      for (final entry in mappings.entries) {
        final source = await drill(entry.value.sourceSession, entry.key);
        final target = await drill(
          entry.value.targetSession,
          entry.value.targetId,
        );
        final evaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice('fold'),
        );
        final receipt = buildBoardTextureRepairReceiptCandidateV1(
          sourceSessionId: entry.value.sourceSession,
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: 'fold',
        );

        expect(receipt, isNotNull, reason: entry.key);
        expect(receipt!.missedSignalId, 'board_texture_dry');
        expect(receipt.targetSessionId, entry.value.targetSession);
        expect(receipt.targetDrillId, entry.value.targetId);
        expect(receipt.targetDrillId, isNot(receipt.sourceDrillId));
        expect(receipt.targetKind, 'same_signal_recheck');
        expect(target.spec.boardTextureV1, source.spec.boardTextureV1);
        expect(target.spec.kind, DrillKindV1.boardTextureClassifier);
      }
    },
  );

  test(
    'W6 range-width sources use distinct active same-answer targets',
    () async {
      const mappings = <String, ({String targetId, String answer})>{
        'classify_button_range_wider': (
          targetId: 'classify_late_position_more_hands',
          answer: 'wider',
        ),
        'classify_late_position_more_hands': (
          targetId: 'classify_button_range_wider',
          answer: 'wider',
        ),
        'classify_continue_range_narrower': (
          targetId: 'classify_big_blind_continue_narrower',
          answer: 'narrower',
        ),
        'classify_big_blind_continue_narrower': (
          targetId: 'classify_continue_range_narrower',
          answer: 'narrower',
        ),
      };

      for (final entry in mappings.entries) {
        final source = await drill('w6.s02', entry.key);
        final target = await drill('w6.s02', entry.value.targetId);
        final wrongChoice = entry.value.answer == 'wider'
            ? 'narrower'
            : 'wider';
        final evaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice(wrongChoice),
        );
        final receipt = buildSessionDrillRepairReceiptCandidateV1(
          sourceSessionId: 'w6.s02',
          sourceDrill: source,
          evaluation: evaluation,
          chosenActionId: wrongChoice,
        );

        expect(receipt, isNotNull, reason: entry.key);
        expect(receipt!.drillFamilyId, 'range_width_classifier_v1');
        expect(receipt.missedSignalId, 'range_width_${entry.value.answer}');
        expect(receipt.targetSessionId, 'w6.s02');
        expect(receipt.targetDrillId, entry.value.targetId);
        expect(receipt.targetDrillId, isNot(receipt.sourceDrillId));
        expect(receipt.targetKind, 'same_signal_recheck');
        expect(target.spec.expected.actionId, source.spec.expected.actionId);
        expect(target.spec.intentV1, 'position_and_range_width');
      }
    },
  );

  test(
    'W4 denial admits one active denial-only source-target direction',
    () async {
      final source = await drill('w4.s02', 'choose_raise_denial');
      final target = await drill('w4.s06', 'choose_raise_repeat');
      final evaluation = evaluator.evaluate(
        source.spec,
        DrillUserEventV1.actionChoice('call'),
      );
      final receipt = buildSessionDrillRepairReceiptCandidateV1(
        sourceSessionId: 'w4.s02',
        sourceDrill: source,
        evaluation: evaluation,
        chosenActionId: 'call',
      );

      expect(receipt, isNotNull);
      expect(receipt!.drillFamilyId, 'denial_action_choice_v1');
      expect(receipt.missedSignalId, 'denial_equity_charge');
      expect(receipt.targetSessionId, 'w4.s06');
      expect(receipt.targetDrillId, 'choose_raise_repeat');
      expect(receipt.targetDrillId, isNot(receipt.sourceDrillId));
      expect(receipt.targetKind, 'same_signal_recheck');
      expect(source.spec.intentV1, 'bet_for_denial');
      expect(target.spec.intentV1, 'bet_for_denial');
      expect(target.spec.expected.actionId, source.spec.expected.actionId);
    },
  );

  test(
    'all admitted families persist queue launch and retained success proof',
    () async {
      const cases =
          <
            ({
              String sourceSession,
              String sourceId,
              String wrongChoice,
              String targetSession,
              String targetId,
              String family,
              String signal,
              String world,
              String sourceFamily,
            })
          >[
            (
              sourceSession: 'w5.s10',
              sourceId: 'classify_texture_synthesis_dry_raise_v1',
              wrongChoice: 'fold',
              targetSession: 'w5.s06',
              targetId: 'classify_in_position_dry_raise_v1',
              family: 'board_texture_classifier_v1',
              signal: 'board_texture_dry',
              world: 'world_5',
              sourceFamily: 'w5_session_drill',
            ),
            (
              sourceSession: 'w6.s02',
              sourceId: 'classify_button_range_wider',
              wrongChoice: 'narrower',
              targetSession: 'w6.s02',
              targetId: 'classify_late_position_more_hands',
              family: 'range_width_classifier_v1',
              signal: 'range_width_wider',
              world: 'world_6',
              sourceFamily: 'w6_session_drill',
            ),
            (
              sourceSession: 'w4.s02',
              sourceId: 'choose_raise_denial',
              wrongChoice: 'call',
              targetSession: 'w4.s06',
              targetId: 'choose_raise_repeat',
              family: 'denial_action_choice_v1',
              signal: 'denial_equity_charge',
              world: 'world_4',
              sourceFamily: 'w4_session_drill',
            ),
          ];

      for (final item in cases) {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final source = await drill(item.sourceSession, item.sourceId);
        final sourceEvaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice(item.wrongChoice),
        );
        final receipt =
            await persistSessionDrillRepairReceiptCandidateIfEligibleV1(
              sourceSessionId: item.sourceSession,
              sourceDrill: source,
              evaluation: sourceEvaluation,
              chosenActionId: item.wrongChoice,
              store: receiptStore,
            );

        expect(receipt, isNotNull, reason: item.sourceId);
        expect(receipt!.drillFamilyId, item.family);
        expect(receipt.missedSignalId, item.signal);
        expect(
          (await receiptStore.loadCandidates()).single.toPayload(),
          receipt.toPayload(),
        );

        final queue = await launchQueue.loadSupportedLaunchQueueItems();
        expect(queue, hasLength(1), reason: item.family);
        final queueItem = queue.single;
        expect(queueItem.launchSessionId, item.targetSession);
        expect(queueItem.targetDrillId, item.targetId);
        expect(queueItem.targetKind, 'same_signal_recheck');

        final target = await drill(item.targetSession, item.targetId);
        final expectedChoice =
            target.spec.expected.actionId ?? target.spec.expectedActionV1!;
        final targetEvaluation = evaluator.evaluate(
          target.spec,
          DrillUserEventV1.actionChoice(expectedChoice),
        );
        final result = await persistSessionDrillRetainedResultIfEligibleV1(
          isRecheckLaunchV1: true,
          initialDrillId: item.targetId,
          sourceSessionId: item.targetSession,
          currentDrill: target,
          evaluation: targetEvaluation,
          chosenActionId: expectedChoice,
          receiptStore: receiptStore,
          resultStore: resultStore,
        );

        expect(result, isNotNull, reason: item.family);
        expect(result!.worldId, item.world);
        expect(result.sourceSessionId, item.sourceSession);
        expect(result.targetDrillId, item.targetId);
        expect(result.signalFamilyId, item.signal);
        expect(result.sourceFamily, item.sourceFamily);
        expect(result.result, 'success');
        expect(
          result.sourceReceiptKey,
          '${item.sourceSession}:${item.sourceId}',
        );
      }
    },
  );

  test('canonical metadata retains every admitted source-target tuple', () {
    const cases =
        <
          ({
            String sourceFamily,
            String world,
            String sourceSession,
            String targetId,
            String signal,
            String expectedAction,
          })
        >[
          (
            sourceFamily: 'w5_session_drill',
            world: 'world_5',
            sourceSession: 'w5.s06',
            targetId: 'classify_texture_synthesis_dry_raise_v1',
            signal: 'board_texture_dry',
            expectedAction: 'raise',
          ),
          (
            sourceFamily: 'w5_session_drill',
            world: 'world_5',
            sourceSession: 'w5.s10',
            targetId: 'classify_in_position_dry_raise_v1',
            signal: 'board_texture_dry',
            expectedAction: 'raise',
          ),
          (
            sourceFamily: 'w6_session_drill',
            world: 'world_6',
            sourceSession: 'w6.s02',
            targetId: 'classify_late_position_more_hands',
            signal: 'range_width_wider',
            expectedAction: 'wider',
          ),
          (
            sourceFamily: 'w6_session_drill',
            world: 'world_6',
            sourceSession: 'w6.s02',
            targetId: 'classify_button_range_wider',
            signal: 'range_width_wider',
            expectedAction: 'wider',
          ),
          (
            sourceFamily: 'w6_session_drill',
            world: 'world_6',
            sourceSession: 'w6.s02',
            targetId: 'classify_big_blind_continue_narrower',
            signal: 'range_width_narrower',
            expectedAction: 'narrower',
          ),
          (
            sourceFamily: 'w6_session_drill',
            world: 'world_6',
            sourceSession: 'w6.s02',
            targetId: 'classify_continue_range_narrower',
            signal: 'range_width_narrower',
            expectedAction: 'narrower',
          ),
          (
            sourceFamily: 'w4_session_drill',
            world: 'world_4',
            sourceSession: 'w4.s02',
            targetId: 'choose_raise_repeat',
            signal: 'denial_equity_charge',
            expectedAction: 'raise',
          ),
        ];
    const catalog = CanonicalSourceTargetMetadataCatalogV1();

    for (final item in cases) {
      final metadata = catalog.resolve(
        CanonicalAtomMappingInputV1(
          sourceFamily: item.sourceFamily,
          sourceWorld: item.world,
          sourceSessionId: item.sourceSession,
          exactTargetId: item.targetId,
          signalFamilyId: item.signal,
        ),
      );

      expect(metadata, isNotNull, reason: item.targetId);
      expect(metadata!.canonicalAtomId, isNull);
      expect(metadata.expectedActionId, item.expectedAction);
      expect(metadata.outcomeSemantics, 'explicit_exact_target_result_v1');
      expect(metadata.context, 'recheck');
      expect(metadata.curatedRepairAvailable, isTrue);
      expect(metadata.curatedRecheckAvailable, isTrue);
      expect(metadata.curatedProveAvailable, isFalse);
      expect(metadata.evidenceConfidence, 'source_proven');
      expect(
        metadata.reviewStamp,
        'stage_1b_wave_d_minimum_same_signal_repair_v1',
      );
    }
  });

  test(
    'consumer queue and result reject unreviewed same-family near matches',
    () async {
      const forgedReceipts = <SessionDrillRepairReceiptCandidateV1>[
        SessionDrillRepairReceiptCandidateV1(
          schemaVersion: 1,
          sourceWorldId: 'world_5',
          sourceSessionId: 'w5.s10',
          sourceDrillId: 'classify_texture_synthesis_wet_fold_v1',
          drillFamilyId: 'board_texture_classifier_v1',
          missedSignalId: 'board_texture_wet',
          missedSignalLabel: 'Wet board texture',
          chosenActionId: 'raise',
          expectedActionId: 'fold',
          targetSessionId: 'w5.s06',
          targetDrillId: 'classify_in_position_wet_call_v1',
          targetKind: 'same_signal_recheck',
          errorClass: 'expected_action_mismatch',
        ),
        SessionDrillRepairReceiptCandidateV1(
          schemaVersion: 1,
          sourceWorldId: 'world_6',
          sourceSessionId: 'w6.s02',
          sourceDrillId: 'classify_button_open_less_constrained',
          drillFamilyId: 'range_width_classifier_v1',
          missedSignalId: 'range_width_less_constrained',
          missedSignalLabel: 'Less constrained range',
          chosenActionId: 'wider',
          expectedActionId: 'less_constrained',
          targetSessionId: 'w6.s02',
          targetDrillId: 'classify_button_range_wider',
          targetKind: 'same_signal_recheck',
          errorClass: 'range_width_mismatch',
        ),
        SessionDrillRepairReceiptCandidateV1(
          schemaVersion: 1,
          sourceWorldId: 'world_4',
          sourceSessionId: 'w4.s02',
          sourceDrillId: 'choose_raise_bluff',
          drillFamilyId: 'denial_action_choice_v1',
          missedSignalId: 'denial_equity_charge',
          missedSignalLabel: 'Charge live overcards and draws',
          chosenActionId: 'call',
          expectedActionId: 'raise',
          targetSessionId: 'w4.s06',
          targetDrillId: 'choose_raise_repeat',
          targetKind: 'same_signal_recheck',
          errorClass: 'expected_action_mismatch',
        ),
      ];

      final builders =
          <
            SessionDrillRepairRecheckCandidateV1? Function(
              SessionDrillRepairReceiptCandidateV1,
            )
          >[
            buildBoardTextureRepairRecheckCandidateV1,
            buildRangeWidthRepairRecheckCandidateV1,
            buildDenialRepairRecheckCandidateV1,
          ];

      for (var index = 0; index < forgedReceipts.length; index++) {
        final receipt = forgedReceipts[index];
        final candidate = builders[index](receipt);
        expect(candidate, isNull, reason: receipt.sourceDrillId);
        expect(
          buildSessionDrillRecheckLaunchQueueItemV1(
            SessionDrillRepairRecheckCandidateV1(
              schemaVersion: receipt.schemaVersion,
              consumerKind: 'session_drill_recheck',
              sourceWorldId: receipt.sourceWorldId,
              sourceSessionId: receipt.sourceSessionId,
              sourceDrillId: receipt.sourceDrillId,
              drillFamilyId: receipt.drillFamilyId,
              missedSignalId: receipt.missedSignalId,
              missedSignalLabel: receipt.missedSignalLabel,
              chosenActionId: receipt.chosenActionId,
              expectedActionId: receipt.expectedActionId,
              targetSessionId: receipt.targetSessionId,
              targetDrillId: receipt.targetDrillId,
              targetKind: receipt.targetKind,
              errorClass: receipt.errorClass,
            ),
          ),
          isNull,
          reason: receipt.targetDrillId,
        );

        SharedPreferences.setMockInitialValues(<String, Object>{});
        await receiptStore.saveCandidate(receipt);
        final target = await drill(
          receipt.targetSessionId,
          receipt.targetDrillId,
        );
        final expectedChoice =
            target.spec.expected.actionId ?? target.spec.expectedActionV1!;
        final evaluation = evaluator.evaluate(
          target.spec,
          DrillUserEventV1.actionChoice(expectedChoice),
        );
        expect(
          await persistSessionDrillRetainedResultIfEligibleV1(
            isRecheckLaunchV1: true,
            initialDrillId: receipt.targetDrillId,
            sourceSessionId: receipt.targetSessionId,
            currentDrill: target,
            evaluation: evaluation,
            chosenActionId: expectedChoice,
            receiptStore: receiptStore,
            resultStore: resultStore,
          ),
          isNull,
          reason: receipt.sourceDrillId,
        );
      }
    },
  );

  test(
    'deferred concepts stay unmapped and forbidden route drift stays absent',
    () async {
      final w5Wet = await drill(
        'w5.s10',
        'classify_texture_synthesis_wet_fold_v1',
      );
      final w5WetFailure = evaluator.evaluate(
        w5Wet.spec,
        DrillUserEventV1.actionChoice('raise'),
      );
      expect(
        buildBoardTextureRepairReceiptCandidateV1(
          sourceSessionId: 'w5.s10',
          sourceDrill: w5Wet,
          evaluation: w5WetFailure,
          chosenActionId: 'raise',
        ),
        isNull,
      );

      for (final id in <String>{
        'classify_button_open_less_constrained',
        'classify_utg_range_stronger_average',
      }) {
        final source = await drill('w6.s02', id);
        final evaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice('wider'),
        );
        expect(
          buildSessionDrillRepairReceiptCandidateV1(
            sourceSessionId: 'w6.s02',
            sourceDrill: source,
            evaluation: evaluation,
            chosenActionId: 'wider',
          ),
          isNull,
          reason: id,
        );
      }

      for (final item in <({String sessionId, String drillId})>{
        (sessionId: 'w4.s01', drillId: 'choose_raise_value'),
        (sessionId: 'w4.s01', drillId: 'choose_raise_protection'),
        (sessionId: 'w4.s02', drillId: 'choose_raise_bluff'),
      }) {
        final source = await drill(item.sessionId, item.drillId);
        final evaluation = evaluator.evaluate(
          source.spec,
          DrillUserEventV1.actionChoice('call'),
        );
        expect(
          buildSessionDrillRepairReceiptCandidateV1(
            sourceSessionId: item.sessionId,
            sourceDrill: source,
            evaluation: evaluation,
            chosenActionId: 'call',
          ),
          isNull,
          reason: item.drillId,
        );
      }

      final activeManifest = File(
        'content/_meta/world_drills_manifest_v1.json',
      ).readAsStringSync();
      expect(activeManifest, isNot(contains('w5.s11')));
      final productionRepairSource = <String>[
        'lib/services/session_drill_repair_receipt_adapter_v1.dart',
        'lib/services/board_texture_repair_receipt_mapping_v1.dart',
        'lib/services/session_drill_repair_receipt_consumer_v1.dart',
        'lib/services/session_drill_recheck_launch_queue_v1.dart',
        'lib/services/session_drill_repair_receipt_persistence_v1.dart',
        'lib/services/canonical_source_target_metadata_v1.dart',
      ].map((path) => File(path).readAsStringSync()).join('\n');
      expect(productionRepairSource, isNot(contains("'w7.")));
      expect(productionRepairSource, isNot(contains('ModernTable')));
    },
  );
}
