import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Analytics dashboard V3 that visualizes rolling averages for XP, retention,
/// and monetization stability. Data comes from
/// `release/analytics_dashboard/analytics_data.json`.
class AnalyticsDashboardScreenV3 extends StatelessWidget {
  const AnalyticsDashboardScreenV3({super.key});

  static const String _dataPath =
      'release/analytics_dashboard/analytics_data.json';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AnalyticsData?>(
      future: _loadAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildPlaceholder(context);
        }

        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Analytics Dashboard V3')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 480;
              final padding = EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 24,
                vertical: 16,
              );
              final cardWidth = isCompact ? double.infinity : (width / 3) - 24;

              return SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Last updated: ${data.generatedAt ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.start,
                      children: [
                        _MetricCard(
                          title: 'XP Avg',
                          values: data.xp,
                          width: cardWidth,
                        ),
                        _MetricCard(
                          title: 'Retention Avg',
                          values: data.retention,
                          width: cardWidth,
                        ),
                        _MetricCard(
                          title: 'Monetization Avg',
                          values: data.monetization,
                          width: cardWidth,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard V3')),
      body: Center(
        child: Text(
          'No data available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Future<_AnalyticsData?> _loadAnalytics() async {
    final file = File(_dataPath);
    if (!await file.exists()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _AnalyticsData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}

class _MetricValues {
  const _MetricValues({required this.avg7, required this.avg14});

  final double avg7;
  final double avg14;

  bool get hasData => avg7 != 0 || avg14 != 0;

  _Trend get trend {
    if (avg7 > avg14) return _Trend.up;
    if (avg7 < avg14) return _Trend.down;
    return _Trend.flat;
  }
}

class _AnalyticsData {
  const _AnalyticsData({
    required this.xp,
    required this.retention,
    required this.monetization,
    required this.generatedAt,
  });

  final _MetricValues xp;
  final _MetricValues retention;
  final _MetricValues monetization;
  final String? generatedAt;

  factory _AnalyticsData.fromJson(Map<String, dynamic> json) {
    return _AnalyticsData(
      xp: _MetricValues(
        avg7: _asDouble(json['xp_gain_avg_7']),
        avg14: _asDouble(json['xp_gain_avg_14']),
      ),
      retention: _MetricValues(
        avg7: _asDouble(json['retention_avg_7']),
        avg14: _asDouble(json['retention_avg_14']),
      ),
      monetization: _MetricValues(
        avg7: _asDouble(json['monetization_stability_avg_7']),
        avg14: _asDouble(json['monetization_stability_avg_14']),
      ),
      generatedAt: json['generated_at']?.toString(),
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return 0;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.values,
    required this.width,
  });

  final String title;
  final _MetricValues values;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final trend = values.trend;
    final String arrow;
    Color trendColor;
    switch (trend) {
      case _Trend.up:
        arrow = '↑';
        trendColor = Colors.green;
        break;
      case _Trend.down:
        arrow = '↓';
        trendColor = Colors.red;
        break;
      case _Trend.flat:
        arrow = '→';
        trendColor = Colors.grey;
        break;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricLine(label: '7-day', value: values.avg7),
                _MetricLine(label: '14-day', value: values.avg14),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Trend:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 8),
                Text(
                  arrow,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: trendColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  values.avg7 > values.avg14
                      ? 'Improving'
                      : values.avg7 < values.avg14
                      ? 'Declining'
                      : 'Stable',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.bold,
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

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: 'RobotoMono'),
        ),
      ],
    );
  }
}

enum _Trend { up, down, flat }
