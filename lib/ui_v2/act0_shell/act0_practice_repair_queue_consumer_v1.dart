import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

class Act0PracticeRepairQueueConsumerV1 {
  const Act0PracticeRepairQueueConsumerV1({
    this.items = const <Act0PracticeRepairQueueItemViewModelV1>[],
  });

  static const int maxVisibleItems = 3;

  final List<Act0PracticeRepairQueueItemViewModelV1> items;

  bool get hasItems => items.isNotEmpty;

  static Act0PracticeRepairQueueConsumerV1 fromProjection(
    Act0PracticeRepairQueueProjectionV1 projection,
  ) {
    final pinned = <Act0PracticeRepairQueueItemViewModelV1>[];
    final regular = <Act0PracticeRepairQueueItemViewModelV1>[];
    var hasPinned = false;
    for (final item in projection.items) {
      if (item.state != act0PracticeRepairQueueStateQueuedUnresolvedV1) {
        continue;
      }
      final viewModel = Act0PracticeRepairQueueItemViewModelV1.fromItem(
        item,
        isPinned:
            !hasPinned &&
            item.sourceType == act0PracticeRepairQueueSourceActiveRepairV1,
      );
      if (viewModel == null) {
        continue;
      }
      if (viewModel.isPinned) {
        pinned.add(viewModel);
        hasPinned = true;
      } else if (item.sourceType !=
          act0PracticeRepairQueueSourceActiveRepairV1) {
        regular.add(viewModel);
      }
    }
    final visible = <Act0PracticeRepairQueueItemViewModelV1>[
      ...pinned,
      ...regular,
    ].take(maxVisibleItems).toList(growable: false);
    return Act0PracticeRepairQueueConsumerV1(items: visible);
  }
}

class Act0PracticeRepairQueueItemViewModelV1 {
  const Act0PracticeRepairQueueItemViewModelV1({
    required this.itemId,
    required this.title,
    required this.isPinned,
    this.launchTarget,
    this.launchRequest,
    this.detail,
    this.actionLine,
  });

  final String itemId;
  final String title;
  final bool isPinned;
  final Act0PracticeRepairQueueLaunchTargetV1? launchTarget;
  final Act0PracticeRepairQueueLaunchRequestV1? launchRequest;
  final String? detail;
  final String? actionLine;

  bool get isLaunchable => launchRequest?.isLaunchable ?? false;

  static Act0PracticeRepairQueueItemViewModelV1? fromItem(
    Act0PracticeRepairQueueItemV1 item, {
    required bool isPinned,
  }) {
    final resolvedTitle = _safeText(item.safeLabel) ?? _safeText(item.skillTag);
    final detail = _safeText(item.context);
    final selected = _safeText(item.selectedId);
    final better = _safeText(item.betterId);
    final actionLine =
        resolvedTitle != null && selected != null && better != null
        ? 'You chose $selected - better: $better'
        : null;
    return Act0PracticeRepairQueueItemViewModelV1(
      itemId: item.itemId,
      title: resolvedTitle ?? 'Practice repair',
      isPinned: isPinned,
      launchTarget: item.launchTarget.isLaunchable ? item.launchTarget : null,
      launchRequest: item.launchRequest?.isLaunchable == true
          ? item.launchRequest
          : null,
      detail: detail,
      actionLine: actionLine,
    );
  }

  @override
  String toString() {
    return 'Act0PracticeRepairQueueItemViewModelV1('
        'itemId: $itemId, title: $title, isPinned: $isPinned, '
        'isLaunchable: $isLaunchable, detail: $detail, '
        'actionLine: $actionLine)';
  }
}

String? _safeText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final lower = trimmed.toLowerCase();
  for (final forbidden in _forbiddenCopyFragmentsV1) {
    if (lower.contains(forbidden)) {
      return null;
    }
  }
  if (trimmed.contains('_')) {
    return null;
  }
  return trimmed;
}

const _forbiddenCopyFragmentsV1 = <String>[
  'fixed',
  'cleared',
  'resolved',
  'completed',
  'leak',
  'mastery',
  'mastered',
  'gto',
  'solver',
  'premium',
  'paywall',
];
