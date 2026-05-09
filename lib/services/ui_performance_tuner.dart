import 'dart:convert';
import 'dart:io';

const String _qaSummaryPath = 'release/_reports/ui_micro_animation_summary.txt';
const String _outputPath = 'release/_reports/ui_performance_tuner_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _settingsPath = 'release/_reports/ui_motion_settings.json';

Future<void> main(List<String> args) async {
  final tuner = UiPerformanceTuner();
  await tuner.run();
}

class UiPerformanceTuner {
  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final stats = await _parseSummary();
    final settings = await _loadSettings();
    final adjustments = _computeAdjustments(stats);
    final updatedSettings = settings.apply(adjustments);

    await _withReportsWritable(() async {
      await updatedSettings.save(_settingsPath);
      await _writeSummary(
        stats: stats,
        adjustments: adjustments,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        adjustments: adjustments,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    stdout.writeln(
      'ui_performance_tuner: fast=${updatedSettings.fastDuration}ms '
      'medium=${updatedSettings.mediumDuration}ms '
      'slow=${updatedSettings.slowDuration}ms',
    );
  }

  Future<_QaStats> _parseSummary() async {
    final file = File(_qaSummaryPath);
    if (!await file.exists()) {
      throw StateError('UI micro animation summary missing at $_qaSummaryPath');
    }
    final lines = await file.readAsLines();
    double? p95Frame;
    final latency = <String, double>{};
    for (final line in lines) {
      if (line.startsWith('- P95')) {
        p95Frame = double.tryParse(
          line.split(':').last.trim().replaceFirst('ms', ''),
        );
      } else if (line.trim().startsWith('- ') &&
          line.contains('p95') &&
          line.contains('ms')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final name = parts.first.replaceFirst('- ', '').trim();
          final p95Part = parts.last
              .split('|')
              .firstWhere((part) => part.contains('p95'), orElse: () => '');
          if (p95Part.contains('p95')) {
            final value = double.tryParse(
              p95Part.replaceAll(RegExp('[^0-9.]'), ''),
            );
            if (value != null) {
              latency[name] = value;
            }
          }
        }
      }
    }

    if (p95Frame == null) {
      throw StateError('Unable to parse p95 frame time from summary.');
    }

    return _QaStats(p95Frame: p95Frame, categoryLatency: latency);
  }

  Future<_MotionSettings> _loadSettings() async {
    final file = File(_settingsPath);
    if (!await file.exists()) {
      return const _MotionSettings(
        fastDuration: 150,
        mediumDuration: 250,
        slowDuration: 350,
      );
    }
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        return _MotionSettings(
          fastDuration: data['fast'] as int? ?? 150,
          mediumDuration: data['medium'] as int? ?? 250,
          slowDuration: data['slow'] as int? ?? 350,
        );
      }
    } catch (_) {
      // fall back to defaults
    }
    return const _MotionSettings(
      fastDuration: 150,
      mediumDuration: 250,
      slowDuration: 350,
    );
  }

  _AdjustmentResult _computeAdjustments(_QaStats stats) {
    final double delta = stats.p95Frame > 16
        ? -0.1
        : (stats.p95Frame < 12 ? 0.1 : 0.0);
    final categoryAdjustments = stats.categoryLatency.map((category, value) {
      final adjustment = value > 300
          ? -0.08
          : value < 250
          ? 0.05
          : 0.0;
      return MapEntry(category, adjustment);
    });
    return _AdjustmentResult(
      globalScale: delta,
      categoryScales: categoryAdjustments,
    );
  }

  Future<void> _writeSummary({
    required _QaStats stats,
    required _AdjustmentResult adjustments,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('UI PERFORMANCE TUNER SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('p95 frame: ${stats.p95Frame.toStringAsFixed(2)}ms')
      ..writeln(
        'Global scale: ${(adjustments.globalScale * 100).toStringAsFixed(1)}%',
      )
      ..writeln()
      ..writeln('Category adjustments:');
    adjustments.categoryScales.forEach((category, value) {
      buffer.writeln('- $category: ${(value * 100).toStringAsFixed(1)}%');
    });
    buffer.writeln();

    await File(_outputPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry({
    required _AdjustmentResult adjustments,
    required int durationMs,
  }) async {
    final payload = <String, Object?>{
      'event': 'ui_performance_tuner_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'global_scale': adjustments.globalScale,
      'categories': adjustments.categoryScales,
      'duration_ms': durationMs,
    };

    await File(_telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _QaStats {
  const _QaStats({required this.p95Frame, required this.categoryLatency});

  final double p95Frame;
  final Map<String, double> categoryLatency;
}

class _MotionSettings {
  const _MotionSettings({
    required this.fastDuration,
    required this.mediumDuration,
    required this.slowDuration,
  });

  final int fastDuration;
  final int mediumDuration;
  final int slowDuration;

  _MotionSettings apply(_AdjustmentResult adjustments) {
    int scale(int value, double delta) =>
        (value * (1 + delta)).clamp(80, 600).round();

    final fast = scale(fastDuration, adjustments.globalScale);
    final medium = scale(mediumDuration, adjustments.globalScale);
    final slow = scale(slowDuration, adjustments.globalScale);
    return _MotionSettings(
      fastDuration: fast,
      mediumDuration: medium,
      slowDuration: slow,
    );
  }

  Future<void> save(String path) async {
    final payload = {
      'fast': fastDuration,
      'medium': mediumDuration,
      'slow': slowDuration,
    };
    await File(
      path,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }
}

class _AdjustmentResult {
  const _AdjustmentResult({
    required this.globalScale,
    required this.categoryScales,
  });

  final double globalScale;
  final Map<String, double> categoryScales;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
