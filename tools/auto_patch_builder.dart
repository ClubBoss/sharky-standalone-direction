import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

Future<void> main(List<String> args) async {
  final start = DateTime.now().toUtc();
  final currentVersion = await _readCurrentVersion();
  final baseTag = await _detectGitBaseTag();

  List<String> changedFiles = <String>[];
  var usedFallback = false;
  DateTime? fallbackTimestamp;
  if (baseTag != null) {
    changedFiles = await _diffFromGit(baseTag);
  }

  if (changedFiles.isEmpty) {
    usedFallback = true;
    fallbackTimestamp = await _readLastVersionTimestamp();
    final since =
        fallbackTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    changedFiles = await _diffFromTimestamps(since);
  }

  if (changedFiles.isEmpty) {
    stderr.writeln('No changes detected under lib/ or tools/ for patch.');
    exit(1);
  }

  final archivePath = 'release/patches';
  await Directory(archivePath).create(recursive: true);
  final patchFilePath = '$archivePath/patch_$currentVersion.zip';
  final archive = Archive();

  final includedFiles = <String>[];
  for (final path in changedFiles) {
    final file = File(path);
    if (!await file.exists()) {
      continue;
    }
    final bytes = await file.readAsBytes();
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
    includedFiles.add(path);
  }

  if (archive.isEmpty) {
    stderr.writeln('No valid files to include in patch.');
    exit(1);
  }

  final encoder = ZipEncoder();
  final encoded = encoder.encode(archive);
  final patchFile = File(patchFilePath);
  await patchFile.writeAsBytes(encoded, flush: true);

  final duration = DateTime.now().toUtc().difference(start);
  final patchSize = await patchFile.length();

  await _writePatchSummary(
    currentVersion: currentVersion,
    fileCount: includedFiles.length,
    files: includedFiles,
    patchPath: patchFilePath,
    sizeBytes: patchSize,
    duration: duration,
  );

  await _appendVersionLog(
    currentVersion,
    patchFilePath,
    includedFiles.length,
    patchSize,
  );

  final telemetry = jsonEncode({
    'event': 'auto_patch_generated',
    'version': currentVersion,
    'file_count': includedFiles.length,
    'archive_path': patchFilePath,
    'archive_bytes': patchSize,
    'duration_ms': duration.inMilliseconds,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    if (baseTag != null) 'base_tag': baseTag,
    if (usedFallback)
      'fallback_timestamp':
          (fallbackTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0).toUtc())
              .toIso8601String(),
  });
  stdout.writeln(telemetry);
}

Future<String> _readCurrentVersion() async {
  final file = File('pubspec.yaml');
  if (!await file.exists()) {
    stderr.writeln('pubspec.yaml not found.');
    exit(1);
  }
  final content = await file.readAsString();
  final lines = const LineSplitter().convert(content);
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('version:')) {
      return trimmed.substring('version:'.length).trim();
    }
  }
  stderr.writeln('Unable to locate version in pubspec.yaml.');
  exit(1);
}

Future<String?> _detectGitBaseTag() async {
  final describe = await Process.run('git', [
    'describe',
    '--tags',
    '--abbrev=0',
  ], runInShell: false);
  if (describe.exitCode != 0) {
    return null;
  }
  final tag = (describe.stdout as String).trim();
  if (tag.isEmpty) {
    return null;
  }
  return tag;
}

Future<List<String>> _diffFromGit(String baseTag) async {
  final diff = await Process.run('git', [
    'diff',
    '--name-only',
    '$baseTag..HEAD',
    '--',
    'lib',
    'tools',
  ], runInShell: false);
  if (diff.exitCode != 0) {
    return <String>[];
  }
  final output = (diff.stdout as String).trim();
  if (output.isEmpty) {
    return <String>[];
  }
  return output.split('\n').where((path) => path.isNotEmpty).toList();
}

Future<DateTime?> _readLastVersionTimestamp() async {
  final file = File('release/_reports/version_tag_log.txt');
  if (!await file.exists()) {
    return null;
  }
  final lines = await file.readAsLines();
  DateTime? last;
  for (final line in lines) {
    if (line.startsWith('Timestamp:')) {
      final value = line.substring('Timestamp:'.length).trim();
      try {
        last = DateTime.parse(value).toUtc();
      } catch (_) {
        // Ignore malformed line.
      }
    }
  }
  return last;
}

Future<List<String>> _diffFromTimestamps(DateTime since) async {
  final collected = <String>[];
  final directories = <String>['lib', 'tools'];
  for (final root in directories) {
    final directory = Directory(root);
    if (!await directory.exists()) {
      continue;
    }
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      final stat = await entity.stat();
      final modified = stat.modified.toUtc();
      if (modified.isAfter(since)) {
        collected.add(entity.path);
      }
    }
  }
  collected.sort();
  return collected;
}

Future<void> _writePatchSummary({
  required String currentVersion,
  required int fileCount,
  required List<String> files,
  required String patchPath,
  required int sizeBytes,
  required Duration duration,
}) async {
  final reportsDir = Directory('release/_reports');
  await reportsDir.create(recursive: true);
  final file = File('${reportsDir.path}/patch_summary.txt');
  final buffer = StringBuffer()
    ..writeln('---')
    ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Version: $currentVersion')
    ..writeln('Patch: $patchPath')
    ..writeln('Files: $fileCount')
    ..writeln('SizeBytes: $sizeBytes')
    ..writeln('DurationMs: ${duration.inMilliseconds}')
    ..writeln('Affected Files:');
  for (final path in files) {
    buffer.writeln(' - $path');
  }
  await file.writeAsString(buffer.toString());
}

Future<void> _appendVersionLog(
  String version,
  String patchPath,
  int fileCount,
  int sizeBytes,
) async {
  final logDir = Directory('release/_reports');
  await logDir.create(recursive: true);
  final logFile = File('${logDir.path}/version_tag_log.txt');
  final entry =
      'Patched: $version -> $patchPath ($fileCount files, $sizeBytes bytes)\n';
  await logFile.writeAsString(entry, mode: FileMode.append);
}
