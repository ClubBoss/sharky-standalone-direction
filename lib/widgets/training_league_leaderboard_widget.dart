import 'package:flutter/material.dart';

import '../models/league_tier_badge.dart';
import '../models/training_league_member.dart';

/// Displays the training league leaderboard in a card layout.
class TrainingLeagueLeaderboardWidget extends StatelessWidget {
  final List<TrainingLeagueMember> members;

  const TrainingLeagueLeaderboardWidget({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.heading,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...members.map(
              (member) => _LeaderboardRow(
                member: member,
                strings: strings,
                locale: locale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final TrainingLeagueMember member;
  final _LocalizedStrings strings;
  final String locale;

  const _LeaderboardRow({
    required this.member,
    required this.strings,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.secondary.withValues(alpha: 0.12);
    final badge = LeagueTierBadge.resolve(xp: member.xp);
    final badgeLabel = badge.label(locale);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: member.isMe ? selectedColor : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minLeadingWidth: 72,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: badgeLabel,
              child: Semantics(
                label: badgeLabel,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: badge.color.withValues(alpha: 0.18),
                  child: Text(
                    badge.emoji,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _RankPill(rank: member.rank),
          ],
        ),
        title: Text(
          member.displayName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: member.isMe ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: Text(
          strings.xpValue(member.xp),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  final int rank;

  const _RankPill({required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$rank',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LocalizedStrings {
  final String heading;
  final String Function(int xp) xpValue;

  const _LocalizedStrings({required this.heading, required this.xpValue});
}

const Map<String, _LocalizedStrings> _localizedStrings = {
  'en': _LocalizedStrings(
    heading: 'League Leaderboard',
    xpValue: _xpValueDefault,
  ),
  'ru': _LocalizedStrings(heading: 'Таблица лиги', xpValue: _xpValueDefault),
};

String _xpValueDefault(int xp) => '$xp XP';
