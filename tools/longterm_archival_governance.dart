import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

Future<void> main(List<String> args) async {
  final sources = <String>[
    'release/_reports/final_release_summary.txt',
    'release/_reports/postlaunch_monitor.json',
    'release/_reports/stability_scaling_plan.txt',
    'release/_reports/ai_adaptive_patch.json',
  ];

  final missing = sources.where((path) => !File(path).existsSync()).toList();
  if (missing.isNotEmpty) {
    stderr.writeln('Missing required reports: ${missing.join(', ')}');
    exit(1);
  }

  final checksums = <String, String>{};
  for (final path in sources) {
    checksums[path] = await _sha256(File(path));
  }

  final archiveDir = Directory('release/_archives');
  await archiveDir.create(recursive: true);
  final timestamp = DateTime.now()
      .toUtc()
      .toIso8601String()
      .replaceAll(':', '')
      .split('.')
      .first;
  final archiveName = '${timestamp}_full_report.zip';
  final archivePath = '${archiveDir.path}/$archiveName';

  await _createZip(sources, archivePath);

  await _applyRetention(archiveDir, keep: 6);
  await _appendGovernanceLog(archivePath, checksums);

  stdout.writeln(
    jsonEncode({
      'event': 'longterm_archival_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'archivesKept': await _countArchives(archiveDir),
      'deleted': _deletedCount,
      'checksumList': checksums,
    }),
  );
}

Future<String> _sha256(File file) async {
  final bytes = await file.readAsBytes();
  final digest = sha256.convert(bytes);
  final buffer = StringBuffer();
  for (final byte in digest.bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

Future<void> _createZip(List<String> sources, String archivePath) async {
  final archive = ZipEncoder();
  final archiveData = Archive();
  for (final path in sources) {
    final file = File(path);
    final data = await file.readAsBytes();
    archiveData.addFile(ArchiveFile(path.split('/').last, data.length, data));
  }
  final bytes = archive.encode(archiveData);
  final outFile = File(archivePath);
  await outFile.writeAsBytes(bytes);
}

int _deletedCount = 0;

Future<void> _applyRetention(Directory archiveDir, {required int keep}) async {
  final archives =
      archiveDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.zip'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
  if (archives.length <= keep) {
    return;
  }
  final toDelete = archives.sublist(keep);
  for (final file in toDelete) {
    await file.delete();
    _deletedCount += 1;
  }
}

Future<void> _appendGovernanceLog(
  String archivePath,
  Map<String, String> checksums,
) async {
  final file = File('release/_reports/governance_log.txt');
  await file.parent.create(recursive: true);
  final buffer = StringBuffer()
    ..writeln('Date: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Archive: $archivePath')
    ..writeln('Retention: keep last 6 archives')
    ..writeln('Checksums:');
  checksums.forEach((path, checksum) {
    buffer.writeln(' - ${path.split('/').last}: $checksum');
  });
  buffer.writeln('');
  await file.writeAsString(buffer.toString(), mode: FileMode.append);
}

Future<int> _countArchives(Directory archiveDir) async {
  return archiveDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.zip'))
      .length;
}
