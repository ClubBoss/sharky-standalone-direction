import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final data = await _loadTelemetryData();
  final currentMetrics = _computeMetrics(data);
  final previous = await _loadPreviousSnapshot();
  final deltas = _computeDeltas(previous, currentMetrics);

  final warnings = _detectDrift(deltas, threshold: 0.03);
  final hotfixTriggered =
      warnings.isNotEmpty && warnings.any((warning) => warning.isCritical);

  _printSummary(currentMetrics, deltas, warnings);

  await _writeSnapshot(currentMetrics);

  if (hotfixTriggered) {
    await _writeHotfixFile(warnings);
    _emitTelemetry(
      'postlaunch_hotfix_triggered',
      currentMetrics,
      deltas,
      warnings,
    );
    exit(1);
  } else {
    _emitTelemetry(
      'postlaunch_monitor_completed',
      currentMetrics,
      deltas,
      warnings,
    );
  }
}

Future<_TelemetryData> _loadTelemetryData() async {
  final finalSummary = await _readFileIfExists(
    'release/_reports/final_release_summary.txt',
  );
  final softLaunch = await _readFileIfExists(
    'release/_reports/softlaunch_feedback.txt',
  );
  final aiReliability = await _readFileIfExists(
    'release/_reports/ai_reliability_audit.txt',
  );
  return _TelemetryData(
    finalSummary: finalSummary,
    softLaunch: softLaunch,
    aiReliability: aiReliability,
  );
}

Map<String, double> _computeMetrics(_TelemetryData data) {
  return <String, double>{
    'crash_free_7d':
        _extractPercent(data.finalSummary, ['crash_free_7d', 'crash_free']) ??
        0.0,
    'crash_free_14d':
        _extractPercent(data.finalSummary, ['crash_free_14d']) ?? 0.0,
    'ai_errors':
        _extractPercent(data.aiReliability, ['Deviation', 'ai_error_rate']) ??
        0.0,
    'monetization_7d':
        _extractMetric(data.softLaunch, ['monetization_events_7d']) ?? 0.0,
    'monetization_14d':
        _extractMetric(data.softLaunch, ['monetization_events_14d']) ?? 0.0,
  };
}

Future<Map<String, double>?> _loadPreviousSnapshot() async {
  final file = File('release/_reports/postlaunch_monitor.json');
  if (!await file.exists()) {
    return null;
  }
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, dynamic>) {
      return decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }
  } catch (_) {
    return null;
  }
  return null;
}

Map<String, double?> _computeDeltas(
  Map<String, double>? previous,
  Map<String, double> current,
) {
  final deltas = <String, double?>{};
  current.forEach((key, value) {
    final oldValue = previous?[key];
    if (oldValue == null) {
      deltas[key] = null;
    } else {
      deltas[key] = value - oldValue;
    }
  });
  return deltas;
}

List<_Warning> _detectDrift(
  Map<String, double?> deltas, {
  required double threshold,
}) {
  final warnings = <_Warning>[];
  deltas.forEach((key, delta) {
    if (delta == null) return;
    final isPercentMetric = _percentMetrics.contains(key);
    final normalized = isPercentMetric ? delta : delta;
    if (key == 'ai_errors') {
      if (normalized > threshold) {
        warnings.add(_Warning(key: key, delta: normalized, isCritical: true));
      }
    } else if (key.startsWith('monetization')) {
      if (normalized < -threshold) {
        warnings.add(_Warning(key: key, delta: normalized, isCritical: false));
      }
    } else {
      if (normalized < -threshold) {
        warnings.add(_Warning(key: key, delta: normalized, isCritical: false));
      }
    }
  });
  return warnings;
}

void _printSummary(
  Map<String, double> metrics,
  Map<String, double?> deltas,
  List<_Warning> warnings,
) {
  final headers = ['Metric', 'Value', 'Delta', 'Status'];
  final rows = <List<String>>[headers];
  metrics.forEach((key, value) {
    final delta = deltas[key];
    final isPercent = _percentMetrics.contains(key) || key == 'ai_errors';
    final valueStr = isPercent ? _percent(value) : value.toStringAsFixed(2);
    final deltaStr = delta == null
        ? 'n/a'
        : isPercent
        ? _percent(delta)
        : delta.toStringAsFixed(2);
    final status = warnings.any((w) => w.key == key) ? 'WARN' : 'OK';
    rows.add([key, valueStr, deltaStr, status]);
  });
  final widths = List<int>.filled(headers.length, 0);
  for (final row in rows) {
    for (var i = 0; i < row.length; i++) {
      widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
    }
  }
  final border =
      '+-${List.generate(widths.length, (i) => '-' * widths[i]).join('-+-')}-+';
  stdout.writeln(border);
  stdout.writeln(_formatRow(rows.first, widths));
  stdout.writeln(border);
  for (final row in rows.skip(1)) {
    stdout.writeln(_formatRow(row, widths));
  }
  stdout.writeln(border);
}

String _formatRow(List<String> row, List<int> widths) {
  final cells = <String>[];
  for (var i = 0; i < row.length; i++) {
    cells.add(row[i].padRight(widths[i]));
  }
  return '| ${cells.join(' | ')} |';
}

Future<void> _writeSnapshot(Map<String, double> metrics) async {
  final file = File('release/_reports/postlaunch_monitor.json');
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(metrics));
}

Future<void> _writeHotfixFile(List<_Warning> warnings) async {
  final file = File('release/_reports/postlaunch_hotfix_required.txt');
  await file.parent.create(recursive: true);
  final buffer = StringBuffer()
    ..writeln('Hotfix required due to:')
    ..writeln(DateTime.now().toUtc().toIso8601String());
  for (final warning in warnings) {
    buffer.writeln('- ${warning.key}: ${warning.delta.toStringAsFixed(4)}');
  }
  await file.writeAsString(buffer.toString());
}

void _emitTelemetry(
  String event,
  Map<String, double> metrics,
  Map<String, double?> deltas,
  List<_Warning> warnings,
) {
  final payload = <String, Object>{
    'event': event,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'metrics': metrics,
    'deltas': deltas.map((key, value) => MapEntry(key, value ?? 'n/a')),
    'warnings': warnings
        .map(
          (warning) => {
            'metric': warning.key,
            'delta': warning.delta,
            'critical': warning.isCritical,
          },
        )
        .toList(),
  };
  stdout.writeln(jsonEncode(payload));
}

String _percent(double value) => '${(value * 100).toStringAsFixed(2)}%';

double? _extractPercent(String content, List<String> keys) {
  final metric = _extractMetric(content, keys);
  if (metric == null) return null;
  return metric > 1 ? metric / 100 : metric;
}

double? _extractMetric(String content, List<String> keys) {
  if (content.isEmpty) return null;
  for (final key in keys) {
    final regex = RegExp(
      '$key\\s*[:=]\\s*([0-9]+\\.?[0-9]*)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(content);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
  }
  return null;
}

Future<String> _readFileIfExists(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
}

const Set<String> _percentMetrics = <String>{'crash_free_7d', 'crash_free_14d'};

class _TelemetryData {
  _TelemetryData({
    required this.finalSummary,
    required this.softLaunch,
    required this.aiReliability,
  });

  final String finalSummary;
  final String softLaunch;
  final String aiReliability;
}

class _Warning {
  const _Warning({
    required this.key,
    required this.delta,
    required this.isCritical,
  });

  final String key;
  final double delta;
  final bool isCritical;
}
