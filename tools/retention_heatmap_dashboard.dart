import 'dart:convert';
import 'dart:io';

const String _funnelJsonPath = 'release/_reports/marketing_funnel_summary.json';
const String _summaryOutPath = 'release/_reports/retention_heatmap_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const double _minStagePercent = 40.0;
const double _minHealthIndex = 60.0;

Future<void> main(List<String> args) async {
  final dashboard = RetentionHeatmapDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionHeatmapDashboard {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final funnel = await _loadFunnel();
    final healthIndex = _computeHealthIndex(funnel);
    final heatmap = _buildHeatmap(funnel);

    await _withReportsWritable(() async {
      await _writeSummary(
        funnel,
        healthIndex,
        heatmap,
        stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(funnel, healthIndex, stopwatch.elapsedMilliseconds);
    });

    final stagesOk = funnel.conversions.every(
      (conversion) => conversion.percentage >= _minStagePercent,
    );
    final healthOk = healthIndex >= _minHealthIndex;
    return stagesOk && healthOk;
  }

  Future<_FunnelSummary> _loadFunnel() async {
    final file = File(_funnelJsonPath);
    if (!await file.exists()) {
      throw StateError(
        'Marketing funnel summary missing: $_funnelJsonPath. '
        'Run tools/marketing_funnel_analytics.dart first.',
      );
    }
    final decoded = json.decode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid marketing funnel summary format.');
    }
    final conversions = decoded['conversions'];
    if (conversions is! List) {
      throw StateError('Marketing funnel summary missing conversions array.');
    }
    final conversionList = conversions
        .whereType<Map>()
        .map(
          (entry) => _Conversion(
            from: entry['from']?.toString() ?? 'unknown',
            to: entry['to']?.toString() ?? 'unknown',
            percentage: (entry['percentage'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    final sampleSize = (decoded['sample_size'] as num?)?.toInt() ?? 0;
    final averageSessionSeconds =
        (decoded['average_session_seconds'] as num?)?.toDouble() ?? 0;
    return _FunnelSummary(
      conversions: conversionList,
      sampleSize: sampleSize,
      averageSessionSeconds: averageSessionSeconds,
    );
  }

  double _computeHealthIndex(_FunnelSummary funnel) {
    if (funnel.conversions.isEmpty) return 0;
    final total = funnel.conversions.fold<double>(
      0,
      (sum, conversion) => sum + conversion.percentage,
    );
    return total / funnel.conversions.length;
  }

  List<String> _buildHeatmap(_FunnelSummary funnel) {
    const block = '█';
    const width = 50;
    final lines = <String>[];
    lines.add('Retention Heatmap (each block = 2%)');
    for (final conversion in funnel.conversions) {
      final blocks = (conversion.percentage / 2).round().clamp(0, width);
      final filled = block * blocks;
      final empty = ' ' * (width - blocks);
      lines.add(
        '${conversion.from.padRight(18)}→ ${conversion.to.padRight(18)} '
        '|$filled$empty| ${conversion.percentage.toStringAsFixed(1)}%',
      );
    }
    return lines;
  }

  Future<void> _writeSummary(
    _FunnelSummary funnel,
    double healthIndex,
    List<String> heatmap,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('RETENTION HEATMAP SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Sample size (signups): ${funnel.sampleSize}')
      ..writeln(
        'Average session duration: '
        '${funnel.averageSessionSeconds.toStringAsFixed(1)}s',
      )
      ..writeln('Retention Health Index: ${healthIndex.toStringAsFixed(1)}%')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln();

    for (final line in heatmap) {
      buffer.writeln(line);
    }

    await File(_summaryOutPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry(
    _FunnelSummary funnel,
    double healthIndex,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_heatmap_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'sample_size': funnel.sampleSize,
      'average_session_seconds': funnel.averageSessionSeconds,
      'retention_health_index': healthIndex,
      'stage_conversions': [
        for (final conversion in funnel.conversions)
          {
            'from': conversion.from,
            'to': conversion.to,
            'percentage': conversion.percentage,
          },
      ],
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _FunnelSummary {
  _FunnelSummary({
    required this.conversions,
    required this.sampleSize,
    required this.averageSessionSeconds,
  });

  final List<_Conversion> conversions;
  final int sampleSize;
  final double averageSessionSeconds;
}

class _Conversion {
  _Conversion({required this.from, required this.to, required this.percentage});

  final String from;
  final String to;
  final double percentage;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory('release/_reports');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
