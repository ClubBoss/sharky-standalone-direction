import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _funnelPath = '$_reportsDir/marketing_funnel_summary.json';
const String _heatmapPath = '$_reportsDir/retention_heatmap_summary.txt';
const String _engagementPath =
    '$_reportsDir/engagement_correlation_summary.txt';
const String _summaryOutPath =
    '$_reportsDir/marketing_intelligence_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _minHealthIndex = 60.0;

Future<void> main(List<String> args) async {
  final dashboard = MarketingIntelligenceDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingIntelligenceDashboard {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final funnel = await _loadFunnel();
    final heatmap = await _loadHeatmap();
    final engagement = await _loadEngagement();

    final conversionScore = funnel.conversionAverage;
    final retentionScore = heatmap.retentionHealthIndex;
    final engagementScore = (engagement.pearsonR.clamp(0, 1)) * 100;
    final marketingHealthIndex =
        (conversionScore + retentionScore + engagementScore) / 3;

    await _withReportsWritable(() async {
      await _writeSummary(
        funnel,
        heatmap,
        engagement,
        marketingHealthIndex,
        stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        funnel,
        heatmap,
        engagement,
        marketingHealthIndex,
        stopwatch.elapsedMilliseconds,
      );
    });

    return marketingHealthIndex >= _minHealthIndex;
  }

  Future<_FunnelSnapshot> _loadFunnel() async {
    final file = File(_funnelPath);
    if (!await file.exists()) {
      throw StateError(
        'Missing marketing funnel summary at $_funnelPath. '
        'Run tools/marketing_funnel_analytics.dart first.',
      );
    }
    final decoded = json.decode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid funnel JSON payload.');
    }
    final conversions = decoded['conversions'];
    if (conversions is! List) {
      throw StateError('Funnel summary missing conversions array.');
    }
    final values = conversions
        .whereType<Map>()
        .map((entry) => (entry['percentage'] as num?)?.toDouble() ?? 0)
        .toList();
    final average = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;
    final sampleSize = (decoded['sample_size'] as num?)?.toInt() ?? 0;
    final avgSessionSeconds =
        (decoded['average_session_seconds'] as num?)?.toDouble() ?? 0;
    return _FunnelSnapshot(
      conversionAverage: average,
      sampleSize: sampleSize,
      averageSessionSeconds: avgSessionSeconds,
    );
  }

  Future<_HeatmapSnapshot> _loadHeatmap() async {
    final file = File(_heatmapPath);
    if (!await file.exists()) {
      throw StateError(
        'Retention heatmap summary missing at $_heatmapPath. '
        'Run tools/retention_heatmap_dashboard.dart first.',
      );
    }
    double index = 0;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Retention Health Index:')) {
        final value = trimmed.split(':').last.trim().replaceAll('%', '');
        index = double.tryParse(value) ?? 0;
        break;
      }
    }
    return _HeatmapSnapshot(retentionHealthIndex: index);
  }

  Future<_EngagementSnapshot> _loadEngagement() async {
    final file = File(_engagementPath);
    if (!await file.exists()) {
      throw StateError(
        'Engagement correlation summary missing at $_engagementPath. '
        'Run tools/engagement_correlation_engine.dart first.',
      );
    }
    double pearson = 0;
    int sampleSize = 0;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Sample size:')) {
        sampleSize = int.tryParse(trimmed.split(':').last.trim()) ?? 0;
      } else if (trimmed.startsWith('Pearson r:')) {
        pearson = double.tryParse(trimmed.split(':').last.trim()) ?? 0;
      }
    }
    return _EngagementSnapshot(pearsonR: pearson, sampleSize: sampleSize);
  }

  Future<void> _writeSummary(
    _FunnelSnapshot funnel,
    _HeatmapSnapshot heatmap,
    _EngagementSnapshot engagement,
    double marketingHealthIndex,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('MARKETING INTELLIGENCE SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Funnel conversion avg: '
        '${funnel.conversionAverage.toStringAsFixed(1)}%',
      )
      ..writeln(
        'Retention Health Index: '
        '${heatmap.retentionHealthIndex.toStringAsFixed(1)}%',
      )
      ..writeln(
        'Engagement Pearson r: '
        '${engagement.pearsonR.toStringAsFixed(3)}',
      )
      ..writeln(
        'Marketing Health Index: '
        '${marketingHealthIndex.toStringAsFixed(1)}%',
      )
      ..writeln('Funnel sample size: ${funnel.sampleSize}')
      ..writeln('Engagement sample size: ${engagement.sampleSize}')
      ..writeln(
        'Average session duration: '
        '${funnel.averageSessionSeconds.toStringAsFixed(1)}s',
      )
      ..writeln('Duration: ${durationMs}ms');

    await File(_summaryOutPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry(
    _FunnelSnapshot funnel,
    _HeatmapSnapshot heatmap,
    _EngagementSnapshot engagement,
    double marketingHealthIndex,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'marketing_intelligence_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'conversion_avg': funnel.conversionAverage,
      'retention_health_index': heatmap.retentionHealthIndex,
      'pearson_r': engagement.pearsonR,
      'marketing_health_index': marketingHealthIndex,
      'funnel_sample_size': funnel.sampleSize,
      'engagement_sample_size': engagement.sampleSize,
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _FunnelSnapshot {
  _FunnelSnapshot({
    required this.conversionAverage,
    required this.sampleSize,
    required this.averageSessionSeconds,
  });

  final double conversionAverage;
  final int sampleSize;
  final double averageSessionSeconds;
}

class _HeatmapSnapshot {
  _HeatmapSnapshot({required this.retentionHealthIndex});

  final double retentionHealthIndex;
}

class _EngagementSnapshot {
  _EngagementSnapshot({required this.pearsonR, required this.sampleSize});

  final double pearsonR;
  final int sampleSize;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
