part of 'act0_learn_path_shell_v1.dart';

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
      borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          Act0SkinTokensV1.gapMd,
          Act0SkinTokensV1.gapSm,
          Act0SkinTokensV1.gapMd,
          Act0SkinTokensV1.gapSm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusControl),
          border: Border.all(
            color: accent.withValues(alpha: Act0SkinTokensV1.tintSoft),
            width: 1.0,
          ),
          color: Act0SkinTokensV1.surface,
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
                    color: accent.withValues(alpha: Act0SkinTokensV1.tintSoft),
                    borderRadius: BorderRadius.circular(Act0SkinTokensV1.gapSm),
                    border: Border.all(
                      color: accent.withValues(
                        alpha: Act0SkinTokensV1.tintStrong,
                      ),
                    ),
                  ),
                  child: Text(
                    '$worldNumber',
                    style: Act0SkinTokensV1.captionStyle.copyWith(
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: Act0SkinTokensV1.gapSm),
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

                        style: Act0SkinTokensV1.headline.copyWith(
                          color: Act0SkinTokensV1.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compactHeader) ...[
                  const SizedBox(width: Act0SkinTokensV1.gapSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Act0SkinTokensV1.gapSm,
                      vertical: Act0SkinTokensV1.gapXs,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(
                        alpha: Act0SkinTokensV1.tintSubtle,
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0SkinTokensV1.radiusControl,
                      ),
                      border: Border.all(
                        color: accent.withValues(
                          alpha: Act0SkinTokensV1.tintStrong,
                        ),
                      ),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: Act0SkinTokensV1.captionStyle.copyWith(
                        color: accent,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: Act0SkinTokensV1.gapSm),
                Tooltip(
                  message: _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                  child: OutlinedButton.icon(
                    key: const Key('act0_shell_levels_menu_button'),
                    onPressed: onOpenWorldMenu,
                    style: Act0SkinTokensV1.secondaryButtonStyle(height: 26)
                        .copyWith(
                          minimumSize: const WidgetStatePropertyAll(
                            Size(0, 26),
                          ),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: compactHeader
                                  ? Act0SkinTokensV1.gapSm
                                  : Act0SkinTokensV1.gapSm,
                            ),
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            accent.withValues(
                              alpha: Act0SkinTokensV1.nearlyOpaque,
                            ),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            accent.withValues(
                              alpha: Act0SkinTokensV1.tintSubtle,
                            ),
                          ),
                          side: const WidgetStatePropertyAll(BorderSide.none),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Act0SkinTokensV1.radiusControl,
                              ),
                            ),
                          ),
                          textStyle: WidgetStatePropertyAll(
                            Act0SkinTokensV1.captionStyle,
                          ),
                        ),
                    icon: Icon(
                      Icons.map_rounded,
                      size: 13,
                      color: accent.withValues(
                        alpha: Act0SkinTokensV1.nearlyOpaque,
                      ),
                    ),
                    label: compactHeader
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
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    compactMeta,
                    key: const Key('act0_shell_learn_route_board'),
                    style: Act0SkinTokensV1.secondary.copyWith(
                      color: Act0SkinTokensV1.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Act0SkinTokensV1.gapXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(
                Act0SkinTokensV1.radiusControl,
              ),
              child: LinearProgressIndicator(
                key: const Key('act0_shell_learn_progress_bar'),
                value: normalizedProgress,
                minHeight: 1.5,
                backgroundColor: Act0SkinTokensV1.surface.withValues(
                  alpha: Act0SkinTokensV1.disabledOpacity,
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
    return Container(color: Act0SkinTokensV1.background, child: child);
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
        lesson.courseTaskList.any(
          (t) => pathClosedTaskIds.contains(t.taskId),
        ) &&
        lesson.courseTaskList.any((t) => !pathClosedTaskIds.contains(t.taskId));
    final stateColor = _stateColor(lesson.state);
    final completedAccent = Act0SkinTokensV1.accent;
    final icon = switch (lesson.state) {
      Act0LessonStateV1.completed => Icons.check_rounded,
      Act0LessonStateV1.current ||
      Act0LessonStateV1.available => Icons.play_arrow_rounded,
      Act0LessonStateV1.locked => Icons.lock_rounded,
    };
    final completedSteps = lesson.courseTaskList
        .where((t) => pathClosedTaskIds.contains(t.taskId))
        .length;
    final totalSteps = lesson.courseTaskList.length;
    final stepSummary = isCompleted
        ? (expanded ? '$totalSteps steps complete' : '')
        : isCurrent
        ? isInProgress
              ? '$completedSteps of $totalSteps steps complete'
              : '$totalSteps steps ready'
        : isLocked
        ? lesson.primaryCtaLabel == 'Clear weak spots'
              ? _learnCopyV1(
                  context,
                  en: 'Clear weak spots in Review to unlock',
                  ru: 'Разбери слабые места в Разборе, чтобы открыть',
                )
              : isNextUp && index > 1
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
    final lessonTitle = act0AcademyLessonTitleV1(context, lesson);
    final isExpandedFocus = expanded;
    final isHighlighted = selected || isCurrent || expanded;
    final currentAccent = Act0SkinTokensV1.accent;
    final nextAccent = Act0SkinTokensV1.accent;
    final showStateBadge = !(isCompleted && !expanded);
    final cardTint = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : worldAccent)
              .withValues(alpha: Act0SkinTokensV1.tintSubtle)
        : isCurrent
        ? currentAccent.withValues(alpha: Act0SkinTokensV1.tintSubtle)
        : isCompletedQuiet
        ? completedAccent.withValues(alpha: Act0SkinTokensV1.tintSubtle)
        : isLocked
        ? Act0SkinTokensV1.caption.withValues(
            alpha: Act0SkinTokensV1.tintSubtle,
          )
        : (isHighlighted ? stateColor : worldAccent).withValues(
            alpha: isHighlighted
                ? Act0SkinTokensV1.tintSubtle
                : Act0SkinTokensV1.tintSubtle,
          );
    final cardBorderColor = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : Act0SkinTokensV1.line)
              .withValues(
                alpha: isCurrent
                    ? Act0SkinTokensV1.edgeStrong
                    : Act0SkinTokensV1.edgeSoft,
              )
        : isCurrent
        ? currentAccent.withValues(alpha: Act0SkinTokensV1.tintStrong)
        : isCompleted
        ? completedAccent.withValues(
            alpha: isCompletedQuiet
                ? Act0SkinTokensV1.tintSubtle
                : Act0SkinTokensV1.tintSubtle,
          )
        : isLocked
        ? Act0SkinTokensV1.line.withValues(alpha: Act0SkinTokensV1.tintSoft)
        : isHighlighted
        ? stateColor.withValues(alpha: Act0SkinTokensV1.tintStrong)
        : Act0SkinTokensV1.line.withValues(alpha: Act0SkinTokensV1.edgeStrong);
    final cardGlowColor = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : worldAccent)
              .withValues(
                alpha: isCurrent
                    ? Act0SkinTokensV1.tintSoft
                    : Act0SkinTokensV1.tintSubtle,
              )
        : (isCurrent ? currentAccent : stateColor).withValues(
            alpha: isCurrent
                ? Act0SkinTokensV1.tintSubtle
                : Act0SkinTokensV1.tintSubtle,
          );
    final leadColor = isExpandedFocus
        ? (isCurrent
                  ? currentAccent
                  : isCompleted
                  ? completedAccent
                  : worldAccent)
              .withValues(
                alpha: isLocked
                    ? Act0SkinTokensV1.edgeSoft
                    : Act0SkinTokensV1.disabledOpacity,
              )
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
          ? Act0SkinTokensV1.radiusControl
          : Act0SkinTokensV1.radiusCard,
    );
    final rowPadding = EdgeInsets.fromLTRB(
      isCurrent ? Act0SkinTokensV1.gapLg : Act0SkinTokensV1.gapMd,
      isCompletedQuiet ? Act0SkinTokensV1.gapXs : Act0SkinTokensV1.gapSm,
      Act0SkinTokensV1.gapMd,
      isCompletedQuiet ? Act0SkinTokensV1.gapXs : Act0SkinTokensV1.gapSm,
    );
    final rowTitleStyle = Act0SkinTokensV1.headline.copyWith(
      color: isCompletedQuiet
          ? Act0SkinTokensV1.muted.withValues(
              alpha: Act0SkinTokensV1.nearlyOpaque,
            )
          : Act0SkinTokensV1.onSurface,
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
        color: Act0SkinTokensV1.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              cardTint,
              isCompletedQuiet
                  ? Act0SkinTokensV1.background
                  : Act0SkinTokensV1.raised,
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
                      color: currentAccent.withValues(
                        alpha: Act0SkinTokensV1.disabledOpacity,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(2.5),
                        bottomRight: Radius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LearnButtonV1(
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
                                      alpha: isCompletedQuiet
                                          ? Act0SkinTokensV1.tintSoft
                                          : Act0SkinTokensV1.tintSoft,
                                    )
                                  : iconTint.withValues(
                                      alpha: Act0SkinTokensV1.tintSoft,
                                    ),
                              borderRadius: BorderRadius.circular(
                                isCompletedQuiet
                                    ? Act0SkinTokensV1.gapSm
                                    : Act0SkinTokensV1.gapMd,
                              ),
                              border: Border.all(
                                color: iconTint.withValues(
                                  alpha: isCompletedQuiet
                                      ? Act0SkinTokensV1.tintStrong
                                      : Act0SkinTokensV1.tintStrong,
                                ),
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: iconTint.withValues(
                                alpha: isCompletedQuiet
                                    ? Act0SkinTokensV1.disabledOpacity
                                    : 1.0,
                              ),
                              size: isCompletedQuiet ? 13 : 16,
                            ),
                          ),
                          SizedBox(
                            width: isCompletedQuiet
                                ? Act0SkinTokensV1.gapSm
                                : Act0SkinTokensV1.gapSm,
                          ),
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
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Act0SkinTokensV1.gapSm,
                                      ),
                                      if (showStateBadge)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Act0SkinTokensV1.gapSm,
                                            vertical: Act0SkinTokensV1.gapXs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeTint.withValues(
                                              alpha:
                                                  Act0SkinTokensV1.tintSubtle,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              Act0SkinTokensV1.radiusControl,
                                            ),
                                            border: Border.all(
                                              color: badgeTint.withValues(
                                                alpha:
                                                    Act0SkinTokensV1.tintSoft,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            stateBadgeLabel,
                                            key: Key(
                                              'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                                            ),

                                            style: Act0SkinTokensV1.captionStyle
                                                .copyWith(color: badgeTint),
                                          ),
                                        ),
                                      const SizedBox(
                                        width: Act0SkinTokensV1.gapXs,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: Act0SkinTokensV1.gapXs,
                                        ),
                                        child: AnimatedRotation(
                                          turns: expanded ? 0.5 : 0.0,
                                          duration:
                                              MediaQuery.disableAnimationsOf(
                                                context,
                                              )
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 280,
                                                ),
                                          curve: Curves.easeOutCubic,
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 17,
                                            color: badgeTint.withValues(
                                              alpha: Act0SkinTokensV1
                                                  .iconMutedOpacity,
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
                                        style: Act0SkinTokensV1.captionStyle
                                            .copyWith(color: badgeTint),
                                      ),
                                      const Spacer(),
                                      AnimatedRotation(
                                        turns: expanded ? 0.5 : 0.0,
                                        duration:
                                            MediaQuery.disableAnimationsOf(
                                              context,
                                            )
                                            ? Duration.zero
                                            : const Duration(milliseconds: 280),
                                        curve: Curves.easeOutCubic,
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 17,
                                          color: badgeTint.withValues(
                                            alpha: Act0SkinTokensV1
                                                .iconMutedOpacity,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Act0SkinTokensV1.gapXs,
                                      ),
                                      if (showStateBadge)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Act0SkinTokensV1.gapSm,
                                            vertical: Act0SkinTokensV1.gapXs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeTint.withValues(
                                              alpha:
                                                  Act0SkinTokensV1.tintSubtle,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              Act0SkinTokensV1.radiusControl,
                                            ),
                                            border: Border.all(
                                              color: badgeTint.withValues(
                                                alpha:
                                                    Act0SkinTokensV1.tintSoft,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            stateBadgeLabel,
                                            key: Key(
                                              'act0_shell_learn_lesson_state_text_${lesson.lessonId}',
                                            ),

                                            style: Act0SkinTokensV1.captionStyle
                                                .copyWith(color: badgeTint),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: Act0SkinTokensV1.gapXs,
                                  ),
                                  Text(lessonTitle, style: rowTitleStyle),
                                ],
                                if (stepSummary.isNotEmpty) ...[
                                  const SizedBox(
                                    height: Act0SkinTokensV1.gapXs,
                                  ),
                                  Text(
                                    stepSummary,
                                    style: Act0SkinTokensV1.secondary.copyWith(
                                      color: isLocked
                                          ? Act0SkinTokensV1.caption
                                          : Act0SkinTokensV1.muted,
                                    ),
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
                                        horizontal: Act0SkinTokensV1.gapMd,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: badgeTint.withValues(
                                          alpha: Act0SkinTokensV1.tintSoft,
                                        ),
                                      ),
                                    ),
                                    expandedBody!,
                                  ],
                                ))
                        : AnimatedSize(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 140),
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
                                          horizontal: Act0SkinTokensV1.gapMd,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: badgeTint.withValues(
                                            alpha: Act0SkinTokensV1.tintSoft,
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
    Act0LessonStateV1.completed => Act0SkinTokensV1.accent,
    Act0LessonStateV1.current ||
    Act0LessonStateV1.available => Act0SkinTokensV1.accent,
    Act0LessonStateV1.locked => Act0SkinTokensV1.caption,
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
    return _learnPlayerCopyV1(
      act0AcademyTaskLockedSummaryV1(
        context,
        task,
        fallback:
            task.lockedSummary ??
            _learnCopyV1(
              context,
              en: blockerTitle.isNotEmpty
                  ? 'Clear ${blockerTitle.toLowerCase()} first, then this node opens.'
                  : 'Clear ${_learnTaskTitleV1(context, nextTask).toLowerCase()} first, then this node opens.',
              ru: blockerTitle.isNotEmpty
                  ? 'Сначала закрой шаг «${blockerTitle.toLowerCase()}», потом этот узел откроется.'
                  : '\u0421\u043d\u0430\u0447\u0430\u043b\u0430 \u0437\u0430\u043a\u0440\u043e\u0439 \u0448\u0430\u0433 \u00ab${_learnTaskTitleV1(context, nextTask).toLowerCase()}\u00bb, \u043f\u043e\u0442\u043e\u043c \u044d\u0442\u043e\u0442 \u0443\u0437\u0435\u043b \u043e\u0442\u043a\u0440\u043e\u0435\u0442\u0441\u044f.',
            ),
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
  return _preChoiceTaskSummaryV1(context, task);
}

// Unrequested Learn previews must not classify the hand before its bucket
// decision. Keep the authored caption in the runner, teaching and feedback.
String _preChoiceTaskSummaryV1(BuildContext context, Act0LessonTaskV1 task) {
  if (task.taskId == 'hand_discipline_buckets_trash') {
    return _learnCopyV1(
      context,
      en: 'J8o from early position: look at the cards and choose a bucket yourself.',
      ru: 'Разномастные валет и восьмёрка с ранней позиции: посмотри на карты и самостоятельно выбери категорию.',
    );
  }
  return _learnPlayerCopyV1(
    act0PrechoiceDisplaySummaryV1(
      taskId: task.taskId,
      authoredSummary: act0AcademyTaskSummaryV1(
        context,
        task,
        fallback: task.summary ?? task.runner.caption,
      ),
      isAssessment: act0IsPrechoiceAssessmentTaskV1(task),
      hasSubmittedCurrentDecision: false,
    ),
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
  if (lesson.lessonId == 'fold_check_call_raise') {
    return _learnCopyV1(
      context,
      en: 'This lesson teaches one table read: what each legal action means before you choose.',
      ru: 'Этот урок учит одному чтению стола: что значит каждое доступное действие перед выбором.',
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
  final nextTaskTitle = _learnTaskTitleV1(context, nextTask).trim();
  final nextTaskSummary = _preChoiceTaskSummaryV1(context, nextTask).trim();
  final safeSummary =
      nextTaskSummary.isEmpty || nextTaskSummary == nextTaskTitle
      ? null
      : nextTaskSummary;

  if (lesson.lessonId == 'fold_check_call_raise') {
    return _learnCopyV1(
      context,
      en: 'Lesson read: legal actions first, then choose without guessing.',
      ru: 'Чтение урока: сначала доступные действия, потом выбор без угадывания.',
    );
  }

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
    Act0WorldStateV1.completed ||
    Act0WorldStateV1.passedByRulesCheck => Act0SkinTokensV1.accent,
    Act0WorldStateV1.current => Act0SkinTokensV1.accent,
    Act0WorldStateV1.locked => Act0SkinTokensV1.caption,
  };
}

class _StateBadgeV1 extends StatelessWidget {
  const _StateBadgeV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Act0SkinChipV1(
    label: label,
    tone: color == Act0SkinTokensV1.ok
        ? Act0SkinChipToneV1.correct
        : color == Act0SkinTokensV1.accent
        ? Act0SkinChipToneV1.brass
        : Act0SkinChipToneV1.neutral,
  );
}
