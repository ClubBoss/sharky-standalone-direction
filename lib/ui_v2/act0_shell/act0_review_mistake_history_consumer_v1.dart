import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';

class Act0ReviewMistakeHistoryConsumerV1 {
  const Act0ReviewMistakeHistoryConsumerV1({required this.items});

  final List<Act0ReviewMistakeHistoryItemV1> items;

  bool get hasItems => items.isNotEmpty;

  static Act0ReviewMistakeHistoryConsumerV1 fromHistory(
    Act0ReviewMistakeHistoryV1 history, {
    Set<String> activeRepairSourceTaskIds = const <String>{},
  }) {
    final activeSources = activeRepairSourceTaskIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final items = <Act0ReviewMistakeHistoryItemV1>[];
    for (final record in history.records) {
      if (activeSources.contains(record.sourceTaskId.trim())) {
        continue;
      }
      items.add(
        Act0ReviewMistakeHistoryItemV1(
          stableKey: record.recordId,
          sourceTaskId: record.sourceTaskId,
          primaryLabel: _firstReadableLabel(<String>[
            record.skillAtomId,
            record.repairFocusId,
            record.errorType,
          ]),
          detailLine: _firstReadableLabel(<String>[
            record.errorType,
            record.repairFocusId,
            record.resultKind,
          ]),
          decisionLine:
              'You chose ${_readableAction(record.selectedId)}; better was '
              '${_readableAction(record.expectedId)}.',
          contextLine: _readableContext(record),
          orderLabel: items.isEmpty ? 'Most recent' : 'Earlier',
        ),
      );
    }
    return Act0ReviewMistakeHistoryConsumerV1(
      items: List<Act0ReviewMistakeHistoryItemV1>.unmodifiable(items),
    );
  }
}

class Act0ReviewMistakeHistoryItemV1 {
  const Act0ReviewMistakeHistoryItemV1({
    required this.stableKey,
    required this.sourceTaskId,
    required this.primaryLabel,
    required this.detailLine,
    required this.decisionLine,
    required this.contextLine,
    required this.orderLabel,
  });

  final String stableKey;
  final String sourceTaskId;
  final String primaryLabel;
  final String detailLine;
  final String decisionLine;
  final String contextLine;
  final String orderLabel;
}

String _firstReadableLabel(List<String> values) {
  for (final raw in values) {
    final value = _humanize(raw);
    if (value.isNotEmpty) {
      return value;
    }
  }
  return 'Review spot';
}

String _readableAction(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return 'your action';
  }
  return _humanize(value).toLowerCase();
}

String _readableContext(Act0ReviewMistakeRecordV1 record) {
  final lesson = _humanize(record.lessonId).toLowerCase();
  if (lesson.isNotEmpty) {
    return lesson;
  }
  final runKind = _humanize(record.runKind).toLowerCase();
  return runKind.isEmpty ? 'completed hand' : runKind;
}

String _humanize(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return '';
  }
  final words = value
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .split(' ');
  if (words.isEmpty) {
    return '';
  }
  final lower = words.join(' ').toLowerCase();
  return lower.substring(0, 1).toUpperCase() + lower.substring(1);
}
