part of 'act0_learn_path_shell_v1.dart';

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
        ? Act0SkinTokensV1.caption
        : Act0SkinTokensV1.accent;
    final tasks = lesson.courseTaskList;
    final lessonSubtitle = act0AcademyLessonSubtitleV1(context, lesson);
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
        compactPanel ? Act0SkinTokensV1.gapXs : Act0SkinTokensV1.gapXs,
        compactPanel ? Act0SkinTokensV1.gapXs : Act0SkinTokensV1.gapXs,
        compactPanel ? Act0SkinTokensV1.gapXs : Act0SkinTokensV1.gapXs,
        compactPanel ? Act0SkinTokensV1.gapXs : Act0SkinTokensV1.gapXs,
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
            padding: const EdgeInsets.symmetric(
              horizontal: Act0SkinTokensV1.gapMd,
              vertical: Act0SkinTokensV1.gapSm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Act0SkinTokensV1.radiusControl,
              ),
              border: Border.all(
                color: stateColor.withValues(
                  alpha: Act0SkinTokensV1.tintStrong,
                ),
                width: 1.0,
              ),
              color: Act0SkinTokensV1.surface,
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

                      style: Act0SkinTokensV1.secondary,
                    ),
                    if (index != lessonSubtitleBlocks.length - 1)
                      const SizedBox(height: Act0SkinTokensV1.gapXs),
                  ],
                  SizedBox(
                    height: compactPanel
                        ? Act0SkinTokensV1.gapXs
                        : Act0SkinTokensV1.gapXs,
                  ),
                ],
                Container(
                  key: const Key('act0_shell_selected_lesson_guidance'),
                  constraints: BoxConstraints(
                    maxWidth: widePanel ? 420 : double.infinity,
                  ),
                  child: Text(
                    guidanceCopy,
                    style: Act0SkinTokensV1.captionStyle.copyWith(
                      color: panelAccent.withValues(
                        alpha: Act0SkinTokensV1.disabledOpacity,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: compactPanel
                      ? Act0SkinTokensV1.gapXs
                      : Act0SkinTokensV1.gapXs,
                ),
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
                  const SizedBox(height: Act0SkinTokensV1.gapXs),
                  Text(
                    completionOutcomeLabel!,
                    key: const Key('act0_shell_selected_lesson_outcome'),
                    style: Act0SkinTokensV1.secondary.copyWith(
                      color: stateColor,
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
                top: Act0SkinTokensV1.gapXs,
                bottom: Act0SkinTokensV1.gapXs,
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
    required this.detailMode,
    required this.firstLessonLanding,
    required this.onStart,
  });

  final Act0LessonCardV1 lesson;
  final Act0LessonTaskV1 task;
  final int stepIndex;
  final int totalSteps;
  final bool detailMode;
  final bool firstLessonLanding;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final replay = lesson.state == Act0LessonStateV1.completed;
    final question = act0RunnerQuestionCopyV1(
      context,
      task.taskId,
      task.runner.question,
    );
    final neutralTitle = act0PrechoiceNeutralTitleByTaskIdV1[task.taskId];
    final stepTitle = _learnPlayerCopyV1(
      question.isEmpty ? _learnTaskTitleV1(context, task) : question,
    );
    final support = _learnPlayerCopyV1(
      firstLessonLanding
          ? _learnCopyV1(
              context,
              en: 'Find your seat, read one clue, and make your first table decision.',
              ru: 'Найдите своё место, прочитайте одну подсказку и примите первое решение.',
            )
          : lesson.phaseLabel == 'Practice'
          ? lesson.subtitle
          : _currentMissionSupportCopyV1(
              context: context,
              lesson: lesson,
              nextTask: task,
              compact: MediaQuery.sizeOf(context).width < 390,
              visualVariant: _missionVisualVariantForV1(lesson, task),
            ),
    );
    return Act0SkinCardV1(
      key: detailMode
          ? const Key('act0_shell_lesson_detail_hero')
          : const Key('act0_shell_current_mission_card'),
      emphasized: onStart != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _learnCopyV1(
              context,
              en: firstLessonLanding
                  ? 'FIRST TABLE GUIDE'
                  : detailMode
                  ? 'Lesson read'
                  : 'Learn route',
              ru: detailMode ? 'Чтение урока' : 'Маршрут обучения',
            ),
            style: Act0SkinTokensV1.sectionLabel,
          ),
          Text(
            act0AcademyLessonTitleV1(context, lesson),
            style: Act0SkinTokensV1.title,
          ),
          const SizedBox(height: Act0SkinTokensV1.gapSm),
          Text(
            support,
            key: const Key('act0_shell_current_mission_support'),
            style: Act0SkinTokensV1.secondary,
          ),
          if (onStart != null && !replay) ...[
            const SizedBox(height: Act0SkinTokensV1.gapMd),
            KeyedSubtree(
              key: const Key('act0_shell_current_mission_step_card'),
              child: Text(
                _learnCopyV1(
                  context,
                  en: neutralTitle == null
                      ? 'Current step $stepIndex of $totalSteps · $stepTitle'
                      : 'Current step $stepIndex of $totalSteps',
                  ru: neutralTitle == null
                      ? 'Текущий шаг $stepIndex из $totalSteps · $stepTitle'
                      : 'Текущий шаг $stepIndex из $totalSteps',
                ),
                key: const Key('act0_shell_current_mission_step_band'),
                style: Act0SkinTokensV1.secondary,
              ),
            ),
            if (neutralTitle != null)
              Text(
                _learnTaskTitleV1(context, task),
                style: Act0SkinTokensV1.secondary,
              ),
          ],
          if (onStart != null) ...[
            const SizedBox(height: Act0SkinTokensV1.gapMd),
            Act0SkinPrimaryButtonV1(
              controlKey: const Key('act0_shell_current_mission_cta'),
              compact: true,
              onPressed: onStart,
              label: replay
                  ? _learnCopyV1(context, en: 'Replay', ru: 'Повторить')
                  : stepIndex > 1
                  ? _learnCopyV1(context, en: 'Continue', ru: 'Продолжить')
                  : _learnCopyV1(context, en: 'Start', ru: 'Начать'),
            ),
          ],
        ],
      ),
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
      padding: EdgeInsets.all(
        compact ? Act0SkinTokensV1.gapSm : Act0SkinTokensV1.gapMd,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
        color: Color.alphaBlend(
          accent.withValues(alpha: Act0SkinTokensV1.tintSubtle),
          Act0SkinTokensV1.background,
        ),
        border: Border.all(
          color: accent.withValues(alpha: Act0SkinTokensV1.tintStrong),
        ),
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
                  accent.withValues(alpha: Act0SkinTokensV1.tintSubtle),
                  Act0SkinTokensV1.surface,
                ),
                borderRadius: BorderRadius.circular(
                  Act0SkinTokensV1.radiusPill,
                ),
                border: Border.all(
                  color: accent.withValues(alpha: Act0SkinTokensV1.edgeSoft),
                ),
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
        color: accent.withValues(alpha: Act0SkinTokensV1.tintSubtle),
        borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusPill),
        border: Border.all(
          color: accent.withValues(alpha: Act0SkinTokensV1.tintStrong),
        ),
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
            color: accent.withValues(
              alpha: seat == heroSeat
                  ? Act0SkinTokensV1.nearlyOpaque
                  : Act0SkinTokensV1.edgeStrong,
            ),
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
              accent.withValues(
                alpha: i == 2
                    ? Act0SkinTokensV1.edgeSoft
                    : Act0SkinTokensV1.tintSoft,
              ),
              Act0SkinTokensV1.surface,
            ),
            borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusPill),
            border: Border.all(
              color: accent.withValues(
                alpha: i == 2
                    ? Act0SkinTokensV1.edgeStrong
                    : Act0SkinTokensV1.tintStrong,
              ),
            ),
          ),
          child: Text(
            labels[i],
            style: Act0SkinTokensV1.captionStyle.copyWith(
              color: i == 2 ? accent : Act0SkinTokensV1.muted,
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
            padding: const EdgeInsets.fromLTRB(
              Act0SkinTokensV1.gapXs,
              Act0SkinTokensV1.gapXs,
              0,
              0,
            ),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                accent.withValues(
                  alpha: i == 1
                      ? Act0SkinTokensV1.tintStrong
                      : Act0SkinTokensV1.tintSoft,
                ),
                Act0SkinTokensV1.surface,
              ),
              borderRadius: BorderRadius.circular(Act0SkinTokensV1.gapSm),
              border: Border.all(
                color: accent.withValues(
                  alpha: i == 1
                      ? Act0SkinTokensV1.edgeStrong
                      : Act0SkinTokensV1.edgeSoft,
                ),
              ),
            ),
            child: Text(
              labels[i],
              style: Act0SkinTokensV1.captionStyle.copyWith(
                color: i == 1 ? accent : Act0SkinTokensV1.muted,
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
              accent.withValues(
                alpha:
                    Act0SkinTokensV1.tintSoft + i * Act0SkinTokensV1.tintSubtle,
              ),
              Act0SkinTokensV1.surface,
            ),
            borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusPill),
            border: Border.all(
              color: accent.withValues(
                alpha:
                    Act0SkinTokensV1.tintStrong +
                    i * Act0SkinTokensV1.tintSubtle,
              ),
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
          color: accent.withValues(alpha: Act0SkinTokensV1.tintStrong),
          border: Border.all(
            color: accent.withValues(alpha: Act0SkinTokensV1.edgeStrong),
          ),
        ),
        child: Container(
          width: compact ? 7 : 8,
          height: compact ? 7 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: Act0SkinTokensV1.edgeSoft),
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
      Act0LessonStateV1.current ||
      Act0LessonStateV1.available => Act0SkinTokensV1.accent,
      Act0LessonStateV1.completed => Act0SkinTokensV1.muted,
      Act0LessonStateV1.locked =>
        isNextUp ? Act0SkinTokensV1.accent : Act0SkinTokensV1.caption,
    };
    final lineAlpha = switch (lesson.state) {
      Act0LessonStateV1.current || Act0LessonStateV1.available => 0.26,
      Act0LessonStateV1.completed => 0.14,
      Act0LessonStateV1.locked => isNextUp ? 0.22 : 0.12,
    };
    final nodeFillAlpha = switch (lesson.state) {
      Act0LessonStateV1.current || Act0LessonStateV1.available => 0.15,
      Act0LessonStateV1.completed => 0.07,
      Act0LessonStateV1.locked => isNextUp ? 0.12 : 0.05,
    };
    final nodeBorderAlpha = switch (lesson.state) {
      Act0LessonStateV1.current || Act0LessonStateV1.available => 0.58,
      Act0LessonStateV1.completed => 0.24,
      Act0LessonStateV1.locked => isNextUp ? 0.42 : 0.22,
    };
    final label = switch (lesson.state) {
      Act0LessonStateV1.current || Act0LessonStateV1.available => '$index',
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
              borderRadius: BorderRadius.circular(
                Act0SkinTokensV1.radiusControl,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: Act0SkinTokensV1.radiusSheet),
          child: child,
        ),
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
                Act0SkinTokensV1.surface,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: stateTone.withValues(alpha: nodeBorderAlpha),
              ),
            ),
            child: Text(
              label,
              style: Act0SkinTokensV1.captionStyle.copyWith(color: stateTone),
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
      Act0CompletionDisplayStateV1.perfect => Act0SkinTokensV1.accent,
      Act0CompletionDisplayStateV1.clear => Act0SkinTokensV1.accent,
      Act0CompletionDisplayStateV1.current =>
        widget.isSkipped ? Act0SkinTokensV1.accent : Act0SkinTokensV1.accent,
      Act0CompletionDisplayStateV1.locked => Act0SkinTokensV1.caption,
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
        ? Act0SkinTokensV1.accent
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
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              children: [
                SizedBox(height: rowHeight),
                if (!widget.isLast)
                  Positioned(
                    left: threadX - 1.5,
                    top: 24,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: color.withValues(
                          alpha: Act0SkinTokensV1.tintStrong,
                        ),
                        borderRadius: BorderRadius.circular(
                          Act0SkinTokensV1.radiusControl,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: Act0SkinTokensV1.gapXs),
                  child: CompositedTransformTarget(
                    link: widget.link,
                    child: Material(
                      borderRadius: BorderRadius.circular(
                        Act0SkinTokensV1.radiusSheet,
                      ),
                      clipBehavior: Clip.antiAlias,
                      color: Act0SkinTokensV1.transparent,
                      child: InkWell(
                        key: Key(
                          'act0_shell_lesson_step_${widget.task.taskId}',
                        ),
                        borderRadius: BorderRadius.circular(
                          Act0SkinTokensV1.radiusSheet,
                        ),
                        onTap: () => widget.onSelectTask(
                          widget.lesson.lessonId,
                          widget.task.taskId,
                        ),
                        child: Ink(
                          width: cardWidth,
                          padding: EdgeInsets.fromLTRB(
                            compactWidth
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapSm,
                            compactRow
                                ? Act0SkinTokensV1.gapXs
                                : Act0SkinTokensV1.gapXs,
                            compactWidth
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapMd,
                            compactRow
                                ? Act0SkinTokensV1.gapXs
                                : Act0SkinTokensV1.gapXs,
                          ),
                          decoration: BoxDecoration(
                            color: Act0SkinTokensV1.surface,
                            borderRadius: BorderRadius.circular(
                              Act0SkinTokensV1.radiusCard,
                            ),
                            border: Border.all(
                              color: widget.isSelected
                                  ? rowAccent.withValues(
                                      alpha: Act0SkinTokensV1.edgeStrong,
                                    )
                                  : Act0SkinTokensV1.line.withValues(
                                      alpha: widget.isLocked
                                          ? Act0SkinTokensV1.edgeSoft
                                          : Act0SkinTokensV1.edgeStrong,
                                    ),
                            ),
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
                                      color: Act0SkinTokensV1.surface,
                                      borderRadius: BorderRadius.circular(
                                        Act0SkinTokensV1.gapMd,
                                      ),
                                      border: Border.all(
                                        color: rowAccent.withValues(
                                          alpha: Act0SkinTokensV1.edgeStrong,
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
                                          ? Act0SkinTokensV1.onAccent
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
                                          color: Act0SkinTokensV1.accent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Act0SkinTokensV1.surface,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.star_rounded,
                                          size: 8,
                                          color: Act0SkinTokensV1.surface,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(
                                width: compactWidth
                                    ? Act0SkinTokensV1.gapSm
                                    : compactRow
                                    ? Act0SkinTokensV1.gapSm
                                    : Act0SkinTokensV1.gapSm,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _learnTaskTitleV1(context, widget.task),
                                      key: Key(
                                        'act0_shell_lesson_step_title_${widget.task.taskId}',
                                      ),
                                      style: Act0SkinTokensV1.body.copyWith(
                                        color: widget.isLocked
                                            ? Act0SkinTokensV1.muted
                                            : Act0SkinTokensV1.onSurface,
                                      ),
                                      maxLines: compactWidth ? 3 : 2,
                                    ),
                                  ],
                                ),
                              ),
                              if (showStatusChip) ...[
                                SizedBox(
                                  width: compactWidth
                                      ? Act0SkinTokensV1.gapXs
                                      : compactRow
                                      ? Act0SkinTokensV1.gapXs
                                      : Act0SkinTokensV1.gapXs,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compactWidth
                                        ? Act0SkinTokensV1.gapXs
                                        : compactRow
                                        ? Act0SkinTokensV1.gapSm
                                        : Act0SkinTokensV1.gapSm,
                                    vertical: compactWidth
                                        ? Act0SkinTokensV1.gapXs
                                        : compactRow
                                        ? Act0SkinTokensV1.gapXs
                                        : Act0SkinTokensV1.gapXs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: rowAccent.withValues(
                                      alpha: widget.isSelected
                                          ? Act0SkinTokensV1.tintSoft
                                          : Act0SkinTokensV1.tintSoft,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Act0SkinTokensV1.radiusControl,
                                    ),
                                    border: Border.all(
                                      color: rowAccent.withValues(
                                        alpha: Act0SkinTokensV1.tintStrong,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: Act0SkinTokensV1.captionStyle
                                        .copyWith(color: rowAccent),
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
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 110),
              reverseDuration: const Duration(milliseconds: 90),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: widget.showDetail
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(
                        cardLeft,
                        compactRow
                            ? Act0SkinTokensV1.gapXs
                            : Act0SkinTokensV1.gapXs,
                        constraints.maxWidth - cardLeft - cardWidth,
                        compactRow
                            ? Act0SkinTokensV1.gapSm
                            : Act0SkinTokensV1.gapSm,
                      ),
                      child: KeyedSubtree(
                        key: widget.detailKey,
                        child: Container(
                          key: const Key(
                            'act0_shell_selected_lesson_task_focus',
                          ),
                          width: cardWidth,
                          padding: EdgeInsets.fromLTRB(
                            compactRow
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapMd,
                            compactRow
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapSm,
                            compactRow
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapMd,
                            compactRow
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapSm,
                          ),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              rowAccent.withValues(
                                alpha: Act0SkinTokensV1.tintSubtle,
                              ),
                              Act0SkinTokensV1.raised.withValues(
                                alpha: Act0SkinTokensV1.nearlyOpaque,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              Act0SkinTokensV1.radiusControl,
                            ),
                            border: Border.all(
                              color: rowAccent.withValues(
                                alpha: Act0SkinTokensV1.tintStrong,
                              ),
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

                                            style: Act0SkinTokensV1.body
                                                .copyWith(
                                                  color: Act0SkinTokensV1
                                                      .onSurface,
                                                ),
                                          ),
                                          if (hasPerfectOpportunity ||
                                              widget.isPerfect) ...[
                                            const SizedBox(
                                              height: Act0SkinTokensV1.gapXs,
                                            ),
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

                                              style: Act0SkinTokensV1
                                                  .captionStyle
                                                  .copyWith(
                                                    color: widget.isPerfect
                                                        ? Act0SkinTokensV1
                                                              .accent
                                                        : rowAccent,
                                                  ),
                                            ),
                                          ],
                                          const SizedBox(
                                            height: Act0SkinTokensV1.gapXs,
                                          ),
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
                                                    ? Act0SkinTokensV1.primaryButtonStyle(
                                                        height: compactRow
                                                            ? 31
                                                            : 33,
                                                      )
                                                    : Act0SkinTokensV1.secondaryButtonStyle(
                                                        tone: rowAccent,
                                                        height: compactRow
                                                            ? 31
                                                            : 33,
                                                      ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    ctaText,

                                                    style: Act0SkinTokensV1
                                                        .button
                                                        .copyWith(
                                                          color: usePrimaryCta
                                                              ? Act0SkinTokensV1
                                                                    .onAccent
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
                                                  style: Act0SkinTokensV1.body
                                                      .copyWith(
                                                        color: Act0SkinTokensV1
                                                            .onSurface,
                                                      ),
                                                ),
                                                if (hasPerfectOpportunity ||
                                                    widget.isPerfect) ...[
                                                  const SizedBox(
                                                    height:
                                                        Act0SkinTokensV1.gapXs,
                                                  ),
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

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Act0SkinTokensV1
                                                        .captionStyle
                                                        .copyWith(
                                                          color:
                                                              widget.isPerfect
                                                              ? Act0SkinTokensV1
                                                                    .accent
                                                              : rowAccent,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Act0SkinTokensV1.gapXs,
                                          ),
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
                                                  ? Act0SkinTokensV1.primaryButtonStyle(
                                                      height: compactRow
                                                          ? 31
                                                          : 33,
                                                    )
                                                  : Act0SkinTokensV1.secondaryButtonStyle(
                                                      tone: rowAccent,
                                                      height: compactRow
                                                          ? 31
                                                          : 33,
                                                    ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  ctaText,

                                                  style: Act0SkinTokensV1.button
                                                      .copyWith(
                                                        color: usePrimaryCta
                                                            ? Act0SkinTokensV1
                                                                  .onAccent
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
