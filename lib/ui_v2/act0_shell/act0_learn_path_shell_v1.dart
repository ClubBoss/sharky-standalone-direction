import 'dart:async' show unawaited;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

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
  final Map<String, GlobalKey> _lessonKeys = <String, GlobalKey>{};
  final Map<String, LayerLink> _taskLinks = <String, LayerLink>{};
  final GlobalKey _learnStackKey = GlobalKey();
  final GlobalKey _selectedLessonPanelKey = GlobalKey();
  final GlobalKey _pinnedModuleHeaderKey = GlobalKey();
  final ScrollController _learnScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.detailLessonId != null) {
      _scrollExpandedLessonIntoView(widget.detailLessonId!);
    }
  }

  @override
  void didUpdateWidget(covariant Act0LearnPathShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWorldId != oldWidget.selectedWorldId) {
      _scrollToTopOnWorldSwitchV1();
    }
  }

  @override
  void dispose() {
    _learnScrollController.dispose();
    super.dispose();
  }

  void _scrollToTopOnWorldSwitchV1() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _scrollExpandedLessonIntoView(String lessonId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _scrollLessonHeaderToTopV1(lessonId);
    });
  }

  Future<void> _scrollLessonHeaderToTopV1(String lessonId) async {
    if (!_learnScrollController.hasClients) {
      return;
    }
    double? computeTargetOffset() {
      final context = _lessonKeys[lessonId]?.currentContext;
      if (context == null) {
        return null;
      }
      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        return null;
      }
      final viewport = RenderAbstractViewport.maybeOf(renderObject);
      if (viewport == null) {
        return null;
      }
      final pinnedHeaderHeight =
          _pinnedModuleHeaderKey.currentContext?.size?.height ?? 118.0;
      // Keep selected lesson title directly under the pinned world header.
      final topInset = (pinnedHeaderHeight - 14).clamp(0.0, 9999.0);
      final revealOffset = viewport.getOffsetToReveal(renderObject, 0.0).offset;
      return (revealOffset - topInset).clamp(
        _learnScrollController.position.minScrollExtent,
        _learnScrollController.position.maxScrollExtent,
      );
    }

    final target = computeTargetOffset();
    if (target == null) {
      return;
    }
    final delta = (target - _learnScrollController.offset).abs();
    if (delta < 1.0) {
      return;
    }
    final durationMs = (180 + (delta * 0.22)).clamp(220, 460).round();
    await _learnScrollController.animateTo(
      target,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeInOutCubic,
    );
    if (!mounted || !_learnScrollController.hasClients) {
      return;
    }
    // Correct final position after layout settles (old panel collapsed,
    // new panel mounted) to avoid ending below the intended header anchor.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_learnScrollController.hasClients) {
      return;
    }
    final correctedTarget = computeTargetOffset();
    if (correctedTarget == null) {
      return;
    }
    if ((correctedTarget - _learnScrollController.offset).abs() >= 1.0) {
      _learnScrollController.jumpTo(correctedTarget);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailLesson = widget.detailLessonId == null
        ? null
        : widget.lessons.firstWhere(
            (lesson) => lesson.lessonId == widget.detailLessonId,
            orElse: () => widget.lessons.first,
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Act0ShellTokensV1.info.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Act0ShellTokensV1.radiusPill,
                                      ),
                                      border: Border.all(
                                        color: Act0ShellTokensV1.info
                                            .withValues(alpha: 0.34),
                                      ),
                                    ),
                                    child: Text(
                                      'COURSE PATH',
                                      style: Act0ShellTokensV1.label.copyWith(
                                        color: Act0ShellTokensV1.info,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Act0ShellTokensV1.gapSm,
                                  ),
                                  Text(
                                    'Learning Path',
                                    style: Act0ShellTokensV1.screenTitle,
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
                              label: const Text('Levels'),
                            ),
                          ],
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        Text(
                          widget.moduleProgressLabel,
                          style: Act0ShellTokensV1.muted,
                        ),
                        if ((widget.sharkyGuideLine ?? '')
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          Act0SharkyGuideCardV1(
                            eyebrow: widget.sharkyGuideTitle ?? 'Sharky guide',
                            line: widget.sharkyGuideLine!,
                            detail: widget.sharkyGuideDetail,
                            mood: widget.sharkyGuideMood,
                            compact: true,
                          ),
                        ],
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
                        Act0ShellTokensV1.gapLg,
                      ),
                      child: KeyedSubtree(
                        key: _pinnedModuleHeaderKey,
                        child: _ModuleHeaderV1(
                          worldNumber: widget.worlds
                              .firstWhere(
                                (w) => w.worldId == widget.selectedWorldId,
                                orElse: () => widget.worlds.first,
                              )
                              .worldNumber,
                          title: widget.moduleTitle,
                          progressLabel: widget.moduleProgressLabel,
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
                                      alignment: i.isEven
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.78,
                                        child: _PathCardV1(
                                          index: i + 1,
                                          lesson: widget.lessons[i],
                                          selected:
                                              widget.lessons[i].lessonId ==
                                              widget.selectedLessonId,
                                          expanded:
                                              widget.lessons[i].lessonId ==
                                              detailLesson?.lessonId,
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
                                          onSelectLesson: (lessonId) {
                                            final shouldAutoOpen =
                                                widget.onSelectLesson(lessonId);
                                            if (!shouldAutoOpen) {
                                              return;
                                            }
                                            unawaited(
                                              _scrollLessonHeaderToTopV1(
                                                lessonId,
                                              ).then((_) {
                                                if (!mounted) {
                                                  return;
                                                }
                                                widget.onOpenLessonAfterScroll(
                                                  lessonId,
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    _InlineLessonHubSlotV1(
                                      alignment: Alignment.center,
                                      visible:
                                          widget.lessons[i].lessonId ==
                                          detailLesson?.lessonId,
                                      child: KeyedSubtree(
                                        key: _selectedLessonPanelKey,
                                        child: _SelectedLessonPopupV1(
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
                                    ),
                                  ],
                                ),
                              ),
                              if (i < widget.lessons.length - 1)
                                const SizedBox(height: Act0ShellTokensV1.gapMd),
                            ],
                            const SizedBox(
                              key: Key('act0_shell_learn_safe_bottom_spacer'),
                              height: Act0ShellTokensV1.gapXl,
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
  });

  final List<Act0WorldCardV1> worlds;
  final String selectedWorldId;
  final Act0WorldCardV1? detailWorld;
  final ValueChanged<String> onSelectWorld;
  final VoidCallback onClose;
  final VoidCallback onDismissWorldDetail;

  @override
  Widget build(BuildContext context) {
    final selectedWorld = worlds.firstWhere(
      (world) => world.worldId == selectedWorldId,
      orElse: () => worlds.first,
    );
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
                      'Levels',
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
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: selectedStateColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                  border: Border.all(
                    color: selectedStateColor.withValues(alpha: 0.42),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedStateColor.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedStateColor.withValues(alpha: 0.70),
                        ),
                      ),
                      child: Text(
                        '${selectedWorld.worldNumber}',
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedWorld.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Act0ShellTokensV1.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$selectedStateLabel · ${selectedWorld.lessons.length} lessons',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Act0ShellTokensV1.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _LevelsHeaderV1(
                title: 'Full Mastery Path',
                subtitle: '36 worlds across 3 mastery tiers',
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
                              margin: const EdgeInsets.only(top: 54, bottom: 58),
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
                            for (var i = 0; i < worlds.length; i++) ...[
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  i.isOdd ? 26 : 0,
                                  0,
                                  i.isEven ? 26 : 0,
                                  0,
                                ),
                                child: Align(
                                  alignment: i.isEven
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.82,
                                    child: _WorldNodeV1(
                                      world: worlds[i],
                                      selected:
                                          worlds[i].worldId == selectedWorldId,
                                      onSelectWorld: onSelectWorld,
                                    ),
                                  ),
                                ),
                              ),
                              if (i < worlds.length - 1)
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
                child: _SelectedWorldPopupV1(world: detailWorld!),
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
        color: Act0ShellTokensV1.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.primary.withValues(alpha: 0.18),
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
                Text(subtitle, style: Act0ShellTokensV1.muted),
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

class _WorldNodeV1 extends StatelessWidget {
  const _WorldNodeV1({
    required this.world,
    required this.selected,
    required this.onSelectWorld,
  });

  final Act0WorldCardV1 world;
  final bool selected;
  final ValueChanged<String> onSelectWorld;

  @override
  Widget build(BuildContext context) {
    final color = _worldStateColor(world.status);
    final locked = world.isLocked;
    final completed = world.status == Act0WorldStateV1.completed;
    final active = world.status == Act0WorldStateV1.current;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('act0_shell_world_${world.worldNumber}'),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        onTap: () => onSelectWorld(world.worldId),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.09)
                : Act0ShellTokensV1.surface.withValues(
                    alpha: locked ? 0.52 : 0.94,
                  ),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
            border: Border.all(
              color: color.withValues(
                alpha: selected ? 0.60 : (locked ? 0.18 : 0.30),
              ),
            ),
            boxShadow: active || selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
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
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: locked ? 0.28 : 0.80),
                    width: active ? 2.0 : 1.5,
                  ),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : locked
                    ? Icon(Icons.lock_rounded, color: color, size: 17)
                    : Text(
                        '${world.worldNumber}',
                        style: const TextStyle(
                          color: Act0ShellTokensV1.text,
                          fontSize: 15,
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
                      world.title,
                      style: Act0ShellTokensV1.cardTitle.copyWith(
                        color: locked
                            ? Act0ShellTokensV1.textMuted
                            : Act0ShellTokensV1.text,
                        fontSize: 13.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      completed
                          ? 'Cleared · ${world.lessons.length} lessons'
                          : active
                          ? world.progressLabel
                          : '${world.lessons.length} lessons',
                      style: Act0ShellTokensV1.label.copyWith(
                        color: locked
                            ? Act0ShellTokensV1.textDim
                            : color.withValues(alpha: 0.80),
                        fontSize: 10.5,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
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
      ),
    );
  }
}

class _SelectedWorldPopupV1 extends StatelessWidget {
  const _SelectedWorldPopupV1({required this.world});

  final Act0WorldCardV1 world;

  @override
  Widget build(BuildContext context) {
    final color = _worldStateColor(world.status);
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
          Text(world.title, style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(world.subtitle, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            world.unlockLabel,
            key: const Key('act0_shell_world_unlock_label'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedLessonPopupV1 extends StatelessWidget {
  const _SelectedLessonPopupV1({
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
    final nextTask = tasks.firstWhere(
      (task) => !pathClosedTaskIds.contains(task.taskId),
      orElse: () => tasks.first,
    );
    return Padding(
      key: const Key('act0_shell_selected_lesson_panel'),
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (lesson.subtitle.isNotEmpty) ...<Widget>[
            Text(
              lesson.subtitle,
              key: const Key('act0_shell_selected_lesson_subtitle'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.muted,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
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
              textAlign: TextAlign.center,
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
                onPressed: () => onStartTask(lesson.lessonId, nextTask.taskId),
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
      reverseDuration: Duration.zero,
      curve: Curves.easeInOutCubicEmphasized,
      alignment: Alignment.topCenter,
      child: visible
          ? Align(
              alignment: alignment,
              child: FractionallySizedBox(
                widthFactor: 0.92,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: Act0ShellTokensV1.gapSm,
                    bottom: Act0ShellTokensV1.gapSm,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    reverseDuration: Duration.zero,
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
            final lanePattern = <double>[-18, 6, 24, -8];
            final laneOffsetRaw = lanePattern[(widget.index - 1) % lanePattern.length];
            final maxShift = (constraints.maxWidth * 0.08).clamp(10.0, 24.0);
            final laneOffset = laneOffsetRaw.clamp(-maxShift, maxShift);
            final cardWidth = constraints.maxWidth < 320
                ? constraints.maxWidth - 58
                : 254.0;
            final centerLeft = (constraints.maxWidth - cardWidth) / 2;
            final cardLeft = (centerLeft + laneOffset)
                .clamp(0.0, constraints.maxWidth - cardWidth)
                .toDouble();
            final threadX = cardLeft + 27;
            return SizedBox(
              height: 68,
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
                                    shape: BoxShape.circle,
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
                                          fontSize: 8.7,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.task.title,
                                        style: Act0ShellTokensV1.body.copyWith(
                                          color: widget.isLocked
                                              ? Act0ShellTokensV1.textMuted
                                              : Act0ShellTokensV1.text,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11.8,
                                        ),
                                        maxLines: 1,
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
                                    maxLines: 1,
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
    required this.progressLabel,
    required this.progressFraction,
    required this.onTap,
  });

  final int worldNumber;
  final String title;
  final String progressLabel;
  final double progressFraction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progressFraction.clamp(0.0, 1.0);
    final progressPercent = (normalizedProgress * 100).round();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
        decoration: Act0ShellTokensV1.heroDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Act0ShellTokensV1.gold,
                        Act0ShellTokensV1.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                  ),
                  child: Text(
                    '$worldNumber',
                    style: const TextStyle(
                      color: Act0ShellTokensV1.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current route',
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.gold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(title, style: Act0ShellTokensV1.cardTitle),
                      const SizedBox(height: Act0ShellTokensV1.gapXs),
                      Text(
                        progressLabel,
                        key: const Key('act0_shell_learn_route_board'),
                        style: Act0ShellTokensV1.muted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface3.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    border: Border.all(
                      color: Act0ShellTokensV1.gold.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.gold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              child: LinearProgressIndicator(
                key: const Key('act0_shell_learn_progress_bar'),
                value: progressFraction,
                minHeight: 4,
                backgroundColor: Act0ShellTokensV1.border.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Act0ShellTokensV1.primary,
                ),
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

  final Widget child;

  @override
  double get minExtent => 138;

  @override
  double get maxExtent => 138;

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
        ? '$totalSteps steps cleared'
        : isCurrent
        ? '$completedSteps of $totalSteps steps clear'
        : isLocked
        ? 'Unlock to open all $totalSteps steps'
        : '$totalSteps steps ready';
    final stateBadgeLabel = isCompleted
        ? 'Done'
        : isInProgress
        ? 'Live'
        : isCurrent
        ? 'Open'
        : isNextUp
        ? 'Next'
        : 'Later';

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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCurrent
                    ? <Color>[
                        stateColor.withValues(alpha: 0.12),
                        Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                      ]
                    : <Color>[
                        Act0ShellTokensV1.surface2.withValues(alpha: 0.84),
                        Act0ShellTokensV1.surface.withValues(alpha: 0.96),
                      ],
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
              border: Border.all(
                color: stateColor.withValues(
                  alpha: expanded || selected || isCurrent ? 0.72 : 0.3,
                ),
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
                if (expanded || selected || isCurrent)
                  BoxShadow(
                    color: stateColor.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: isCompleted ? 1 : 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
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
                    size: 24,
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
                            'LESSON $index',
                            style: Act0ShellTokensV1.label.copyWith(
                              color: stateColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: Act0ShellTokensV1.gapSm),
                          Expanded(
                            child: Text(
                              stateBadgeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: isCompleted
                                    ? Act0ShellTokensV1.gold
                                    : stateColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Text(
                        lesson.title,
                        style: Act0ShellTokensV1.cardTitle.copyWith(
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCurrent || expanded || isLocked) ...[
                        const SizedBox(height: 5),
                        Text(
                          stepSummary,
                          style: Act0ShellTokensV1.muted.copyWith(
                            fontSize: 11,
                            color: isLocked
                                ? Act0ShellTokensV1.textDim
                                : Act0ShellTokensV1.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
  required Act0LessonTaskV1 task,
  required Act0LessonTaskV1 nextTask,
  required bool isDone,
  required bool isSkipped,
  required bool isLocked,
}) {
  if (isLocked) {
    return task.lockedSummary ??
        'Clear ${nextTask.title.toLowerCase()} first, then this node opens.';
  }
  if (isSkipped) {
    return 'Skipped during placement. Run it now to convert it into a full clear.';
  }
  if (isDone) {
    return task.summary ?? task.runner.caption;
  }
  return task.summary ?? task.runner.caption;
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
