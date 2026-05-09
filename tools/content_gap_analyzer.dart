import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/content_gap_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/content_gap_summary.txt';
const String _summaryJsonPath = '$_reportsDir/content_gap_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final analyzer = ContentGapAnalyzer();
  final ok = await analyzer.run();
  if (!ok) exitCode = 2;
}

class ContentGapAnalyzer {
  final ContentGapService _service = const ContentGapService();

  Future<bool> run() async {
    final modules = await _service.analyze();
    if (modules.isEmpty) {
      stderr.writeln('No modules found.');
      return false;
    }
    final missingConcepts = modules.fold<int>(
      0,
      (sum, info) => sum + info.missingConcepts.length,
    );
    final densityWarnings = modules.fold<int>(
      0,
      (sum, info) => sum + info.densityWarnings.length,
    );
    final pass = modules.every((info) => info.passed);

    final text = _buildText(modules, missingConcepts, densityWarnings, pass);
    final json = _buildJson(modules, missingConcepts, densityWarnings, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(modules.length, missingConcepts, densityWarnings);
    });

    if (!pass) {
      stderr.writeln('Content gaps detected.');
    }
    return pass;
  }

  String _buildText(
    List<ModuleGapInfo> modules,
    int missingConcepts,
    int densityWarnings,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('CONTENT GAP SUMMARY')
      ..writeln('===================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Modules: ${modules.length}')
      ..writeln('Missing concepts: $missingConcepts')
      ..writeln('Density warnings: $densityWarnings')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    List<ModuleGapInfo> modules,
    int missingConcepts,
    int densityWarnings,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'module_count': modules.length,
    'missing_concepts': missingConcepts,
    'density_warnings': densityWarnings,
    'modules': modules.map((m) => m.toJson()).toList(),
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    int moduleCount,
    int missingConcepts,
    int densityWarnings,
  ) async {
    final payload = <String, Object?>{
      'event': 'content_gap_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'module_count': moduleCount,
      'total_missing_concepts': missingConcepts,
      'total_density_warnings': densityWarnings,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
