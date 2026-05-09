import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

const String _reportsDir = 'release/_reports';
const String _snapshotsDir = 'release/_snapshots';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/regression_snapshot_summary.txt';
const String _summaryJsonPath = '$_reportsDir/regression_snapshot_summary.json';

const List<String> _criticalFiles = <String>[
  'stability_qa_consolidator_v2_summary.txt',
  'stability_qa_consolidator_v2_summary.json',
  'release_qa_consolidation_summary.txt',
  'release_qa_consolidation_summary.json',
  'release_certification_summary.txt',
  'release_certification_summary.json',
  'final_stability_summary.txt',
  'final_stability_summary.json',
];

Future<void> main(List<String> args) async {
  final archive = RegressionSnapshotArchive();
  final ok = await archive.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RegressionSnapshotArchive {
  Future<bool> run() async {
    final missing = await _validateCriticalFiles();
    if (missing.isNotEmpty) {
      stderr.writeln('Missing critical files:\n- ${missing.join('\n- ')}');
      return false;
    }

    final files = await _gatherFilesForArchive();
    if (files.isEmpty) {
      stderr.writeln('No report files (.txt/.json) found to archive.');
      return false;
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final archivePath = '$_snapshotsDir/regression_snapshot_$timestamp.zip';
    final stats = _ArchiveStats(files);

    try {
      await _withReportsWritable(() async {
        await Directory(_snapshotsDir).create(recursive: true);
        final archive = Archive();
        for (final entry in files) {
          final bytes = await entry.file.readAsBytes();
          archive.addFile(ArchiveFile(entry.relativePath, bytes.length, bytes));
        }
        final encoded = ZipEncoder().encode(archive);
        await File(archivePath).writeAsBytes(encoded, flush: true);

        await _writeSummaries(
          archivePath: archivePath,
          stats: stats,
          criticalFiles: _criticalFiles
              .map((name) => '$_reportsDir/$name')
              .toList(growable: false),
        );
      });
    } catch (error, stackTrace) {
      stderr.writeln('Failed to create archive: $error');
      stderr.writeln(stackTrace);
      return false;
    }

    return true;
  }

  Future<List<String>> _validateCriticalFiles() async {
    final missing = <String>[];
    for (final relative in _criticalFiles) {
      final path = '$_reportsDir/$relative';
      final file = File(path);
      if (!await file.exists()) {
        missing.add(path);
      }
    }
    final telemetry = File(_telemetryPath);
    if (!await telemetry.exists()) {
      missing.add(_telemetryPath);
    }
    return missing;
  }

  Future<List<_ArchiveEntry>> _gatherFilesForArchive() async {
    final dir = Directory(_reportsDir);
    if (!await dir.exists()) {
      return <_ArchiveEntry>[];
    }
    final files = <_ArchiveEntry>[];
    final reportsRoot = dir.absolute.path;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final path = entity.path;
      if (path.endsWith('.txt') || path.endsWith('.json')) {
        files.add(
          _ArchiveEntry(
            file: entity,
            relativePath: p.relative(entity.absolute.path, from: reportsRoot),
          ),
        );
      }
    }
    final telemetry = File(_telemetryPath);
    if (await telemetry.exists()) {
      files.add(
        _ArchiveEntry(
          file: telemetry,
          relativePath: p.relative(telemetry.absolute.path, from: reportsRoot),
        ),
      );
    }
    return files;
  }

  Future<void> _writeSummaries({
    required String archivePath,
    required _ArchiveStats stats,
    required List<String> criticalFiles,
  }) async {
    final now = DateTime.now().toIso8601String();
    final summaryText = StringBuffer()
      ..writeln('REGRESSION SNAPSHOT ARCHIVE')
      ..writeln('Generated: $now')
      ..writeln('Archive: $archivePath')
      ..writeln('Files archived: ${stats.count}')
      ..writeln('Total size (MB): ${stats.sizeMb.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('Critical files verified:');
    for (final file in criticalFiles) {
      summaryText.writeln('- $file');
    }

    final summaryJson = <String, Object?>{
      'generated_at': now,
      'archive_path': archivePath,
      'file_count': stats.count,
      'total_size_bytes': stats.sizeBytes,
      'total_size_mb': stats.sizeMb,
      'critical_files': criticalFiles,
      'verdict': 'PASS',
    };

    await File(_summaryTextPath).writeAsString(summaryText.toString());
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
    await _appendTelemetry(archivePath: archivePath, stats: stats);
  }

  Future<void> _appendTelemetry({
    required String archivePath,
    required _ArchiveStats stats,
  }) async {
    final payload = <String, Object?>{
      'event': 'regression_snapshot_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'archive_path': archivePath,
      'file_count': stats.count,
      'total_size_mb': stats.sizeMb,
      'exit_code': 0,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _ArchiveStats {
  _ArchiveStats(List<_ArchiveEntry> files)
    : count = files.length,
      sizeBytes = files.fold<int>(
        0,
        (total, entry) => total + entry.file.lengthSync(),
      );

  final int count;
  final int sizeBytes;

  double get sizeMb => sizeBytes / (1024 * 1024);
}

class _ArchiveEntry {
  const _ArchiveEntry({required this.file, required this.relativePath});

  final File file;
  final String relativePath;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dirs = <Directory>[Directory(_reportsDir), Directory(_snapshotsDir)];
  for (final dir in dirs) {
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
  try {
    for (final dir in dirs) {
      await Process.run('chmod', ['-R', 'u+w', dir.path]);
    }
  } catch (_) {
    // ignore permission adjustment errors
  }
  try {
    await action();
  } finally {
    try {
      for (final dir in dirs) {
        await Process.run('chmod', ['-R', 'u-w', dir.path]);
      }
    } catch (_) {
      // ignore
    }
  }
}
