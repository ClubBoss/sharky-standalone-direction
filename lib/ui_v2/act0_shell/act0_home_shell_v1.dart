import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

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
    this.handoffLabel = 'Keep going',
    this.handoffHeadline,
    this.handoffDetail,
    this.handoffOutcome,
    this.handoffPills = const <String>[
      'Lesson step',
      'Live spot',
      'Repair loop',
    ],
    this.showHandoffPanel = true,
    this.onDismissHandoff,
    this.dailyGoalValue,
    this.dailyGoalCtaLabel = 'Practice now →',
    this.sharkyOverride,
    this.onOpenDevMenu,
    this.onStartDailyDrill,
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
  final String handoffLabel;
  final String? handoffHeadline;
  final String? handoffDetail;
  final String? handoffOutcome;
  final List<String> handoffPills;
  final bool showHandoffPanel;
  final VoidCallback? onDismissHandoff;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final Act0SharkyCueV1? sharkyOverride;
  final VoidCallback? onOpenDevMenu;
  final VoidCallback? onStartDailyDrill;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final lesson = currentLesson ?? state.currentLesson;
    final title = nextActionTitle ?? lesson.title;
    final subtitle = nextActionSubtitle ?? lesson.subtitle;
    final sharky = sharkyOverride ?? lesson.runner.sharky;
    final earnedAchievements = state.profile.achievements
        .where((achievement) => !achievement.locked)
        .take(2)
        .toList(growable: false);
    return ListView(
      key: const Key('act0_shell_home_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                state.courseTitle,
                style: Act0ShellTokensV1.screenTitle,
              ),
            ),
            if (onOpenDevMenu != null)
              IconButton(
                key: const Key('act0_shell_home_dev_menu_button'),
                onPressed: onOpenDevMenu,
                icon: const Icon(Icons.more_horiz_rounded),
                color: Act0ShellTokensV1.muted.color,
                splashRadius: 18,
                tooltip: 'Dev menu',
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -3,
                ),
              ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(state.courseSubtitle, style: Act0ShellTokensV1.muted),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _DailyGoalCardV1(
          state: state,
          dailyGoalValue: dailyGoalValue,
          dailyGoalCtaLabel: dailyGoalCtaLabel,
          onStartDailyDrill: onStartDailyDrill,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _HomeStreakStripV1(
          streakDays: state.streakDays,
          streakLast7: state.profile.streakLast7,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _SharkyHomeCardV1(
          sharky: sharky,
          streakDays: state.streakDays,
          earnedAchievements: earnedAchievements,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapXl),
          decoration: Act0ShellTokensV1.heroDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('act0_shell_home_primary_tap_target'),
                  onTap: onContinue,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusXl,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
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
                                    nextActionLabel,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: Act0ShellTokensV1.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Act0ShellTokensV1.gapXs,
                                  ),
                                  Text(
                                    title,
                                    style: Act0ShellTokensV1.sectionTitle,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Act0ShellTokensV1.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        Text(
                          subtitle,
                          style: Act0ShellTokensV1.muted,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        if (showHandoffPanel)
                          Container(
                            key: const Key('act0_shell_home_handoff_panel'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Act0ShellTokensV1.gapMd,
                              vertical: Act0ShellTokensV1.gapSm,
                            ),
                            decoration: BoxDecoration(
                              color: Act0ShellTokensV1.surface2.withValues(
                                alpha: 0.78,
                              ),
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusXl,
                              ),
                              border: Border.all(
                                color: Act0ShellTokensV1.primary.withValues(
                                  alpha: 0.22,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        handoffLabel,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          color: Act0ShellTokensV1.primary,
                                        ),
                                      ),
                                    ),
                                    if (onDismissHandoff != null)
                                      IconButton(
                                        key: const Key(
                                          'act0_shell_home_handoff_dismiss',
                                        ),
                                        onPressed: onDismissHandoff,
                                        icon: const Icon(Icons.close_rounded),
                                        color: Act0ShellTokensV1.muted.color,
                                        splashRadius: 16,
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        tooltip: 'Dismiss',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: Act0ShellTokensV1.gapSm),
                                Text(
                                  handoffHeadline ??
                                      'Short session. Progress saves automatically.',
                                  style: Act0ShellTokensV1.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (handoffDetail != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    handoffDetail!,
                                    style: Act0ShellTokensV1.muted,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (handoffOutcome != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Outcome: $handoffOutcome',
                                    key: const Key(
                                      'act0_shell_home_handoff_outcome',
                                    ),
                                    style: Act0ShellTokensV1.muted.copyWith(
                                      color: Act0ShellTokensV1.gold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (handoffPills.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: Act0ShellTokensV1.gapSm,
                                    runSpacing: 6,
                                    children: [
                                      for (final pill in handoffPills)
                                        _TodayFlowPillV1(label: pill),
                                    ],
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
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              FilledButton(
                key: const Key('act0_shell_main_cta'),
                onPressed: onContinue,
                style: Act0ShellTokensV1.primaryButtonStyle(),
                child: Text(nextActionCtaLabel),
              ),
              if (nextActionHint != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  nextActionHint!,
                  key: const Key('act0_shell_home_cta_hint'),
                  style: Act0ShellTokensV1.muted,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.surfaceDecoration(),
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
                          state.levelLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Course progress',
                          style: Act0ShellTokensV1.cardTitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Text(
                    '${state.xp}/${state.xpTarget} XP',
                    textAlign: TextAlign.right,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.gold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                child: LinearProgressIndicator(
                  minHeight: Act0ShellTokensV1.progressHeight + 2,
                  value: state.xpProgress,
                  backgroundColor: Act0ShellTokensV1.surface3,
                  color: Act0ShellTokensV1.gold,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(_xpToNextLevelLabel(state), style: Act0ShellTokensV1.muted),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Row(
                children: [
                  Expanded(
                    child: _TinyStatV1(
                      label: 'Streak',
                      value: _streakStatLabel(state.streakDays),
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: _TinyStatV1(
                      label: 'Lessons',
                      value: pathProgressLabel ?? state.pathProgressLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _streakStatLabel(int days) {
  if (days == 0) return '—';
  if (days == 1) return '1 day';
  return '$days days';
}

String _xpToNextLevelLabel(Act0ShellStateV1 state) {
  final remaining = (state.xpTarget - state.xp).clamp(0, 999999);
  if (remaining == 0) {
    return 'Level target reached';
  }
  return '$remaining XP to next level';
}

String _dailyGoalSupportText(String goalValue) {
  if (goalValue.startsWith('Streak saved')) {
    return 'Recovery earned. Momentum is protected today.';
  }
  if (goalValue.startsWith('Done') || goalValue.contains('3/3')) {
    return 'Goal complete. Return tomorrow to keep the streak alive.';
  }
  if (goalValue.startsWith('0/')) {
    return 'Start one spot to keep the pace.';
  }
  return 'Good start. Keep the path moving.';
}

class _DailyGoalCardV1 extends StatelessWidget {
  const _DailyGoalCardV1({
    required this.state,
    required this.dailyGoalValue,
    required this.dailyGoalCtaLabel,
    this.onStartDailyDrill,
  });

  final Act0ShellStateV1 state;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final VoidCallback? onStartDailyDrill;

  @override
  Widget build(BuildContext context) {
    final goalValue = dailyGoalValue ?? state.dailyGoalValue;
    final isDone = goalValue.startsWith('Done') || goalValue.contains('3/3');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('act0_shell_home_daily_goal_card'),
        onTap: isDone ? null : onStartDailyDrill,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.surfaceDecoration(),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: state.xpProgress,
                      strokeWidth: 4,
                      backgroundColor: Act0ShellTokensV1.surface3,
                      color: Act0ShellTokensV1.primary,
                    ),
                    Center(
                      child: Text(
                        '${(state.xpProgress * 100).round()}%',
                        style: Act0ShellTokensV1.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.dailyGoalLabel, style: Act0ShellTokensV1.label),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(goalValue, style: Act0ShellTokensV1.cardTitle),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(
                      _dailyGoalSupportText(goalValue),
                      style: Act0ShellTokensV1.muted,
                    ),
                    if (isDone) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Container(
                        key: const Key('act0_shell_home_daily_done_badge'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.primary.withValues(
                              alpha: 0.26,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Act0ShellTokensV1.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Done today',
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!isDone && onStartDailyDrill != null) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Text(
                        dailyGoalCtaLabel,
                        key: const Key('act0_shell_home_daily_practice_now'),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                state.levelLabel,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyStatV1 extends StatelessWidget {
  const _TinyStatV1({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(value, style: Act0ShellTokensV1.body),
        ],
      ),
    );
  }
}

class _HomeStreakStripV1 extends StatelessWidget {
  const _HomeStreakStripV1({
    required this.streakDays,
    required this.streakLast7,
  });

  final int streakDays;
  final List<bool> streakLast7;

  @override
  Widget build(BuildContext context) {
    final days = _normalize7DayStreak(streakDays, streakLast7);
    return Container(
      key: const Key('act0_shell_home_streak_strip'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: Act0ShellTokensV1.primary.withValues(alpha: 0.22),
        color: Act0ShellTokensV1.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Return rhythm',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.primary,
                ),
              ),
              const Spacer(),
              Text(
                _streakStatLabel(streakDays),
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Row(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                Expanded(
                  child: Container(
                    key: Key('act0_shell_home_streak_day_$i'),
                    height: 8,
                    decoration: BoxDecoration(
                      color: days[i]
                          ? Act0ShellTokensV1.primary
                          : Act0ShellTokensV1.surface3,
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                  ),
                ),
                if (i < days.length - 1)
                  const SizedBox(width: Act0ShellTokensV1.gapXs),
              ],
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            'No pressure: one clean rep keeps rhythm.',
            key: const Key('act0_shell_home_streak_trust_line'),
            style: Act0ShellTokensV1.muted,
          ),
        ],
      ),
    );
  }

  List<bool> _normalize7DayStreak(int streakDays, List<bool> streakLast7) {
    if (streakLast7.length == 7) {
      return streakLast7;
    }
    final normalized = List<bool>.filled(7, false);
    final activeDays = streakDays.clamp(0, 7);
    for (var i = 7 - activeDays; i < 7; i++) {
      normalized[i] = true;
    }
    return normalized;
  }
}

class _SharkyHomeCardV1 extends StatelessWidget {
  const _SharkyHomeCardV1({
    required this.sharky,
    required this.streakDays,
    required this.earnedAchievements,
  });

  final Act0SharkyCueV1 sharky;
  final int streakDays;
  final List<Act0AchievementV1> earnedAchievements;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_home_sharky_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: Act0ShellTokensV1.primary.withValues(alpha: 0.28),
        glow: true,
        color: Act0ShellTokensV1.surface2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Act0SharkyGuideCardV1(
            eyebrow: 'Sharky guide',
            line: sharky.preSessionLine,
            detail: sharky.summaryLine,
            mood: sharky.preSessionMood,
            badgeLabel: streakDays > 0 ? '$streakDays day streak' : null,
          ),
          if (earnedAchievements.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Text('Unlocked', style: Act0ShellTokensV1.label),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Wrap(
              spacing: Act0ShellTokensV1.gapSm,
              runSpacing: Act0ShellTokensV1.gapSm,
              children: [
                for (final achievement in earnedAchievements)
                  _HomeAccentPillV1(
                    key: Key(
                      'act0_shell_home_achievement_${achievement.label}',
                    ),
                    label: achievement.label,
                    icon: Icons.workspace_premium_rounded,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeAccentPillV1 extends StatelessWidget {
  const _HomeAccentPillV1({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Act0ShellTokensV1.primary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayFlowPillV1 extends StatelessWidget {
  const _TodayFlowPillV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.primary.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
