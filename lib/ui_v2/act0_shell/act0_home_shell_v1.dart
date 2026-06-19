import 'package:flutter/material.dart';
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
    this.nextUsefulHandReasonLine,
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
  final String? nextUsefulHandReasonLine;
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
    final nextActionCtaLabel = this.nextActionCtaLabel == 'Continue'
        ? act0LocalizedSurfaceAtomV1(
            context,
            'home_checklist_continue_label',
            fallback: 'Continue',
          )
        : this.nextActionCtaLabel;
    final goalValue = dailyGoalValue ?? state.dailyGoalValue;
    final checklistActive =
        showChecklist ??
        dailyPlanJobs.isNotEmpty ||
            showRepairPanel ||
            (weeklyFocus != null && weeklyFocus!.title.trim().isNotEmpty) ||
            _isDailyGoalDoneValue(goalValue);
    final missionCard = _HomeMissionCommandCardV1(
      courseTitle: courseTitle,
      title: title,
      subtitle: subtitle,
      progressLabel: pathProgressLabel,
      nextActionCtaLabel: nextActionCtaLabel,
      nextActionHint: nextActionHint,
      onContinue: onContinue,
      localeIsRu: _isRuLocaleV1(context),
    );
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
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeIdentityRowV1(
                state: state,
                sharky: sharky,
                courseTitle: courseTitle,
                localeIsRu: _isRuLocaleV1(context),
                onOpenDevMenu: onOpenDevMenu,
              ),
              const SizedBox(height: Act0VisualMetricsV1.sectionGap),
              missionCard,
              const SizedBox(height: Act0VisualMetricsV1.sectionGap),
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
                            act0LocalizedSurfaceAtomV1(
                              context,
                              'home_checklist_title',
                              fallback: 'Short table practice',
                            ),
                        nextUsefulHandReasonLine: nextUsefulHandReasonLine,
                      ))
              else
                const SizedBox.shrink(),
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
            label: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_fix_label',
              fallback: 'Repair',
            ),
            title: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_fix_mistake_title',
              fallback: 'Repair this signal',
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
            label: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_keep_sharp_label',
              fallback: 'Keep sharp',
            ),
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
            label: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_keep_sharp_label',
              fallback: 'Keep sharp',
            ),
            title: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_clean_today_title',
              fallback: 'Clean today',
            ),
            detail: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_clean_today_detail',
              fallback: 'No leaks due. Keep the skill warm.',
            ),
            icon: Icons.check_rounded,
            accentColor: Act0VisualCanonV1.greenTable,
          );
    final reviewRow = recheckJob != null
        ? Act0HomeChecklistRowV1(
            rowKey: 'review',
            stepNumber: 3,
            label: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_review_label',
              fallback: 'Review',
            ),
            title: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_check_confidence_title',
              fallback: 'Check confidence',
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
            label: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_review_label',
              fallback: 'Review',
            ),
            title: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_no_old_spots_title',
              fallback: 'No old spots due',
            ),
            detail: act0LocalizedSurfaceAtomV1(
              context,
              'home_checklist_no_old_spots_detail',
              fallback: 'Nothing to review right now.',
            ),
            icon: Icons.check_circle_outline_rounded,
            accentColor: Act0VisualCanonV1.greenTable,
          );

    final rows = <Act0HomeChecklistRowV1>[
      Act0HomeChecklistRowV1(
        rowKey: 'learn',
        stepNumber: 1,
        label: act0LocalizedSurfaceAtomV1(
          context,
          'home_checklist_learn_label',
          fallback: 'Learn',
        ),
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
        label: act0LocalizedSurfaceAtomV1(
          context,
          'home_checklist_practice_label',
          fallback: 'Practice',
        ),
        title: _drillChecklistTitle(context, goalValue),
        detail: checklistActive
            ? ''
            : _dailyGoalSupportText(context, goalValue),
        icon: Icons.flash_on_rounded,
        accentColor: Act0ShellTokensV1.actionCyan,
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

  String _drillChecklistTitle(BuildContext context, String goalValue) {
    if (_isDailyGoalDoneValue(goalValue)) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'home_daily_goal_done_title',
        fallback: 'Done for today',
      );
    }
    if (goalValue.startsWith('0/')) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'home_drill_checklist_title_0_of_3',
        fallback: '0/3 daily spots',
      );
    }
    if (goalValue.startsWith('1/')) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'home_drill_checklist_title_1_of_3',
        fallback: '1/3 daily spots',
      );
    }
    if (goalValue.startsWith('2/')) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'home_drill_checklist_title_2_of_3',
        fallback: '2/3 daily spots',
      );
    }
    return goalValue;
  }
}

class _HomeIdentityRowV1 extends StatelessWidget {
  const _HomeIdentityRowV1({
    required this.state,
    required this.sharky,
    required this.courseTitle,
    required this.localeIsRu,
    this.onOpenDevMenu,
  });

  final Act0ShellStateV1 state;
  final Act0SharkyCueV1 sharky;
  final String courseTitle;
  final bool localeIsRu;
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    final tone = act0SharkyToneForMoodV1(sharky.preSessionMood);
    return Row(
      key: const Key('act0_shell_home_identity_row'),
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: tone.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: tone.withOpacity(0.18)),
          ),
          child: Act0SharkyPresenceMascotV1(
            mood: sharky.preSessionMood,
            tone: tone,
            size: 26,
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeIsRu ? 'Sharky' : 'Sharky',
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                courseTitle,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.textDim,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        if (onOpenDevMenu != null) ...[
          const SizedBox(width: 2),
          IconButton(
            key: const Key('act0_shell_home_dev_menu_button'),
            onPressed: onOpenDevMenu,
            icon: const Icon(Icons.more_horiz_rounded),
            color: Act0ShellTokensV1.textMuted,
            splashRadius: 18,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            tooltip: localeIsRu ? 'Меню разработчика' : 'Dev menu',
          ),
        ],
      ],
    );
  }
}

class _HomeMissionCommandCardV1 extends StatelessWidget {
  const _HomeMissionCommandCardV1({
    required this.courseTitle,
    required this.title,
    required this.subtitle,
    required this.nextActionCtaLabel,
    required this.onContinue,
    required this.localeIsRu,
    this.progressLabel,
    this.nextActionHint,
  });

  final String courseTitle;
  final String title;
  final String subtitle;
  final String nextActionCtaLabel;
  final VoidCallback onContinue;
  final bool localeIsRu;
  final String? progressLabel;
  final String? nextActionHint;

  @override
  Widget build(BuildContext context) {
    final cleanProgress = progressLabel?.trim();
    return KeyedSubtree(
      key: const Key('act0_shell_home_v6_route_hero'),
      child: Container(
        key: const Key('act0_shell_home_mission_command_card'),
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
        decoration: Act0ShellTokensV1.premiumActionSurfaceDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Act0ShellTokensV1.actionCyan,
                        Act0ShellTokensV1.actionBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusMd,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Act0ShellTokensV1.actionBlue.withOpacity(0.34),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: Act0ShellTokensV1.onPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Text(
                    localeIsRu ? 'Чтение стола сегодня' : 'Today\'s table read',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.actionCyan,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Text(
              title,
              key: const Key('act0_shell_home_primary_route_title'),
              style: Act0ShellTokensV1.sectionTitle.copyWith(
                fontSize: 23,
                height: 1.04,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              nextActionHint?.trim().isNotEmpty == true
                  ? nextActionHint!.trim()
                  : subtitle,
              key: const Key('act0_shell_home_next_action_subtitle'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.textMuted,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localeIsRu
                  ? 'Sharky держит одно чистое чтение готовым.'
                  : 'Sharky has one clean read ready.',
              key: const Key('act0_shell_home_mission_sharky_line'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0VisualCanonV1.textSecondary.withOpacity(0.80),
                fontSize: 12,
                height: 1.22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HomeMetaPillV1(
                  icon: Icons.school_rounded,
                  label: courseTitle,
                  color: Act0ShellTokensV1.actionCyan,
                ),
                if (cleanProgress != null && cleanProgress.isNotEmpty)
                  _HomeMetaPillV1(
                    icon: Icons.flag_rounded,
                    label: cleanProgress,
                    color: Act0ShellTokensV1.textMuted,
                  ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Container(
              key: const Key('act0_shell_home_v6_primary_cta'),
              child: FilledButton(
                key: const Key('act0_shell_main_cta'),
                onPressed: onContinue,
                style: Act0ShellTokensV1.premiumActionButtonStyle(
                  height: Act0VisualMetricsV1.primaryCtaHeight,
                ),
                child: Text(nextActionCtaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMetaPillV1 extends StatelessWidget {
  const _HomeMetaPillV1({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeChecklistSurfaceV1 extends StatelessWidget {
  const _HomeChecklistSurfaceV1({
    required this.rows,
    required this.localeIsRu,
    required this.title,
    this.nextUsefulHandReasonLine,
  });

  final List<Act0HomeChecklistRowV1> rows;
  final bool localeIsRu;
  final String title;
  final String? nextUsefulHandReasonLine;

  @override
  Widget build(BuildContext context) {
    int activeFocusIndex = -1;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].onTap != null) {
        activeFocusIndex = i;
        break;
      }
    }

    return KeyedSubtree(
      key: const Key('act0_shell_home_daily_plan_card'),
      child: Container(
        key: const Key('act0_shell_home_focus_checklist'),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          color: Act0ShellTokensV1.surface.withOpacity(0.72),
          borderColor: Act0ShellTokensV1.actionBlue.withOpacity(0.16),
          glow: false,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    key: const Key('act0_shell_home_daily_plan_title'),
                    style: Act0ShellTokensV1.cardTitle.copyWith(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withOpacity(0.74),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    border: Border.all(color: Act0ShellTokensV1.border),
                  ),
                  child: Text(
                    localeIsRu ? 'Следующая раздача' : 'Next useful hand',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.textDim,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              localeIsRu
                  ? 'Неделя 1: тренируй одно чтение стола'
                  : 'Week 1: train one table read',
              key: const Key('act0_shell_home_week1_title'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              localeIsRu
                  ? 'Сегодня: держи одну подсказку стола в тонусе.'
                  : 'Today: keep one table clue warm',
              key: const Key('act0_shell_home_daily_plan_support'),
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              (nextUsefulHandReasonLine ?? '').trim().isNotEmpty
                  ? nextUsefulHandReasonLine!.trim()
                  : localeIsRu
                  ? 'Sharky уже держит твою следующую полезную раздачу готовой.'
                  : 'Sharky has your next useful hand ready.',
              key: const Key('act0_shell_home_week1_return_line'),
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textDim,
              ),
            ),
            const SizedBox(height: 12),
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
    final rowTone = isCompleted
        ? Act0VisualCanonV1.greenTable
        : isActiveFocus
        ? Act0ShellTokensV1.actionCyan
        : isPending
        ? Act0ShellTokensV1.textDim
        : row.accentColor;
    final rowActionable =
        row.onTap != null && (isActiveFocus || row.isRepairAction);
    final opacity = isPending ? 0.78 : 1.0;
    final content = Container(
      constraints: BoxConstraints(minHeight: isActiveFocus ? 56 : 52),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: isActiveFocus ? 8 : 7,
      ),
      decoration: BoxDecoration(
        color: isActiveFocus
            ? Act0ShellTokensV1.actionBlue.withOpacity(0.075)
            : Act0ShellTokensV1.surface2.withOpacity(0.42),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: isActiveFocus
              ? Act0ShellTokensV1.actionCyan.withOpacity(0.22)
              : Act0ShellTokensV1.border.withOpacity(0.50),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            key: Key('act0_shell_home_checklist_step_${row.rowKey}'),
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rowTone.withOpacity(isActiveFocus ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(color: rowTone.withOpacity(0.28)),
            ),
            child: isCompleted
                ? Icon(Icons.check_rounded, color: rowTone, size: 17)
                : Text(
                    '${row.stepNumber}',
                    key: Key(
                      'act0_shell_home_checklist_step_label_${row.rowKey}',
                    ),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: rowTone,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Opacity(
              opacity: opacity,
              child: Column(
                key: row.isRepairAction
                    ? const Key('act0_shell_home_repair_panel')
                    : null,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        row.label,
                        key: Key(
                          'act0_shell_home_checklist_label_${row.rowKey}',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: rowTone,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      if (isActiveFocus) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Act0ShellTokensV1.actionCyan.withOpacity(
                              0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusPill,
                            ),
                            border: Border.all(
                              color: Act0ShellTokensV1.actionCyan.withOpacity(
                                0.22,
                              ),
                            ),
                          ),
                          child: Text(
                            act0LocalizedSurfaceAtomV1(
                              context,
                              'home_checklist_next_label',
                              fallback: 'Next',
                            ),
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.actionCyan,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.title,
                    key: Key('act0_shell_home_checklist_title_${row.rowKey}'),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: isActiveFocus
                          ? Act0ShellTokensV1.text
                          : Act0ShellTokensV1.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  if (row.detail.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      row.detail,
                      key: Key(
                        'act0_shell_home_checklist_detail_${row.rowKey}',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.textDim,
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
              color: rowActionable ? rowTone : Act0ShellTokensV1.textDim,
              size: 18,
            ),
          ),
        ],
      ),
    );

    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        key: row.tapKey == null ? null : Key(row.tapKey!),
        onTap: rowActionable ? row.onTap : null,
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
                      act0LocalizedSurfaceAtomV1(
                        context,
                        'home_daily_done_title',
                        fallback: 'Session complete',
                      ),
                      style: Act0ShellTokensV1.cardTitle.copyWith(height: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earnedStreak
                          ? act0LocalizedSurfaceAtomV1(
                              context,
                              'home_daily_done_streak_label',
                              fallback: 'Table read improved',
                            )
                          : act0LocalizedSurfaceAtomV1(
                              context,
                              'home_daily_done_warm_label',
                              fallback: 'Table read improved',
                            ),
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
            act0LocalizedSurfaceAtomV1(
              context,
              'home_daily_done_detail',
              fallback:
                  'One table clue warmed. Sharky has tomorrow\'s read ready.',
            ),
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.textMuted,
            ),
          ),
          if (streakDays > 0) ...[
            const SizedBox(height: 6),
            Text(
              _isRuLocaleV1(context)
                  ? 'Серия держится: $streakDays ${act0RussianPluralV1(streakDays, 'день', 'дня', 'дней')}.'
                  : '$streakDays day streak is holding.',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.textDim,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            act0LocalizedSurfaceAtomV1(
              context,
              'home_daily_done_continue_hint',
              fallback: 'Come back tomorrow for the next useful hand',
            ),
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

String _dailyGoalSupportText(BuildContext context, String goalValue) {
  if (goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён')) {
    return act0LocalizedSurfaceAtomV1(
      context,
      'home_daily_goal_streak_saved',
      fallback: 'Repair banked. You earned tomorrow\'s rhythm.',
    );
  }
  if (_isDailyGoalDoneValue(goalValue)) {
    return act0LocalizedSurfaceAtomV1(
      context,
      'home_daily_goal_complete',
      fallback: 'Goal complete. Tomorrow\'s return already feels lighter.',
    );
  }
  if (goalValue.startsWith('0/')) {
    return act0LocalizedSurfaceAtomV1(
      context,
      'home_daily_goal_start_day',
      fallback: 'One clean spot starts the day.',
    );
  }
  return act0LocalizedSurfaceAtomV1(
    context,
    'home_daily_goal_keep_pace',
    fallback: 'One more clean rep keeps the pace.',
  );
}
