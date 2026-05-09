import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final monitor = _UxCalibrationMonitor();
  try {
    final result = await monitor.run();
    await monitor.writeSummary(result);
    await monitor.emitTelemetry(result);
  } finally {
    await monitor.restorePermissions();
  }
}

class _UxCalibrationMonitor {
  bool _reportsWritable = false;

  Future<_CalibrationResult> run() async {
    final watch = Stopwatch()..start();
    final metrics = await _readUxMetrics();
    final dashboard = await _readDashboardSummary();
    final visual = await _readVisualSummary();
    final previous = await _readPreviousSummary();
    watch.stop();

    final fallbackPrevious =
        previous ??
        _BaselineMetrics(
          fps: metrics.avgFps,
          stability: metrics.stability,
          peakMemMb: metrics.peakMemMb,
          uiTokens: visual.totalTokens.toDouble(),
        );

    final drifts = _DriftMetrics(
      fps: metrics.avgFps - fallbackPrevious.fps,
      stability: metrics.stability - fallbackPrevious.stability,
      peakMemMb: metrics.peakMemMb - fallbackPrevious.peakMemMb,
      uiTokens: visual.totalTokens.toDouble() - fallbackPrevious.uiTokens,
    );

    return _CalibrationResult(
      timestamp: DateTime.now().toUtc(),
      metrics: metrics,
      dashboard: dashboard,
      visual: visual,
      previous: fallbackPrevious,
      drifts: drifts,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_UxMetrics> _readUxMetrics() async {
    final file = File('release/_exports/ux_metrics.json');
    if (!file.existsSync()) {
      throw StateError('release/_exports/ux_metrics.json is missing.');
    }
    final dynamic decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('ux_metrics.json must contain a JSON object.');
    }

    double readDouble(String key) {
      final value = decoded[key];
      if (value is num) {
        return value.toDouble();
      }
      throw StateError('Missing numeric "$key" in ux_metrics.json');
    }

    return _UxMetrics(
      timestamp: _tryParseIso(decoded['timestamp'] as String?),
      avgFps: readDouble('avg_fps'),
      stability: readDouble('stability_score'),
      peakMemMb: readDouble('peak_mem_mb'),
    );
  }

  Future<_DashboardSummary> _readDashboardSummary() async {
    final file = File('release/_reports/ux_dashboard_summary.txt');
    if (!file.existsSync()) {
      throw StateError('release/_reports/ux_dashboard_summary.txt missing.');
    }
    final lines = await file.readAsLines();
    DateTime? timestamp;
    int? warnings;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Timestamp:')) {
        timestamp = _tryParseIso(trimmed.split(':').skip(1).join(':').trim());
        continue;
      }
      if (!line.startsWith('|')) continue;
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 5 || parts[1].isEmpty) continue;
      if (parts[1] == 'Warnings') {
        warnings = int.tryParse(parts[2]);
      }
    }
    return _DashboardSummary(timestamp: timestamp, warnings: warnings ?? 0);
  }

  Future<_VisualSummary> _readVisualSummary() async {
    final paths = <String>[
      'release/_reports/visual_retrospective_summary.md',
      'release/_exports/visual_retrospective_summary.md',
    ];
    File? file;
    for (final path in paths) {
      final candidate = File(path);
      if (candidate.existsSync()) {
        file = candidate;
        break;
      }
    }
    file ??= File(paths.last);
    if (!file.existsSync()) {
      throw StateError('visual_retrospective_summary.md not found.');
    }

    final lines = await file.readAsLines();
    DateTime? generated;
    final tokens = <String, int>{};
    final tokenPattern = RegExp(r'^-\s+([A-Za-z ]+):\s*(\d+)');
    var inTokenInventory = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Generated:')) {
        generated = _tryParseIso(trimmed.substring('Generated:'.length).trim());
        continue;
      }
      if (trimmed.startsWith('## ')) {
        inTokenInventory = trimmed == '## Token Inventory';
        continue;
      }
      if (!inTokenInventory) continue;
      final match = tokenPattern.firstMatch(trimmed);
      if (match != null) {
        final label = match.group(1)!.trim();
        final value = int.parse(match.group(2)!);
        tokens[label] = value;
      }
    }
    final totalTokens = tokens.values.fold<int>(0, (sum, value) => sum + value);
    return _VisualSummary(
      timestamp: generated,
      tokens: tokens,
      totalTokens: totalTokens,
    );
  }

  Future<_BaselineMetrics?> _readPreviousSummary() async {
    final file = File('release/_reports/ux_calibration_summary.txt');
    if (!file.existsSync()) {
      return null;
    }
    try {
      final lines = await file.readAsLines();
      double? fps;
      double? stability;
      double? peakMem;
      double? uiTokens;
      for (final line in lines) {
        if (!line.startsWith('|')) continue;
        final parts = line.split('|').map((p) => p.trim()).toList();
        if (parts.length < 5) continue;
        final metric = parts[1];
        final currentValue = double.tryParse(parts[2]);
        if (currentValue == null) continue;
        switch (metric) {
          case _MetricConfigs.fpsLabel:
            fps = currentValue;
            break;
          case _MetricConfigs.stabilityLabel:
            stability = currentValue;
            break;
          case _MetricConfigs.memoryLabel:
            peakMem = currentValue;
            break;
          case _MetricConfigs.uiTokensLabel:
            uiTokens = currentValue;
            break;
        }
      }
      if (fps == null ||
          stability == null ||
          peakMem == null ||
          uiTokens == null) {
        return null;
      }
      return _BaselineMetrics(
        fps: fps,
        stability: stability,
        peakMemMb: peakMem,
        uiTokens: uiTokens,
      );
    } on FileSystemException {
      return null;
    }
  }

  Future<void> writeSummary(_CalibrationResult result) async {
    final buffer = StringBuffer()
      ..writeln('UX Calibration Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Sources:')
      ..writeln('  - UX metrics: ${_formatSource(result.metrics.timestamp)}')
      ..writeln(
        '  - UX dashboard: ${_formatSource(result.dashboard.timestamp)}',
      )
      ..writeln(
        '  - Visual retrospective: ${_formatSource(result.visual.timestamp)}',
      )
      ..writeln()
      ..writeln('| Metric | Current | Previous | Drift | Status | Notes |')
      ..writeln('|--------|---------|----------|-------|--------|-------|');

    void addMetric(
      _MetricConfig config,
      double current,
      double previous,
      double drift,
    ) {
      buffer.writeln(
        '| ${config.label} | '
        '${current.toStringAsFixed(config.decimals)} | '
        '${previous.toStringAsFixed(config.decimals)} | '
        '${_formatSigned(drift, config.decimals)} | '
        '${_statusFor(config, drift)} | '
        '${config.notes} |',
      );
    }

    addMetric(
      _MetricConfigs.fps,
      result.metrics.avgFps,
      result.previous.fps,
      result.drifts.fps,
    );
    addMetric(
      _MetricConfigs.stability,
      result.metrics.stability,
      result.previous.stability,
      result.drifts.stability,
    );
    addMetric(
      _MetricConfigs.memory,
      result.metrics.peakMemMb,
      result.previous.peakMemMb,
      result.drifts.peakMemMb,
    );
    addMetric(
      _MetricConfigs.uiTokens,
      result.visual.totalTokens.toDouble(),
      result.previous.uiTokens,
      result.drifts.uiTokens,
    );

    buffer
      ..writeln()
      ..writeln('Token Inventory')
      ..writeln('| Token | Count |')
      ..writeln('|-------|-------|');
    if (result.visual.tokens.isEmpty) {
      buffer.writeln('| (none) | 0 |');
    } else {
      for (final entry in result.visual.tokens.entries) {
        buffer.writeln('| ${entry.key} | ${entry.value} |');
      }
    }

    buffer
      ..writeln()
      ..writeln('Warnings observed: ${result.dashboard.warnings}')
      ..writeln('Runtime (ms): ${result.durationMs}');

    await _writeReportsFile(
      'release/_reports/ux_calibration_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_CalibrationResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.uxCalibrationCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'fps_drift': _round(result.drifts.fps, 3),
      'stability_drift': _round(result.drifts.stability, 4),
      'ui_drift': _round(result.drifts.uiTokens, 2),
      'duration_ms': result.durationMs,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    try {
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  String _statusFor(_MetricConfig config, double drift) {
    final degrade = config.higherIsBetter ? -drift : drift;
    if (degrade <= 0) return 'PASS';
    if (degrade <= config.warnThreshold) return 'PASS';
    if (degrade <= config.failThreshold) return 'WARN';
    return 'FAIL';
  }

  double _round(double value, int precision) {
    final mod = math.pow(10, precision).toDouble();
    return (value * mod).round() / mod;
  }

  String _formatSigned(double value, int decimals) {
    final rounded = value.toStringAsFixed(decimals);
    if (value > 0) {
      return '+$rounded';
    }
    return rounded;
  }

  String _formatSource(DateTime? timestamp) =>
      timestamp?.toIso8601String() ?? 'unknown';

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _UxMetrics {
  _UxMetrics({
    required this.timestamp,
    required this.avgFps,
    required this.stability,
    required this.peakMemMb,
  });

  final DateTime? timestamp;
  final double avgFps;
  final double stability;
  final double peakMemMb;
}

class _DashboardSummary {
  _DashboardSummary({required this.timestamp, required this.warnings});

  final DateTime? timestamp;
  final int warnings;
}

class _VisualSummary {
  _VisualSummary({
    required this.timestamp,
    required this.tokens,
    required this.totalTokens,
  });

  final DateTime? timestamp;
  final Map<String, int> tokens;
  final int totalTokens;
}

class _BaselineMetrics {
  _BaselineMetrics({
    required this.fps,
    required this.stability,
    required this.peakMemMb,
    required this.uiTokens,
  });

  final double fps;
  final double stability;
  final double peakMemMb;
  final double uiTokens;
}

class _DriftMetrics {
  _DriftMetrics({
    required this.fps,
    required this.stability,
    required this.peakMemMb,
    required this.uiTokens,
  });

  final double fps;
  final double stability;
  final double peakMemMb;
  final double uiTokens;
}

class _CalibrationResult {
  _CalibrationResult({
    required this.timestamp,
    required this.metrics,
    required this.dashboard,
    required this.visual,
    required this.previous,
    required this.drifts,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _UxMetrics metrics;
  final _DashboardSummary dashboard;
  final _VisualSummary visual;
  final _BaselineMetrics previous;
  final _DriftMetrics drifts;
  final int durationMs;
}

class _MetricConfig {
  const _MetricConfig({
    required this.label,
    required this.notes,
    required this.higherIsBetter,
    required this.warnThreshold,
    required this.failThreshold,
    required this.decimals,
  });

  final String label;
  final String notes;
  final bool higherIsBetter;
  final double warnThreshold;
  final double failThreshold;
  final int decimals;
}

class _MetricConfigs {
  static const String fpsLabel = 'FPS';
  static const String stabilityLabel = 'Stability';
  static const String memoryLabel = 'Peak Mem (MB)';
  static const String uiTokensLabel = 'UI Tokens';

  static const _MetricConfig fps = _MetricConfig(
    label: fpsLabel,
    notes: 'Higher is better (target ≥60 FPS)',
    higherIsBetter: true,
    warnThreshold: 0.3,
    failThreshold: 0.8,
    decimals: 2,
  );

  static const _MetricConfig stability = _MetricConfig(
    label: stabilityLabel,
    notes: 'Composite stability score',
    higherIsBetter: true,
    warnThreshold: 0.005,
    failThreshold: 0.02,
    decimals: 3,
  );

  static const _MetricConfig memory = _MetricConfig(
    label: memoryLabel,
    notes: 'Lower peak memory is better',
    higherIsBetter: false,
    warnThreshold: 5.0,
    failThreshold: 15.0,
    decimals: 1,
  );

  static const _MetricConfig uiTokens = _MetricConfig(
    label: uiTokensLabel,
    notes: 'Token adoption (sum of visual tokens)',
    higherIsBetter: true,
    warnThreshold: 1.0,
    failThreshold: 3.0,
    decimals: 0,
  );
}

DateTime? _tryParseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}
