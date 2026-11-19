import 'dart:async' show Timer, unawaited;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

part 'act0_learn_path_journey_v1.dart';
part 'act0_learn_path_world_menu_v1.dart';
part 'act0_learn_path_mission_v1.dart';
part 'act0_learn_path_cards_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ru';

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
    Act0WorldStateV1.completed => Act0AcademyDesignTokensV1.focus,
    Act0WorldStateV1.current => Act0AcademyDesignTokensV1.focus,
    Act0WorldStateV1.locked =>
      _isImmediateNextWorldV1(worlds, world)
          ? Act0AcademyDesignTokensV1.needsReviewFg
          : Act0AcademyDesignTokensV1.inkMuted,
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
    if (routeLesson == null || routeLesson.courseTaskList.isEmpty) {
      return null;
    }
    Act0LessonTaskV1? routeTask;
    for (final task in routeLesson.courseTaskList) {
      if (task.taskId == widget.selectedTaskId) {
        routeTask = task;
        break;
      }
    }
    routeTask ??= routeLesson.courseTaskList.first;
    return act0AcademyTaskTitleV1(context, routeTask);
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
    final currentMissionTask = currentMissionLesson.courseTaskList.firstWhere(
      (task) => !widget.pathClosedTaskIds.contains(task.taskId),
      orElse: () => currentMissionLesson.courseTaskList.first,
    );
    final currentMissionStepIndex =
        currentMissionLesson.courseTaskList.indexWhere(
          (task) => task.taskId == currentMissionTask.taskId,
        ) +
        1;
    final isFirstLessonLanding =
        currentMissionLesson.lessonId == 'what_poker_is' &&
        currentMissionStepIndex == 1 &&
        detailLessonId == null;
    // Routing may be closed by Placement; the visible progress bar is earned
    // completion only. Keep lesson.state for existing navigation/eligibility.
    final progressFraction = widget.lessons.isEmpty
        ? 0.0
        : widget.lessons
                  .where(
                    (lesson) =>
                        lesson.courseTaskList.isNotEmpty &&
                        lesson.courseTaskList.every(
                          (task) =>
                              widget.completedTaskIds.contains(task.taskId),
                        ),
                  )
                  .length /
              widget.lessons.length;
    final journeyLessonIndexes =
        _missionFirstJourneyPreviewIndexesV5(
              widget.lessons,
              showFullPath: _showFullJourneyPathV5,
            )
            .where(
              (index) =>
                  widget.lessons[index].lessonId !=
                  currentMissionLesson.lessonId,
            )
            .toList();
    final deferredLockedCount = _hiddenLockedLessonCountV5(
      widget.lessons,
      journeyLessonIndexes,
    );
    return TapRegionSurface(
      child: Stack(
        key: _learnStackKey,
        children: [
          Positioned.fill(
            child: ColoredBox(
              key: const Key('act0_shell_learn_page_background'),
              color: Act0AcademyDesignTokensV1.pageSurface,
            ),
          ),
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
                        detailMode: detailLessonId != null,
                        firstLessonLanding: isFirstLessonLanding,
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
