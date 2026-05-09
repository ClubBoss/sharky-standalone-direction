import 'dart:convert';
import 'dart:io';

const String _protectionSummary =
    'release/_reports/regression_protection_summary.txt';
const String _historyPath = 'release/_reports/regression_metrics_history.json';
const String _summaryPath = 'release/_reports/regression_metrics_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const int _historyLimit = 10;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final latest = await _parseProtectionSummary();
  var history = await _loadHistory();

  history.insert(0, latest);
  if (history.length > _historyLimit) {
    history = history.sublist(0, _historyLimit);
  }

  final averages = _computeAverages(history);
  final trend = _determineTrend(history);

  await _withReportsWritable(() async {
    await _writeHistory(history);
    await _writeSummary(
      averages: averages,
      trend: trend,
      historyCount: history.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _appendTelemetry(
      index: averages.index,
      trend: trend,
      historyCount: history.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'regression_metrics_aggregator: history=${history.length} '
    'index=${averages.index.toStringAsFixed(1)}% trend=$trend',
  );
}

Future<_RunRecord> _parseProtectionSummary() async {
  final file = File(_protectionSummary);
  if (!await file.exists()) {
    throw StateError('Protection summary missing: $_protectionSummary');
  }

  final content = await file.readAsLines();
  double? index;
  final toolResults = <String, bool>{};

  for (final line in content) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Regression Health Index')) {
      final match = RegExp(r'([\d.]+)%').firstMatch(trimmed);
      if (match != null) {
        index = double.tryParse(match.group(1)!);
      }
    } else if (trimmed.startsWith('Tool:')) {
      final match = RegExp(
        r'Tool:\s+(\w+)\s+→\s+(PASS|FAIL)',
      ).firstMatch(trimmed);
      if (match != null) {
        final name = match.group(1)!;
        final status = match.group(2)! == 'PASS';
        toolResults[name] = status;
      }
    }
  }

  if (index == null || toolResults.isEmpty) {
    throw StateError('Regression summary is missing required fields.');
  }

  return _RunRecord(
    timestamp: DateTime.now().toIso8601String(),
    index: index,
    toolStatus: toolResults,
  );
}

Future<List<_RunRecord>> _loadHistory() async {
  final file = File(_historyPath);
  if (!await file.exists()) return [];
  try {
    final raw = json.decode(await file.readAsString());
    if (raw is! List) throw FormatException('History file is not a list');
    return raw.map<_RunRecord>((entry) {
      if (entry is! Map<String, dynamic>) {
        throw FormatException('History entry is not a map');
      }
      return _RunRecord.fromJson(entry);
    }).toList();
  } catch (e) {
    throw StateError('History file corrupt: $e');
  }
}

_Averages _computeAverages(List<_RunRecord> history) {
  if (history.isEmpty) {
    return const _Averages(index: 0, toolPassRate: 0);
  }
  final indexAvg =
      history.map((r) => r.index).reduce((a, b) => a + b) / history.length;
  final tools = <String>{};
  for (final run in history) {
    tools.addAll(run.toolStatus.keys);
  }
  var passSum = 0.0;
  for (final tool in tools) {
    final passes = history.where((run) => run.toolStatus[tool] ?? false).length;
    passSum += passes / history.length;
  }
  final toolRate = tools.isEmpty ? 0.0 : (passSum / tools.length) * 100;
  return _Averages(index: indexAvg, toolPassRate: toolRate);
}

String _determineTrend(List<_RunRecord> history) {
  if (history.length < 2) return 'stable';
  final recent = history.first.index;
  final previous = history.skip(1).first.index;
  if (recent >= previous + 1) return '↑ improving';
  if (recent <= previous - 1) return '↓ regressing';
  return '→ stable';
}

Future<void> _writeHistory(List<_RunRecord> history) async {
  final encoder = const JsonEncoder.withIndent('  ');
  await File(_historyPath).writeAsString(
    '${encoder.convert(history.map((r) => r.toJson()).toList())}\n',
  );
}

Future<void> _writeSummary({
  required _Averages averages,
  required String trend,
  required int historyCount,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION METRICS SUMMARY')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('History length: $historyCount')
    ..writeln(
      'Rolling index: ${averages.index.toStringAsFixed(1)}%   '
      'Tool pass rate: ${averages.toolPassRate.toStringAsFixed(1)}%',
    )
    ..writeln('Trend: $trend')
    ..writeln('Duration: ${durationMs}ms');

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double index,
  required String trend,
  required int historyCount,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_metrics_updated',
    'timestamp': DateTime.now().toIso8601String(),
    'rolling_index': double.parse(index.toStringAsFixed(1)),
    'trend': trend,
    'history_count': historyCount,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
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
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'regression_metrics_aggregator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _RunRecord {
  const _RunRecord({
    required this.timestamp,
    required this.index,
    required this.toolStatus,
  });

  factory _RunRecord.fromJson(Map<String, dynamic> json) {
    final toolStatus = json['tool_status'] as Map<String, dynamic>? ?? const {};
    return _RunRecord(
      timestamp: json['timestamp']?.toString() ?? '',
      index: (json['index'] as num?)?.toDouble() ?? 0,
      toolStatus: toolStatus.map((key, value) => MapEntry(key, value == true)),
    );
  }

  final String timestamp;
  final double index;
  final Map<String, bool> toolStatus;

  Map<String, Object?> toJson() => {
    'timestamp': timestamp,
    'index': index,
    'tool_status': toolStatus,
  };
}

class _Averages {
  const _Averages({required this.index, required this.toolPassRate});

  final double index;
  final double toolPassRate;
}
