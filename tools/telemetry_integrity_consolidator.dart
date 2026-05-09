import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/telemetry_integrity_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final telemetry = await _parseTelemetry();
  final summaries = await _collectSummaries();
  final fileResults = <_FileCheckResult>[];
  int missing = 0;

  for (final summary in summaries) {
    final expectedEvent = _expectedEventName(summary.baseName);
    final eventRecords = telemetry.byEvent[expectedEvent];
    if (eventRecords == null || eventRecords.isEmpty) {
      missing++;
      fileResults.add(
        _FileCheckResult(
          fileName: summary.fileName,
          expectedEvent: expectedEvent,
          status: 'FAIL',
          notes: ['No matching telemetry event found'],
        ),
      );
    } else {
      final duplicateCount = telemetry.duplicatesByEvent[expectedEvent] ?? 0;
      final status = duplicateCount > 0 ? 'WARN' : 'PASS';
      final notes = duplicateCount > 0
          ? ['${duplicateCount + 1} identical events detected']
          : ['Telemetry event present'];
      fileResults.add(
        _FileCheckResult(
          fileName: summary.fileName,
          expectedEvent: expectedEvent,
          status: status,
          notes: notes,
        ),
      );
    }
  }

  final duplicates = telemetry.totalDuplicateEvents;
  final status = missing > 0 ? 'FAIL' : (duplicates > 0 ? 'WARN' : 'PASS');

  await _withReportsWritable(() async {
    await _writeSummary(
      fileResults: fileResults,
      checked: summaries.length,
      missing: missing,
      duplicates: duplicates,
      status: status,
    );
    await _appendTelemetry(
      checked: summaries.length,
      missing: missing,
      duplicates: duplicates,
      status: status,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'telemetry_integrity_consolidator: checked=${summaries.length} '
    'missing=$missing duplicates=$duplicates status=$status',
  );
}

Future<_TelemetrySnapshot> _parseTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) {
    return const _TelemetrySnapshot();
  }
  final eventsByType = <String, List<_TelemetryRecord>>{};
  final duplicatesByEvent = <String, int>{};
  final seenKeys = <String>{};
  int duplicateEvents = 0;

  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is! Map) continue;
    final event = payload['event']?.toString();
    if (event == null || event.isEmpty) continue;
    final timestamp = payload['timestamp']?.toString() ?? '';
    final record = _TelemetryRecord(event: event, timestamp: timestamp);
    eventsByType.putIfAbsent(event, () => []).add(record);
    final key = '$event@$timestamp';
    if (!seenKeys.add(key)) {
      duplicatesByEvent[event] = (duplicatesByEvent[event] ?? 0) + 1;
      duplicateEvents++;
    }
  }
  return _TelemetrySnapshot(
    byEvent: eventsByType,
    duplicatesByEvent: duplicatesByEvent,
    totalDuplicateEvents: duplicateEvents,
  );
}

Future<List<_SummaryFile>> _collectSummaries() async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) return const [];
  final files = <_SummaryFile>[];
  await for (final entity in dir.list()) {
    if (entity is! File) continue;
    final fileName = p.basename(entity.path);
    if (fileName.endsWith('_summary.txt')) {
      files.add(
        _SummaryFile(
          fileName: fileName,
          baseName: fileName.replaceAll('.txt', ''),
        ),
      );
    }
  }
  files.sort((a, b) => a.fileName.compareTo(b.fileName));
  return files;
}

String _expectedEventName(String baseName) {
  final core = baseName.replaceAll('_summary', '');
  if (core.endsWith('_report')) return core.replaceAll('_report', '_completed');
  return '${core}_completed';
}

Future<void> _writeSummary({
  required List<_FileCheckResult> fileResults,
  required int checked,
  required int missing,
  required int duplicates,
  required String status,
}) async {
  final buffer = StringBuffer()
    ..writeln('TELEMETRY INTEGRITY SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Checked files: $checked   Missing events: $missing   '
      'Duplicate events: $duplicates   Status: $status',
    )
    ..writeln();

  if (fileResults.isEmpty) {
    buffer.writeln('No summary files found in release/_reports.');
  } else {
    for (final result in fileResults) {
      buffer
        ..writeln('File: ${result.fileName}')
        ..writeln('  Expected event: ${result.expectedEvent}')
        ..writeln('  Status: ${result.status}')
        ..writeln('  Notes: ${result.notes.join('; ')}')
        ..writeln();
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int checked,
  required int missing,
  required int duplicates,
  required String status,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'telemetry_integrity_consolidated',
    'timestamp': DateTime.now().toIso8601String(),
    'checked': checked,
    'missing': missing,
    'duplicates': duplicates,
    'status': status,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'telemetry_integrity_consolidator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _TelemetrySnapshot {
  const _TelemetrySnapshot({
    this.byEvent = const {},
    this.duplicatesByEvent = const {},
    this.totalDuplicateEvents = 0,
  });

  final Map<String, List<_TelemetryRecord>> byEvent;
  final Map<String, int> duplicatesByEvent;
  final int totalDuplicateEvents;
}

class _TelemetryRecord {
  const _TelemetryRecord({required this.event, required this.timestamp});

  final String event;
  final String timestamp;
}

class _SummaryFile {
  const _SummaryFile({required this.fileName, required this.baseName});

  final String fileName;
  final String baseName;
}

class _FileCheckResult {
  const _FileCheckResult({
    required this.fileName,
    required this.expectedEvent,
    required this.status,
    required this.notes,
  });

  final String fileName;
  final String expectedEvent;
  final String status;
  final List<String> notes;
}
