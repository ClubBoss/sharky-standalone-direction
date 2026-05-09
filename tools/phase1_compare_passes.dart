import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const _passMarker = 'PHASE1_PASS';
const _attemptResult = 'PHASE1_ATTEMPT_RESULT';
const _schema = 'phase1_pass_compare_v1';
const _keyOrder = [
  'schema',
  'generated_at_utc',
  'event',
  'passes',
  'accuracy_delta',
  'decision_time_mean_delta_ms',
];

void main(List<String> args) {
  final parser = _ArgParser(args);
  if (!parser.valid) {
    stderr.writeln(parser.usage);
    exit(1);
  }

  final runPassStats = <String, Map<String, _PassStats>>{};
  final runCurrentPass = <String, String>{};
  for (final input in parser.paths) {
    final file = File(input);
    if (!file.existsSync()) {
      stderr.writeln('Input file missing: $input');
      exit(1);
    }
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.contains(_passMarker)) {
        final payload = _parsePayload(line, _passMarker);
        final runId = payload['run_id'] as String?;
        final pass = (payload['pass'] as String?)?.toUpperCase();
        if (runId == null || pass == null || (pass != 'A' && pass != 'B')) {
          continue;
        }
        runCurrentPass[runId] = pass;
        final perRun = runPassStats.putIfAbsent(runId, () => {});
        perRun.putIfAbsent(pass, () => _PassStats(runId, pass));
        continue;
      }
      if (line.contains(_attemptResult)) {
        final payload = _parsePayload(line, _attemptResult);
        final runId = payload['run_id'] as String?;
        if (runId == null) continue;
        final pass = runCurrentPass[runId];
        if (pass == null) continue;
        final perRun = runPassStats.putIfAbsent(runId, () => {});
        final stats = perRun.putIfAbsent(pass, () => _PassStats(runId, pass));
        stats.recordResult(payload);
      }
    }
  }

  _PassStats? passA;
  _PassStats? passB;
  for (final entry in runPassStats.entries) {
    final perRun = entry.value;
    if (perRun.containsKey('A') && perRun.containsKey('B')) {
      passA = perRun['A'];
      passB = perRun['B'];
      break;
    }
  }
  if (passA == null || passB == null) {
    stderr.writeln('Missing Phase-1 Pass A or Pass B markers');
    exit(2);
  }
  if (passA.attemptTotal == 0 || passB.attemptTotal == 0) {
    stderr.writeln('Phase-1 passes must each include at least one attempt');
    exit(2);
  }

  final accuracyDelta = _delta(passB.accuracy, passA.accuracy);
  final meanDelta = _delta(passB.decisionTimeMean, passA.decisionTimeMean);

  final passesMap = LinkedHashMap<String, Object?>()
    ..['A'] = passA.toJson()
    ..['B'] = passB.toJson();
  final summary = LinkedHashMap<String, Object?>()
    ..['schema'] = _schema
    ..['generated_at_utc'] = DateTime.now().toUtc().toIso8601String()
    ..['event'] = 'PHASE1_PASS_COMPARE'
    ..['passes'] = passesMap
    ..['accuracy_delta'] = accuracyDelta
    ..['decision_time_mean_delta_ms'] = meanDelta;

  assert(() {
    final keys = summary.keys.toList();
    if (keys.length != _keyOrder.length) return true;
    for (var i = 0; i < keys.length; i++) {
      if (keys[i] != _keyOrder[i]) {
        throw StateError(
          'Phase1 pass compare key order drift: expected "${_keyOrder[i]}" at $i but got "${keys[i]}"',
        );
      }
    }
    return true;
  }());

  stdout.writeln(jsonEncode(summary));
  exit(0);
}

double? _delta(double? a, double? b) {
  if (a == null || b == null) return null;
  return a - b;
}

double _doubleFromNum(num value) => value.toDouble();

Map<String, dynamic> _parsePayload(String line, String marker) {
  final idx = line.indexOf(marker);
  if (idx == -1) return {};
  final start = line.indexOf('{', idx);
  if (start == -1) return {};
  final jsonPart = line.substring(start);
  return jsonDecode(jsonPart) as Map<String, dynamic>;
}

class _PassStats {
  final String runId;
  final String pass;
  int attemptTotal = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  final List<double> _decisionTimes = [];

  _PassStats(this.runId, this.pass);

  void recordResult(Map<String, dynamic> payload) {
    attemptTotal++;
    final result = payload['result'] as String? ?? '';
    if (result == 'correct') {
      correctCount++;
      final duration = payload['decision_time_ms'];
      if (duration is num) {
        _decisionTimes.add(_doubleFromNum(duration));
      }
    } else {
      incorrectCount++;
    }
  }

  double get accuracy => attemptTotal == 0 ? 0.0 : correctCount / attemptTotal;

  List<double> get _sortedDecisionTimes {
    final sorted = List<double>.from(_decisionTimes);
    sorted.sort();
    return sorted;
  }

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

  double? get decisionTimeMin =>
      _sortedDecisionTimes.isEmpty ? null : _sortedDecisionTimes.first;

  double? get decisionTimeMax =>
      _sortedDecisionTimes.isEmpty ? null : _sortedDecisionTimes.last;

  double? get decisionTimeMean => _sortedDecisionTimes.isEmpty
      ? null
      : _sortedDecisionTimes.reduce((a, b) => a + b) /
            _sortedDecisionTimes.length;

  Map<String, Object?> toJson() {
    return LinkedHashMap<String, Object?>()
      ..['attempts_total'] = attemptTotal
      ..['correct_count'] = correctCount
      ..['incorrect_count'] = incorrectCount
      ..['accuracy'] = accuracy
      ..['decision_time_ms_min'] = decisionTimeMin
      ..['decision_time_ms_p50'] = _percentile(0.5)
      ..['decision_time_ms_p90'] = _percentile(0.9)
      ..['decision_time_ms_max'] = decisionTimeMax
      ..['decision_time_ms_mean'] = decisionTimeMean;
  }
}

class _ArgParser {
  final List<String> args;
  bool valid = true;
  late final List<String> paths;
  final usage =
      'Usage: phase1_compare_passes.dart --input <path> [--input <path> ...]';

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
      valid = false;
      return;
    }
    if (paths.isEmpty) valid = false;
  }
}
