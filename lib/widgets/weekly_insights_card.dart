import 'package:flutter/material.dart';
import '../services/weekly_insights_service.dart';
import '../services/booster_service.dart';

/// Displays weekly recap stats for the last 7 days.
///
/// Shows aggregated metrics:
/// - Total XP earned
/// - Active days count (n / 7)
/// - Sessions played
/// - Most used booster type
/// - Trophies earned
class WeeklyInsightsCard extends StatefulWidget {
  const WeeklyInsightsCard({super.key});

  @override
  State<WeeklyInsightsCard> createState() => _WeeklyInsightsCardState();
}

class _WeeklyInsightsCardState extends State<WeeklyInsightsCard> {
  WeeklyInsights _insights = WeeklyInsights.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final service = WeeklyInsightsService();
    final insights = await service.computeWeeklyInsights();
    if (!mounted) return;
    setState(() {
      _insights = insights;
      _loading = false;
    });
  }

  String _title(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Итоги недели' : 'Weekly Recap';
  }

  String _totalXpLabel(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Всего XP' : 'Total XP';
  }

  String _activeDaysLabel(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Активных дней' : 'Active Days';
  }

  String _sessionsLabel(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Сессий' : 'Sessions';
  }

  String _topBoosterLabel(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Топ бустер' : 'Top Booster';
  }

  String _trophiesLabel(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Трофеев' : 'Trophies';
  }

  String _emptyMessage(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Начните новую неделю!' : 'Start your week!';
  }

  String _boosterIcon(BoosterType? type) {
    if (type == null) return '—';
    switch (type) {
      case BoosterType.study:
        return '📚';
      case BoosterType.play:
        return '🎮';
      case BoosterType.review:
        return '🔍';
    }
  }

  String _boosterLabel(BuildContext context, BoosterType? type) {
    if (type == null) {
      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      return isRu ? 'Нет' : 'None';
    }
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    if (isRu) {
      switch (type) {
        case BoosterType.study:
          return 'Обучение';
        case BoosterType.play:
          return 'Игра';
        case BoosterType.review:
          return 'Обзор';
      }
    } else {
      switch (type) {
        case BoosterType.study:
          return 'Study';
        case BoosterType.play:
          return 'Play';
        case BoosterType.review:
          return 'Review';
      }
    }
  }

  bool get _isEmpty =>
      _insights.totalXp == 0 &&
      _insights.activeDaysCount == 0 &&
      _insights.totalSessions == 0 &&
      _insights.trophiesEarned == 0;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;
    final onSurfaceColor = theme.colorScheme.onSurfaceVariant;

    return Card(
      color: surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            if (_isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _emptyMessage(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  _buildStatRow(
                    context,
                    icon: '🧠',
                    label: _totalXpLabel(context),
                    value: '+${_insights.totalXp}',
                    valueColor: Colors.green.shade700,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    icon: '📅',
                    label: _activeDaysLabel(context),
                    value: '${_insights.activeDaysCount} / 7',
                    valueColor: onSurfaceColor,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    icon: '⏱️',
                    label: _sessionsLabel(context),
                    value: '${_insights.totalSessions}',
                    valueColor: onSurfaceColor,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    icon: _boosterIcon(_insights.mostUsedBoosterType),
                    label: _topBoosterLabel(context),
                    value: _boosterLabel(
                      context,
                      _insights.mostUsedBoosterType,
                    ),
                    valueColor: onSurfaceColor,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    icon: '🏆',
                    label: _trophiesLabel(context),
                    value: '${_insights.trophiesEarned}',
                    valueColor: Colors.orange.shade700,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: onSurfaceColor),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
