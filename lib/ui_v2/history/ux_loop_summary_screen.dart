import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';

/// Stage H4 — UX Loop Summary & Trend Chart.
///
/// Presents a seven day XP/Chip trend along with quick stats so players can
/// gauge recent progress. Data pulls from the adaptive reward cache and the
/// persisted progression state; everything is ASCII friendly.
const String _defaultRewardCachePath =
    'tools/_reports/adaptive_reward_cache.json';

class UxLoopSummaryScreen extends StatefulWidget {
  const UxLoopSummaryScreen({
    super.key,
    this.rewardCachePath = _defaultRewardCachePath,
  });

  final String rewardCachePath;

  @override
  State<UxLoopSummaryScreen> createState() => _UxLoopSummaryScreenState();
}

class _UxLoopSummaryScreenState extends State<UxLoopSummaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  _UxLoopSummaryData? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    final summary = await _loadSummary();
    if (!mounted) return;
    setState(() {
      _data = summary;
      _isLoading = false;
    });
    _controller
      ..reset()
      ..forward();
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'ux_loop_summary_viewed',
        params: <String, Object?>{
          'sessions': summary.totalSessions,
          'avg_xp': summary.averageXpPerSession,
          'total_chips': summary.totalChips,
        },
      ),
    );
  }

  Future<_UxLoopSummaryData> _loadSummary() async {
    final dateNow = DateTime.now().toUtc();
    final days = List<DateTime>.generate(
      7,
      (index) => dateNow.subtract(Duration(days: 6 - index)),
    ).map((d) => DateTime.utc(d.year, d.month, d.day)).toList(growable: false);

    final chartBuckets = Map<DateTime, _TrendBucket>.fromEntries(
      days.map((d) => MapEntry(d, _TrendBucket())),
    );

    final file = File(widget.rewardCachePath);
    if (await file.exists()) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          final history = decoded['history'];
          if (history is List) {
            for (final entry in history) {
              if (entry is! Map<String, dynamic>) continue;
              final timestampStr = entry['timestamp']?.toString();
              if (timestampStr == null) continue;
              final timestamp = DateTime.tryParse(timestampStr);
              if (timestamp == null) continue;

              final dateKey = DateTime.utc(
                timestamp.year,
                timestamp.month,
                timestamp.day,
              );
              if (!chartBuckets.containsKey(dateKey)) {
                // Only consider the most recent seven buckets; older values are ignored.
                continue;
              }

              final adjustedXp = (entry['adjusted_xp'] as num?)?.toInt() ?? 0;
              final adjustedChips =
                  (entry['adjusted_chips'] as num?)?.toInt() ?? 0;

              chartBuckets[dateKey]!.xp += adjustedXp;
              chartBuckets[dateKey]!.chips += adjustedChips;
              chartBuckets[dateKey]!.sessions += 1;
            }
          }
        }
      } catch (_) {
        // Keep default zeroed buckets if parsing fails.
      }
    }

    final trendPoints = <_TrendPoint>[];
    int totalXp = 0;
    int totalChips = 0;
    int totalSessions = 0;

    for (final date in days) {
      final bucket = chartBuckets[date]!;
      trendPoints.add(
        _TrendPoint(
          date: date,
          xp: bucket.xp.toDouble(),
          chips: bucket.chips.toDouble(),
        ),
      );
      totalXp += bucket.xp;
      totalChips += bucket.chips;
      totalSessions += bucket.sessions;
    }

    final progression = PlayerProgressionService.instance.snapshot();

    final averageXp = totalSessions > 0 ? totalXp / totalSessions : 0;

    return _UxLoopSummaryData(
      points: trendPoints,
      averageXpPerSession: double.parse(averageXp.toStringAsFixed(1)),
      totalChips: totalChips,
      activeStreak: progression.streak,
      totalSessions: totalSessions,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = _data;
    if (data == null || data.points.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('UX Loop Summary')),
        body: const Center(
          child: Text(
            'No recent reward history recorded.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('UX Loop Summary')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 420 ? 12.0 : 24.0;
          final chartHeight = min(320.0, max(220.0, width * 0.4));
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryCard(
                      title: 'Avg XP per Session',
                      value: data.averageXpPerSession.toStringAsFixed(1),
                    ),
                    _SummaryCard(
                      title: 'Total Chips Earned',
                      value: data.totalChips.toString(),
                    ),
                    _SummaryCard(
                      title: 'Active Streak',
                      value: data.activeStreak.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '7-Day XP and Chips Trend',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: BoxConstraints.tightFor(height: chartHeight),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _TrendChart(
                    points: data.points,
                    animation: _controller,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'RobotoMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points, required this.animation});

  final List<_TrendPoint> points;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _TrendChartPainter(
            points: points,
            progress: animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({required this.points, required this.progress});

  final List<_TrendPoint> points;
  final double progress;

  static const double _axisPadding = 32;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }
    final paintAxis = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final chartRect = Rect.fromLTWH(
      _axisPadding,
      8,
      size.width - _axisPadding - 8,
      size.height - _axisPadding - 16,
    );

    // Axes
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      paintAxis,
    );
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      paintAxis,
    );

    final maxValue = points.map((p) => max(p.xp, p.chips)).fold<double>(0, max);
    final safeMax = maxValue <= 0 ? 1 : maxValue;

    final xpPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final chipsPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final pointPaintXp = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    final pointPaintChips = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    final xpPath = Path();
    final chipsPath = Path();
    final stepX = points.length <= 1
        ? 0
        : chartRect.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final ratio = i / max(1, points.length - 1);
      final x = chartRect.left + (ratio * chartRect.width);

      final xpY =
          chartRect.bottom -
          (chartRect.height * (points[i].xp / safeMax) * progress);
      final chipsY =
          chartRect.bottom -
          (chartRect.height * (points[i].chips / safeMax) * progress);

      if (i == 0) {
        xpPath.moveTo(x, xpY);
        chipsPath.moveTo(x, chipsY);
      } else {
        xpPath.lineTo(x, xpY);
        chipsPath.lineTo(x, chipsY);
      }
    }

    canvas.drawPath(xpPath, xpPaint);
    canvas.drawPath(chipsPath, chipsPaint);

    for (var i = 0; i < points.length; i++) {
      final x = chartRect.left + (stepX * i);
      final xpY =
          chartRect.bottom -
          (chartRect.height * (points[i].xp / safeMax) * progress);
      final chipsY =
          chartRect.bottom -
          (chartRect.height * (points[i].chips / safeMax) * progress);
      canvas.drawCircle(Offset(x, xpY), 4, pointPaintXp);
      canvas.drawCircle(Offset(x, chipsY), 4, pointPaintChips);

      final label = _weekdayLabel(points[i].date);
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontFamily: 'RobotoMono',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartRect.bottom + 4),
      );
    }
  }

  static String _weekdayLabel(DateTime date) {
    const labels = <int, String>{
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return labels[date.weekday] ?? 'Day';
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.progress != progress;
  }
}

class _TrendPoint {
  const _TrendPoint({
    required this.date,
    required this.xp,
    required this.chips,
  });

  final DateTime date;
  final double xp;
  final double chips;
}

class _TrendBucket {
  int xp = 0;
  int chips = 0;
  int sessions = 0;
}

class _UxLoopSummaryData {
  const _UxLoopSummaryData({
    required this.points,
    required this.averageXpPerSession,
    required this.totalChips,
    required this.activeStreak,
    required this.totalSessions,
  });

  final List<_TrendPoint> points;
  final double averageXpPerSession;
  final int totalChips;
  final int activeStreak;
  final int totalSessions;
}
