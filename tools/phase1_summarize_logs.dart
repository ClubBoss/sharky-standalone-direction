import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const _sessionStart = 'PHASE1_SESSION_START';
const _attemptStart = 'PHASE1_ATTEMPT_START';
const _attemptResult = 'PHASE1_ATTEMPT_RESULT';
const _flowEnd = 'PHASE1_FLOW_END';
const _schema = 'phase1_summary_v1';
const _keyOrder = [
  'schema',
  'generated_at_utc',
  'event',
  'total_runs',
  'flow_end_count',
  'attempt_start_count',
  'attempt_result_count',
  'correct_count',
  'incorrect_count',
  'decision_time_samples_count',
  'missing_runs',
  'ok',
];

void main(List<String> args) {
  final parser = _ArgParser(args);
  if (!parser.valid) {
    stderr.writeln(parser.usage);
    exit(1);
  }

  final runs = <String, _RunRecord>{};
  for (final input in parser.paths) {
    final file = File(input);
    if (!file.existsSync()) {
      stderr.writeln('Input file missing: $input');
      exit(1);
    }
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (!line.contains(_sessionStart) &&
          !line.contains(_attemptStart) &&
          !line.contains(_attemptResult) &&
          !line.contains(_flowEnd))
        continue;
      final marker = _detectMarker(line);
      final payload = _parsePayload(line, marker);
      final runId = payload['run_id'] as String?;
      if (runId == null || runId.isEmpty) continue;
      final record = runs.putIfAbsent(runId, () => _RunRecord(runId));
      record.kick(marker, payload);
    }
  }

  final flowEndCount = runs.values.where((record) => record.flowEnd).length;
  final totalRuns = flowEndCount;
  final attemptStartCount = runs.values
      .map((r) => r.attemptStartCount)
      .fold<int>(0, (a, b) => a + b);
  final attemptResultCount = runs.values
      .map((r) => r.attemptResultCount)
      .fold<int>(0, (a, b) => a + b);
  final correctCount = runs.values
      .map((r) => r.correctCount)
      .fold<int>(0, (a, b) => a + b);
  final incorrectCount = runs.values
      .map((r) => r.incorrectCount)
      .fold<int>(0, (a, b) => a + b);
  final decisionTimeCount = runs.values
      .map((r) => r.decisionTimeSamples)
      .fold<int>(0, (a, b) => a + b);
  final missingRuns = runs.values
      .where((record) => record.hasActivity && !record.flowEnd)
      .map((r) => r.runId)
      .toList();
  final ok =
      flowEndCount >= parser.minRuns &&
      (!parser.failOnMissing || missingRuns.isEmpty);

  final summary = LinkedHashMap<String, Object?>()
    ..['schema'] = _schema
    ..['generated_at_utc'] = DateTime.now().toUtc().toIso8601String()
    ..['event'] = 'PHASE1_LOG_SUMMARY'
    ..['total_runs'] = totalRuns
    ..['flow_end_count'] = flowEndCount
    ..['attempt_start_count'] = attemptStartCount
    ..['attempt_result_count'] = attemptResultCount
    ..['correct_count'] = correctCount
    ..['incorrect_count'] = incorrectCount
    ..['decision_time_samples_count'] = decisionTimeCount
    ..['missing_runs'] = missingRuns
    ..['ok'] = ok;

  assert(() {
    final keys = summary.keys.toList();
    if (keys.length != _keyOrder.length) return true;
    for (var i = 0; i < keys.length; i++) {
      if (keys[i] != _keyOrder[i]) {
        throw StateError(
          'Phase1 summary key order drift: expected "${_keyOrder[i]}" at $i but got "${keys[i]}"',
        );
      }
    }
    return true;
  }());

  stdout.writeln(jsonEncode(summary));

  if (parser.exportMode) {
    final runExports = runs.values.toList()
      ..sort((a, b) => a.runId.compareTo(b.runId));
    final exportRecords = runExports
        .map(
          (record) => LinkedHashMap<String, Object?>.from(record.toExportRow()),
        )
        .toList();
    final exportLine = LinkedHashMap<String, Object?>()
      ..['event'] = 'PHASE1_EXPORT'
      ..['runs'] = exportRecords;
    stdout.writeln(jsonEncode(exportLine));
  }

  if (parser.failOnMissing && missingRuns.isNotEmpty) {
    exit(2);
  }
  if (flowEndCount < parser.minRuns) {
    exit(3);
  }
  exit(0);
}

String _detectMarker(String line) {
  if (line.contains(_flowEnd)) return _flowEnd;
  if (line.contains(_attemptResult)) return _attemptResult;
  if (line.contains(_attemptStart)) return _attemptStart;
  return _sessionStart;
}

Map<String, dynamic> _parsePayload(String line, String marker) {
  final idx = line.indexOf(marker);
  if (idx == -1) throw FormatException('Missing marker $marker');
  final start = line.indexOf('{', idx);
  if (start == -1) {
    return {};
  }
  final jsonPart = line.substring(start).trim();
  return jsonDecode(jsonPart) as Map<String, dynamic>;
}

class _RunRecord {
  final String runId;
  bool flowEnd = false;
  bool hasActivity = false;
  int attemptStartCount = 0;
  int attemptResultCount = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  int decisionTimeSamples = 0;
  final List<double> _decisionTimes = [];

  _RunRecord(this.runId);

  void kick(String marker, Map<String, dynamic> payload) {
    hasActivity = true;
    switch (marker) {
      case _sessionStart:
        break;
      case _attemptStart:
        attemptStartCount++;
        break;
      case _attemptResult:
        attemptResultCount++;
        final result = payload['result'] as String?;
        if (result == 'correct') {
          correctCount++;
        } else {
          incorrectCount++;
        }
        if (payload.containsKey('decision_time_ms')) {
          final duration = payload['decision_time_ms'];
          if (duration is num) {
            decisionTimeSamples++;
            _decisionTimes.add(duration.toDouble());
          }
        }
        break;
      case _flowEnd:
        flowEnd = true;
        break;
    }
  }

  List<double> get _sortedDecisionTimes {
    final sorted = _decisionTimes.toList();
    sorted.sort();
    return sorted;
  }

  // Linear interpolation for percentile ensures deterministic output even for small samples.
  double? _percentile(double percentile) {
    final values = _sortedDecisionTimes;
    if (values.isEmpty) return null;
    final index = (values.length - 1) * percentile;
    final lowerIndex = index.floor();
    final upperIndex = index.ceil();
    if (lowerIndex == upperIndex) return values[lowerIndex];
    final lower = values[lowerIndex];
    final upper = values[upperIndex];
    return lower + (upper - lower) * (index - lowerIndex);
  }

  double? get decisionTimeMean => _sortedDecisionTimes.isEmpty
      ? null
      : _sortedDecisionTimes.reduce((a, b) => a + b) /
            _sortedDecisionTimes.length;

  double? get decisionTimeMin =>
      _sortedDecisionTimes.isEmpty ? null : _sortedDecisionTimes.first;

  Map<String, Object?> toExportRow() {
    return LinkedHashMap<String, Object?>()
      ..['run_id'] = runId
      ..['total_attempts'] = attemptResultCount
      ..['correct_count'] = correctCount
      ..['incorrect_count'] = incorrectCount
      ..['decision_time_ms_min'] = decisionTimeMin
      ..['decision_time_ms_p50'] = _percentile(0.5)
      ..['decision_time_ms_p90'] = _percentile(0.9)
      ..['decision_time_ms_mean'] = decisionTimeMean;
  }
}

class _ArgParser {
  final List<String> args;
  bool failOnMissing = false;
  int minRuns = 0;
  bool exportMode = false;
  bool valid = true;
  late final List<String> paths;
  final usage =
      'Usage: phase1_summarize_logs.dart --input <path> [--input <path> ...] [--fail_on_missing] [--min_runs N] [--export]';

  _ArgParser(this.args) {
    paths = [];
    if (args.isEmpty) {
      valid = false;
      return;
    }
    var i = 0;
    while (i < args.length) {
      final token = args[i];
      if (token == '--input') {
        i++;
        if (i >= args.length) {
          valid = false;
          return;
        }
        paths.add(args[i]);
        i++;
        continue;
      }
      if (token == '--fail_on_missing') {
        failOnMissing = true;
        i++;
        continue;
      }
      if (token == '--min_runs') {
        i++;
        if (i >= args.length) {
          valid = false;
          return;
        }
        minRuns = int.tryParse(args[i]) ?? 0;
        i++;
        continue;
      }
      if (token == '--export') {
        exportMode = true;
        i++;
        continue;
      }
      valid = false;
      return;
    }
    if (paths.isEmpty) valid = false;
  }
}
