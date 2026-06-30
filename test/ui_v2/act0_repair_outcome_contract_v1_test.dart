import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

void main() {
  test(
    'active repair queue item keeps source context outside launch target',
    () {
      const intent = Act0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: 'fold_check_call_raise',
        sourceTaskId: 'actions_legal_context',
        choiceId: 'fold',
        result: 'incorrect',
        errorType: 'missed_action_read',
        missedSignalId: 'no_bet_yet',
        missedSignalLabel: 'No bet yet',
        skillAtomId: 'action_read',
        skillLabel: 'Action read',
        targetWorldId: 'world_1',
        targetLessonId: 'fold_check_call_raise',
        targetTaskId: 'actions_check_drill',
        mappingType: 'repair',
        reasonCode: 'same_signal_action_read_no_bet_yet',
      );

      final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
        activeRepairIntents: const <Act0RepairIntentV1>[intent],
      );

      expect(projection.items, hasLength(1));
      final itemPayload = projection.items.single.toPayload();
      expect(itemPayload['sourceRecordId'], intent.reasonCode);
      expect(itemPayload['sourceKey'], contains(intent.sourceTaskId));
      expect(itemPayload['sourceTaskId'], intent.sourceTaskId);

      final targetPayload = projection.items.single.launchTarget.toPayload();
      expect(targetPayload['worldId'], intent.targetWorldId);
      expect(targetPayload['lessonId'], intent.targetLessonId);
      expect(targetPayload['taskId'], intent.targetTaskId);
      expect(
        targetPayload['targetType'],
        act0PracticeRepairQueueTargetTypeActiveRepairV1,
      );
      expect(
        targetPayload,
        isNot(containsPair('sourceTaskId', intent.sourceTaskId)),
      );
      expect(targetPayload, isNot(contains('sourceRecordId')));
      expect(targetPayload, isNot(contains('sourceKey')));

      final requestPayload = projection.items.single.launchRequest?.toPayload();
      expect(requestPayload?['targetWorldId'], intent.targetWorldId);
      expect(requestPayload?['targetLessonId'], intent.targetLessonId);
      expect(requestPayload?['targetTaskId'], intent.targetTaskId);
      expect(requestPayload?['sourceTaskId'], intent.sourceTaskId);
      expect(requestPayload?['repairTaskId'], intent.targetTaskId);
      expect(requestPayload?['queueItemId'], itemPayload['itemId']);
    },
  );

  test(
    'practice queue shell launch restores source context without resolution',
    () {
      final previewSource = File(
        'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
      ).readAsStringSync();
      final methodStart = previewSource.indexOf(
        'void _startPracticeRepairQueueTarget(',
      );
      final methodEnd = previewSource.indexOf(
        'void _startMistakeRepair(',
        methodStart,
      );
      expect(methodStart, isNonNegative);
      expect(methodEnd, greaterThan(methodStart));

      final methodSource = previewSource.substring(methodStart, methodEnd);
      expect(
        methodSource,
        contains('Act0PracticeRepairQueueLaunchRequestV1 request'),
      );
      expect(methodSource, contains("String evidenceStartedBy ="));
      expect(methodSource, contains("evidenceRunKind: 'repair'"));
      expect(methodSource, contains('evidenceStartedBy: evidenceStartedBy'));
      expect(methodSource, contains("_activePracticeGroupId = 'weak_spots'"));
      expect(
        methodSource,
        contains('_activeRepairTaskId = request.repairTaskId'),
      );
      expect(
        methodSource,
        contains('_activeRepairSourceTaskId = request.sourceTaskId'),
      );
      expect(methodSource, isNot(contains('sourceRecordId')));
      expect(methodSource, isNot(contains('sourceKey')));
      expect(methodSource, isNot(contains('fixed_v1')));
      expect(methodSource, isNot(contains('cleared_v1')));
      expect(methodSource, isNot(contains('resolved_v1')));
      expect(methodSource, isNot(contains('completed_v1')));
    },
  );

  test('repair outcome projection admits only safe outcome states', () {
    final outcomeSource = File(
      'lib/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart',
    ).readAsStringSync();
    final previewSource = File(
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
    ).readAsStringSync();
    final scannedSource = '$outcomeSource\n$previewSource';

    expect(outcomeSource, contains('Act0RepairOutcomeProjectionV1'));
    expect(outcomeSource, contains('Act0RepairOutcomeV1'));
    expect(outcomeSource, contains('repair_attempted_v1'));
    expect(outcomeSource, contains('repair_correct_v1'));
    expect(outcomeSource, contains('repair_still_needs_rep_v1'));
    for (final forbidden in <String>[
      'fixed_v1',
      'cleared_v1',
      'resolved_v1',
      'completed_v1',
      'mastered_v1',
    ]) {
      expect(scannedSource, isNot(contains(forbidden)));
    }
  });
}
