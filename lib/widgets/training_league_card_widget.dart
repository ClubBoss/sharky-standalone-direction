import 'package:flutter/material.dart';

import '../models/league_tier_badge.dart';
import '../models/training_league_status.dart';

/// Displays the current state of the Training League MVP.
class TrainingLeagueCardWidget extends StatelessWidget {
  final TrainingLeagueStatus status;
  final VoidCallback? onViewLeaderboard;
  final LeagueTierBadge? badge;

  const TrainingLeagueCardWidget({
    super.key,
    required this.status,
    this.onViewLeaderboard,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;
    final badgeLabel = badge?.label(locale);
    final cta = _ctaConfig(strings);
    final total = status.totalMatches;

    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: cta.kind == _CtaKind.leaderboard ? onViewLeaderboard : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sports_esports_outlined,
                    color: theme.colorScheme.secondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.heading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (badge != null && badgeLabel != null) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: badgeLabel,
                      child: Semantics(
                        label: badgeLabel,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badge!.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${badge!.emoji} $badgeLabel',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: badge!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  _StatBlock(label: strings.rankLabel, value: status.rank),
                  _StatBlock(
                    label: strings.recordLabel,
                    value: strings.recordValue(status.wins, status.losses),
                  ),
                  _StatBlock(
                    label: strings.matchesLabel,
                    value: total.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (cta.kind == _CtaKind.leaderboard) {
                    onViewLeaderboard?.call();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                child: Text(cta.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CtaConfig _ctaConfig(_LocalizedStrings strings) {
    if (!status.joined) {
      return _CtaConfig(label: strings.joinNowCta, kind: _CtaKind.join);
    }
    if (status.totalMatches == 0) {
      return _CtaConfig(label: strings.playMatchCta, kind: _CtaKind.play);
    }
    return _CtaConfig(
      label: strings.viewLeaderboardCta,
      kind: _CtaKind.leaderboard,
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LocalizedStrings {
  final String heading;
  final String rankLabel;
  final String recordLabel;
  final String matchesLabel;
  final String joinNowCta;
  final String playMatchCta;
  final String viewLeaderboardCta;
  final String Function(int wins, int losses) recordValue;

  const _LocalizedStrings({
    required this.heading,
    required this.rankLabel,
    required this.recordLabel,
    required this.matchesLabel,
    required this.joinNowCta,
    required this.playMatchCta,
    required this.viewLeaderboardCta,
    required this.recordValue,
  });
}

const Map<String, _LocalizedStrings> _localizedStrings = {
  'en': _LocalizedStrings(
    heading: 'Training League',
    rankLabel: 'Rank',
    recordLabel: 'Record',
    matchesLabel: 'Matches',
    joinNowCta: 'Join Now',
    playMatchCta: 'Play Match',
    viewLeaderboardCta: 'View Leaderboard',
    recordValue: _recordValue,
  ),
  'ru': _LocalizedStrings(
    heading: 'Лига тренировки',
    rankLabel: 'Ранг',
    recordLabel: 'Результат',
    matchesLabel: 'Матчи',
    joinNowCta: 'Присоединиться',
    playMatchCta: 'Начать матч',
    viewLeaderboardCta: 'Смотреть рейтинг',
    recordValue: _recordValue,
  ),
};

enum _CtaKind { join, play, leaderboard }

class _CtaConfig {
  final String label;
  final _CtaKind kind;

  const _CtaConfig({required this.label, required this.kind});
}

String _recordValue(int wins, int losses) => '$wins-$losses';
