import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/xp_tracker_service.dart';
import '../services/xp_level_engine.dart';
import '../models/xp_entry.dart';
import '../widgets/sync_status_widget.dart';

/// Level progression screen showing current level, XP progress, and level history.
///
/// Features:
/// - Current level badge with XP progress bar
/// - XP to next level indicator
/// - Timeline of past level-ups
/// - Duolingo-style clean UI
class LevelProgressionScreen extends StatelessWidget {
  LevelProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final xpService = context.watch<XPTrackerService>();
    final currentLevel = xpService.level;
    final totalXp = xpService.xp;
    final progress = xpService.progress.clamp(0.0, 1.0);
    final nextLevelXp = xpService.nextLevelXp;
    final currentLevelBaseXp = XPLevelEngine.instance.xpForLevel(currentLevel);
    final xpInCurrentLevel = totalXp - currentLevelBaseXp;
    final xpNeededForNextLevel = nextLevelXp - totalXp;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Progression'),
        centerTitle: true,
        actions: [SyncStatusIcon.of(context)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Level Card
          _CurrentLevelCard(
            level: currentLevel,
            totalXp: totalXp,
            progress: progress,
            xpInCurrentLevel: xpInCurrentLevel,
            xpNeededForNextLevel: xpNeededForNextLevel,
            nextLevelXp: nextLevelXp - currentLevelBaseXp,
          ),
          const SizedBox(height: 24),
          // Level Timeline
          _LevelTimeline(
            currentLevel: currentLevel,
            totalXp: totalXp,
            history: xpService.history,
          ),
        ],
      ),
    );
  }
}

class _CurrentLevelCard extends StatelessWidget {
  final int level;
  final int totalXp;
  final double progress;
  final int xpInCurrentLevel;
  final int xpNeededForNextLevel;
  final int nextLevelXp;

  const _CurrentLevelCard({
    required this.level,
    required this.totalXp,
    required this.progress,
    required this.xpInCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          // Level Badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Level $level',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalXp Total XP',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$xpInCurrentLevel XP',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  Text(
                    '$nextLevelXp XP',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '$xpNeededForNextLevel XP to Level ${level + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelTimeline extends StatelessWidget {
  final int currentLevel;
  final int totalXp;
  final List<XPEntry> history;

  const _LevelTimeline({
    required this.currentLevel,
    required this.totalXp,
    required this.history,
  });

  List<_LevelMilestone> _computeMilestones() {
    final milestones = <_LevelMilestone>[];
    final engine = XPLevelEngine.instance;

    // Add current level
    milestones.add(
      _LevelMilestone(
        level: currentLevel,
        xp: totalXp,
        date: DateTime.now(),
        isCurrent: true,
      ),
    );

    // Compute past level-ups from XP history
    var runningXp = 0;
    final sortedHistory = [...history]
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final entry in sortedHistory) {
      final previousLevel = engine.getLevel(runningXp);
      runningXp += entry.xp;
      final newLevel = engine.getLevel(runningXp);

      // If level changed, record it
      if (newLevel > previousLevel) {
        for (var lvl = previousLevel + 1; lvl <= newLevel; lvl++) {
          milestones.add(
            _LevelMilestone(
              level: lvl,
              xp: engine.xpForLevel(lvl),
              date: entry.date,
              isCurrent: false,
            ),
          );
        }
      }
    }

    // Sort by level descending (newest first)
    milestones.sort((a, b) => b.level.compareTo(a.level));

    // Remove duplicates (keep only the first occurrence of each level)
    final seen = <int>{};
    milestones.removeWhere((m) {
      if (seen.contains(m.level)) return true;
      seen.add(m.level);
      return false;
    });

    return milestones.take(10).toList(); // Show last 10 levels
  }

  @override
  Widget build(BuildContext context) {
    final milestones = _computeMilestones();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Level History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (milestones.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.timeline, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 12),
                  Text(
                    'No level history yet',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ...milestones.map(
            (milestone) => _MilestoneItem(milestone: milestone),
          ),
      ],
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final _LevelMilestone milestone;

  const _MilestoneItem({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.secondary;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: milestone.isCurrent
            ? accentColor.withValues(alpha: 0.15)
            : Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: milestone.isCurrent
            ? Border.all(color: accentColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Level Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: milestone.isCurrent ? accentColor : Colors.grey[700],
            ),
            child: Center(
              child: Text(
                '${milestone.level}',
                style: TextStyle(
                  color: milestone.isCurrent ? Colors.black : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Level ${milestone.level}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: milestone.isCurrent ? accentColor : Colors.white,
                      ),
                    ),
                    if (milestone.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.isCurrent
                      ? '${milestone.xp} XP'
                      : '${_formatXP(milestone.xp)} XP • ${dateFormat.format(milestone.date)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          // Icon
          Icon(
            milestone.isCurrent ? Icons.star : Icons.check_circle_outline,
            color: milestone.isCurrent ? accentColor : Colors.grey[600],
            size: 24,
          ),
        ],
      ),
    );
  }

  String _formatXP(int xp) {
    if (xp >= 1000000) {
      return '${(xp / 1000000).toStringAsFixed(1)}M';
    } else if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return '$xp';
  }
}

class _LevelMilestone {
  final int level;
  final int xp;
  final DateTime date;
  final bool isCurrent;

  _LevelMilestone({
    required this.level,
    required this.xp,
    required this.date,
    required this.isCurrent,
  });
}
