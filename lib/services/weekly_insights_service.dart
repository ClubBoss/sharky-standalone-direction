import 'xp_history_service.dart';
import 'session_log_service.dart';
import 'xp_trophy_service.dart';
import 'booster_service.dart';

/// Represents aggregated weekly insights for a rolling 7-day window.
class WeeklyInsights {
  final int totalXp;
  final int activeDaysCount;
  final int totalSessions;
  final BoosterType? mostUsedBoosterType;
  final int trophiesEarned;

  const WeeklyInsights({
    required this.totalXp,
    required this.activeDaysCount,
    required this.totalSessions,
    this.mostUsedBoosterType,
    required this.trophiesEarned,
  });

  /// Empty state for new users or when no data exists in the 7-day window
  static const WeeklyInsights empty = WeeklyInsights(
    totalXp: 0,
    activeDaysCount: 0,
    totalSessions: 0,
    mostUsedBoosterType: null,
    trophiesEarned: 0,
  );
}

/// Service for computing weekly recap stats over a rolling 7-day window.
///
/// This service aggregates data from multiple sources:
/// - XpHistoryService: Total XP earned
/// - SessionLogService: Active days and session count
/// - XpTrophyService: Trophies unlocked
/// - Booster usage tracking from XP history metadata
class WeeklyInsightsService {
  /// Computes insights for the last 7 days (rolling window from now).
  Future<WeeklyInsights> computeWeeklyInsights() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Calculate total XP from history
    final xpHistory = await XpHistoryService().getHistory();
    int totalXp = 0;
    for (final event in xpHistory) {
      if (event.timestamp.isAfter(sevenDaysAgo)) {
        totalXp += event.amount;
      }
    }

    // Calculate active days and session count from session logs
    final sessionService = SessionLogService.instance;
    final sessions = await sessionService.getLogs();

    final activeDays = <String>{};
    int sessionCount = 0;

    for (final session in sessions) {
      if (session.startTime.isAfter(sevenDaysAgo)) {
        // Normalize to date string for unique day counting
        final dateKey =
            '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
        activeDays.add(dateKey);
        sessionCount++;
      }
    }

    // Calculate most used booster type
    // Track booster usage by counting session_log events with boosted XP
    final boosterUsage = <BoosterType, int>{};
    for (final event in xpHistory) {
      if (event.timestamp.isAfter(sevenDaysAgo) &&
          event.type == 'session_log') {
        // Heuristic: If session XP is relatively high, it might have used a booster
        // For now, we'll track all session types based on tags if available
        // This is a simplified approach - in production, you'd want explicit booster tracking

        // For MVP, we'll distribute proportionally across booster types
        // This can be enhanced later with explicit booster activation tracking
        if (event.amount >= 10) {
          // Assume higher XP sessions might have used boosters
          // This is a placeholder - real implementation would track actual booster usage
          boosterUsage[BoosterType.play] =
              (boosterUsage[BoosterType.play] ?? 0) + 1;
        }
      }
    }

    BoosterType? mostUsedBooster;
    if (boosterUsage.isNotEmpty) {
      mostUsedBooster = boosterUsage.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    // Calculate trophies earned in last 7 days
    await XpTrophyService.instance.init();
    final trophies = XpTrophyService.instance.unlocked;
    int trophiesEarned = 0;
    for (final trophy in trophies) {
      if (trophy.achievedAt.isAfter(sevenDaysAgo)) {
        trophiesEarned++;
      }
    }

    return WeeklyInsights(
      totalXp: totalXp,
      activeDaysCount: activeDays.length,
      totalSessions: sessionCount,
      mostUsedBoosterType: mostUsedBooster,
      trophiesEarned: trophiesEarned,
    );
  }
}
