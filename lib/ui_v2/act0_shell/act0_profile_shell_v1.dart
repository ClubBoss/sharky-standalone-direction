import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String _profileCopyV1(
  BuildContext context, {
  String? atomId,
  String? fallback,
  String? en,
  String? ru,
}) {
  if (atomId != null) {
    return act0LocalizedSurfaceAtomV1(
      context,
      atomId,
      fallback: fallback ?? en ?? '',
    );
  }
  return _isRuLocaleV1(context) ? (ru ?? en ?? '') : (en ?? fallback ?? '');
}

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
        Text(
          _profileCopyV1(context, atomId: 'profile_title', fallback: 'You'),
          style: Act0ShellTokensV1.screenTitle,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          key: const Key('act0_shell_profile_hero_card'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapXl),
          decoration: Act0ShellTokensV1.heroDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Text(
                _profileCopyV1(
                  context,
                  en: 'This screen is your growth view: momentum, focus, and proof that the work is sticking.',
                  ru: 'Это твой экран роста: ритм, текущий фокус и короткое доказательство, что работа закрепляется.',
                ),
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Wrap(
                spacing: Act0ShellTokensV1.gapSm,
                runSpacing: Act0ShellTokensV1.gapSm,
                children: [
                  _ProfileHeroFactChipV1(
                    keyName: 'tasks',
                    label: profile.lessonsLine,
                    tone: Act0ShellTokensV1.primary,
                  ),
                  _ProfileHeroFactChipV1(
                    keyName: 'accuracy',
                    label: profile.accuracyLine,
                    tone: Act0ShellTokensV1.gold,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
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
                            _profileCopyV1(
                              context,
                              atomId: 'profile_recommended_focus_label',
                              fallback: 'Recommended focus',
                            ),
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.gold,
                            ),
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                          Text(
                            profile.recommendedFocusTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Act0ShellTokensV1.cardTitle,
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                          Text(
                            profile.recommendedFocusBody,
                            key: const Key(
                              'act0_shell_profile_recommended_focus_body',
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
        _ProfileIdentityCardV1(profile: profile),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _ProfileConsistencyCardV1(profile: profile),
        if (profile.recentSkillGains.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _ProfileRecentGainsCardV1(profile: profile),
        ],
        if (profile.totalWorldsCount > 0) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _WorldProgressStripV1(
            clearedCount: profile.worldsClearedCount,
            activeCount: profile.worldsActiveCount,
            totalCount: profile.totalWorldsCount,
          ),
        ],
        if (profile.achievements.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _ProfileMilestonesCardV1(profile: profile),
        ],
        if (profile.skillStats.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _ProfileSkillStatsStripV1(profile: profile),
        ],
      ],
    );
  }
}

class _ProfileHeroFactChipV1 extends StatelessWidget {
  const _ProfileHeroFactChipV1({
    required this.keyName,
    required this.label,
    required this.tone,
  });

  final String keyName;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_profile_hero_$keyName'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: tone,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

class _ProfileSkillStatsStripV1 extends StatelessWidget {
  const _ProfileSkillStatsStripV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final visibleStats = profile.skillStats.toList(growable: false);
    if (visibleStats.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      key: const Key('act0_shell_profile_skill_stats'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profileCopyV1(
              context,
              en: 'Core poker skills',
              ru: 'Базовые покерные навыки',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            _profileCopyV1(
              context,
              en: 'Placement seeds the first read. Real reps sharpen it from here.',
              ru: 'Плейсмент даёт первый срез. Дальше навык шлифуют реальные репы.',
            ),
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < visibleStats.length; i++) ...[
                  _ProfileSkillCardV1(stat: visibleStats[i]),
                  if (i != visibleStats.length - 1)
                    const SizedBox(width: Act0ShellTokensV1.gapMd),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileConsistencyCardV1 extends StatelessWidget {
  const _ProfileConsistencyCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final streakLine = profile.streakLine.isNotEmpty
        ? profile.streakLine
        : _profileCopyV1(context, en: 'No streak yet', ru: 'Серии пока нет');
    final support = _profileConsistencySupportLineV1(
      context,
      profile,
      streakLine,
    );
    final momentumLine = _profileMomentumLineV1(context, profile);
    return Container(
      key: const Key('act0_shell_profile_streak_nudge'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profileCopyV1(
              context,
              atomId: 'profile_consistency_label',
              fallback: 'Consistency',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            _profileCopyV1(
              context,
              atomId: 'profile_streak_label',
              fallback: 'Streak',
            ),
            style: Act0ShellTokensV1.label,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(streakLine, style: Act0ShellTokensV1.cardTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            support,
            key: const Key('act0_shell_profile_consistency_support_text'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Wrap(
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: Act0ShellTokensV1.gapSm,
            children: [
              _ConsistencyFactChipV1(
                keyName: 'active_days',
                label: _isRuLocaleV1(context)
                    ? '${profile.consistencyActiveDays} активных дней'
                    : '${profile.consistencyActiveDays} active days',
                tone: Act0ShellTokensV1.primary,
              ),
              if (profile.worldsClearedCount > 0)
                _ConsistencyFactChipV1(
                  keyName: 'worlds',
                  label: _isRuLocaleV1(context)
                      ? '${profile.worldsClearedCount}/${profile.totalWorldsCount} миров закрыто'
                      : '${profile.worldsClearedCount}/${profile.totalWorldsCount} worlds cleared',
                  tone: Act0ShellTokensV1.gold,
                ),
              if (profile.mistakesFixedLine.isNotEmpty)
                _ConsistencyFactChipV1(
                  keyName: 'fixes',
                  label: profile.mistakesFixedLine,
                  tone: Act0ShellTokensV1.info,
                ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Container(
            key: const Key('act0_shell_profile_momentum_line'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface3.withOpacity(0.74),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(color: Act0ShellTokensV1.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                  color: Act0ShellTokensV1.primary,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Text(
                    momentumLine,
                    key: const Key('act0_shell_profile_momentum_text'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (profile.streakLast7.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            _StreakCalendarV1(days: profile.streakLast7),
          ],
        ],
      ),
    );
  }
}

String _profileMomentumLineV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  if (profile.streakDays >= 7) {
    return _profileSurfaceAtomByIdV1(
      context,
      'profile_momentum_streak_7',
      'Seven days in a row is no longer luck. This is becoming part of your game.',
    );
  }
  if (profile.streakDays >= 3) {
    return _profileSurfaceAtomByIdV1(
      context,
      'profile_momentum_streak_3',
      'The streak is real now. Keep stacking clean reps while the rhythm is warm.',
    );
  }
  if (profile.mistakesFixedLine.isNotEmpty) {
    return '${profile.mistakesFixedLine}. Clean repair is part of the climb.';
  }
  if (profile.worldsClearedCount > 0) {
    return _profileSurfaceAtomByIdV1(
      context,
      'profile_momentum_worlds_cleared',
      'A cleared world matters more than a loud stat. Keep the route moving.',
    );
  }
  return _profileSurfaceAtomByIdV1(
    context,
    'profile_momentum_first_habit',
    'The first stable habit is simply coming back for one more clean rep.',
  );
}

String _profileConsistencySupportLineV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
  String streakLine,
) {
  if (streakLine == 'No streak yet') {
    return profile.mistakesFixedLine.isNotEmpty
        ? _profileSurfaceAtomByIdV1(
            context,
            'profile_support_no_streak_with_fix',
            'You already fixed a live miss. One more clean rep starts the rhythm.',
          )
        : _profileSurfaceAtomByIdV1(
            context,
            'profile_support_no_streak_plain',
            'One clean rep starts the rhythm.',
          );
  }
  if (profile.streakDays >= 7) {
    return _profileSurfaceAtomByIdV1(
      context,
      'profile_support_streak_7',
      'This is no longer a random streak. The rhythm is becoming part of your game.',
    );
  }
  if (profile.worldsClearedCount > 0) {
    return _profileSurfaceAtomByIdV1(
      context,
      'profile_support_worlds_cleared',
      'Consistency is already leaving proof behind. Keep the route warm.',
    );
  }
  return _profileSurfaceAtomByIdV1(
    context,
    'profile_support_default',
    'Keep the rhythm warm. Consistency is turning into feel.',
  );
}

String _profileSurfaceAtomByIdV1(
  BuildContext context,
  String atomId,
  String fallback,
) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

class _ConsistencyFactChipV1 extends StatelessWidget {
  const _ConsistencyFactChipV1({
    required this.keyName,
    required this.label,
    required this.tone,
  });

  final String keyName;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_profile_consistency_$keyName'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: tone,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

class _ProfileMilestonesCardV1 extends StatelessWidget {
  const _ProfileMilestonesCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final featured = profile.achievements.take(2).toList();
    final storyLine = _milestoneStoryLineV1(profile);
    return Container(
      key: const Key('act0_shell_profile_milestones'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.gold.withOpacity(0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milestones',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(storyLine, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          for (var i = 0; i < featured.length; i++) ...[
            _AchievementCardV1(
              label: featured[i].label,
              icon: _achievementIconForLabel(featured[i].label),
              locked: featured[i].locked,
            ),
            if (i < featured.length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ),
    );
  }
}

class _ProfileRecentGainsCardV1 extends StatelessWidget {
  const _ProfileRecentGainsCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_profile_recent_skill_gains'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.info.withOpacity(0.20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profileCopyV1(
              context,
              en: 'Recent gains',
              ru: 'Последний рост',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            _profileCopyV1(
              context,
              en: 'Keep this short: what moved recently, not a full report card.',
              ru: 'Здесь только то, что реально сдвинулось недавно, без длинного отчёта.',
            ),
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          for (var index = 0; index < profile.recentSkillGains.take(3).length; index += 1) ...[
            _RecentSkillGainRowV1(gain: profile.recentSkillGains[index]),
            if (index < profile.recentSkillGains.take(3).length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapMd),
          ],
        ],
      ),
    );
  }
}

IconData _achievementIconForLabel(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('streak')) {
    return Icons.local_fire_department_rounded;
  }
  if (normalized.contains('perfect')) {
    return Icons.stars_rounded;
  }
  if (normalized.contains('table')) {
    return Icons.visibility_rounded;
  }
  return Icons.emoji_events_rounded;
}

String _milestoneStoryLineV1(Act0ProfileStateV1 profile) {
  final unlockedCount = profile.achievements
      .where((item) => !item.locked)
      .length;
  if (unlockedCount >= 3) {
    return 'These are no longer tiny wins. The route is leaving visible proof.';
  }
  if (unlockedCount >= 1) {
    return 'Small proofs that the work is starting to stick.';
  }
  if (profile.streakDays >= 3) {
    return 'The streak is warming up. The first real milestone is close.';
  }
  return 'Small proofs appear fast when the reps stay clean.';
}

class _StatTileV1 extends StatelessWidget {
  const _StatTileV1({
    required this.label,
    required this.value,
    this.subLine = '',
    this.compact = false,
  });

  final String label;
  final String value;
  final String subLine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        compact ? Act0ShellTokensV1.gapSm : Act0ShellTokensV1.gapMd,
      ),
      decoration: compact
          ? BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(color: Act0ShellTokensV1.border),
            )
          : Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            value,
            style: Act0ShellTokensV1.body.copyWith(
              fontWeight: compact ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
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
        : _profileCopyV1(context, en: 'Table basics', ru: 'Основы стола');
    final gain = profile.recentSkillGains.isNotEmpty
        ? profile.recentSkillGains.first.label
        : _profileCopyV1(context, en: 'Recent reps', ru: 'Недавние повторы');
    final focus = profile.recommendedFocusTitle.isNotEmpty
        ? profile.recommendedFocusTitle
        : _profileCopyV1(context, en: 'the next lesson', ru: 'следующий урок');
    final headline = profile.strongCategories.isNotEmpty
        ? _profileCopyV1(
            context,
            en: '$strong is starting to feel steady.',
            ru: '$strong начинает ощущаться увереннее.',
          )
        : _profileCopyV1(
            context,
            en: 'Your table base is starting to feel real.',
            ru: 'Твоя база по столу уже начинает ощущаться настоящей.',
          );
    final body = _profileCopyV1(
      context,
      en: 'Recent gains are sticking. Keep the route moving with $focus.',
      ru: 'Последние улучшения закрепляются. Продолжай маршрут через $focus.',
    );
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
            _profileCopyV1(
              context,
              en: 'Your game right now',
              ru: 'Твоя игра сейчас',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(headline, style: Act0ShellTokensV1.cardTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(body, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Column(
            children: [
              _IdentitySignalRowV1(
                label: _profileCopyV1(context, en: 'Steady', ru: 'Стабильно'),
                value: strong,
                color: Act0ShellTokensV1.primary,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _IdentitySignalRowV1(
                label: _profileCopyV1(
                  context,
                  en: 'Recent gain',
                  ru: 'Последний рост',
                ),
                value: gain,
                color: Act0ShellTokensV1.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdentitySignalRowV1 extends StatelessWidget {
  const _IdentitySignalRowV1({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Text(label, style: Act0ShellTokensV1.label.copyWith(color: color)),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Act0ShellTokensV1.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSnapshotStripV1 extends StatelessWidget {
  const _ProfileSnapshotStripV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, String value, String support})>[
      (
        label:
            profile.streakLine.isNotEmpty &&
                profile.streakLine != 'No streak yet'
            ? 'Streak'
            : 'Activity',
        value: profile.streakLine.isNotEmpty
            ? profile.streakLine
            : profile.level,
        support: '',
      ),
      (
        label: 'Tasks',
        value: profile.lessonsLine,
        support: profile.mistakesFixedLine,
      ),
      (label: 'XP', value: profile.xpLine, support: ''),
      (label: 'Accuracy', value: profile.accuracyLine, support: ''),
    ];
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Wrap(
        spacing: Act0ShellTokensV1.gapMd,
        runSpacing: Act0ShellTokensV1.gapMd,
        children: [
          for (final item in items)
            SizedBox(
              width: 140,
              child: _StatTileV1(
                label: item.label,
                value: item.value,
                subLine: item.support,
                compact: true,
              ),
            ),
        ],
      ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final value in values.take(3)) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusPill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Text(value, style: Act0ShellTokensV1.body),
                      ),
                    ],
                  ),
                  if (value != values.take(3).last)
                    const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
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
