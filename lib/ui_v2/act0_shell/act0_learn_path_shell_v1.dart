import 'dart:async' show Timer, unawaited;
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
    false;

String _learnCopyV1(
  BuildContext context, {
  required String en,
  required String ru,
}) => _isRuLocaleV1(context) ? ru : en;

const Color _learnV6Blue = Act0VisualCanonV1.bluePrimary;
const Color _learnV6Cyan = Act0VisualCanonV1.cyanAccent;
const Color _learnV6Gold = Act0VisualCanonV1.goldAccent;
const Color _learnV6Green = Act0VisualCanonV1.greenTable;
const Color _learnV6Navy = Act0VisualCanonV1.navySurface;
const Color _learnV6Deep = Act0VisualCanonV1.deepNavy;

BoxDecoration _learnV6PrimarySurfaceDecoration({
  double radius = Act0ShellTokensV1.radiusLg,
  double borderAlpha = 0.36,
  double glowAlpha = 0.16,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: _learnV6Blue.withValues(alpha: borderAlpha)),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFF0B3153),
        Color(0xFF082441),
        Color(0xFF06182A),
        _learnV6Deep,
      ],
      stops: <double>[0.0, 0.34, 0.74, 1.0],
    ),
    boxShadow: <BoxShadow>[
      const BoxShadow(
        color: Color(0x61000000),
        blurRadius: 18,
        offset: Offset(0, 10),
      ),
      BoxShadow(
        color: _learnV6Blue.withValues(alpha: glowAlpha),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

BoxDecoration _learnV6SecondarySurfaceDecoration({
  Color borderColor = const Color(0xFF17456A),
  double borderAlpha = 0.64,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
    border: Border.all(color: borderColor.withValues(alpha: borderAlpha)),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF071C31), Color(0xFF061525), _learnV6Deep],
    ),
    boxShadow: const <BoxShadow>[
      BoxShadow(color: Color(0x48000000), blurRadius: 16, offset: Offset(0, 8)),
    ],
  );
}

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
    milliseconds: 380,
  );
  static const Duration _inlineLessonHubCollapseDurationV1 = Duration(
    milliseconds: 320,
  );
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
  String? _dismissedDefaultTaskFocusLessonIdV1;
  bool _showFullJourneyPathV5 = false;
  String? _fullPathManualExpandedLessonIdV6;

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

  Future<void> _waitForLearnLayoutSettleV1({int frames = 2}) async {
    for (var i = 0; i < frames; i++) {
      WidgetsBinding.instance.scheduleFrame();
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
    }
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
    await _waitForLearnLayoutSettleV1(frames: 1);
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
    final durationMs = (140 + (distance * 0.15)).clamp(140, 280).round();
    if (epoch != _scrollEpochV1 ||
        widget.detailLessonId != lessonId ||
        widget.activePopupTaskId != taskId) {
      return;
    }
    await _learnScrollController.animateTo(
      target,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _shouldShowDefaultTaskFocusV1(Act0LessonCardV1 lesson) {
    return lesson.state == Act0LessonStateV1.current &&
        widget.detailLessonId == lesson.lessonId &&
        widget.activePopupTaskId == null &&
        _dismissedDefaultTaskFocusLessonIdV1 != lesson.lessonId;
  }

  void _dismissTaskFocusForLessonV1(String lessonId) {
    final alreadyDismissed = _dismissedDefaultTaskFocusLessonIdV1 == lessonId;
    if (!alreadyDismissed) {
      setState(() {
        _dismissedDefaultTaskFocusLessonIdV1 = lessonId;
      });
    }
    if (widget.activePopupTaskId != null) {
      widget.onDismissTaskPopup();
    }
  }

  void _clearDefaultTaskFocusDismissalV1(String lessonId) {
    if (_dismissedDefaultTaskFocusLessonIdV1 != lessonId) {
      return;
    }
    setState(() {
      _dismissedDefaultTaskFocusLessonIdV1 = null;
    });
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

  Widget? _expandedBodyForLessonV5({
    required BuildContext context,
    required Act0LessonCardV1 lesson,
    required String? detailLessonId,
    required bool shouldShowDefaultTaskFocus,
  }) {
    if (lesson.lessonId != detailLessonId) {
      return null;
    }
    return _SelectedLessonPopupV1(
      panelRenderKey: _selectedLessonPanelKey,
      lesson: lesson,
      selectedTaskId: widget.selectedTaskId,
      activePopupTaskId: widget.activePopupTaskId,
      showDefaultTaskFocus:
          lesson.lessonId == detailLessonId && shouldShowDefaultTaskFocus,
      completedTaskIds: widget.completedTaskIds,
      perfectTaskIds: widget.perfectTaskIds,
      skippedTaskIds: widget.skippedTaskIds,
      pathClosedTaskIds: widget.pathClosedTaskIds,
      completionOutcomeLabel: widget.lessonOutcomeLabels[lesson.lessonId],
      routeBlockerTaskTitle: _routeBlockerTaskTitleV1(context),
      taskLinkForId: (taskId) =>
          _taskLinks.putIfAbsent('${lesson.lessonId}::$taskId', LayerLink.new),
      taskDetailKeyForId: (taskId) => _taskDetailKeys.putIfAbsent(
        '${lesson.lessonId}::$taskId',
        GlobalKey.new,
      ),
      onDismissTaskPopup: () => _dismissTaskFocusForLessonV1(lesson.lessonId),
      onSelectTask: (lessonId, taskId) {
        _clearDefaultTaskFocusDismissalV1(lessonId);
        widget.onSelectTask(lessonId, taskId);
      },
      onStartTask: (lessonId, taskId) {
        _clearDefaultTaskFocusDismissalV1(lessonId);
        widget.onStartTask(lessonId, taskId);
      },
    );
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
    final detailLessonId = widget.detailLessonId;
    final journeyDetailLessonId = _showFullJourneyPathV5
        ? _fullPathManualExpandedLessonIdV6
        : detailLessonId;
    final shouldShowDefaultTaskFocus =
        detailLesson != null && _shouldShowDefaultTaskFocusV1(detailLesson);
    final currentMissionLesson = widget.lessons.firstWhere(
      (lesson) => lesson.state == Act0LessonStateV1.current,
      orElse: () => widget.lessons.firstWhere(
        (lesson) => lesson.lessonId == widget.selectedLessonId,
        orElse: () => widget.lessons.first,
      ),
    );
    final currentMissionTask = currentMissionLesson.taskList.firstWhere(
      (task) => !widget.pathClosedTaskIds.contains(task.taskId),
      orElse: () => currentMissionLesson.taskList.first,
    );
    final currentMissionStepIndex =
        currentMissionLesson.taskList.indexWhere(
          (task) => task.taskId == currentMissionTask.taskId,
        ) +
        1;
    final progressFraction = widget.lessons.isEmpty
        ? 0.0
        : widget.lessons
                  .where((l) => l.state == Act0LessonStateV1.completed)
                  .length /
              widget.lessons.length;
    final journeyLessonIndexes = _missionFirstJourneyPreviewIndexesV5(
      widget.lessons,
      showFullPath: _showFullJourneyPathV5,
    );
    final deferredLockedCount = _hiddenLockedLessonCountV5(
      widget.lessons,
      journeyLessonIndexes,
    );
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
              if (detailLessonId != null &&
                  (widget.activePopupTaskId != null ||
                      shouldShowDefaultTaskFocus)) {
                _dismissTaskFocusForLessonV1(detailLessonId);
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
                    Act0ShellTokensV1.gapXs,
                    Act0ShellTokensV1.pageX,
                    Act0ShellTokensV1.bottomNavHeight + 34,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Act0ShellTokensV1.centeredContent(
                      context,
                      child: _LearnMissionFirstBodyV5(
                        pinnedHeaderKey: _pinnedModuleHeaderKey,
                        world: selectedWorld,
                        moduleTitle: widget.moduleTitle,
                        moduleProgressLabel: widget.moduleProgressLabel,
                        lessonCount: widget.lessons.length,
                        progressFraction: progressFraction,
                        onOpenWorldMenu: widget.onOpenWorldMenu,
                        onDismissDetail: widget.detailLessonId == null
                            ? null
                            : widget.onDismissDetail,
                        currentMissionLesson: currentMissionLesson,
                        currentMissionTask: currentMissionTask,
                        currentMissionStepIndex: currentMissionStepIndex,
                        onStartMission: currentMissionLesson.isSelectable
                            ? () => widget.onStartTask(
                                currentMissionLesson.lessonId,
                                currentMissionTask.taskId,
                              )
                            : null,
                        lessons: widget.lessons,
                        journeyLessonIndexes: journeyLessonIndexes,
                        deferredLockedCount: deferredLockedCount,
                        showFullPath: _showFullJourneyPathV5,
                        onToggleFullPath: () {
                          setState(() {
                            _showFullJourneyPathV5 = !_showFullJourneyPathV5;
                            _fullPathManualExpandedLessonIdV6 = null;
                          });
                        },
                        lessonKeyForId: (lessonId) =>
                            _lessonKeys.putIfAbsent(lessonId, GlobalKey.new),
                        selectedLessonId: widget.selectedLessonId,
                        detailLessonId: journeyDetailLessonId,
                        activePopupTaskId: widget.activePopupTaskId,
                        shouldShowDefaultTaskFocus: shouldShowDefaultTaskFocus,
                        completedTaskIds: widget.completedTaskIds,
                        skippedTaskIds: widget.skippedTaskIds,
                        pathClosedTaskIds: widget.pathClosedTaskIds,
                        onTapOutsideLesson: (lesson) {
                          if (lesson.lessonId == detailLessonId &&
                              (widget.activePopupTaskId != null ||
                                  shouldShowDefaultTaskFocus)) {
                            _dismissTaskFocusForLessonV1(lesson.lessonId);
                            return;
                          }
                          widget.onDismissDetail();
                        },
                        onSelectLesson: (lessonId) {
                          if (!_showFullJourneyPathV5) {
                            return widget.onSelectLesson(lessonId);
                          }
                          final lesson = widget.lessons.firstWhere(
                            (entry) => entry.lessonId == lessonId,
                            orElse: () => widget.lessons.first,
                          );
                          if (!lesson.isSelectable) {
                            return widget.onSelectLesson(lessonId);
                          }
                          final collapse =
                              _fullPathManualExpandedLessonIdV6 == lessonId;
                          setState(() {
                            _fullPathManualExpandedLessonIdV6 = collapse
                                ? null
                                : lessonId;
                          });
                          return widget.onSelectLesson(lessonId);
                        },
                        expandedBodyForLesson: (lesson) =>
                            _expandedBodyForLessonV5(
                              context: context,
                              lesson: lesson,
                              detailLessonId: journeyDetailLessonId,
                              shouldShowDefaultTaskFocus:
                                  shouldShowDefaultTaskFocus,
                            ),
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

List<int> _missionFirstJourneyPreviewIndexesV5(
  List<Act0LessonCardV1> lessons, {
  required bool showFullPath,
}) {
  if (showFullPath) {
    return List<int>.generate(lessons.length, (index) => index);
  }
  final currentIndex = lessons.indexWhere(
    (lesson) => lesson.state == Act0LessonStateV1.current,
  );
  if (currentIndex < 0) {
    return _focusedJourneyLessonIndexesV1(lessons);
  }
  final indexes = <int>{};
  final completedIndexes = <int>[
    for (var i = 0; i < lessons.length; i++)
      if (lessons[i].state == Act0LessonStateV1.completed) i,
  ];
  if (completedIndexes.isNotEmpty) {
    indexes.add(completedIndexes.first);
  }
  if (completedIndexes.length > 1) {
    indexes.add(completedIndexes.last);
  }
  indexes.add(currentIndex);
  final nextIndex = currentIndex + 1;
  if (nextIndex < lessons.length) {
    indexes.add(nextIndex);
  }
  return indexes.toList()..sort();
}

int _hiddenLockedLessonCountV5(
  List<Act0LessonCardV1> lessons,
  List<int> visibleIndexes,
) {
  final visible = visibleIndexes.toSet();
  return <int>[
    for (var i = 0; i < lessons.length; i++)
      if (!visible.contains(i) && lessons[i].state == Act0LessonStateV1.locked)
        i,
  ].length;
}

class _LearnMissionFirstBodyV5 extends StatelessWidget {
  const _LearnMissionFirstBodyV5({
    required this.pinnedHeaderKey,
    required this.world,
    required this.moduleTitle,
    required this.moduleProgressLabel,
    required this.lessonCount,
    required this.progressFraction,
    required this.onOpenWorldMenu,
    required this.onDismissDetail,
    required this.currentMissionLesson,
    required this.currentMissionTask,
    required this.currentMissionStepIndex,
    required this.onStartMission,
    required this.lessons,
    required this.journeyLessonIndexes,
    required this.deferredLockedCount,
    required this.showFullPath,
    required this.onToggleFullPath,
    required this.lessonKeyForId,
    required this.selectedLessonId,
    required this.detailLessonId,
    required this.activePopupTaskId,
    required this.shouldShowDefaultTaskFocus,
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    required this.onTapOutsideLesson,
    required this.onSelectLesson,
    required this.expandedBodyForLesson,
  });

  final GlobalKey pinnedHeaderKey;
  final Act0WorldCardV1 world;
  final String moduleTitle;
  final String moduleProgressLabel;
  final int lessonCount;
  final double progressFraction;
  final VoidCallback onOpenWorldMenu;
  final VoidCallback? onDismissDetail;
  final Act0LessonCardV1 currentMissionLesson;
  final Act0LessonTaskV1 currentMissionTask;
  final int currentMissionStepIndex;
  final VoidCallback? onStartMission;
  final List<Act0LessonCardV1> lessons;
  final List<int> journeyLessonIndexes;
  final int deferredLockedCount;
  final bool showFullPath;
  final VoidCallback onToggleFullPath;
  final GlobalKey Function(String lessonId) lessonKeyForId;
  final String selectedLessonId;
  final String? detailLessonId;
  final String? activePopupTaskId;
  final bool shouldShowDefaultTaskFocus;
  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final ValueChanged<Act0LessonCardV1> onTapOutsideLesson;
  final bool Function(String lessonId) onSelectLesson;
  final Widget? Function(Act0LessonCardV1 lesson) expandedBodyForLesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('act0_shell_learn_v5_body'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: pinnedHeaderKey,
          child: _WorldContextStripV5(
            world: world,
            moduleTitle: moduleTitle,
            moduleProgressLabel: moduleProgressLabel,
            lessonCount: lessonCount,
            progressFraction: progressFraction,
            onOpenWorldMenu: onOpenWorldMenu,
            onTap: onDismissDetail,
          ),
        ),
        const SizedBox(height: 9),
        _CurrentMissionCardV1(
          lesson: currentMissionLesson,
          task: currentMissionTask,
          stepIndex: currentMissionStepIndex,
          totalSteps: currentMissionLesson.taskList.length,
          accent: Act0ShellTokensV1.primary,
          onStart: onStartMission,
        ),
        const SizedBox(height: 14),
        _JourneyPreviewV5(
          lessons: lessons,
          journeyLessonIndexes: journeyLessonIndexes,
          deferredLockedCount: deferredLockedCount,
          showFullPath: showFullPath,
          onToggleFullPath: onToggleFullPath,
          lessonKeyForId: lessonKeyForId,
          selectedLessonId: selectedLessonId,
          detailLessonId: detailLessonId,
          activePopupTaskId: activePopupTaskId,
          shouldShowDefaultTaskFocus: shouldShowDefaultTaskFocus,
          completedTaskIds: completedTaskIds,
          skippedTaskIds: skippedTaskIds,
          pathClosedTaskIds: pathClosedTaskIds,
          onTapOutsideLesson: onTapOutsideLesson,
          onSelectLesson: onSelectLesson,
          expandedBodyForLesson: expandedBodyForLesson,
        ),
        const SizedBox(
          key: Key('act0_shell_learn_safe_bottom_spacer'),
          height: Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapLg,
        ),
      ],
    );
  }
}

class _WorldContextStripV5 extends StatelessWidget {
  const _WorldContextStripV5({
    required this.world,
    required this.moduleTitle,
    required this.moduleProgressLabel,
    required this.lessonCount,
    required this.progressFraction,
    required this.onOpenWorldMenu,
    required this.onTap,
  });

  final Act0WorldCardV1 world;
  final String moduleTitle;
  final String moduleProgressLabel;
  final int lessonCount;
  final double progressFraction;
  final VoidCallback onOpenWorldMenu;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;
    final normalizedProgress = progressFraction.clamp(0.0, 1.0);
    final progressPercent = (normalizedProgress * 100).round();
    const accent = _learnV6Cyan;
    return Material(
      key: const Key('act0_shell_module_header'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Ink(
          key: const Key('act0_shell_learn_v5_world_context'),
          padding: EdgeInsets.fromLTRB(compact ? 12 : 14, 10, 12, 10),
          decoration: _learnV6SecondarySurfaceDecoration(
            borderColor: _learnV6Blue,
            borderAlpha: 0.42,
          ),
          child: Stack(
            children: [
              Positioned(
                key: const Key('act0_shell_learn_v6_world_luminous_context'),
                right: compact ? 46 : 84,
                top: -34,
                child: IgnorePointer(
                  child: Container(
                    width: compact ? 106 : 136,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: RadialGradient(
                        colors: <Color>[
                          _learnV6Blue.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: compact ? 32 : 36,
                    height: compact ? 32 : 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          _learnV6Cyan.withValues(alpha: 0.22),
                          _learnV6Blue.withValues(alpha: 0.22),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: _learnV6Cyan.withValues(alpha: 0.28),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _learnV6Cyan.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${world.worldNumber}',
                      style: Act0ShellTokensV1.sectionTitle.copyWith(
                        color: _learnV6Cyan,
                        fontSize: compact ? 15.5 : 16.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _learnCopyV1(
                                  context,
                                  en: 'World ${world.worldNumber}',
                                  ru: 'Мир ${world.worldNumber}',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: _learnV6Cyan,
                                  fontSize: 9.8,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            if (!compact) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  moduleTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: Act0ShellTokensV1.label.copyWith(
                                    color: Act0ShellTokensV1.textMuted,
                                    fontSize: 9.4,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          world.title,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.sectionTitle.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontSize: compact ? 14.2 : 15.2,
                            height: 1.04,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusPill,
                                ),
                                child: LinearProgressIndicator(
                                  key: const Key(
                                    'act0_shell_learn_progress_bar',
                                  ),
                                  value: normalizedProgress,
                                  minHeight: 3,
                                  backgroundColor: const Color(
                                    0xFF0C2133,
                                  ).withValues(alpha: 0.96),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        _learnV6Blue,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$progressPercent%',
                              style: Act0ShellTokensV1.label.copyWith(
                                color: _learnV6Blue.withValues(alpha: 0.92),
                                fontSize: 10.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _learnCopyV1(
                            context,
                            en: '$lessonCount lessons · $moduleProgressLabel',
                            ru: '$lessonCount уроков · $moduleProgressLabel',
                          ),
                          key: const Key('act0_shell_learn_route_board'),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.muted.copyWith(
                            color: Act0ShellTokensV1.textMuted,
                            fontSize: 9.8,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                    child: OutlinedButton.icon(
                      key: const Key('act0_shell_levels_menu_button'),
                      onPressed: onOpenWorldMenu,
                      style: Act0ShellTokensV1.quietButtonStyle(height: 34)
                          .copyWith(
                            minimumSize: const WidgetStatePropertyAll(
                              Size(0, 30),
                            ),
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: compact ? 7 : 9),
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              _learnV6Blue.withValues(alpha: 0.92),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              _learnV6Blue.withValues(alpha: 0.075),
                            ),
                            side: WidgetStatePropertyAll(
                              BorderSide(
                                color: _learnV6Blue.withValues(alpha: 0.22),
                              ),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusPill,
                                ),
                              ),
                            ),
                          ),
                      icon: const Icon(
                        Icons.map_rounded,
                        size: 15,
                        color: _learnV6Blue,
                      ),
                      label: compact
                          ? const SizedBox.shrink()
                          : Text(
                              _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyPreviewV5 extends StatelessWidget {
  const _JourneyPreviewV5({
    required this.lessons,
    required this.journeyLessonIndexes,
    required this.deferredLockedCount,
    required this.showFullPath,
    required this.onToggleFullPath,
    required this.lessonKeyForId,
    required this.selectedLessonId,
    required this.detailLessonId,
    required this.activePopupTaskId,
    required this.shouldShowDefaultTaskFocus,
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    required this.onTapOutsideLesson,
    required this.onSelectLesson,
    required this.expandedBodyForLesson,
  });

  final List<Act0LessonCardV1> lessons;
  final List<int> journeyLessonIndexes;
  final int deferredLockedCount;
  final bool showFullPath;
  final VoidCallback onToggleFullPath;
  final GlobalKey Function(String lessonId) lessonKeyForId;
  final String selectedLessonId;
  final String? detailLessonId;
  final String? activePopupTaskId;
  final bool shouldShowDefaultTaskFocus;
  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final ValueChanged<Act0LessonCardV1> onTapOutsideLesson;
  final bool Function(String lessonId) onSelectLesson;
  final Widget? Function(Act0LessonCardV1 lesson) expandedBodyForLesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('act0_shell_learn_v5_journey_preview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _learnCopyV1(
                  context,
                  en: showFullPath ? 'Full journey' : 'Journey preview',
                  ru: showFullPath ? 'Весь путь' : 'Путь впереди',
                ),
                key: const Key('act0_shell_journey_path_header'),
                style: Act0ShellTokensV1.sectionTitle.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontSize: 14.4,
                  height: 1.05,
                ),
              ),
            ),
            TextButton(
              key: const Key('act0_shell_learn_v5_view_full_path'),
              onPressed: onToggleFullPath,
              style: TextButton.styleFrom(
                foregroundColor: _learnV6Cyan,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: Act0ShellTokensV1.label.copyWith(
                  fontSize: 10.0,
                  letterSpacing: 0.04,
                ),
              ),
              child: Text(
                _learnCopyV1(
                  context,
                  en: showFullPath ? 'Preview' : 'View path',
                  ru: showFullPath ? 'Кратко' : 'Весь путь',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          _learnCopyV1(
            context,
            en: 'This week, see the table before choosing.',
            ru: 'На этой неделе смотри на стол перед выбором.',
          ),
          key: const Key('act0_shell_learn_week1_support_line'),
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: Act0ShellTokensV1.muted.copyWith(
            color: Act0ShellTokensV1.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        if (showFullPath)
          SizedBox(
            key: detailLessonId == null
                ? const Key('act0_shell_full_path_collapsed_v6')
                : const Key('act0_shell_full_path_manual_expand_v6'),
            height: 0,
          ),
        DecoratedBox(
          key: const Key('act0_shell_journey_preview_surface_v5'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                const Color(0xFF071C31).withValues(alpha: 0.72),
                const Color(0xFF061525).withValues(alpha: 0.62),
                _learnV6Deep.withValues(alpha: 0.44),
              ],
            ),
            border: Border.all(color: _learnV6Blue.withValues(alpha: 0.26)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _learnV6Blue.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
            child: Column(
              children: [
                for (
                  var windowIndex = 0;
                  windowIndex < journeyLessonIndexes.length;
                  windowIndex++
                ) ...[
                  Builder(
                    builder: (context) {
                      final i = journeyLessonIndexes[windowIndex];
                      final lesson = lessons[i];
                      final isNextUp =
                          i > 0 &&
                          lessons[i - 1].state == Act0LessonStateV1.current &&
                          lesson.state == Act0LessonStateV1.locked;
                      final expanded = lesson.lessonId == detailLessonId;
                      return KeyedSubtree(
                        key: lessonKeyForId(lesson.lessonId),
                        child: TapRegion(
                          groupId: _Act0LearnPathShellV1State
                              ._lessonTapRegionGroupIdV1,
                          onTapOutside: expanded
                              ? (_) => onTapOutsideLesson(lesson)
                              : null,
                          child: _JourneyPreviewRowV5(
                            index: i + 1,
                            lesson: lesson,
                            isNextUp: isNextUp,
                            selected: lesson.lessonId == selectedLessonId,
                            expanded: expanded,
                            completedTaskIds: completedTaskIds,
                            skippedTaskIds: skippedTaskIds,
                            pathClosedTaskIds: pathClosedTaskIds,
                            onSelectLesson: onSelectLesson,
                            expandedBody: expanded
                                ? expandedBodyForLesson(lesson)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  if (windowIndex < journeyLessonIndexes.length - 1 ||
                      deferredLockedCount > 0)
                    const SizedBox(height: 6),
                ],
                if (deferredLockedCount > 0) ...[
                  _JourneyFutureSummaryV5(count: deferredLockedCount),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JourneyPreviewRowV5 extends StatelessWidget {
  const _JourneyPreviewRowV5({
    required this.index,
    required this.lesson,
    required this.isNextUp,
    required this.selected,
    required this.expanded,
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    required this.onSelectLesson,
    required this.expandedBody,
  });

  final int index;
  final Act0LessonCardV1 lesson;
  final bool isNextUp;
  final bool selected;
  final bool expanded;
  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final bool Function(String lessonId) onSelectLesson;
  final Widget? expandedBody;

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.state == Act0LessonStateV1.completed;
    final isCurrent = lesson.state == Act0LessonStateV1.current;
    final isLocked = lesson.state == Act0LessonStateV1.locked;
    final accent = isNextUp
        ? _learnV6Gold
        : isLocked
        ? Act0ShellTokensV1.textDim
        : isCompleted
        ? _learnV6Green
        : _learnV6Cyan;
    final opacity = isCurrent
        ? 0.88
        : isCompleted
        ? 0.92
        : isLocked
        ? (isNextUp ? 0.76 : 0.66)
        : 0.86;
    final stateLabel = isCompleted
        ? null
        : isCurrent
        ? 'Now'
        : isNextUp
        ? 'Next'
        : isLocked
        ? 'Locked'
        : null;
    final meta = isCompleted
        ? _learnCopyV1(context, en: 'Replay available', ru: 'Можно повторить')
        : isCurrent
        ? _learnCopyV1(
            context,
            en: 'Current mission above',
            ru: 'Текущая миссия выше',
          )
        : isNextUp
        ? _learnCopyV1(
            context,
            en: 'Opens after the current mission',
            ru: 'Откроется после текущей миссии',
          )
        : _learnCopyV1(context, en: 'Unlocks later', ru: 'Откроется позже');
    final icon = isCompleted
        ? Icons.check_rounded
        : isCurrent
        ? Icons.my_location_rounded
        : isLocked
        ? Icons.lock_rounded
        : Icons.circle_rounded;
    final fill = isCurrent
        ? _learnV6Blue.withValues(alpha: 0.075)
        : isCompleted
        ? _learnV6Cyan.withValues(alpha: 0.040)
        : isNextUp
        ? _learnV6Gold.withValues(alpha: 0.045)
        : Act0ShellTokensV1.textDim.withValues(alpha: 0.012);
    final border = isCurrent
        ? _learnV6Cyan.withValues(alpha: 0.20)
        : isCompleted
        ? _learnV6Cyan.withValues(alpha: 0.10)
        : isNextUp
        ? _learnV6Gold.withValues(alpha: 0.18)
        : Act0ShellTokensV1.border.withValues(alpha: 0.045);

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: Color.alphaBlend(fill, _learnV6Deep),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            border: Border.all(color: border),
            boxShadow: <BoxShadow>[
              if (isCurrent || expanded)
                BoxShadow(
                  color: _learnV6Blue.withValues(alpha: 0.09),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                key: Key('act0_shell_lesson_${lesson.title}'),
                onTap: () => onSelectLesson(lesson.lessonId),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCurrent ? 11 : 9,
                    isCurrent
                        ? 9
                        : isCompleted
                        ? 7
                        : 8,
                    9,
                    isCurrent
                        ? 9
                        : isCompleted
                        ? 7
                        : 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isCompleted ? 23 : 28,
                        height: isCompleted ? 23 : 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              accent.withValues(
                                alpha: isCompleted ? 0.28 : 0.16,
                              ),
                              _learnV6Blue.withValues(
                                alpha: isCompleted ? 0.035 : 0.045,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            isCompleted ? 8 : 10,
                          ),
                          border: Border.all(
                            color: accent.withValues(
                              alpha: isCompleted ? 0.16 : 0.22,
                            ),
                          ),
                        ),
                        child: isCompleted
                            ? Icon(
                                icon,
                                key: const Key(
                                  'act0_shell_journey_completed_achieved_v5',
                                ),
                                color: accent,
                                size: 14,
                              )
                            : Text(
                                '$index',
                                key: isNextUp
                                    ? const Key(
                                        'act0_shell_journey_v6_next_soft_gold',
                                      )
                                    : null,
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: accent,
                                  fontSize: 10.0,
                                  letterSpacing: 0,
                                ),
                              ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        key: isCurrent
                            ? const Key('act0_shell_journey_v6_progress_depth')
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act0LocalizedLessonTitleV1(context, lesson),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: Act0ShellTokensV1.cardTitle.copyWith(
                                color: isLocked
                                    ? Act0ShellTokensV1.textMuted
                                    : Act0ShellTokensV1.text,
                                fontSize: isCompleted ? 12.8 : 13.6,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: Act0ShellTokensV1.muted.copyWith(
                                color: isLocked
                                    ? Act0ShellTokensV1.textDim
                                    : Act0ShellTokensV1.textMuted,
                                fontSize: 10.2,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (stateLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.055),
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusPill,
                            ),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Text(
                            stateLabel,
                            key: Key(
                              'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: accent,
                              fontSize: 9.0,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: accent.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 140),
                  reverseDuration: const Duration(milliseconds: 110),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: expandedBody == null
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: accent.withValues(alpha: 0.12),
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

class _JourneyFutureSummaryV5 extends StatelessWidget {
  const _JourneyFutureSummaryV5({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final minHeight = size.height >= 1080
        ? 230.0
        : size.height >= 900
        ? 118.0
        : 84.0;
    final label = _learnCopyV1(
      context,
      en: count == 1
          ? '1 lesson unlocks as you progress'
          : '$count lessons unlock as you progress',
      ru: count == 1
          ? '1 урок откроется дальше'
          : '$count уроков откроются дальше',
    );
    return Container(
      key: const Key('act0_shell_locked_journey_summary'),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          Act0ShellTokensV1.primary.withValues(alpha: 0.010),
          Act0ShellTokensV1.background,
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.primary.withValues(alpha: 0.035),
        ),
      ),
      child: Column(
        key: const Key('act0_shell_journey_preview_closeout'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_open_rounded,
                size: 14,
                color: Act0ShellTokensV1.primary.withValues(alpha: 0.54),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  key: const Key('act0_shell_learn_v5_future_summary'),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontSize: 10.8,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _learnCopyV1(context, en: 'In order', ru: 'По порядку'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.textDim,
                  fontSize: 8.8,
                  letterSpacing: 0.08,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 1; i <= 3; i++) ...[
                Container(
                  key: Key('act0_shell_journey_future_milestone_dot_$i'),
                  width: i == 1 ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    color: i == 1
                        ? Act0ShellTokensV1.primary.withValues(alpha: 0.12)
                        : Act0ShellTokensV1.textDim.withValues(alpha: 0.12),
                    border: Border.all(
                      color: i == 1
                          ? Act0ShellTokensV1.primary.withValues(alpha: 0.18)
                          : Act0ShellTokensV1.border.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                if (i < 3)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      color: Act0ShellTokensV1.border.withValues(alpha: 0.07),
                    ),
                  ),
              ],
            ],
          ),
          if (minHeight > 100) ...[
            SizedBox(height: minHeight >= 200 ? 82 : 18),
            Container(
              key: const Key('act0_shell_learn_v5_path_floor'),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Act0ShellTokensV1.primary.withValues(alpha: 0.035),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: Act0ShellTokensV1.primary.withValues(alpha: 0.035),
                ),
              ),
              child: Text(
                _learnCopyV1(
                  context,
                  en: 'The road ahead opens one mission at a time.',
                  ru: 'Путь впереди открывается по одной миссии.',
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textDim.withValues(alpha: 0.86),
                  fontSize: 10.8,
                  height: 1.12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<int> _focusedJourneyLessonIndexesV1(List<Act0LessonCardV1> lessons) {
  return <int>[
    for (var i = 0; i < lessons.length; i++)
      if (_shouldShowJourneyLessonInWindowV1(lessons, i)) i,
  ];
}

bool _shouldShowJourneyLessonInWindowV1(
  List<Act0LessonCardV1> lessons,
  int index,
) {
  final lesson = lessons[index];
  if (lesson.state != Act0LessonStateV1.locked) {
    return true;
  }
  return index > 0 && lessons[index - 1].state == Act0LessonStateV1.current;
}

class _LockedJourneySummaryV1 extends StatelessWidget {
  const _LockedJourneySummaryV1({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final widePreview = viewportWidth >= 700;
    final compactPreview = viewportWidth < 420;
    final label = _learnCopyV1(
      context,
      en: count == 1
          ? '1 lesson unlocks as you progress'
          : '$count lessons unlock as you progress',
      ru: count == 1 ? '1 урок закрыт дальше' : '$count уроков закрыты дальше',
    );
    return FractionallySizedBox(
      widthFactor: _Act0LearnPathShellV1State._learnPathCardWidthFactorV1,
      child: Container(
        key: const Key('act0_shell_locked_journey_summary'),
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: widePreview
              ? 150
              : compactPreview
              ? 72
              : 84,
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            Act0ShellTokensV1.primary.withValues(alpha: 0.018),
            Act0ShellTokensV1.background,
          ),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
          border: Border.all(
            color: Act0ShellTokensV1.primary.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          key: const Key('act0_shell_journey_preview_closeout'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: 14,
                  color: Act0ShellTokensV1.primary.withValues(alpha: 0.64),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted.withValues(
                        alpha: 0.96,
                      ),
                      fontSize: 11.2,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _learnCopyV1(context, en: 'In order', ru: 'По порядку'),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.textDim,
                    fontSize: 8.8,
                    letterSpacing: 0.10,
                  ),
                ),
              ],
            ),
            SizedBox(height: widePreview ? 26 : 10),
            Row(
              children: [
                for (var i = 1; i <= 3; i++) ...[
                  Container(
                    key: Key('act0_shell_journey_future_milestone_dot_$i'),
                    width: i == 1 ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      color: i == 1
                          ? Act0ShellTokensV1.primary.withValues(alpha: 0.18)
                          : Act0ShellTokensV1.textDim.withValues(alpha: 0.18),
                      border: Border.all(
                        color: i == 1
                            ? Act0ShellTokensV1.primary.withValues(alpha: 0.18)
                            : Act0ShellTokensV1.border.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  if (i < 3)
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        color: Act0ShellTokensV1.border.withValues(alpha: 0.10),
                      ),
                    ),
                ],
              ],
            ),
            SizedBox(height: widePreview ? 18 : 7),
            Text(
              _learnCopyV1(
                context,
                en: 'The road continues when the next mission clears.',
                ru: 'Путь продолжается, когда следующая миссия закрыта.',
              ),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textDim.withValues(alpha: 0.82),
                fontSize: 10.3,
                height: 1.10,
              ),
            ),
          ],
        ),
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
    required this.showDefaultTaskFocus,
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
  final bool showDefaultTaskFocus;
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
        : _selectedLessonGuidanceV1(
            context: context,
            lesson: lesson,
            nextTask: nextTask,
          );
    final fallbackSelectedTaskId =
        tasks.any((task) => task.taskId == selectedTaskId)
        ? selectedTaskId
        : nextTask.taskId;
    final visibleTaskFocusId =
        activePopupTaskId ??
        (showDefaultTaskFocus ? fallbackSelectedTaskId : null);

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
        onTap: visibleTaskFocusId == null ? null : onDismissTaskPopup,
        child: TapRegion(
          onTapOutside: visibleTaskFocusId == null
              ? null
              : (_) => onDismissTaskPopup(),
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
              border: Border.all(
                color: stateColor.withValues(alpha: 0.16),
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  stateColor.withValues(alpha: 0.04),
                  Act0ShellTokensV1.surface2.withValues(alpha: 0.4),
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
                        showDetail: tasks[i].taskId == visibleTaskFocusId,
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

class _CurrentMissionCardV1 extends StatelessWidget {
  const _CurrentMissionCardV1({
    required this.lesson,
    required this.task,
    required this.stepIndex,
    required this.totalSteps,
    required this.accent,
    required this.onStart,
  });

  final Act0LessonCardV1 lesson;
  final Act0LessonTaskV1 task;
  final int stepIndex;
  final int totalSteps;
  final Color accent;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final lessonTitle = act0LocalizedLessonTitleV1(context, lesson);
    final taskTitle = act0LocalizedTaskTitleV1(context, task);
    final visualVariant = _missionVisualVariantForV1(lesson, task);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final support = _currentMissionSupportCopyV1(
          context: context,
          lesson: lesson,
          nextTask: task,
          compact: compact,
          visualVariant: visualVariant,
        );
        return Container(
          key: const Key('act0_shell_current_mission_card'),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 15 : 18,
            17,
            compact ? 15 : 18,
            17,
          ),
          decoration: _learnV6PrimarySurfaceDecoration(
            radius: Act0ShellTokensV1.radiusXl,
            borderAlpha: 0.48,
            glowAlpha: 0.24,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                key: const Key('act0_shell_current_mission_premium_depth'),
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: const Key(
                      'act0_shell_current_mission_luminous_frame_v6',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusXl,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          _learnV6Cyan.withValues(alpha: 0.08),
                          Colors.transparent,
                          _learnV6Blue.withValues(alpha: 0.09),
                        ],
                        stops: const <double>[0.0, 0.48, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                key: const Key('act0_shell_current_mission_ambient_visual'),
                right: compact ? -58 : -46,
                top: compact ? -2 : -8,
                child: Transform.rotate(
                  angle: -0.14,
                  child: Container(
                    width: compact ? 250 : 310,
                    height: compact ? 132 : 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          _learnV6Cyan.withValues(alpha: compact ? 0.16 : 0.18),
                          _learnV6Blue.withValues(alpha: 0.10),
                          const Color(0xFF031018).withValues(alpha: 0.02),
                        ],
                      ),
                      border: Border.all(
                        color: _learnV6Cyan.withValues(
                          alpha: compact ? 0.10 : 0.14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _learnV6Cyan.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: _learnV6Cyan.withValues(alpha: 0.40),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: _learnV6Cyan.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _learnCopyV1(context, en: 'Now', ru: 'Сейчас'),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: _learnV6Cyan,
                            fontSize: 9.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _learnCopyV1(
                          context,
                          en: 'Learning path',
                          ru: 'Путь обучения',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          letterSpacing: 0,
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lessonTitle,
                          style: Act0ShellTokensV1.cardTitle.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontSize: compact ? 22.0 : 25.0,
                            height: 1.03,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _learnCopyV1(
                            context,
                            en: 'Why it matters',
                            ru: 'Зачем это нужно',
                          ),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: _learnV6Cyan,
                            fontSize: 9.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          support,
                          key: const Key('act0_shell_current_mission_support'),
                          style: Act0ShellTokensV1.muted.copyWith(
                            color: Act0ShellTokensV1.textMuted,
                            height: 1.28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 18),
                  Container(
                    key: const Key('act0_shell_current_mission_step_card'),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          _learnV6Blue.withValues(alpha: 0.16),
                          _learnV6Navy.withValues(alpha: 0.72),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: _learnV6Cyan.withValues(alpha: 0.16),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _learnV6Blue.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _learnCopyV1(
                            context,
                            en: 'Step $stepIndex of $totalSteps',
                            ru: 'Шаг $stepIndex из $totalSteps',
                          ),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: _learnV6Cyan,
                            letterSpacing: 0,
                            fontSize: 9.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          taskTitle,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      enabled: onStart != null,
                      child: Material(
                        key: const Key('act0_shell_current_mission_cta'),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusPill,
                        ),
                        child: InkWell(
                          key: const Key('act0_shell_start_luminous_cta_v6'),
                          onTap: onStart,
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          child: Ink(
                            height: Act0VisualMetricsV1.primaryCtaHeight,
                            decoration:
                                Act0VisualCanonV1.primaryCtaDecoration(),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _learnCopyV1(
                                    context,
                                    en: 'Start',
                                    ru: 'Старт',
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: Act0ShellTokensV1.cta.copyWith(
                                    color: Act0ShellTokensV1.onPrimary,
                                    fontSize: 15.8,
                                    shadows: const <Shadow>[
                                      Shadow(
                                        color: Color(0x66002244),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _MissionVisualVariantV1 { table, chips, cards, decision, fallback }

_MissionVisualVariantV1 _missionVisualVariantForV1(
  Act0LessonCardV1 lesson,
  Act0LessonTaskV1 task,
) {
  final id = '${lesson.lessonId}_${task.taskId}'.toLowerCase();
  final title = '${lesson.title} ${task.title}'.toLowerCase();
  final text = '$id $title';
  if (text.contains('position') ||
      text.contains('seat') ||
      text.contains('button')) {
    return _MissionVisualVariantV1.table;
  }
  if (text.contains('card') ||
      text.contains('rank') ||
      text.contains('suit') ||
      text.contains('hand')) {
    return _MissionVisualVariantV1.cards;
  }
  if (text.contains('blind') ||
      text.contains('pot') ||
      text.contains('chip') ||
      text.contains('stack')) {
    return _MissionVisualVariantV1.chips;
  }
  if (text.contains('fold') ||
      text.contains('check') ||
      text.contains('call') ||
      text.contains('raise') ||
      text.contains('action')) {
    return _MissionVisualVariantV1.decision;
  }
  return _MissionVisualVariantV1.fallback;
}

class _MissionHubMotifV1 extends StatelessWidget {
  const _MissionHubMotifV1({
    required this.accent,
    required this.compact,
    required this.variant,
  });

  final Color accent;
  final bool compact;
  final _MissionVisualVariantV1 variant;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 82.0 : 104.0;
    final height = compact ? 70.0 : 82.0;
    return Container(
      key: const Key('act0_shell_current_mission_motif'),
      width: width,
      height: height,
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.060),
          const Color(0xFF06131C),
        ),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: KeyedSubtree(
        key: Key('act0_shell_current_mission_visual_${variant.name}'),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width * 0.68,
              height: height * 0.38,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accent.withValues(alpha: 0.08),
                  Act0ShellTokensV1.surface,
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accent.withValues(alpha: 0.24)),
              ),
            ),
            if (variant == _MissionVisualVariantV1.cards)
              ..._buildCardMotifV1(accent, compact)
            else if (variant == _MissionVisualVariantV1.chips)
              ..._buildChipMotifV1(accent, compact)
            else if (variant == _MissionVisualVariantV1.decision)
              ..._buildDecisionMotifV1(accent, compact)
            else
              ..._buildTableMotifV1(
                accent,
                compact,
                heroSeat: variant == _MissionVisualVariantV1.table
                    ? Alignment.topCenter
                    : Alignment.centerRight,
              ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildTableMotifV1(
  Color accent,
  bool compact, {
  required Alignment heroSeat,
}) {
  return <Widget>[
    Container(
      width: compact ? 34 : 42,
      height: compact ? 16 : 18,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
    ),
    for (final seat in const <Alignment>[
      Alignment.topCenter,
      Alignment.centerRight,
      Alignment.bottomRight,
      Alignment.bottomCenter,
      Alignment.bottomLeft,
      Alignment.centerLeft,
    ])
      Align(
        alignment: seat,
        child: Container(
          width: compact ? 8 : 9,
          height: compact ? 8 : 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: seat == heroSeat ? 0.95 : 0.36),
            boxShadow: [
              if (seat == heroSeat)
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
      ),
  ];
}

List<Widget> _buildDecisionMotifV1(Color accent, bool compact) {
  const labels = <String>['F', 'C', 'R'];
  const alignments = <Alignment>[
    Alignment.centerLeft,
    Alignment.topCenter,
    Alignment.centerRight,
  ];
  return <Widget>[
    ..._buildTableMotifV1(accent, compact, heroSeat: Alignment.centerRight),
    for (var i = 0; i < labels.length; i++)
      Align(
        alignment: alignments[i],
        child: Container(
          width: compact ? 17 : 20,
          height: compact ? 17 : 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              accent.withValues(alpha: i == 2 ? 0.24 : 0.11),
              Act0ShellTokensV1.surface,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent.withValues(alpha: i == 2 ? 0.42 : 0.20),
            ),
          ),
          child: Text(
            labels[i],
            style: Act0ShellTokensV1.label.copyWith(
              color: i == 2 ? accent : Act0ShellTokensV1.textMuted,
              fontSize: compact ? 8.0 : 8.8,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
  ];
}

List<Widget> _buildCardMotifV1(Color accent, bool compact) {
  const labels = <String>['A', 'K', 'Q'];
  return <Widget>[
    for (var i = 0; i < labels.length; i++)
      Transform.translate(
        offset: Offset((i - 1) * (compact ? 14.0 : 17.0), i == 1 ? -4 : 3),
        child: Transform.rotate(
          angle: (i - 1) * 0.10,
          child: Container(
            width: compact ? 23 : 27,
            height: compact ? 32 : 38,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.fromLTRB(5, 4, 0, 0),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                accent.withValues(alpha: i == 1 ? 0.16 : 0.09),
                Act0ShellTokensV1.surface,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: accent.withValues(alpha: i == 1 ? 0.36 : 0.22),
              ),
            ),
            child: Text(
              labels[i],
              style: Act0ShellTokensV1.label.copyWith(
                color: i == 1 ? accent : Act0ShellTokensV1.textMuted,
                fontSize: compact ? 8.8 : 9.6,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
  ];
}

List<Widget> _buildChipMotifV1(Color accent, bool compact) {
  return <Widget>[
    for (var i = 0; i < 4; i++)
      Transform.translate(
        offset: Offset(i * (compact ? 4.0 : 5.0), -i * 4.0),
        child: Container(
          width: compact ? 28 : 32,
          height: compact ? 10 : 12,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.11 + i * 0.035),
              Act0ShellTokensV1.surface,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent.withValues(alpha: 0.18 + i * 0.045),
            ),
          ),
        ),
      ),
    Transform.translate(
      offset: Offset(compact ? -20 : -24, compact ? 14 : 16),
      child: Container(
        width: compact ? 18 : 21,
        height: compact ? 18 : 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.18),
          border: Border.all(color: accent.withValues(alpha: 0.34)),
        ),
        child: Container(
          width: compact ? 7 : 8,
          height: compact ? 7 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.32),
          ),
        ),
      ),
    ),
  ];
}

class _LearnRouteSpineNodeV1 extends StatelessWidget {
  const _LearnRouteSpineNodeV1({
    required this.index,
    required this.lesson,
    required this.isNextUp,
    required this.isLast,
    required this.child,
  });

  final int index;
  final Act0LessonCardV1 lesson;
  final bool isNextUp;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final stateTone = switch (lesson.state) {
      Act0LessonStateV1.current => Act0ShellTokensV1.primary,
      Act0LessonStateV1.completed => Act0ShellTokensV1.textMuted,
      Act0LessonStateV1.locked =>
        isNextUp ? Act0ShellTokensV1.gold : Act0ShellTokensV1.textDim,
    };
    final lineAlpha = switch (lesson.state) {
      Act0LessonStateV1.current => 0.26,
      Act0LessonStateV1.completed => 0.14,
      Act0LessonStateV1.locked => isNextUp ? 0.22 : 0.12,
    };
    final nodeFillAlpha = switch (lesson.state) {
      Act0LessonStateV1.current => 0.15,
      Act0LessonStateV1.completed => 0.07,
      Act0LessonStateV1.locked => isNextUp ? 0.12 : 0.05,
    };
    final nodeBorderAlpha = switch (lesson.state) {
      Act0LessonStateV1.current => 0.58,
      Act0LessonStateV1.completed => 0.24,
      Act0LessonStateV1.locked => isNextUp ? 0.42 : 0.22,
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
              color: stateTone.withValues(alpha: lineAlpha),
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
                stateTone.withValues(alpha: nodeFillAlpha),
                Act0ShellTokensV1.surface,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: stateTone.withValues(alpha: nodeBorderAlpha),
              ),
              boxShadow: <BoxShadow>[
                if (lesson.state == Act0LessonStateV1.current || isNextUp)
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
                          color: color.withValues(alpha: 0.18),
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
                                        boxShadow: [
                                          if (widget.isCurrent)
                                            BoxShadow(
                                              color: rowAccent.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 6,
                                            ),
                                        ],
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
              duration: const Duration(milliseconds: 110),
              reverseDuration: const Duration(milliseconds: 90),
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
    final compactHeader = MediaQuery.sizeOf(context).width < 420;
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
        padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
          border: Border.all(color: accent.withValues(alpha: 0.09), width: 1.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              const Color(0xFF06131C).withValues(alpha: 0.96),
              const Color(0xFF071923).withValues(alpha: 0.80),
              Act0ShellTokensV1.background.withValues(alpha: 0.74),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    '$worldNumber',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 10.2,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _learnCopyV1(
                          context,
                          en: compactHeader
                              ? title
                              : 'World $worldNumber · $title',
                          ru: compactHeader
                              ? title
                              : 'Мир $worldNumber · $title',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.sectionTitle.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: 12.6,
                          height: 1.02,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compactHeader) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
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
                        fontSize: 8.4,
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Tooltip(
                  message: _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                  child: OutlinedButton.icon(
                    key: const Key('act0_shell_levels_menu_button'),
                    onPressed: onOpenWorldMenu,
                    style: Act0ShellTokensV1.quietButtonStyle(height: 26)
                        .copyWith(
                          minimumSize: const WidgetStatePropertyAll(
                            Size(0, 26),
                          ),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: compactHeader ? 7 : 8,
                            ),
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            accent.withValues(alpha: 0.95),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            accent.withValues(alpha: 0.08),
                          ),
                          side: const WidgetStatePropertyAll(BorderSide.none),
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
                    icon: Icon(
                      Icons.map_rounded,
                      size: 13,
                      color: accent.withValues(alpha: 0.95),
                    ),
                    label: compactHeader
                        ? const SizedBox.shrink()
                        : Text(_learnCopyV1(context, en: 'Worlds', ru: 'Миры')),
                  ),
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
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 9.6,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              child: LinearProgressIndicator(
                key: const Key('act0_shell_learn_progress_bar'),
                value: normalizedProgress,
                minHeight: 1.5,
                backgroundColor: Act0ShellTokensV1.surface.withValues(
                  alpha: 0.72,
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
    required this.disableExpansionAnimation,
    required this.onSelectLesson,
    required this.expandedBody,
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
  final bool disableExpansionAnimation;
  final bool Function(String lessonId) onSelectLesson;
  final Widget? expandedBody;

  @override
  Widget build(BuildContext context) {
    final compactLessonChrome = MediaQuery.sizeOf(context).width <= 440;
    final isCompleted = lesson.state == Act0LessonStateV1.completed;
    final isCurrent = lesson.state == Act0LessonStateV1.current;
    final isLocked = lesson.state == Act0LessonStateV1.locked;
    final isCompletedQuiet = isCompleted && !selected && !expanded;
    final isInProgress =
        isCurrent &&
        lesson.taskList.any((t) => pathClosedTaskIds.contains(t.taskId)) &&
        lesson.taskList.any((t) => !pathClosedTaskIds.contains(t.taskId));
    final stateColor = _stateColor(lesson.state);
    final completedAccent = Act0ShellTokensV1.primary;
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
        ? (expanded ? '$totalSteps steps complete' : '')
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
    final showStateBadge = !(isCompleted && !expanded);
    final cardTint = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : worldAccent)
              .withValues(alpha: 0.034)
        : isCurrent
        ? currentAccent.withValues(alpha: 0.070)
        : isCompletedQuiet
        ? completedAccent.withValues(alpha: 0.018)
        : isLocked
        ? Act0ShellTokensV1.textDim.withValues(alpha: 0.004)
        : (isHighlighted ? stateColor : worldAccent).withValues(
            alpha: isHighlighted ? 0.036 : 0.024,
          );
    final cardBorderColor = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : Act0ShellTokensV1.border)
              .withValues(alpha: isCurrent ? 0.42 : 0.28)
        : isCurrent
        ? currentAccent.withValues(alpha: 0.20)
        : isCompleted
        ? completedAccent.withValues(alpha: isCompletedQuiet ? 0.075 : 0.08)
        : isLocked
        ? Act0ShellTokensV1.border.withValues(alpha: 0.12)
        : isHighlighted
        ? stateColor.withValues(alpha: 0.15)
        : Act0ShellTokensV1.border.withValues(alpha: 0.34);
    final cardGlowColor = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : worldAccent)
              .withValues(alpha: isCurrent ? 0.14 : 0.04)
        : (isCurrent ? currentAccent : stateColor).withValues(
            alpha: isCurrent ? 0.08 : 0.05,
          );
    final leadColor = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : worldAccent)
              .withValues(alpha: isLocked ? 0.28 : 0.74)
        : (isCurrent ? currentAccent : stateColor).withValues(
            alpha: isLocked
                ? 0.30
                : isCurrent
                ? 0.54
                : 0.62,
          );
    final iconTint = isCurrent
        ? currentAccent
        : isCompleted
        ? completedAccent
        : isNextUp
        ? nextAccent
        : isExpandedFocus
        ? worldAccent
        : stateColor;
    final badgeTint = isCurrent
        ? currentAccent
        : isCompleted
        ? completedAccent
        : isNextUp
        ? nextAccent
        : isExpandedFocus
        ? worldAccent
        : stateColor;
    final cardRadius = BorderRadius.circular(
      isCompletedQuiet
          ? Act0ShellTokensV1.radiusMd
          : Act0ShellTokensV1.radiusLg,
    );
    final rowPadding = EdgeInsets.fromLTRB(
      isCurrent ? 14 : 10,
      isCompletedQuiet ? 5 : 8,
      10,
      isCompletedQuiet ? 5 : 8,
    );
    final rowTitleStyle = Act0ShellTokensV1.cardTitle.copyWith(
      color: isCompletedQuiet
          ? Act0ShellTokensV1.textMuted.withValues(alpha: 0.92)
          : Act0ShellTokensV1.text,
      fontSize: isCompletedQuiet ? 13.0 : 14.2,
      height: 1.08,
    );

    return Opacity(
      opacity: lesson.state == Act0LessonStateV1.locked
          ? 0.54
          : isCompletedQuiet
          ? 0.82
          : isCurrent && !expanded
          ? 0.85
          : 1.0,
      child: Material(
        borderRadius: cardRadius,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              cardTint,
              isCompletedQuiet
                  ? Act0ShellTokensV1.background
                  : Act0ShellTokensV1.surface2,
            ),
            borderRadius: cardRadius,
            border: Border.all(
              color: isExpandedFocus
                  ? cardBorderColor
                  : cardBorderColor.withValues(
                      alpha: isCompletedQuiet
                          ? 0.26
                          : isLocked
                          ? 0.32
                          : 0.68,
                    ),
            ),
            boxShadow: <BoxShadow>[
              if (!isCompletedQuiet)
                const BoxShadow(
                  color: Color(0x0E000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              if (isHighlighted && !isExpandedFocus)
                BoxShadow(
                  color: cardGlowColor.withValues(alpha: 0.50),
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Stack(
            children: [
              if (isCurrent)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  width: 2.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: currentAccent.withValues(alpha: 0.72),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(2.5),
                        bottomRight: Radius.circular(2.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentAccent.withValues(alpha: 0.22),
                          blurRadius: 5,
                          offset: const Offset(1, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    key: Key('act0_shell_lesson_${lesson.title}'),
                    borderRadius: cardRadius,
                    onTap: () => onSelectLesson(lesson.lessonId),
                    child: Padding(
                      padding: rowPadding,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isCompletedQuiet ? 24 : 32,
                            height: isCompletedQuiet ? 24 : 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? iconTint.withValues(
                                      alpha: isCompletedQuiet ? 0.090 : 0.10,
                                    )
                                  : iconTint.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(
                                isCompletedQuiet ? 8 : 10,
                              ),
                              border: Border.all(
                                color: iconTint.withValues(
                                  alpha: isCompletedQuiet ? 0.16 : 0.20,
                                ),
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: iconTint.withValues(
                                alpha: isCompletedQuiet ? 0.78 : 1.0,
                              ),
                              size: isCompletedQuiet ? 13 : 16,
                            ),
                          ),
                          SizedBox(width: isCompletedQuiet ? 7 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (compactLessonChrome)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lessonTitle,
                                          style: rowTitleStyle,
                                          maxLines: isCompletedQuiet ? 1 : 2,
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (showStateBadge)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeTint.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              Act0ShellTokensV1.radiusPill,
                                            ),
                                            border: Border.all(
                                              color: badgeTint.withValues(
                                                alpha: 0.13,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            stateBadgeLabel,
                                            key: Key(
                                              'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            style: Act0ShellTokensV1.label
                                                .copyWith(
                                                  color: badgeTint,
                                                  letterSpacing: 0.06,
                                                  fontSize: 9.0,
                                                ),
                                          ),
                                        ),
                                      const SizedBox(width: 2),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 1),
                                        child: AnimatedRotation(
                                          turns: expanded ? 0.5 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 280,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 17,
                                            color: badgeTint.withValues(
                                              alpha: 0.62,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        duration: const Duration(
                                          milliseconds: 280,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 17,
                                          color: badgeTint.withValues(
                                            alpha: 0.62,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      if (showStateBadge)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeTint.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              Act0ShellTokensV1.radiusPill,
                                            ),
                                            border: Border.all(
                                              color: badgeTint.withValues(
                                                alpha: 0.13,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            stateBadgeLabel,
                                            key: Key(
                                              'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            style: Act0ShellTokensV1.label
                                                .copyWith(
                                                  color: badgeTint,
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
                                    style: rowTitleStyle,
                                    maxLines: isCompletedQuiet ? 1 : 2,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
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
                    child: disableExpansionAnimation
                        ? (expandedBody == null
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
                                        color: badgeTint.withValues(
                                          alpha: 0.14,
                                        ),
                                      ),
                                    ),
                                    expandedBody!,
                                  ],
                                ))
                        : AnimatedSize(
                            duration: const Duration(milliseconds: 140),
                            reverseDuration: const Duration(milliseconds: 110),
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
                                          color: badgeTint.withValues(
                                            alpha: 0.14,
                                          ),
                                        ),
                                      ),
                                      expandedBody!,
                                    ],
                                  ),
                          ),
                  ),
                ],
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

String _currentMissionSupportCopyV1({
  required BuildContext context,
  required Act0LessonCardV1 lesson,
  required Act0LessonTaskV1 nextTask,
  required bool compact,
  required _MissionVisualVariantV1 visualVariant,
}) {
  if (compact && visualVariant == _MissionVisualVariantV1.chips) {
    return _learnCopyV1(
      context,
      en: 'Learn what goes into the pot and what stays with a player.',
      ru: 'Узнай, что идет в банк, а что остается у игрока.',
    );
  }
  return _selectedLessonGuidanceV1(
    context: context,
    lesson: lesson,
    nextTask: nextTask,
  );
}

String _selectedLessonGuidanceV1({
  required BuildContext context,
  required Act0LessonCardV1 lesson,
  required Act0LessonTaskV1 nextTask,
}) {
  final nextTaskTitle = act0LocalizedTaskTitleV1(context, nextTask).trim();
  final nextTaskSummary = act0LocalizedTaskSummaryV1(
    context,
    nextTask,
    fallback: nextTask.summary ?? nextTask.runner.caption,
  ).trim();
  final safeSummary =
      nextTaskSummary.isEmpty || nextTaskSummary == nextTaskTitle
      ? null
      : nextTaskSummary;

  if (lesson.state == Act0LessonStateV1.current) {
    return safeSummary == null
        ? _learnCopyV1(
            context,
            en: 'Start here: $nextTaskTitle.',
            ru: 'Начни здесь: $nextTaskTitle.',
          )
        : _learnCopyV1(
            context,
            en: 'Start here: $nextTaskTitle. $safeSummary',
            ru: 'Начни здесь: $nextTaskTitle. $safeSummary',
          );
  }

  return safeSummary == null
      ? _learnCopyV1(
          context,
          en: 'Inside: $nextTaskTitle.',
          ru: 'Внутри: $nextTaskTitle.',
        )
      : _learnCopyV1(
          context,
          en: 'Inside: $nextTaskTitle. $safeSummary',
          ru: 'Внутри: $nextTaskTitle. $safeSummary',
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
