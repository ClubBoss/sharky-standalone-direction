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
        _ProfileHeaderBandV1(profile: profile),
        const SizedBox(height: Act0ShellTokensV1.gapSm),
        _ProfileHeroCardV1(profile: profile),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        if (profile.recommendedFocusTitle.isNotEmpty) ...[
          _ProfileCurrentFocusCardV1(profile: profile, onGoToHome: onGoToHome),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
        ],
        if (profile.recentSkillGains.isNotEmpty ||
            profile.mistakesFixedLine.isNotEmpty ||
            profile.streakLine.isNotEmpty ||
            profile.qualityLine.isNotEmpty) ...[
          _ProfileRecentGainsCardV1(profile: profile),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
        ],
        if (profile.recentSkillGains.isNotEmpty ||
            profile.strongCategories.isNotEmpty ||
            profile.weakCategories.isNotEmpty ||
            profile.recommendedFocusTitle.isNotEmpty) ...[
          _ProfileIdentityCardV1(profile: profile),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
        ],
        _ProfileConsistencyCardV1(profile: profile),
        if (profile.skillStats.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _ProfileSkillStatsStripV1(profile: profile),
        ],
        if (profile.achievements.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _ProfileMilestonesCardV1(profile: profile),
        ],
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _ProfileUtilityFooterV1(
          onRetakePlacement: onRetakePlacement,
          onReplayWelcome: onReplayWelcome,
        ),
      ],
    );
  }
}

class _ProfileHeaderBandV1 extends StatelessWidget {
  const _ProfileHeaderBandV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_profile_header_band'),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profileCopyV1(context, atomId: 'profile_title', fallback: 'You'),
            style: Act0ShellTokensV1.screenTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            _profileHeaderSublineV1(context, profile),
            style: Act0ShellTokensV1.muted,
          ),
        ],
      ),
    );
  }
}

String _profileHeaderSublineV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
  final strongest = recentGains.isNotEmpty
      ? recentGains.first.label
      : (profile.strongCategories.isNotEmpty
            ? profile.strongCategories.first
            : '');
  if (strongest.isNotEmpty) {
    return _profileCopyV1(
      context,
      en: '${profile.level} · $strongest is getting stronger',
      ru: '${profile.level} · $strongest укрепляется',
    );
  }
  return _profileCopyV1(
    context,
    en: '${profile.level} · Your game is taking shape',
    ru: '${profile.level} · Твоя игра начинает обретать форму',
  );
}

class _ProfileUtilityFooterV1 extends StatelessWidget {
  const _ProfileUtilityFooterV1({
    required this.onRetakePlacement,
    this.onReplayWelcome,
  });

  final VoidCallback onRetakePlacement;
  final VoidCallback? onReplayWelcome;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        key: const Key('act0_shell_profile_first_start_tools_button'),
        onPressed: () => _showFirstStartToolsSheetV1(
          context,
          onRetakePlacement: onRetakePlacement,
          onReplayWelcome: onReplayWelcome,
        ),
        style: Act0ShellTokensV1.quietButtonStyle().copyWith(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: Act0ShellTokensV1.border.withOpacity(0.72)),
          ),
          iconSize: const WidgetStatePropertyAll(17),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
        ),
        icon: const Icon(Icons.tune_rounded),
        label: Text(
          _profileCopyV1(
            context,
            atomId: 'profile_first_start_tools_title',
            fallback: 'First start tools',
          ),
        ),
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
    final completionLine = _profileCompactCompletionLineV1(context, profile);
    return Container(
      key: const Key('act0_shell_profile_hero_card'),
      padding: const EdgeInsets.all(12),
      decoration: Act0ShellTokensV1.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
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
                  size: 20,
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
                    const SizedBox(height: 6),
                    Text(
                      summary.headline,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.cardTitle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.gold.withOpacity(0.18),
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
          const SizedBox(height: 8),
          Text(
            summary.body,
            key: const Key('act0_shell_profile_identity_summary'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: 5,
            children: [
              _ProfileHeroFactChipV1(
                keyName: 'quality',
                label: _profileHeroQualityLineV1(context, profile),
                tone: Act0ShellTokensV1.gold,
              ),
              _ProfileHeroFactChipV1(
                keyName: 'tasks',
                label: completionLine,
                tone: Act0ShellTokensV1.textMuted,
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
  final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
  final strong = profile.strongCategories.isNotEmpty
      ? profile.strongCategories.first
      : '';
  final weak = profile.weakCategories.isNotEmpty
      ? profile.weakCategories.first
      : '';
  final gain = recentGains.isNotEmpty ? recentGains.first.label : '';
  final headline = gain.isNotEmpty
      ? _profileCopyV1(
          context,
          en: 'You are getting better at $gain.',
          ru: 'Ты становишься сильнее в $gain.',
        )
      : strong.isNotEmpty
      ? _profileCopyV1(
          context,
          en: '$strong is your strongest start.',
          ru: '$strong — твой самый сильный старт.',
        )
      : weak.isNotEmpty
      ? _profileCopyV1(
          context,
          en: '$weak still needs one clean rep.',
          ru: '$weak всё ещё нужен один чистый повтор.',
        )
      : _profileCopyV1(
          context,
          en: 'Your poker base is starting to feel real.',
          ru: 'Твоя покерная база уже начинает ощущаться реальной.',
        );
  final body = gain.isNotEmpty
      ? _profileSkillInsightBodyV1(context, gain)
      : strong.isNotEmpty
      ? _profileStrongSkillSupportBodyV1(context, strong)
      : weak.isNotEmpty
      ? _profileWeakSkillSupportBodyV1(context, weak)
      : _profileCopyV1(
          context,
          en: 'Your profile below shows the skills, rhythm, and proof you have already built.',
          ru: 'Ниже видно навыки, ритм и доказательства того, что уже закрепилось.',
        );
  return (headline: headline, body: body);
}

String _profileStrongSkillSupportBodyV1(BuildContext context, String label) {
  switch (label) {
    case 'Table sense':
      return _profileCopyV1(
        context,
        en: 'Use it before every close decision.',
        ru: 'Опирайся на это перед каждым близким решением.',
      );
    case 'Board reading':
      return _profileCopyV1(
        context,
        en: 'Let board texture steady the next close spot.',
        ru: 'Пусть текстура борда удерживает следующий тонкий спот.',
      );
    case 'Hand reading':
      return _profileCopyV1(
        context,
        en: 'Keep narrowing ranges before you commit chips.',
        ru: 'Продолжай сужать диапазоны до того, как вкладывать фишки.',
      );
    case 'Betting decisions':
      return _profileCopyV1(
        context,
        en: 'Keep using it before every purposeful bet.',
        ru: 'Продолжай использовать это перед каждой осмысленной ставкой.',
      );
  }
  return _profileCopyV1(
    context,
    en: 'Use it before every close decision.',
    ru: 'Опирайся на это перед каждым близким решением.',
  );
}

String _profileWeakSkillSupportBodyV1(BuildContext context, String label) {
  return _profileCopyV1(
    context,
    en: 'A short review keeps $label from becoming a habit.',
    ru: 'Короткий разбор не даст $label стать привычкой.',
  );
}

String _profileSkillInsightBodyV1(BuildContext context, String label) {
  switch (label) {
    case 'Table sense':
      return _profileCopyV1(
        context,
        en: 'You are beginning to read the table before acting.',
        ru: 'Ты начинаешь читать стол ещё до действия.',
      );
    case 'Board reading':
      return _profileCopyV1(
        context,
        en: 'Board texture is starting to guide your decisions earlier.',
        ru: 'Текстура борда уже раньше начинает направлять твои решения.',
      );
    case 'Hand reading':
      return _profileCopyV1(
        context,
        en: 'You are getting faster at narrowing what opponents can hold.',
        ru: 'Ты быстрее сужаешь, что может быть у соперников.',
      );
    case 'Betting decisions':
      return _profileCopyV1(
        context,
        en: 'Your bets are starting to carry cleaner purpose.',
        ru: 'Твои ставки начинают нести более чистую цель.',
      );
    case 'Position play':
      return _profileCopyV1(
        context,
        en: 'Seat order is starting to shape your choices more naturally.',
        ru: 'Порядок позиций уже естественнее влияет на твой выбор.',
      );
    case 'Blind play':
      return _profileCopyV1(
        context,
        en: 'Blind pressure is becoming easier to handle without noise.',
        ru: 'Давление блайндов становится проще выдерживать без шума.',
      );
    case 'Legal actions':
      return _profileCopyV1(
        context,
        en: 'Cleaner action rules are reducing hesitation at the table.',
        ru: 'Более чистые правила действий уменьшают заминку за столом.',
      );
    case 'Choose best five':
      return _profileCopyV1(
        context,
        en: 'You are getting quicker at spotting the best made hand.',
        ru: 'Ты быстрее замечаешь лучшую готовую руку.',
      );
  }
  return _profileCopyV1(
    context,
    en: 'That is the base for cleaner decisions.',
    ru: 'Это база для более чистых решений.',
  );
}

String _profileStrengthPayoffTitleV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
  if (recentGains.isNotEmpty) {
    return recentGains.first.label;
  }
  if (profile.strongCategories.isNotEmpty) {
    return profile.strongCategories.first;
  }
  return _profileCopyV1(context, en: 'Table basics', ru: 'Основы стола');
}

String _profileStrengthPayoffBodyV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
  if (recentGains.isNotEmpty) {
    return _profileCopyV1(
      context,
      en: 'This skill is starting to hold up in more clean spots.',
      ru: 'Этот навык начинает держаться в большем числе чистых спотов.',
    );
  }
  final strong = profile.strongCategories.isNotEmpty
      ? profile.strongCategories.first
      : '';
  if (strong.isNotEmpty) {
    return _profileStrongSkillSupportBodyV1(context, strong);
  }
  return _profileCopyV1(
    context,
    en: 'This part of your game is beginning to feel steadier.',
    ru: 'Эта часть твоей игры начинает чувствоваться увереннее.',
  );
}

int _profileUnlockedAchievementsCountV1(Act0ProfileStateV1 profile) {
  return profile.achievements
      .where((achievement) => !achievement.locked)
      .length;
}

String _profileCompactCompletionLineV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final match = RegExp(
    r'^\s*(\d+)\s+of\s+\d+\s+tasks?\s+complete',
  ).firstMatch(profile.lessonsLine);
  if (match != null) {
    return _profileCopyV1(
      context,
      en: '${match.group(1)} tasks complete',
      ru: '${match.group(1)} заданий завершено',
    );
  }
  return profile.lessonsLine;
}

String _profileHeroQualityLineV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  if (profile.qualityLine.trim().isNotEmpty) {
    return profile.qualityLine;
  }
  final completedMatch = RegExp(
    r'^\s*(\d+)\s+of\s+\d+\s+tasks?\s+complete',
  ).firstMatch(profile.lessonsLine);
  final completedCount = int.tryParse(completedMatch?.group(1) ?? '') ?? 0;
  if (completedCount > 0) {
    return _profileCopyV1(context, en: 'Perfect path open', ru: 'Идеал открыт');
  }
  return _profileCopyV1(
    context,
    en: 'Clean progress started',
    ru: 'Чистый прогресс начат',
  );
}

List<Act0SkillGainV1> _dedupedRecentSkillGainsV1(List<Act0SkillGainV1> gains) {
  final ordered = <String>[];
  final aggregated = <String, Act0SkillGainV1>{};
  for (final gain in gains) {
    if (!aggregated.containsKey(gain.label)) {
      ordered.add(gain.label);
      aggregated[gain.label] = gain;
      continue;
    }
    final prior = aggregated[gain.label]!;
    aggregated[gain.label] = Act0SkillGainV1(
      label: prior.label,
      gain: prior.gain + gain.gain,
      source: prior.source,
    );
  }
  return ordered.map((label) => aggregated[label]!).toList(growable: false);
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: tone.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: tone,
          letterSpacing: 0.05,
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
    final ctaLabel = profile.recommendedFocusCtaLabel.isNotEmpty
        ? profile.recommendedFocusCtaLabel
        : _profileCopyV1(context, en: 'View progress', ru: 'Смотреть прогресс');
    final card = Container(
      key: const Key('act0_shell_profile_recommended_focus'),
      padding: const EdgeInsets.all(13),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface3.withOpacity(0.82),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(
                color: Act0ShellTokensV1.primary.withOpacity(0.16),
              ),
            ),
            child: Text(
              ctaLabel,
              key: const Key('act0_shell_profile_recommended_focus_cta_label'),
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.primary,
                letterSpacing: 0.1,
              ),
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
    final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
    visibleStats.sort((left, right) {
      final leftGain = recentGains.any((gain) => gain.label == left.label)
          ? 1
          : 0;
      final rightGain = recentGains.any((gain) => gain.label == right.label)
          ? 1
          : 0;
      if (leftGain != rightGain) {
        return rightGain.compareTo(leftGain);
      }
      return right.value.compareTo(left.value);
    });
    final recentGainByLabel = <String, Act0SkillGainV1>{
      for (final gain in recentGains) gain.label: gain,
    };
    final inlineStats = visibleStats.take(2).toList(growable: false);
    final hasMoreStats = visibleStats.length > inlineStats.length;
    return Container(
      key: const Key('act0_shell_profile_skill_stats'),
      padding: const EdgeInsets.all(12),
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
                  ? 'Keep the key parts of your game in view without turning this into a report.'
                  : 'Keep the sharpest skill signals in view. Open the full list when you want the deeper read.',
              ru: profile.recentSkillGains.isEmpty
                  ? 'Главные части твоей игры остаются на виду, но экран не превращается в отчёт.'
                  : 'Здесь видны самые живые сигналы навыков. Полный список можно открыть отдельно.',
            ),
            style: Act0ShellTokensV1.muted,
          ),
          if (recentGains.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.gold.withOpacity(0.06),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                border: Border.all(
                  color: Act0ShellTokensV1.gold.withOpacity(0.12),
                ),
              ),
              child: Text(
                '${_profileCopyV1(context, en: 'Recent progress', ru: 'Последние приросты')} · ${recentGains.take(2).map((gain) => '${gain.label} +${gain.gain}').join('  ·  ')}',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.gold,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Column(
            children: [
              for (final stat in inlineStats) ...[
                _ProfileSkillSummaryTileV1(
                  stat: stat,
                  gain: recentGainByLabel[stat.label],
                ),
                if (stat != inlineStats.last)
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
              ],
            ],
          ),
          if (hasMoreStats) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const Key('act0_shell_profile_skills_button'),
                onPressed: () => _showAllSkillsSheet(
                  context,
                  visibleStats,
                  recentGainByLabel,
                ),
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
                    en: 'View all skills',
                    ru: 'Все навыки',
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

class _ProfileConsistencyCardV1 extends StatelessWidget {
  const _ProfileConsistencyCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final hasStreak = profile.streakLine.isNotEmpty;
    final streakLine = hasStreak
        ? profile.streakLine
        : _profileCopyV1(context, en: 'No streak yet', ru: 'Серии пока нет');
    final support = _profilePrimaryConsistencyLineV1(
      context,
      profile,
      hasStreak,
    );
    return Container(
      key: const Key('act0_shell_profile_streak_nudge'),
      padding: const EdgeInsets.all(12),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface3.withOpacity(0.78),
        borderColor: Act0ShellTokensV1.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _profileCopyV1(
                    context,
                    atomId: 'profile_consistency_label',
                    fallback: 'Rhythm',
                  ),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.primary,
                  ),
                ),
              ),
              Container(
                key: const Key('act0_shell_profile_consistency_active_days'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface2.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.border.withOpacity(0.88),
                  ),
                ),
                child: Text(
                  _isRuLocaleV1(context)
                      ? '${profile.consistencyActiveDays} активных дней'
                      : '${profile.consistencyActiveDays} active days',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Row(
            children: [
              Container(
                key: const Key('act0_shell_profile_streak_icon'),
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusXs,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.gold.withOpacity(0.26),
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 14,
                  color: Act0ShellTokensV1.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(streakLine, style: Act0ShellTokensV1.cardTitle),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            support,
            key: const Key('act0_shell_profile_consistency_support_text'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted,
          ),
          const KeyedSubtree(
            key: Key('act0_shell_profile_momentum_line'),
            child: SizedBox.shrink(
              key: Key('act0_shell_profile_momentum_text'),
            ),
          ),
          if (profile.streakLast7.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Row(
              children: [
                Expanded(
                  child: _CompactStreakStripV1(days: profile.streakLast7),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                OutlinedButton(
                  key: const Key('act0_shell_profile_rhythm_week_button'),
                  onPressed: () => _showRhythmWeekSheet(context, profile),
                  style: Act0ShellTokensV1.quietButtonStyle().copyWith(
                    minimumSize: const WidgetStatePropertyAll(
                      Size(0, Act0ShellTokensV1.compactCtaHeight),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  child: Text(
                    _profileCopyV1(context, en: 'View week', ru: 'Неделя'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _profilePrimaryConsistencyLineV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
  bool hasStreak,
) {
  if (!hasStreak) {
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
    return _profileCopyV1(
      context,
      en: 'Seven clean returns in a row means the rhythm is becoming part of your game.',
      ru: 'Семь чистых возвращений подряд значит, что ритм уже становится частью твоей игры.',
    );
  }
  if (profile.streakDays >= 3) {
    return _profileCopyV1(
      context,
      en: 'Consistency is turning into feel.',
      ru: 'Постоянство уже начинает превращаться в ощущение.',
    );
  }
  if (profile.mistakesFixedLine.isNotEmpty) {
    return _profileCopyV1(
      context,
      en: '${profile.mistakesFixedLine}. Clean review work is part of the climb.',
      ru: '${profile.mistakesFixedLine}. Чистая работа над ошибками тоже часть подъёма.',
    );
  }
  if (profile.worldsClearedCount > 0) {
    return _profileSurfaceAtomByIdV1(
      context,
      'profile_support_worlds_cleared',
      'Consistency is already turning into something real. Keep the momentum alive.',
    );
  }
  return _profileSurfaceAtomByIdV1(
    context,
    'profile_support_default',
    'Keep the rhythm alive. One short clean rep keeps the feel warm.',
  );
}

String _profileSurfaceAtomByIdV1(
  BuildContext context,
  String atomId,
  String fallback,
) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

class _ProfileMilestonesCardV1 extends StatelessWidget {
  const _ProfileMilestonesCardV1({required this.profile});

  final Act0ProfileStateV1 profile;

  @override
  Widget build(BuildContext context) {
    final featured = profile.achievements.take(2).toList();
    return Container(
      key: const Key('act0_shell_profile_milestones'),
      padding: const EdgeInsets.all(12),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface3.withOpacity(0.78),
        borderColor: Act0ShellTokensV1.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _profileCopyV1(context, en: 'Milestones', ru: 'Рубежи'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
            ),
          ),
          const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
    final compact = MediaQuery.sizeOf(context).width < 420;
    final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
    final showStrength =
        recentGains.isNotEmpty || profile.strongCategories.isNotEmpty;
    final showFixed = profile.mistakesFixedLine.trim().isNotEmpty;
    final showReturnValue =
        profile.streakLine.trim().isNotEmpty ||
        profile.qualityLine.trim().isNotEmpty;
    final primaryGain = recentGains.isNotEmpty ? recentGains.first : null;
    final supportRow = _profileRecentSupportRowV1(
      context,
      profile,
      compact: compact,
      showReturnValue: showReturnValue,
      showStrength: showStrength,
      showFixed: showFixed,
    );
    return Container(
      key: const Key('act0_shell_profile_recent_skill_gains'),
      padding: EdgeInsets.all(
        compact ? Act0ShellTokensV1.gapMd : Act0ShellTokensV1.gapLg,
      ),
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
              en: 'Recent progress',
              ru: 'Последний прогресс',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            compact
                ? _profileRecentProgressSummaryV1(context, profile)
                : _profileCopyV1(
                    context,
                    en: 'See what improved, what is getting stronger, and why the next session starts warmer.',
                    ru: 'Здесь видно, что улучшилось, что укрепляется и почему следующий заход начнётся теплее.',
                  ),
            key: compact
                ? const Key('act0_shell_profile_recent_progress_summary')
                : null,
            style: Act0ShellTokensV1.muted,
          ),
          SizedBox(
            height: compact ? Act0ShellTokensV1.gapSm : Act0ShellTokensV1.gapMd,
          ),
          if (primaryGain != null) ...[
            _ProfilePayoffRowV1(
              label: _profileCopyV1(context, en: 'Improved', ru: 'Улучшилось'),
              title: '${primaryGain.label} +${primaryGain.gain}',
              body: _profileGainPayoffBodyV1(context, primaryGain),
              tone: Act0ShellTokensV1.info,
              compact: compact,
            ),
            if (supportRow != null)
              SizedBox(
                height: compact
                    ? Act0ShellTokensV1.gapSm
                    : Act0ShellTokensV1.gapMd,
              ),
          ],
          if (supportRow != null) supportRow,
        ],
      ),
    );
  }
}

Widget? _profileRecentSupportRowV1(
  BuildContext context,
  Act0ProfileStateV1 profile, {
  required bool compact,
  required bool showReturnValue,
  required bool showStrength,
  required bool showFixed,
}) {
  if (showReturnValue) {
    return _ProfilePayoffRowV1(
      label: _profileCopyV1(context, en: 'Return value', ru: 'Зачем вернуться'),
      title: _profileReturnValueTitleV1(context, profile),
      body: _profileReturnValueBodyV1(context, profile),
      tone: Act0ShellTokensV1.gold,
      compact: compact,
    );
  }
  if (showStrength) {
    return _ProfilePayoffRowV1(
      label: _profileCopyV1(
        context,
        en: 'Getting stronger',
        ru: 'Становится сильнее',
      ),
      title: _profileStrengthPayoffTitleV1(context, profile),
      body: _profileStrengthPayoffBodyV1(context, profile),
      tone: Act0ShellTokensV1.primary,
      compact: compact,
    );
  }
  if (showFixed) {
    return _ProfilePayoffRowV1(
      label: _profileCopyV1(context, en: 'Fixed', ru: 'Закрепилось'),
      title: profile.mistakesFixedLine,
      body: _profileFixedSupportBodyV1(context, profile.mistakesFixedLine),
      tone: Act0ShellTokensV1.primary,
      compact: compact,
    );
  }
  return null;
}

String _profileRecentProgressSummaryV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
  if (recentGains.isNotEmpty) {
    return _profileCopyV1(
      context,
      en: '${recentGains.first.label} is starting to hold.',
      ru: '${recentGains.first.label} начинает закрепляться.',
    );
  }
  if (profile.mistakesFixedLine.trim().isNotEmpty) {
    return _profileCopyV1(
      context,
      en: 'One repaired spot is back under control.',
      ru: 'Один исправленный спот снова под контролем.',
    );
  }
  return _profileCopyV1(
    context,
    en: 'Recent clean reps are keeping the skill live.',
    ru: 'Недавние чистые повторы держат навык живым.',
  );
}

String _profileGainPayoffBodyV1(BuildContext context, Act0SkillGainV1 gain) {
  final source = gain.source.trim();
  if (source.isNotEmpty) {
    return _profileCopyV1(
      context,
      en: '${gain.label} is starting to show up more naturally in $source.',
      ru: '${gain.label} начинает естественнее проявляться в $source.',
    );
  }
  return _profileSkillInsightBodyV1(context, gain.label);
}

String _profileFixedSupportBodyV1(BuildContext context, String fixedLine) {
  if (fixedLine.startsWith('1 ') || fixedLine.startsWith('1\u00A0')) {
    return _profileCopyV1(
      context,
      en: 'That repaired spot is back under control.',
      ru: 'Этот спот снова под контролем.',
    );
  }
  return _profileCopyV1(
    context,
    en: 'Those repaired spots are back under control.',
    ru: 'Эти споты снова под контролем.',
  );
}

String _profileReturnValueTitleV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  if (profile.streakLine.trim().isNotEmpty) {
    return profile.streakLine;
  }
  if (profile.qualityLine.trim().isNotEmpty) {
    return profile.qualityLine;
  }
  return _profileCopyV1(
    context,
    en: 'One clean return still matters.',
    ru: 'Один чистый возврат всё ещё важен.',
  );
}

String _profileReturnValueBodyV1(
  BuildContext context,
  Act0ProfileStateV1 profile,
) {
  final recentGains = _dedupedRecentSkillGainsV1(profile.recentSkillGains);
  final hasKeptSharpSignal =
      profile.qualityLine.trim().isNotEmpty || recentGains.isNotEmpty;
  final hasFixedSignal = profile.mistakesFixedLine.trim().isNotEmpty;
  if (profile.streakDays >= 3) {
    return _profileCopyV1(
      context,
      en: hasKeptSharpSignal
          ? hasFixedSignal
                ? 'Returning tomorrow starts warmer because recent clean reps kept this skill live, that repaired spot stayed under control, and the next close decision should feel clearer.'
                : 'Returning tomorrow starts warmer because recent clean reps already kept this skill live and the next close decision should feel clearer.'
          : 'Returning tomorrow starts warmer because your rhythm is already live.',
      ru: hasKeptSharpSignal
          ? hasFixedSignal
                ? 'Вернуться завтра будет проще, потому что недавние чистые повторы удержали этот навык живым, исправленный спот остался под контролем, а следующее близкое решение должно читаться яснее.'
                : 'Вернуться завтра будет проще, потому что недавние чистые повторы уже удержали этот навык живым, а следующее близкое решение должно читаться яснее.'
          : 'Вернуться завтра будет проще, потому что ритм уже живой.',
    );
  }
  if (profile.streakLine.trim().isNotEmpty) {
    return _profileCopyV1(
      context,
      en: hasKeptSharpSignal
          ? 'One more clean return keeps this skill feeling familiar, so the next close decision does not feel far away again.'
          : 'One more clean return turns repetition into feel.',
      ru: hasKeptSharpSignal
          ? 'Ещё одно чистое возвращение удержит этот навык знакомым, чтобы следующее близкое решение снова не казалось далёким.'
          : 'Ещё одно чистое возвращение превращает повторение в ощущение.',
    );
  }
  return _profileCopyV1(
    context,
    en: 'A short return tomorrow keeps today from fading back into noise.',
    ru: 'Короткое возвращение завтра не даст сегодняшнему дню снова раствориться в шуме.',
  );
}

class _ProfilePayoffRowV1 extends StatelessWidget {
  const _ProfilePayoffRowV1({
    required this.label,
    required this.title,
    required this.body,
    required this.tone,
    this.compact = false,
  });

  final String label;
  final String title;
  final String body;
  final Color tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        compact ? Act0ShellTokensV1.gapSm : Act0ShellTokensV1.gapMd,
      ),
      decoration: BoxDecoration(
        color: tone.withOpacity(compact ? 0.035 : 0.06),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: tone.withOpacity(compact ? 0.10 : 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label.copyWith(color: tone)),
          SizedBox(height: compact ? 3 : Act0ShellTokensV1.gapXs),
          Text(
            title,
            style: Act0ShellTokensV1.body.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: compact ? 2 : 3),
          Text(
            body,
            style: Act0ShellTokensV1.muted,
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
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
      en: 'Recent reps are turning into steadier reads, clearer growth, and one calm next step.',
      ru: 'Недавние повторы превращаются в более устойчивые чтения, более ясный рост и один спокойный следующий шаг.',
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(color: color),
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.body.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
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
            ? _profileCopyV1(context, en: 'Streak', ru: 'Серия')
            : _profileCopyV1(context, en: 'Activity', ru: 'Активность'),
        value: profile.streakLine.isNotEmpty
            ? profile.streakLine
            : profile.level,
        support: '',
      ),
      (
        label: _profileCopyV1(context, en: 'Tasks', ru: 'Задания'),
        value: profile.lessonsLine,
        support: profile.mistakesFixedLine,
      ),
      (label: 'XP', value: profile.xpLine, support: ''),
      (
        label: _profileCopyV1(context, en: 'Accuracy', ru: 'Точность'),
        value: profile.accuracyLine,
        support: '',
      ),
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
            _profileCopyV1(
              context,
              en: 'World progress',
              ru: 'Прогресс по мирам',
            ),
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

  @override
  Widget build(BuildContext context) {
    final dayLabels = _isRuLocaleV1(context)
        ? const <String>['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
        : const <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      key: const Key('act0_shell_profile_streak_calendar'),
      padding: const EdgeInsets.all(13),
      decoration: Act0ShellTokensV1.surfaceDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _StreakDayCellV1(index: i, label: dayLabels[i], active: days[i]),
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
    final isToday = index == 6;
    final borderColor = isToday
        ? Act0ShellTokensV1.gold.withOpacity(0.72)
        : active
        ? Act0ShellTokensV1.primary.withOpacity(0.38)
        : Act0ShellTokensV1.border.withOpacity(0.92);
    return Column(
      children: [
        Container(
          key: Key('act0_shell_profile_streak_day_$index'),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withOpacity(0.94),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
            border: Border.all(color: borderColor, width: isToday ? 1.4 : 1),
            boxShadow: active
                ? <BoxShadow>[
                    BoxShadow(
                      color: Act0ShellTokensV1.primary.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: active ? 18 : 12,
                height: active ? 18 : 12,
                decoration: BoxDecoration(
                  gradient: active
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Act0ShellTokensV1.primary.withOpacity(0.98),
                            Act0ShellTokensV1.primary.withOpacity(0.74),
                          ],
                        )
                      : null,
                  color: active
                      ? null
                      : Act0ShellTokensV1.surface3.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(
                    active
                        ? Act0ShellTokensV1.radiusXs
                        : Act0ShellTokensV1.radius2xs,
                  ),
                  border: Border.all(
                    color: active
                        ? Act0ShellTokensV1.primary.withOpacity(0.22)
                        : Act0ShellTokensV1.border.withOpacity(0.72),
                  ),
                ),
              ),
              if (isToday)
                Container(
                  key: const Key('act0_shell_profile_streak_today_ring'),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusSm,
                    ),
                    border: Border.all(
                      color: active
                          ? Colors.white.withOpacity(0.84)
                          : Act0ShellTokensV1.gold.withOpacity(0.58),
                      width: 1.1,
                    ),
                  ),
                ),
            ],
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
        constraints: const BoxConstraints(minHeight: 74),
        padding: const EdgeInsets.all(8),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          color: Act0ShellTokensV1.surface3.withOpacity(0.72),
          borderColor: stat.locked
              ? Act0ShellTokensV1.border
              : tone.withOpacity(gain == null ? 0.10 : 0.16),
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
                      Text(
                        stat.locked
                            ? _profileCopyV1(context, en: 'Later', ru: 'Позже')
                            : stat.levelLabel,
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
                      color: Act0ShellTokensV1.gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.gold.withOpacity(0.16),
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
                    color: Act0ShellTokensV1.textMuted.withOpacity(0.82),
                  ),
              ],
            ),
            const SizedBox(height: 5),
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

class _ProfileSkillSummaryTileV1 extends StatelessWidget {
  const _ProfileSkillSummaryTileV1({required this.stat, this.gain});

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
        padding: const EdgeInsets.symmetric(
          horizontal: Act0ShellTokensV1.gapMd,
          vertical: Act0ShellTokensV1.gapSm,
        ),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          color: Act0ShellTokensV1.surface3.withOpacity(0.54),
          borderColor: stat.locked
              ? Act0ShellTokensV1.border
              : tone.withOpacity(gain == null ? 0.10 : 0.16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat.label, style: Act0ShellTokensV1.body),
                  const SizedBox(height: 2),
                  Text(
                    stat.locked
                        ? _profileCopyV1(context, en: 'Later', ru: 'Позже')
                        : stat.levelLabel,
                    style: Act0ShellTokensV1.label.copyWith(color: tone),
                  ),
                ],
              ),
            ),
            if (gain != null) ...[
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.gold.withOpacity(0.16),
                  ),
                ),
                child: Text(
                  '+${gain!.gain}',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.gold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactStreakStripV1 extends StatelessWidget {
  const _CompactStreakStripV1({required this.days});

  final List<bool> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_profile_rhythm_strip'),
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapSm,
        vertical: 10,
      ),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.58),
        borderColor: Act0ShellTokensV1.border.withOpacity(0.82),
      ),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            Expanded(
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: days[i]
                      ? Act0ShellTokensV1.primary.withOpacity(0.86)
                      : Act0ShellTokensV1.surface3.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radius2xs,
                  ),
                  border: i == days.length - 1
                      ? Border.all(
                          color: Act0ShellTokensV1.gold.withOpacity(0.62),
                        )
                      : null,
                ),
              ),
            ),
            if (i != days.length - 1)
              const SizedBox(width: Act0ShellTokensV1.gapXs),
          ],
        ],
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
              Text(
                _profileCopyV1(
                  context,
                  en: 'Badge collection',
                  ru: 'Коллекция бейджей',
                ),
                style: Act0ShellTokensV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                _profileCopyV1(
                  context,
                  en: 'Proof from streaks, repairs, clean drills, and steady return.',
                  ru: 'Доказательства из серий, исправлений, чистых дриллов и стабильных возвращений.',
                ),
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

void _showAllSkillsSheet(
  BuildContext context,
  List<Act0PlacementSkillStatV1> stats,
  Map<String, Act0SkillGainV1> recentGainByLabel,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Container(
          key: const Key('act0_shell_profile_skills_sheet'),
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
              Text(
                _profileCopyV1(
                  context,
                  en: 'Skill details',
                  ru: 'Навыки подробно',
                ),
                style: Act0ShellTokensV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                _profileCopyV1(
                  context,
                  en: 'All tracked skill families stay here when you want the full picture.',
                  ru: 'Все отслеживаемые семьи навыков остаются здесь, когда нужен полный обзор.',
                ),
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Flexible(
                child: SingleChildScrollView(
                  child: _TwoColumnStaggeredGridV1(
                    children: [
                      for (final stat in stats)
                        _ProfileSkillCardV1(
                          stat: stat,
                          gain: recentGainByLabel[stat.label],
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
                        ? _profileCopyV1(context, en: 'Later', ru: 'Позже')
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
              _SkillDetailBlockV1(
                title: _profileCopyV1(
                  context,
                  en: 'What it means',
                  ru: 'Что это значит',
                ),
                text: stat.meaning,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _SkillDetailBlockV1(
                title: _profileCopyV1(
                  context,
                  en: 'What it affects',
                  ru: 'На что это влияет',
                ),
                text: stat.affects,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _SkillDetailBlockV1(
                title: _profileCopyV1(
                  context,
                  en: 'Why it matters',
                  ru: 'Почему это важно',
                ),
                text: stat.whyImportant,
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showRhythmWeekSheet(BuildContext context, Act0ProfileStateV1 profile) {
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
              Text(
                _profileCopyV1(context, en: 'Weekly rhythm', ru: 'Ритм недели'),
                style: Act0ShellTokensV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                _profileCopyV1(
                  context,
                  en: 'Keep the week visible without letting it take over the whole screen.',
                  ru: 'Неделя остаётся видимой, но не забирает на себя весь экран.',
                ),
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _StreakCalendarV1(days: profile.streakLast7),
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
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          color: Act0ShellTokensV1.surface3.withOpacity(0.76),
          borderColor: locked
              ? Act0ShellTokensV1.border
              : Act0ShellTokensV1.gold.withOpacity(0.28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color:
                        (locked
                                ? Act0ShellTokensV1.textDim
                                : Act0ShellTokensV1.gold)
                            .withOpacity(0.14),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusMd,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: locked
                        ? Act0ShellTokensV1.textDim
                        : Act0ShellTokensV1.gold,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showFirstStartToolsSheetV1(
  BuildContext context, {
  required VoidCallback onRetakePlacement,
  required VoidCallback? onReplayWelcome,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          key: const Key('act0_shell_profile_first_start_tools'),
          margin: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          padding: const EdgeInsets.all(13),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface,
            borderColor: Act0ShellTokensV1.border,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReplayWelcome();
                      },
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetakePlacement();
                    },
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
        ),
      );
    },
  );
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
