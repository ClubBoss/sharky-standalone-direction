import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';

const String act0PracticeRepairQueueSourceReviewHistoryV1 =
    'review_history_unresolved_v1';
const String act0PracticeRepairQueueSourceActiveRepairV1 = 'active_repair_v1';
const String act0PracticeRepairQueueStateQueuedUnresolvedV1 =
    'queued_unresolved_v1';
const String act0PracticeRepairQueueTargetTypeActiveRepairV1 =
    'active_repair_target_v1';
const String act0PracticeRepairQueueTargetTypeNotLaunchableV1 =
    'not_launchable_v1';

class Act0PracticeRepairQueueProjectionV1 {
  const Act0PracticeRepairQueueProjectionV1({
    this.items = const <Act0PracticeRepairQueueItemV1>[],
  });

  static const int maxCandidateCount = 10;

  final List<Act0PracticeRepairQueueItemV1> items;

  bool get hasItems => items.isNotEmpty;

  List<Map<String, Object?>> toPayload() =>
      items.map((item) => item.toPayload()).toList(growable: false);

  static Act0PracticeRepairQueueProjectionV1 fromSources({
    Act0ReviewMistakeHistoryV1 reviewMistakeHistory =
        const Act0ReviewMistakeHistoryV1(),
    List<Act0RepairIntentV1> activeRepairIntents = const <Act0RepairIntentV1>[],
    int maxCandidates = maxCandidateCount,
  }) {
    final safeMax = maxCandidates < 1
        ? maxCandidateCount
        : maxCandidates.clamp(1, maxCandidateCount);
    final candidates = <_QueueCandidateV1>[];
    final seenDedupKeys = <String>{};

    final activeRepairs = <Act0RepairIntentV1>[...activeRepairIntents]
      ..sort(
        (a, b) => _activeRepairSortKey(a).compareTo(_activeRepairSortKey(b)),
      );
    for (final intent in activeRepairs) {
      final key = _dedupKey(
        sourceTaskId: intent.sourceTaskId,
        repairFocusId: intent.missedSignalId,
        skillTag: intent.skillAtomId,
        errorDetail: intent.errorType,
      );
      if (key.isEmpty || seenDedupKeys.contains(key)) {
        continue;
      }
      seenDedupKeys.add(key);
      candidates.add(
        _QueueCandidateV1(
          sortBucket: 0,
          sortOrder: 0,
          item: Act0PracticeRepairQueueItemV1(
            itemId: 'practice_repair_queue_v1|active|${_keyPart(key)}',
            sourceRecordId: intent.reasonCode,
            sourceKey: key,
            sourceTaskId: intent.sourceTaskId.trim(),
            skillTag: intent.skillAtomId.trim(),
            safeLabel: _safeLabel(intent.skillLabel, intent.skillAtomId),
            errorDetail: intent.errorType.trim(),
            selectedId: intent.choiceId.trim(),
            betterId: '',
            context: intent.missedSignalLabel.trim(),
            priority: 0,
            sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
            state: act0PracticeRepairQueueStateQueuedUnresolvedV1,
            launchTarget: _activeRepairLaunchTarget(intent),
          ),
        ),
      );
    }

    final records = <Act0ReviewMistakeRecordV1>[...reviewMistakeHistory.records]
      ..sort((a, b) {
        final updatedCompare = b.updatedOrder.compareTo(a.updatedOrder);
        return updatedCompare != 0
            ? updatedCompare
            : a.recordId.compareTo(b.recordId);
      });
    for (final record in records) {
      final key = _dedupKey(
        sourceTaskId: record.sourceTaskId,
        repairFocusId: record.repairFocusId,
        skillTag: record.skillAtomId,
        errorDetail: record.errorType,
      );
      if (key.isEmpty || seenDedupKeys.contains(key)) {
        continue;
      }
      seenDedupKeys.add(key);
      candidates.add(
        _QueueCandidateV1(
          sortBucket: 1,
          sortOrder: -record.updatedOrder,
          item: Act0PracticeRepairQueueItemV1(
            itemId: 'practice_repair_queue_v1|history|${record.recordId}',
            sourceRecordId: record.recordId,
            sourceKey: key,
            sourceTaskId: record.sourceTaskId.trim(),
            skillTag: record.skillAtomId.trim(),
            safeLabel: _safeLabel('', record.skillAtomId),
            errorDetail: record.errorType.trim(),
            selectedId: record.selectedId.trim(),
            betterId: record.expectedId.trim(),
            context: record.repairFocusId.trim(),
            priority: 0,
            sourceType: act0PracticeRepairQueueSourceReviewHistoryV1,
            state: act0PracticeRepairQueueStateQueuedUnresolvedV1,
            launchTarget:
                const Act0PracticeRepairQueueLaunchTargetV1.notLaunchable(
                  source: act0PracticeRepairQueueSourceReviewHistoryV1,
                ),
          ),
        ),
      );
    }

    candidates.sort((a, b) {
      final bucketCompare = a.sortBucket.compareTo(b.sortBucket);
      if (bucketCompare != 0) {
        return bucketCompare;
      }
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return a.item.sourceKey.compareTo(b.item.sourceKey);
    });
    final capped = candidates.take(safeMax).toList(growable: false);
    final items = <Act0PracticeRepairQueueItemV1>[
      for (var index = 0; index < capped.length; index++)
        capped[index].item.copyWith(priority: index),
    ];
    return Act0PracticeRepairQueueProjectionV1(
      items: List<Act0PracticeRepairQueueItemV1>.unmodifiable(items),
    );
  }
}

class Act0PracticeRepairQueueItemV1 {
  const Act0PracticeRepairQueueItemV1({
    this.schemaVersion = 1,
    required this.itemId,
    required this.sourceRecordId,
    required this.sourceKey,
    required this.sourceTaskId,
    required this.skillTag,
    required this.safeLabel,
    required this.errorDetail,
    required this.selectedId,
    required this.betterId,
    required this.context,
    required this.priority,
    required this.sourceType,
    required this.state,
    this.launchTarget =
        const Act0PracticeRepairQueueLaunchTargetV1.notLaunchable(),
  });

  final int schemaVersion;
  final String itemId;
  final String sourceRecordId;
  final String sourceKey;
  final String sourceTaskId;
  final String skillTag;
  final String safeLabel;
  final String errorDetail;
  final String selectedId;
  final String betterId;
  final String context;
  final int priority;
  final String sourceType;
  final String state;
  final Act0PracticeRepairQueueLaunchTargetV1 launchTarget;

  Act0PracticeRepairQueueItemV1 copyWith({int? priority}) {
    return Act0PracticeRepairQueueItemV1(
      schemaVersion: schemaVersion,
      itemId: itemId,
      sourceRecordId: sourceRecordId,
      sourceKey: sourceKey,
      sourceTaskId: sourceTaskId,
      skillTag: skillTag,
      safeLabel: safeLabel,
      errorDetail: errorDetail,
      selectedId: selectedId,
      betterId: betterId,
      context: context,
      priority: priority ?? this.priority,
      sourceType: sourceType,
      state: state,
      launchTarget: launchTarget,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'itemId': itemId,
    'sourceRecordId': sourceRecordId,
    'sourceKey': sourceKey,
    'sourceTaskId': sourceTaskId,
    'skillTag': skillTag,
    'safeLabel': safeLabel,
    'errorDetail': errorDetail,
    'selectedId': selectedId,
    'betterId': betterId,
    'context': context,
    'priority': priority,
    'sourceType': sourceType,
    'state': state,
    'launchTarget': launchTarget.toPayload(),
  };
}

class Act0PracticeRepairQueueLaunchTargetV1 {
  const Act0PracticeRepairQueueLaunchTargetV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.source,
    required this.targetType,
  });

  const Act0PracticeRepairQueueLaunchTargetV1.notLaunchable({
    this.source = act0PracticeRepairQueueTargetTypeNotLaunchableV1,
  }) : worldId = '',
       lessonId = '',
       taskId = '',
       targetType = act0PracticeRepairQueueTargetTypeNotLaunchableV1;

  final String worldId;
  final String lessonId;
  final String taskId;
  final String source;
  final String targetType;

  bool get isLaunchable =>
      targetType != act0PracticeRepairQueueTargetTypeNotLaunchableV1 &&
      worldId.trim().isNotEmpty &&
      lessonId.trim().isNotEmpty &&
      taskId.trim().isNotEmpty;

  Map<String, Object> toPayload() {
    if (!isLaunchable) {
      return <String, Object>{'source': source, 'targetType': targetType};
    }
    return <String, Object>{
      'worldId': worldId,
      'lessonId': lessonId,
      'taskId': taskId,
      'source': source,
      'targetType': targetType,
    };
  }
}

class _QueueCandidateV1 {
  const _QueueCandidateV1({
    required this.sortBucket,
    required this.sortOrder,
    required this.item,
  });

  final int sortBucket;
  final int sortOrder;
  final Act0PracticeRepairQueueItemV1 item;
}

String _activeRepairSortKey(Act0RepairIntentV1 intent) {
  return <String>[
    intent.sourceTaskId,
    intent.missedSignalId,
    intent.skillAtomId,
    intent.errorType,
  ].join('|');
}

Act0PracticeRepairQueueLaunchTargetV1 _activeRepairLaunchTarget(
  Act0RepairIntentV1 intent,
) {
  final worldId = intent.targetWorldId.trim();
  final lessonId = intent.targetLessonId.trim();
  final taskId = intent.targetTaskId.trim();
  if (worldId.isEmpty || lessonId.isEmpty || taskId.isEmpty) {
    return const Act0PracticeRepairQueueLaunchTargetV1.notLaunchable(
      source: act0PracticeRepairQueueSourceActiveRepairV1,
    );
  }
  return Act0PracticeRepairQueueLaunchTargetV1(
    worldId: worldId,
    lessonId: lessonId,
    taskId: taskId,
    source: act0PracticeRepairQueueSourceActiveRepairV1,
    targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
  );
}

String _dedupKey({
  required String sourceTaskId,
  required String repairFocusId,
  required String skillTag,
  required String errorDetail,
}) {
  final parts = <String>[
    sourceTaskId.trim(),
    repairFocusId.trim(),
    skillTag.trim(),
    errorDetail.trim(),
  ];
  if (parts.every((part) => part.isEmpty)) {
    return '';
  }
  return parts.map(_keyPart).join('|');
}

String _keyPart(String value) => '${value.length}:$value';

String _safeLabel(String rawLabel, String skillTag) {
  final label = rawLabel.trim();
  if (label.isNotEmpty) {
    return label;
  }
  final normalized = skillTag.trim().replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return 'Practice repair';
  }
  final lower = normalized
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part.toLowerCase())
      .join(' ');
  return lower.isEmpty
      ? 'Practice repair'
      : lower[0].toUpperCase() + lower.substring(1);
}
