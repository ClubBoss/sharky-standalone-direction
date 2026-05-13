import 'dart:async' show Completer, Timer, unawaited;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
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
  static const double _learnPathCardWidthFactorV1 = 0.88;
  static const double _inlineLessonHubWidthFactorV1 = 0.96;
  static const double _levelsWorldNodeWidthFactorV1 = 0.76;
  static const double _tailPhantomSpacerHeightV1 = 320;
  final Map<String, GlobalKey> _lessonKeys = <String, GlobalKey>{};
  final Map<String, LayerLink> _taskLinks = <String, LayerLink>{};
  final GlobalKey _learnStackKey = GlobalKey();
  final GlobalKey _pinnedModuleHeaderKey = GlobalKey();
  final GlobalKey _selectedLessonPanelKey = GlobalKey();
  final ScrollController _learnScrollController = ScrollController();
  final Set<Timer> _pendingTimersV1 = <Timer>{};
  int _scrollEpochV1 = 0;
  String? _expansionReadyLessonIdV1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialLessonId = widget.detailLessonId ?? widget.selectedLessonId;
      if (!mounted) {
        return;
      }
      _handleLessonOpenedV1(initialLessonId, from: null);
    });
  }

  @override
  void didUpdateWidget(covariant Act0LearnPathShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWorldId != oldWidget.selectedWorldId) {
      _scrollToTopOnWorldSwitchV1();
    }
    if (widget.detailLessonId != null &&
        widget.detailLessonId != oldWidget.detailLessonId) {
      _handleLessonOpenedV1(
        widget.detailLessonId!,
        from: oldWidget.detailLessonId,
      );
    } else if (widget.detailLessonId == null &&
        oldWidget.detailLessonId != null &&
        _expansionReadyLessonIdV1 != null) {
      setState(() {
        _expansionReadyLessonIdV1 = null;
      });
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
    if (_expansionReadyLessonIdV1 != null) {
      setState(() {
        _expansionReadyLessonIdV1 = null;
      });
    }
    unawaited(() async {
      if (from != null) {
        await _waitWithCancelV1(_inlineLessonHubCollapseDurationV1);
      }
      if (epoch != _scrollEpochV1 ||
          !mounted ||
          widget.detailLessonId != newLessonId) {
        return;
      }
      setState(() {
        _expansionReadyLessonIdV1 = newLessonId;
      });
      await _waitForLearnLayoutSettleV1(frames: from == null ? 2 : 1);
      if (epoch != _scrollEpochV1 ||
          !mounted ||
          widget.detailLessonId != newLessonId) {
        return;
      }
      await _scrollLessonHeaderToTopV1(
        newLessonId,
        settleFrames: 2,
        maxDurationMs: 760,
        maxAttempts: 1,
      );
    }());
  }

  Future<void> _waitForLearnLayoutSettleV1({int frames = 2}) async {
    for (var i = 0; i < frames; i++) {
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
    final popupTask = detailLesson == null || widget.activePopupTaskId == null
        ? null
        : detailLesson.taskList.cast<Act0LessonTaskV1?>().firstWhere(
            (task) => task?.taskId == widget.activePopupTaskId,
            orElse: () => null,
          );
    final selectedWorld = widget.worlds.firstWhere(
      (world) => world.worldId == widget.selectedWorldId,
      orElse: () => widget.worlds.first,
    );
    final nextWorld = _nextWorldAfterV1(widget.worlds, selectedWorld);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _learnCopyV1(
                                      context,
                                      en: 'Learn',
                                      ru: 'Обучение',
                                    ),
                                    style: Act0ShellTokensV1.screenTitle,
                                  ),
                                  const SizedBox(
                                    height: Act0ShellTokensV1.gapXs,
                                  ),
                                  Text(
                                    _learnCopyV1(
                                      context,
                                      en: 'Move one chapter at a time.',
                                      ru: 'Двигайся по главам шаг за шагом.',
                                    ),
                                    style: Act0ShellTokensV1.muted,
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              key: const Key('act0_shell_levels_menu_button'),
                              onPressed: widget.onOpenWorldMenu,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Act0ShellTokensV1.primary,
                                side: BorderSide(
                                  color: Act0ShellTokensV1.primary.withValues(
                                    alpha: 0.48,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Act0ShellTokensV1.radiusPill,
                                  ),
                                ),
                                textStyle: Act0ShellTokensV1.label.copyWith(
                                  letterSpacing: 0.8,
                                ),
                              ),
                              icon: const Icon(Icons.map_rounded, size: 17),
                              label: Text(
                                _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        Text(
                          widget.moduleProgressLabel,
                          style: Act0ShellTokensV1.muted,
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapMd),
                        _LearnJourneyStripV1(
                          worldNumber: selectedWorld.worldNumber,
                          title: widget.moduleTitle,
                          subtitle: selectedWorld.subtitle,
                          lessonCount: widget.lessons.length,
                          rewardXp: selectedWorld.rewardXp,
                          nextLandmarkTitle: nextWorld?.title,
                          accent: worldTone.accent,
                          accentSoft: worldTone.accentSoft,
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapLg),
                      ],
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Act0ShellTokensV1.pageX,
                    0,
                    Act0ShellTokensV1.pageX,
                    Act0ShellTokensV1.bottomNavHeight + 34,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.only(
                                top: 84,
                                bottom: 64,
                              ),
                              decoration: BoxDecoration(
                                color: Act0ShellTokensV1.border.withValues(
                                  alpha: 0.44,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusPill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            for (var i = 0; i < widget.lessons.length; i++) ...[
                              KeyedSubtree(
                                key: _lessonKeys.putIfAbsent(
                                  widget.lessons[i].lessonId,
                                  GlobalKey.new,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: _useCenteredLearnSpineLayoutV1
                                          ? Alignment.center
                                          : (i.isEven
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight),
                                      child: FractionallySizedBox(
                                        widthFactor:
                                            _learnPathCardWidthFactorV1,
                                        child: _PathCardV1(
                                          index: i + 1,
                                          worldAccent: worldTone.accent,
                                          worldAccentSoft: worldTone.accentSoft,
                                          lesson: widget.lessons[i],
                                          selected:
                                              widget.lessons[i].lessonId ==
                                              widget.selectedLessonId,
                                          expanded:
                                              widget.lessons[i].lessonId ==
                                              widget.detailLessonId,
                                          completedTaskIds:
                                              widget.completedTaskIds,
                                          skippedTaskIds: widget.skippedTaskIds,
                                          pathClosedTaskIds:
                                              widget.pathClosedTaskIds,
                                          isNextUp:
                                              i > 0 &&
                                              widget.lessons[i - 1].state ==
                                                  Act0LessonStateV1.current &&
                                              widget.lessons[i].state ==
                                                  Act0LessonStateV1.locked,
                                          onSelectLesson: widget.onSelectLesson,
                                        ),
                                      ),
                                    ),
                                    _InlineLessonHubSlotV1(
                                      alignment: Alignment.center,
                                      visible:
                                          widget.lessons[i].lessonId ==
                                              widget.detailLessonId &&
                                          widget.lessons[i].lessonId ==
                                              _expansionReadyLessonIdV1,
                                      child: _SelectedLessonPopupV1(
                                        panelRenderKey: _selectedLessonPanelKey,
                                        lesson: widget.lessons[i],
                                        selectedTaskId: widget.selectedTaskId,
                                        activePopupTaskId:
                                            widget.activePopupTaskId,
                                        completedTaskIds:
                                            widget.completedTaskIds,
                                        skippedTaskIds: widget.skippedTaskIds,
                                        pathClosedTaskIds:
                                            widget.pathClosedTaskIds,
                                        completionOutcomeLabel:
                                            widget.lessonOutcomeLabels[widget
                                                .lessons[i]
                                                .lessonId],
                                        taskLinkForId: (taskId) =>
                                            _taskLinks.putIfAbsent(
                                              '${widget.lessons[i].lessonId}::$taskId',
                                              LayerLink.new,
                                            ),
                                        onSelectTask: widget.onSelectTask,
                                        onStartTask: widget.onStartTask,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i < widget.lessons.length - 1)
                                const SizedBox(height: Act0ShellTokensV1.gapLg),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (popupTask != null &&
              detailLesson != null &&
              !widget.showWorldMenu) ...[
            Positioned.fill(
              child: _SelectedTaskPopupOverlayV1(
                link:
                    _taskLinks['${detailLesson.lessonId}::${popupTask.taskId}'],
                lesson: detailLesson,
                task: popupTask,
                nextTask: detailLesson.taskList.firstWhere(
                  (task) => !widget.pathClosedTaskIds.contains(task.taskId),
                  orElse: () => detailLesson.taskList.first,
                ),
                isDone: widget.completedTaskIds.contains(popupTask.taskId),
                isSkipped: widget.skippedTaskIds.contains(popupTask.taskId),
                isCurrent:
                    popupTask.taskId ==
                    detailLesson.taskList
                        .firstWhere(
                          (task) =>
                              !widget.pathClosedTaskIds.contains(task.taskId),
                          orElse: () => detailLesson.taskList.first,
                        )
                        .taskId,
                isLocked:
                    detailLesson.state == Act0LessonStateV1.locked ||
                    (!widget.pathClosedTaskIds.contains(popupTask.taskId) &&
                        popupTask.taskId !=
                            detailLesson.taskList
                                .firstWhere(
                                  (task) => !widget.pathClosedTaskIds.contains(
                                    task.taskId,
                                  ),
                                  orElse: () => detailLesson.taskList.first,
                                )
                                .taskId),
                onDismiss: widget.onDismissTaskPopup,
                onStartTask: widget.onStartTask,
              ),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final selectedWorld = worlds.firstWhere(
      (world) => world.worldId == selectedWorldId,
      orElse: () => worlds.first,
    );
    final secondaryWorlds = worlds
        .where((world) => world.worldId != selectedWorldId)
        .toList(growable: false);
    final selectedStateColor = _worldStateColor(selectedWorld.status);
    final selectedStateLabel = switch (selectedWorld.status) {
      Act0WorldStateV1.completed => 'Cleared',
      Act0WorldStateV1.current => 'Active now',
      Act0WorldStateV1.locked => 'Locked',
    };
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
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Container(
                key: const Key('act0_shell_levels_sticky_node_header'),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: selectedStateColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                  border: Border.all(
                    color: selectedStateColor.withValues(alpha: 0.34),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: selectedStateColor.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _learnCopyV1(
                          context,
                          en: 'ACTIVE CHAPTER',
                          ru: 'АКТИВНАЯ ГЛАВА',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: selectedStateColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _WorldNodeV1(
                      world: selectedWorld,
                      selected: true,
                      onSelectWorld: onSelectWorld,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'World ${selectedWorld.worldNumber} of ${worlds.length} · $selectedStateLabel',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: selectedStateColor.withValues(alpha: 0.86),
                              fontSize: 10.8,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedWorld.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Act0ShellTokensV1.muted.copyWith(
                              fontSize: 11.5,
                              height: 1.2,
                            ),
                          ),
                          if (_nextWorldAfterV1(worlds, selectedWorld) !=
                              null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _learnCopyV1(
                                context,
                                en: 'Next landmark · ${_nextWorldAfterV1(worlds, selectedWorld)!.title}',
                                ru: 'Следующий рубеж · ${_nextWorldAfterV1(worlds, selectedWorld)!.title}',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.gold,
                                fontSize: 10.4,
                                letterSpacing: 0.26,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _LevelsHeaderV1(
                title: _learnCopyV1(
                  context,
                  en: 'Volume I route',
                  ru: 'Маршрут Том I',
                ),
                subtitle: _learnCopyV1(
                  context,
                  en: '12 live worlds. Later volumes unlock ahead.',
                  ru: '12 активных миров. Следующие тома откроются позже.',
                ),
                progressLabel: () {
                  final active = worlds.firstWhere(
                    (w) => w.status == Act0WorldStateV1.current,
                    orElse: () => worlds.first,
                  );
                  final cleared = worlds
                      .where((w) => w.status == Act0WorldStateV1.completed)
                      .length;
                  return cleared > 0
                      ? 'Level ${active.worldNumber} active · $cleared cleared'
                      : 'Level ${active.worldNumber} active';
                }(),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                    bottom: Act0ShellTokensV1.bottomNavHeight + 44,
                  ),
                  children: [
                    Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 3,
                              margin: const EdgeInsets.only(
                                top: 54,
                                bottom: 58,
                              ),
                              decoration: BoxDecoration(
                                color: Act0ShellTokensV1.border.withValues(
                                  alpha: 0.72,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusPill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            for (
                              var i = 0;
                              i < secondaryWorlds.length;
                              i++
                            ) ...[
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  i.isOdd ? 22 : 0,
                                  8,
                                  i.isEven ? 22 : 0,
                                  8,
                                ),
                                child: Align(
                                  alignment: i.isEven
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: FractionallySizedBox(
                                    widthFactor: _Act0LearnPathShellV1State
                                        ._levelsWorldNodeWidthFactorV1,
                                    child: _WorldNodeV1(
                                      world: secondaryWorlds[i],
                                      selected: false,
                                      onSelectWorld: onSelectWorld,
                                    ),
                                  ),
                                ),
                              ),
                              if (i < secondaryWorlds.length - 1)
                                const SizedBox(height: Act0ShellTokensV1.gapLg),
                            ],
                          ],
                        ),
                      ],
                    ),
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

class _LevelsHeaderV1 extends StatelessWidget {
  const _LevelsHeaderV1({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
  });

  final String title;
  final String subtitle;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(alpha: 0.70),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Act0ShellTokensV1.primary.withValues(alpha: 0.40),
              ),
            ),
            child: const Icon(
              Icons.map_rounded,
              color: Act0ShellTokensV1.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Act0ShellTokensV1.cardTitle),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Act0ShellTokensV1.muted.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 3),
                Text(
                  progressLabel,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.gold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldNodeV1 extends StatefulWidget {
  const _WorldNodeV1({
    required this.world,
    required this.selected,
    required this.onSelectWorld,
  });

  final Act0WorldCardV1 world;
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
    final color = _worldStateColor(widget.world.status);
    final locked = widget.world.isLocked;
    final completed = widget.world.status == Act0WorldStateV1.completed;
    final active = widget.world.status == Act0WorldStateV1.current;
    // Harder rectangles: radiusBase (12) instead of radiusCard (18)
    final nodeRadius = Act0ShellTokensV1.radiusBase;

    // Phase 1: Scale differentiation
    final targetScaleFactor = active ? 1.08 : (locked ? 0.95 : 1.0);

    // Phase 2: Color desaturation for locked state
    // Selection uses background fill + shadow glow, no border
    final targetBorderColor = locked
        ? _desaturateColor(color, 0.35).withValues(alpha: 0.35)
        : color.withValues(alpha: 0.22);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Phase 3: Micro-motion easing (Material Design 3 emphasized)
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
                  padding: const EdgeInsets.fromLTRB(11, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? color.withValues(alpha: 0.20)
                        : Act0ShellTokensV1.surface.withValues(
                            alpha: locked ? 0.42 : 0.82,
                          ),
                    borderRadius: BorderRadius.circular(nodeRadius),
                    border: widget.selected
                        ? null
                        : Border.all(color: targetBorderColor, width: 1.0),
                    boxShadow: <BoxShadow>[
                      // Selection glow: prominent visual indicator (border removed)
                      if (widget.selected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.28 * t),
                          blurRadius: 16,
                          spreadRadius: 1.0,
                          offset: Offset.zero,
                        ),
                      // Phase 1 & 3: Enhanced shadow depth with animation
                      if (active || widget.selected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.15 * t),
                          blurRadius: 12 * t,
                          spreadRadius: 1 * t,
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
                          color: locked
                              ? color.withValues(alpha: 0.09)
                              : completed
                              ? color
                              : color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusCard,
                          ),
                          border: Border.all(
                            color: color.withValues(
                              alpha: locked ? 0.28 : 0.80,
                            ),
                            width: active ? 2.0 : 1.5,
                          ),
                        ),
                        child: completed
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: active ? 22 : 20,
                              )
                            : locked
                            ? Icon(
                                Icons.lock_rounded,
                                color: _desaturateColor(color, 0.30),
                                size: 16,
                              )
                            : Text(
                                '${widget.world.worldNumber}',
                                style: TextStyle(
                                  color: Act0ShellTokensV1.text,
                                  fontSize: active ? 16 : 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              act0LocalizedWorldTitleV1(context, widget.world),
                              style: Act0ShellTokensV1.cardTitle.copyWith(
                                color: locked
                                    ? Act0ShellTokensV1.textMuted
                                    : Act0ShellTokensV1.text,
                                fontSize: widget.selected ? 14.0 : 13.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              completed
                                  ? 'Cleared · ${widget.world.lessons.length} lessons'
                                  : active
                                  ? widget.world.progressLabel
                                  : '${widget.world.lessons.length} lessons',
                              style: Act0ShellTokensV1.label.copyWith(
                                color: locked
                                    ? Act0ShellTokensV1.textDim
                                    : color.withValues(alpha: 0.80),
                                fontSize: widget.selected ? 10.8 : 10.2,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (active)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: color.withValues(alpha: 0.50),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        )
                      else if (completed)
                        Icon(Icons.check_circle_rounded, color: color, size: 16)
                      else
                        const SizedBox.shrink(),
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
    required this.onPreviewPremiumWorld,
  });

  final Act0WorldCardV1 world;
  final ValueChanged<Act0WorldCardV1> onPreviewPremiumWorld;

  @override
  Widget build(BuildContext context) {
    final color = _worldStateColor(world.status);
    final worldTitle = act0LocalizedWorldTitleV1(context, world);
    final worldSubtitle = act0LocalizedWorldSubtitleV1(context, world);
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
              _StateBadgeV1(
                label: switch (world.status) {
                  Act0WorldStateV1.completed => 'Cleared',
                  Act0WorldStateV1.current => 'Active',
                  Act0WorldStateV1.locked => world.progressLabel,
                },
                color: color,
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Text(
                '+${world.rewardXp} XP',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.gold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(worldTitle, style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(worldSubtitle, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            world.unlockLabel,
            key: const Key('act0_shell_world_unlock_label'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
          if (world.isLocked) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Text(
              'Premium preview',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              'See what this world adds before it opens. No pressure, no forced upgrade.',
              style: Act0ShellTokensV1.muted,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            OutlinedButton(
              key: const Key('act0_shell_world_premium_preview_cta'),
              onPressed: () => onPreviewPremiumWorld(world),
              style: Act0ShellTokensV1.quietButtonStyle(height: 40),
              child: const Text('Preview premium path'),
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
    required this.skippedTaskIds,
    required this.pathClosedTaskIds,
    this.completionOutcomeLabel,
    required this.taskLinkForId,
    required this.onSelectTask,
    required this.onStartTask,
  });

  final Key panelRenderKey;
  final Act0LessonCardV1 lesson;
  final String selectedTaskId;
  final String? activePopupTaskId;
  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> pathClosedTaskIds;
  final String? completionOutcomeLabel;
  final LayerLink Function(String taskId) taskLinkForId;
  final void Function(String lessonId, String taskId) onSelectTask;
  final void Function(String lessonId, String taskId) onStartTask;

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(lesson.state);
    final locked = lesson.state == Act0LessonStateV1.locked;
    final tasks = lesson.taskList;
    final lessonTitle = act0LocalizedLessonTitleV1(context, lesson);
    final lessonSubtitle = act0LocalizedLessonSubtitleV1(context, lesson);
    final nextTask = tasks.firstWhere(
      (task) => !pathClosedTaskIds.contains(task.taskId),
      orElse: () => tasks.first,
    );
    return Padding(
      key: const Key('act0_shell_selected_lesson_panel'),
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Container(
        key: panelRenderKey,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration:
            Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.94),
              borderColor: stateColor.withValues(alpha: 0.18),
            ).copyWith(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lessonTitle, style: Act0ShellTokensV1.cardTitle),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            if (lessonSubtitle.isNotEmpty) ...<Widget>[
              Text(
                lessonSubtitle,
                key: const Key('act0_shell_selected_lesson_subtitle'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: stateColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                border: Border.all(color: stateColor.withValues(alpha: 0.22)),
              ),
              child: Text(
                locked
                    ? 'This lesson opens after the path reaches it.'
                    : 'Open one step at a time. The next clear step stays on top.',
                style: Act0ShellTokensV1.label.copyWith(
                  color: locked ? Act0ShellTokensV1.textDim : stateColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
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
                    isSkipped: skippedTaskIds.contains(tasks[i].taskId),
                    isCurrent: tasks[i].taskId == nextTask.taskId,
                    isSelected: activePopupTaskId == null
                        ? tasks[i].taskId == nextTask.taskId
                        : tasks[i].taskId == activePopupTaskId,
                    isLocked:
                        locked ||
                        (!pathClosedTaskIds.contains(tasks[i].taskId) &&
                            tasks[i].taskId != nextTask.taskId),
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
            if (!locked) ...[
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('act0_shell_lesson_start_cta'),
                  onPressed: () =>
                      onStartTask(lesson.lessonId, nextTask.taskId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Act0ShellTokensV1.primary,
                    foregroundColor: Act0ShellTokensV1.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    textStyle: Act0ShellTokensV1.label.copyWith(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(lesson.primaryCtaLabel),
                ),
              ),
            ],
          ],
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
    return AnimatedSize(
      duration: const Duration(milliseconds: 580),
      reverseDuration:
          _Act0LearnPathShellV1State._inlineLessonHubCollapseDurationV1,
      curve: Curves.easeInOutCubicEmphasized,
      alignment: Alignment.topCenter,
      child: visible
          ? Align(
              alignment: alignment,
              child: FractionallySizedBox(
                widthFactor:
                    _Act0LearnPathShellV1State._inlineLessonHubWidthFactorV1,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: Act0ShellTokensV1.gapSm,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    reverseDuration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SizeTransition(
                          sizeFactor: curved,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: const ValueKey<String>('act0_inline_lesson_hub'),
                      child: child,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
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
    required this.isSkipped,
    required this.isCurrent,
    required this.isSelected,
    required this.isLocked,
    required this.onSelectTask,
    required this.onStartTask,
  });

  final int index;
  final LayerLink link;
  final Act0LessonCardV1 lesson;
  final Act0LessonTaskV1 task;
  final bool isLast;
  final bool isDone;
  final bool isSkipped;
  final bool isCurrent;
  final bool isSelected;
  final bool isLocked;
  final void Function(String lessonId, String taskId) onSelectTask;
  final void Function(String lessonId, String taskId) onStartTask;

  @override
  State<_LessonHubStepV1> createState() => _LessonHubStepV1State();
}

class _LessonHubStepV1State extends State<_LessonHubStepV1> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _showWithDelay();
  }

  void _showWithDelay() {
    Future<void>.delayed(Duration(milliseconds: 110 + widget.index * 115), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDone
        ? Act0ShellTokensV1.primary
        : widget.isSkipped
        ? Act0ShellTokensV1.gold
        : widget.isCurrent || widget.isSelected
        ? Act0ShellTokensV1.gold
        : widget.isLocked
        ? Act0ShellTokensV1.textDim
        : Act0ShellTokensV1.primary;
    final icon = widget.isLocked
        ? Icons.lock_rounded
        : widget.isDone
        ? Icons.check_rounded
        : widget.isSkipped
        ? Icons.fast_forward_rounded
        : _stepIcon(widget.task.stepKind);
    final statusLabel = widget.isSkipped
        ? 'Skipped'
        : widget.isSelected && !widget.isLocked
        ? 'Ready'
        : widget.isCurrent
        ? 'Next'
        : widget.isLocked
        ? 'Later'
        : '${widget.index}';
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, -0.06),
        duration: const Duration(milliseconds: 430),
        curve: Curves.easeOutCubic,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 320
                ? constraints.maxWidth - 34
                : (constraints.maxWidth * 0.9).clamp(248.0, 320.0);
            final centerLeft = (constraints.maxWidth - cardWidth) / 2;
            final cardLeft = centerLeft
                .clamp(0.0, constraints.maxWidth - cardWidth)
                .toDouble();
            final threadX = cardLeft + 27;
            return SizedBox(
              height: 80,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  if (!widget.isLast)
                    Positioned(
                      left: threadX - 1.5,
                      top: 25,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
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
                            height: 56,
                            padding: const EdgeInsets.fromLTRB(9, 6, 10, 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isSelected
                                    ? <Color>[
                                        color.withValues(alpha: 0.18),
                                        Act0ShellTokensV1.surface2.withValues(
                                          alpha: 0.96,
                                        ),
                                      ]
                                    : <Color>[
                                        Act0ShellTokensV1.learnPathTaskSurface,
                                        Act0ShellTokensV1.surface.withValues(
                                          alpha: 0.92,
                                        ),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusXl,
                              ),
                              border: Border.all(
                                color: widget.isSelected
                                    ? color.withValues(alpha: 0.58)
                                    : Act0ShellTokensV1.border.withValues(
                                        alpha: 0.40,
                                      ),
                              ),
                              boxShadow: <BoxShadow>[
                                const BoxShadow(
                                  color: Color(0x44000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                                if (widget.isSelected)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.10),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        color.withValues(
                                          alpha: widget.isDone ? 1 : 0.24,
                                        ),
                                        color.withValues(
                                          alpha: widget.isDone ? 0.82 : 0.08,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Act0ShellTokensV1.radiusCard,
                                    ),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.62),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      if (!widget.isLocked)
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.20),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                    ],
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 16,
                                    color: widget.isDone
                                        ? Act0ShellTokensV1.onPrimary
                                        : color,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _stepLabel(widget.task.stepKind),
                                        style: Act0ShellTokensV1.label.copyWith(
                                          color: color,
                                          letterSpacing: 0.8,
                                          fontSize: 8.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 0.5),
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
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11.3,
                                          height: 1.0,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(
                                      alpha: widget.isSelected ? 0.20 : 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Act0ShellTokensV1.radiusPill,
                                    ),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: color,
                                      letterSpacing: 0.45,
                                      fontSize: 8.7,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectedTaskPopupOverlayV1 extends StatelessWidget {
  const _SelectedTaskPopupOverlayV1({
    required this.link,
    required this.lesson,
    required this.task,
    required this.nextTask,
    required this.isDone,
    required this.isSkipped,
    required this.isCurrent,
    required this.isLocked,
    required this.onDismiss,
    required this.onStartTask,
  });

  final LayerLink? link;
  final Act0LessonCardV1 lesson;
  final Act0LessonTaskV1 task;
  final Act0LessonTaskV1 nextTask;
  final bool isDone;
  final bool isSkipped;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback onDismiss;
  final void Function(String lessonId, String taskId) onStartTask;

  @override
  Widget build(BuildContext context) {
    if (link == null) {
      return const SizedBox.shrink();
    }
    final color = isLocked
        ? Act0ShellTokensV1.textDim
        : isDone
        ? Act0ShellTokensV1.primary
        : isSkipped
        ? Act0ShellTokensV1.gold
        : isCurrent
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final detailLine = _selectedTaskDetail(
      context: context,
      task: task,
      nextTask: nextTask,
      isDone: isDone,
      isSkipped: isSkipped,
      isLocked: isLocked,
    );
    final ctaText = isLocked
        ? 'Later'
        : isDone
        ? 'Review lesson'
        : isSkipped
        ? 'Do skipped spot'
        : isCurrent &&
              lesson.taskList.isNotEmpty &&
              lesson.taskList.first.taskId != nextTask.taskId
        ? 'Continue'
        : 'Start';

    return IgnorePointer(
      ignoring: false,
      child: TapRegion(
        onTapOutside: (_) => onDismiss(),
        child: CompositedTransformFollower(
          link: link!,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 12),
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              heightFactor: 1,
              child: SizedBox(
                width: 252,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusOverlay,
                          ),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Act0ShellTokensV1.surface.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      key: const Key('act0_shell_selected_lesson_task_focus'),
                      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color.alphaBlend(
                              color.withValues(alpha: 0.18),
                              Act0ShellTokensV1.surface2,
                            ),
                            Act0ShellTokensV1.surface.withValues(alpha: 0.995),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusXl,
                        ),
                        border: Border.all(
                          color: color.withValues(alpha: 0.42),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xAA091018),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: color.withValues(alpha: 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detailLine,
                            key: const Key(
                              'act0_shell_selected_lesson_task_detail',
                            ),
                            style: Act0ShellTokensV1.body.copyWith(
                              color: Act0ShellTokensV1.text,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapSm),
                          FilledButton(
                            key: const Key('act0_shell_selected_lesson_cta'),
                            onPressed: lesson.isSelectable && !isLocked
                                ? () =>
                                      onStartTask(lesson.lessonId, task.taskId)
                                : null,
                            style: lesson.isSelectable
                                ? Act0ShellTokensV1.primaryButtonStyle(
                                    height: 42,
                                  )
                                : Act0ShellTokensV1.quietButtonStyle(
                                    height: 42,
                                  ),
                            child: Text(ctaText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
  final VoidCallback? onTap;
  final Color accent;
  final Color accentSoft;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progressFraction.clamp(0.0, 1.0);
    final progressPercent = (normalizedProgress * 100).round();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.gapMd,
          9,
          Act0ShellTokensV1.gapMd,
          8,
        ),
        decoration: Act0ShellTokensV1.heroDecoration().copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              accent.withValues(alpha: 0.26),
              accentSoft.withValues(alpha: 0.92),
              Act0ShellTokensV1.surface,
              Act0ShellTokensV1.surface2,
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
          boxShadow: <BoxShadow>[
            const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2,
              width: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    accent.withValues(alpha: 0.85),
                    Act0ShellTokensV1.gold.withValues(alpha: 0.58),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Act0ShellTokensV1.gold.withValues(alpha: 0.96),
                        accent.withValues(alpha: 0.92),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Text(
                    '$worldNumber',
                    style: const TextStyle(
                      color: Act0ShellTokensV1.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _learnCopyV1(
                          context,
                          en: 'Volume I · World $worldNumber',
                          ru: 'Том I · Мир $worldNumber',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: accent,
                          fontSize: 10.6,
                          letterSpacing: 0.42,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.cardTitle,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: Act0ShellTokensV1.muted.copyWith(fontSize: 10.6),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _learnCopyV1(
                          context,
                          en: '$lessonCount lessons · $progressLabel',
                          ru: '$lessonCount уроков · $progressLabel',
                        ),
                        key: const Key('act0_shell_learn_route_board'),
                        style: Act0ShellTokensV1.muted.copyWith(fontSize: 10.8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface3.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.24)),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: accent,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              child: LinearProgressIndicator(
                key: const Key('act0_shell_learn_progress_bar'),
                value: normalizedProgress,
                minHeight: 3,
                backgroundColor: Act0ShellTokensV1.border.withValues(
                  alpha: 0.3,
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

  static const double extentV1 = 118.0;

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
  final ValueChanged<String> onSelectLesson;

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
        ? 'Opens after the lesson before it'
        : '$totalSteps steps inside';
    final stateBadgeLabel = isCompleted
        ? 'Done'
        : isInProgress
        ? 'Now'
        : isCurrent
        ? 'Open'
        : isNextUp
        ? 'Next'
        : isLocked
        ? 'Locked'
        : 'Later';
    final lessonTitle = act0LocalizedLessonTitleV1(context, lesson);
    final isHighlighted = expanded || selected || isCurrent;

    return Opacity(
      opacity: lesson.state == Act0LessonStateV1.locked ? 0.68 : 1,
      child: Material(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          key: Key('act0_shell_lesson_${lesson.title}'),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
          onTap: () => onSelectLesson(lesson.lessonId),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isHighlighted
                    ? <Color>[
                        stateColor.withValues(alpha: 0.18),
                        worldAccent.withValues(alpha: 0.08),
                        Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                      ]
                    : <Color>[
                        worldAccentSoft.withValues(alpha: 0.30),
                        Act0ShellTokensV1.surface2.withValues(alpha: 0.84),
                        Act0ShellTokensV1.surface.withValues(alpha: 0.96),
                      ],
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
                if (isHighlighted)
                  BoxShadow(
                    color: stateColor.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: isCompleted ? 1 : 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    gradient: isCompleted
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              stateColor.withValues(alpha: 0.18),
                              worldAccent.withValues(alpha: 0.12),
                            ],
                          ),
                    border: Border.all(
                      color: stateColor.withValues(alpha: 0.62),
                    ),
                    boxShadow: <BoxShadow>[
                      if (!isLocked)
                        BoxShadow(
                          color: stateColor.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted
                        ? Act0ShellTokensV1.onPrimary
                        : stateColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Lesson $index',
                            style: Act0ShellTokensV1.label.copyWith(
                              color: stateColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: Act0ShellTokensV1.gapSm),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: stateColor.withValues(
                                alpha: isCompleted ? 0.18 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusPill,
                              ),
                            ),
                            child: Text(
                              stateBadgeLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: isCompleted
                                    ? Act0ShellTokensV1.gold
                                    : stateColor,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        lessonTitle,
                        style: Act0ShellTokensV1.cardTitle.copyWith(
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.route_rounded,
                            size: 12,
                            color: isLocked
                                ? Act0ShellTokensV1.textDim
                                : Act0ShellTokensV1.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              stepSummary,
                              style: Act0ShellTokensV1.muted.copyWith(
                                fontSize: 11.2,
                                color: isLocked
                                    ? Act0ShellTokensV1.textDim
                                    : Act0ShellTokensV1.textMuted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _stateColor(Act0LessonStateV1 state) {
  return switch (state) {
    Act0LessonStateV1.completed => Act0ShellTokensV1.primary,
    Act0LessonStateV1.current => Act0ShellTokensV1.gold,
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
  required bool isDone,
  required bool isSkipped,
  required bool isLocked,
}) {
  if (isLocked) {
    return act0LocalizedTaskLockedSummaryV1(
      context,
      task,
      fallback:
          task.lockedSummary ??
          'Clear ${act0LocalizedTaskTitleV1(context, nextTask).toLowerCase()} first, then this node opens.',
    );
  }
  if (isSkipped) {
    return _isRuLocaleV1(context)
        ? 'Этот шаг был пропущен во время плейсмента. Пройди его сейчас, чтобы закрыть путь полностью.'
        : 'Skipped during placement. Run it now to convert it into a full clear.';
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
    Act0WorldStateV1.current => Act0ShellTokensV1.gold,
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
