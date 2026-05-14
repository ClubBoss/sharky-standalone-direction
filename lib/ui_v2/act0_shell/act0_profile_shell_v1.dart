import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
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
    this.onReplayWelcome,
    this.onGoToHome,
  });

  final Act0ProfileStateV1 profile;
  final VoidCallback onRetakePlacement;
  final VoidCallback? onReplayWelcome;
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
        Act0ShellScreenHeaderV1(
          title: _profileCopyV1(
            context,
            atomId: 'profile_title',
            fallback: 'You',
          ),
          subtitle: _profileCopyV1(
            context,
            en: 'See what is sticking, what still leaks, and where to focus next.',
            ru: 'Смотри, что уже держится, где ещё течёт и куда идти дальше.',
          ),
          eyebrow: profile.level,
          eyebrowTone: Act0ShellTokensV1.info,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _ProfileHeroCardV1(profile: profile),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        if (profile.skillStats.isNotEmpty) ...[
          _ProfileSkillStatsStripV1(profile: profile),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        _ProfileIdentityCardV1(profile: profile),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _ProfileConsistencyCardV1(profile: profile),
        if (profile.achievements.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _ProfileMilestonesCardV1(profile: profile),
        ],
        if (profile.recommendedFocusTitle.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _ProfileCurrentFocusCardV1(profile: profile, onGoToHome: onGoToHome),
        ],
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _ProfileFirstStartToolsCardV1(
          onRetakePlacement: onRetakePlacement,
          onReplayWelcome: onReplayWelcome,
        ),
      ],
    );
  }
}

class _ProfileFirstStartToolsCardV1 extends StatelessWidget {
  const _ProfileFirstStartToolsCardV1({
    required this.onRetakePlacement,
    this.onReplayWelcome,
  });

  final VoidCallback onRetakePlacement;
  final VoidCallback? onReplayWelcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_profile_first_start_tools'),
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
              atomId: 'profile_first_start_tools_title',
              fallback: 'First start tools',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            _profileCopyV1(
              context,
              atomId: 'profile_first_start_tools_body',
              fallback:
                  'Replay the product intro or run placement again without touching your route progress.',
            ),
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Wrap(
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: Act0ShellTokensV1.gapSm,
            children: [
              if (onReplayWelcome != null)
                OutlinedButton.icon(
                  key: const Key('act0_shell_profile_replay_welcome'),
                  onPressed: onReplayWelcome,
                  style: Act0ShellTokensV1.quietButtonStyle(),
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(
                    _profileCopyV1(
                      context,
                      atomId: 'profile_first_start_replay_welcome',
                      fallback: 'Replay welcome',
                    ),
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('act0_shell_profile_retake_placement'),
                onPressed: onRetakePlacement,
                style: Act0ShellTokensV1.quietButtonStyle(),
                icon: const Icon(Icons.route_rounded),
                label: Text(
                  _profileCopyV1(
                    context,
                    atomId: 'profile_first_start_retake_placement',
                    fallback: 'Retake placement',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCardV1 extends StatelessWidget {
  const _ProfileHeroCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final summary = _profileIdentitySummaryV1(context, profile);
    return Container(
      key: const Key('act0_shell_profile_hero_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.primary,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusLg,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Act0ShellTokensV1.primary.withOpacity(0.32),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Act0ShellTokensV1.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.playerName,
                      style: Act0ShellTokensV1.sectionTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(profile.level, style: Act0ShellTokensV1.muted),
                    const SizedBox(height: Act0ShellTokensV1.gapSm),
                    Text(summary.headline, style: Act0ShellTokensV1.cardTitle),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.gold.withOpacity(0.22),
                  ),
                ),
                child: Text(
                  profile.xpLine,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.gold,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            summary.body,
            key: const Key('act0_shell_profile_identity_summary'),
            maxLines: 3,
            overflow: TextOverflow.fade,
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
                keyName: 'accuracy',
                label: profile.accuracyLine,
                tone: Act0ShellTokensV1.primary,
              ),
              _ProfileHeroFactChipV1(
                keyName: 'tasks',
                label: profile.lessonsLine,
                tone: Act0ShellTokensV1.info,
              ),
              if (profile.streakDays > 0)
                _ProfileHeroFactChipV1(
                  keyName: 'streak',
                  label: profile.streakLine,
                  tone: Act0ShellTokensV1.gold,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

({String headline, String body}) _profileIdentitySummaryV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final strong = profile.strongCategories.isNotEmpty
      ? profile.strongCategories.first
      : _profileCopyV1(context, en: 'table basics', ru: 'база по столу');
  final gain = profile.recentSkillGains.isNotEmpty
      ? profile.recentSkillGains.first.label
      : _profileCopyV1(context, en: 'recent progress', ru: 'недавний прогресс');
  final headline = profile.strongCategories.isNotEmpty
      ? _profileCopyV1(
          context,
          en: '$strong is becoming part of your game.',
          ru: '$strong уже становится частью твоей игры.',
        )
      : _profileCopyV1(
          context,
          en: 'Your poker base is starting to feel real.',
          ru: 'Твоя покерная база уже начинает ощущаться реальной.',
        );
  final body = profile.recentSkillGains.isNotEmpty
      ? _profileCopyV1(
          context,
          en: '$gain moved recently. The profile below shows what is already sticking.',
          ru: '$gain сдвинулся недавно. Ниже видно, что уже закрепляется.',
        )
      : _profileCopyV1(
          context,
          en: 'Your profile below shows the skills, rhythm, and proof you have already built.',
          ru: 'Ниже видно навыки, ритм и доказательства того, что уже закрепилось.',
        );
  return (headline: headline, body: body);
}

int _profileUnlockedAchievementsCountV1(Act0ProfileStateV1 profile) {
  return profile.achievements
      .where((achievement) => !achievement.locked)
      .length;
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
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
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

class _ProfileCurrentFocusCardV1 extends StatelessWidget {
  const _ProfileCurrentFocusCardV1({required this.profile, this.onGoToHome});

  final Act0ProfileStateV1 profile;
  final VoidCallback? onGoToHome;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      key: const Key('act0_shell_profile_recommended_focus'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profileCopyV1(context, en: 'Next focus', ru: 'Следующий фокус'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            profile.recommendedFocusTitle,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            profile.recommendedFocusBody,
            key: const Key('act0_shell_profile_recommended_focus_body'),
            maxLines: 3,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            profile.recommendedFocusCtaLabel,
            key: const Key('act0_shell_profile_recommended_focus_cta_label'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
    if (onGoToHome == null) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('act0_shell_profile_recommended_focus_tap'),
        onTap: onGoToHome,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        child: card,
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
    final recentGainByLabel = <String, Act0SkillGainV1>{
      for (final gain in profile.recentSkillGains) gain.label: gain,
    };
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
            _profileCopyV1(context, en: 'Poker skills', ru: 'Покерные навыки'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            _profileCopyV1(
              context,
              en: profile.recentSkillGains.isEmpty
                  ? 'This is what your game is actually made of.'
                  : 'Recent gains show where the game is moving right now.',
              ru: profile.recentSkillGains.isEmpty
                  ? 'Это и есть те навыки, из которых реально состоит твоя игра.'
                  : 'Последние приросты показывают, куда игра двигается прямо сейчас.',
            ),
            style: Act0ShellTokensV1.muted,
          ),
          if (profile.recentSkillGains.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Text(
              _profileCopyV1(
                context,
                en: 'Recent gains',
                ru: 'Последние приросты',
              ),
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.recentSkillGains
                  .take(2)
                  .map((gain) => '${gain.label} +${gain.gain}')
                  .join('  ·  '),
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _TwoColumnStaggeredGridV1(
            children: [
              for (final stat in visibleStats)
                _ProfileSkillCardV1(
                  stat: stat,
                  gain: recentGainByLabel[stat.label],
                ),
            ],
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
              fallback: 'Rhythm',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(streakLine, style: Act0ShellTokensV1.cardTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            support,
            key: const Key('act0_shell_profile_consistency_support_text'),
            maxLines: 3,
            overflow: TextOverflow.fade,
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
              if (profile.mistakesFixedLine.isNotEmpty)
                _ConsistencyFactChipV1(
                  keyName: 'fixes',
                  label: profile.mistakesFixedLine,
                  tone: Act0ShellTokensV1.info,
                ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          KeyedSubtree(
            key: const Key('act0_shell_profile_momentum_line'),
            child: Text(
              momentumLine,
              key: const Key('act0_shell_profile_momentum_text'),
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.textMuted,
              ),
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
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
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
    final featured = profile.achievements.take(3).toList();
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
          _TwoColumnStaggeredGridV1(
            children: [
              for (final achievement in featured)
                _AchievementCardV1(
                  achievementId: achievement.stableId,
                  label: achievement.label,
                  icon: _achievementIconForAchievement(achievement),
                  locked: achievement.locked,
                ),
            ],
          ),
          if (profile.achievements.length > featured.length) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const Key('act0_shell_profile_achievements_button'),
                onPressed: () => _showAchievementsSheet(context, profile),
                style: Act0ShellTokensV1.quietButtonStyle().copyWith(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusMd,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  _profileCopyV1(
                    context,
                    en: 'View all badges',
                    ru: 'Все бейджи',
                  ),
                ),
              ),
            ),
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
            _profileCopyV1(context, en: 'Recent gains', ru: 'Последний рост'),
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
          for (
            var index = 0;
            index < profile.recentSkillGains.take(3).length;
            index += 1
          ) ...[
            _RecentSkillGainRowV1(gain: profile.recentSkillGains[index]),
            if (index < profile.recentSkillGains.take(3).length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapMd),
          ],
        ],
      ),
    );
  }
}

IconData _achievementIconForAchievement(Act0AchievementV1 achievement) {
  final normalizedId = achievement.stableId.toLowerCase();
  final normalizedLabel = achievement.label.toLowerCase();
  if (normalizedId.contains('streak') || normalizedId.contains('rhythm')) {
    return Icons.local_fire_department_rounded;
  }
  if (normalizedId.contains('perfect') ||
      normalizedId.contains('clean_drill') ||
      normalizedLabel.contains('clean')) {
    return Icons.stars_rounded;
  }
  if (normalizedId.contains('table') || normalizedLabel.contains('read')) {
    return Icons.visibility_rounded;
  }
  if (normalizedId.contains('repair')) {
    return Icons.build_circle_rounded;
  }
  return Icons.emoji_events_rounded;
}

String _milestoneStoryLineV1(Act0ProfileStateV1 profile) {
  final unlockedCount = profile.achievements
      .where((item) => !item.locked)
      .length;
  if (unlockedCount >= 3) {
    return 'Visible proof that the work is turning into something real.';
  }
  if (unlockedCount >= 1) {
    return 'Small proofs that the work is starting to stick.';
  }
  if (profile.streakDays >= 3) {
    return 'The streak is warming up. The first real badge is close.';
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
        ? '${profile.recentSkillGains.first.label} +${profile.recentSkillGains.first.gain}'
        : _profileCopyV1(context, en: 'Recent reps', ru: 'Недавние повторы');
    final weak = profile.weakCategories.isNotEmpty
        ? profile.weakCategories.first
        : _profileCopyV1(
            context,
            en: 'No live leak',
            ru: 'Явных слабых мест нет',
          );
    final focus = profile.recommendedFocusTitle.isNotEmpty
        ? profile.recommendedFocusTitle
        : _profileCopyV1(
            context,
            en: 'Keep the next clean rep simple.',
            ru: 'Пусть следующий шаг будет простым.',
          );
    final headline = profile.strongCategories.isNotEmpty
        ? _profileCopyV1(
            context,
            en: 'You are becoming the kind of player who keeps $strong steady.',
            ru: 'Ты становишься игроком, у которого $strong держится увереннее.',
          )
        : _profileCopyV1(
            context,
            en: 'Your table base is starting to feel real.',
            ru: 'Твоя база по столу уже начинает ощущаться настоящей.',
          );
    final body = _profileCopyV1(
      context,
      en: 'You can already see what is steady, what is growing, and what still needs calm reps.',
      ru: 'Уже видно, что у тебя стабильно, что растёт и где ещё нужен спокойный повтор.',
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
                  en: 'Earned growth',
                  ru: 'Заработанный рост',
                ),
                value: gain,
                color: Act0ShellTokensV1.info,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _IdentitySignalRowV1(
                label: _profileCopyV1(
                  context,
                  en: 'Next focus',
                  ru: 'Следующий фокус',
                ),
                value: focus,
                color: Act0ShellTokensV1.gold,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _IdentitySignalRowV1(
                label: _profileCopyV1(
                  context,
                  en: 'Still shaping',
                  ru: 'Ещё формируется',
                ),
                value: weak,
                color: Act0ShellTokensV1.danger,
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
  const _ProfileSkillCardV1({required this.stat, this.gain});

  final Act0PlacementSkillStatV1 stat;
  final Act0SkillGainV1? gain;

  @override
  Widget build(BuildContext context) {
    final tone = stat.locked
        ? Act0ShellTokensV1.textMuted
        : Act0ShellTokensV1.primary;
    return InkWell(
      key: Key('act0_shell_profile_skill_stat_${stat.label}'),
      onTap: () => _showSkillDetailsSheet(context, stat),
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
      child: Container(
        constraints: const BoxConstraints(minHeight: 126),
        padding: const EdgeInsets.all(12),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          color: Act0ShellTokensV1.surface3.withOpacity(0.72),
          borderColor: stat.locked
              ? Act0ShellTokensV1.border
              : tone.withOpacity(0.18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat.label, style: Act0ShellTokensV1.body),
                      const SizedBox(height: 4),
                      Text(
                        stat.locked ? 'Later' : stat.levelLabel,
                        style: Act0ShellTokensV1.label.copyWith(color: tone),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                if (gain != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.gold.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.gold.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      '+${gain!.gain}',
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.gold,
                      ),
                    ),
                  )
                else
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
            const SizedBox(height: 6),
            Text(
              stat.locked ? 'Opens later' : stat.nextLevelLabel,
              key: Key('act0_shell_profile_skill_value_${stat.label}'),
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted,
            ),
            if (gain != null) ...[
              const SizedBox(height: 2),
              Text(
                gain!.source,
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.textDim,
                  letterSpacing: 0.1,
                ),
              ),
            ],
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radius2xs),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: stat.nextLevelProgress,
                backgroundColor: Act0ShellTokensV1.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  stat.locked
                      ? Act0ShellTokensV1.textMuted.withOpacity(0.20)
                      : tone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAchievementsSheet(BuildContext context, Act0ProfileStateV1 profile) {
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
            borderColor: Act0ShellTokensV1.gold.withOpacity(0.22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Badge collection', style: Act0ShellTokensV1.sectionTitle),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                'Proof from streaks, repairs, clean drills, and steady return.',
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Flexible(
                child: SingleChildScrollView(
                  child: _TwoColumnStaggeredGridV1(
                    children: [
                      for (final achievement in profile.achievements)
                        _AchievementCardV1(
                          achievementId: achievement.stableId,
                          label: achievement.label,
                          icon: _achievementIconForAchievement(achievement),
                          locked: achievement.locked,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
    required this.achievementId,
    required this.label,
    required this.icon,
    required this.locked,
  });

  final String achievementId;
  final String label;
  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      key: Key('act0_shell_profile_achievement_$achievementId'),
      opacity: locked ? 0.62 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(12),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          borderColor: locked
              ? Act0ShellTokensV1.border
              : Act0ShellTokensV1.gold.withOpacity(0.42),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Text(
              label,
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoColumnStaggeredGridV1 extends StatelessWidget {
  const _TwoColumnStaggeredGridV1({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = Act0ShellTokensV1.gapSm;
        final itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < children.length; i++)
              SizedBox(width: itemWidth, child: children[i]),
          ],
        );
      },
    );
  }
}
