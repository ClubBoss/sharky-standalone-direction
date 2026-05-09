import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/xp_trophy.dart';
import '../services/xp_trophy_service.dart';

/// Displays a feed of recent achievements (trophies unlocked).
/// Shows 3-5 most recent entries from the last 30 days.
class AchievementsFeedWidget extends StatelessWidget {
  const AchievementsFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final recentAchievements = _getRecentAchievements();

    if (recentAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            isRu ? 'Недавние достижения' : 'Recent Achievements',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...recentAchievements.map((entry) => _buildFeedItem(entry, isRu)),
      ],
    );
  }

  /// Get recent achievements from the last 30 days, limit to 5.
  List<XpTrophyEntry> _getRecentAchievements() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final allTrophies = XpTrophyService.instance.unlocked.toList();

    // Filter to last 30 days
    final recent = allTrophies
        .where((entry) => entry.achievedAt.isAfter(thirtyDaysAgo))
        .toList();

    // Sort by date descending (most recent first)
    recent.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));

    // Take top 5
    return recent.take(5).toList();
  }

  /// Build a single feed item for a trophy unlock.
  Widget _buildFeedItem(XpTrophyEntry entry, bool isRu) {
    final trophy = entry.type;
    final title = trophy.title(isRu: isRu);
    final date = DateFormat('yyyy-MM-dd').format(entry.achievedAt);
    final unlockLabel = isRu ? 'Разблокировано' : 'Unlocked';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber[700], size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlockLabel: $title',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
