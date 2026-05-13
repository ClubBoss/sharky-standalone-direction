import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

/// Team Ops Dashboard (Ω4): unified QA + CI + Telemetry visibility.
class TeamOpsDashboard extends StatefulWidget {
  const TeamOpsDashboard({super.key});
  @override
  State<TeamOpsDashboard> createState() => _TeamOpsDashboardState();
}

class _TeamOpsDashboardState extends State<TeamOpsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  final _metrics = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    FirebaseLiteTelemetryService.instance.logEvent('team_ops_dashboard_opened');
    _loadMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    final start = DateTime.now();
    setState(() => _loading = true);
    await _parse();
    setState(() => _loading = false);
    FirebaseLiteTelemetryService.instance.logEvent(
      'team_ops_dashboard_refreshed',
      params: {
        'refresh_duration_ms': DateTime.now().difference(start).inMilliseconds,
      },
    );
  }

  Future<void> _parse() async {
    _metrics.addAll({
      'tests_passed': 0,
      'tests_failed': 0,
      'analyzer_issues': 0,
      'coverage_percent': 0.0,
      'retention_percent': 0.0,
      'crash_free_percent': 100.0,
      'ai_accuracy_percent': 0.0,
    });
    for (final path in [
      'release/_reports/final_release_summary.txt',
      'release/_reports/qa_ci_perfection_sweep.txt',
      'release/_reports/full_qa_report.txt',
      'release/_reports/telemetry_dashboard.txt',
      'release/_reports/stability_scaling_plan.txt',
    ]) {
      final file = File(path);
      if (!file.existsSync()) continue;
      try {
        for (final line in (await file.readAsString()).split('\n')) {
          final lower = line.toLowerCase(),
              match = RegExp(r'(\d+\.?\d*)').firstMatch(line);
          if (match == null) continue;
          final val = match.group(1)!;
          if (lower.contains('test') && lower.contains('passed'))
            _metrics['tests_passed'] =
                int.tryParse(val) ?? _metrics['tests_passed'];
          else if (lower.contains('fail'))
            _metrics['tests_failed'] =
                int.tryParse(val) ?? _metrics['tests_failed'];
          else if (lower.contains('analyzer') || lower.contains('issue'))
            _metrics['analyzer_issues'] =
                int.tryParse(val) ?? _metrics['analyzer_issues'];
          else if (lower.contains('coverage'))
            _metrics['coverage_percent'] =
                double.tryParse(val) ?? _metrics['coverage_percent'];
          else if (lower.contains('retention'))
            _metrics['retention_percent'] =
                double.tryParse(val) ?? _metrics['retention_percent'];
          else if (lower.contains('crash') && lower.contains('free'))
            _metrics['crash_free_percent'] =
                double.tryParse(val) ?? _metrics['crash_free_percent'];
          else if (lower.contains('ai') && lower.contains('accuracy'))
            _metrics['ai_accuracy_percent'] =
                double.tryParse(val) ?? _metrics['ai_accuracy_percent'];
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: VisualThemeV3.theme,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Poker Analyzer Ops Dashboard v1.0'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadMetrics,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'QA & CI'),
            Tab(text: 'Telemetry'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: const EdgeInsets.all(VisualThemeV3.spacingM),
                  children: [
                    _metricCard(
                      context,
                      'Tests Passed',
                      '${_metrics['tests_passed']}',
                      (_metrics['tests_passed'] as int) > 0 ? _S.ok : _S.neu,
                    ),
                    const SizedBox(height: VisualThemeV3.spacingM),
                    _metricCard(
                      context,
                      'Tests Failed',
                      '${_metrics['tests_failed']}',
                      (_metrics['tests_failed'] as int) == 0 ? _S.ok : _S.err,
                    ),
                    const SizedBox(height: VisualThemeV3.spacingM),
                    _metricCard(
                      context,
                      'Analyzer Issues',
                      '${_metrics['analyzer_issues']}',
                      (_metrics['analyzer_issues'] as int) == 0
                          ? _S.ok
                          : _S.warn,
                    ),
                    const SizedBox(height: VisualThemeV3.spacingM),
                    _metricCard(
                      context,
                      'Coverage',
                      '${(_metrics['coverage_percent'] as double).toStringAsFixed(1)}%',
                      (_metrics['coverage_percent'] as double) >= 80
                          ? _S.ok
                          : _S.warn,
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(VisualThemeV3.spacingM),
                  children: [
                    _metricCard(
                      context,
                      'Retention',
                      '${(_metrics['retention_percent'] as double).toStringAsFixed(1)}%',
                      (_metrics['retention_percent'] as double) >= 70
                          ? _S.ok
                          : (_metrics['retention_percent'] as double) >= 50
                          ? _S.warn
                          : _S.err,
                    ),
                    const SizedBox(height: VisualThemeV3.spacingM),
                    _metricCard(
                      context,
                      'Crash-Free',
                      '${(_metrics['crash_free_percent'] as double).toStringAsFixed(1)}%',
                      (_metrics['crash_free_percent'] as double) >= 99
                          ? _S.ok
                          : (_metrics['crash_free_percent'] as double) >= 95
                          ? _S.warn
                          : _S.err,
                    ),
                    const SizedBox(height: VisualThemeV3.spacingM),
                    _metricCard(
                      context,
                      'AI Accuracy',
                      '${(_metrics['ai_accuracy_percent'] as double).toStringAsFixed(1)}%',
                      (_metrics['ai_accuracy_percent'] as double) >= 90
                          ? _S.ok
                          : (_metrics['ai_accuracy_percent'] as double) >= 80
                          ? _S.warn
                          : _S.err,
                    ),
                  ],
                ),
              ],
            ),
    ),
  );

  Widget _metricCard(
    BuildContext context,
    String label,
    String value,
    _S state,
  ) {
    final iconColor = {
      _S.ok: VisualThemeV3.success,
      _S.warn: VisualThemeV3.warning,
      _S.err: VisualThemeV3.danger,
      _S.neu: VisualThemeV3.neutralGrey,
    }[state];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: VisualThemeV3.elevationLow,
      margin: const EdgeInsets.symmetric(
        horizontal: VisualThemeV3.spacingS,
        vertical: VisualThemeV3.spacingXS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(VisualThemeV3.spacingSM),
        child: Row(
          children: [
            Icon(
              {
                _S.ok: Icons.check_circle,
                _S.warn: Icons.warning,
                _S.err: Icons.error,
                _S.neu: Icons.info,
              }[state],
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: VisualThemeV3.spacingSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: VisualThemeV3.spacingXS),
                  Text(value, style: textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _S { ok, warn, err, neu }
