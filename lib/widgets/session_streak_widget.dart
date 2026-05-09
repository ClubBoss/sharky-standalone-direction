import 'package:flutter/material.dart';

import '../services/streak_tracker_service.dart';

class SessionStreakWidget extends StatelessWidget {
  final SessionStreakStats stats;

  const SessionStreakWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final streakLabel = isRu
        ? 'Серия: ${stats.currentStreak} д.'
        : '${stats.currentStreak}-day streak';
    final longestLabel = isRu
        ? 'Макс: ${stats.longestStreak} д.'
        : 'Longest: ${stats.longestStreak} days';
    final totalLabel = isRu
        ? 'Активные дни: ${stats.totalDaysActive}'
        : 'Active days: ${stats.totalDaysActive}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streakLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  longestLabel,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                Text(
                  totalLabel,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
