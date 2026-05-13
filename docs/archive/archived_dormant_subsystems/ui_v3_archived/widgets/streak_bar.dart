import 'package:flutter/material.dart';
import '../theme/visual_theme_v3.dart';
import '../../services/engagement_loop_service.dart';

/// Animated horizontal progress bar visualizing daily streak progress.
///
/// Displays "Day X of Y" caption with color coding based on streak length.
/// Shows glow effect when milestone thresholds are hit (3/5/7/14/30 days).
///
/// Usage:
/// ```dart
/// StreakBar(
///   currentStreak: 5,
///   nextMilestone: 7,
/// )
/// ```
class StreakBar extends StatefulWidget {
  const StreakBar({
    super.key,
    required this.currentStreak,
    required this.nextMilestone,
  });

  final int currentStreak;
  final int nextMilestone;

  @override
  State<StreakBar> createState() => _StreakBarState();
}

class _StreakBarState extends State<StreakBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isMilestone = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: VisualThemeV3.speedSlow,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _checkMilestone();
  }

  @override
  void didUpdateWidget(StreakBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStreak != widget.currentStreak) {
      _checkMilestone();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _checkMilestone() {
    // Check if current streak matches a milestone
    final milestones = [3, 5, 7, 14, 30];
    _isMilestone = milestones.contains(widget.currentStreak);

    if (_isMilestone) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  Color _getStreakColor() {
    if (widget.currentStreak >= 30) return VisualThemeV3.success;
    if (widget.currentStreak >= 14) return VisualThemeV3.primary;
    if (widget.currentStreak >= 7) return VisualThemeV3.warning;
    if (widget.currentStreak >= 3) return VisualThemeV3.secondaryAccent;
    return VisualThemeV3.neutralGrey;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.nextMilestone > 0
        ? widget.currentStreak / widget.nextMilestone
        : 0.0;
    final streakColor = _getStreakColor();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: VisualThemeV3.spacingM,
            vertical: VisualThemeV3.spacingS,
          ),
          decoration: BoxDecoration(
            color: VisualThemeV3.card,
            borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
            boxShadow: _isMilestone
                ? [
                    BoxShadow(
                      color: streakColor.withValues(
                        alpha: 0.4 * _glowAnimation.value,
                      ),
                      blurRadius: VisualThemeV3.glowIntensity,
                      spreadRadius: 2,
                    ),
                  ]
                : [VisualThemeV3.shadowLight],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Caption
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day ${widget.currentStreak} of ${widget.nextMilestone}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: VisualThemeV3.secondaryText,
                    ),
                  ),
                  if (_isMilestone)
                    Text(
                      'MILESTONE!',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: streakColor),
                    ),
                ],
              ),
              const SizedBox(height: VisualThemeV3.spacingS),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: VisualThemeV3.speedNormal,
                  curve: Curves.easeOut,
                  height: 8,
                  decoration: BoxDecoration(
                    color: VisualThemeV3.neutralGrey.withValues(alpha: 0.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            streakColor,
                            streakColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget that fetches and displays streak data from EngagementLoopService.
class StreakBarLive extends StatefulWidget {
  const StreakBarLive({super.key});

  @override
  State<StreakBarLive> createState() => _StreakBarLiveState();
}

class _StreakBarLiveState extends State<StreakBarLive> {
  int _currentStreak = 0;
  int _nextMilestone = 3;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final streak = await EngagementLoopService.instance.getCurrentStreak();

    // Calculate next milestone
    const milestones = [3, 5, 7, 14, 30];
    int nextMilestone = 30;
    for (final m in milestones) {
      if (streak < m) {
        nextMilestone = m;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _nextMilestone = nextMilestone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreakBar(
      currentStreak: _currentStreak,
      nextMilestone: _nextMilestone,
    );
  }
}
