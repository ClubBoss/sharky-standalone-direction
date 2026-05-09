import 'dart:collection';
import 'dart:convert';
import 'dart:io';

const _flowEnd = 'PHASE2_FLOW_END';
const _shown = 'PHASE2_AHA_HINT_SHOWN';
const _dismissed = 'PHASE2_AHA_HINT_DISMISSED';
const _schema = 'phase2_summary_v1';
const _keyOrder = [
  'schema',
  'generated_at_utc',
  'event',
  'total_runs',
  'flow_end_count',
  'shown_count',
  'dismissed_count',
  'missing_runs',
  'ok',
];

void main(List<String> args) {
  final parser = _ArgParser(args);
  if (!parser.valid) {
    stderr.writeln(parser.usage);
    exit(1);
  }

  final records = <String, _Record>{};
  for (final path in parser.paths) {
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('Input file missing: $path');
      exit(3);
    }
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final markers = <String>[_flowEnd, _shown, _dismissed];
      final marker = markers.firstWhere(
        (m) => line.contains(m),
        orElse: () => '',
      );
      if (marker.isEmpty) continue;
      final payload = _parsePayload(line, marker);
      final runId = payload['run_id'] as String?;
      if (runId == null || runId.isEmpty) continue;
      final record = records.putIfAbsent(runId, () => _Record());
      if (marker == _flowEnd) {
        record.flowEnd = true;
        record.flowEndCount += 1;
      } else if (marker == _shown) {
        record.shownCount += 1;
      } else if (marker == _dismissed) {
        record.dismissedCount += 1;
      }
    }
  }

  final flowEndCount = records.values.fold<int>(
    0,
    (sum, record) => sum + record.flowEndCount,
  );
  final totalRuns = records.values.where((record) => record.flowEnd).length;
  final missingRuns = records.entries
      .where(
        (entry) =>
            entry.value.shownCount > 0 && entry.value.dismissedCount == 0,
      )
      .map((entry) => entry.key)
      .toList();
  final missingCount = missingRuns.length;

  final summary = LinkedHashMap<String, Object?>()
    ..['schema'] = _schema
    ..['generated_at_utc'] = DateTime.now().toUtc().toIso8601String()
    ..['event'] = 'PHASE2_LOG_SUMMARY'
    ..['total_runs'] = totalRuns
    ..['flow_end_count'] = flowEndCount
    ..['shown_count'] = records.values.fold<int>(
      0,
      (sum, r) => sum + r.shownCount,
    )
    ..['dismissed_count'] = records.values.fold<int>(
      0,
      (sum, r) => sum + r.dismissedCount,
    )
    ..['missing_runs'] = missingRuns
    ..['ok'] =
        flowEndCount >= parser.minRuns &&
        (!parser.failOnMissing || missingCount == 0);

  assert(() {
    final keys = summary.keys.toList();
    if (keys.length != _keyOrder.length) return true;
    for (var i = 0; i < keys.length; i++) {
      if (keys[i] != _keyOrder[i]) {
        throw StateError(
          'Phase2 summary key order drift: expected "${_keyOrder[i]}" at $i but got "${keys[i]}"',
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
  final part = line.substring(start).trim();
  return jsonDecode(part) as Map<String, dynamic>;
}

class _Record {
  int flowEndCount = 0;
  bool flowEnd = false;
  int shownCount = 0;
  int dismissedCount = 0;
}

class _ArgParser {
  final List<String> args;
  bool failOnMissing = false;
  int minRuns = 1;
  bool valid = true;
  late final List<String> paths;
  final usage =
      'Usage: phase2_summarize_logs.dart --input <path> [--input <path> ...] [--fail_on_missing] [--min_runs N]';

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
