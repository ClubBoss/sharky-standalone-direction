import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final telemetryContent = await _readFileIfExists(
    'release/_reports/telemetry_dashboard.txt',
  );
  final aiContent = await _readFileIfExists(
    'release/_reports/ai_reliability_audit.txt',
  );
  final marketingContent = await _readFileIfExists(
    'release/_reports/marketing_summary.txt',
  );

  final metrics = <String, double>{
    'session_length':
        _extractMetric(telemetryContent, [
          'avg_session_length',
          'session_minutes',
        ]) ??
        0.0,
    'ai_accuracy':
        _extractPercent(aiContent, ['Win Rate', 'AI Accuracy']) ?? 0.0,
    'retention_7d':
        _extractPercent(telemetryContent, [
          'retention_7d',
          'retention_avg_7',
        ]) ??
        0.0,
    'retention_14d':
        _extractPercent(telemetryContent, [
          'retention_14d',
          'retention_avg_14',
        ]) ??
        0.0,
    'premium_conversion':
        _extractPercent(marketingContent, [
          'premium_conversion',
          'conversion_rate',
        ]) ??
        0.0,
  };

  final previous = await _loadPreviousMetrics();
  final deltas = <String, double>{};
  final warnings = <String>[];
  var hasCriticalDrop = false;
  metrics.forEach((key, value) {
    final oldValue = previous?[key];
    if (oldValue != null && oldValue > 0) {
      final delta = value - oldValue;
      deltas[key] = delta;
      final dropRatio = delta / oldValue;
      if (dropRatio <= -0.05) {
        warnings.add('$key drop ${_percent(dropRatio.abs())}');
      }
      if (dropRatio <= -0.10) {
        hasCriticalDrop = true;
      }
    } else {
      deltas[key] = double.nan;
    }
  });

  _printSummary(metrics, deltas, previous);

  await _writeReport(metrics, deltas, warnings);
  _emitTelemetry(metrics, deltas, warnings);

  if (hasCriticalDrop) {
    exit(1);
  }
}

Future<String> _readFileIfExists(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
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

double? _extractPercent(String content, List<String> keys) {
  final value = _extractMetric(content, keys);
  if (value == null) return null;
  return value > 1 ? value / 100 : value;
}

Future<Map<String, double>?> _loadPreviousMetrics() async {
  final file = File('release/_reports/softlaunch_feedback.txt');
  if (!await file.exists()) {
    return null;
  }
  final lines = await file.readAsLines();
  for (final line in lines.reversed) {
    if (line.startsWith('METRICS_JSON:')) {
      final jsonPart = line.substring('METRICS_JSON:'.length).trim();
      try {
        final decoded = jsonDecode(jsonPart);
        if (decoded is Map<String, dynamic>) {
          return decoded.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }
      } catch (_) {
        return null;
      }
    }
  }
  return null;
}

void _printSummary(
  Map<String, double> metrics,
  Map<String, double> deltas,
  Map<String, double>? previous,
) {
  final headers = ['Metric', 'Value', 'Delta', 'Trend'];
  final rows = <List<String>>[headers];
  metrics.forEach((key, value) {
    final delta = deltas[key];
    final percentMetric = _percentMetrics.contains(key);
    String deltaText;
    String trend;
    if (delta == null) {
      deltaText = '-';
      trend = '→';
    } else if (delta.isNaN) {
      deltaText = 'n/a';
      trend = '→';
    } else {
      if (percentMetric) {
        deltaText = delta >= 0
            ? '+${_percent(delta)}'
            : '-${_percent(delta.abs())}';
      } else {
        deltaText = delta >= 0
            ? '+${delta.toStringAsFixed(2)}'
            : '-${delta.abs().toStringAsFixed(2)}';
      }
      if (delta >= 0.001) {
        trend = '↑';
      } else if (delta <= -0.001) {
        trend = '↓';
      } else {
        trend = '→';
      }
    }
    rows.add([
      key,
      percentMetric ? _percent(value) : value.toStringAsFixed(2),
      deltaText,
      trend,
    ]);
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

Future<void> _writeReport(
  Map<String, double> metrics,
  Map<String, double> deltas,
  List<String> warnings,
) async {
  final buffer = StringBuffer()
    ..writeln('Soft Launch Feedback')
    ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('');
  metrics.forEach((key, value) {
    final delta = deltas[key];
    final isPercent = _percentMetrics.contains(key);
    final valueStr = isPercent
        ? '${(value * 100).toStringAsFixed(2)}%'
        : value.toStringAsFixed(2);
    final deltaStr = delta == null || delta.isNaN
        ? 'n/a'
        : isPercent
        ? '${(delta * 100).toStringAsFixed(2)}%'
        : delta.toStringAsFixed(2);
    buffer.writeln('$key: $valueStr (delta: $deltaStr)');
  });
  if (warnings.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('Warnings:');
    for (final warning in warnings) {
      buffer.writeln('- $warning');
    }
  }
  final file = File('release/_reports/softlaunch_feedback.txt');
  await file.parent.create(recursive: true);
  await file.writeAsString(
    '${buffer.toString()}\nMETRICS_JSON: ${jsonEncode(metrics)}\n',
  );
}

void _emitTelemetry(
  Map<String, double> metrics,
  Map<String, double> deltas,
  List<String> warnings,
) {
  final payload = <String, Object>{
    'event': 'softlaunch_feedback_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'metrics': metrics,
    'deltas': deltas.map(
      (key, value) => MapEntry(key, value.isNaN ? 'n/a' : value),
    ),
    'warnings': warnings,
  };
  stdout.writeln(jsonEncode(payload));
}

String _percent(double value) => '${(value * 100).toStringAsFixed(2)}%';

const Set<String> _percentMetrics = <String>{
  'ai_accuracy',
  'retention_7d',
  'retention_14d',
  'premium_conversion',
};
