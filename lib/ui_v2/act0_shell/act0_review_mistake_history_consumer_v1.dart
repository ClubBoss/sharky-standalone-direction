import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';

class Act0ReviewMistakeHistoryConsumerV1 {
  const Act0ReviewMistakeHistoryConsumerV1({required this.items});

  final List<Act0ReviewMistakeHistoryItemV1> items;

  bool get hasItems => items.isNotEmpty;

  static Act0ReviewMistakeHistoryConsumerV1 fromHistory(
    Act0ReviewMistakeHistoryV1 history, {
    Set<String> activeRepairSourceTaskIds = const <String>{},
    Act0ReviewResolutionStateV1? reviewResolutionState,
    Act0ReviewPatternCoachingProjectionV1? patternCoachingProjection,
  }) {
    final activeSources = activeRepairSourceTaskIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final items = <Act0ReviewMistakeHistoryItemV1>[];
    var didAttachPattern = false;
    for (final record in history.records) {
      final resolution = reviewResolutionState?.resolutionForReviewItemId(
        record.recordId,
      );
      if (resolution != null && !resolution.isVisibleInActiveReview) {
        continue;
      }
      if (activeSources.contains(record.sourceTaskId.trim())) {
        continue;
      }
      final patternLine =
          !didAttachPattern &&
              _recordMatchesPrimaryPattern(record, patternCoachingProjection)
          ? patternCoachingProjection?.copyLine
          : null;
      if (patternLine != null) {
        didAttachPattern = true;
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
          patternLine: patternLine,
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
    this.patternLine,
  });

  final String stableKey;
  final String sourceTaskId;
  final String primaryLabel;
  final String detailLine;
  final String decisionLine;
  final String contextLine;
  final String orderLabel;
  final String? patternLine;
}

bool _recordMatchesPrimaryPattern(
  Act0ReviewMistakeRecordV1 record,
  Act0ReviewPatternCoachingProjectionV1? projection,
) {
  final pattern = projection?.primaryPattern;
  if (pattern == null) {
    return false;
  }
  return _conceptFamilyIdForRecord(record) == pattern.conceptFamilyId;
}

String _conceptFamilyIdForRecord(Act0ReviewMistakeRecordV1 record) {
  for (final raw in <String>[
    record.repairFocusId,
    record.skillAtomId,
    record.errorType,
  ]) {
    final value = raw.trim();
    if (value.isNotEmpty && value != 'none') {
      return value;
    }
  }
  return '';
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
