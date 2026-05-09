import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

class Act0ProfileShellV1 extends StatelessWidget {
  const Act0ProfileShellV1({
    super.key,
    required this.profile,
    required this.onRetakePlacement,
    this.onGoToHome,
  });

  final Act0ProfileStateV1 profile;
  final VoidCallback onRetakePlacement;
  final VoidCallback? onGoToHome;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('act0_shell_profile_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Row(
          children: [
            Text('You', style: Act0ShellTokensV1.screenTitle),
            const Spacer(),
            IconButton(
              key: const Key('act0_shell_profile_retake_placement'),
              onPressed: onRetakePlacement,
              icon: const Icon(Icons.settings_rounded),
              color: Act0ShellTokensV1.textMuted,
            ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapXl),
          decoration: Act0ShellTokensV1.heroDecoration(),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.primary,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusXl,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Act0ShellTokensV1.primary.withOpacity(0.34),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Act0ShellTokensV1.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.playerName,
                      style: Act0ShellTokensV1.sectionTitle,
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(profile.level, style: Act0ShellTokensV1.muted),
                    const SizedBox(height: Act0ShellTokensV1.gapSm),
                    Text(
                      profile.xpLine,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _ProfileIdentityCardV1(profile: profile),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        if (profile.totalWorldsCount > 0)
          _WorldProgressStripV1(
            clearedCount: profile.worldsClearedCount,
            activeCount: profile.worldsActiveCount,
            totalCount: profile.totalWorldsCount,
          ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        if (profile.recommendedFocusTitle.isNotEmpty) ...[
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('act0_shell_profile_recommended_focus'),
              onTap: onGoToHome,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Act0ShellTokensV1.gold.withOpacity(0.15),
                      Act0ShellTokensV1.surface,
                      Act0ShellTokensV1.surface2,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusLg,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.gold.withOpacity(0.28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Act0ShellTokensV1.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusLg,
                        ),
                        border: Border.all(
                          color: Act0ShellTokensV1.gold.withOpacity(0.28),
                        ),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Act0ShellTokensV1.gold,
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended focus',
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.gold,
                            ),
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                          Text(
                            profile.recommendedFocusTitle,
                            style: Act0ShellTokensV1.cardTitle,
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                          Text(
                            profile.recommendedFocusBody,
                            style: Act0ShellTokensV1.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          profile.recommendedFocusCtaLabel,
                          key: const Key(
                            'act0_shell_profile_recommended_focus_cta_label',
                          ),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.primary,
                          ),
                        ),
                        if (onGoToHome != null) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Act0ShellTokensV1.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        Row(
          children: [
            Expanded(
              child: _StatTileV1(
                label:
                    profile.streakLine.isNotEmpty &&
                        profile.streakLine != 'No streak yet'
                    ? 'Streak'
                    : 'Activity',
                value: profile.streakLine.isNotEmpty
                    ? profile.streakLine
                    : profile.level,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            Expanded(
              child: _StatTileV1(
                label: 'Tasks',
                value: profile.lessonsLine,
                subLine: profile.mistakesFixedLine,
              ),
            ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapSm),
        Row(
          children: [
            Expanded(
              child: _StatTileV1(label: 'XP', value: profile.xpLine),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            Expanded(
              child: _StatTileV1(
                label: 'Accuracy',
                value: profile.accuracyLine,
              ),
            ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        if (profile.skillStats.isNotEmpty) ...[
          const Text('Poker skills', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Container(
            key: const Key('act0_shell_profile_skill_stats'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
            decoration: Act0ShellTokensV1.surfaceDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap any skill to learn what it means.',
                  style: Act0ShellTokensV1.muted,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                Wrap(
                  spacing: Act0ShellTokensV1.gapSm,
                  runSpacing: Act0ShellTokensV1.gapSm,
                  children: [
                    for (final stat in profile.skillStats)
                      _ProfileSkillCardV1(stat: stat),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        if (profile.recentSkillGains.isNotEmpty) ...[
          const Text('Recent gains', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Container(
            key: const Key('act0_shell_profile_recent_skill_gains'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
            decoration: Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
              borderColor: Act0ShellTokensV1.info.withOpacity(0.24),
            ),
            child: Column(
              children: [
                for (var i = 0; i < profile.recentSkillGains.length; i++) ...[
                  _RecentSkillGainRowV1(gain: profile.recentSkillGains[i]),
                  if (i < profile.recentSkillGains.length - 1)
                    const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        Row(
          children: [
            Expanded(
              child: _CategoryPanelV1(
                title: 'Working well',
                values: profile.strongCategories,
                emptyLabel: 'Finish clean drills',
                color: Act0ShellTokensV1.primary,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            Expanded(
              child: _CategoryPanelV1(
                title: 'Next reps',
                values: profile.weakCategories,
                emptyLabel: 'No weak spots',
                color: Act0ShellTokensV1.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        const Text('Recent progress', style: Act0ShellTokensV1.sectionTitle),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2,
          ),
          child: Column(
            children: [
              for (final item in profile.recentProgress.take(4)) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Act0ShellTokensV1.primary,
                      size: 18,
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Expanded(child: Text(item, style: Act0ShellTokensV1.body)),
                  ],
                ),
                if (item != profile.recentProgress.take(4).last)
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
              ],
              if (profile.recentProgress.isEmpty)
                Text(
                  'Start a lesson to fill this in.',
                  style: Act0ShellTokensV1.muted,
                ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        const Text('Daily habit', style: Act0ShellTokensV1.sectionTitle),
        const SizedBox(height: Act0ShellTokensV1.gapSm),
        Text(
          key: const Key('act0_shell_profile_streak_nudge'),
          profile.streakDays >= 7
              ? 'Solid consistency. Keep the momentum going.'
              : profile.streakDays > 0
              ? 'Come back tomorrow to extend your streak.'
              : 'Start your streak today — one lesson is enough.',
          style: Act0ShellTokensV1.muted,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        if (profile.streakLast7.length == 7)
          _StreakCalendarV1(days: profile.streakLast7)
        else
          Container(
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
            decoration: Act0ShellTokensV1.surfaceDecoration(),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (var i = 0; i < 28; i++)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: i < profile.consistencyActiveDays
                          ? Act0ShellTokensV1.primary.withOpacity(0.80)
                          : Act0ShellTokensV1.surface3,
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radius2xs,
                      ),
                      border: Border.all(color: Act0ShellTokensV1.border),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        OutlinedButton.icon(
          key: const Key('act0_shell_profile_retake_placement_cta'),
          onPressed: onRetakePlacement,
          style: Act0ShellTokensV1.quietButtonStyle(),
          icon: const Icon(Icons.route_rounded, size: 18),
          label: const Text('Retake placement'),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        const Text('Achievements', style: Act0ShellTokensV1.sectionTitle),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        for (var i = 0; i < profile.achievements.length; i++) ...[
          _AchievementCardV1(
            label: profile.achievements[i].label,
            icon: profile.achievements[i].locked
                ? Icons.lock_rounded
                : i.isEven
                ? Icons.emoji_events_rounded
                : Icons.local_fire_department_rounded,
            locked: profile.achievements[i].locked,
          ),
          if (i < profile.achievements.length - 1)
            const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
      ],
    );
  }
}

class _StatTileV1 extends StatelessWidget {
  const _StatTileV1({
    required this.label,
    required this.value,
    this.subLine = '',
  });

  final String label;
  final String value;
  final String subLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(value, style: Act0ShellTokensV1.body),
          if (subLine.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(subLine, style: Act0ShellTokensV1.muted),
          ],
        ],
      ),
    );
  }
}

class _ProfileIdentityCardV1 extends StatelessWidget {
  const _ProfileIdentityCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final strong = profile.strongCategories.isNotEmpty
        ? profile.strongCategories.first
        : 'Table basics';
    final weak = profile.weakCategories.isNotEmpty
        ? profile.weakCategories.first
        : profile.recommendedFocusTitle;
    final gain = profile.recentSkillGains.isNotEmpty
        ? profile.recentSkillGains.first.label
        : 'Recent reps';
    final focus = profile.recommendedFocusTitle.isNotEmpty
        ? profile.recommendedFocusTitle
        : 'the next lesson';
    final headline = profile.weakCategories.isNotEmpty
        ? '$strong is starting to feel steady.'
        : 'Your table base is starting to feel real.';
    final body = profile.weakCategories.isNotEmpty
        ? 'Recent gains are showing up. Keep pushing $weak so the next decisions feel simpler.'
        : 'Recent gains are sticking. Keep the route moving with $focus.';
    return Container(
      key: const Key('act0_shell_profile_identity_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your game right now',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(headline, style: Act0ShellTokensV1.cardTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(body, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Wrap(
            spacing: Act0ShellTokensV1.gapXs,
            runSpacing: Act0ShellTokensV1.gapXs,
            children: [
              _IdentitySignalChipV1(
                label: 'Base: $strong',
                color: Act0ShellTokensV1.primary,
              ),
              if (weak.isNotEmpty)
                _IdentitySignalChipV1(
                  label: 'Next reps: $weak',
                  color: Act0ShellTokensV1.gold,
                ),
              _IdentitySignalChipV1(
                label: 'Recent gain: $gain',
                color: Act0ShellTokensV1.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdentitySignalChipV1 extends StatelessWidget {
  const _IdentitySignalChipV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Text(label, style: Act0ShellTokensV1.label.copyWith(color: color)),
    );
  }
}

class _WorldProgressStripV1 extends StatelessWidget {
  const _WorldProgressStripV1({
    required this.clearedCount,
    required this.activeCount,
    required this.totalCount,
  });

  final int clearedCount;
  final int activeCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final lockedCount = (totalCount - clearedCount - activeCount).clamp(
      0,
      totalCount,
    );
    final summaryParts = <String>[
      if (clearedCount > 0) '$clearedCount cleared',
      if (activeCount > 0) '$activeCount active',
      if (lockedCount > 0) '$lockedCount locked',
    ];
    return Container(
      key: const Key('act0_shell_profile_world_progress'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'World progress',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textDim,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Row(
            children: [
              for (var i = 0; i < totalCount.clamp(0, 12); i++)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 22,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i < clearedCount
                          ? Act0ShellTokensV1.primary
                          : i < clearedCount + activeCount
                          ? Act0ShellTokensV1.gold
                          : Act0ShellTokensV1.surface3,
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radius2xs,
                      ),
                      border: (i >= clearedCount + activeCount)
                          ? Border.all(color: Act0ShellTokensV1.border)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(summaryParts.join(' · '), style: Act0ShellTokensV1.muted),
        ],
      ),
    );
  }
}

class _StreakCalendarV1 extends StatelessWidget {
  const _StreakCalendarV1({required this.days});

  // 7 booleans: index 0 = oldest day, index 6 = today
  final List<bool> days;

  static const _dayLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_profile_streak_calendar'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _StreakDayCellV1(index: i, label: _dayLabels[i], active: days[i]),
        ],
      ),
    );
  }
}

class _StreakDayCellV1 extends StatelessWidget {
  const _StreakDayCellV1({
    required this.index,
    required this.label,
    required this.active,
  });

  final int index;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          key: Key('act0_shell_profile_streak_day_$index'),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active
                ? Act0ShellTokensV1.primary
                : Act0ShellTokensV1.surface3,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
            border: Border.all(
              color: active
                  ? Act0ShellTokensV1.primary.withOpacity(0.60)
                  : Act0ShellTokensV1.border,
            ),
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          label,
          style: Act0ShellTokensV1.label.copyWith(
            color: active
                ? Act0ShellTokensV1.primary
                : Act0ShellTokensV1.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CategoryPanelV1 extends StatelessWidget {
  const _CategoryPanelV1({
    required this.title,
    required this.values,
    required this.emptyLabel,
    required this.color,
  });

  final String title;
  final List<String> values;
  final String emptyLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: color.withOpacity(0.30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Act0ShellTokensV1.label.copyWith(color: color)),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          if (values.isEmpty)
            Text(emptyLabel, style: Act0ShellTokensV1.muted)
          else
            Wrap(
              spacing: Act0ShellTokensV1.gapXs,
              runSpacing: Act0ShellTokensV1.gapXs,
              children: [
                for (final value in values.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Act0ShellTokensV1.gapSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(color: color.withOpacity(0.28)),
                    ),
                    child: Text(
                      value,
                      style: Act0ShellTokensV1.label.copyWith(color: color),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProfileSkillCardV1 extends StatelessWidget {
  const _ProfileSkillCardV1({required this.stat});

  final Act0PlacementSkillStatV1 stat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: InkWell(
        key: Key('act0_shell_profile_skill_stat_${stat.label}'),
        onTap: () => _showSkillDetailsSheet(context, stat),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2,
            borderColor: stat.locked
                ? Act0ShellTokensV1.border
                : Act0ShellTokensV1.primary.withOpacity(0.20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(stat.label, style: Act0ShellTokensV1.body),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapXs),
                  Icon(
                    stat.locked
                        ? Icons.lock_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: stat.locked
                        ? Act0ShellTokensV1.textMuted
                        : Act0ShellTokensV1.info,
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                stat.locked ? 'Later' : stat.levelLabel,
                style: Act0ShellTokensV1.label.copyWith(
                  color: stat.locked
                      ? Act0ShellTokensV1.textMuted
                      : Act0ShellTokensV1.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stat.locked ? 'Opens later' : stat.nextLevelLabel,
                key: Key('act0_shell_profile_skill_value_${stat.label}'),
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: stat.nextLevelProgress,
                  backgroundColor: Act0ShellTokensV1.surface3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stat.locked
                        ? Act0ShellTokensV1.textMuted.withOpacity(0.20)
                        : Act0ShellTokensV1.primary,
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

void _showSkillDetailsSheet(
  BuildContext context,
  Act0PlacementSkillStatV1 stat,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface,
            borderColor: Act0ShellTokensV1.primary.withOpacity(0.22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.label,
                      style: Act0ShellTokensV1.sectionTitle,
                    ),
                  ),
                  Text(
                    stat.locked
                        ? 'Later'
                        : '${stat.levelLabel}  ${stat.nextLevelLabel}',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: stat.locked
                          ? Act0ShellTokensV1.textMuted
                          : Act0ShellTokensV1.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _SkillDetailBlockV1(title: 'What it means', text: stat.meaning),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _SkillDetailBlockV1(title: 'What it affects', text: stat.affects),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _SkillDetailBlockV1(
                title: 'Why it matters',
                text: stat.whyImportant,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SkillDetailBlockV1 extends StatelessWidget {
  const _SkillDetailBlockV1({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Act0ShellTokensV1.label.copyWith(
            color: Act0ShellTokensV1.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: Act0ShellTokensV1.muted.copyWith(
            color: Act0ShellTokensV1.text,
          ),
        ),
      ],
    );
  }
}

class _RecentSkillGainRowV1 extends StatelessWidget {
  const _RecentSkillGainRowV1({required this.gain});

  final Act0SkillGainV1 gain;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.info.withOpacity(0.14),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
          ),
          child: Text(
            '+${gain.gain}',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
            ),
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gain.label, style: Act0ShellTokensV1.body),
              const SizedBox(height: 2),
              Text(gain.source, style: Act0ShellTokensV1.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementCardV1 extends StatelessWidget {
  const _AchievementCardV1({
    required this.label,
    required this.icon,
    required this.locked,
  });

  final String label;
  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final keySlug = label.toLowerCase().replaceAll(' ', '_');
    return Opacity(
      key: Key('act0_shell_profile_achievement_$keySlug'),
      opacity: locked ? 0.62 : 1,
      child: Container(
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          borderColor: locked
              ? Act0ShellTokensV1.border
              : Act0ShellTokensV1.gold.withOpacity(0.42),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    (locked
                            ? Act0ShellTokensV1.textDim
                            : Act0ShellTokensV1.gold)
                        .withOpacity(0.14),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              ),
              child: Icon(
                icon,
                color: locked
                    ? Act0ShellTokensV1.textDim
                    : Act0ShellTokensV1.gold,
                size: 20,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapMd),
            Expanded(child: Text(label, style: Act0ShellTokensV1.cardTitle)),
          ],
        ),
      ),
    );
  }
}
