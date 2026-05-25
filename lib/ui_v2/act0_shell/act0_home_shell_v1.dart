import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String _shellCopyV1(
  BuildContext context, {
  required String en,
  required String ru,
}) => _isRuLocaleV1(context) ? ru : en;

class Act0HomePlanJobV1 {
  const Act0HomePlanJobV1({
    required this.jobId,
    required this.label,
    required this.title,
    this.detail = '',
  });

  final String jobId;
  final String label;
  final String title;
  final String detail;
}

class Act0HomeWeeklyFocusV1 {
  const Act0HomeWeeklyFocusV1({
    required this.title,
    this.label = 'Weekly focus',
    this.detail = '',
  });

  final String label;
  final String title;
  final String detail;
}

class Act0HomeChecklistRowV1 {
  const Act0HomeChecklistRowV1({
    required this.rowKey,
    required this.stepNumber,
    required this.label,
    required this.title,
    required this.icon,
    required this.accentColor,
    this.detail = '',
    this.tapKey,
    this.onTap,
    this.isRepairAction = false,
  });

  final String rowKey;
  final int stepNumber;
  final String label;
  final String title;
  final String detail;
  final IconData icon;
  final Color accentColor;
  final String? tapKey;
  final VoidCallback? onTap;
  final bool isRepairAction;
}

class Act0HomeShellV1 extends StatelessWidget {
  const Act0HomeShellV1({
    super.key,
    required this.state,
    this.currentLesson,
    this.pathProgressLabel,
    this.nextActionLabel = 'Continue',
    this.nextActionTitle,
    this.nextActionSubtitle,
    this.nextActionCtaLabel = 'Continue',
    this.nextActionHint,
    this.repairLabel = 'Review',
    this.repairHeadline,
    this.repairDetail,
    this.repairOutcome,
    this.repairCtaLabel,
    this.showRepairPanel = true,
    this.onStartRepair,
    this.dailyGoalValue,
    this.dailyGoalCtaLabel = 'Start practice',
    this.dailyPlanTitle,
    this.weeklyFocus,
    this.dailyPlanJobs = const <Act0HomePlanJobV1>[],
    this.onOpenDailyPlanJob,
    this.onOpenLearnContext,
    this.onOpenPracticeContext,
    this.onOpenReviewContext,
    this.sharkyOverride,
    this.onOpenDevMenu,
    this.onStartDailyDrill,
    this.showChecklist,
    this.completionEarnedStreak = false,
    required this.onContinue,
  });

  final Act0ShellStateV1 state;
  final Act0LessonCardV1? currentLesson;
  final String? pathProgressLabel;
  final String nextActionLabel;
  final String? nextActionTitle;
  final String? nextActionSubtitle;
  final String nextActionCtaLabel;
  final String? nextActionHint;
  final String repairLabel;
  final String? repairHeadline;
  final String? repairDetail;
  final String? repairOutcome;
  final String? repairCtaLabel;
  final bool showRepairPanel;
  final VoidCallback? onStartRepair;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final String? dailyPlanTitle;
  final Act0HomeWeeklyFocusV1? weeklyFocus;
  final List<Act0HomePlanJobV1> dailyPlanJobs;
  final ValueChanged<String>? onOpenDailyPlanJob;
  final VoidCallback? onOpenLearnContext;
  final VoidCallback? onOpenPracticeContext;
  final VoidCallback? onOpenReviewContext;
  final Act0SharkyCueV1? sharkyOverride;
  final VoidCallback? onOpenDevMenu;
  final VoidCallback? onStartDailyDrill;
  final bool? showChecklist;
  final bool completionEarnedStreak;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final lesson = currentLesson ?? state.currentLesson;
    final title =
        nextActionTitle ?? act0LocalizedLessonTitleV1(context, lesson);
    final subtitle =
        nextActionSubtitle ?? act0LocalizedLessonSubtitleV1(context, lesson);
    final courseTitle = act0LocalizedWorldTitleV1(context, state.selectedWorld);
    final sharky = sharkyOverride ?? lesson.runner.sharky;
    final nextActionLabel = this.nextActionLabel == 'Continue'
        ? _shellCopyV1(context, en: 'Next', ru: 'Дальше')
        : this.nextActionLabel;
    final nextActionCtaLabel = this.nextActionCtaLabel == 'Continue'
        ? _shellCopyV1(context, en: 'Continue', ru: 'Продолжить')
        : this.nextActionCtaLabel;
    final repairLabel = this.repairLabel == 'Review'
        ? _shellCopyV1(context, en: 'Review', ru: 'Разбор')
        : this.repairLabel;
    final dailyGoalCtaLabel = this.dailyGoalCtaLabel == 'Start practice'
        ? _shellCopyV1(context, en: 'Start practice', ru: 'Начать практику')
        : this.dailyGoalCtaLabel;
    final goalValue = dailyGoalValue ?? state.dailyGoalValue;
    final checklistActive =
        showChecklist ??
        dailyPlanJobs.isNotEmpty ||
            showRepairPanel ||
            (weeklyFocus != null && weeklyFocus!.title.trim().isNotEmpty) ||
            _isDailyGoalDoneValue(goalValue);
    final normalizedWeeklyFocus =
        !checklistActive ||
            weeklyFocus == null ||
            weeklyFocus!.title.trim().isEmpty
        ? null
        : Act0HomeWeeklyFocusV1(
            label: weeklyFocus!.label == 'Weekly focus'
                ? _shellCopyV1(context, en: 'Focus today', ru: 'Фокус сегодня')
                : weeklyFocus!.label,
            title: weeklyFocus!.title.trim(),
            detail: weeklyFocus!.detail.trim(),
          );
    final showFocusStrip =
        normalizedWeeklyFocus != null &&
        normalizedWeeklyFocus.title.trim().toLowerCase() !=
            title.trim().toLowerCase();
    final heroCard = Container(
      padding: EdgeInsets.all(
        checklistActive ? Act0ShellTokensV1.gapMd : Act0ShellTokensV1.gapLg,
      ),
      decoration: Act0ShellTokensV1.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pathProgressLabel?.trim().isNotEmpty == true
                ? pathProgressLabel!.trim()
                : _shellCopyV1(
                    context,
                    en: 'Active world: $courseTitle',
                    ru: 'Активный мир: $courseTitle',
                  ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textDim,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('act0_shell_home_primary_tap_target'),
              onTap: onContinue,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: checklistActive ? 38 : 44,
                          height: checklistActive ? 38 : 44,
                          decoration: BoxDecoration(
                            color: Act0ShellTokensV1.primary,
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusMd,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Act0ShellTokensV1.primary.withValues(
                                  alpha: 0.38,
                                ),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Act0ShellTokensV1.onPrimary,
                          ),
                        ),
                        const SizedBox(width: Act0ShellTokensV1.gapMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                checklistActive
                                    ? _shellCopyV1(
                                        context,
                                        en: 'Continue path',
                                        ru: 'Продолжить путь',
                                      )
                                    : nextActionLabel,
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: Act0ShellTokensV1.primary,
                                ),
                              ),
                              if (!checklistActive) ...[
                                const SizedBox(height: Act0ShellTokensV1.gapXs),
                                Text(
                                  title,
                                  style: Act0ShellTokensV1.sectionTitle,
                                ),
                              ] else ...[
                                const SizedBox(height: 2),
                                Text(
                                  _shellCopyV1(
                                    context,
                                    en: 'One fresh lesson step is still open.',
                                    ru: 'Один новый шаг урока всё ещё открыт.',
                                  ),
                                  style: Act0ShellTokensV1.muted.copyWith(
                                    color: Act0ShellTokensV1.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Act0ShellTokensV1.primary,
                        ),
                      ],
                    ),
                    if (!checklistActive) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Text(
                        subtitle,
                        key: const Key('act0_shell_home_next_action_subtitle'),
                        style: Act0ShellTokensV1.muted,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ),
                    ],
                    if (!checklistActive &&
                        nextActionHint?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        nextActionHint!.trim(),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.textDim,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          FilledButton(
            key: const Key('act0_shell_main_cta'),
            onPressed: onContinue,
            style: Act0ShellTokensV1.primaryButtonStyle(),
            child: Text(nextActionCtaLabel),
          ),
        ],
      ),
    );
    final dailyCard = _DailyGoalCardV1(
      localeIsRu: _isRuLocaleV1(context),
      state: state,
      dailyGoalValue: goalValue,
      dailyGoalCtaLabel: dailyGoalCtaLabel,
      onStartDailyDrill: onStartDailyDrill,
    );
    final sharkyFooter = _HomeFooterSharkyLineV1(
      state: state,
      sharky: sharky,
      localeIsRu: _isRuLocaleV1(context),
    );
    final routeSurface = checklistActive
        ? _HomeCompactRouteStripV1(contextTitle: courseTitle, onTap: onContinue)
        : heroCard;
    final checklistRows = _buildChecklistRows(
      context,
      goalValue: goalValue,
      checklistActive: checklistActive,
      showReviewOnlyIfDue: true,
    );
    return ListView(
      key: const Key('act0_shell_home_screen'),
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        Act0ShellTokensV1.gapLg,
        pagePadding,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Act0ShellScreenHeaderV1(
          title: _shellCopyV1(context, en: 'Home', ru: 'Главная'),
          subtitle: _shellCopyV1(
            context,
            en: 'One clear next step is waiting below.',
            ru: 'Ниже тебя ждёт один ясный следующий шаг.',
          ),
          eyebrow: _shellCopyV1(
            context,
            en: 'Active world: $courseTitle',
            ru: 'Активный мир: $courseTitle',
          ),
          trailing: onOpenDevMenu == null
              ? null
              : IconButton(
                  key: const Key('act0_shell_home_dev_menu_button'),
                  onPressed: onOpenDevMenu,
                  icon: const Icon(Icons.more_horiz_rounded),
                  color: Act0ShellTokensV1.muted.color,
                  splashRadius: 18,
                  tooltip: _shellCopyV1(
                    context,
                    en: 'Dev menu',
                    ru: 'Меню разработчика',
                  ),
                  visualDensity: const VisualDensity(
                    horizontal: -3,
                    vertical: -3,
                  ),
                ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeDashboardRowV1(
                state: state,
                localeIsRu: _isRuLocaleV1(context),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              routeSurface,
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              if (showFocusStrip) ...[
                _HomeWeeklyFocusStripV1(
                  localeIsRu: _isRuLocaleV1(context),
                  focus: normalizedWeeklyFocus,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
              ],
              if (checklistActive)
                (_isDailyGoalDoneValue(goalValue)
                    ? _HomeCompletionSurfaceV1(
                        localeIsRu: _isRuLocaleV1(context),
                        earnedStreak: completionEarnedStreak,
                        streakDays: state.streakDays,
                      )
                    : _HomeChecklistSurfaceV1(
                        rows: checklistRows,
                        localeIsRu: _isRuLocaleV1(context),
                        title:
                            dailyPlanTitle ??
                            _shellCopyV1(
                              context,
                              en: "Today's training",
                              ru: 'Тренировка на сегодня',
                            ),
                      ))
              else
                dailyCard,
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              sharkyFooter,
            ],
          ),
        ),
      ],
    );
  }

  List<Act0HomeChecklistRowV1> _buildChecklistRows(
    BuildContext context, {
    required String goalValue,
    required bool checklistActive,
    required bool showReviewOnlyIfDue,
  }) {
    Act0HomePlanJobV1? findJob(String prefix) {
      for (final job in dailyPlanJobs) {
        if (job.jobId.startsWith(prefix)) {
          return job;
        }
      }
      return null;
    }

    Act0HomePlanJobV1? findExactJob(String id) {
      for (final job in dailyPlanJobs) {
        if (job.jobId == id) {
          return job;
        }
      }
      return null;
    }

    final continueJob = findExactJob('continue');
    final repairJob = findJob('repair:');
    final recheckJob = findJob('recheck:');
    final proveJob = findJob('prove:');
    final localeIsRu = _isRuLocaleV1(context);
    final learnDetail = checklistActive
        ? ''
        : (continueJob?.detail.trim().isNotEmpty ?? false)
        ? continueJob!.detail.trim()
        : nextActionSubtitle?.trim() ?? '';

    final fixRow = repairJob != null
        ? Act0HomeChecklistRowV1(
            rowKey: 'fix',
            stepNumber: 4,
            label: _shellCopyV1(context, en: 'Fix', ru: 'Исправь'),
            title: _shellCopyV1(
              context,
              en: 'Fix one mistake',
              ru: 'Исправь одну ошибку',
            ),
            detail: repairJob.title,
            icon: Icons.build_circle_outlined,
            accentColor: Act0ShellTokensV1.primary,
            tapKey: 'act0_shell_home_plan_job_${repairJob.jobId}',
            isRepairAction: true,
            onTap: onOpenDailyPlanJob == null
                ? onStartRepair
                : () => onOpenDailyPlanJob!(repairJob.jobId),
          )
        : proveJob != null
        ? Act0HomeChecklistRowV1(
            rowKey: 'fix',
            stepNumber: 4,
            label: _shellCopyV1(context, en: 'Keep sharp', ru: 'Держи острым'),
            title: proveJob.label,
            detail: proveJob.detail.trim().isNotEmpty
                ? proveJob.detail
                : proveJob.title,
            icon: Icons.workspace_premium_outlined,
            accentColor: Act0ShellTokensV1.gold,
            tapKey: 'act0_shell_home_plan_job_${proveJob.jobId}',
            onTap: onOpenDailyPlanJob == null
                ? null
                : () => onOpenDailyPlanJob!(proveJob.jobId),
          )
        : Act0HomeChecklistRowV1(
            rowKey: 'fix',
            stepNumber: 4,
            label: _shellCopyV1(context, en: 'Keep sharp', ru: 'Держи острым'),
            title: _shellCopyV1(
              context,
              en: 'Clean today',
              ru: 'Сегодня чисто',
            ),
            detail: _shellCopyV1(
              context,
              en: 'No leaks due. Keep the skill warm.',
              ru: 'Явных сбоев нет. Просто держи навык тёплым.',
            ),
            icon: Icons.check_rounded,
            accentColor: Act0ShellTokensV1.primary,
          );
    final reviewRow = recheckJob != null
        ? Act0HomeChecklistRowV1(
            rowKey: 'review',
            stepNumber: 3,
            label: _shellCopyV1(context, en: 'Review', ru: 'Повтор'),
            title: _shellCopyV1(
              context,
              en: 'Check confidence',
              ru: 'Проверь уверенность',
            ),
            detail: recheckJob.title,
            icon: Icons.refresh_rounded,
            accentColor: Act0ShellTokensV1.info,
            tapKey: 'act0_shell_home_plan_job_${recheckJob.jobId}',
            onTap:
                onOpenReviewContext ??
                (onOpenDailyPlanJob == null
                    ? null
                    : () => onOpenDailyPlanJob!(recheckJob.jobId)),
          )
        : Act0HomeChecklistRowV1(
            rowKey: 'review',
            stepNumber: 3,
            label: _shellCopyV1(context, en: 'Review', ru: 'Повтор'),
            title: _shellCopyV1(
              context,
              en: 'No old spots due',
              ru: 'Старых спотов пока нет',
            ),
            detail: _shellCopyV1(
              context,
              en: 'Nothing to review right now.',
              ru: 'Сейчас нечего повторять.',
            ),
            icon: Icons.check_circle_outline_rounded,
            accentColor: Act0ShellTokensV1.textDim,
          );

    final rows = <Act0HomeChecklistRowV1>[
      Act0HomeChecklistRowV1(
        rowKey: 'learn',
        stepNumber: 1,
        label: _shellCopyV1(context, en: 'Learn', ru: 'Учись'),
        title:
            nextActionTitle ??
            currentLesson?.title ??
            state.currentLesson.title,
        detail: learnDetail,
        icon: Icons.menu_book_rounded,
        accentColor: Act0ShellTokensV1.primary,
        tapKey: 'act0_shell_home_plan_job_continue',
        onTap: continueJob == null ? null : (onOpenLearnContext ?? onContinue),
      ),
      Act0HomeChecklistRowV1(
        rowKey: 'drill',
        stepNumber: 2,
        label: _shellCopyV1(context, en: 'Practice', ru: 'Практика'),
        title: _drillChecklistTitle(localeIsRu, goalValue),
        detail: checklistActive
            ? ''
            : _dailyGoalSupportText(localeIsRu, goalValue),
        icon: Icons.flash_on_rounded,
        accentColor: state.streakDays >= 3
            ? Act0ShellTokensV1.gold
            : Act0ShellTokensV1.info,
        tapKey: onOpenPracticeContext == null && onStartDailyDrill == null
            ? null
            : 'act0_shell_home_daily_practice_now',
        onTap: onOpenPracticeContext ?? onStartDailyDrill,
      ),
      reviewRow,
      fixRow,
    ];
    return rows;
  }

  String _drillChecklistTitle(bool localeIsRu, String goalValue) {
    if (_isDailyGoalDoneValue(goalValue)) {
      return localeIsRu ? 'На сегодня всё' : 'Done for today';
    }
    if (goalValue.startsWith('0/')) {
      return localeIsRu ? '0/3 спота сегодня' : '0/3 daily spots';
    }
    if (goalValue.startsWith('1/')) {
      return localeIsRu ? '1/3 спота сегодня' : '1/3 daily spots';
    }
    if (goalValue.startsWith('2/')) {
      return localeIsRu ? '2/3 спота сегодня' : '2/3 daily spots';
    }
    return goalValue;
  }
}

class _HomeDashboardRowV1 extends StatelessWidget {
  const _HomeDashboardRowV1({required this.state, required this.localeIsRu});

  final Act0ShellStateV1 state;
  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    final progress = state.xpProgress;
    return Row(
      children: [
        // XP Progress Card
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Act0ShellTokensV1.gapMd,
              vertical: 10,
            ),
            decoration: Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface.withOpacity(0.7),
              borderColor: Act0ShellTokensV1.primary.withOpacity(0.2),
              glow: false,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        state.levelLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.primary,
                          fontSize: 8.5,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.xp}/${state.xpTarget} XP',
                      style: Act0ShellTokensV1.muted.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Act0ShellTokensV1.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Act0ShellTokensV1.surface3,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Act0ShellTokensV1.primary,
                              Act0ShellTokensV1.info,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Act0ShellTokensV1.info.withOpacity(0.38),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
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
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        // Streak Card
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Act0ShellTokensV1.gapMd,
              vertical: 10,
            ),
            decoration: Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface.withOpacity(0.7),
              borderColor: Act0ShellTokensV1.gold.withOpacity(0.2),
              glow: false,
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.orange, Act0ShellTokensV1.gold],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.streakDays}',
                        style: Act0ShellTokensV1.cardTitle.copyWith(
                          color: Act0ShellTokensV1.gold,
                          height: 1.0,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        localeIsRu ? 'дн. подряд' : 'day streak',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.label.copyWith(
                          fontSize: 8,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeCompactRouteStripV1 extends StatelessWidget {
  const _HomeCompactRouteStripV1({
    required this.contextTitle,
    required this.onTap,
  });

  final String contextTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('act0_shell_home_compact_route_strip'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Act0ShellTokensV1.gapMd,
            vertical: Act0ShellTokensV1.gapSm,
          ),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.primary.withOpacity(0.04),
            borderColor: Act0ShellTokensV1.primary.withOpacity(0.18),
            glow: true,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusSm,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 16,
                  color: Act0ShellTokensV1.primary,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  _shellCopyV1(
                    context,
                    en: 'Path open: $contextTitle',
                    ru: 'Путь открыт: $contextTitle',
                  ),
                  key: const Key('act0_shell_home_compact_route_title'),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Act0ShellTokensV1.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: Act0ShellTokensV1.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeChecklistSurfaceV1 extends StatelessWidget {
  const _HomeChecklistSurfaceV1({
    required this.rows,
    required this.localeIsRu,
    required this.title,
  });

  final List<Act0HomeChecklistRowV1> rows;
  final bool localeIsRu;
  final String title;

  @override
  Widget build(BuildContext context) {
    int activeFocusIndex = -1;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].onTap != null) {
        activeFocusIndex = i;
        break;
      }
    }

    return Container(
      key: const Key('act0_shell_home_daily_plan_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface.withOpacity(0.82),
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.18),
        glow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: const Key('act0_shell_home_daily_plan_title'),
            style: Act0ShellTokensV1.sectionTitle,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            localeIsRu
                ? 'Несколько точных шагов на сегодня.'
                : 'A few useful steps for today.',
            key: const Key('act0_shell_home_daily_plan_support'),
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.textMuted,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          for (var i = 0; i < rows.length; i++) ...[
            _HomeChecklistRowTileV1(
              row: rows[i],
              isFirst: i == 0,
              isLast: i == rows.length - 1,
              isCompleted: activeFocusIndex != -1 && i < activeFocusIndex,
              isActiveFocus: i == activeFocusIndex,
              isPending: activeFocusIndex != -1 && i > activeFocusIndex,
            ),
            if (i + 1 < rows.length) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _HomeChecklistRowTileV1 extends StatelessWidget {
  const _HomeChecklistRowTileV1({
    required this.row,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.isActiveFocus,
    required this.isPending,
  });

  final Act0HomeChecklistRowV1 row;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isActiveFocus;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final opacity = isPending ? 0.55 : 1.0;

    Widget circleWidget;
    if (isCompleted) {
      circleWidget = Container(
        key: Key('act0_shell_home_checklist_step_${row.rowKey}'),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: row.accentColor.withOpacity(0.12),
          border: Border.all(
            color: row.accentColor.withOpacity(0.5),
            width: 1.5,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(Icons.check_rounded, color: row.accentColor, size: 18),
        ),
      );
    } else if (isActiveFocus) {
      circleWidget = Container(
        key: Key('act0_shell_home_checklist_step_${row.rowKey}'),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [row.accentColor, row.accentColor.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: row.accentColor.withOpacity(0.38),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${row.stepNumber}',
            key: Key('act0_shell_home_checklist_step_label_${row.rowKey}'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    } else {
      circleWidget = Container(
        key: Key('act0_shell_home_checklist_step_${row.rowKey}'),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.surface3.withOpacity(0.5),
          border: Border.all(
            color: Act0ShellTokensV1.border.withOpacity(0.5),
            width: 1.5,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${row.stepNumber}',
            key: Key('act0_shell_home_checklist_step_label_${row.rowKey}'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textDim.withOpacity(0.6),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final activeLineColor = row.accentColor.withOpacity(0.7);
    final mutedLineColor = Act0ShellTokensV1.border.withOpacity(0.3);

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 38,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isFirst)
                    Positioned(
                      top: 0,
                      height: 25,
                      child: Container(
                        width: 2,
                        color: isCompleted || isActiveFocus
                            ? activeLineColor
                            : mutedLineColor,
                      ),
                    ),
                  if (!isLast)
                    Positioned(
                      top: 25,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: isCompleted ? activeLineColor : mutedLineColor,
                      ),
                    ),
                  Positioned(top: 8, child: circleWidget),
                ],
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapMd),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: isActiveFocus
                    ? BoxDecoration(
                        color: row.accentColor.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusMd,
                        ),
                        border: Border.all(
                          color: row.accentColor.withOpacity(0.16),
                          width: 1,
                        ),
                      )
                    : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: opacity,
                        child: Column(
                          key: row.isRepairAction
                              ? const Key('act0_shell_home_repair_panel')
                              : null,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  row.label,
                                  key: Key(
                                    'act0_shell_home_checklist_label_${row.rowKey}',
                                  ),
                                  style: Act0ShellTokensV1.label.copyWith(
                                    color: row.accentColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (isActiveFocus)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: row.accentColor.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: row.accentColor.withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      _shellCopyV1(
                                        context,
                                        en: 'NEXT',
                                        ru: 'ШАГ',
                                      ),
                                      style: Act0ShellTokensV1.label.copyWith(
                                        color: row.accentColor,
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              row.title,
                              key: Key(
                                'act0_shell_home_checklist_title_${row.rowKey}',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: Act0ShellTokensV1.body.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: isActiveFocus
                                    ? Colors.white
                                    : Act0ShellTokensV1.text,
                              ),
                            ),
                            if (row.detail.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                row.detail,
                                key: Key(
                                  'act0_shell_home_checklist_detail_${row.rowKey}',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: Act0ShellTokensV1.muted.copyWith(
                                  color: Act0ShellTokensV1.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Opacity(
                      opacity: opacity,
                      child: Icon(
                        row.onTap == null
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                        color: row.onTap == null
                            ? Act0ShellTokensV1.textDim
                            : row.accentColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        key: row.tapKey == null ? null : Key(row.tapKey!),
        onTap: row.onTap,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: content,
      ),
    );

    return KeyedSubtree(
      key: Key('act0_shell_home_checklist_row_${row.rowKey}'),
      child: tile,
    );
  }
}

class _HomeSharkyQuoteCardV1 extends StatelessWidget {
  const _HomeSharkyQuoteCardV1({required this.localeIsRu});
  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface3.withOpacity(0.4),
        borderColor: Act0ShellTokensV1.textDim.withOpacity(0.1),
        glow: false,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology_outlined,
            color: Act0ShellTokensV1.textDim,
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Text(
              localeIsRu
                  ? 'Маленькие шаги ведут к большим прыжкам.'
                  : 'Small steps lead to big jumps.',
              style: Act0ShellTokensV1.muted.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeWeeklyFocusStripV1 extends StatelessWidget {
  const _HomeWeeklyFocusStripV1({
    required this.localeIsRu,
    required this.focus,
  });

  final bool localeIsRu;
  final Act0HomeWeeklyFocusV1 focus;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_home_focus_strip'),
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.primary.withOpacity(0.04),
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.14),
        glow: false,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            focus.label,
            key: const Key('act0_shell_home_weekly_focus_label'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focus.title.trim(),
                  key: const Key('act0_shell_home_weekly_focus_title'),
                  style: Act0ShellTokensV1.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (focus.detail.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    focus.detail.trim(),
                    key: const Key('act0_shell_home_weekly_focus_detail'),
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCompletionSurfaceV1 extends StatelessWidget {
  const _HomeCompletionSurfaceV1({
    required this.localeIsRu,
    required this.earnedStreak,
    required this.streakDays,
  });

  final bool localeIsRu;
  final bool earnedStreak;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_home_daily_plan_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.82),
        borderColor: Act0ShellTokensV1.gold.withValues(alpha: 0.18),
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusLg,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Act0ShellTokensV1.gold,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localeIsRu ? 'Сегодня закрыто' : 'Today complete',
                      style: Act0ShellTokensV1.cardTitle.copyWith(height: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earnedStreak
                          ? (localeIsRu ? '+1 к серии' : '+1 streak')
                          : (localeIsRu ? 'Навык тёплый' : 'Skill kept warm'),
                      key: const Key('act0_shell_home_daily_done_badge'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            localeIsRu
                ? 'Ритм засчитан. Если хочешь, можно идти дальше спокойно.'
                : 'The minimum is banked. Continue if you want.',
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.textMuted,
            ),
          ),
          if (streakDays > 0) ...[
            const SizedBox(height: 6),
            Text(
              localeIsRu
                  ? '$streakDays дн. уже собраны.'
                  : '$streakDays day streak is holding.',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.textDim,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            localeIsRu ? 'Продолжай, если хочешь' : 'Continue if you want',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isDailyGoalDoneValue(String goalValue) {
  return goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Done') ||
      goalValue.contains('3/3') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён') ||
      goalValue.startsWith('На сегодня всё');
}

String _dailyGoalSupportText(bool localeIsRu, String goalValue) {
  if (goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён')) {
    return localeIsRu
        ? 'Фикс засчитан. Ты честно удержал ритм на завтра.'
        : 'Repair banked. You earned tomorrow\'s rhythm.';
  }
  if (_isDailyGoalDoneValue(goalValue)) {
    return localeIsRu
        ? 'Цель на сегодня закрыта. Завтрашнее возвращение уже стало легче.'
        : 'Goal complete. Tomorrow\'s return already feels lighter.';
  }
  if (goalValue.startsWith('0/')) {
    return localeIsRu
        ? 'Один чистый спот запускает день.'
        : 'One clean spot starts the day.';
  }
  return localeIsRu
      ? 'Ещё один чистый реп держит темп.'
      : 'One more clean rep keeps the pace.';
}

String _dailyGoalTrustLineV1({
  required bool localeIsRu,
  required String goalValue,
  required int streakDays,
}) {
  if (goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён')) {
    return localeIsRu
        ? (streakDays > 0
              ? '$streakDays дн. сохранены'
              : 'Импульс на завтра сохранён.')
        : (streakDays > 0
              ? '$streakDays day rhythm held'
              : 'Momentum protected for tomorrow.');
  }
  if (_isDailyGoalDoneValue(goalValue)) {
    return localeIsRu
        ? (streakDays > 0
              ? '$streakDays дн. в порядке'
              : 'Сегодняшний день засчитан. Завтра будет легче.')
        : (streakDays > 0
              ? '$streakDays day streak safe'
              : 'Today is banked. Tomorrow starts lighter.');
  }
  if (streakDays >= 7) {
    return localeIsRu ? '$streakDays дн.' : '$streakDays day streak';
  }
  if (streakDays >= 3) {
    return localeIsRu ? '$streakDays дня' : '$streakDays day streak';
  }
  return localeIsRu ? 'Стартуй ритм' : 'Start the rhythm';
}

class _DailyGoalCardV1 extends StatelessWidget {
  const _DailyGoalCardV1({
    required this.localeIsRu,
    required this.state,
    required this.dailyGoalValue,
    required this.dailyGoalCtaLabel,
    this.onStartDailyDrill,
  });

  final bool localeIsRu;
  final Act0ShellStateV1 state;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final VoidCallback? onStartDailyDrill;

  @override
  Widget build(BuildContext context) {
    final goalValue = dailyGoalValue ?? state.dailyGoalValue;
    final isDone = _isDailyGoalDoneValue(goalValue);
    final accentColor = isDone
        ? Act0ShellTokensV1.primary
        : (state.streakDays >= 3
              ? Act0ShellTokensV1.gold
              : Act0ShellTokensV1.info);
    final trustLine = _dailyGoalTrustLineV1(
      localeIsRu: localeIsRu,
      goalValue: goalValue,
      streakDays: state.streakDays,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('act0_shell_home_daily_goal_card'),
        onTap: isDone ? null : onStartDailyDrill,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface.withValues(alpha: 0.76),
            borderColor: accentColor.withValues(alpha: 0.18),
            glow: false,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusLg,
                      ),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.flash_on_rounded,
                      color: accentColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localeIsRu ? 'Опциональный реп' : 'Optional rep',
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.textDim,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goalValue,
                          style: Act0ShellTokensV1.cardTitle.copyWith(
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDone)
                    Text(
                      localeIsRu ? 'Готово' : 'Done',
                      key: const Key('act0_shell_home_daily_done_badge'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.primary,
                        letterSpacing: 0.1,
                      ),
                    )
                  else if (trustLine.isNotEmpty)
                    Text(
                      trustLine,
                      key: const Key('act0_shell_home_daily_trust_line'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: accentColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                ],
              ),
              () {
                int completed = 0;
                int total = 3;
                final regExp = RegExp(r'(\d+)/(\d+)');
                final match = regExp.firstMatch(goalValue);
                bool hasPills = false;
                if (match != null) {
                  completed = int.tryParse(match.group(1) ?? '0') ?? 0;
                  total = int.tryParse(match.group(2) ?? '3') ?? 3;
                  hasPills = true;
                } else if (isDone) {
                  completed = 3;
                  total = 3;
                  hasPills = true;
                }
                if (!hasPills || total <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Row(
                    children: List.generate(total, (index) {
                      final isFilled = index < completed;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(
                            right: index == total - 1 ? 0 : 5,
                          ),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? accentColor
                                : Act0ShellTokensV1.surface3,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isFilled
                                ? [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.38),
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                    ),
                                  ]
                                : null,
                            border: isFilled
                                ? null
                                : Border.all(
                                    color: Act0ShellTokensV1.border.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }(),
              const SizedBox(height: 8),
              Text(
                _dailyGoalSupportText(localeIsRu, goalValue),
                key: const Key('act0_shell_home_daily_support_line'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: 12.5,
                  color: Act0ShellTokensV1.textMuted,
                ),
              ),
              if (!isDone && onStartDailyDrill != null) ...[
                const SizedBox(height: 10),
                FilledButton.tonal(
                  key: const Key('act0_shell_home_daily_practice_now'),
                  onPressed: onStartDailyDrill,
                  style: Act0ShellTokensV1.tonalButtonStyle(
                    tone: accentColor,
                    fullWidth: true,
                  ),
                  child: Text(dailyGoalCtaLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFooterSharkyLineV1 extends StatelessWidget {
  const _HomeFooterSharkyLineV1({
    required this.state,
    required this.sharky,
    required this.localeIsRu,
  });

  final Act0ShellStateV1 state;
  final Act0SharkyCueV1 sharky;
  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    final line = _footerLine();
    final tone = act0SharkyToneForMoodV1(sharky.preSessionMood);
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withOpacity(0.12),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Act0ShellTokensV1.surface2.withOpacity(0.6),
            Act0ShellTokensV1.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('act0_shell_home_footer_sharky_presence'),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tone.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Act0SharkyPresenceMascotV1(
                key: const Key('act0_shell_home_footer_sharky_mascot'),
                mood: sharky.preSessionMood,
                tone: tone,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _shellCopyV1(context, en: 'SHARKY CUE', ru: 'СОВЕТ Sharky'),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    fontSize: 8.5,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line,
                  key: const Key('act0_shell_home_footer_sharky_line'),
                  style: Act0ShellTokensV1.body.copyWith(
                    fontSize: 12.5,
                    height: 1.35,
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _footerLine() {
    switch (sharky.preSessionMood) {
      case Act0SharkyMoodV1.repair:
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Сначала почини это место. Потом маршрут снова станет лёгким.',
                  'Один чистый фикс сначала. Потом можно спокойно идти дальше.',
                  'Почини этот узел первым. Остальное сразу станет проще.',
                ]
              : <String>[
                  'Fix this spot first. Then the next step feels clear again.',
                  'One clean repair first. Then continue with a clear head.',
                  'Repair this pressure point first. The rest gets easier right away.',
                ],
        );
      case Act0SharkyMoodV1.celebrate:
        if (state.streakDays > 0) {
          return _pickPaletteLineV1(
            localeIsRu
                ? <String>[
                    'Место на завтра удержано. Один короткий чистый реп его продлит.',
                    'Ритм уже собран. Один короткий реп удержит ход.',
                    'Темп держится. Один чистый проход и завтра остаётся тёплым.',
                  ]
                : <String>[
                    'Seat held for tomorrow. One short clean rep extends it.',
                    'Rhythm is locked in. One short rep keeps it alive.',
                    'Pace is holding. One clean pass keeps tomorrow warm.',
                  ],
          );
        }
        return sharky.summaryLine;
      case Act0SharkyMoodV1.happy:
        if (state.streakDays >= 7) {
          return _pickPaletteLineV1(
            localeIsRu
                ? <String>[
                    'Серия уже настоящая. Один спокойный чистый реп держит её честной.',
                    'Серия собрана. Один аккуратный реп не даёт ей распасться.',
                    'Это уже не случайность. Один чистый проход закрепит ритм.',
                  ]
                : <String>[
                    'The streak is real now. One calm clean rep keeps it honest.',
                    'This streak is earned. One tidy rep keeps it stable.',
                    'This is not random anymore. One clean pass secures the rhythm.',
                  ],
          );
        }
        if (state.streakDays >= 3) {
          return _pickPaletteLineV1(
            localeIsRu
                ? <String>[
                    '${state.streakDays} дня в ритме. Один чистый реп удерживает место тёплым.',
                    '${state.streakDays} дня подряд. Один короткий чистый реп и темп сохранён.',
                    'Уже ${state.streakDays} дня в движении. Один точный реп держит курс.',
                  ]
                : <String>[
                    '${state.streakDays} days running. One clean rep keeps the rhythm warm.',
                    '${state.streakDays} days in a row. One short clean rep keeps the pace.',
                    '${state.streakDays} days in motion already. One precise rep keeps the rhythm steady.',
                  ],
          );
        }
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Ты уже входишь в ритм. Один чистый реп задаст тон.',
                  'Ритм уже появляется. Один точный проход его закрепит.',
                  'Ты разогреваешься. Один спокойный реп задаёт правильный вектор.',
                ]
              : <String>[
                  'You are settling in. One clean rep sets the tone.',
                  'Rhythm is starting to form. One precise pass locks it in.',
                  'You are warming up. One calm rep sets the right direction.',
                ],
        );
      case Act0SharkyMoodV1.thinking:
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Один спокойный чистый реп сейчас лучше десяти спешных потом.',
                  'Сначала спокойное чтение, потом действие. Так меньше лишних ошибок.',
                  'Не форсируй темп. Один чистый проход даёт больше, чем серия спешных.',
                ]
              : <String>[
                  'One calm clean rep now beats ten rushed ones later.',
                  'Read calmly first, then act. That removes avoidable mistakes.',
                  'Do not force pace. One clean pass beats a rushed streak.',
                ],
        );
      case Act0SharkyMoodV1.neutral:
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Не спеши. Чистые чтения собирают настоящее преимущество.',
                  'Держи темп ровным. Сначала качество чтения, потом скорость.',
                  'Спокойный ритм даёт лучший результат, чем спешка.',
                ]
              : <String>[
                  'Stay patient. Clean reads build real edge.',
                  'Keep the pace steady. Reading quality comes before speed.',
                  'A calm rhythm outperforms rushed decisions.',
                ],
        );
    }
  }

  String _pickPaletteLineV1(List<String> variants) {
    final cleaned = variants
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) {
      return localeIsRu
          ? 'Один чистый реп и дальше по пути.'
          : 'One clean rep, then continue the path.';
    }
    final seed = state.streakDays.abs();
    var index = seed % cleaned.length;
    final previous = sharky.preSessionLine.trim().toLowerCase();
    if (cleaned.length > 1 && cleaned[index].toLowerCase() == previous) {
      index = (index + 1) % cleaned.length;
    }
    return cleaned[index];
  }
}
