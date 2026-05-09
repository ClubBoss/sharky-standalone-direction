import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final archival = _FinalArchivalLock();
  final report = await archival.createArchive();
  await archival.writeSummary(report);
  await archival.emitTelemetry(report);
}

class _FinalArchivalLock {
  Future<_ArchiveReport> createArchive() async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();
    final stamp = timestamp
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('-', '');
    final archiveDir = Directory('release/_archives');
    await archiveDir.create(recursive: true);
    final zipPath = '${archiveDir.path}/final_$stamp.zip';

    final sources = <File>[];
    sources.addAll(_collectFiles(Directory('release/_reports')));
    sources.addAll(_collectFiles(Directory('assets/brand')));

    if (sources.isEmpty) {
      throw StateError('No files found in release/_reports or assets/brand.');
    }

    final zipArgs = <String>['-r', zipPath];
    zipArgs.addAll(sources.map((file) => file.path));
    final zipResult = await Process.run('zip', zipArgs);
    if (zipResult.exitCode != 0) {
      throw ProcessException(
        'zip',
        zipArgs,
        zipResult.stderr.toString(),
        zipResult.exitCode,
      );
    }

    final entries = <_FileEntry>[];
    for (final file in sources) {
      final size = await file.length();
      final hash = await _sha256(file.path);
      entries.add(_FileEntry(path: file.path, size: size, hash: hash));
    }

    final totalBytes = entries.fold<int>(0, (sum, e) => sum + e.size);
    stopwatch.stop();
    return _ArchiveReport(
      timestamp: timestamp,
      zipPath: zipPath,
      entries: entries,
      totalBytes: totalBytes,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<void> writeSummary(_ArchiveReport report) async {
    final buffer = StringBuffer()
      ..writeln('Final Archival Summary')
      ..writeln('Timestamp: ${report.timestamp.toIso8601String()}')
      ..writeln('Archive: ${report.zipPath}')
      ..writeln('')
      ..writeln('| File | Size (bytes) | SHA-256 |')
      ..writeln('| ---- | ------------ | ------- |');
    for (final entry in report.entries) {
      buffer.writeln('| ${entry.path} | ${entry.size} | ${entry.hash} |');
    }
    buffer
      ..writeln('')
      ..writeln('Files: ${report.entries.length}')
      ..writeln('Total Bytes: ${report.totalBytes}');

    final summary = File('release/_reports/final_archival_summary.txt');
    await summary.parent.create(recursive: true);
    await summary.writeAsString(buffer.toString());
  }

  Future<void> emitTelemetry(_ArchiveReport report) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.finalArchivalLockCompleted,
      'timestamp': report.timestamp.toIso8601String(),
      'files': report.entries.length,
      'bytes': report.totalBytes,
      'hashes': report.entries.map((e) => e.hash).toList(),
      'duration_ms': report.durationMs,
    };
    final telemetry = File('release/_reports/telemetry.jsonl');
    await telemetry.parent.create(recursive: true);
    await telemetry.writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  List<File> _collectFiles(Directory directory) {
    if (!directory.existsSync()) {
      return const <File>[];
    }
    return directory.listSync(recursive: true).whereType<File>().toList();
  }

  Future<String> _sha256(String path) async {
    final result = await Process.run('shasum', ['-a', '256', path]);
    if (result.exitCode != 0) {
      throw ProcessException(
        'shasum',
        ['-a', '256', path],
        result.stderr.toString(),
        result.exitCode,
      );
    }
    return result.stdout.toString().split(' ').first.trim();
  }
}

class _ArchiveReport {
  _ArchiveReport({
    required this.timestamp,
    required this.zipPath,
    required this.entries,
    required this.totalBytes,
    required this.durationMs,
  });

  final DateTime timestamp;
  final String zipPath;
  final List<_FileEntry> entries;
  final int totalBytes;
  final int durationMs;
}

class _FileEntry {
  const _FileEntry({
    required this.path,
    required this.size,
    required this.hash,
  });

  final String path;
  final int size;
  final String hash;
}
