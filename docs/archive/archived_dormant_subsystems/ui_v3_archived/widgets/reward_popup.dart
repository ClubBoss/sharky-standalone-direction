import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/visual_theme_v3.dart';
import '../../services/engagement_loop_service.dart';

/// Simple overlay displaying "Reward Unlocked" banner when milestone reached.
///
/// Shows ASCII banner with XP/chip count, auto-dismisses after 1s or on tap.
/// Listens to EngagementLoopService for reward updates.
///
/// Usage:
/// ```dart
/// RewardPopup.show(
///   context: context,
///   bonusXp: 25,
///   streakLength: 5,
/// )
/// ```
class RewardPopup extends StatelessWidget {
  const RewardPopup({
    super.key,
    required this.bonusXp,
    required this.streakLength,
    required this.onDismiss,
  });

  final int bonusXp;
  final int streakLength;
  final VoidCallback onDismiss;

  /// Show reward popup as overlay.
  static void show({
    required BuildContext context,
    required int bonusXp,
    required int streakLength,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => RewardPopup(
        bonusXp: bonusXp,
        streakLength: streakLength,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VisualThemeV3.surfaceDark.withValues(alpha: 0.78),
      child: GestureDetector(
        onTap: onDismiss,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: VisualThemeV3.spacingXL,
            ),
            padding: const EdgeInsets.all(VisualThemeV3.spacingL),
            decoration: BoxDecoration(
              color: VisualThemeV3.card,
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              boxShadow: [VisualThemeV3.shadowHigh],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ASCII Banner
                Text(
                  '*** REWARD UNLOCKED ***',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: VisualThemeV3.success,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: VisualThemeV3.spacingM),
                // Streak info
                Text(
                  '$streakLength-Day Streak Milestone',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: VisualThemeV3.primaryText,
                  ),
                ),
                const SizedBox(height: VisualThemeV3.spacingS),
                // XP reward
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: VisualThemeV3.warning, size: 24),
                    const SizedBox(width: VisualThemeV3.spacingS),
                    Text(
                      '+$bonusXp XP',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: VisualThemeV3.warning),
                    ),
                  ],
                ),
                const SizedBox(height: VisualThemeV3.spacingM),
                // Dismiss hint
                Text(
                  'Tap to dismiss',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: VisualThemeV3.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that listens for reward events and displays popups automatically.
class RewardPopupListener extends StatefulWidget {
  const RewardPopupListener({super.key, required this.child});

  final Widget child;

  @override
  State<RewardPopupListener> createState() => _RewardPopupListenerState();
}

class _RewardPopupListenerState extends State<RewardPopupListener> {
  Timer? _pollTimer;
  int _lastKnownRewards = 0;

  @override
  void initState() {
    super.initState();
    _initializeRewardTracking();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeRewardTracking() async {
    // Get initial reward count
    _lastKnownRewards = await EngagementLoopService.instance.getTotalRewards();

    // Poll for changes (since there's no stream API)
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _checkForNewRewards();
    });
  }

  Future<void> _checkForNewRewards() async {
    if (!mounted) return;

    final currentRewards = await EngagementLoopService.instance
        .getTotalRewards();

    if (currentRewards > _lastKnownRewards) {
      // New reward detected
      final bonusXp = currentRewards - _lastKnownRewards;
      final streak = await EngagementLoopService.instance.getCurrentStreak();

      // Show popup
      if (mounted) {
        RewardPopup.show(
          context: context,
          bonusXp: bonusXp,
          streakLength: streak,
        );
      }

      _lastKnownRewards = currentRewards;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
