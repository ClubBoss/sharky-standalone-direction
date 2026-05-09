import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final loop = _TelemetryRefinementLoop();
  try {
    final result = await loop.run();
    await loop.writeNormalizedLog(result);
    await loop.writeSummary(result);
    await loop.emitTelemetry(result);
  } finally {
    await loop.restorePermissions();
  }
}

class _TelemetryRefinementLoop {
  bool _reportsWritable = false;

  Future<_RefinementResult> run() async {
    final watch = Stopwatch()..start();
    final declared = await _readDeclaredEvents();
    final logStats = await _readTelemetryLog(declared);
    watch.stop();

    final uniqueLogged = logStats.loggedCounts.keys.toSet();
    final missing = declared.difference(uniqueLogged);

    return _RefinementResult(
      timestamp: DateTime.now().toUtc(),
      declaredEvents: declared,
      loggedCounts: logStats.loggedCounts,
      missingEvents: missing,
      deprecatedEvents: logStats.deprecatedEvents,
      duplicatePairs: logStats.duplicateCount,
      records: logStats.records,
      skippedLines: logStats.skippedLines,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<Set<String>> _readDeclaredEvents() async {
    final file = File('TELEMETRY_EVENTS.md');
    if (!file.existsSync()) {
      throw StateError('TELEMETRY_EVENTS.md not found.');
    }
    final events = <String>{};
    final bulletPattern = RegExp(r'^-\s+([a-z0-9_]+)$');
    for (final rawLine in await file.readAsLines()) {
      final line = rawLine.trim();
      final match = bulletPattern.firstMatch(line);
      if (match != null) {
        events.add(match.group(1)!);
      }
    }
    return events;
  }

  Future<_TelemetryLogStats> _readTelemetryLog(Set<String> declared) async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) {
      throw StateError('release/_reports/telemetry.jsonl not found.');
    }
    final loggedCounts = <String, int>{};
    final deprecated = <String>{};
    final records = <_NormalizedRecord>[];
    final seenPairs = <String>{};
    var duplicateCount = 0;
    var skipped = 0;
    final lines = await file.readAsLines();
    for (var i = 0; i < lines.length; i += 1) {
      final trimmed = lines[i].trim();
      if (trimmed.isEmpty) {
        continue;
      }
      Map<String, dynamic>? decoded;
      try {
        final dynamic data = jsonDecode(trimmed);
        if (data is Map<String, dynamic>) {
          decoded = data;
        }
      } on FormatException {
        // fall through to skip counter
      }
      if (decoded == null) {
        skipped += 1;
        continue;
      }
      final event = decoded['event'];
      final timestamp = decoded['timestamp'];
      if (event is String) {
        loggedCounts[event] = (loggedCounts[event] ?? 0) + 1;
        if (!declared.contains(event)) {
          deprecated.add(event);
        }
      }
      if (event is String && timestamp is String) {
        final pairKey = '$event|$timestamp';
        if (!seenPairs.add(pairKey)) {
          duplicateCount += 1;
        }
      }
      final normalized = _normalizeRecord(decoded);
      final normalizedTimestamp = normalized['timestamp'];
      records.add(
        _NormalizedRecord(
          event: event is String ? event : null,
          timestamp: normalizedTimestamp is String ? normalizedTimestamp : null,
          timestampInstant: normalizedTimestamp is String
              ? _tryParseIso(normalizedTimestamp)
              : null,
          normalized: normalized,
          originalIndex: i,
        ),
      );
    }
    return _TelemetryLogStats(
      records: records,
      loggedCounts: loggedCounts,
      deprecatedEvents: deprecated,
      duplicateCount: duplicateCount,
      skippedLines: skipped,
    );
  }

  Map<String, Object?> _normalizeRecord(Map<String, dynamic> record) {
    final normalized = <String, Object?>{};
    final event = record['event'];
    final timestamp = record['timestamp'];
    if (event is String && event.isNotEmpty) {
      normalized['event'] = event;
    }
    if (timestamp is String && timestamp.isNotEmpty) {
      normalized['timestamp'] = timestamp;
    }
    final otherKeys =
        record.keys
            .where((key) => key != 'event' && key != 'timestamp')
            .toList()
          ..sort();
    for (final key in otherKeys) {
      final value = record[key];
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      normalized[key] = value;
    }
    return normalized;
  }

  Future<void> writeNormalizedLog(_RefinementResult result) async {
    final sorted = List<_NormalizedRecord>.from(result.records)
      ..sort((a, b) {
        final at = a.timestampInstant;
        final bt = b.timestampInstant;
        if (at == null && bt == null) {
          return a.originalIndex.compareTo(b.originalIndex);
        }
        if (at == null) return 1;
        if (bt == null) return -1;
        final cmp = at.compareTo(bt);
        if (cmp != 0) return cmp;
        return a.originalIndex.compareTo(b.originalIndex);
      });
    final buffer = StringBuffer();
    for (final record in sorted) {
      buffer.writeln(jsonEncode(record.normalized));
    }
    await _writeReportsFile(
      'release/_reports/telemetry_normalized.jsonl',
      buffer.toString(),
    );
  }

  Future<void> writeSummary(_RefinementResult result) async {
    final buffer = StringBuffer()
      ..writeln('Telemetry Refinement Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Metric | Count | Details |')
      ..writeln('|--------|-------|---------|')
      ..writeln(
        _row(
          'Declared events',
          result.declaredEvents.length,
          'From TELEMETRY_EVENTS.md',
        ),
      )
      ..writeln(
        _row(
          'Logged (unique)',
          result.loggedCounts.length,
          'Distinct events in telemetry.jsonl',
        ),
      )
      ..writeln(
        _row(
          'Missing',
          result.missingEvents.length,
          _sample(result.missingEvents),
        ),
      )
      ..writeln(
        _row(
          'Deprecated',
          result.deprecatedEvents.length,
          _sample(result.deprecatedEvents),
        ),
      )
      ..writeln(
        _row(
          'Duplicate event/timestamp pairs',
          result.duplicatePairs,
          result.duplicatePairs == 0 ? '-' : 'Found repeated entries',
        ),
      )
      ..writeln(
        _row(
          'Records normalized',
          result.records.length,
          'Saved to telemetry_normalized.jsonl',
        ),
      )
      ..writeln(
        _row(
          'Lines skipped',
          result.skippedLines,
          result.skippedLines == 0 ? '-' : 'Non-JSON entries skipped',
        ),
      )
      ..writeln()
      ..writeln('Duplicates detail: ${_duplicateNote(result)}');

    await _writeReportsFile(
      'release/_reports/telemetry_refinement_summary.txt',
      buffer.toString(),
    );
  }

  String _duplicateNote(_RefinementResult result) {
    if (result.duplicatePairs == 0) {
      return 'no repeated event/timestamp pairs detected';
    }
    return 'duplicates were detected and preserved in the normalized log';
  }

  String _row(String label, int count, String details) {
    final safeDetails = details.isEmpty ? '-' : details;
    return '| $label | $count | $safeDetails |';
  }

  String _sample(Iterable<String> values) {
    if (values.isEmpty) return '-';
    final list = values.toList()..sort();
    final preview = list.take(5).join(', ');
    return list.length > 5 ? '$preview …' : preview;
  }

  Future<void> emitTelemetry(_RefinementResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.telemetryRefinementCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'duplicates': result.duplicatePairs,
      'missing': result.missingEvents.length,
      'deprecated': result.deprecatedEvents.length,
      'duration_ms': result.durationMs,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    try {
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _RefinementResult {
  _RefinementResult({
    required this.timestamp,
    required this.declaredEvents,
    required this.loggedCounts,
    required this.missingEvents,
    required this.deprecatedEvents,
    required this.duplicatePairs,
    required this.records,
    required this.skippedLines,
    required this.durationMs,
  });

  final DateTime timestamp;
  final Set<String> declaredEvents;
  final Map<String, int> loggedCounts;
  final Set<String> missingEvents;
  final Set<String> deprecatedEvents;
  final int duplicatePairs;
  final List<_NormalizedRecord> records;
  final int skippedLines;
  final int durationMs;
}

class _TelemetryLogStats {
  _TelemetryLogStats({
    required this.records,
    required this.loggedCounts,
    required this.deprecatedEvents,
    required this.duplicateCount,
    required this.skippedLines,
  });

  final List<_NormalizedRecord> records;
  final Map<String, int> loggedCounts;
  final Set<String> deprecatedEvents;
  final int duplicateCount;
  final int skippedLines;
}

class _NormalizedRecord {
  _NormalizedRecord({
    required this.event,
    required this.timestamp,
    required this.timestampInstant,
    required this.normalized,
    required this.originalIndex,
  });

  final String? event;
  final String? timestamp;
  final DateTime? timestampInstant;
  final Map<String, Object?> normalized;
  final int originalIndex;
}

DateTime? _tryParseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}
