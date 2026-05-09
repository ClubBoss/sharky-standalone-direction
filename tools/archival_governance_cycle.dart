import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final cycle = _ArchivalGovernanceCycle();
  final result = await cycle.run();
  result.printSummary();
  await result.writeLog();
  result.emitTelemetry();
  if (result.hasErrors) {
    exit(1);
  }
}

class _ArchivalGovernanceCycle {
  static const String _reportsDir = 'release/_reports';
  static const String _archivesDir = 'release/_archives';
  static const String _logPath = 'release/_reports/archival_governance_log.txt';
  static const int _maxCycles = 6;

  Future<_CycleResult> run() async {
    final warnings = <String>[];
    final reports = _collectFiles(_reportsDir);
    if (reports.isEmpty) {
      warnings.add('No reports found in $_reportsDir');
    }

    final archiveName = 'archive_${_todayString()}.zip';
    final archivePath = '$_archivesDir/$archiveName';
    int checksums = 0;

    if (reports.isNotEmpty) {
      await _createArchive(reports, archivePath);
      checksums = await _logChecksums(reports);
    } else {
      await Directory(_archivesDir).create(recursive: true);
      File(archivePath).writeAsBytesSync(const <int>[]);
    }

    final deleted = await _pruneOldArchives();

    return _CycleResult(
      archivePath: archivePath,
      archiveCount: _archiveFiles().length,
      deletedCount: deleted,
      warningCount: warnings.length,
      warnings: warnings,
      checksumCount: checksums,
    );
  }

  List<File> _collectFiles(String dirPath) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) return <File>[];
    return dir.listSync(recursive: false).whereType<File>().toList();
  }

  Future<void> _createArchive(List<File> files, String archivePath) async {
    final archive = Archive();
    for (final file in files) {
      final data = await file.readAsBytes();
      final relative = file.path.split('/').last;
      archive.addFile(ArchiveFile(relative, data.length, data));
    }
    final encoder = ZipEncoder();
    final bytes = encoder.encode(archive);
    final outFile = File(archivePath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsBytes(bytes, flush: true);
  }

  Future<int> _logChecksums(List<File> files) async {
    final buffer = StringBuffer()
      ..writeln('=== ${DateTime.now().toUtc().toIso8601String()} ===');
    for (final file in files) {
      final checksum = await _sha256(file);
      final name = file.path.split('/').last;
      buffer.writeln('- $name: $checksum');
    }
    buffer.writeln('');
    final logFile = File(_logPath);
    await logFile.parent.create(recursive: true);
    await logFile.writeAsString(buffer.toString(), mode: FileMode.append);
    return files.length;
  }

  Future<int> _pruneOldArchives() async {
    final files = _archiveFiles();
    if (files.length <= _maxCycles) return 0;
    files.sort((a, b) => b.path.compareTo(a.path));
    final toDelete = files.skip(_maxCycles).toList();
    for (final file in toDelete) {
      await file.delete();
    }
    return toDelete.length;
  }

  List<File> _archiveFiles() {
    final dir = Directory(_archivesDir);
    if (!dir.existsSync()) return <File>[];
    return dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.zip'))
        .toList();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

class _CycleResult {
  _CycleResult({
    required this.archivePath,
    required this.archiveCount,
    required this.deletedCount,
    required this.warningCount,
    required this.warnings,
    required this.checksumCount,
  });

  final String archivePath;
  final int archiveCount;
  final int deletedCount;
  final int warningCount;
  final List<String> warnings;
  final int checksumCount;

  bool get hasErrors => false;

  void printSummary() {
    stdout.writeln('+----------------+--------+');
    stdout.writeln('| Metric         | Value  |');
    stdout.writeln('+----------------+--------+');
    stdout.writeln(
      '| Archives kept  | ${archiveCount.toString().padLeft(6)} |',
    );
    stdout.writeln(
      '| Archives pruned| ${deletedCount.toString().padLeft(6)} |',
    );
    stdout.writeln(
      '| Checksums      | ${checksumCount.toString().padLeft(6)} |',
    );
    stdout.writeln(
      '| Warnings       | ${warningCount.toString().padLeft(6)} |',
    );
    stdout.writeln('+----------------+--------+');
    if (warnings.isNotEmpty) {
      stdout.writeln('Warnings:');
      for (final warn in warnings) {
        stdout.writeln(' - $warn');
      }
    }
  }

  Future<void> writeLog() async {
    final summary = File('release/_reports/archival_cycle_summary.txt');
    await summary.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Archival Governance Cycle')
      ..writeln('Archive: $archivePath')
      ..writeln('archives_kept=$archiveCount')
      ..writeln('archives_pruned=$deletedCount')
      ..writeln('checksums=$checksumCount')
      ..writeln('warnings=$warningCount');
    await summary.writeAsString(buffer.toString());
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': TelemetryEvents.archivalGovernanceCycleCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'archiveCount': archiveCount,
      'checksumCount': checksumCount,
      'deletedCount': deletedCount,
      'warnings': warningCount,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

Future<String> _sha256(File file) async {
  final digest = sha256.convert(await file.readAsBytes());
  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}
