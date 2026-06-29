import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

void main() {
  test('maps no-bet-yet action read candidate to existing Practice target', () {
    final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      _candidate(),
    );

    expect(result.isMapped, isTrue);
    expect(result.reasonCode, act0ConceptCandidatePracticeMappedV1);
    expect(result.request?.isLaunchable, isTrue);
    expect(result.request?.targetWorldId, 'world_1');
    expect(result.request?.targetLessonId, 'fold_check_call_raise');
    expect(result.request?.targetTaskId, 'actions_check_drill');
    expect(
      result.request?.targetType,
      act0PracticeRepairQueueTargetTypeActiveRepairV1,
    );
    expect(
      result.request?.sourceType,
      act0PracticeRepairQueueSourceActiveRepairV1,
    );
    expect(result.request?.sourceTaskId, 'actions_legal_context');
    expect(
      result.request?.repairFocusKey,
      '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
    );
  });

  test('unknown concept id returns explicit no-target reason', () {
    final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      _candidate(repairFocusId: 'unknown_focus'),
    );

    expect(result.isMapped, isFalse);
    expect(result.request, isNull);
    expect(
      result.reasonCode,
      act0ConceptCandidatePracticeNoTargetUnknownConceptV1,
    );
  });

  test('route-locked allowlist target returns explicit no-target reason', () {
    final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      _candidate(),
      allowlist: const <Act0ConceptCandidatePracticeTargetSpecV1>[
        Act0ConceptCandidatePracticeTargetSpecV1(
          mappingId: 'locked_w7',
          conceptFamilyId: 'no_bet_yet',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          errorType: 'missed_action_read',
          sourceTaskId: 'actions_legal_context',
          targetWorldId: 'world_7',
          targetLessonId: 'w7_stack_checkpoint',
          targetTaskId: 'w7_task',
        ),
      ],
    );

    expect(result.isMapped, isFalse);
    expect(result.request, isNull);
    expect(
      result.reasonCode,
      act0ConceptCandidatePracticeNoTargetRouteLockedV1,
    );
  });

  test('bridge-limited allowlist target returns explicit no-target reason', () {
    final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      _candidate(),
      allowlist: const <Act0ConceptCandidatePracticeTargetSpecV1>[
        Act0ConceptCandidatePracticeTargetSpecV1(
          mappingId: 'bridge_limited',
          conceptFamilyId: 'no_bet_yet',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          errorType: 'missed_action_read',
          sourceTaskId: 'actions_legal_context',
          targetWorldId: 'world_1',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'actions_check_drill',
          bridgeLimited: true,
        ),
      ],
    );

    expect(result.isMapped, isFalse);
    expect(result.request, isNull);
    expect(
      result.reasonCode,
      act0ConceptCandidatePracticeNoTargetBridgeLimitedV1,
    );
  });

  test('missing launch owner fields return explicit no-target reason', () {
    final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      _candidate(),
      allowlist: const <Act0ConceptCandidatePracticeTargetSpecV1>[
        Act0ConceptCandidatePracticeTargetSpecV1(
          mappingId: 'missing_owner',
          conceptFamilyId: 'no_bet_yet',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          errorType: 'missed_action_read',
          sourceTaskId: '',
          targetWorldId: 'world_1',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'actions_check_drill',
        ),
      ],
    );

    expect(result.isMapped, isFalse);
    expect(result.request, isNull);
    expect(
      result.reasonCode,
      act0ConceptCandidatePracticeNoTargetUnsafeLaunchOwnerV1,
    );
  });

  test('duplicate matching specs resolve deterministically by mapping id', () {
    final candidate = _candidate();
    const later = Act0ConceptCandidatePracticeTargetSpecV1(
      mappingId: 'z_later',
      conceptFamilyId: 'no_bet_yet',
      repairFocusId: 'no_bet_yet',
      skillAtomId: 'action_read',
      errorType: 'missed_action_read',
      sourceTaskId: 'actions_legal_context',
      targetWorldId: 'world_1',
      targetLessonId: 'fold_check_call_raise',
      targetTaskId: 'actions_bet_drill',
    );
    const earlier = Act0ConceptCandidatePracticeTargetSpecV1(
      mappingId: 'a_earlier',
      conceptFamilyId: 'no_bet_yet',
      repairFocusId: 'no_bet_yet',
      skillAtomId: 'action_read',
      errorType: 'missed_action_read',
      sourceTaskId: 'actions_legal_context',
      targetWorldId: 'world_1',
      targetLessonId: 'fold_check_call_raise',
      targetTaskId: 'actions_check_drill',
    );

    final first = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      candidate,
      allowlist: const <Act0ConceptCandidatePracticeTargetSpecV1>[
        later,
        earlier,
      ],
    );
    final second = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      candidate,
      allowlist: const <Act0ConceptCandidatePracticeTargetSpecV1>[
        earlier,
        later,
      ],
    );

    expect(first.request?.targetTaskId, 'actions_check_drill');
    expect(second.request?.targetTaskId, first.request?.targetTaskId);
    expect(second.request?.queueItemId, first.request?.queueItemId);
  });

  test('mapper source has no UI route telemetry or content dependency', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart',
    ).readAsStringSync();

    // Keep this mapper pure: it may know launch request types, not shell owners.
    expect(source, isNot(contains('act0_shell_preview_screen_v1.dart')));
    expect(source, isNot(contains('act0_play_shell_v1.dart')));
    expect(source, isNot(contains('Widget')));
    expect(source, isNot(contains('Navigator')));
    expect(source, isNot(contains('telemetry')));
  });
}

Act0ConceptFamilyRepairCandidateV1 _candidate({
  String conceptFamilyId = 'no_bet_yet',
  String repairFocusId = 'no_bet_yet',
  String skillAtomId = 'action_read',
  String errorType = 'missed_action_read',
}) {
  return Act0ConceptFamilyRepairCandidateV1(
    conceptFamilyId: conceptFamilyId,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    errorType: errorType,
    incorrectCount: 1,
    correctCount: 0,
    latestIncorrectOrder: 1,
    selectionReasonCode: 'latest_incorrect_family',
  );
}
