import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/release_inventory_summary.txt';
const String _summaryJsonPath = '$_reportsDir/release_inventory_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const Duration _staleWindow = Duration(days: 7);

const List<String> _criticalSummaries = [
  'stability_dashboard_summary.txt',
  'regression_maintenance_summary.txt',
  'regression_consolidation_summary.txt',
  'visual_cohesion_dashboard_v2_summary.txt',
  'content_semantic_audit_summary.txt',
  'content_schema_validator_summary.txt',
];

Future<void> main(List<String> args) async {
  final cleaner = ReleaseInventoryCleaner();
  final ok = await cleaner.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ReleaseInventoryCleaner {
  Future<bool> run() async {
    final dir = Directory(_reportsDir);
    if (!await dir.exists()) {
      stderr.writeln('Reports directory $_reportsDir missing.');
      return false;
    }

    final now = DateTime.now();
    final staleCutoff = now.subtract(_staleWindow);
    final staleEntries = <FileSystemEntity>[];
    final deletedTmp = <String>[];
    var criticalMissing = <String>[];

    final files = await dir.list(recursive: false, followLinks: false).toList();

    for (final entity in files) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name.endsWith('.tmp') || name.endsWith('.bak')) {
        try {
          await entity.delete();
          deletedTmp.add(name);
        } catch (_) {
          // ignore failures
        }
        continue;
      }
      final lastModified = await entity.lastModified();
      if (lastModified.isBefore(staleCutoff)) {
        staleEntries.add(entity);
      }
    }

    criticalMissing = _criticalSummaries
        .where((name) => !File('$_reportsDir/$name').existsSync())
        .toList();

    final archiveName = '_archive_${_formatDate(now)}.zip';
    final archivePath = '$_reportsDir/$archiveName';
    final filesToArchive = files
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('.txt') || file.path.endsWith('.json'),
        )
        .where((file) => file.uri.pathSegments.last != archiveName)
        .toList();

    final archiveResult = await _createArchive(archivePath, filesToArchive);

    final summary = _buildTextSummary(
      stale: staleEntries,
      deletedTmp: deletedTmp,
      criticalMissing: criticalMissing,
      archivePath: archiveResult.success ? archivePath : null,
      archivedCount: filesToArchive.length,
      archiveError: archiveResult.error,
    );

    final summaryJson = _buildJsonSummary(
      stale: staleEntries,
      deletedTmp: deletedTmp,
      criticalMissing: criticalMissing,
      archivePath: archiveResult.success ? archivePath : null,
      archivedCount: filesToArchive.length,
      archiveError: archiveResult.error,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summary);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        criticalMissing: criticalMissing,
        archiveSuccess: archiveResult.success,
        archivedCount: filesToArchive.length,
      );
    });

    final success =
        criticalMissing.isEmpty &&
        archiveResult.success &&
        archiveResult.error == null;
    if (!success) {
      stderr.writeln('Release inventory cleaner detected blocking issues.');
      if (criticalMissing.isNotEmpty) {
        stderr.writeln(
          'Missing critical summaries: ${criticalMissing.join(', ')}',
        );
      }
      if (!archiveResult.success) {
        stderr.writeln('Archive failure: ${archiveResult.error}');
      }
    }

    return success;
  }

  Future<_ArchiveResult> _createArchive(
    String archivePath,
    List<File> sources,
  ) async {
    try {
      final archiveFile = File(archivePath);
      if (await archiveFile.exists()) {
        await archiveFile.delete();
      }
      final process = await Process.start('zip', [
        '-q',
        '-r',
        archiveFile.path,
        ...sources.map((file) => file.uri.pathSegments.last),
      ], workingDirectory: _reportsDir);
      final exit = await process.exitCode;
      if (exit != 0) {
        final err = await process.stderr.transform(utf8.decoder).join();
        return _ArchiveResult(success: false, error: err.trim());
      }
      return _ArchiveResult(success: true);
    } catch (error) {
      return _ArchiveResult(success: false, error: error.toString());
    }
  }

  String _buildTextSummary({
    required List<FileSystemEntity> stale,
    required List<String> deletedTmp,
    required List<String> criticalMissing,
    required String? archivePath,
    required int archivedCount,
    required String? archiveError,
  }) {
    final buffer = StringBuffer()
      ..writeln('RELEASE INVENTORY SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Stale files (>7d): ${stale.length}')
      ..writeln('Deleted temp files: ${deletedTmp.length}')
      ..writeln('Archived files: $archivedCount')
      ..writeln('Archive path: ${archivePath ?? 'FAILED'}')
      ..writeln('Critical missing summaries: ${criticalMissing.length}')
      ..writeln();
    if (stale.isNotEmpty) {
      buffer.writeln('Stale entries:');
      for (final entry in stale.take(10)) {
        buffer.writeln('  - ${entry.uri.pathSegments.last}');
      }
      if (stale.length > 10) {
        buffer.writeln('  ... +${stale.length - 10} more');
      }
      buffer.writeln();
    }
    if (deletedTmp.isNotEmpty) {
      buffer.writeln('Deleted *.tmp/*.bak files:');
      for (final name in deletedTmp) {
        buffer.writeln('  - $name');
      }
      buffer.writeln();
    }
    if (criticalMissing.isNotEmpty) {
      buffer.writeln('Missing critical summaries:');
      for (final name in criticalMissing) {
        buffer.writeln('  - $name');
      }
      buffer.writeln();
    }
    if (archiveError != null) {
      buffer.writeln('Archive error: $archiveError');
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required List<FileSystemEntity> stale,
    required List<String> deletedTmp,
    required List<String> criticalMissing,
    required String? archivePath,
    required int archivedCount,
    required String? archiveError,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'stale_files': stale.map((e) => e.uri.pathSegments.last).toList(),
      'deleted_temp_files': deletedTmp,
      'critical_missing': criticalMissing,
      'archived_count': archivedCount,
      'archive_path': archivePath,
      'archive_error': archiveError,
    };
  }

  Future<void> _appendTelemetry({
    required List<String> criticalMissing,
    required bool archiveSuccess,
    required int archivedCount,
  }) async {
    final payload = <String, Object?>{
      'event': 'release_inventory_cleaner_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'critical_missing': criticalMissing,
      'archive_success': archiveSuccess,
      'archived_count': archivedCount,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _ArchiveResult {
  const _ArchiveResult({required this.success, this.error});

  final bool success;
  final String? error;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}'
    '${value.month.toString().padLeft(2, '0')}'
    '${value.day.toString().padLeft(2, '0')}';

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod fails
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
