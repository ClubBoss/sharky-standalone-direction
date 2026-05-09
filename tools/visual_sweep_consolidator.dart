import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final consolidator = _VisualSweepConsolidator();
  await consolidator.generateSummary();
}

class _VisualSweepConsolidator {
  static const String _violationsPath =
      'release/_reports/visual_token_violations.txt';
  static const String _uxReportPath = 'release/_reports/ux_polish_sweep.txt';
  static const String _summaryPath =
      'release/_reports/visual_sweep_summary.txt';

  Future<void> generateSummary() async {
    final violationsFile = File(_violationsPath);
    final uxReportFile = File(_uxReportPath);

    if (!violationsFile.existsSync()) {
      stderr.writeln('Missing $_violationsPath');
      exit(1);
    }
    if (!uxReportFile.existsSync()) {
      stderr.writeln('Missing $_uxReportPath');
      exit(1);
    }

    final violationLines = violationsFile
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final fileCounts = <String, int>{};
    for (final line in violationLines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex <= 0) continue;
      final filePath = line.substring(0, colonIndex);
      fileCounts[filePath] = (fileCounts[filePath] ?? 0) + 1;
    }

    final topOffenders = fileCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTen = topOffenders.take(10).toList();

    final uxLines = uxReportFile.readAsLinesSync();
    final filesScannedLine = uxLines
        .firstWhere(
          (line) => line.toLowerCase().startsWith('files scanned:'),
          orElse: () => 'Files scanned: unknown',
        )
        .trim();
    final warningsLine = uxLines
        .firstWhere(
          (line) => line.toLowerCase().startsWith('total warnings:'),
          orElse: () => 'Total warnings: 0',
        )
        .trim();
    final screensLine = uxLines
        .firstWhere(
          (line) => line.toLowerCase().startsWith('screens with warnings:'),
          orElse: () => 'Screens with warnings: 0',
        )
        .trim();

    final uxWarnings = _extractInt(warningsLine);

    final summary = StringBuffer()
      ..writeln('Visual Sweep Summary (Stage Ω11B-A.1d)')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln()
      ..writeln('Visual token violations: ${violationLines.length}')
      ..writeln('Unique files with violations: ${fileCounts.length}')
      ..writeln('UX polish warnings: $uxWarnings')
      ..writeln(filesScannedLine)
      ..writeln(screensLine)
      ..writeln();

    if (topTen.isNotEmpty) {
      summary.writeln('Top offending files:');
      for (var i = 0; i < topTen.length; i++) {
        final entry = topTen[i];
        summary.writeln('  ${i + 1}. ${entry.key} (${entry.value} issues)');
      }
      summary.writeln();
    }

    summary
      ..writeln('Source Reports:')
      ..writeln('  - $_violationsPath')
      ..writeln('  - $_uxReportPath');

    final summaryFile = File(_summaryPath);
    summaryFile.parent.createSync(recursive: true);
    summaryFile.writeAsStringSync(summary.toString());

    if (violationLines.isNotEmpty) {
      stdout.writeln('Top offending files:');
      for (final entry in topTen) {
        stdout.writeln('  ${entry.key} — ${entry.value}');
      }
    }

    _emitTelemetry(
      filesScanned: fileCounts.length,
      warnings: violationLines.length + uxWarnings,
      fixes: 0,
    );
  }

  void _emitTelemetry({
    required int filesScanned,
    required int warnings,
    required int fixes,
  }) {
    final payload = <String, Object>{
      'event': TelemetryEvents.visualSweepCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'files_scanned': filesScanned,
      'warnings': warnings,
      'fixes': fixes,
    };
    stdout.writeln(jsonEncode(payload));
  }

  static int _extractInt(String line) {
    final parts = line.split(':');
    if (parts.length < 2) return 0;
    return int.tryParse(parts[1].trim()) ?? 0;
  }
}
