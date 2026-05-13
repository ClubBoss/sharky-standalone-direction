import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/xp_history_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class DailyGoalXpBar extends StatefulWidget {
  const DailyGoalXpBar({super.key});

  @override
  State<DailyGoalXpBar> createState() => _DailyGoalXpBarState();
}

class _DailyGoalXpBarState extends State<DailyGoalXpBar> {
  static const int _goal = 50;
  int _xpToday = 0;
  bool _goalLogged = false;

  @override
  void initState() {
    super.initState();
    _loadXp();
  }

  Future<void> _loadXp() async {
    final history = await XpHistoryService().getHistory();
    final now = DateTime.now();
    final xp = history
        .where((event) {
          final ts = event.timestamp;
          return ts.year == now.year &&
              ts.month == now.month &&
              ts.day == now.day;
        })
        .fold<int>(0, (sum, event) => sum + event.amount);

    if (!mounted) return;
    setState(() {
      _xpToday = xp;
    });

    FirebaseLiteTelemetryService.instance.logEvent(
      'daily_xp_bar_rendered',
      params: {'xp_today': xp, 'goal': _goal},
    );
    if (xp >= _goal && !_goalLogged) {
      _goalLogged = true;
      FirebaseLiteTelemetryService.instance.logEvent(
        'daily_xp_goal_reached',
        params: {'xp_today': xp},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (_xpToday / _goal).clamp(0.0, 1.0);
    final color = ratio >= 0.8 ? VisualThemeV3.warning : VisualThemeV3.success;
    return Container(
      padding: const EdgeInsets.all(VisualThemeV3.spacingS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Goal: $_xpToday / $_goal XP',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: VisualThemeV3.spacingS),
          LayoutBuilder(
            builder: (context, constraints) {
              final targetWidth = constraints.maxWidth * ratio;
              return Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: VisualThemeV3.speedNormal,
                    width: targetWidth,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(
                        VisualThemeV3.cardRadius,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
