import 'package:flutter/material.dart';
import '../services/streak_tracker_service.dart';

/// Compact badge showing current session streak with flame icon.
/// Hides when streak is 0, shows milestone styling for 7+ and 30+ days.
class StreakFlameWidget extends StatefulWidget {
  const StreakFlameWidget({super.key});

  @override
  State<StreakFlameWidget> createState() => _StreakFlameWidgetState();
}

class _StreakFlameWidgetState extends State<StreakFlameWidget> {
  final _streakService = StreakTrackerService.instance;
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await _streakService.getCurrentStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide if loading or streak is 0
    if (_isLoading || _currentStreak == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    // Determine milestone styling
    final isMilestone7 = _currentStreak >= 7;
    final isMilestone30 = _currentStreak >= 30;

    Color badgeColor;
    Color textColor;
    double fontSize;
    FontWeight fontWeight;

    if (isMilestone30) {
      // Gold for 30+ days
      badgeColor = Colors.amber.shade700;
      textColor = Colors.white;
      fontSize = 16;
      fontWeight = FontWeight.bold;
    } else if (isMilestone7) {
      // Green for 7+ days
      badgeColor = Colors.green.shade600;
      textColor = Colors.white;
      fontSize = 15;
      fontWeight = FontWeight.w600;
    } else {
      // Default for 1-6 days
      badgeColor = Colors.orange.shade600;
      textColor = Colors.white;
      fontSize = 14;
      fontWeight = FontWeight.w500;
    }

    final daysSuffix = isRu ? 'д' : 'd';
    final text = '🔥 $_currentStreak$daysSuffix';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
