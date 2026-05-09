import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/beta_playtest_service.dart';
import 'package:poker_analyzer/services/emotion_adaptive_engine.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

class UiV2SessionAnalyticsScreen extends StatefulWidget {
  const UiV2SessionAnalyticsScreen({super.key});

  @override
  State<UiV2SessionAnalyticsScreen> createState() =>
      _UiV2SessionAnalyticsScreenState();
}

class _UiV2SessionAnalyticsScreenState
    extends State<UiV2SessionAnalyticsScreen> {
  BetaSessionStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await BetaPlaytestService.getSessionStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Analytics')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(theme, spacing),
    );
  }

  Widget _buildContent(ThemeData theme, double spacing) {
    final stats = _stats!;
    final tone = EmotionAdaptiveEngine.instance.getAdaptiveTone(
      sentiment: stats.xpTrend,
      consistency: stats.accuracy,
    );
    final toneLabel = _toneLabel(tone);

    final cards = <Widget>[
      _AnalyticsCard(
        title: 'XP Earned',
        value: stats.xpTotal.toStringAsFixed(0),
        subtitle: 'last ${stats.sessionsCompleted} sessions',
        progress: _normalize(stats.xpTotal, 0, 1000),
        trend: stats.xpTrend,
        color: Colors.teal,
      ),
      _AnalyticsCard(
        title: 'Accuracy',
        value: '${(stats.accuracy * 100).toStringAsFixed(1)}%',
        subtitle: 'correct hands',
        progress: stats.accuracy.clamp(0.0, 1.0),
        trend: stats.accuracyTrend,
        color: Colors.indigo,
      ),
      _AnalyticsCard(
        title: 'Energy Used',
        value: stats.energyUsed.toStringAsFixed(1),
        subtitle:
            'avg ${stats.energyUsed / stats.sessionsCompleted}'
            ' per session',
        progress: _normalize(stats.energyUsed, 0, 50),
        trend: stats.energyTrend,
        color: Colors.orange,
        invertTrend: true,
      ),
      _AnalyticsCard(
        title: 'Leaks Fixed',
        value: stats.leaksFixed.toString(),
        subtitle: 'tracked improvements',
        progress: _normalize(stats.leaksFixed.toDouble(), 0, 10),
        trend: stats.leaksTrend,
        color: Colors.purple,
        invertTrend: true,
      ),
      _AnalyticsCard(
        title: 'Sessions',
        value: stats.sessionsCompleted.toString(),
        subtitle: 'tracked last week',
        progress: _normalize(stats.sessionsCompleted.toDouble(), 0, 10),
        trend: 0,
        color: Colors.blueGrey,
      ),
    ];

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: EdgeInsets.all(spacing),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(
                toneLabel,
                style: AppTypography.body.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              backgroundColor: theme.colorScheme.primary,
              avatar: Text(_toneIcon(tone)),
            ),
          ),
          SizedBox(height: spacing),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxis = width > 640 ? 2 : 1;
              return GridView.count(
                crossAxisCount: crossAxis,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: width > 640 ? 1.6 : 1.3,
                children: cards,
              );
            },
          ),
        ],
      ),
    );
  }

  double _normalize(double value, double min, double max) {
    if (max <= min) return 0.0;
    final normalized = (value - min) / (max - min);
    return normalized.clamp(0.0, 1.0);
  }

  String _toneLabel(String tone) {
    switch (tone) {
      case 'energetic':
        return 'Crushing momentum!';
      case 'motivating':
        return 'Pushing the edge';
      case 'calm':
      default:
        return 'Steady and focused';
    }
  }

  String _toneIcon(String tone) {
    switch (tone) {
      case 'energetic':
        return '🔥';
      case 'motivating':
        return '💪';
      case 'calm':
      default:
        return '🧘';
    }
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double progress;
  final double trend;
  final Color color;
  final bool invertTrend;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.progress,
    required this.trend,
    required this.color,
    this.invertTrend = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final radius = brand?.radius ?? 16.0;
    final trendValue = invertTrend ? -trend : trend;
    final trendIcon = trendValue >= 0 ? '↑' : '↓';
    final trendColor = trendValue >= 0 ? Colors.green : Colors.redAccent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h1.copyWith(color: color)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTypography.body),
          ],
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.1),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '$trendIcon ${(trendValue * 100).toStringAsFixed(1)}%',
            style: AppTypography.caption.copyWith(color: trendColor),
          ),
        ],
      ),
    );
  }
}
