import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

class Act0ReviewMistakeHistoryConsumerV1 {
  const Act0ReviewMistakeHistoryConsumerV1({required this.items});

  final List<Act0ReviewMistakeHistoryItemV1> items;

  bool get hasItems => items.isNotEmpty;

  static Act0ReviewMistakeHistoryConsumerV1 fromHistory(
    Act0ReviewMistakeHistoryV1 history, {
    Set<String> activeRepairSourceTaskIds = const <String>{},
    Act0ReviewResolutionStateV1? reviewResolutionState,
    Act0ReviewPatternCoachingProjectionV1? patternCoachingProjection,
    Act0ShellStateV1? sourceState,
    String Function(String)? localizeOptionLabel,
    bool localeIsRu = false,
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
          decisionLine: localeIsRu
              ? '\u0412\u0430\u0448 \u0432\u044B\u0431\u043E\u0440: ${_readableAction(record, record.selectedId, sourceState: sourceState, localizeOptionLabel: localizeOptionLabel, localeIsRu: true)}; \u043B\u0443\u0447\u0448\u0435: ${_readableAction(record, record.expectedId, sourceState: sourceState, localizeOptionLabel: localizeOptionLabel, localeIsRu: true)}.'
              : 'You chose ${_readableAction(record, record.selectedId, sourceState: sourceState, localizeOptionLabel: localizeOptionLabel)}; better was ${_readableAction(record, record.expectedId, sourceState: sourceState, localizeOptionLabel: localizeOptionLabel)}.',
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

// Source-owned task option copy, not a guessed interpretation of technical IDs.
// The immutable answer IDs remain in persisted history and telemetry.
String _readableAction(
  Act0ReviewMistakeRecordV1 record,
  String raw, {
  Act0ShellStateV1? sourceState,
  String Function(String)? localizeOptionLabel,
  bool localeIsRu = false,
}) {
  final id = raw.trim();
  if (id.isEmpty)
    return localeIsRu
        ? '\u043D\u0435\u0438\u0437\u0432\u0435\u0441\u0442\u043D\u044B\u0439 \u0432\u0430\u0440\u0438\u0430\u043D\u0442'
        : 'unknown option';
  if (sourceState != null) {
    final decisionTaskId = record.decisionTaskId.trim().isNotEmpty
        ? record.decisionTaskId.trim()
        : record.sourceTaskId.trim();
    for (final world in sourceState.worlds) {
      if (world.worldId != record.worldId) continue;
      for (final lesson in world.lessons) {
        if (lesson.lessonId != record.lessonId) continue;
        for (final task in lesson.taskList) {
          if (task.taskId != decisionTaskId) continue;
          for (final option in task.runner.options) {
            if (option.id != id) continue;
            final sourceCopy = option.label.trim();
            final localCopy =
                (localizeOptionLabel?.call(sourceCopy) ?? sourceCopy).trim();
            if (localeIsRu && localCopy == sourceCopy) {
              // Exact authored W1 option text, never guessed from answer IDs.
              final match = RegExp(
                r'^(\d+) private cards, (\d+) board cards, (.+) in the pot$',
              ).firstMatch(sourceCopy);
              if (match != null) {
                return '${match.group(1)} \u0437\u0430\u043a\u0440\u044b\u0442\u044b\u0435 \u043a\u0430\u0440\u0442\u044b, '
                    '${match.group(2)} \u043e\u0431\u0449\u0438\u0435 \u043a\u0430\u0440\u0442\u044b, \u0431\u0430\u043d\u043a ${match.group(3)}';
              }
              if (sourceCopy == '5 board cards are already out') {
                return '\u0423\u0436\u0435 \u043e\u0442\u043a\u0440\u044b\u0442\u043e 5 \u043e\u0431\u0449\u0438\u0445 \u043a\u0430\u0440\u0442';
              }
            }
            if (localCopy.isNotEmpty) return localCopy;
          }
        }
      }
    }
  }
  // Only direct poker action IDs have unambiguous standalone meanings.
  switch (id) {
    case 'fold':
      return localeIsRu ? '\u0444\u043E\u043B\u0434' : 'fold';
    case 'check':
      return localeIsRu ? '\u0447\u0435\u043A' : 'check';
    case 'call':
      return localeIsRu ? '\u043A\u043E\u043B\u043B' : 'call';
    case 'raise':
      return localeIsRu ? '\u0440\u0435\u0439\u0437' : 'raise';
    case 'all_in':
      return localeIsRu ? '\u043E\u043B\u043B-\u0438\u043D' : 'all-in';
    default:
      return localeIsRu
          ? '\u044D\u0442\u043E\u0442 \u0432\u0430\u0440\u0438\u0430\u043D\u0442'
          : 'that option';
  }
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
