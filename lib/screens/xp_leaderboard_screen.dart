import 'package:flutter/material.dart';

/// XP Leaderboard screen showing top 10 users by XP.
///
/// Features:
/// - Static mock data (no backend)
/// - Russian labels
/// - Highlights current user if in top 10
/// - Shows current user position at bottom if not in top 10
/// - Consistent with XP UI styling (amber/green badges)
class XpLeaderboardScreen extends StatelessWidget {
  XpLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = _getMockLeaderboard();
    final currentUserEntry = leaderboard.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () =>
          _LeaderboardEntry(rank: 42, name: 'Вы', xp: 85, isCurrentUser: true),
    );
    final isCurrentUserInTop10 = currentUserEntry.rank <= 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Таблица лидеров'), elevation: 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...leaderboard
              .where((e) => e.rank <= 10)
              .map((e) => _LeaderboardCard(entry: e)),
          if (!isCurrentUserInTop10) ...[
            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Ваша позиция',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _LeaderboardCard(entry: currentUserEntry),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() => Card(
    elevation: 2,
    color: Colors.amber[50],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber[700], size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Топ-10 по XP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Зарабатывайте XP и поднимайтесь в рейтинге!',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  List<_LeaderboardEntry> _getMockLeaderboard() => [
    _LeaderboardEntry(
      rank: 1,
      name: 'Игрок 8923',
      xp: 1250,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 2,
      name: 'Игрок 4156',
      xp: 1180,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 3,
      name: 'Игрок 7742',
      xp: 1050,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 4,
      name: 'Игрок 2319',
      xp: 920,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(rank: 5, name: 'Вы', xp: 850, isCurrentUser: true),
    _LeaderboardEntry(
      rank: 6,
      name: 'Игрок 5581',
      xp: 780,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 7,
      name: 'Игрок 9204',
      xp: 720,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 8,
      name: 'Игрок 3467',
      xp: 650,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 9,
      name: 'Игрок 6138',
      xp: 580,
      isCurrentUser: false,
    ),
    _LeaderboardEntry(
      rank: 10,
      name: 'Игрок 1029',
      xp: 520,
      isCurrentUser: false,
    ),
  ];
}

/// Card widget for a single leaderboard entry.
class _LeaderboardCard extends StatelessWidget {
  final _LeaderboardEntry entry;

  const _LeaderboardCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.rank <= 3;
    final rankColor = _getRankColor(entry.rank);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: entry.isCurrentUser ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: entry.isCurrentUser
            ? BorderSide(color: Colors.green[600]!, width: 2)
            : BorderSide.none,
      ),
      color: entry.isCurrentUser ? Colors.green[50] : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: rankColor.withValues(alpha: 0.2),
          radius: 24,
          child: Text(
            '${entry.rank}',
            style: TextStyle(
              fontSize: isTopThree ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.name,
                style: TextStyle(
                  fontWeight: entry.isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (entry.isCurrentUser)
              Icon(Icons.person, color: Colors.green[700], size: 20),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 16),
              const SizedBox(width: 4),
              Text(
                '${entry.xp} XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.orange[800]!; // Bronze
      default:
        return Colors.blue[700]!; // Other ranks
    }
  }
}

/// Data model for a leaderboard entry.
class _LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isCurrentUser;

  _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isCurrentUser,
  });
}
