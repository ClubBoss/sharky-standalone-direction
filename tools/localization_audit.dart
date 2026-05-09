import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localization_core.dart';

const String _summaryPath = 'release/_reports/localization_audit_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final audit = LocalizationAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LocalizationAudit {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    await LocalizationCore.instance.load();
    final translations = LocalizationCore.instance;
    final files = await _collectDartFiles();
    final issues = <String, List<String>>{};

    final regex = RegExp(r'AppLocalizations\.of\([^)]*\)\.([a-zA-Z0-9_]+)');
    for (final file in files) {
      final text = await file.readAsString();
      final matches = regex.allMatches(text);
      for (final match in matches) {
        final key = match.group(1);
        if (key == null) continue;
        final missingLangs = <String>[];
        for (final lang in translations.languages) {
          if (!translations.hasKey(lang, key)) {
            missingLangs.add(lang);
          }
        }
        if (missingLangs.isNotEmpty) {
          issues
              .putIfAbsent(file.path, () => <String>[])
              .add('Key "$key" missing for: ${missingLangs.join(', ')}');
        }
      }
    }

    final hasIssues = issues.isNotEmpty;
    await _withReportsWritable(() async {
      await _writeSummary(
        issues: issues,
        filesScanned: files.length,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        issues: issues,
        filesScanned: files.length,
        durationMs: stopwatch.elapsedMilliseconds,
        verdict: hasIssues ? 'FAIL' : 'PASS',
      );
    });

    return !hasIssues;
  }

  Future<List<File>> _collectDartFiles() async {
    final dir = Directory('lib');
    if (!await dir.exists()) return const [];
    final files = <File>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
    return files;
  }

  Future<void> _writeSummary({
    required Map<String, List<String>> issues,
    required int filesScanned,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('LOCALIZATION AUDIT SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Files scanned: $filesScanned')
      ..writeln();

    if (issues.isEmpty) {
      buffer.writeln('No missing localization keys detected.');
    } else {
      buffer.writeln('Issues:');
      issues.forEach((path, messages) {
        buffer.writeln('- $path');
        for (final message in messages) {
          buffer.writeln('  • $message');
        }
      });
    }

    await File(_summaryPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry({
    required Map<String, List<String>> issues,
    required int filesScanned,
    required int durationMs,
    required String verdict,
  }) async {
    final payload = <String, Object?>{
      'event': 'localization_audit_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'verdict': verdict,
      'files_scanned': filesScanned,
      'issue_count': issues.length,
      'issues': issues,
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
