import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

void main() {
  test('empty projection produces no Practice repair queue rows', () {
    final consumer = Act0PracticeRepairQueueConsumerV1.fromProjection(
      const Act0PracticeRepairQueueProjectionV1(),
    );

    expect(consumer.hasItems, isFalse);
    expect(consumer.items, isEmpty);
  });

  test('consumer caps Practice repair queue rows at three', () {
    final consumer = Act0PracticeRepairQueueConsumerV1.fromProjection(
      Act0PracticeRepairQueueProjectionV1(
        items: <Act0PracticeRepairQueueItemV1>[
          for (var index = 0; index < 5; index++)
            _item(
              itemId: 'history_$index',
              sourceTaskId: 'task_$index',
              safeLabel: 'Action read $index',
            ),
        ],
      ),
    );

    expect(consumer.items, hasLength(3));
    expect(consumer.items.map((item) => item.title), <String>[
      'Action read 0',
      'Action read 1',
      'Action read 2',
    ]);
  });

  test('active repair item is pinned first and capped to one row', () {
    final consumer = Act0PracticeRepairQueueConsumerV1.fromProjection(
      Act0PracticeRepairQueueProjectionV1(
        items: <Act0PracticeRepairQueueItemV1>[
          _item(
            itemId: 'history',
            sourceTaskId: 'history_task',
            safeLabel: 'History read',
          ),
          _item(
            itemId: 'active_a',
            sourceTaskId: 'active_a_task',
            safeLabel: 'Active read A',
            sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
          ),
          _item(
            itemId: 'active_b',
            sourceTaskId: 'active_b_task',
            safeLabel: 'Active read B',
            sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
          ),
        ],
      ),
    );

    expect(consumer.items, hasLength(2));
    expect(consumer.items.first.title, 'Active read A');
    expect(consumer.items.first.isPinned, isTrue);
    expect(consumer.items.where((item) => item.isPinned), hasLength(1));
  });

  test('unsafe or empty labels use safe fallback copy', () {
    final consumer = Act0PracticeRepairQueueConsumerV1.fromProjection(
      Act0PracticeRepairQueueProjectionV1(
        items: <Act0PracticeRepairQueueItemV1>[
          _item(
            itemId: 'unsafe',
            sourceTaskId: 'unsafe_task',
            safeLabel: '  ',
            errorDetail: 'solver leak fixed',
            context: 'mastery claim',
          ),
        ],
      ),
    );

    expect(consumer.items.single.title, 'Practice repair');
    expect(consumer.items.single.detail, isNull);
    expect(consumer.items.single.actionLine, isNull);
    final rendered = consumer.items.single.toString().toLowerCase();
    for (final forbidden in <String>[
      'solver',
      'leak',
      'fixed',
      'mastery',
      'gto',
      'premium',
    ]) {
      expect(rendered, isNot(contains(forbidden)));
    }
  });

  test(
    'consumer imports projection only, not Review history or active intent',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart',
      ).readAsStringSync();

      expect(source, contains('act0_practice_repair_queue_projection_v1.dart'));
      expect(source, isNot(contains('act0_review_mistake_history_v1.dart')));
      expect(source, isNot(contains('Act0ReviewMistakeHistory')));
      expect(source, isNot(contains('act0_repair_intent_contract_v1.dart')));
      expect(source, isNot(contains('Act0RepairIntent')));
      expect(source, isNot(contains('Navigator')));
      expect(source, isNot(contains('ProgressService')));
      expect(source, isNot(contains('telemetry')));
    },
  );
}

Act0PracticeRepairQueueItemV1 _item({
  required String itemId,
  required String sourceTaskId,
  required String safeLabel,
  String sourceType = act0PracticeRepairQueueSourceReviewHistoryV1,
  String errorDetail = 'missed_action_read',
  String context = 'No bet yet',
}) {
  return Act0PracticeRepairQueueItemV1(
    itemId: itemId,
    sourceRecordId: 'record_$itemId',
    sourceKey: 'key_$itemId',
    sourceTaskId: sourceTaskId,
    skillTag: 'action_read',
    safeLabel: safeLabel,
    errorDetail: errorDetail,
    selectedId: 'fold',
    betterId: 'check',
    context: context,
    priority: 0,
    sourceType: sourceType,
    state: act0PracticeRepairQueueStateQueuedUnresolvedV1,
  );
}
