import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _historyPath =
    'release/_reports/_regression_maintenance_history.json';
const String _statePath =
    'release/_reports/_regression_consolidation_state.json';
const String _summaryOutPath =
    'release/_reports/regression_consolidation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const Duration _staleThreshold = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final analyzer = RegressionConsolidationAnalyzer();
  await analyzer.run();
}

class RegressionConsolidationAnalyzer {
  Future<void> run() async {
    final reports = await _collectReportVerdicts();
    final history = await _loadHistory();
    final latestHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;
    final trendSlope = _computeTrendSlope(latestHistory);
    final currentRsi = latestHistory.isNotEmpty
        ? latestHistory.last.regressionStabilityIndex
        : 0.0;

    final stageStatuses = await _readStageStatuses();
    final streaks = await _updateStreaks(stageStatuses);
    final persistentFailures =
        streaks.entries
            .where((entry) => entry.value >= 3)
            .map((entry) => entry.key)
            .toList()
          ..sort();

    final difficulties =
        reports
            .map(
              (report) => _ReportDifficulty(
                name: report.name,
                path: report.path,
                verdict: report.verdict,
                index: _difficultyIndex(report.verdict, report.isStale),
                stale: report.isStale,
              ),
            )
            .toList()
          ..sort((a, b) => b.index.compareTo(a.index));

    final now = DateTime.now().toIso8601String();
    final verdict = (persistentFailures.isEmpty && currentRsi >= 90)
        ? 'PASS'
        : 'FAIL';

    await _withReportsWritable(() async {
      await _writeSummary(
        generatedAt: now,
        currentRsi: currentRsi,
        trendSlope: trendSlope,
        difficulties: difficulties,
        persistentFailures: persistentFailures,
        stageStatuses: stageStatuses,
        verdict: verdict,
      );
      await _writeState(streaks);
      await _emitTelemetry(
        generatedAt: now,
        currentRsi: currentRsi,
        trendSlope: trendSlope,
        difficulties: difficulties,
        persistentFailures: persistentFailures,
        verdict: verdict,
      );
    });

    if (verdict != 'PASS') {
      exitCode = 2;
    }
  }
}

Future<List<_ReportVerdict>> _collectReportVerdicts() async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) return const [];
  final reports = <_ReportVerdict>[];
  await for (final entity in dir.list()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.startsWith('regression_') && !name.startsWith('stability_')) {
      continue;
    }
    final verdict = await _extractVerdict(entity);
    final stat = await entity.stat();
    reports.add(
      _ReportVerdict(
        name: name,
        path: entity.path,
        verdict: verdict ?? 'UNKNOWN',
        modified: stat.modified.toUtc(),
      ),
    );
  }
  return reports;
}

Future<String?> _extractVerdict(File file) async {
  try {
    if (file.path.endsWith('.json')) {
      final dynamic decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final dynamic verdict =
            decoded['verdict'] ?? decoded['Verdict'] ?? decoded['status'];
        if (verdict is String && verdict.isNotEmpty) {
          return verdict.toUpperCase();
        }
      }
    } else {
      final lines = await file.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.toUpperCase().startsWith('VERDICT:')) {
          final value = trimmed.split(':').last.trim();
          if (value.isNotEmpty) return value.toUpperCase();
        }
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}

Future<List<_HistoryEntry>> _loadHistory() async {
  final file = File(_historyPath);
  if (!await file.exists()) return <_HistoryEntry>[];
  try {
    final dynamic decoded = json.decode(await file.readAsString());
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((entry) => _HistoryEntry.fromJson(entry.cast<String, Object?>()))
          .whereType<_HistoryEntry>()
          .toList();
    }
  } catch (_) {
    return <_HistoryEntry>[];
  }
  return <_HistoryEntry>[];
}

double _computeTrendSlope(List<_HistoryEntry> history) {
  if (history.length < 2) return 0;
  final first = history.first.regressionStabilityIndex;
  final last = history.last.regressionStabilityIndex;
  final runs = history.length - 1;
  return (last - first) / runs;
}

Future<List<_StageStatus>> _readStageStatuses() async {
  final file = File('release/_reports/regression_maintenance_summary.txt');
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final statuses = <_StageStatus>[];
  var inSection = false;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('Per-stage breakdown')) {
      inSection = true;
      continue;
    }
    if (inSection) {
      if (line.isEmpty) break;
      if (!line.startsWith('- ')) continue;
      final stageLine = line.substring(2);
      final colonIndex = stageLine.indexOf(':');
      if (colonIndex == -1) continue;
      final name = stageLine.substring(0, colonIndex).trim();
      final remainder = stageLine.substring(colonIndex + 1).trim();
      final verdictToken = remainder.split(' ').first.toUpperCase();
      statuses.add(_StageStatus(name: name, verdict: verdictToken));
    }
  }
  return statuses;
}

Future<Map<String, int>> _updateStreaks(List<_StageStatus> statuses) async {
  final file = File(_statePath);
  Map<String, int> streaks = {};
  if (await file.exists()) {
    try {
      final dynamic decoded = json.decode(await file.readAsString());
      if (decoded is Map) {
        streaks = decoded.map(
          (key, value) => MapEntry('$key', (value as num?)?.toInt() ?? 0),
        );
      }
    } catch (_) {
      streaks = {};
    }
  }

  final updated = Map<String, int>.from(streaks);
  for (final status in statuses) {
    final previous = streaks[status.name] ?? 0;
    if (status.verdict == 'FAIL') {
      updated[status.name] = previous + 1;
    } else {
      updated[status.name] = 0;
    }
  }
  return updated;
}

Future<void> _writeState(Map<String, int> streaks) async {
  final file = File(_statePath);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(streaks));
}

Future<void> _writeSummary({
  required String generatedAt,
  required double currentRsi,
  required double trendSlope,
  required List<_ReportDifficulty> difficulties,
  required List<String> persistentFailures,
  required List<_StageStatus> stageStatuses,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION CONSOLIDATION SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: $generatedAt')
    ..writeln('Current RSI: ${currentRsi.toStringAsFixed(2)}%')
    ..writeln('RSI Trend (Δ/run): ${trendSlope.toStringAsFixed(2)}')
    ..writeln('Verdict: $verdict')
    ..writeln();

  if (persistentFailures.isEmpty) {
    buffer.writeln('Persistent failures: none detected');
  } else {
    buffer.writeln('Persistent failures (≥3 consecutive FAIL):');
    for (final name in persistentFailures) {
      final stage = stageStatuses.firstWhere(
        (s) => s.name == name,
        orElse: () => _StageStatus(name: name, verdict: 'FAIL'),
      );
      buffer.writeln('- $name (${stage.verdict})');
    }
  }

  buffer
    ..writeln()
    ..writeln('Recovery difficulty index (higher = harder):');
  for (final entry in difficulties) {
    buffer.writeln(
      '- ${entry.name}: ${entry.index.toStringAsFixed(1)} '
      '(${entry.verdict}${entry.stale ? ', stale' : ''})',
    );
  }

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required String generatedAt,
  required double currentRsi,
  required double trendSlope,
  required List<_ReportDifficulty> difficulties,
  required List<String> persistentFailures,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_consolidation_completed',
    'timestamp': generatedAt,
    'current_rsi': currentRsi,
    'trend_slope': trendSlope,
    'persistent_failures': persistentFailures,
    'verdict': verdict,
    'reports': [
      for (final entry in difficulties)
        {
          'name': entry.name,
          'verdict': entry.verdict,
          'difficulty_index': entry.index,
          'stale': entry.stale,
        },
    ],
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

double _difficultyIndex(String verdict, bool isStale) {
  double base;
  switch (verdict) {
    case 'PASS':
      base = 20;
      break;
    case 'WARN':
      base = 55;
      break;
    case 'FAIL':
      base = 90;
      break;
    default:
      base = 65;
  }
  if (isStale) base += 5;
  return base;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod fails
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

class _ReportVerdict {
  _ReportVerdict({
    required this.name,
    required this.path,
    required this.verdict,
    required this.modified,
  });

  final String name;
  final String path;
  final String verdict;
  final DateTime modified;

  bool get isStale =>
      DateTime.now().toUtc().difference(modified) > _staleThreshold;
}

class _ReportDifficulty {
  _ReportDifficulty({
    required this.name,
    required this.path,
    required this.verdict,
    required this.index,
    required this.stale,
  });

  final String name;
  final String path;
  final String verdict;
  final double index;
  final bool stale;
}

class _HistoryEntry {
  _HistoryEntry({
    required this.timestamp,
    required this.regressionStabilityIndex,
  });

  final DateTime timestamp;
  final double regressionStabilityIndex;

  static _HistoryEntry? fromJson(Map<String, Object?> json) {
    final timestampRaw = json['timestamp']?.toString();
    final rsiRaw = json['regression_stability_index'];
    if (timestampRaw == null || rsiRaw == null) return null;
    final timestamp = DateTime.tryParse(timestampRaw);
    final rsi = (rsiRaw as num?)?.toDouble();
    if (timestamp == null || rsi == null) return null;
    return _HistoryEntry(timestamp: timestamp, regressionStabilityIndex: rsi);
  }
}

class _StageStatus {
  _StageStatus({required this.name, required this.verdict});

  final String name;
  final String verdict;
}
