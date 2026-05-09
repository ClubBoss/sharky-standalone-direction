import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/streak_tracker_service.dart';
import '../services/xp_milestone_service.dart';

/// Event representing a streak milestone achievement.
class StreakEvent {
  final int days;
  final DateTime date;

  StreakEvent({required this.days, required this.date});
}

/// Event representing an XP milestone achievement.
class MilestoneEvent {
  final int value;
  final DateTime date;

  MilestoneEvent({required this.value, required this.date});
}

/// Screen displaying chronological history of streak and XP milestone achievements.
///
/// Shows two sections:
/// - Streaks: Days-long streaks achieved (e.g., "7-дневная серия")
/// - XP Milestones: XP thresholds reached (e.g., "100 XP")
class StreakMilestoneHistoryScreen extends StatefulWidget {
  StreakMilestoneHistoryScreen({super.key});

  @override
  State<StreakMilestoneHistoryScreen> createState() =>
      _StreakMilestoneHistoryScreenState();
}

class _StreakMilestoneHistoryScreenState
    extends State<StreakMilestoneHistoryScreen> {
  List<StreakEvent> _streakEvents = [];
  List<MilestoneEvent> _milestoneEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final streakService = StreakTrackerService.instance;
      final milestoneService = XpMilestoneService();

      final streaks = await streakService.getStreakMilestoneHistory();
      final streakEvents = streaks
          .map((entry) => StreakEvent(days: entry.days, date: entry.achievedAt))
          .toList();
      final milestones = await milestoneService.getClaimedMilestoneEvents();

      if (!mounted) return;

      setState(() {
        _streakEvents = streakEvents;
        _milestoneEvents = milestones;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date, String locale) {
    final format = DateFormat('d MMM yyyy', locale);
    return format.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.xpHistoryAchievementsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(l10n, locale),
    );
  }

  Widget _buildContent(AppLocalizations l10n, String locale) {
    final hasStreaks = _streakEvents.isNotEmpty;
    final hasMilestones = _milestoneEvents.isNotEmpty;

    if (!hasStreaks && !hasMilestones) {
      return _buildEmptyState(l10n);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hasStreaks) ...[
          _buildStreaksSection(l10n, locale),
          const SizedBox(height: 24),
        ],
        if (hasMilestones) _buildMilestonesSection(l10n, locale),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          l10n.xpHistoryEmptyTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.xpHistoryEmptyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    ),
  );

  Widget _buildStreaksSection(AppLocalizations l10n, String locale) => Card(
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
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.xpHistoryStreaksSection,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._streakEvents.map(
            (event) => _buildStreakItem(l10n, locale, event),
          ),
        ],
      ),
    ),
  );

  Widget _buildStreakItem(
    AppLocalizations l10n,
    String locale,
    StreakEvent event,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_fire_department,
            color: Colors.orange[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.xpHistoryStreakLabel(l10n.xpDaysCount(event.days)),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(event.date, locale),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildMilestonesSection(AppLocalizations l10n, String locale) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.xpHistoryMilestonesSection,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._milestoneEvents.map(
            (event) => _buildMilestoneItem(locale, event),
          ),
        ],
      ),
    ),
  );

  Widget _buildMilestoneItem(String locale, MilestoneEvent event) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.amber[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.emoji_events, color: Colors.amber[700], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.value} XP',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(event.date, locale),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
