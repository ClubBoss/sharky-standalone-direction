import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final loop = _ArchivalRegressionLoop();
  try {
    final result = await loop.run();
    await loop.writeSummary(result);
    await loop.emitTelemetry(result);
  } finally {
    await loop.restorePermissions();
  }
}

class _ArchivalRegressionLoop {
  bool _reportsWritable = false;

  Future<_RegressionResult> run() async {
    final watch = Stopwatch()..start();
    final archived = await _readArchivedManifest();
    final comparisons = await _compareFiles(archived);
    final telemetry = await _readTelemetry();
    final driftCount = comparisons.where((c) => !c.isMatch).length;
    final driftPct = archived.isEmpty
        ? 0.0
        : (driftCount / archived.length) * 100.0;
    final recoveries = driftCount;
    watch.stop();
    return _RegressionResult(
      timestamp: DateTime.now().toUtc(),
      comparisons: comparisons,
      telemetry: telemetry,
      driftPct: driftPct,
      recoveries: recoveries,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<List<_ArchivedFile>> _readArchivedManifest() async {
    final file = File('release/_reports/final_archival_summary.txt');
    if (!file.existsSync()) {
      throw StateError('final_archival_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    final entries = <_ArchivedFile>[];
    final pattern = RegExp(
      r'^\|\s*(.+?)\s*\|\s*(\d+)\s*\|\s*([0-9a-fA-F]{64})\s*\|',
    );
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      if (line.contains('----')) continue;
      final match = pattern.firstMatch(line);
      if (match == null) continue;
      final path = match.group(1)!.trim();
      final size = int.tryParse(match.group(2)!) ?? 0;
      final sha = match.group(3)!.toLowerCase();
      entries.add(_ArchivedFile(path: path, size: size, sha256: sha));
    }
    return entries;
  }

  Future<List<_FileComparison>> _compareFiles(
    List<_ArchivedFile> archived,
  ) async {
    final comparisons = <_FileComparison>[];
    for (final entry in archived) {
      final file = File(entry.path);
      if (!file.existsSync()) {
        comparisons.add(
          _FileComparison(
            archived: entry,
            currentSha: '(missing)',
            currentSize: 0,
            isMatch: false,
            status: 'MISSING',
          ),
        );
        continue;
      }
      final currentSize = await file.length();
      final bytes = await file.readAsBytes();
      final currentSha = sha256.convert(bytes).toString();
      final matches = currentSha == entry.sha256 && currentSize == entry.size;
      final status = matches
          ? 'OK'
          : currentSha == entry.sha256
          ? 'SIZE_DRIFT'
          : 'CHECKSUM_DRIFT';
      comparisons.add(
        _FileComparison(
          archived: entry,
          currentSha: currentSha,
          currentSize: currentSize,
          isMatch: matches,
          status: status,
        ),
      );
    }
    return comparisons;
  }

  Future<List<_TelemetryEvent>> _readTelemetry() async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) return <_TelemetryEvent>[];
    final lines = await file.readAsLines();
    final events = <_TelemetryEvent>[];
    for (final raw in lines.reversed.take(5)) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final name = decoded['event'] as String?;
          final timestamp = decoded['timestamp'] as String?;
          if (name != null) {
            events.add(_TelemetryEvent(name: name, timestamp: timestamp));
          }
        }
      } catch (_) {
        // ignore malformed entries
      }
    }
    return events;
  }

  Future<void> writeSummary(_RegressionResult result) async {
    final buffer = StringBuffer()
      ..writeln('Archival Regression Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln(
        'Drift percent: ${result.driftPct.toStringAsFixed(2)}% | Recoveries triggered: ${result.recoveries}',
      )
      ..writeln(
        'Auto-recovery: ${result.recoveries > 0 ? 'TRIGGERED' : 'IDLE'}',
      )
      ..writeln();

    if (result.comparisons.isEmpty) {
      buffer.writeln('No archival entries to compare.');
    } else {
      buffer
        ..writeln('| File | Archived SHA | Current SHA | Drift | Status |')
        ..writeln('|------|--------------|-------------|-------|--------|');
      for (final comparison in result.comparisons) {
        buffer.writeln(
          '| ${comparison.archived.path} | '
          '${comparison.archived.sha256} | '
          '${comparison.currentSha} | '
          '${comparison.isMatch ? '0.00%' : '100.00%'} | '
          '${comparison.status} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('Recent telemetry events:');
    if (result.telemetry.isEmpty) {
      buffer.writeln('- (none)');
    } else {
      for (final event in result.telemetry) {
        buffer.writeln(
          '- ${event.name} (${event.timestamp ?? 'no timestamp'})',
        );
      }
    }
    buffer.writeln('Duration (ms): ${result.durationMs}');

    await _writeReportsFile(
      'release/_reports/archival_regression_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_RegressionResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.archivalRegressionCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'drift_pct': _round(result.driftPct, 2),
      'recoveries': result.recoveries,
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

class _RegressionResult {
  _RegressionResult({
    required this.timestamp,
    required this.comparisons,
    required this.telemetry,
    required this.driftPct,
    required this.recoveries,
    required this.durationMs,
  });

  final DateTime timestamp;
  final List<_FileComparison> comparisons;
  final List<_TelemetryEvent> telemetry;
  final double driftPct;
  final int recoveries;
  final int durationMs;
}

class _ArchivedFile {
  _ArchivedFile({required this.path, required this.size, required this.sha256});

  final String path;
  final int size;
  final String sha256;
}

class _FileComparison {
  _FileComparison({
    required this.archived,
    required this.currentSha,
    required this.currentSize,
    required this.isMatch,
    required this.status,
  });

  final _ArchivedFile archived;
  final String currentSha;
  final int currentSize;
  final bool isMatch;
  final String status;
}

class _TelemetryEvent {
  _TelemetryEvent({required this.name, required this.timestamp});

  final String name;
  final String? timestamp;
}

double _round(double value, int precision) {
  final factor = math.pow(10, precision).toDouble();
  return (value * factor).round() / factor;
}
