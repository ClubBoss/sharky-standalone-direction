import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const String _finalSummaryPath = 'release/_reports/final_archival_summary.txt';
const String _reportsDir = 'release/_reports';
const String _archivesDir = 'release/_archives';
const String _outputPath = 'release/_reports/archival_verification_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final expected = await _readExpectedEntries();
  final actual = await _hashCurrentFiles();

  final mismatches = <_Drift>[];
  final missing = <_ExpectedEntry>[];
  var verified = 0;

  expected.forEach((path, entry) {
    final actualHash = actual[path];
    if (actualHash == null) {
      missing.add(entry);
      return;
    }
    if (actualHash != entry.hash) {
      mismatches.add(_Drift(entry: entry, actualHash: actualHash));
    } else {
      verified++;
    }
  });

  final extras =
      actual.keys.where((path) => !expected.containsKey(path)).toList()..sort();

  final driftPercent = expected.isEmpty
      ? 0.0
      : ((missing.length + mismatches.length) / expected.length) * 100;

  await _withReportsWritable(() async {
    await _writeSummary(
      verified: verified,
      expectedTotal: expected.length,
      driftPercent: driftPercent,
      missing: missing,
      mismatches: mismatches,
      extras: extras,
    );
    await _appendTelemetry(
      verified: verified,
      mismatched: mismatches.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'archival_verification_lock_v2: verified=$verified '
    'missing=${missing.length} mismatched=${mismatches.length}',
  );
}

Future<Map<String, _ExpectedEntry>> _readExpectedEntries() async {
  final file = File(_finalSummaryPath);
  if (!await file.exists()) return <String, _ExpectedEntry>{};
  final entries = <String, _ExpectedEntry>{};
  final pattern = RegExp(
    r'^\|\s*(.+?)\s*\|\s*(\d+)\s*\|\s*([0-9a-fA-F]{64})\s*\|',
  );
  for (final line in await file.readAsLines()) {
    final match = pattern.firstMatch(line.trim());
    if (match == null) continue;
    final path = match.group(1)!.replaceAll('//', '/');
    if (!path.startsWith('release/_reports/') &&
        !path.startsWith('release/_archives/')) {
      continue;
    }
    entries[path] = _ExpectedEntry(
      path: path,
      size: int.tryParse(match.group(2) ?? '0') ?? 0,
      hash: match.group(3)!.toLowerCase(),
    );
  }
  return entries;
}

Future<Map<String, String>> _hashCurrentFiles() async {
  final result = <String, String>{};
  for (final root in [_reportsDir, _archivesDir]) {
    final dir = Directory(root);
    if (!await dir.exists()) continue;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relativePath = entity.path.replaceAll('\\', '/');
      final hash = await _hashFile(entity);
      result[relativePath] = hash;
    }
  }
  return result;
}

Future<String> _hashFile(File file) async {
  final digest = sha256.convert(await file.readAsBytes());
  return digest.toString();
}

Future<void> _writeSummary({
  required int verified,
  required int expectedTotal,
  required double driftPercent,
  required List<_ExpectedEntry> missing,
  required List<_Drift> mismatches,
  required List<String> extras,
}) async {
  final buffer = StringBuffer()
    ..writeln('ARCHIVAL VERIFICATION SUMMARY V2')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Files verified: $verified / $expectedTotal')
    ..writeln('Drift: ${driftPercent.toStringAsFixed(2)}%')
    ..writeln('Missing: ${missing.length}')
    ..writeln('Mismatches: ${mismatches.length}')
    ..writeln()
    ..writeln('Missing Files:');
  if (missing.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final entry in missing.take(10)) {
      buffer.writeln('- ${entry.path}');
    }
    if (missing.length > 10) {
      buffer.writeln('- ... (${missing.length - 10} more)');
    }
  }

  buffer
    ..writeln()
    ..writeln('Mismatched Files:');
  if (mismatches.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final drift in mismatches.take(10)) {
      buffer.writeln(
        '- ${drift.entry.path}: expected ${drift.entry.hash} | actual ${drift.actualHash}',
      );
    }
    if (mismatches.length > 10) {
      buffer.writeln('- ... (${mismatches.length - 10} more)');
    }
  }

  buffer
    ..writeln()
    ..writeln('Extra Files (not in final summary):');
  if (extras.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final path in extras.take(10)) {
      buffer.writeln('- $path');
    }
    if (extras.length > 10) {
      buffer.writeln('- ... (${extras.length - 10} more)');
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int verified,
  required int mismatched,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'archival_verification_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'verified': verified,
    'mismatched': mismatched,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    jsonEncode(payload) + '\n',
    mode: FileMode.append,
    flush: true,
  );
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
      'archival_verification_lock_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
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

class _Drift {
  const _Drift({required this.entry, required this.actualHash});

  final _ExpectedEntry entry;
  final String actualHash;
}
