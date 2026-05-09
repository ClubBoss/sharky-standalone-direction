import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final validator = _PostReleaseValidator();
  final report = await validator.validate();
  await validator.writeSummary(report);
  await validator.emitTelemetry(report);
}

class _PostReleaseValidator {
  Future<_ValidationReport> validate() async {
    final summaryFile = File('release/_reports/final_archival_summary.txt');
    if (!summaryFile.existsSync()) {
      throw StateError('final_archival_summary.txt not found.');
    }
    final lines = await summaryFile.readAsLines();
    final archivePath = _findArchivePath(lines);
    if (archivePath == null) {
      throw StateError('Archive path not found in summary.');
    }
    final expectedEntries = _parseEntries(lines);
    if (expectedEntries.isEmpty) {
      throw StateError('No entries parsed from summary.');
    }

    final tempDir = await Directory.systemTemp.createTemp('post_release_');
    try {
      final unzip = await Process.run('unzip', [
        '-q',
        archivePath,
        '-d',
        tempDir.path,
      ]);
      if (unzip.exitCode != 0) {
        throw ProcessException(
          'unzip',
          ['-q', archivePath],
          unzip.stderr.toString(),
          unzip.exitCode,
        );
      }

      final mismatches = <_DiffEntry>[];
      for (final entry in expectedEntries.values) {
        final file = File('${tempDir.path}/${entry.path}');
        if (!file.existsSync()) {
          mismatches.add(
            _DiffEntry(
              path: entry.path,
              status: _DiffStatus.missing,
              expectedHash: entry.hash,
              actualHash: '',
            ),
          );
          continue;
        }
        final actualHash = await _sha256(file.path);
        if (actualHash != entry.hash) {
          mismatches.add(
            _DiffEntry(
              path: entry.path,
              status: _DiffStatus.hashMismatch,
              expectedHash: entry.hash,
              actualHash: actualHash,
            ),
          );
        }
      }

      final extractedFiles = _collectFiles(tempDir);
      for (final actualPath in extractedFiles) {
        final relativePath = actualPath.path.replaceFirst(
          '${tempDir.path}/',
          '',
        );
        if (!expectedEntries.containsKey(relativePath)) {
          mismatches.add(
            _DiffEntry(
              path: relativePath,
              status: _DiffStatus.extra,
              expectedHash: '',
              actualHash: await _sha256(actualPath.path),
            ),
          );
        }
      }

      return _ValidationReport(
        archivePath: archivePath,
        expectedCount: expectedEntries.length,
        mismatches: mismatches,
        timestamp: DateTime.now().toUtc(),
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  Future<void> writeSummary(_ValidationReport report) async {
    final buffer = StringBuffer()
      ..writeln('Post-Release Validation Summary')
      ..writeln('Timestamp: ${report.timestamp.toIso8601String()}')
      ..writeln('Archive: ${report.archivePath}')
      ..writeln('Status: ${report.isPass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Entries Expected: ${report.expectedCount}')
      ..writeln('Diff Count: ${report.mismatches.length}')
      ..writeln();
    if (report.mismatches.isEmpty) {
      buffer.writeln('No mismatches detected.');
    } else {
      buffer
        ..writeln('| File | Status | Expected Hash | Actual Hash |')
        ..writeln('| ---- | ------ | ------------- | ----------- |');
      for (final diff in report.mismatches) {
        buffer.writeln(
          '| ${diff.path} | ${diff.status.label} | '
          '${diff.expectedHash.isEmpty ? 'n/a' : diff.expectedHash} | '
          '${diff.actualHash.isEmpty ? 'n/a' : diff.actualHash} |',
        );
      }
    }

    final file = File('release/_reports/post_release_validation_summary.txt');
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
  }

  Future<void> emitTelemetry(_ValidationReport report) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.postReleaseValidationCompleted,
      'timestamp': report.timestamp.toIso8601String(),
      'pass': report.isPass,
      'expected': report.expectedCount,
      'diffs': report.mismatches.length,
    };
    final file = File('release/_reports/telemetry.jsonl');
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  String? _findArchivePath(List<String> lines) {
    for (final line in lines) {
      if (line.startsWith('Archive:')) {
        return line.split(':').sublist(1).join(':').trim();
      }
    }
    return null;
  }

  Map<String, _ExpectedEntry> _parseEntries(List<String> lines) {
    final entries = <String, _ExpectedEntry>{};
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      if (line.contains('File') && line.contains('Size')) continue;
      if (line.contains('----')) continue;
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 4) continue;
      final path = parts[1];
      final sizeStr = parts[2];
      final hash = parts[3];
      if (path.isEmpty || hash.isEmpty) continue;
      final size = int.tryParse(sizeStr) ?? 0;
      entries[path] = _ExpectedEntry(path: path, size: size, hash: hash);
    }
    return entries;
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

  List<File> _collectFiles(Directory root) {
    final files = <File>[];
    for (final entity in root.listSync(recursive: true)) {
      if (entity is File) {
        files.add(entity);
      }
    }
    return files;
  }
}

class _ExpectedEntry {
  const _ExpectedEntry({
    required this.path,
    required this.size,
    required this.hash,
  });

  final String path;
  final int size;
  final String hash;
}

class _ValidationReport {
  const _ValidationReport({
    required this.archivePath,
    required this.expectedCount,
    required this.mismatches,
    required this.timestamp,
  });

  final String archivePath;
  final int expectedCount;
  final List<_DiffEntry> mismatches;
  final DateTime timestamp;

  bool get isPass => mismatches.isEmpty;
}

class _DiffEntry {
  const _DiffEntry({
    required this.path,
    required this.status,
    required this.expectedHash,
    required this.actualHash,
  });

  final String path;
  final _DiffStatus status;
  final String expectedHash;
  final String actualHash;
}

enum _DiffStatus { missing, hashMismatch, extra }

extension on _DiffStatus {
  String get label {
    switch (this) {
      case _DiffStatus.missing:
        return 'MISSING';
      case _DiffStatus.hashMismatch:
        return 'HASH_MISMATCH';
      case _DiffStatus.extra:
        return 'EXTRA';
    }
  }
}
