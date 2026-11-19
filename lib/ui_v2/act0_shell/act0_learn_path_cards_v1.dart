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
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 9.6,
                      height: 1.0,
                    ),
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
    final lessonTitle = act0AcademyLessonTitleV1(context, lesson);
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
                                  Text(lessonTitle, style: rowTitleStyle),
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
    return act0AcademyTaskLockedSummaryV1(
      context,
      task,
      fallback:
          task.lockedSummary ??
          _learnCopyV1(
            context,
            en: blockerTitle.isNotEmpty
                ? 'Clear ${blockerTitle.toLowerCase()} first, then this node opens.'
                : 'Clear ${act0AcademyTaskTitleV1(context, nextTask).toLowerCase()} first, then this node opens.',
            ru: blockerTitle.isNotEmpty
                ? 'Сначала закрой шаг «${blockerTitle.toLowerCase()}», потом этот узел откроется.'
                : '\u0421\u043d\u0430\u0447\u0430\u043b\u0430 \u0437\u0430\u043a\u0440\u043e\u0439 \u0448\u0430\u0433 \u00ab${act0AcademyTaskTitleV1(context, nextTask).toLowerCase()}\u00bb, \u043f\u043e\u0442\u043e\u043c \u044d\u0442\u043e\u0442 \u0443\u0437\u0435\u043b \u043e\u0442\u043a\u0440\u043e\u0435\u0442\u0441\u044f.',
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
  return act0PrechoiceDisplaySummaryV1(
    taskId: task.taskId,
    authoredSummary: act0AcademyTaskSummaryV1(
      context,
      task,
      fallback: task.summary ?? task.runner.caption,
    ),
    isAssessment: act0IsPrechoiceAssessmentTaskV1(task),
    hasSubmittedCurrentDecision: false,
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
  final nextTaskTitle = act0AcademyTaskTitleV1(context, nextTask).trim();
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
