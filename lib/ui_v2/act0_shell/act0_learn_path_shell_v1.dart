import 'dart:async' show Completer, Timer, unawaited;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String _learnCopyV1(
  BuildContext context, {
  required String en,
  required String ru,
}) => _isRuLocaleV1(context) ? ru : en;

({Color accent, Color accentSoft}) _learnWorldToneV1(int worldNumber) {
  return switch (worldNumber) {
    <= 2 => (
      accent: const Color(0xFF43C8A6),
      accentSoft: const Color(0xFF1A3B33),
    ),
    <= 4 => (
      accent: const Color(0xFF4EA3F8),
      accentSoft: const Color(0xFF182C44),
    ),
    <= 6 => (
      accent: const Color(0xFF7D8CFF),
      accentSoft: const Color(0xFF242D56),
    ),
    <= 8 => (
      accent: const Color(0xFFF7B83E),
      accentSoft: const Color(0xFF3F2D12),
    ),
    <= 10 => (
      accent: const Color(0xFFFF8A5B),
      accentSoft: const Color(0xFF4A261B),
    ),
    _ => (accent: const Color(0xFFE76FB3), accentSoft: const Color(0xFF44233D)),
  };
}

Act0WorldCardV1? _nextWorldAfterV1(
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 currentWorld,
) {
  for (final world in worlds) {
    if (world.worldNumber == currentWorld.worldNumber + 1) {
      return world;
    }
  }
  return null;
}

bool _isImmediateNextWorldV1(
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 world,
) {
  if (world.status != Act0WorldStateV1.locked) {
    return false;
  }
  final currentWorld = worlds.firstWhere(
    (entry) => entry.status == Act0WorldStateV1.current,
    orElse: () => worlds.first,
  );
  return world.worldNumber == currentWorld.worldNumber + 1;
}

String _worldRouteStatusLabelV1(
  BuildContext context,
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 world,
) {
  return switch (world.status) {
    Act0WorldStateV1.completed => _learnCopyV1(
      context,
      en: 'Cleared',
      ru: 'Пройден',
    ),
    Act0WorldStateV1.current => _learnCopyV1(
      context,
      en: 'Active',
      ru: 'Активен',
    ),
    Act0WorldStateV1.locked =>
      _isImmediateNextWorldV1(worlds, world)
          ? _learnCopyV1(context, en: 'Next', ru: 'Дальше')
          : _learnCopyV1(context, en: 'Locked', ru: 'Закрыт'),
  };
}

Color _worldRouteStatusColorV1(
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 world,
) {
  return switch (world.status) {
    Act0WorldStateV1.completed => Act0ShellTokensV1.primary,
    Act0WorldStateV1.current => Act0ShellTokensV1.primary,
    Act0WorldStateV1.locked =>
      _isImmediateNextWorldV1(worlds, world)
          ? Act0ShellTokensV1.gold
          : Act0ShellTokensV1.textDim,
  };
}

String _progressionUnlockLineShortV1(
  BuildContext context,
  String prerequisiteTitle,
) {
  return _learnCopyV1(
    context,
    en: 'Finish $prerequisiteTitle to open.',
    ru: 'Заверши $prerequisiteTitle, чтобы открыть.',
  );
}

Act0WorldCardV1? _worldBeforeV1(
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 world,
) {
  for (final entry in worlds) {
    if (entry.worldNumber == world.worldNumber - 1) {
      return entry;
    }
  }
  return null;
}

bool _isProgressionLockedWorldV1(
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 world,
) {
  return world.isLocked && _isImmediateNextWorldV1(worlds, world);
}

String _volumeSummaryLabelV1({
  required BuildContext context,
  required int volumeNumber,
  required String subtitle,
}) {
  return _learnCopyV1(
    context,
    en: 'Volume $volumeNumber · $subtitle',
    ru: 'Том $volumeNumber · $subtitle',
  );
}

class _VolumePillModelV1 {
  const _VolumePillModelV1({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.stateLabel,
    required this.color,
    this.unlockAfterLabel,
    this.previewLine,
  });

  final String id;
  final String label;
  final String subtitle;
  final String stateLabel;
  final Color color;
  final String? unlockAfterLabel;
  final String? previewLine;
}

class Act0LearnPathShellV1 extends StatefulWidget {
  const Act0LearnPathShellV1({
    super.key,
    required this.moduleTitle,
    required this.moduleProgressLabel,
    this.sharkyGuideTitle,
    this.sharkyGuideLine,
    this.sharkyGuideDetail,
    this.sharkyGuideMood = Act0SharkyMoodV1.thinking,
    required this.worlds,
    required this.selectedWorldId,
    required this.showWorldMenu,
    required this.worldDetailId,
    required this.lessons,
    required this.selectedLessonId,
    required this.selectedTaskId,
    required this.activePopupTaskId,
    required this.completedTaskIds,
    required this.perfectTaskIds,
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    required this.detailLessonId,
    required this.lessonOutcomeLabels,
    required this.onSelectWorld,
    required this.onOpenWorldMenu,
    required this.onCloseWorldMenu,
    required this.onDismissWorldDetail,
    required this.onPreviewPremiumWorld,
    required this.onSelectLesson,
    required this.onOpenLessonAfterScroll,
    required this.onDismissDetail,
    required this.onSelectTask,
    required this.onDismissTaskPopup,
    required this.onStartTask,
  });

  final String moduleTitle;
  final String moduleProgressLabel;
  final String? sharkyGuideTitle;
  final String? sharkyGuideLine;
  final String? sharkyGuideDetail;
  final Act0SharkyMoodV1 sharkyGuideMood;
  final List<Act0WorldCardV1> worlds;
  final String selectedWorldId;
  final bool showWorldMenu;
  final String? worldDetailId;
  final List<Act0LessonCardV1> lessons;
  final String selectedLessonId;
  final String selectedTaskId;
  final String? activePopupTaskId;
  final Set<String> completedTaskIds;
  final Set<String> perfectTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final String? detailLessonId;
  final Map<String, String> lessonOutcomeLabels;
  final ValueChanged<String> onSelectWorld;
  final VoidCallback onOpenWorldMenu;
  final VoidCallback onCloseWorldMenu;
  final VoidCallback onDismissWorldDetail;
  final ValueChanged<Act0WorldCardV1> onPreviewPremiumWorld;
  final bool Function(String lessonId) onSelectLesson;
  final ValueChanged<String> onOpenLessonAfterScroll;
  final VoidCallback onDismissDetail;
  final void Function(String lessonId, String taskId) onSelectTask;
  final VoidCallback onDismissTaskPopup;
  final void Function(String lessonId, String taskId) onStartTask;

  @override
  State<Act0LearnPathShellV1> createState() => _Act0LearnPathShellV1State();
}

class _Act0LearnPathShellV1State extends State<Act0LearnPathShellV1> {
  static const bool _useCenteredLearnSpineLayoutV1 = true;
  static const Duration _inlineLessonHubExpandDurationV1 = Duration(
    milliseconds: 660,
  );
  static const Duration _inlineLessonHubCollapseDurationV1 = Duration(
    milliseconds: 420,
  );
  static const double _lessonTopGapUnderHeaderV1 = 2.0;
  static const double _learnPathCardWidthFactorV1 = 0.94;
  static const double _inlineLessonHubWidthFactorV1 = 0.94;
  static const double _levelsWorldNodeWidthFactorV1 = 0.76;
  static const double _tailPhantomSpacerHeightV1 = 320;
  static const String _lessonTapRegionGroupIdV1 = 'act0_learn_lesson_zone';
  final Map<String, GlobalKey> _lessonKeys = <String, GlobalKey>{};
  final Map<String, GlobalKey> _taskDetailKeys = <String, GlobalKey>{};
  final Map<String, LayerLink> _taskLinks = <String, LayerLink>{};
  final GlobalKey _learnStackKey = GlobalKey();
  final GlobalKey _pinnedModuleHeaderKey = GlobalKey();
  final GlobalKey _selectedLessonPanelKey = GlobalKey();
  final ScrollController _learnScrollController = ScrollController();
  final Set<Timer> _pendingTimersV1 = <Timer>{};
  int _scrollEpochV1 = 0;

  @override
  void didUpdateWidget(covariant Act0LearnPathShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWorldId != oldWidget.selectedWorldId) {
      _scrollToTopOnWorldSwitchV1();
    }
    if (widget.detailLessonId != null &&
        widget.activePopupTaskId != null &&
        (widget.detailLessonId != oldWidget.detailLessonId ||
            widget.activePopupTaskId != oldWidget.activePopupTaskId)) {
      unawaited(
        _scrollSelectedTaskDetailIntoComfortV1(
          widget.detailLessonId!,
          widget.activePopupTaskId!,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _pendingTimersV1) {
      timer.cancel();
    }
    _pendingTimersV1.clear();
    _learnScrollController.dispose();
    super.dispose();
  }

  Future<void> _waitWithCancelV1(Duration duration) {
    if (duration == Duration.zero) {
      return Future<void>.value();
    }
    final completer = Completer<void>();
    late final Timer timer;
    timer = Timer(duration, () {
      _pendingTimersV1.remove(timer);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    _pendingTimersV1.add(timer);
    return completer.future;
  }

  void _scrollToTopOnWorldSwitchV1() {
    final epoch = ++_scrollEpochV1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (epoch != _scrollEpochV1) {
        return;
      }
      if (widget.detailLessonId != null) {
        return;
      }
      if (!mounted || !_learnScrollController.hasClients) {
        return;
      }
      final top = _learnScrollController.position.minScrollExtent;
      _learnScrollController.animateTo(
        top,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleLessonOpenedV1(String newLessonId, {required String? from}) {
    final epoch = ++_scrollEpochV1;
    unawaited(() async {
      if (from != null) {
        await _waitForLearnLayoutSettleV1(frames: 2);
        await _waitWithCancelV1(
          _inlineLessonHubCollapseDurationV1 + const Duration(milliseconds: 60),
        );
      }
      if (epoch != _scrollEpochV1 || !mounted) {
        return;
      }
      await _waitForLearnLayoutSettleV1(frames: 2);
      if (epoch != _scrollEpochV1 || !mounted) {
        return;
      }
      await _scrollLessonHeaderToTopV1(
        newLessonId,
        settleFrames: 2,
        maxDurationMs: 760,
        maxAttempts: from == null ? 1 : 2,
      );
      if (epoch != _scrollEpochV1 || !mounted) {
        return;
      }
      widget.onOpenLessonAfterScroll(newLessonId);
    }());
  }

  Future<void> _waitForLearnLayoutSettleV1({int frames = 2}) async {
    for (var i = 0; i < frames; i++) {
      WidgetsBinding.instance.scheduleFrame();
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
    }
  }

  Future<void> _scrollLessonHeaderToTopV1(
    String lessonId, {
    int settleFrames = 2,
    int maxDurationMs = 460,
    int maxAttempts = 1,
  }) async {
    if (!_learnScrollController.hasClients) {
      return;
    }
    await _waitForLearnLayoutSettleV1(frames: settleFrames);
    if (!mounted || !_learnScrollController.hasClients) {
      return;
    }
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final target = _computeLessonTargetOffsetV1(lessonId);
      if (target == null) {
        return;
      }
      final delta = (target - _learnScrollController.offset).abs();
      if (delta < 0.75) {
        return;
      }
      final durationCap = attempt == 0 ? maxDurationMs : 240;
      final durationMs = (160 + (delta * 0.2)).clamp(140, durationCap).round();
      await _learnScrollController.animateTo(
        target,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.easeOutCubic,
      );
      if (attempt == maxAttempts - 1) {
        return;
      }
      await _waitForLearnLayoutSettleV1(frames: 1);
      if (!mounted || !_learnScrollController.hasClients) {
        return;
      }
    }
  }

  double? _computeLessonTargetOffsetV1(String lessonId) {
    // Use anchored calculation first (works for lessons 1-5).
    final anchoredTarget = _computeLessonTargetOffsetAnchoredV1(lessonId);
    if (anchoredTarget != null) {
      return anchoredTarget;
    }
    // Fallback for lessons 6-8: calculate scroll to position lesson below pinned header.
    // Use a simpler approach that always works.
    if (!_learnScrollController.hasClients) {
      return null;
    }
    final lessonContext = _lessonKeys[lessonId]?.currentContext;
    if (lessonContext == null) {
      return null;
    }
    final lessonRenderObject = lessonContext.findRenderObject();
    if (lessonRenderObject is! RenderBox) {
      return null;
    }
    // Get lesson position relative to the CustomScrollView.
    final anchorBox = _learnStackKey.currentContext?.findRenderObject();
    if (anchorBox is! RenderBox) {
      return null;
    }
    // Calculate current lesson position in global coordinates.
    try {
      final lessonTopGlobal = lessonRenderObject.localToGlobal(Offset.zero).dy;
      final anchorTopGlobal = anchorBox.localToGlobal(Offset.zero).dy;
      final relativeTop = lessonTopGlobal - anchorTopGlobal;

      // Header takes up extentV1 pixels at the top.
      final targetOffset =
          relativeTop -
          _PinnedModuleHeaderDelegateV1.extentV1 -
          _lessonTopGapUnderHeaderV1;

      final currentOffset = _learnScrollController.offset;
      final delta = targetOffset - currentOffset;

      return (currentOffset + delta).clamp(
        _learnScrollController.position.minScrollExtent,
        _learnScrollController.position.maxScrollExtent,
      );
    } catch (e) {
      // If coordinate calculation fails, use viewport reveal as last resort.
      final viewport = RenderAbstractViewport.maybeOf(lessonRenderObject);
      if (viewport == null) {
        return null;
      }
      final topInset =
          (_PinnedModuleHeaderDelegateV1.extentV1 + _lessonTopGapUnderHeaderV1)
              .clamp(0.0, 9999.0);
      final revealOffset = viewport
          .getOffsetToReveal(lessonRenderObject, 0.0)
          .offset;
      return (revealOffset - topInset).clamp(
        _learnScrollController.position.minScrollExtent,
        _learnScrollController.position.maxScrollExtent,
      );
    }
  }

  double? _computeLessonTargetOffsetAnchoredV1(String lessonId) {
    if (!_learnScrollController.hasClients) {
      return null;
    }
    final anchorBox = _learnStackKey.currentContext?.findRenderObject();
    final lessonBox = _lessonKeys[lessonId]?.currentContext?.findRenderObject();
    final headerBox = _pinnedModuleHeaderKey.currentContext?.findRenderObject();
    if (anchorBox is! RenderBox ||
        lessonBox is! RenderBox ||
        headerBox is! RenderBox) {
      return null;
    }
    final lessonTop = lessonBox
        .localToGlobal(Offset.zero, ancestor: anchorBox)
        .dy;
    final headerTop = headerBox
        .localToGlobal(Offset.zero, ancestor: anchorBox)
        .dy;
    final desiredLessonTop =
        headerTop +
        _PinnedModuleHeaderDelegateV1.extentV1 +
        _lessonTopGapUnderHeaderV1;
    final requiredDelta = lessonTop - desiredLessonTop;
    return (_learnScrollController.offset + requiredDelta).clamp(
      _learnScrollController.position.minScrollExtent,
      _learnScrollController.position.maxScrollExtent,
    );
  }

  double? _computeExpandedLessonTargetOffsetV1(String lessonId) {
    // For expanded lessons, use anchored approach to position correctly.
    return _computeLessonTargetOffsetAnchoredV1(lessonId);
  }

  Future<void> _scrollExpandedLessonPanelIntoViewV1(String lessonId) async {
    if (!_learnScrollController.hasClients) {
      return;
    }
    await _waitForLearnLayoutSettleV1(frames: 1);
    if (!mounted || !_learnScrollController.hasClients) {
      return;
    }
    final anchorBox = _learnStackKey.currentContext?.findRenderObject();
    final panelBox = _selectedLessonPanelKey.currentContext?.findRenderObject();
    final lessonBox = _lessonKeys[lessonId]?.currentContext?.findRenderObject();
    if (anchorBox is! RenderBox ||
        panelBox is! RenderBox ||
        lessonBox is! RenderBox) {
      return;
    }
    final lessonTop = lessonBox
        .localToGlobal(Offset.zero, ancestor: anchorBox)
        .dy;
    final panelBottom = panelBox
        .localToGlobal(Offset(0, panelBox.size.height), ancestor: anchorBox)
        .dy;
    const minLessonTop = 45.0;
    final viewportBottom =
        anchorBox.size.height -
        Act0ShellTokensV1.bottomNavHeight -
        Act0ShellTokensV1.gapLg;
    final overflow = panelBottom - viewportBottom;
    // Keep the validated "scroll first, then open" contract dominant.
    // Only run a second pass when the expanded panel is materially clipped.
    if (overflow <= 12) {
      return;
    }
    final extraScroll = (overflow + 8).clamp(
      0.0,
      (lessonTop - minLessonTop).clamp(0.0, overflow + 8),
    );
    if (extraScroll <= 0) {
      return;
    }
    final target = (_learnScrollController.offset + extraScroll).clamp(
      _learnScrollController.position.minScrollExtent,
      _learnScrollController.position.maxScrollExtent,
    );
    final delta = (target - _learnScrollController.offset).abs();
    if (delta < 0.75) {
      return;
    }
    final durationMs = (140 + (delta * 0.18)).clamp(140, 320).round();
    await _learnScrollController.animateTo(
      target,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _scrollSelectedTaskDetailIntoComfortV1(
    String lessonId,
    String taskId,
  ) async {
    final epoch = _scrollEpochV1;
    if (!_learnScrollController.hasClients) {
      return;
    }
    await _waitForLearnLayoutSettleV1(frames: 2);
    if (!mounted ||
        !_learnScrollController.hasClients ||
        epoch != _scrollEpochV1 ||
        widget.detailLessonId != lessonId ||
        widget.activePopupTaskId != taskId) {
      return;
    }
    final anchorBox = _learnStackKey.currentContext?.findRenderObject();
    final detailBox = _taskDetailKeys['$lessonId::$taskId']?.currentContext
        ?.findRenderObject();
    if (anchorBox is! RenderBox || detailBox is! RenderBox) {
      await _scrollExpandedLessonPanelIntoViewV1(lessonId);
      return;
    }
    final detailTop = detailBox
        .localToGlobal(Offset.zero, ancestor: anchorBox)
        .dy;
    final detailBottom = detailBox
        .localToGlobal(Offset(0, detailBox.size.height), ancestor: anchorBox)
        .dy;
    const comfortableTop = 124.0;
    final comfortableBottom =
        anchorBox.size.height -
        Act0ShellTokensV1.bottomNavHeight -
        Act0ShellTokensV1.gapLg -
        28;
    double delta = 0;
    if (detailBottom > comfortableBottom) {
      delta = detailBottom - comfortableBottom;
    } else if (detailTop < comfortableTop) {
      delta = detailTop - comfortableTop;
    }
    if (delta.abs() < 6) {
      return;
    }
    final target = (_learnScrollController.offset + delta).clamp(
      _learnScrollController.position.minScrollExtent,
      _learnScrollController.position.maxScrollExtent,
    );
    final distance = (target - _learnScrollController.offset).abs();
    if (distance < 0.75) {
      return;
    }
    final durationMs = (150 + (distance * 0.16)).clamp(150, 320).round();
    if (epoch != _scrollEpochV1 ||
        widget.detailLessonId != lessonId ||
        widget.activePopupTaskId != taskId) {
      return;
    }
    await _learnScrollController.animateTo(
      target,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
    );
  }

  String? _routeBlockerTaskTitleV1(BuildContext context) {
    Act0LessonCardV1? routeLesson;
    for (final lesson in widget.lessons) {
      if (lesson.state == Act0LessonStateV1.current) {
        routeLesson = lesson;
        break;
      }
    }
    if (routeLesson == null) {
      for (final lesson in widget.lessons) {
        if (lesson.lessonId == widget.selectedLessonId) {
          routeLesson = lesson;
          break;
        }
      }
    }
    if (routeLesson == null) {
      for (final lesson in widget.lessons) {
        if (lesson.isSelectable) {
          routeLesson = lesson;
          break;
        }
      }
    }
    routeLesson ??= widget.lessons.isEmpty ? null : widget.lessons.first;
    if (routeLesson == null || routeLesson.taskList.isEmpty) {
      return null;
    }
    Act0LessonTaskV1? routeTask;
    for (final task in routeLesson.taskList) {
      if (task.taskId == widget.selectedTaskId) {
        routeTask = task;
        break;
      }
    }
    routeTask ??= routeLesson.taskList.first;
    return act0LocalizedTaskTitleV1(context, routeTask);
  }

  bool get _shouldShowSharkyGuideCardV1 {
    if (_resolvedSharkyGuideLineV1.isNotEmpty) {
      return true;
    }
    return (widget.sharkyGuideDetail ?? '').trim().isNotEmpty;
  }

  String get _resolvedSharkyGuideLineV1 {
    final explicitLine = (widget.sharkyGuideLine ?? '').trim();
    if (explicitLine.isNotEmpty) {
      return explicitLine;
    }
    if ((widget.sharkyGuideDetail ?? '').trim().isNotEmpty) {
      return 'Stay with the next clear step.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final detailLesson = widget.detailLessonId == null
        ? null
        : widget.lessons.cast<Act0LessonCardV1?>().firstWhere(
            (lesson) => lesson?.lessonId == widget.detailLessonId,
            orElse: () => null,
          );
    final detailWorld = widget.worldDetailId == null
        ? null
        : widget.worlds.firstWhere(
            (world) => world.worldId == widget.worldDetailId,
            orElse: () => widget.worlds.first,
          );
    final selectedWorld = widget.worlds.firstWhere(
      (world) => world.worldId == widget.selectedWorldId,
      orElse: () => widget.worlds.first,
    );
    final worldTone = _learnWorldToneV1(selectedWorld.worldNumber);
    return TapRegionSurface(
      child: Stack(
        key: _learnStackKey,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.depth != 0) {
                return false;
              }
              final isDirectionalScroll =
                  notification is UserScrollNotification &&
                  notification.direction != ScrollDirection.idle;
              final isDragUpdate =
                  notification is ScrollUpdateNotification &&
                  notification.dragDetails != null &&
                  (notification.scrollDelta ?? 0).abs() > 0;
              if (!isDirectionalScroll && !isDragUpdate) {
                return false;
              }
              if (widget.activePopupTaskId != null) {
                widget.onDismissTaskPopup();
              }
              return false;
            },
            child: CustomScrollView(
              controller: _learnScrollController,
              key: const Key('act0_shell_learn_screen'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Act0ShellTokensV1.pageX,
                    Act0ShellTokensV1.gapLg,
                    Act0ShellTokensV1.pageX,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Act0ShellTokensV1.centeredContent(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LearnHeroHeaderV1(
                            title: _learnCopyV1(
                              context,
                              en: 'Learn',
                              ru: 'Обучение',
                            ),
                            subtitle: _learnCopyV1(
                              context,
                              en: 'Move one chapter at a time.',
                              ru: 'Двигайся по главам шаг за шагом.',
                            ),
                            eyebrow: _learnCopyV1(
                              context,
                              en: 'Guided route',
                              ru: 'Маршрут',
                            ),
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedModuleHeaderDelegateV1(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Act0ShellTokensV1.pageX,
                        0,
                        Act0ShellTokensV1.pageX,
                        Act0ShellTokensV1.gapXs,
                      ),
                      child: Act0ShellTokensV1.centeredContent(
                        context,
                        child: KeyedSubtree(
                          key: _pinnedModuleHeaderKey,
                          child: _ModuleHeaderV1(
                            worldNumber: selectedWorld.worldNumber,
                            title: widget.moduleTitle,
                            subtitle: selectedWorld.subtitle,
                            progressLabel: widget.moduleProgressLabel,
                            lessonCount: widget.lessons.length,
                            progressFraction: widget.lessons.isEmpty
                                ? 0.0
                                : widget.lessons
                                          .where(
                                            (l) =>
                                                l.state ==
                                                Act0LessonStateV1.completed,
                                          )
                                          .length /
                                      widget.lessons.length,
                            onOpenWorldMenu: widget.onOpenWorldMenu,
                            onTap: widget.detailLessonId == null
                                ? null
                                : widget.onDismissDetail,
                            accent: worldTone.accent,
                            accentSoft: worldTone.accentSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Act0ShellTokensV1.pageX,
                    0,
                    Act0ShellTokensV1.pageX,
                    Act0ShellTokensV1.bottomNavHeight + 34,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Act0ShellTokensV1.centeredContent(
                      context,
                      child: Column(
                        children: [
                          for (var i = 0; i < widget.lessons.length; i++) ...[
                            KeyedSubtree(
                              key: _lessonKeys.putIfAbsent(
                                widget.lessons[i].lessonId,
                                GlobalKey.new,
                              ),
                              child: _LearnRouteSpineNodeV1(
                                index: i + 1,
                                lesson: widget.lessons[i],
                                isNextUp:
                                    i > 0 &&
                                    widget.lessons[i - 1].state ==
                                        Act0LessonStateV1.current &&
                                    widget.lessons[i].state ==
                                        Act0LessonStateV1.locked,
                                isLast: i == widget.lessons.length - 1,
                                worldAccent: worldTone.accent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: _useCenteredLearnSpineLayoutV1
                                          ? Alignment.center
                                          : (i.isEven
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight),
                                      child: TapRegion(
                                        groupId: _lessonTapRegionGroupIdV1,
                                        onTapOutside:
                                            widget.lessons[i].lessonId ==
                                                widget.detailLessonId
                                            ? (_) => widget.onDismissDetail()
                                            : null,
                                        child: FractionallySizedBox(
                                          widthFactor:
                                              _learnPathCardWidthFactorV1,
                                          child: _PathCardV1(
                                            index: i + 1,
                                            worldAccent: worldTone.accent,
                                            worldAccentSoft:
                                                worldTone.accentSoft,
                                            lesson: widget.lessons[i],
                                            selected:
                                                widget.lessons[i].lessonId ==
                                                widget.selectedLessonId,
                                            expanded:
                                                widget.lessons[i].lessonId ==
                                                widget.detailLessonId,
                                            completedTaskIds:
                                                widget.completedTaskIds,
                                            skippedTaskIds:
                                                widget.skippedTaskIds,
                                            pathClosedTaskIds:
                                                widget.pathClosedTaskIds,
                                            isNextUp:
                                                i > 0 &&
                                                widget.lessons[i - 1].state ==
                                                    Act0LessonStateV1.current &&
                                                widget.lessons[i].state ==
                                                    Act0LessonStateV1.locked,
                                            onSelectLesson: (lessonId) {
                                              final shouldOpenAfterScroll =
                                                  widget.onSelectLesson(
                                                    lessonId,
                                                  );
                                              if (shouldOpenAfterScroll) {
                                                _handleLessonOpenedV1(
                                                  lessonId,
                                                  from: widget.detailLessonId,
                                                );
                                              }
                                              return shouldOpenAfterScroll;
                                            },
                                            expandedBody:
                                                widget.lessons[i].lessonId ==
                                                    widget.detailLessonId
                                                ? _SelectedLessonPopupV1(
                                                    panelRenderKey:
                                                        _selectedLessonPanelKey,
                                                    lesson: widget.lessons[i],
                                                    selectedTaskId:
                                                        widget.selectedTaskId,
                                                    activePopupTaskId: widget
                                                        .activePopupTaskId,
                                                    completedTaskIds:
                                                        widget.completedTaskIds,
                                                    perfectTaskIds:
                                                        widget.perfectTaskIds,
                                                    skippedTaskIds:
                                                        widget.skippedTaskIds,
                                                    pathClosedTaskIds: widget
                                                        .pathClosedTaskIds,
                                                    completionOutcomeLabel:
                                                        widget
                                                            .lessonOutcomeLabels[widget
                                                            .lessons[i]
                                                            .lessonId],
                                                    routeBlockerTaskTitle:
                                                        _routeBlockerTaskTitleV1(
                                                          context,
                                                        ),
                                                    taskLinkForId: (taskId) =>
                                                        _taskLinks.putIfAbsent(
                                                          '${widget.lessons[i].lessonId}::$taskId',
                                                          LayerLink.new,
                                                        ),
                                                    taskDetailKeyForId:
                                                        (
                                                          taskId,
                                                        ) => _taskDetailKeys
                                                            .putIfAbsent(
                                                              '${widget.lessons[i].lessonId}::$taskId',
                                                              GlobalKey.new,
                                                            ),
                                                    onDismissTaskPopup: widget
                                                        .onDismissTaskPopup,
                                                    onSelectTask:
                                                        widget.onSelectTask,
                                                    onStartTask:
                                                        widget.onStartTask,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < widget.lessons.length - 1)
                              const SizedBox(height: Act0ShellTokensV1.gapXs),
                          ],
                          const SizedBox(
                            key: Key('act0_shell_learn_safe_bottom_spacer'),
                            height:
                                Act0ShellTokensV1.bottomNavHeight +
                                Act0ShellTokensV1.gapLg,
                          ),
                          SizedBox(
                            key: const Key(
                              'act0_shell_learn_tail_phantom_spacer',
                            ),
                            height: _tailPhantomSpacerHeightV1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showWorldMenu)
            Positioned.fill(
              child: _WorldMenuOverlayV1(
                worlds: widget.worlds,
                selectedWorldId: widget.selectedWorldId,
                detailWorld: detailWorld,
                onSelectWorld: widget.onSelectWorld,
                onClose: widget.onCloseWorldMenu,
                onDismissWorldDetail: widget.onDismissWorldDetail,
                onPreviewPremiumWorld: widget.onPreviewPremiumWorld,
              ),
            ),
        ],
      ),
    );
  }
}

class _WorldMenuOverlayV1 extends StatelessWidget {
  const _WorldMenuOverlayV1({
    required this.worlds,
    required this.selectedWorldId,
    required this.detailWorld,
    required this.onSelectWorld,
    required this.onClose,
    required this.onDismissWorldDetail,
    required this.onPreviewPremiumWorld,
  });

  final List<Act0WorldCardV1> worlds;
  final String selectedWorldId;
  final Act0WorldCardV1? detailWorld;
  final ValueChanged<String> onSelectWorld;
  final VoidCallback onClose;
  final VoidCallback onDismissWorldDetail;
  final ValueChanged<Act0WorldCardV1> onPreviewPremiumWorld;

  Future<void> _showLockedVolumePreviewV1(
    BuildContext context,
    _VolumePillModelV1 volume,
    Act0WorldCardV1 currentWorld,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.gapMd,
        ),
        child: _LockedVolumePreviewSheetV1(
          volume: volume,
          continueLabel: _learnCopyV1(
            context,
            en: 'Continue ${currentWorld.title}',
            ru: 'Продолжить ${currentWorld.title}',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWorld = worlds.firstWhere(
      (world) => world.worldId == selectedWorldId,
      orElse: () => worlds.first,
    );
    final currentWorld = worlds.firstWhere(
      (world) => world.status == Act0WorldStateV1.current,
      orElse: () => selectedWorld,
    );
    final currentStateColor = _worldRouteStatusColorV1(worlds, currentWorld);
    final nextWorld = _nextWorldAfterV1(worlds, currentWorld);
    final volumePills = <_VolumePillModelV1>[
      _VolumePillModelV1(
        id: 'volume_i',
        label: _learnCopyV1(context, en: 'Volume I', ru: 'Том I'),
        subtitle: _learnCopyV1(context, en: 'Foundations', ru: 'Основы'),
        stateLabel: _learnCopyV1(context, en: 'Active', ru: 'Активен'),
        color: Act0ShellTokensV1.primary,
      ),
      _VolumePillModelV1(
        id: 'volume_ii',
        label: _learnCopyV1(context, en: 'Volume II', ru: 'Том 2'),
        subtitle: _learnCopyV1(context, en: 'Strategy', ru: 'Стратегия'),
        stateLabel: _learnCopyV1(context, en: 'Locked', ru: 'Закрыт'),
        color: Act0ShellTokensV1.textDim,
        unlockAfterLabel: _learnCopyV1(
          context,
          en: 'Unlocks after Volume I.',
          ru: 'Откроется после Тома I.',
        ),
        previewLine: _learnCopyV1(
          context,
          en: 'Preview: position, preflop structure, bet purpose, and board reading.',
          ru: 'Внутри: позиция, префлоп-структура, цель ставки и чтение борда.',
        ),
      ),
      _VolumePillModelV1(
        id: 'volume_iii',
        label: _learnCopyV1(context, en: 'Volume III', ru: 'Том 3'),
        subtitle: _learnCopyV1(context, en: 'Mastery', ru: 'Мастерство'),
        stateLabel: _learnCopyV1(context, en: 'Locked', ru: 'Закрыт'),
        color: Act0ShellTokensV1.textDim,
        unlockAfterLabel: _learnCopyV1(
          context,
          en: 'Unlocks after Volume II.',
          ru: 'Откроется после Тома 2.',
        ),
        previewLine: _learnCopyV1(
          context,
          en: 'Preview: pressure spots, adjustments, and review loops.',
          ru: 'Внутри: споты давления, подстройки и циклы разбора.',
        ),
      ),
    ];
    return Stack(
      key: const Key('act0_shell_levels_menu'),
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              color: Act0ShellTokensV1.background.withValues(alpha: 0.96),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Act0ShellTokensV1.pageX,
            Act0ShellTokensV1.gapLg,
            Act0ShellTokensV1.pageX,
            Act0ShellTokensV1.gapSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Row(
                children: [
                  IconButton(
                    key: const Key('act0_shell_levels_menu_close'),
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Act0ShellTokensV1.text,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                      textAlign: TextAlign.center,
                      style: Act0ShellTokensV1.screenTitle,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  _learnCopyV1(
                    context,
                    en: '3 volumes · 36 worlds',
                    ru: '3 тома · 36 миров',
                  ),
                  style: Act0ShellTokensV1.muted.copyWith(fontSize: 11.0),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              SizedBox(
                key: const Key('act0_shell_volume_strip'),
                height: 56,
                child: Row(
                  children: [
                    for (var i = 0; i < volumePills.length; i++) ...[
                      Expanded(
                        child: _VolumePillV1(
                          volume: volumePills[i],
                          onTap: volumePills[i].id == 'volume_i'
                              ? null
                              : () => _showLockedVolumePreviewV1(
                                  context,
                                  volumePills[i],
                                  currentWorld,
                                ),
                        ),
                      ),
                      if (i < volumePills.length - 1)
                        const SizedBox(width: Act0ShellTokensV1.gapXs),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Container(
                key: const Key('act0_shell_levels_sticky_node_header'),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    currentStateColor.withValues(alpha: 0.08),
                    Act0ShellTokensV1.surface2,
                  ),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                  border: Border.all(
                    color: currentStateColor.withValues(alpha: 0.36),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: currentStateColor.withValues(alpha: 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _volumeSummaryLabelV1(
                        context: context,
                        volumeNumber: 1,
                        subtitle: _learnCopyV1(
                          context,
                          en: 'Foundations',
                          ru: 'Основы',
                        ),
                      ),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: currentStateColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'World ${currentWorld.worldNumber} of ${worlds.length} active',
                      key: const Key(
                        'act0_shell_levels_selected_world_status_line',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: currentStateColor.withValues(alpha: 0.90),
                        fontSize: 10.8,
                        letterSpacing: 0.36,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _learnCopyV1(
                        context,
                        en: 'Current: ${currentWorld.title}',
                        ru: 'Текущий: ${currentWorld.title}',
                      ),
                      key: const Key(
                        'act0_shell_levels_selected_world_current_line',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (nextWorld != null) ...[
                      Text(
                        _learnCopyV1(
                          context,
                          en: 'Next: ${nextWorld.title}',
                          ru: 'Дальше: ${nextWorld.title}',
                        ),
                        key: const Key(
                          'act0_shell_levels_selected_world_next_landmark',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                    bottom: Act0ShellTokensV1.bottomNavHeight + 44,
                  ),
                  children: [
                    for (var i = 0; i < worlds.length; i++) ...[
                      _WorldNodeV1(
                        world: worlds[i],
                        worlds: worlds,
                        selected: worlds[i].worldId == selectedWorldId,
                        onSelectWorld: onSelectWorld,
                      ),
                      if (i < worlds.length - 1)
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (detailWorld != null) ...[
          Positioned.fill(
            child: ModalBarrier(
              key: const Key('act0_shell_world_popup_scrim'),
              color: Colors.black.withValues(alpha: 0.18),
              dismissible: true,
              onDismiss: onDismissWorldDetail,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.gapMd,
              ),
              child: GestureDetector(
                onTap: () {},
                child: _SelectedWorldPopupV1(
                  world: detailWorld!,
                  worlds: worlds,
                  currentWorld: currentWorld,
                  onContinueCurrentWorld: () =>
                      onSelectWorld(currentWorld.worldId),
                  onPreviewPremiumWorld: onPreviewPremiumWorld,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LearnHeroHeaderV1 extends StatelessWidget {
  const _LearnHeroHeaderV1({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
  });

  final String title;
  final String subtitle;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.primary.withValues(alpha: 0.10),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.primary.withValues(alpha: 0.08),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.info.withValues(alpha: 0.03),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Act0ShellTokensV1.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Text(
              eyebrow,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.primary,
                letterSpacing: 0.20,
                fontSize: 10.0,
              ),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Text(
            title.toUpperCase(),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: 10.4,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.22,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumePillV1 extends StatelessWidget {
  const _VolumePillV1({required this.volume, this.onTap});

  final _VolumePillModelV1 volume;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = volume.id == 'volume_i';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('act0_shell_${volume.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              volume.color.withValues(alpha: active ? 0.10 : 0.05),
              Act0ShellTokensV1.surface2,
            ),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            border: Border.all(
              color: volume.color.withValues(alpha: active ? 0.22 : 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                volume.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Act0ShellTokensV1.label.copyWith(
                  color: volume.color,
                  letterSpacing: 0.18,
                  fontSize: 8.5,
                ),
              ),
              Text(
                volume.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: 9.6,
                  height: 1.0,
                  color: active
                      ? Act0ShellTokensV1.textMuted
                      : Act0ShellTokensV1.textDim,
                ),
              ),
              Text(
                volume.stateLabel,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Act0ShellTokensV1.label.copyWith(
                  color: volume.color,
                  fontSize: 8.6,
                  letterSpacing: 0.08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedVolumePreviewSheetV1 extends StatelessWidget {
  const _LockedVolumePreviewSheetV1({
    required this.volume,
    required this.continueLabel,
  });

  final _VolumePillModelV1 volume;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_${volume.id}_preview_panel'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration:
          Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2,
            borderColor: Act0ShellTokensV1.textDim.withValues(alpha: 0.36),
          ).copyWith(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StateBadgeV1(
            label: volume.stateLabel,
            color: Act0ShellTokensV1.textDim,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(volume.label, style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(volume.subtitle, style: Act0ShellTokensV1.body),
          if ((volume.unlockAfterLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Text(
              volume.unlockAfterLabel!,
              key: Key('act0_shell_${volume.id}_unlock_label'),
              style: Act0ShellTokensV1.body,
            ),
          ],
          if ((volume.previewLine ?? '').isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              volume.previewLine!,
              key: Key('act0_shell_${volume.id}_preview_line'),
              style: Act0ShellTokensV1.muted,
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          OutlinedButton(
            key: Key('act0_shell_${volume.id}_continue_current_cta'),
            onPressed: () => Navigator.of(context).pop(),
            style: Act0ShellTokensV1.quietButtonStyle(height: 40),
            child: Text(continueLabel),
          ),
        ],
      ),
    );
  }
}

class _WorldNodeV1 extends StatefulWidget {
  const _WorldNodeV1({
    required this.world,
    required this.worlds,
    required this.selected,
    required this.onSelectWorld,
  });

  final Act0WorldCardV1 world;
  final List<Act0WorldCardV1> worlds;
  final bool selected;
  final ValueChanged<String> onSelectWorld;

  @override
  State<_WorldNodeV1> createState() => _WorldNodeV1State();
}

class _WorldNodeV1State extends State<_WorldNodeV1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_WorldNodeV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected ||
        oldWidget.world.status != widget.world.status) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _worldRouteStatusColorV1(widget.worlds, widget.world);
    final statusLabel = _worldRouteStatusLabelV1(
      context,
      widget.worlds,
      widget.world,
    );
    final locked = widget.world.isLocked;
    final completed = widget.world.status == Act0WorldStateV1.completed;
    final active = widget.world.status == Act0WorldStateV1.current;
    final nextWorld = _isImmediateNextWorldV1(widget.worlds, widget.world);
    final nodeRadius = Act0ShellTokensV1.radiusBase;
    final targetScaleFactor = widget.selected ? 1.01 : 1.0;
    final subtitle = act0LocalizedWorldSubtitleV1(context, widget.world);
    final previousWorld = _worldBeforeV1(widget.worlds, widget.world);
    final detailText = switch (widget.world.status) {
      Act0WorldStateV1.completed => widget.world.progressLabel,
      Act0WorldStateV1.current => widget.world.progressLabel,
      Act0WorldStateV1.locked =>
        nextWorld && previousWorld != null
            ? _progressionUnlockLineShortV1(context, previousWorld.title)
            : '',
    };
    final targetBorderColor = widget.selected
        ? color.withValues(alpha: 0.40)
        : locked
        ? color.withValues(alpha: nextWorld ? 0.30 : 0.18)
        : color.withValues(alpha: 0.24);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = CurvedAnimation(
          parent: _controller,
          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
        ).value;

        final scaleFactor = 1 + (targetScaleFactor - 1) * t;

        return Container(
          clipBehavior: Clip.none,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('act0_shell_world_${widget.world.worldNumber}'),
              borderRadius: BorderRadius.circular(nodeRadius),
              onTap: () => widget.onSelectWorld(widget.world.worldId),
              child: Transform.scale(
                scale: scaleFactor,
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? Color.alphaBlend(
                            color.withValues(alpha: active ? 0.12 : 0.08),
                            Act0ShellTokensV1.surface2,
                          )
                        : Act0ShellTokensV1.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(nodeRadius),
                    border: Border.all(color: targetBorderColor, width: 1.0),
                    boxShadow: <BoxShadow>[
                      if (widget.selected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.18 * t),
                          blurRadius: 14,
                          spreadRadius: 1.0,
                          offset: Offset.zero,
                        ),
                      if (active || widget.selected || nextWorld)
                        BoxShadow(
                          color: color.withValues(alpha: 0.10 * t),
                          blurRadius: 9 * t,
                          spreadRadius: 0.5 * t,
                          offset: Offset(0, 2 * t),
                        )
                      else if (completed)
                        BoxShadow(
                          color: color.withValues(alpha: 0.08 * t),
                          blurRadius: 6 * t,
                          offset: Offset(0, 1 * t),
                        ),
                      // locked: no shadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: completed
                              ? color
                              : color.withValues(
                                  alpha: locked
                                      ? (nextWorld ? 0.14 : 0.10)
                                      : 0.16,
                                ),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusCard,
                          ),
                          border: Border.all(
                            color: color.withValues(
                              alpha: locked ? (nextWorld ? 0.58 : 0.30) : 0.82,
                            ),
                            width: active ? 2.0 : 1.4,
                          ),
                        ),
                        child: completed
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: active ? 22 : 20,
                              )
                            : Text(
                                '${widget.world.worldNumber}',
                                style: TextStyle(
                                  color: locked && !nextWorld
                                      ? Act0ShellTokensV1.textMuted
                                      : Act0ShellTokensV1.text,
                                  fontSize: active ? 16 : 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'World ${widget.world.worldNumber}',
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: color,
                                      letterSpacing: 0.42,
                                    ),
                                  ),
                                ),
                                _StateBadgeV1(label: statusLabel, color: color),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act0LocalizedWorldTitleV1(context, widget.world),
                              style: Act0ShellTokensV1.cardTitle.copyWith(
                                color: locked && !nextWorld
                                    ? Act0ShellTokensV1.textMuted
                                    : Act0ShellTokensV1.text,
                                fontSize: widget.selected ? 14.2 : 13.8,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: Act0ShellTokensV1.muted.copyWith(
                                color: locked && !nextWorld
                                    ? Act0ShellTokensV1.textDim
                                    : Act0ShellTokensV1.textMuted,
                                fontSize: 11.2,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (detailText.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                detailText,
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: color.withValues(
                                    alpha: locked ? 0.92 : 0.88,
                                  ),
                                  fontSize: 10.2,
                                  letterSpacing: 0.28,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ), // closes Transform.scale
            ), // closes InkWell
          ), // closes Material
        ); // closes Container
      },
    );
  }
}

class _SelectedWorldPopupV1 extends StatelessWidget {
  const _SelectedWorldPopupV1({
    required this.world,
    required this.worlds,
    required this.currentWorld,
    required this.onContinueCurrentWorld,
    required this.onPreviewPremiumWorld,
  });

  final Act0WorldCardV1 world;
  final List<Act0WorldCardV1> worlds;
  final Act0WorldCardV1 currentWorld;
  final VoidCallback onContinueCurrentWorld;
  final ValueChanged<Act0WorldCardV1> onPreviewPremiumWorld;

  @override
  Widget build(BuildContext context) {
    final progressionLocked = _isProgressionLockedWorldV1(worlds, world);
    final color = progressionLocked
        ? Act0ShellTokensV1.gold
        : switch (world.status) {
            Act0WorldStateV1.completed => Act0ShellTokensV1.primary,
            Act0WorldStateV1.current => Act0ShellTokensV1.primary,
            Act0WorldStateV1.locked => Act0ShellTokensV1.textDim,
          };
    final worldTitle = act0LocalizedWorldTitleV1(context, world);
    final worldSubtitle = act0LocalizedWorldSubtitleV1(context, world);
    final stateLabel = switch (world.status) {
      Act0WorldStateV1.completed => _learnCopyV1(
        context,
        en: 'Cleared',
        ru: 'Пройден',
      ),
      Act0WorldStateV1.current => _learnCopyV1(
        context,
        en: 'Active',
        ru: 'Активен',
      ),
      Act0WorldStateV1.locked =>
        progressionLocked
            ? _learnCopyV1(context, en: 'Next', ru: 'Дальше')
            : _learnCopyV1(context, en: 'Locked', ru: 'Закрыт'),
    };
    return Container(
      key: const Key('act0_shell_selected_world_panel'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration:
          Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2,
            borderColor: color.withValues(alpha: 0.48),
          ).copyWith(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StateBadgeV1(label: stateLabel, color: color),
              if (!progressionLocked) ...[
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Text(
                  _learnCopyV1(
                    context,
                    en: 'Reward +${world.rewardXp} XP',
                    ru: 'Награда +${world.rewardXp} XP',
                  ),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.gold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(worldTitle, style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            progressionLocked
                ? _learnCopyV1(
                    context,
                    en: 'Finish ${currentWorld.title} to open this world.',
                    ru: 'Заверши ${currentWorld.title}, чтобы открыть этот мир.',
                  )
                : world.unlockLabel,
            key: const Key('act0_shell_world_unlock_label'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
          if (progressionLocked) ...[
            Text(worldSubtitle, style: Act0ShellTokensV1.muted),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            OutlinedButton(
              key: const Key('act0_shell_world_continue_current_cta'),
              onPressed: onContinueCurrentWorld,
              style: Act0ShellTokensV1.quietButtonStyle(height: 40),
              child: Text(
                _learnCopyV1(
                  context,
                  en: 'Continue ${currentWorld.title}',
                  ru: 'Продолжить ${currentWorld.title}',
                ),
              ),
            ),
          ] else if (world.isLocked) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Text(
              _learnCopyV1(context, en: 'Locked preview', ru: 'Предпросмотр'),
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.textMuted,
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              _learnCopyV1(
                context,
                en: 'This world opens later in the route. Stay on the current path first.',
                ru: 'Этот мир откроется позже по маршруту. Сначала держись текущего пути.',
              ),
              style: Act0ShellTokensV1.muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _LearnCoachLineV1 extends StatelessWidget {
  const _LearnCoachLineV1({
    required this.line,
    required this.detail,
    required this.mood,
  });

  final String line;
  final String? detail;
  final Act0SharkyMoodV1 mood;

  @override
  Widget build(BuildContext context) {
    final accent = switch (mood) {
      Act0SharkyMoodV1.repair => Act0ShellTokensV1.gold,
      Act0SharkyMoodV1.celebrate => Act0ShellTokensV1.primary,
      Act0SharkyMoodV1.happy => Act0ShellTokensV1.primary,
      Act0SharkyMoodV1.neutral => Act0ShellTokensV1.info,
      Act0SharkyMoodV1.thinking => Act0ShellTokensV1.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
            child: Icon(Icons.waves_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line,
                  style: Act0ShellTokensV1.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((detail ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail!, style: Act0ShellTokensV1.muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnRouteContractCardV1 extends StatelessWidget {
  const _LearnRouteContractCardV1({required this.line, required this.detail});

  final String line;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_learn_route_contract_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              size: 18,
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line,
                  key: const Key('act0_shell_learn_route_contract_line'),
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  detail,
                  key: const Key('act0_shell_learn_route_contract_detail'),
                  style: Act0ShellTokensV1.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedLessonPopupV1 extends StatelessWidget {
  const _SelectedLessonPopupV1({
    required this.panelRenderKey,
    required this.lesson,
    required this.selectedTaskId,
    required this.activePopupTaskId,
    required this.completedTaskIds,
    required this.perfectTaskIds,
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    this.completionOutcomeLabel,
    this.routeBlockerTaskTitle,
    required this.taskLinkForId,
    required this.taskDetailKeyForId,
    required this.onDismissTaskPopup,
    required this.onSelectTask,
    required this.onStartTask,
  });

  final Key panelRenderKey;
  final Act0LessonCardV1 lesson;
  final String selectedTaskId;
  final String? activePopupTaskId;
  final Set<String> completedTaskIds;
  final Set<String> perfectTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final String? completionOutcomeLabel;
  final String? routeBlockerTaskTitle;
  final LayerLink Function(String taskId) taskLinkForId;
  final GlobalKey Function(String taskId) taskDetailKeyForId;
  final VoidCallback onDismissTaskPopup;
  final void Function(String lessonId, String taskId) onSelectTask;
  final void Function(String lessonId, String taskId) onStartTask;

  @override
  Widget build(BuildContext context) {
    final compactPanel = MediaQuery.sizeOf(context).height < 940;
    final widePanel = MediaQuery.sizeOf(context).width >= 680;
    final stateColor = _stateColor(lesson.state);
    final locked = lesson.state == Act0LessonStateV1.locked;
    final panelAccent = locked
        ? Act0ShellTokensV1.textDim
        : Act0ShellTokensV1.primary;
    final tasks = lesson.taskList;
    final lessonSubtitle = act0LocalizedLessonSubtitleV1(context, lesson);
    final lessonSubtitleBlocks = act0BuildInstructionBlocksV1(
      text: lessonSubtitle,
      compact: compactPanel,
    );
    final nextTask = tasks.firstWhere(
      (task) => !pathClosedTaskIds.contains(task.taskId),
      orElse: () => tasks.first,
    );
    final guidanceCopy = locked
        ? _learnCopyV1(
            context,
            en: 'Opens when this route reaches it.',
            ru: 'Откроется, когда маршрут дойдёт сюда.',
          )
        : _learnCopyV1(
            context,
            en: 'Next: ${act0LocalizedTaskTitleV1(context, nextTask)}',
            ru: 'Дальше: ${act0LocalizedTaskTitleV1(context, nextTask)}',
          );
    final fallbackSelectedTaskId =
        tasks.any((task) => task.taskId == selectedTaskId)
        ? selectedTaskId
        : nextTask.taskId;

    return Container(
      key: const Key('act0_shell_selected_lesson_panel'),
      padding: EdgeInsets.fromLTRB(
        compactPanel ? 1 : 2,
        compactPanel ? 1 : 2,
        compactPanel ? 1 : 2,
        compactPanel ? 1 : 3,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: activePopupTaskId == null ? null : onDismissTaskPopup,
        child: Container(
          key: panelRenderKey,
          padding: EdgeInsets.fromLTRB(
            compactPanel ? 10 : 11,
            compactPanel ? 8 : 9,
            compactPanel ? 10 : 11,
            compactPanel ? 6 : 7,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.alphaBlend(
                  stateColor.withValues(alpha: 0.035),
                  Act0ShellTokensV1.surface2.withValues(alpha: 0.54),
                ),
                Act0ShellTokensV1.surface.withValues(alpha: 0.16),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lessonSubtitleBlocks.isNotEmpty) ...<Widget>[
                for (
                  var index = 0;
                  index < lessonSubtitleBlocks.length;
                  index++
                ) ...[
                  Text(
                    lessonSubtitleBlocks[index],
                    key: index == 0
                        ? const Key('act0_shell_selected_lesson_subtitle')
                        : Key(
                            'act0_shell_selected_lesson_subtitle_block_$index',
                          ),
                    maxLines: compactPanel ? 2 : 3,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.muted.copyWith(
                      height: compactPanel ? 1.14 : 1.22,
                    ),
                  ),
                  if (index != lessonSubtitleBlocks.length - 1)
                    const SizedBox(height: 2),
                ],
                SizedBox(height: compactPanel ? 3 : Act0ShellTokensV1.gapXs),
              ],
              Container(
                key: const Key('act0_shell_selected_lesson_guidance'),
                constraints: BoxConstraints(
                  maxWidth: widePanel ? 420 : double.infinity,
                ),
                child: Text(
                  guidanceCopy,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: panelAccent.withValues(alpha: 0.82),
                    letterSpacing: 0.04,
                    fontSize: compactPanel ? 10.1 : 10.4,
                    height: compactPanel ? 1.10 : 1.12,
                  ),
                ),
              ),
              SizedBox(height: compactPanel ? 3 : Act0ShellTokensV1.gapXs),
              Column(
                key: const Key('act0_shell_lesson_hub_steps'),
                children: [
                  for (var i = 0; i < tasks.length; i++) ...[
                    _LessonHubStepV1(
                      index: i + 1,
                      link: taskLinkForId(tasks[i].taskId),
                      lesson: lesson,
                      task: tasks[i],
                      isLast: i == tasks.length - 1,
                      isDone: completedTaskIds.contains(tasks[i].taskId),
                      isPerfect: perfectTaskIds.contains(tasks[i].taskId),
                      isSkipped: skippedTaskIds.contains(tasks[i].taskId),
                      isCurrent: tasks[i].taskId == nextTask.taskId,
                      isSelected: activePopupTaskId == null
                          ? tasks[i].taskId == fallbackSelectedTaskId
                          : tasks[i].taskId == activePopupTaskId,
                      showDetail: tasks[i].taskId == activePopupTaskId,
                      isLocked:
                          locked ||
                          (!pathClosedTaskIds.contains(tasks[i].taskId) &&
                              tasks[i].taskId != nextTask.taskId),
                      routeBlockerTaskTitle: routeBlockerTaskTitle,
                      detailKey: taskDetailKeyForId(tasks[i].taskId),
                      onSelectTask: onSelectTask,
                      onStartTask: onStartTask,
                    ),
                  ],
                ],
              ),
              if (completionOutcomeLabel != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  completionOutcomeLabel!,
                  key: const Key('act0_shell_selected_lesson_outcome'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: stateColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineLessonHubSlotV1 extends StatelessWidget {
  const _InlineLessonHubSlotV1({
    required this.visible,
    required this.alignment,
    required this.child,
  });

  final bool visible;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: alignment,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 920
              ? 760.0
              : constraints.maxWidth >= 640
              ? 700.0
              : double.infinity;
          return FractionallySizedBox(
            widthFactor:
                _Act0LearnPathShellV1State._inlineLessonHubWidthFactorV1,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 2,
                bottom: Act0ShellTokensV1.gapXs,
              ),
              child: KeyedSubtree(
                key: const ValueKey<String>('act0_inline_lesson_hub'),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LearnRouteSpineNodeV1 extends StatelessWidget {
  const _LearnRouteSpineNodeV1({
    required this.index,
    required this.lesson,
    required this.isNextUp,
    required this.isLast,
    required this.worldAccent,
    required this.child,
  });

  final int index;
  final Act0LessonCardV1 lesson;
  final bool isNextUp;
  final bool isLast;
  final Color worldAccent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final stateTone = switch (lesson.state) {
      Act0LessonStateV1.current => Act0ShellTokensV1.primary,
      Act0LessonStateV1.completed => worldAccent,
      Act0LessonStateV1.locked =>
        isNextUp ? Act0ShellTokensV1.gold : Act0ShellTokensV1.textDim,
    };
    final label = switch (lesson.state) {
      Act0LessonStateV1.current => '$index',
      Act0LessonStateV1.completed => '$index',
      Act0LessonStateV1.locked => '$index',
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 12,
          top: 0,
          bottom: isLast ? 12 : 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: stateTone.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 28), child: child),
        Positioned(
          left: 0,
          top: 14,
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                stateTone.withValues(alpha: 0.14),
                Act0ShellTokensV1.surface,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: stateTone.withValues(alpha: 0.60)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: stateTone.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: Act0ShellTokensV1.label.copyWith(
                color: stateTone,
                letterSpacing: 0,
                fontSize: 10.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonHubStepV1 extends StatefulWidget {
  const _LessonHubStepV1({
    required this.index,
    required this.link,
    required this.lesson,
    required this.task,
    required this.isLast,
    required this.isDone,
    required this.isPerfect,
    required this.isSkipped,
    required this.isCurrent,
    required this.isSelected,
    required this.showDetail,
    required this.isLocked,
    this.routeBlockerTaskTitle,
    required this.detailKey,
    required this.onSelectTask,
    required this.onStartTask,
  });

  final int index;
  final LayerLink link;
  final Act0LessonCardV1 lesson;
  final Act0LessonTaskV1 task;
  final bool isLast;
  final bool isDone;
  final bool isPerfect;
  final bool isSkipped;
  final bool isCurrent;
  final bool isSelected;
  final bool showDetail;
  final bool isLocked;
  final String? routeBlockerTaskTitle;
  final GlobalKey detailKey;
  final void Function(String lessonId, String taskId) onSelectTask;
  final void Function(String lessonId, String taskId) onStartTask;

  @override
  State<_LessonHubStepV1> createState() => _LessonHubStepV1State();
}

class _LessonHubStepV1State extends State<_LessonHubStepV1> {
  @override
  Widget build(BuildContext context) {
    final compactRow = MediaQuery.sizeOf(context).height < 940;
    final nextTask = widget.task;
    final completionState = act0ResolveTaskCompletionDisplayStateV1(
      taskId: widget.task.taskId,
      isLocked: widget.isLocked,
      isCurrent: widget.isCurrent,
      completedTaskIds: widget.isDone
          ? <String>{widget.task.taskId}
          : const <String>{},
      perfectTaskIds: widget.isPerfect
          ? <String>{widget.task.taskId}
          : const <String>{},
    );
    final color = switch (completionState) {
      Act0CompletionDisplayStateV1.perfect => Act0ShellTokensV1.primary,
      Act0CompletionDisplayStateV1.clear => Act0ShellTokensV1.primary,
      Act0CompletionDisplayStateV1.current =>
        widget.isSkipped ? Act0ShellTokensV1.gold : Act0ShellTokensV1.gold,
      Act0CompletionDisplayStateV1.locked => Act0ShellTokensV1.textDim,
    };
    final icon = widget.isSkipped
        ? Icons.fast_forward_rounded
        : switch (completionState) {
            Act0CompletionDisplayStateV1.locked => Icons.lock_rounded,
            Act0CompletionDisplayStateV1.clear => Icons.check_rounded,
            Act0CompletionDisplayStateV1.perfect => Icons.check_rounded,
            Act0CompletionDisplayStateV1.current => _stepIcon(
              widget.task.stepKind,
            ),
          };
    final statusLabel = switch (completionState) {
      Act0CompletionDisplayStateV1.current => 'Now',
      _ => null,
    };
    final rowAccent = widget.isSelected && !widget.isLocked
        ? Act0ShellTokensV1.primary
        : color;
    final showStatusChip = statusLabel != null && !widget.isLocked;
    final hasPerfectOpportunity = widget.isDone && !widget.isPerfect;
    final detailLine = _selectedTaskDetail(
      context: context,
      task: widget.task,
      nextTask: nextTask,
      routeBlockerTaskTitle: widget.routeBlockerTaskTitle,
      isDone: widget.isDone,
      isPerfect: widget.isPerfect,
      isSkipped: widget.isSkipped,
      isLocked: widget.isLocked,
    );
    final ctaText = widget.isLocked
        ? 'Later'
        : widget.isDone
        ? widget.isPerfect
              ? 'Review'
              : 'Replay'
        : widget.isSkipped
        ? 'Retry'
        : 'Start';
    final usePrimaryCta =
        !widget.isLocked && !widget.isDone && !widget.isSkipped;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactWidth = constraints.maxWidth < 352;
        final cardWidth = constraints.maxWidth < 320
            ? constraints.maxWidth - 30
            : (constraints.maxWidth * 0.925).clamp(252.0, 336.0);
        final centerLeft = (constraints.maxWidth - cardWidth) / 2;
        final cardLeft = centerLeft
            .clamp(0.0, constraints.maxWidth - cardWidth)
            .toDouble();
        final threadX = cardLeft + 27;
        final rowHeight = widget.isLocked
            ? (compactWidth
                  ? 62.0
                  : compactRow
                  ? 56.0
                  : 60.0)
            : compactWidth
            ? 67.0
            : compactRow
            ? 60.0
            : 66.0;
        final stackDetailVertically = compactWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: rowHeight,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  if (!widget.isLast)
                    Positioned(
                      left: threadX - 1.5,
                      top: 24,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: cardLeft,
                    top: 4,
                    child: CompositedTransformTarget(
                      link: widget.link,
                      child: Material(
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusXxl,
                        ),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.transparent,
                        child: InkWell(
                          key: Key(
                            'act0_shell_lesson_step_${widget.task.taskId}',
                          ),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusXxl,
                          ),
                          onTap: () => widget.onSelectTask(
                            widget.lesson.lessonId,
                            widget.task.taskId,
                          ),
                          child: Ink(
                            width: cardWidth,
                            height: widget.isLocked
                                ? (compactWidth
                                      ? 42
                                      : compactRow
                                      ? 38
                                      : 40)
                                : compactWidth
                                ? 47
                                : compactRow
                                ? 42
                                : 46,
                            padding: EdgeInsets.fromLTRB(
                              compactWidth ? 8 : 9,
                              compactRow ? 4 : 5,
                              compactWidth ? 9 : 10,
                              compactRow ? 4 : 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isSelected
                                    ? <Color>[
                                        rowAccent.withValues(alpha: 0.10),
                                        Act0ShellTokensV1.surface2.withValues(
                                          alpha: 0.96,
                                        ),
                                      ]
                                    : <Color>[
                                        Act0ShellTokensV1.learnPathTaskSurface,
                                        Act0ShellTokensV1.surface.withValues(
                                          alpha: 0.90,
                                        ),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusXl,
                              ),
                              border: Border.all(
                                color: widget.isSelected
                                    ? rowAccent.withValues(alpha: 0.34)
                                    : Act0ShellTokensV1.border.withValues(
                                        alpha: widget.isLocked ? 0.22 : 0.34,
                                      ),
                              ),
                              boxShadow: <BoxShadow>[
                                if (widget.isSelected && !widget.isLocked)
                                  BoxShadow(
                                    color: rowAccent.withValues(alpha: 0.05),
                                    blurRadius: compactWidth ? 6 : 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: compactWidth
                                          ? 24
                                          : compactRow
                                          ? 26
                                          : 30,
                                      height: compactWidth
                                          ? 24
                                          : compactRow
                                          ? 26
                                          : 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: <Color>[
                                            rowAccent.withValues(
                                              alpha: widget.isDone ? 1 : 0.24,
                                            ),
                                            rowAccent.withValues(
                                              alpha: widget.isDone
                                                  ? 0.82
                                                  : 0.08,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: rowAccent.withValues(
                                            alpha: 0.46,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        size: compactWidth
                                            ? 12
                                            : compactRow
                                            ? 13
                                            : 14,
                                        color: widget.isDone
                                            ? Act0ShellTokensV1.onPrimary
                                            : rowAccent,
                                      ),
                                    ),
                                    if (widget.isPerfect)
                                      Positioned(
                                        right: -3,
                                        top: -3,
                                        child: Container(
                                          key: Key(
                                            'act0_shell_lesson_step_perfect_${widget.task.taskId}',
                                          ),
                                          width: 12,
                                          height: 12,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Act0ShellTokensV1.gold,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Act0ShellTokensV1.surface,
                                              width: 1.2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.star_rounded,
                                            size: 8,
                                            color: Act0ShellTokensV1.surface,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  width: compactWidth
                                      ? 6
                                      : compactRow
                                      ? 7
                                      : 8,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act0LocalizedTaskTitleV1(
                                          context,
                                          widget.task,
                                        ),
                                        key: Key(
                                          'act0_shell_lesson_step_title_${widget.task.taskId}',
                                        ),
                                        style: Act0ShellTokensV1.body.copyWith(
                                          color: widget.isLocked
                                              ? Act0ShellTokensV1.textMuted
                                              : Act0ShellTokensV1.text,
                                          fontWeight: FontWeight.w900,
                                          fontSize: compactWidth
                                              ? 12.0
                                              : compactRow
                                              ? 11.8
                                              : 12.2,
                                          height: 1.08,
                                        ),
                                        maxLines: compactWidth ? 3 : 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (showStatusChip) ...[
                                  SizedBox(
                                    width: compactWidth
                                        ? 2
                                        : compactRow
                                        ? 3
                                        : 4,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: compactWidth
                                          ? 5
                                          : compactRow
                                          ? 6
                                          : 7,
                                      vertical: compactWidth
                                          ? 2
                                          : compactRow
                                          ? 2
                                          : 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: rowAccent.withValues(
                                        alpha: widget.isSelected ? 0.12 : 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Act0ShellTokensV1.radiusPill,
                                      ),
                                      border: Border.all(
                                        color: rowAccent.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: Act0ShellTokensV1.label.copyWith(
                                        color: rowAccent,
                                        letterSpacing: 0.20,
                                        fontSize: compactWidth
                                            ? 7.1
                                            : compactRow
                                            ? 7.4
                                            : 7.8,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              reverseDuration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: widget.showDetail
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(
                        cardLeft,
                        compactRow ? 2 : 4,
                        constraints.maxWidth - cardLeft - cardWidth,
                        compactRow ? 6 : 8,
                      ),
                      child: KeyedSubtree(
                        key: widget.detailKey,
                        child: Container(
                          key: const Key(
                            'act0_shell_selected_lesson_task_focus',
                          ),
                          width: cardWidth,
                          padding: EdgeInsets.fromLTRB(
                            compactRow ? 9 : 10,
                            compactRow ? 7 : 8,
                            compactRow ? 9 : 10,
                            compactRow ? 7 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              rowAccent.withValues(alpha: 0.07),
                              Act0ShellTokensV1.surface2.withValues(
                                alpha: 0.96,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusMd,
                            ),
                            border: Border.all(
                              color: rowAccent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: stackDetailVertically
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detailLine,
                                            key: const Key(
                                              'act0_shell_selected_lesson_task_detail',
                                            ),
                                            maxLines: compactRow ? 3 : 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: Act0ShellTokensV1.body
                                                .copyWith(
                                                  color: Act0ShellTokensV1.text,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: compactRow
                                                      ? 11.5
                                                      : 12.1,
                                                  height: 1.16,
                                                ),
                                          ),
                                          if (hasPerfectOpportunity ||
                                              widget.isPerfect) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.isPerfect
                                                  ? _learnCopyV1(
                                                      context,
                                                      en: 'Perfect clear complete.',
                                                      ru: 'Идеально пройдено.',
                                                    )
                                                  : _learnCopyV1(
                                                      context,
                                                      en: 'Replay once for perfect.',
                                                      ru: 'Повтори один раз для идеала.',
                                                    ),
                                              key: const Key(
                                                'act0_shell_selected_lesson_quality_detail',
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Act0ShellTokensV1.label
                                                  .copyWith(
                                                    color: widget.isPerfect
                                                        ? Act0ShellTokensV1.gold
                                                        : rowAccent,
                                                    letterSpacing: 0.04,
                                                  ),
                                            ),
                                          ],
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                              width: compactRow ? 78 : 84,
                                              child: FilledButton(
                                                key: const Key(
                                                  'act0_shell_selected_lesson_cta',
                                                ),
                                                onPressed:
                                                    widget
                                                            .lesson
                                                            .isSelectable &&
                                                        !widget.isLocked
                                                    ? () => widget.onStartTask(
                                                        widget.lesson.lessonId,
                                                        widget.task.taskId,
                                                      )
                                                    : null,
                                                style: usePrimaryCta
                                                    ? Act0ShellTokensV1.primaryButtonStyle(
                                                        height: compactRow
                                                            ? 31
                                                            : 33,
                                                      )
                                                    : Act0ShellTokensV1.tonalButtonStyle(
                                                        tone: rowAccent,
                                                        height: compactRow
                                                            ? 31
                                                            : 33,
                                                      ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    ctaText,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    style: Act0ShellTokensV1.cta
                                                        .copyWith(
                                                          fontSize: compactRow
                                                              ? 12.1
                                                              : 12.6,
                                                          color: usePrimaryCta
                                                              ? Act0ShellTokensV1
                                                                    .onPrimary
                                                              : rowAccent,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  detailLine,
                                                  key: const Key(
                                                    'act0_shell_selected_lesson_task_detail',
                                                  ),
                                                  maxLines: compactRow ? 2 : 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Act0ShellTokensV1.body
                                                      .copyWith(
                                                        color: Act0ShellTokensV1
                                                            .text,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: compactRow
                                                            ? 11.4
                                                            : 12.0,
                                                        height: 1.14,
                                                      ),
                                                ),
                                                if (hasPerfectOpportunity ||
                                                    widget.isPerfect) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    widget.isPerfect
                                                        ? _learnCopyV1(
                                                            context,
                                                            en: 'Perfect clear complete.',
                                                            ru: 'Идеально пройдено.',
                                                          )
                                                        : _learnCopyV1(
                                                            context,
                                                            en: 'Replay once for perfect.',
                                                            ru: 'Повтори один раз для идеала.',
                                                          ),
                                                    key: const Key(
                                                      'act0_shell_selected_lesson_quality_detail',
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Act0ShellTokensV1
                                                        .label
                                                        .copyWith(
                                                          color:
                                                              widget.isPerfect
                                                              ? Act0ShellTokensV1
                                                                    .gold
                                                              : rowAccent,
                                                          letterSpacing: 0.04,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          SizedBox(
                                            width: compactRow ? 74 : 80,
                                            child: FilledButton(
                                              key: const Key(
                                                'act0_shell_selected_lesson_cta',
                                              ),
                                              onPressed:
                                                  widget.lesson.isSelectable &&
                                                      !widget.isLocked
                                                  ? () => widget.onStartTask(
                                                      widget.lesson.lessonId,
                                                      widget.task.taskId,
                                                    )
                                                  : null,
                                              style: usePrimaryCta
                                                  ? Act0ShellTokensV1.primaryButtonStyle(
                                                      height: compactRow
                                                          ? 31
                                                          : 33,
                                                    )
                                                  : Act0ShellTokensV1.tonalButtonStyle(
                                                      tone: rowAccent,
                                                      height: compactRow
                                                          ? 31
                                                          : 33,
                                                    ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  ctaText,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  style: Act0ShellTokensV1.cta
                                                      .copyWith(
                                                        fontSize: compactRow
                                                            ? 12.1
                                                            : 12.6,
                                                        color: usePrimaryCta
                                                            ? Act0ShellTokensV1
                                                                  .onPrimary
                                                            : rowAccent,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _ModuleHeaderV1 extends StatelessWidget {
  const _ModuleHeaderV1({
    required this.worldNumber,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.lessonCount,
    required this.progressFraction,
    required this.onOpenWorldMenu,
    required this.onTap,
    required this.accent,
    required this.accentSoft,
  });

  final int worldNumber;
  final String title;
  final String subtitle;
  final String progressLabel;
  final int lessonCount;
  final double progressFraction;
  final VoidCallback onOpenWorldMenu;
  final VoidCallback? onTap;
  final Color accent;
  final Color accentSoft;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progressFraction.clamp(0.0, 1.0);
    final progressPercent = (normalizedProgress * 100).round();
    final compactMeta = _learnCopyV1(
      context,
      en: '$lessonCount lessons · $progressLabel',
      ru: '$lessonCount уроков · $progressLabel',
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(
                accent.withValues(alpha: 0.14),
                Act0ShellTokensV1.surface2,
              ),
              Color.alphaBlend(
                accentSoft.withValues(alpha: 0.28),
                Act0ShellTokensV1.surface2,
              ),
              Act0ShellTokensV1.surface2,
            ],
            stops: const <double>[0.0, 0.48, 1.0],
          ),
          boxShadow: <BoxShadow>[
            const BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        accent.withValues(alpha: 0.20),
                        accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    '$worldNumber',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 10.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _learnCopyV1(
                          context,
                          en: 'World $worldNumber · $title',
                          ru: 'Мир $worldNumber · $title',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.sectionTitle.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: 13.2,
                          height: 1.02,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: accent,
                      fontSize: 8.8,
                      letterSpacing: 0.18,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  key: const Key('act0_shell_levels_menu_button'),
                  onPressed: onOpenWorldMenu,
                  style: Act0ShellTokensV1.quietButtonStyle(height: 28)
                      .copyWith(
                        minimumSize: const WidgetStatePropertyAll(Size(0, 28)),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 8),
                        ),
                        foregroundColor: const WidgetStatePropertyAll(
                          Act0ShellTokensV1.primary,
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          Act0ShellTokensV1.surface.withValues(alpha: 0.12),
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: accent.withValues(alpha: 0.18)),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusPill,
                            ),
                          ),
                        ),
                        textStyle: WidgetStatePropertyAll(
                          Act0ShellTokensV1.label.copyWith(
                            letterSpacing: 0.22,
                            fontSize: 9.2,
                          ),
                        ),
                      ),
                  icon: const Icon(Icons.map_rounded, size: 13),
                  label: Text(_learnCopyV1(context, en: 'Worlds', ru: 'Миры')),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    compactMeta,
                    key: const Key('act0_shell_learn_route_board'),
                    style: Act0ShellTokensV1.muted.copyWith(
                      fontSize: 9.6,
                      height: 1.08,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              child: LinearProgressIndicator(
                key: const Key('act0_shell_learn_progress_bar'),
                value: normalizedProgress,
                minHeight: 2,
                backgroundColor: Act0ShellTokensV1.border.withValues(
                  alpha: 0.24,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedModuleHeaderDelegateV1 extends SliverPersistentHeaderDelegate {
  const _PinnedModuleHeaderDelegateV1({required this.child});

  static const double extentV1 = 84.0;

  final Widget child;

  @override
  double get minExtent => extentV1;

  @override
  double get maxExtent => extentV1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Act0ShellTokensV1.background, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedModuleHeaderDelegateV1 oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _LearnJourneyStripV1 extends StatelessWidget {
  const _LearnJourneyStripV1({
    required this.worldNumber,
    required this.title,
    required this.subtitle,
    required this.lessonCount,
    required this.rewardXp,
    required this.nextLandmarkTitle,
    required this.accent,
    required this.accentSoft,
  });

  final int worldNumber;
  final String title;
  final String subtitle;
  final int lessonCount;
  final int rewardXp;
  final String? nextLandmarkTitle;
  final Color accent;
  final Color accentSoft;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_learn_journey_strip'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.16),
            accentSoft.withValues(alpha: 0.62),
            Act0ShellTokensV1.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _learnCopyV1(context, en: 'CURRENT CHAPTER', ru: 'ТЕКУЩАЯ ГЛАВА'),
            style: Act0ShellTokensV1.label.copyWith(
              color: accent,
              fontSize: 10.4,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _learnCopyV1(
              context,
              en: 'World $worldNumber · $title',
              ru: 'Мир $worldNumber · $title',
            ),
            style: Act0ShellTokensV1.cardTitle,
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Act0ShellTokensV1.muted.copyWith(height: 1.25)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LearnStatTagV1(
                icon: Icons.route_rounded,
                label: _learnCopyV1(
                  context,
                  en: '$lessonCount lessons',
                  ru: '$lessonCount уроков',
                ),
                accent: accent,
              ),
              _LearnStatTagV1(
                icon: Icons.workspace_premium_rounded,
                label: _learnCopyV1(
                  context,
                  en: '$rewardXp XP route',
                  ru: '$rewardXp XP пути',
                ),
                accent: Act0ShellTokensV1.gold,
              ),
              if (nextLandmarkTitle != null)
                _LearnStatTagV1(
                  icon: Icons.flag_rounded,
                  label: _learnCopyV1(
                    context,
                    en: 'Next · $nextLandmarkTitle',
                    ru: 'Дальше · $nextLandmarkTitle',
                  ),
                  accent: accent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearnStatTagV1 extends StatelessWidget {
  const _LearnStatTagV1({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.text,
              letterSpacing: 0.18,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathCardV1 extends StatelessWidget {
  const _PathCardV1({
    required this.index,
    required this.worldAccent,
    required this.worldAccentSoft,
    required this.lesson,
    required this.selected,
    required this.expanded,
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    required this.isNextUp,
    required this.onSelectLesson,
    this.expandedBody,
  });

  final int index;
  final Color worldAccent;
  final Color worldAccentSoft;
  final Act0LessonCardV1 lesson;
  final bool selected;
  final bool expanded;
  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final bool isNextUp;
  final bool Function(String lessonId) onSelectLesson;
  final Widget? expandedBody;

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.state == Act0LessonStateV1.completed;
    final isCurrent = lesson.state == Act0LessonStateV1.current;
    final isLocked = lesson.state == Act0LessonStateV1.locked;
    final isInProgress =
        isCurrent &&
        lesson.taskList.any((t) => pathClosedTaskIds.contains(t.taskId)) &&
        lesson.taskList.any((t) => !pathClosedTaskIds.contains(t.taskId));
    final stateColor = _stateColor(lesson.state);
    final icon = switch (lesson.state) {
      Act0LessonStateV1.completed => Icons.check_rounded,
      Act0LessonStateV1.current => Icons.play_arrow_rounded,
      Act0LessonStateV1.locked => Icons.lock_rounded,
    };
    final completedSteps = lesson.taskList
        .where((t) => pathClosedTaskIds.contains(t.taskId))
        .length;
    final totalSteps = lesson.taskList.length;
    final stepSummary = isCompleted
        ? '$totalSteps steps complete'
        : isCurrent
        ? isInProgress
              ? '$completedSteps of $totalSteps steps complete'
              : '$totalSteps steps ready'
        : isLocked
        ? isNextUp && index > 1
              ? _learnCopyV1(
                  context,
                  en: 'Complete Lesson ${index - 1} to unlock',
                  ru: 'Заверши урок ${index - 1}, чтобы открыть',
                )
              : ''
        : '$totalSteps steps inside';
    final stateBadgeLabel = isCompleted
        ? 'Done'
        : isCurrent
        ? 'Now'
        : isNextUp
        ? 'Next'
        : isLocked
        ? 'Locked'
        : 'Later';
    final lessonTitle = act0LocalizedLessonTitleV1(context, lesson);
    final isExpandedFocus = expanded;
    final isHighlighted = selected || isCurrent || expanded;
    final currentAccent = Act0ShellTokensV1.primary;
    final nextAccent = Act0ShellTokensV1.gold;
    final cardTint = isExpandedFocus
        ? (isCurrent ? currentAccent : worldAccent).withValues(alpha: 0.028)
        : (isHighlighted
                  ? (isCurrent ? currentAccent : stateColor)
                  : worldAccent)
              .withValues(alpha: isHighlighted ? 0.06 : 0.035);
    final cardBorderColor = isExpandedFocus
        ? Act0ShellTokensV1.border.withValues(alpha: 0.44)
        : isHighlighted
        ? (isCurrent ? currentAccent : stateColor).withValues(alpha: 0.22)
        : Act0ShellTokensV1.border.withValues(alpha: 0.52);
    final cardGlowColor = isExpandedFocus
        ? (isCurrent ? currentAccent : worldAccent).withValues(alpha: 0.04)
        : (isCurrent ? currentAccent : stateColor).withValues(alpha: 0.08);
    final leadColor = isExpandedFocus
        ? (isCurrent ? currentAccent : worldAccent).withValues(
            alpha: isLocked ? 0.28 : 0.74,
          )
        : (isCurrent ? currentAccent : stateColor).withValues(
            alpha: isLocked ? 0.36 : 0.90,
          );
    final iconTint = isCurrent
        ? currentAccent
        : isNextUp && !isLocked
        ? nextAccent
        : isExpandedFocus
        ? worldAccent
        : stateColor;
    final badgeTint = isCurrent
        ? currentAccent
        : isNextUp && !isLocked
        ? nextAccent
        : isExpandedFocus
        ? worldAccent
        : stateColor;
    final cardRadius = BorderRadius.circular(Act0ShellTokensV1.radiusLg);

    return Opacity(
      opacity: lesson.state == Act0LessonStateV1.locked ? 0.68 : 1,
      child: Material(
        borderRadius: cardRadius,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Color.alphaBlend(cardTint, Act0ShellTokensV1.surface2),
            borderRadius: cardRadius,
            border: Border.all(
              color: isExpandedFocus
                  ? cardBorderColor
                  : cardBorderColor.withValues(alpha: 0.88),
            ),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
              if (isHighlighted && !isExpandedFocus)
                BoxShadow(
                  color: cardGlowColor.withValues(alpha: 0.72),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                key: Key('act0_shell_lesson_${lesson.title}'),
                borderRadius: cardRadius,
                onTap: () => onSelectLesson(lesson.lessonId),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? iconTint
                              : iconTint.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: iconTint.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isCompleted
                              ? Act0ShellTokensV1.onPrimary
                              : iconTint,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lesson $index',
                                  style: Act0ShellTokensV1.label.copyWith(
                                    color: badgeTint,
                                    letterSpacing: 0.22,
                                    fontSize: 9.6,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: expanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 17,
                                    color: badgeTint.withValues(alpha: 0.62),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeTint.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(
                                      Act0ShellTokensV1.radiusPill,
                                    ),
                                    border: Border.all(
                                      color: badgeTint.withValues(alpha: 0.13),
                                    ),
                                  ),
                                  child: Text(
                                    stateBadgeLabel,
                                    key: Key(
                                      'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: isCompleted
                                          ? Act0ShellTokensV1.gold
                                          : badgeTint,
                                      letterSpacing: 0.06,
                                      fontSize: 9.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lessonTitle,
                              style: Act0ShellTokensV1.cardTitle.copyWith(
                                fontSize: 14.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                            ),
                            if (stepSummary.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                stepSummary,
                                style: Act0ShellTokensV1.muted.copyWith(
                                  fontSize: 10.6,
                                  color: isLocked
                                      ? Act0ShellTokensV1.textDim
                                      : Act0ShellTokensV1.textMuted,
                                  height: 1.14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 430),
                  reverseDuration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: expandedBody == null
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                              ),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: badgeTint.withValues(alpha: 0.14),
                              ),
                            ),
                            expandedBody!,
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _stateColor(Act0LessonStateV1 state) {
  return switch (state) {
    Act0LessonStateV1.completed => Act0ShellTokensV1.primary,
    Act0LessonStateV1.current => Act0ShellTokensV1.primary,
    Act0LessonStateV1.locked => Act0ShellTokensV1.textDim,
  };
}

// Phase 2: Color desaturation helper for locked state
Color _desaturateColor(Color color, double factor) {
  final hsv = HSVColor.fromColor(color);
  return hsv.withSaturation(hsv.saturation * (1 - factor)).toColor();
}

String _stepLabel(Act0LessonStepKindV1 kind) {
  return switch (kind) {
    Act0LessonStepKindV1.learn => 'Learn',
    Act0LessonStepKindV1.practice => 'Practice',
    Act0LessonStepKindV1.fixMistakes => 'Fix mistakes',
    Act0LessonStepKindV1.review => 'Review',
    Act0LessonStepKindV1.proveIt => 'Prove it',
  };
}

String _selectedTaskDetail({
  required BuildContext context,
  required Act0LessonTaskV1 task,
  required Act0LessonTaskV1 nextTask,
  String? routeBlockerTaskTitle,
  required bool isDone,
  required bool isPerfect,
  required bool isSkipped,
  required bool isLocked,
}) {
  if (isLocked) {
    final blockerTitle = (routeBlockerTaskTitle ?? '').trim();
    return act0LocalizedTaskLockedSummaryV1(
      context,
      task,
      fallback:
          task.lockedSummary ??
          _learnCopyV1(
            context,
            en: blockerTitle.isNotEmpty
                ? 'Clear ${blockerTitle.toLowerCase()} first, then this node opens.'
                : 'Clear ${act0LocalizedTaskTitleV1(context, nextTask).toLowerCase()} first, then this node opens.',
            ru: blockerTitle.isNotEmpty
                ? 'Сначала закрой шаг «${blockerTitle.toLowerCase()}», потом этот узел откроется.'
                : 'Сначала закрой шаг «${act0LocalizedTaskTitleV1(context, nextTask).toLowerCase()}», потом этот узел откроется.',
          ),
    );
  }
  if (isSkipped) {
    return _isRuLocaleV1(context)
        ? 'Этот шаг доступен в любой момент. Плейсмент просто провёл тебя дальше; пройди его сейчас, чтобы путь стал полностью чистым.'
        : 'Available anytime. Placement started you later; run it now to turn this path into a full clear.';
  }
  if (isDone) {
    return isPerfect
        ? _learnCopyV1(
            context,
            en: 'Already clear. This step is sitting on its best finish.',
            ru: 'Уже чисто. Этот шаг уже закрыт в лучшем виде.',
          )
        : _learnCopyV1(
            context,
            en: 'Already clear. One calm replay turns this into a perfect clear.',
            ru: 'Уже чисто. Один спокойный повтор превратит это в идеал.',
          );
  }
  return act0LocalizedTaskSummaryV1(
    context,
    task,
    fallback: task.summary ?? task.runner.caption,
  );
}

IconData _stepIcon(Act0LessonStepKindV1 kind) {
  return switch (kind) {
    Act0LessonStepKindV1.learn => Icons.menu_book_rounded,
    Act0LessonStepKindV1.practice => Icons.touch_app_rounded,
    Act0LessonStepKindV1.fixMistakes => Icons.build_circle_rounded,
    Act0LessonStepKindV1.review => Icons.refresh_rounded,
    Act0LessonStepKindV1.proveIt => Icons.verified_rounded,
  };
}

Color _worldStateColor(Act0WorldStateV1 state) {
  return switch (state) {
    Act0WorldStateV1.completed => Act0ShellTokensV1.primary,
    Act0WorldStateV1.current => Act0ShellTokensV1.primary,
    Act0WorldStateV1.locked => Act0ShellTokensV1.textDim,
  };
}

class _StateBadgeV1 extends StatelessWidget {
  const _StateBadgeV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
