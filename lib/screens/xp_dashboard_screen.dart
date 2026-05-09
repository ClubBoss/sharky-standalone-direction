import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/session_log_service.dart';
import '../services/streak_tracker_service.dart';
import '../services/xp_history_service.dart';

/// A minimal XP Dashboard screen displaying recent XP award events.
///
/// Fetches from XpHistoryService and shows:
/// - Event type icon and label
/// - XP amount (e.g., "+5 XP")
/// - Formatted timestamp (e.g., "Today 14:35")
///
/// Shows empty state if no history exists.
class XpDashboardScreen extends StatelessWidget {
  XpDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.xpDashboardTitle), elevation: 2),
      body: FutureBuilder<List<XpEvent>>(
        future: XpHistoryService().getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: events.length + 2, // +2 for streak and trends summary
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _StreakOverviewCard();
              }
              if (index == 1) {
                return _XpTrendsSummary(events: events);
              }
              final event = events[index - 2];
              return _XpEventCard(event: event);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.xpDashboardEmptyTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.xpDashboardEmptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// Streak overview card showing current and best streaks with 30-day calendar.
class _StreakOverviewCard extends StatefulWidget {
  const _StreakOverviewCard();

  @override
  State<_StreakOverviewCard> createState() => _StreakOverviewCardState();
}

class _StreakOverviewCardState extends State<_StreakOverviewCard> {
  int _currentStreak = 0;
  int _bestStreak = 0;
  Map<DateTime, bool> _last30Days = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final tracker = StreakTrackerService.instance;
    final stats = await tracker.compute();
    final days = await _buildLast30DaysMap();

    if (!mounted) return;

    setState(() {
      _currentStreak = stats.currentStreak;
      _bestStreak = stats.longestStreak;
      _last30Days = days;
      _isLoading = false;
    });
  }

  Future<Map<DateTime, bool>> _buildLast30DaysMap() async {
    final logs = await SessionLogService.instance.getLogs();
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final start = todayNormalized.subtract(const Duration(days: 29));
    final map = <DateTime, bool>{};
    for (var i = 0; i < 30; i++) {
      final day = start.add(Duration(days: i));
      map[DateTime(day.year, day.month, day.day)] = false;
    }
    for (final log in logs) {
      final day = DateTime(
        log.startTime.year,
        log.startTime.month,
        log.startTime.day,
      );
      if (!day.isBefore(start) && !day.isAfter(todayNormalized)) {
        map[day] = true;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.xpDashboardStreakTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: l10n.xpDashboardStreakTooltip,
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStreakStat(
                    icon: Icons.local_fire_department,
                    color: _currentStreak > 0 ? Colors.orange : Colors.grey,
                    label: l10n.xpDashboardCurrentStreakLabel,
                    value: _currentStreak > 0
                        ? l10n.xpDaysCount(_currentStreak)
                        : l10n.xpDashboardNoStreak,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStreakStat(
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                    label: l10n.xpDashboardBestStreakLabel,
                    value: l10n.xpDaysCount(_bestStreak),
                  ),
                ),
              ],
            ),
            if (_last30Days.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                l10n.xpDashboardLast30Days,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _build30DayCalendar(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) => Column(
    children: [
      Icon(icon, color: color, size: 32),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 2),
      Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );

  Widget _build30DayCalendar(AppLocalizations l10n) {
    final sortedDays = _last30Days.keys.toList()..sort();
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final locale = l10n.localeName;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final isActive = _last30Days[day] ?? false;
        final isToday = day == todayNormalized;

        return Tooltip(
          message: DateFormat('MMM d', locale).format(day),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green[500] : Colors.transparent,
              border: Border.all(
                color: isToday
                    ? Colors.blue[700]!
                    : (isActive ? Colors.green[500]! : Colors.grey[400]!),
                width: isToday ? 2 : 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Summary card displaying XP trends over the last 7 days.
class _XpTrendsSummary extends StatelessWidget {
  final List<XpEvent> events;

  const _XpTrendsSummary({required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Filter events from last 7 days
    final recentEvents = events
        .where((e) => e.timestamp.isAfter(sevenDaysAgo))
        .toList();

    // Calculate totals by type
    int totalXp = 0;
    int drillXp = 0;
    int moduleXp = 0;
    int theoryXp = 0;

    for (final event in recentEvents) {
      totalXp += event.amount;
      switch (event.type) {
        case 'drill_completed':
          drillXp += event.amount;
          break;
        case 'module_completed':
          moduleXp += event.amount;
          break;
        case 'theory_view':
          theoryXp += event.amount;
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.xpDashboardTrendsTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildTrendRow(
              icon: Icons.emoji_events,
              color: Colors.amber,
              label: l10n.xpDashboardTotalXpLabel,
              value: '+$totalXp XP',
            ),
            const SizedBox(height: 8),
            _buildTrendRow(
              icon: Icons.fitness_center,
              color: Colors.blue,
              label: l10n.xpDashboardDrillsLabel,
              value: '+$drillXp XP',
            ),
            const SizedBox(height: 8),
            _buildTrendRow(
              icon: Icons.emoji_events,
              color: Colors.amber,
              label: l10n.xpDashboardModulesLabel,
              value: '+$moduleXp XP',
            ),
            const SizedBox(height: 8),
            _buildTrendRow(
              icon: Icons.menu_book,
              color: Colors.purple,
              label: l10n.xpDashboardTheoryLabel,
              value: '+$theoryXp XP',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) => Row(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
      ),
    ],
  );
}

/// Card widget displaying a single XP event.
class _XpEventCard extends StatelessWidget {
  final XpEvent event;

  const _XpEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventInfo = _getEventInfo(l10n, event.type);
    final formattedTime = _formatTimestamp(context, event.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: eventInfo.color.withValues(alpha: 0.1),
          child: Icon(eventInfo.icon, color: eventInfo.color, size: 24),
        ),
        title: Row(
          children: [
            Text(
              eventInfo.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '+${event.amount} XP',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          formattedTime,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.star, color: Colors.amber, size: 20),
      ),
    );
  }

  _EventInfo _getEventInfo(AppLocalizations l10n, String type) {
    switch (type) {
      case 'drill_completed':
        return _EventInfo(
          label: l10n.xpEventDrillCompleted,
          icon: Icons.fitness_center,
          color: Colors.blue,
        );
      case 'module_completed':
        return _EventInfo(
          label: l10n.xpEventModuleCompleted,
          icon: Icons.emoji_events,
          color: Colors.amber,
        );
      case 'theory_view':
        return _EventInfo(
          label: l10n.xpEventTheoryViewed,
          icon: Icons.menu_book,
          color: Colors.purple,
        );
      default:
        return _EventInfo(
          label: l10n.xpEventGeneric,
          icon: Icons.star,
          color: Colors.grey,
        );
    }
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final timeStr = DateFormat.Hm(locale).format(timestamp);

    if (eventDate == today) {
      return l10n.xpRelativeTodayAt(timeStr);
    } else if (eventDate == yesterday) {
      return l10n.xpRelativeYesterdayAt(timeStr);
    } else if (now.difference(timestamp).inDays < 7) {
      final weekday = DateFormat('EEEE', locale).format(timestamp);
      return l10n.xpRelativeWeekdayAt(weekday, timeStr);
    } else {
      final datePart = DateFormat.yMMMd(locale).format(timestamp);
      return l10n.xpRelativeDateTime(datePart, timeStr);
    }
  }
}

/// Helper class to organize event display information.
class _EventInfo {
  final String label;
  final IconData icon;
  final Color color;

  _EventInfo({required this.label, required this.icon, required this.color});
}
