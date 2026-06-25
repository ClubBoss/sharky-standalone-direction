import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';

void main() {
  test('empty history creates an empty Practice repair queue', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources();

    expect(projection.items, isEmpty);
    expect(projection.hasItems, isFalse);
  });

  test('unresolved Review history records become queued Practice items', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[
          _mistakeRecord(order: 2, sourceTaskId: 'actions_bet_drill'),
          _mistakeRecord(order: 1, sourceTaskId: 'actions_check_drill'),
        ],
      ),
    );

    expect(projection.items, hasLength(2));
    final first = projection.items.first;
    expect(first.sourceType, act0PracticeRepairQueueSourceReviewHistoryV1);
    expect(first.state, act0PracticeRepairQueueStateQueuedUnresolvedV1);
    expect(first.sourceRecordId, startsWith('review_mistake_v1|'));
    expect(first.sourceTaskId, 'actions_bet_drill');
    expect(first.skillTag, 'action_read');
    expect(first.safeLabel, 'Action read');
    expect(first.selectedId, 'fold');
    expect(first.betterId, 'check');
    expect(first.priority, 0);
  });

  test('correct or empty sources do not create queue items', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      reviewMistakeHistory: const Act0ReviewMistakeHistoryV1(),
      activeRepairIntents: const <Act0RepairIntentV1>[],
    );

    expect(projection.items, isEmpty);
  });

  test('retention caps Practice queue candidates at ten', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[
          for (var order = 1; order <= 12; order++)
            _mistakeRecord(order: order, sourceTaskId: 'task_$order'),
        ],
      ),
    );

    expect(projection.items, hasLength(10));
    expect(projection.items.first.sourceTaskId, 'task_12');
    expect(projection.items.last.sourceTaskId, 'task_3');
    expect(
      projection.items.map((item) => item.priority),
      List.generate(10, (i) => i),
    );
  });

  test('ordering is deterministic with active repair pinned first', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[
          _mistakeRecord(order: 2, sourceTaskId: 'review_two'),
          _mistakeRecord(order: 1, sourceTaskId: 'review_one'),
        ],
      ),
    );

    expect(projection.items.map((item) => item.sourceType), <String>[
      act0PracticeRepairQueueSourceActiveRepairV1,
      act0PracticeRepairQueueSourceReviewHistoryV1,
      act0PracticeRepairQueueSourceReviewHistoryV1,
    ]);
    expect(projection.items.map((item) => item.priority), <int>[0, 1, 2]);
  });

  test('active repair dedups against matching Review history item', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[
          _mistakeRecord(
            order: 2,
            sourceTaskId: 'actions_legal_context',
            repairFocusId: 'no_bet_yet',
            skillAtomId: 'action_read',
            errorType: 'missed_action_read',
          ),
        ],
      ),
    );

    expect(projection.items, hasLength(1));
    expect(
      projection.items.single.sourceType,
      act0PracticeRepairQueueSourceActiveRepairV1,
    );
    expect(projection.items.single.sourceTaskId, 'actions_legal_context');
  });

  test('active repair payload remains owned and unchanged', () {
    const intent = _activeRepairIntent;
    final before = intent.toPayload();

    Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[intent],
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[_mistakeRecord(order: 1)],
      ),
    );

    expect(intent.toPayload(), before);
  });

  test('active repair row with target exposes launch target metadata', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
    );

    final item = projection.items.single;
    expect(item.launchTarget.isLaunchable, isTrue);
    expect(
      item.launchTarget.targetType,
      act0PracticeRepairQueueTargetTypeActiveRepairV1,
    );
    expect(item.launchTarget.worldId, 'world_1');
    expect(item.launchTarget.lessonId, 'fold_check_call_raise');
    expect(item.launchTarget.taskId, 'actions_check_drill');
    expect(
      item.launchTarget.source,
      act0PracticeRepairQueueSourceActiveRepairV1,
    );

    final payload = item.toPayload();
    expect(payload['targetWorldId'], isNull);
    expect(payload['targetLessonId'], isNull);
    expect(payload['targetTaskId'], isNull);
    expect(payload['launchTarget'], <String, Object>{
      'worldId': 'world_1',
      'lessonId': 'fold_check_call_raise',
      'taskId': 'actions_check_drill',
      'source': act0PracticeRepairQueueSourceActiveRepairV1,
      'targetType': act0PracticeRepairQueueTargetTypeActiveRepairV1,
    });
    expect(item.launchRequest?.toPayload(), <String, Object>{
      'targetWorldId': 'world_1',
      'targetLessonId': 'fold_check_call_raise',
      'targetTaskId': 'actions_check_drill',
      'targetType': act0PracticeRepairQueueTargetTypeActiveRepairV1,
      'sourceType': act0PracticeRepairQueueSourceActiveRepairV1,
      'sourceTaskId': 'actions_legal_context',
      'repairTaskId': 'actions_check_drill',
      'repairFocusKey':
          '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
      'queueItemId': item.itemId,
    });
  });

  test('active repair row without target remains passive', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[
        Act0RepairIntentV1(
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
          targetWorldId: ' ',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'actions_check_drill',
          mappingType: 'repair',
          reasonCode: 'same_signal_action_read_no_bet_yet',
        ),
      ],
    );

    final item = projection.items.single;
    expect(item.launchTarget.isLaunchable, isFalse);
    expect(item.launchRequest, isNull);
    expect(
      item.launchTarget.targetType,
      act0PracticeRepairQueueTargetTypeNotLaunchableV1,
    );
    expect(item.toPayload()['launchTarget'], <String, Object>{
      'source': act0PracticeRepairQueueSourceActiveRepairV1,
      'targetType': act0PracticeRepairQueueTargetTypeNotLaunchableV1,
    });
  });

  test('history rows remain passive and expose no launch target ids', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[
          _mistakeRecord(order: 1, skillAtomId: 'target_like_label'),
        ],
      ),
    );

    final item = projection.items.single;
    expect(item.sourceType, act0PracticeRepairQueueSourceReviewHistoryV1);
    expect(item.launchTarget.isLaunchable, isFalse);
    expect(item.launchRequest, isNull);
    final launchTarget =
        item.toPayload()['launchTarget'] as Map<String, Object?>;
    expect(
      launchTarget['targetType'],
      act0PracticeRepairQueueTargetTypeNotLaunchableV1,
    );
    expect(launchTarget.keys, isNot(contains('worldId')));
    expect(launchTarget.keys, isNot(contains('lessonId')));
    expect(launchTarget.keys, isNot(contains('taskId')));
    expect(item.toPayload().keys, isNot(contains('launchRequest')));
  });

  test('projection contains no fixed cleared or resolved states', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[_mistakeRecord(order: 1)],
      ),
    );

    final payloadText = projection.toPayload().toString().toLowerCase();
    expect(payloadText, isNot(contains('fixed')));
    expect(payloadText, isNot(contains('cleared')));
    expect(payloadText, isNot(contains('done')));
    expect(projection.items.map((item) => item.state).toSet(), <String>{
      act0PracticeRepairQueueStateQueuedUnresolvedV1,
    });
  });

  test('projection has no forbidden claim or commerce vocabulary', () {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[_mistakeRecord(order: 1)],
      ),
    );
    final payloadText = projection.toPayload().toString().toLowerCase();
    final sourceText = File(
      'lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart',
    ).readAsStringSync().toLowerCase();

    for (final forbidden in <String>[
      'ai found',
      'ai detected',
      'leak fixed',
      'mastery',
      'mastered',
      'gto',
      'solver',
      'premium',
      'paywall',
    ]) {
      expect(payloadText, isNot(contains(forbidden)));
      expect(sourceText, isNot(contains(forbidden)));
    }
  });

  test('projection source has no UI dependency', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('Widget')));
    expect(source, isNot(contains('BuildContext')));
    expect(source, isNot(contains('act0_practice')));
    expect(source, isNot(contains('act0_play_shell')));
    expect(source, isNot(contains('act0_home_shell')));
    expect(source, isNot(contains('act0_review_shell')));
  });
}

const _activeRepairIntent = Act0RepairIntentV1(
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

Act0ReviewMistakeRecordV1 _mistakeRecord({
  required int order,
  String sourceTaskId = 'actions_legal_context',
  String repairFocusId = 'no_bet_yet',
  String skillAtomId = 'action_read',
  String errorType = 'missed_action_read',
}) {
  final recordId =
      'review_mistake_v1|${sourceTaskId.length}:$sourceTaskId|'
      '${repairFocusId.length}:$repairFocusId|'
      '${skillAtomId.length}:$skillAtomId|'
      '${errorType.length}:$errorType';
  return Act0ReviewMistakeRecordV1(
    recordId: recordId,
    sourceDecisionId: 'decision_v1|$order',
    createdOrder: order,
    updatedOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    decisionTaskId: '${sourceTaskId}_decision',
    sourceTaskId: sourceTaskId,
    decisionKind: 'actionList',
    selectedId: 'fold',
    expectedId: 'check',
    resultKind: 'incorrect',
    errorType: errorType,
    skillAtomId: skillAtomId,
    repairFocusId: repairFocusId,
    runId: 'run_v1|world_1|fold_check_call_raise|1',
    runKind: 'lesson',
    runOrdinal: 1,
    attemptRecordIds: <String>['decision_v1|$order'],
    dedupUsesFallback: false,
  );
}
