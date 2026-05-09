import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath =
    'release/_reports/telemetry_reliability_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final telemetry = await _readTelemetry();
  final summaryFiles = await _listSummaryFiles();
  final check = _analyze(summaryFiles, telemetry);

  await _withReportsWritable(() async {
    await _writeSummary(check);
    await _appendTelemetry(
      missing: check.missingSummaries.length,
      duplicates: check.duplicateEvents.length,
      inconsistencies: check.inconsistentSummaries.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'telemetry_reliability_sweep: missing=${check.missingSummaries.length} '
    'duplicates=${check.duplicateEvents.length} '
    'inconsistencies=${check.inconsistentSummaries.length}',
  );
}

Future<List<File>> _listSummaryFiles() async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) return const [];
  final files = <File>[];
  await for (final entity in dir.list()) {
    if (entity is File && entity.path.endsWith('_summary.txt')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

Future<List<_TelemetryEvent>> _readTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final events = <_TelemetryEvent>[];
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    try {
      final data = json.decode(line);
      if (data is Map<String, dynamic>) {
        final eventName = data['event']?.toString() ?? 'unknown';
        final timestampRaw = data['timestamp']?.toString();
        events.add(
          _TelemetryEvent(
            name: eventName,
            timestamp: timestampRaw == null
                ? null
                : DateTime.tryParse(timestampRaw),
            raw: data,
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }
  return events;
}

_ReliabilityReport _analyze(
  List<File> summaries,
  List<_TelemetryEvent> telemetry,
) {
  final normalizedEvents = <String, List<_TelemetryEvent>>{};
  for (final event in telemetry) {
    final key = _normalize(event.name);
    normalizedEvents.putIfAbsent(key, () => <_TelemetryEvent>[]).add(event);
  }

  final duplicateEvents = <_TelemetryEvent>[];
  final seenPairs = <String>{};
  for (final event in telemetry) {
    final key = '${event.name}|${event.timestamp?.toIso8601String() ?? 'na'}';
    if (!seenPairs.add(key)) {
      duplicateEvents.add(event);
    }
  }

  final missing = <_SummaryInfo>[];
  final inconsistent = <_SummaryInconsistency>[];
  for (final file in summaries) {
    final info = _parseSummary(file);
    final normalizedName = _normalize(info.baseName);
    final matching =
        normalizedEvents.entries
            .where(
              (entry) =>
                  entry.key.contains(normalizedName) ||
                  normalizedName.contains(entry.key),
            )
            .expand((entry) => entry.value)
            .toList()
          ..sort((a, b) {
            final at = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bt = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bt.compareTo(at);
          });
    if (matching.isEmpty) {
      missing.add(info);
      continue;
    }
    final latest = matching.first;
    if (info.generated != null && latest.timestamp != null) {
      final delta = info.generated!.difference(latest.timestamp!).abs();
      if (delta.inHours > 24) {
        inconsistent.add(
          _SummaryInconsistency(summary: info, event: latest, delta: delta),
        );
      }
    }
  }

  return _ReliabilityReport(
    missingSummaries: missing,
    duplicateEvents: duplicateEvents,
    inconsistentSummaries: inconsistent,
  );
}

_SummaryInfo _parseSummary(File file) {
  String baseName = file.uri.pathSegments.last;
  if (baseName.endsWith('_summary.txt')) {
    baseName = baseName.substring(0, baseName.length - '_summary.txt'.length);
  }
  DateTime? generated;
  try {
    final lines = file.readAsLinesSync();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Generated:')) {
        final value = trimmed.substring('Generated:'.length).trim();
        generated = DateTime.tryParse(value);
        break;
      }
    }
  } catch (_) {}
  return _SummaryInfo(
    path: file.path,
    baseName: baseName,
    generated: generated,
  );
}

String _normalize(String input) =>
    input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

Future<void> _writeSummary(_ReliabilityReport report) async {
  final buffer = StringBuffer()
    ..writeln('TELEMETRY RELIABILITY SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln(
      'Missing summary <-> telemetry links: ${report.missingSummaries.length}',
    )
    ..writeln('Duplicate telemetry events: ${report.duplicateEvents.length}')
    ..writeln(
      'Timestamp inconsistencies: ${report.inconsistentSummaries.length}',
    )
    ..writeln();

  buffer.writeln('Missing Summaries (examples):');
  if (report.missingSummaries.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final info in report.missingSummaries.take(10)) {
      buffer.writeln('- ${info.path}');
    }
    if (report.missingSummaries.length > 10) {
      buffer.writeln('- ... (${report.missingSummaries.length - 10} more)');
    }
  }

  buffer
    ..writeln()
    ..writeln('Duplicate Events (examples):');
  if (report.duplicateEvents.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final event in report.duplicateEvents.take(10)) {
      buffer.writeln(
        '- ${event.name} @ ${event.timestamp?.toIso8601String() ?? 'n/a'}',
      );
    }
    if (report.duplicateEvents.length > 10) {
      buffer.writeln('- ... (${report.duplicateEvents.length - 10} more)');
    }
  }

  buffer
    ..writeln()
    ..writeln('Inconsistencies (summary vs telemetry timestamp >24h):');
  if (report.inconsistentSummaries.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final entry in report.inconsistentSummaries.take(10)) {
      buffer.writeln(
        '- ${entry.summary.path} vs ${entry.event.name} '
        '(${entry.delta.inHours}h)',
      );
    }
    if (report.inconsistentSummaries.length > 10) {
      buffer.writeln(
        '- ... (${report.inconsistentSummaries.length - 10} more)',
      );
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int missing,
  required int duplicates,
  required int inconsistencies,
  required int durationMs,
}) async {
  final event = <String, Object>{
    'event': 'telemetry_reliability_sweep_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'missing': missing,
    'duplicates': duplicates,
    'inconsistencies': inconsistencies,
    'duration_ms': durationMs,
  };
  await File(
    _telemetryPath,
  ).writeAsString(jsonEncode(event) + '\n', mode: FileMode.append, flush: true);
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
      'telemetry_reliability_sweep: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _TelemetryEvent {
  const _TelemetryEvent({
    required this.name,
    required this.timestamp,
    required this.raw,
  });

  final String name;
  final DateTime? timestamp;
  final Map<String, dynamic> raw;
}

class _SummaryInfo {
  const _SummaryInfo({
    required this.path,
    required this.baseName,
    required this.generated,
  });

  final String path;
  final String baseName;
  final DateTime? generated;
}

class _SummaryInconsistency {
  const _SummaryInconsistency({
    required this.summary,
    required this.event,
    required this.delta,
  });

  final _SummaryInfo summary;
  final _TelemetryEvent event;
  final Duration delta;
}

class _ReliabilityReport {
  const _ReliabilityReport({
    required this.missingSummaries,
    required this.duplicateEvents,
    required this.inconsistentSummaries,
  });

  final List<_SummaryInfo> missingSummaries;
  final List<_TelemetryEvent> duplicateEvents;
  final List<_SummaryInconsistency> inconsistentSummaries;
}
