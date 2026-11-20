part of 'act0_learn_path_shell_v1.dart';

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
    required this.detailMode,
    required this.firstLessonLanding,
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
  final bool detailMode;
  final bool firstLessonLanding;
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
          totalSteps: currentMissionLesson.courseTaskList.length,
          accent: Act0AcademyDarkReadingStyleV1.primary,
          detailMode: detailMode,
          firstLessonLanding: firstLessonLanding,
          onStart: onStartMission,
        ),
        const SizedBox(height: 12),
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
    final conciseProgressLabel = moduleProgressLabel
        .replaceFirst(RegExp(r'\s+complete$'), '')
        .trim();
    return Material(
      key: const Key('act0_shell_module_header'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Ink(
          key: const Key('act0_shell_learn_v5_world_context'),
          padding: EdgeInsets.fromLTRB(compact ? 12 : 14, 10, 12, 10),
          decoration: Act0AcademyDarkReadingStyleV1.cardDecoration(
            borderColor: Act0AcademyDarkReadingStyleV1.primary.withValues(
              alpha: 0.42,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 32 : 36,
                height: compact ? 32 : 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0AcademyDarkReadingStyleV1.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                  border: Border.all(
                    color: Act0AcademyDarkReadingStyleV1.primary.withValues(
                      alpha: 0.28,
                    ),
                  ),
                ),
                child: Text(
                  '${world.worldNumber}',
                  style: Act0AcademyDarkReadingStyleV1.sectionHeading.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.primary,
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
                              en: 'Current world · W${world.worldNumber}',
                              ru: 'Текущий мир · W${world.worldNumber}',
                            ),
                            style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                              color: Act0AcademyDarkReadingStyleV1.primary,
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

                              style: Act0AcademyDarkReadingStyleV1.label
                                  .copyWith(fontSize: 9.4, letterSpacing: 0),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      act0AcademyWorldTitleV1(context, world),

                      style: Act0AcademyDarkReadingStyleV1.sectionHeading
                          .copyWith(
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
                              key: const Key('act0_shell_learn_progress_bar'),
                              value: normalizedProgress,
                              minHeight: 3,
                              backgroundColor: Act0AcademyDarkReadingStyleV1
                                  .border
                                  .withValues(alpha: 0.55),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Act0AcademyDarkReadingStyleV1.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$progressPercent%',
                          style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                            color: Act0AcademyDarkReadingStyleV1.primary,
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
                        en: conciseProgressLabel,
                        ru: act0AcademyProgressLabelV1(
                          context,
                          conciseProgressLabel,
                        ),
                      ),
                      key: const Key('act0_shell_learn_route_board'),

                      style: Act0AcademyDarkReadingStyleV1.supporting.copyWith(
                        fontSize: 9.8,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                container: true,
                label: _learnCopyV1(
                  context,
                  en: 'Open worlds',
                  ru: '\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043c\u0438\u0440\u044b',
                ),
                button: true,
                onTap: onOpenWorldMenu,
                excludeSemantics: true,
                child: Tooltip(
                  message: _learnCopyV1(
                    context,
                    en: 'Worlds',
                    ru: '\u041c\u0438\u0440\u044b',
                  ),
                  child: OutlinedButton.icon(
                    key: const Key('act0_shell_levels_menu_button'),
                    onPressed: onOpenWorldMenu,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 7 : 9,
                      ),
                      foregroundColor: Act0AcademyDarkReadingStyleV1.primary,
                      backgroundColor: Act0AcademyDarkReadingStyleV1.primary
                          .withValues(alpha: 0.075),
                      side: BorderSide(
                        color: Act0AcademyDarkReadingStyleV1.primary.withValues(
                          alpha: 0.32,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Act0AcademyDesignTokensV1.radiusCard,
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.map_rounded,
                      size: 15,
                      color: Act0AcademyDarkReadingStyleV1.primary,
                    ),
                    label: compact
                        ? const SizedBox.shrink()
                        : Text(
                            _learnCopyV1(
                              context,
                              en: 'Worlds',
                              ru: '\u041c\u0438\u0440\u044b',
                            ),
                          ),
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
                  en: showFullPath ? 'All lessons' : 'Up next',
                  ru: showFullPath ? 'Все уроки' : 'Дальше',
                ),
                key: const Key('act0_shell_journey_path_header'),
                style: Act0AcademyDarkReadingStyleV1.sectionHeading.copyWith(
                  fontSize: 14.4,
                  height: 1.05,
                ),
              ),
            ),
            TextButton(
              key: const Key('act0_shell_learn_v5_view_full_path'),
              onPressed: onToggleFullPath,
              style: TextButton.styleFrom(
                foregroundColor: Act0AcademyDarkReadingStyleV1.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: Act0AcademyDarkReadingStyleV1.label.copyWith(
                  fontSize: 10.0,
                  letterSpacing: 0.04,
                ),
              ),
              child: Text(
                _learnCopyV1(
                  context,
                  en: showFullPath ? 'Show less' : 'All lessons',
                  ru: showFullPath ? 'Свернуть' : 'Все уроки',
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

          style: Act0AcademyDarkReadingStyleV1.supporting,
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
          decoration: Act0AcademyDarkReadingStyleV1.cardDecoration(),
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
    final isEarnedCompleted =
        isCompleted &&
        lesson.courseTaskList.isNotEmpty &&
        lesson.courseTaskList.every(
          (task) => completedTaskIds.contains(task.taskId),
        );
    final isPlacementCleared =
        isCompleted &&
        !isEarnedCompleted &&
        lesson.courseTaskList.any(
          (task) => skippedTaskIds.contains(task.taskId),
        );
    final isCurrent = lesson.state == Act0LessonStateV1.current;
    final isLocked = lesson.state == Act0LessonStateV1.locked;
    final accent = isNextUp
        ? Act0AcademyDarkReadingStyleV1.needsReviewFg
        : isLocked
        ? Act0AcademyDarkReadingStyleV1.textMuted
        : isEarnedCompleted
        ? Act0AcademyDarkReadingStyleV1.correctFg
        : Act0AcademyDarkReadingStyleV1.primary;
    final opacity = isCurrent
        ? 1.0
        : isEarnedCompleted
        ? 1.0
        : isLocked
        ? (isNextUp ? 0.92 : 0.78)
        : 1.0;
    final stateLabel = isEarnedCompleted
        ? null
        : isPlacementCleared
        ? _learnCopyV1(
            context,
            en: 'Placed',
            ru: '\u041f\u043e \u0443\u0440\u043e\u0432\u043d\u044e',
          )
        : isCurrent
        ? _learnCopyV1(context, en: 'Now', ru: 'Сейчас')
        : isNextUp
        ? _learnCopyV1(context, en: 'Next', ru: 'Дальше')
        : isLocked
        ? _learnCopyV1(context, en: 'Locked', ru: 'Закрыт')
        : null;
    final meta = isEarnedCompleted
        ? _learnCopyV1(context, en: 'Replay available', ru: 'Можно повторить')
        : isPlacementCleared
        ? _learnCopyV1(
            context,
            en: 'Placement cleared - available to practice',
            ru: '\u041f\u0440\u043e\u043f\u0443\u0449\u0435\u043d \u043f\u043e \u0443\u0440\u043e\u0432\u043d\u044e - \u041c\u043e\u0436\u043d\u043e \u043f\u0440\u043e\u0439\u0442\u0438',
          )
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
    final icon = isEarnedCompleted
        ? Icons.check_rounded
        : isCurrent
        ? Icons.my_location_rounded
        : isLocked
        ? Icons.lock_rounded
        : Icons.circle_rounded;
    final fill = isCurrent
        ? Act0AcademyDarkReadingStyleV1.primary.withValues(alpha: 0.06)
        : isEarnedCompleted
        ? Act0AcademyDarkReadingStyleV1.correctBg
        : isNextUp
        ? Act0AcademyDarkReadingStyleV1.needsReviewBg
        : Act0AcademyDarkReadingStyleV1.surface;
    final border = isCurrent
        ? Act0AcademyDarkReadingStyleV1.primary.withValues(alpha: 0.32)
        : isEarnedCompleted
        ? Act0AcademyDarkReadingStyleV1.correctFg.withValues(alpha: 0.24)
        : isNextUp
        ? Act0AcademyDarkReadingStyleV1.needsReviewFg.withValues(alpha: 0.28)
        : Act0AcademyDarkReadingStyleV1.border;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          Act0AcademyDesignTokensV1.radiusCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(
              Act0AcademyDesignTokensV1.radiusCard,
            ),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                key: Key('act0_shell_lesson_${lesson.title}'),
                onTap: () => onSelectLesson(lesson.lessonId),
                borderRadius: BorderRadius.circular(
                  Act0AcademyDesignTokensV1.radiusCard,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCurrent ? 11 : 9,
                    isCurrent
                        ? 9
                        : isEarnedCompleted
                        ? 7
                        : 8,
                    9,
                    isCurrent
                        ? 9
                        : isEarnedCompleted
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
                          color: accent.withValues(
                            alpha: isCompleted ? 0.18 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(
                            isCompleted ? 8 : 10,
                          ),
                          border: Border.all(
                            color: accent.withValues(
                              alpha: isCompleted ? 0.30 : 0.36,
                            ),
                          ),
                        ),
                        child: isEarnedCompleted
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
                                style: Act0AcademyDarkReadingStyleV1.label
                                    .copyWith(
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
                              act0AcademyLessonTitleV1(context, lesson),

                              style: Act0AcademyDarkReadingStyleV1
                                  .sectionHeading
                                  .copyWith(
                                    color: isLocked
                                        ? Act0AcademyDarkReadingStyleV1
                                              .textMuted
                                        : Act0AcademyDarkReadingStyleV1.text,
                                    fontSize: isCompleted ? 12.8 : 13.6,
                                    height: 1.05,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              meta,

                              style: Act0AcademyDarkReadingStyleV1.supporting
                                  .copyWith(fontSize: 10.2, height: 1.0),
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
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(
                              Act0AcademyDesignTokensV1.radiusCard,
                            ),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            stateLabel,
                            key: Key(
                              'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                            ),
                            style: Act0AcademyDarkReadingStyleV1.label.copyWith(
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
        color: Act0AcademyDarkReadingStyleV1.pageSurface,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
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
                color: Act0AcademyDarkReadingStyleV1.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  key: const Key('act0_shell_learn_v5_future_summary'),

                  style: Act0AcademyDarkReadingStyleV1.supporting.copyWith(
                    fontSize: 10.8,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _learnCopyV1(context, en: 'In order', ru: 'По порядку'),
                style: Act0AcademyDarkReadingStyleV1.label.copyWith(
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
                        ? Act0AcademyDarkReadingStyleV1.primary.withValues(
                            alpha: 0.24,
                          )
                        : Act0AcademyDarkReadingStyleV1.border,
                    border: Border.all(
                      color: i == 1
                          ? Act0AcademyDarkReadingStyleV1.primary.withValues(
                              alpha: 0.36,
                            )
                          : Act0AcademyDarkReadingStyleV1.border,
                    ),
                  ),
                ),
                if (i < 3)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      color: Act0AcademyDarkReadingStyleV1.border,
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
                color: Act0AcademyDarkReadingStyleV1.primary.withValues(
                  alpha: 0.05,
                ),
                border: Border.all(
                  color: Act0AcademyDarkReadingStyleV1.primary.withValues(
                    alpha: 0.14,
                  ),
                ),
              ),
              child: Text(
                _learnCopyV1(
                  context,
                  en: 'The road ahead opens one mission at a time.',
                  ru: 'Путь впереди открывается по одной миссии.',
                ),

                style: Act0AcademyDarkReadingStyleV1.supporting.copyWith(
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
