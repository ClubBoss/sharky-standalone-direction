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
        ? Act0ShellTokensV1.textDim
        : Act0ShellTokensV1.primary;
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
    required this.detailMode,
    required this.firstLessonLanding,
    required this.onStart,
  });

  final Act0LessonCardV1 lesson;
  final Act0LessonTaskV1 task;
  final int stepIndex;
  final int totalSteps;
  final Color accent;
  final bool detailMode;
  final bool firstLessonLanding;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final lessonTitle = act0AcademyLessonTitleV1(context, lesson);
    final taskTitle = act0AcademyTaskTitleV1(context, task);
    final visualVariant = _missionVisualVariantForV1(lesson, task);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final support = firstLessonLanding
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
                compact: compact,
                visualVariant: visualVariant,
              );
        return Container(
          key: detailMode
              ? const Key('act0_shell_lesson_detail_hero')
              : const Key('act0_shell_current_mission_card'),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 15 : 18,
            17,
            compact ? 15 : 18,
            17,
          ),
          decoration: Act0AcademyDesignTokensV1.cardDecoration(
            borderColor: accent.withValues(alpha: detailMode ? 0.60 : 0.32),
          ),
          child: Column(
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
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(color: accent.withValues(alpha: 0.32)),
                    ),
                    child: Text(
                      _learnCopyV1(
                        context,
                        en: firstLessonLanding
                            ? 'FIRST TABLE GUIDE'
                            : detailMode
                            ? 'Lesson read'
                            : 'Learn route',
                        ru: detailMode ? 'Чтение урока' : 'Маршрут обучения',
                      ),
                      style: Act0AcademyDesignTokensV1.label.copyWith(
                        color: accent,
                        fontSize: 9.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (!firstLessonLanding) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _learnCopyV1(
                          context,
                          en: detailMode
                              ? 'What this teaches'
                              : 'Current table read',
                          ru: detailMode
                              ? 'Что это учит'
                              : 'Текущее чтение стола',
                        ),

                        style: Act0AcademyDesignTokensV1.label.copyWith(
                          letterSpacing: 0,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
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
                      style: Act0AcademyDesignTokensV1.lessonHeading.copyWith(
                        fontSize: 30,
                        height: 1.16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!firstLessonLanding) ...[
                      Text(
                        _learnCopyV1(
                          context,
                          en: 'Why it matters',
                          ru: 'Зачем это нужно',
                        ),
                        style: Act0AcademyDesignTokensV1.label.copyWith(
                          color: accent,
                          fontSize: 9.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      support,
                      key: const Key('act0_shell_current_mission_support'),
                      style: Act0AcademyDesignTokensV1.supporting.copyWith(
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 16 : 18),
              if (!firstLessonLanding)
                Container(
                  key: const Key('act0_shell_current_mission_step_card'),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.06),
                    border: Border(left: BorderSide(color: accent, width: 3)),
                  ),
                  child: KeyedSubtree(
                    key: const Key('act0_shell_current_mission_step_band'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _learnCopyV1(
                            context,
                            en: 'Current step · $stepIndex of $totalSteps',
                            ru: 'Текущий шаг · $stepIndex из $totalSteps',
                          ),
                          style: Act0AcademyDesignTokensV1.label.copyWith(
                            color: accent,
                            letterSpacing: 0,
                            fontSize: 9.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          taskTitle,
                          style: Act0AcademyDesignTokensV1.body.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('act0_shell_current_mission_cta'),
                  onPressed: onStart,
                  style: Act0AcademyDesignTokensV1.primaryButtonStyle(),
                  child: Text(
                    _learnCopyV1(
                      context,
                      en: firstLessonLanding ? 'Start first table' : 'Start',
                      ru: firstLessonLanding
                          ? '\u041d\u0430\u0447\u0430\u0442\u044c \u043f\u0435\u0440\u0432\u044b\u0439 \u0441\u0442\u043e\u043b'
                          : '\u0421\u0442\u0430\u0440\u0442',
                    ),
                  ),
                ),
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
      Act0LessonStateV1.current ||
      Act0LessonStateV1.available => Act0ShellTokensV1.primary,
      Act0LessonStateV1.completed => Act0ShellTokensV1.textMuted,
      Act0LessonStateV1.locked =>
        isNextUp ? Act0ShellTokensV1.gold : Act0ShellTokensV1.textDim,
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
                                        act0AcademyTaskTitleV1(
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
