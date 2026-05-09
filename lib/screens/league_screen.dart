import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/league_engine.dart';

/// Weekly competitive league screen showing 50 players ranked by XP.
///
/// Features:
/// - Simulated 50-player league with promotion/demotion zones
/// - Top 10: promoted (green upward arrow)
/// - Bottom 10: demoted (red downward arrow)
/// - Current user highlighted with green border
/// - League name and weekly reset info
/// - Offline-only (client-side simulation)
class LeagueScreen extends StatelessWidget {
  final int userXp;
  final String? leagueName;

  LeagueScreen({super.key, required this.userXp, this.leagueName});

  @override
  Widget build(BuildContext context) {
    // Generate league standings using current week as seed
    final l10n = AppLocalizations.of(context)!;
    final displayLeagueName = leagueName ?? l10n.xpLeagueDefaultName;
    final weekNumber = _getCurrentWeekNumber();
    final engine = LeagueEngine();
    final standings = engine.simulateWeeklyLeague(
      userXp: userXp,
      weekSeed: weekNumber,
    );

    return Scaffold(
      appBar: AppBar(title: Text(displayLeagueName), elevation: 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, l10n, displayLeagueName, weekNumber, standings),
          const SizedBox(height: 16),
          _buildPromotionZoneHeader(l10n),
          const SizedBox(height: 8),
          ...standings.take(10).map((e) => _LeagueEntryCard(entry: e)),
          const SizedBox(height: 16),
          _buildSafeZoneHeader(l10n),
          const SizedBox(height: 8),
          ...standings.skip(10).take(30).map((e) => _LeagueEntryCard(entry: e)),
          const SizedBox(height: 16),
          _buildDemotionZoneHeader(l10n),
          const SizedBox(height: 8),
          ...standings.skip(40).map((e) => _LeagueEntryCard(entry: e)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    String displayLeagueName,
    int weekNumber,
    List<LeagueEntry> standings,
  ) {
    final userEntry = standings.firstWhere((e) => e.isUser);
    final locale = l10n.localeName;
    final nextMonday = _getNextMonday(locale);

    return Card(
      elevation: 2,
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.amber[700],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayLeagueName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.xpLeagueWeekSubtitle(weekNumber, nextMonday),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  icon: Icons.emoji_events,
                  label: l10n.xpLeagueYourRank,
                  value: '#${userEntry.rank}',
                  color: Colors.blue[700]!,
                ),
                _buildStatChip(
                  icon: Icons.star,
                  label: l10n.xpLeagueYourXp,
                  value: '${userEntry.xp}',
                  color: Colors.amber[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Column(
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );

  Widget _buildPromotionZoneHeader(AppLocalizations l10n) => Row(
    children: [
      Icon(Icons.arrow_upward, color: Colors.green[700], size: 20),
      const SizedBox(width: 8),
      Text(
        l10n.xpLeaguePromotionZone,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
      ),
    ],
  );

  Widget _buildSafeZoneHeader(AppLocalizations l10n) => Row(
    children: [
      Icon(Icons.shield, color: Colors.blue[700], size: 20),
      const SizedBox(width: 8),
      Text(
        l10n.xpLeagueSafeZone,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    ],
  );

  Widget _buildDemotionZoneHeader(AppLocalizations l10n) => Row(
    children: [
      Icon(Icons.arrow_downward, color: Colors.red[700], size: 20),
      const SizedBox(width: 8),
      Text(
        l10n.xpLeagueDemotionZone,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red[700],
        ),
      ),
    ],
  );

  int _getCurrentWeekNumber() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysSinceStart = now.difference(firstDayOfYear).inDays;
    return (daysSinceStart / 7).floor() + 1;
  }

  String _getNextMonday(String locale) {
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    final nextMonday = now.add(
      Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday),
    );
    return DateFormat('d MMM', locale).format(nextMonday);
  }
}

/// Card widget for a single league entry.
class _LeagueEntryCard extends StatelessWidget {
  final LeagueEntry entry;

  const _LeagueEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final statusIcon = _getStatusIcon();
    final statusColor = _getStatusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: entry.isUser ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: entry.isUser
            ? BorderSide(color: Colors.green[600]!, width: 2)
            : BorderSide.none,
      ),
      color: entry.isUser ? Colors.green[50] : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusIcon != null)
              Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _getRankColor().withValues(alpha: 0.2),
              radius: 20,
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.name,
                style: TextStyle(
                  fontWeight: entry.isUser ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (entry.isUser)
              Icon(Icons.person, color: Colors.green[700], size: 18),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 14),
              const SizedBox(width: 3),
              Text(
                '${entry.xp}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor() {
    if (entry.rank <= 10) {
      return Colors.green[700]!;
    } else if (entry.rank >= 41) {
      return Colors.red[700]!;
    } else {
      return Colors.blue[700]!;
    }
  }

  IconData? _getStatusIcon() {
    switch (entry.status) {
      case LeagueStatus.promoted:
        return Icons.arrow_upward;
      case LeagueStatus.demoted:
        return Icons.arrow_downward;
      case LeagueStatus.safe:
        return null;
    }
  }

  Color _getStatusColor() {
    switch (entry.status) {
      case LeagueStatus.promoted:
        return Colors.green[700]!;
      case LeagueStatus.demoted:
        return Colors.red[700]!;
      case LeagueStatus.safe:
        return Colors.blue[700]!;
    }
  }
}
