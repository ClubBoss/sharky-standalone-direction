import 'package:flutter/material.dart';
import '../services/goal_orchestrator.dart';

/// Card widget displaying daily XP goal progress.
class DailyGoalCard extends StatefulWidget {
  final int target;

  const DailyGoalCard({
    super.key,
    this.target = GoalOrchestrator.defaultTarget,
  });

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard>
    with SingleTickerProviderStateMixin {
  final _goalService = GoalOrchestrator.instance.dailyGoalService;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _wasCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Check initial completion state
    _wasCompleted = _goalService.isCompleted(target: widget.target);

    _goalService.progressNotifier.addListener(_onProgressChanged);
  }

  void _onProgressChanged() {
    final isNowCompleted = _goalService.isCompleted(target: widget.target);
    if (isNowCompleted && !_wasCompleted) {
      // Just completed! Trigger animation
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    _wasCompleted = isNowCompleted;
    if (mounted) {
      setState(() {}); // Rebuild to show new progress
    }
  }

  @override
  void dispose() {
    _goalService.progressNotifier.removeListener(_onProgressChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final progress = _goalService.getTodayProgress();
    final isCompleted = progress >= widget.target;
    final progressPercent = (progress / widget.target).clamp(0.0, 1.0);
    final timeUntilReset = _goalService.formatTimeUntilReset();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isRu ? 'Дневная цель' : 'Daily Goal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    isCompleted ? '✅' : '🔒',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress text
            Text(
              isRu
                  ? 'Прогресс: $progress / ${widget.target} XP'
                  : 'Progress: $progress / ${widget.target} XP',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 8,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reset timer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  isRu
                      ? 'Сброс через: $timeUntilReset'
                      : 'Resets in: $timeUntilReset',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
