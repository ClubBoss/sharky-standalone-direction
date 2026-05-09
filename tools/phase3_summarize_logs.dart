import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const _returnSignal = 'PHASE3_RETURN_SIGNAL';
const _flowEnd = 'PHASE3_FLOW_END';
const _ctaShown = 'PHASE3_RETURN_CTA_SHOWN';
const _ctaTapped = 'PHASE3_RETURN_CTA_TAPPED';
const _ctaLatency = 'PHASE3_RETURN_CTA_TAP_LATENCY_MS';
const _schema = 'phase3_summary_v1';
const _keyOrder = [
  'schema',
  'generated_at_utc',
  'event',
  'total_runs',
  'flow_end_count',
  'missing_flow_end_count',
  'missing_runs',
  'ok',
  'cta_shown_count',
  'cta_tapped_count',
  'cta_tap_latency_ms',
];

void main(List<String> args) {
  final parser = _ArgParser(args);
  if (!parser.valid) {
    stderr.writeln(parser.usage);
    exit(1);
  }

  final records = <String, _Record>{};
  var ctaShownCount = 0;
  var ctaTappedCount = 0;
  final latencyValues = <int>[];
  for (final path in parser.paths) {
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('Input file missing: $path');
      exit(3);
    }
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.contains(_ctaShown)) {
        ctaShownCount++;
      }
      if (line.contains(_ctaTapped)) {
        ctaTappedCount++;
      }
      final containsFlowEnd = line.contains(_flowEnd);
      final containsReturnSignal = line.contains(_returnSignal);
      if (line.contains(_ctaLatency)) {
        final payload = _parsePayload(line, _ctaLatency);
        final duration = payload['duration_ms'];
        if (duration is num) {
          latencyValues.add(duration.toInt());
        }
      }
      if (!containsFlowEnd && !containsReturnSignal) {
        continue;
      }
      final marker = containsFlowEnd ? _flowEnd : _returnSignal;
      final payload = _parsePayload(line, marker);
      final runId = payload['run_id'] as String?;
      if (runId == null || runId.isEmpty) continue;
      final record = records.putIfAbsent(runId, () => _Record());
      if (marker == _flowEnd) {
        record.flowEnd = true;
        record.flowEndCount += 1;
      } else {
        record.returnSignal = true;
      }
    }
  }

  final flowEndCount = records.values.fold<int>(
    0,
    (sum, record) => sum + record.flowEndCount,
  );
  final totalRuns = records.values.where((record) => record.flowEnd).length;
  final missingRuns = records.entries
      .where((entry) => entry.value.returnSignal && !entry.value.flowEnd)
      .map((e) => e.key)
      .toList();
  final missingCount = missingRuns.length;

  final summary = LinkedHashMap<String, Object?>()
    ..['schema'] = _schema
    ..['generated_at_utc'] = DateTime.now().toUtc().toIso8601String()
    ..['event'] = 'PHASE3_LOG_SUMMARY'
    ..['total_runs'] = totalRuns
    ..['flow_end_count'] = flowEndCount
    ..['missing_flow_end_count'] = missingCount
    ..['missing_runs'] = missingRuns
    ..['ok'] =
        flowEndCount >= parser.minRuns &&
        (!parser.failOnMissing || missingCount == 0);
  summary
    ..['cta_shown_count'] = ctaShownCount
    ..['cta_tapped_count'] = ctaTappedCount;
  final latencySummary = _describeLatencies(latencyValues);
  summary['cta_tap_latency_ms'] = latencySummary;

  assert(() {
    final keys = summary.keys.toList();
    if (keys.length != _keyOrder.length) return true;
    for (var i = 0; i < keys.length; i++) {
      if (keys[i] != _keyOrder[i]) {
        throw StateError(
          'Phase3 summary key order drift: expected "${_keyOrder[i]}" at $i but got "${keys[i]}"',
        );
      }
    }
    return true;
  }());

  stdout.writeln(jsonEncode(summary));

  if (parser.failOnMissing && missingCount > 0) {
    exit(2);
  }
  if (flowEndCount < parser.minRuns) {
    exit(3);
  }
  exit(0);
}

Map<String, dynamic> _parsePayload(String line, String marker) {
  final idx = line.indexOf(marker);
  if (idx == -1) throw FormatException('Missing marker $marker');
  final start = line.indexOf('{', idx);
  if (start == -1) throw FormatException('Missing JSON after $marker');
  final jsonPart = line.substring(start).trim();
  return jsonDecode(jsonPart) as Map<String, dynamic>;
}

class _Record {
  int flowEndCount = 0;
  bool flowEnd = false;
  bool returnSignal = false;
}

Map<String, Object?> _describeLatencies(List<int> values) {
  if (values.isEmpty) {
    return const {
      'min': null,
      'p50': null,
      'p90': null,
      'max': null,
      'mean': null,
    };
  }
  final sorted = List<int>.from(values)..sort();
  final total = sorted.fold<int>(0, (sum, v) => sum + v);
  final mean = total / sorted.length;
  return {
    'min': sorted.first,
    'p50': _percentile(sorted, 50),
    'p90': _percentile(sorted, 90),
    'max': sorted.last,
    'mean': mean,
  };
}

int _percentile(List<int> values, double percentile) {
  if (values.isEmpty) return 0;
  final idx = (percentile / 100 * (values.length - 1)).round();
  final select = idx.clamp(0, values.length - 1);
  return values[select];
}

class _ArgParser {
  final List<String> args;
  bool failOnMissing = false;
  int minRuns = 1;
  bool valid = true;
  late final List<String> paths;
  final usage =
      'Usage: phase3_summarize_logs.dart --input <path> [--input <path> ...] [--fail_on_missing] [--min_runs N]';

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
        minRuns = int.tryParse(args[i]) ?? 1;
        i++;
        continue;
      }
      valid = false;
      return;
    }
    if (paths.isEmpty) valid = false;
  }
}
