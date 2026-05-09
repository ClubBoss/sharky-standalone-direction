import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

class UiV2AdaptiveDashboardScreen extends StatefulWidget {
  const UiV2AdaptiveDashboardScreen({super.key});

  @override
  State<UiV2AdaptiveDashboardScreen> createState() =>
      _UiV2AdaptiveDashboardScreenState();
}

class _UiV2AdaptiveDashboardScreenState
    extends State<UiV2AdaptiveDashboardScreen> {
  Map<String, dynamic>? simulation;
  Map<String, dynamic>? report;
  Map<String, dynamic>? history;
  Map<String, dynamic>? forecast;
  Map<String, dynamic>? optimizer;

  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    final sim = await _readJson('adaptive_simulation.json');
    final rep = await _readJson('adaptive_report.json');
    final hist = await _readJson('adaptive_history.json');
    final fore = await _readJson('adaptive_forecast.json');
    final opt = await _readJson('economy_auto_optimizer.json');

    DateTime? updated;
    for (final src in [sim, rep, hist, fore, opt]) {
      final ts = src?['timestamp'];
      if (ts is String) {
        final parsed = DateTime.tryParse(ts);
        if (parsed != null && (updated == null || parsed.isAfter(updated))) {
          updated = parsed;
        }
      }
    }

    setState(() {
      simulation = sim;
      report = rep;
      history = hist;
      forecast = fore;
      optimizer = opt;
      lastUpdated = updated ?? DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadTelemetry,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload telemetry',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTelemetry,
        child: ListView(
          padding: EdgeInsets.all(brand?.spacingMedium ?? 16),
          children: [
            _TelemetryCard(
              title: 'Simulation',
              status: simulation?['pass'] == true,
              metrics: {
                'Sessions': simulation?['sessions']?.toString(),
                'Avg pace': _format(simulation?['avg_pace'], fractionDigits: 3),
                'Avg stability': _format(
                  simulation?['stability'],
                  fractionDigits: 3,
                ),
                'Drift': _format(
                  simulation?['drift'],
                  fractionDigits: 3,
                  signed: true,
                ),
              },
            ),
            const SizedBox(height: 16),
            _TelemetryCard(
              title: 'Adaptive Report',
              status: report?['pass'] == true,
              metrics: {
                'Grade': report?['grade']?.toString(),
                'Stability': _format(report?['stability'], fractionDigits: 3),
                'Drift': _format(
                  report?['drift'],
                  fractionDigits: 3,
                  signed: true,
                ),
                'Risk': report?['risk']?.toString(),
              },
            ),
            const SizedBox(height: 16),
            _TelemetryCard(
              title: 'History Trend',
              status: history?['pass'] == true,
              metrics: {
                'Trend': _format(
                  history?['trend'],
                  fractionDigits: 3,
                  signed: true,
                ),
                'Grade':
                    '${history?['grade_start'] ?? '?'} → ${history?['grade_end'] ?? '?'}',
                'Pass ratio': _format(
                  history?['pass_ratio'],
                  fractionDigits: 3,
                ),
              },
              child: history == null
                  ? null
                  : _AsciiSparkline(
                      data: _extractHistoryStability(history!),
                      label: 'Stability trend',
                    ),
            ),
            const SizedBox(height: 16),
            _TelemetryCard(
              title: 'Forecast',
              status: forecast?['pass'] == true,
              metrics: {
                'Trend': _format(
                  forecast?['trend_stability'],
                  fractionDigits: 3,
                ),
                'Risk': forecast?['risk_level']?.toString(),
                'XP next': _format(
                  (forecast?['forecast_xp'] as List?)?.first,
                  fractionDigits: 3,
                ),
                'Refill next': _format(
                  (forecast?['forecast_refill'] as List?)?.first,
                  fractionDigits: 2,
                ),
              },
              child: forecast == null
                  ? null
                  : _AsciiSparkline(
                      data: _toDoubleList(forecast?['forecast_stability']),
                      label: 'Next stability forecast',
                    ),
            ),
            const SizedBox(height: 16),
            _TelemetryCard(
              title: 'Auto Optimizer',
              status: optimizer?['pass'] == true,
              metrics: {
                'XP':
                    '${_format(optimizer?['xp_before'])} → ${_format(optimizer?['xp_after'])}',
                'Refill':
                    '${_format(optimizer?['refill_before'])} → ${_format(optimizer?['refill_after'])}',
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Last Updated at ${_formatTime(lastUpdated)}',
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? ts) {
    final value = ts ?? DateTime.now();
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    final s = value.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  List<double> _extractHistoryStability(Map<String, dynamic> history) {
    final records = history['records'];
    if (records is! List) return const [];
    return records
        .whereType<Map>()
        .map((r) => _asDouble(r['stability']))
        .toList();
  }

  List<double> _toDoubleList(Object? value) {
    if (value is List) {
      return value
          .whereType<num>()
          .map((n) => double.parse(n.toStringAsFixed(3)))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return null;
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  String _format(Object? value, {int fractionDigits = 2, bool signed = false}) {
    double number = 0;
    if (value is num) number = value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) number = parsed;
    }
    final prefix = signed ? (number >= 0 ? '+' : '') : '';
    return '$prefix${number.toStringAsFixed(fractionDigits)}';
  }
}

class _TelemetryCard extends StatelessWidget {
  final String title;
  final bool status;
  final Map<String, String?> metrics;
  final Widget? child;

  const _TelemetryCard({
    required this.title,
    required this.status,
    required this.metrics,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final color = status ? Colors.green : Colors.red;
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(brand?.spacingMedium ?? 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: AppTypography.h1),
                const SizedBox(width: 8),
                Text(
                  status ? '🟢' : '🔴',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: double.infinity,
              color: color.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            for (final entry in metrics.entries)
              if (entry.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: AppTypography.body,
                  ),
                ),
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }
}

class _AsciiSparkline extends StatelessWidget {
  final List<double> data;
  final String label;

  const _AsciiSparkline({required this.data, required this.label});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Text('$label: no data', style: AppTypography.caption);
    }
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs() < 1e-6 ? 1.0 : max - min;
    final normalized = data
        .map((v) => ((v - min) / range * 4).clamp(0, 4).round())
        .toList();
    const levels = ['.', '-', '=', '^', '#'];
    final buffer = StringBuffer();
    for (final index in normalized) {
      buffer.write(levels[index]);
    }
    return Text('$label: ${buffer.toString()}', style: AppTypography.caption);
  }
}
