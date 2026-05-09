import 'package:flutter/material.dart';

import '../models/xp_leaderboard_entry.dart' as xp;
import '../models/xp_league.dart';
import '../services/xp_leaderboard_service.dart';

class XpLeaderboardWidget extends StatelessWidget {
  final List<xp.LeaderboardEntry>? entries;

  const XpLeaderboardWidget({super.key, this.entries});

  static const _localizedLabels = {
    'leaderboard': {'en': 'Leaderboard', 'ru': 'Таблица лидеров'},
    'xp': {'en': 'XP', 'ru': 'XP'},
    'you': {'en': 'You', 'ru': 'Вы'},
  };

  String _label(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    return _localizedLabels[key]?[lang] ?? _localizedLabels[key]?['en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedEntries = entries ?? XpLeaderboardService.fetchTop5();
    if (resolvedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final xpLabel = _label(context, 'xp');
    final youLabel = _label(context, 'you');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _label(context, 'leaderboard'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                xpLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...resolvedEntries.map(
              (entry) => _LeaderboardRow(
                entry: entry,
                xpLabel: xpLabel,
                youLabel: youLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final xp.LeaderboardEntry entry;
  final String xpLabel;
  final String youLabel;

  const _LeaderboardRow({
    required this.entry,
    required this.xpLabel,
    required this.youLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: entry.isMe ? FontWeight.bold : FontWeight.w500,
    );

    final baseName = entry.isMe ? youLabel : entry.displayName;
    final emoji = entry.xp > 0 ? XpLeagueExt.fromXp(entry.xp).emoji() : null;
    final name = emoji == null ? baseName : '$emoji $baseName';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('#${entry.rank}', style: textStyle),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: textStyle)),
          Text('${entry.xp} $xpLabel', style: textStyle),
        ],
      ),
    );
  }
}
