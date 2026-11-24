import 'academy_leaves/act0_academy_home_leaf_v1.dart';
import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';
import 'act0_curriculum_pilot_v1.dart';
import 'act0_goal_route_v1.dart';
import 'act0_learn_path_view_model_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'skin/act0_skin_tokens_v1.dart';

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

String _learnPlayerCopyV1(String text) => text
    .replaceAll(RegExp(r"\bHero[’']s\b"), 'Your')
    .replaceAll(RegExp(r'\bHero\b'), 'You');

String _learnTaskTitleV1(BuildContext context, Act0LessonTaskV1 task) =>
    _learnPlayerCopyV1(act0AcademyTaskTitleV1(context, task));

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
    Act0WorldStateV1.passedByRulesCheck => 'Skipped by rules check',
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
    Act0WorldStateV1.completed ||
    Act0WorldStateV1.passedByRulesCheck => Act0SkinTokensV1.accent,
    Act0WorldStateV1.current => Act0SkinTokensV1.accent,
    Act0WorldStateV1.locked =>
      _isImmediateNextWorldV1(worlds, world)
          ? Act0SkinTokensV1.accent
          : Act0SkinTokensV1.muted,
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
    this.liveRoomTitle,
    this.goalRoute,
    required this.selectedWorldId,
    required this.showWorldMenu,
    this.onW1RulesCheck,
    this.nextAction,
    this.dayGoalDone,
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
    this.requiredPractice,
    this.requiredPracticeAnswered = 0,
    this.onStartRequiredPractice,
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
  final String? liveRoomTitle;
  final Act0GoalRouteViewModelV1<Act0WorldCardV1>? goalRoute;
  final String selectedWorldId;
  final bool showWorldMenu;
  final VoidCallback? onW1RulesCheck;
  final Act0AcademyHomeNextActionV1? nextAction;
  final bool? dayGoalDone;
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
  final Act0LessonCardV1? requiredPractice;
  final int requiredPracticeAnswered;
  final VoidCallback? onStartRequiredPractice;
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
      if (MediaQuery.disableAnimationsOf(context)) {
        _learnScrollController.jumpTo(top);
        return;
      }
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
        Act0SkinTokensV1.bottomNavHeight -
        Act0SkinTokensV1.gapLg;
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
    if (MediaQuery.disableAnimationsOf(context)) {
      _learnScrollController.jumpTo(target);
      return;
    }
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
        Act0SkinTokensV1.bottomNavHeight -
        Act0SkinTokensV1.gapLg -
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
    if (MediaQuery.disableAnimationsOf(context)) {
      _learnScrollController.jumpTo(target);
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
    return _learnTaskTitleV1(context, routeTask);
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
    final view = Act0LearnPathViewModelV1(
      worlds: widget.worlds,
      lessons: widget.lessons,
      selectedWorldId: widget.selectedWorldId,
      selectedLessonId: widget.selectedLessonId,
      detailLessonId: widget.detailLessonId,
      worldDetailId: widget.worldDetailId,
      requiredPractice: widget.requiredPractice,
      requiredPracticeAnswered: widget.requiredPracticeAnswered,
      pathClosedTaskIds: widget.pathClosedTaskIds,
      completedTaskIds: widget.completedTaskIds,
      showFullPath: _showFullJourneyPathV5,
      catalogFlag: act0CurriculumPilotEnabledV1,
    );
    final detailLesson = view.detailLesson;
    final selectedWorld = view.selectedWorld;
    final detailLessonId = widget.detailLessonId;
    final journeyDetailLessonId = _showFullJourneyPathV5
        ? _fullPathManualExpandedLessonIdV6
        : detailLessonId;
    final shouldShowDefaultTaskFocus =
        detailLesson != null && _shouldShowDefaultTaskFocusV1(detailLesson);
    final currentMissionLesson = view.currentMissionLesson;
    final currentMissionTask = view.currentMissionTask;
    return TapRegionSurface(
      child: Stack(
        key: _learnStackKey,
        children: [
          Positioned.fill(
            child: ColoredBox(
              key: const Key('act0_shell_learn_page_background'),
              color: Act0SkinTokensV1.background,
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
                if (widget.onW1RulesCheck != null && detailLessonId == null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Act0SkinTokensV1.screenGutter,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Act0SkinListRowV1(
                        controlKey: const Key('act0_shell_w1_rules_map'),
                        title: 'Check W1 rules',
                        subtitle: 'Pass to unlock W2 and skip the W1 lessons.',
                        expanded: false,
                        dark: true,
                        expandable: false,
                        onTap: widget.onW1RulesCheck,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Act0SkinTokensV1.screenGutter,
                    Act0SkinTokensV1.gapXs,
                    Act0SkinTokensV1.screenGutter,
                    Act0SkinTokensV1.gapSm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.sizeOf(context).shortestSide >=
                                  Act0SkinTokensV1.tabletMinWidth
                              ? Act0SkinTokensV1.wideContentMaxWidth
                              : Act0SkinTokensV1.contentMaxWidth,
                        ),
                        child: _LearnMissionFirstBodyV5(
                          pinnedHeaderKey: _pinnedModuleHeaderKey,
                          dayGoalDone: widget.dayGoalDone,
                          world: selectedWorld,
                          moduleTitle: widget.moduleTitle,
                          moduleProgressLabel: widget.moduleProgressLabel,
                          lessonCount: widget.lessons.length,
                          progressFraction: view.progressFraction,
                          onOpenWorldMenu: widget.onOpenWorldMenu,
                          onDismissDetail: widget.detailLessonId == null
                              ? null
                              : widget.onDismissDetail,
                          currentMissionLesson: currentMissionLesson,
                          currentMissionTask: currentMissionTask,
                          currentMissionStepIndex: view.currentMissionStepIndex,
                          detailMode: detailLessonId != null,
                          firstLessonLanding: view.firstRun,
                          onStartMission:
                              widget.onStartRequiredPractice ??
                              (currentMissionLesson.isSelectable
                                  ? () => widget.onStartTask(
                                      currentMissionLesson.lessonId,
                                      currentMissionTask.taskId,
                                    )
                                  : null),
                          lessons: widget.lessons,
                          journeyLessonIndexes: view.journeyLessonIndexes,
                          deferredLockedCount: view.deferredLockedCount,
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
                          shouldShowDefaultTaskFocus:
                              shouldShowDefaultTaskFocus,
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
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Act0SkinTokensV1.screenGutter,
                    Act0SkinTokensV1.gapMd,
                    Act0SkinTokensV1.screenGutter,
                    Act0SkinTokensV1.bottomNavHeight,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.nextAction case final action?)
                          Act0SkinSecondaryButtonV1(
                            label: '${action.title} · ${action.ctaLabel}',
                            onPressed: action.onPressed,
                          ),
                        if (widget.liveRoomTitle case final title?
                            when widget.selectedWorldId !=
                                    act0LiveRoomModuleIdV1 &&
                                detailLessonId == null)
                          Act0SkinSecondaryButtonV1(
                            controlKey: const Key('act0_shell_live_room_v1'),
                            label: title,
                            onPressed: () =>
                                widget.onSelectWorld(act0LiveRoomModuleIdV1),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showWorldMenu)
            Positioned.fill(
              child: _WorldMenuOverlayV1(
                view: view,
                selectedWorldId: widget.selectedWorldId,
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

class _LearnButtonV1 extends InkWell {
  const _LearnButtonV1({
    required super.key,
    required super.onTap,
    required super.borderRadius,
    required super.child,
  });

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(button: true, child: super.build(context)),
  );
}
