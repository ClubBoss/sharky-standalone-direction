import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/content_sync_audit_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/content_sync_audit_summary.txt';
const String _summaryJsonPath = '$_reportsDir/content_sync_audit_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final dashboard = ContentSyncAuditDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContentSyncAuditDashboard {
  ContentSyncAuditDashboard({ContentSyncAuditService? service})
    : _service = service ?? ContentSyncAuditService();

  final ContentSyncAuditService _service;

  Future<bool> run() async {
    final result = await _service.audit();
    if (result == null) {
      stderr.writeln(
        'Missing content sync inputs (adaptive drill / skill fusion / smart pack / persona summaries).',
      );
      return false;
    }

    final pass = result.contentConsistencyIndex >= _threshold;
    final summaryText = _buildTextSummary(result, pass);
    final summaryJson = _buildJsonSummary(result, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Content Consistency Index '
        '${result.contentConsistencyIndex.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  String _buildTextSummary(ContentSyncAuditResult result, bool pass) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONTENT SYNC AUDIT SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Adaptive drill score: ${pct(result.adaptiveScore)}')
      ..writeln('Skill-fusion coverage: ${pct(result.skillFusionCoverage)}')
      ..writeln('Smart pack alignment: ${pct(result.smartPackAlignment)}')
      ..writeln('Persona sync score: ${pct(result.personaSync)}')
      ..writeln(
        'Content Consistency Index: ${pct(result.contentConsistencyIndex)}',
      )
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    ContentSyncAuditResult result,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'adaptive_drill_score': result.adaptiveScore,
      'skill_fusion_coverage': result.skillFusionCoverage,
      'smart_pack_alignment': result.smartPackAlignment,
      'persona_sync_score': result.personaSync,
      'content_consistency_index': result.contentConsistencyIndex,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    ContentSyncAuditResult result,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'content_sync_audit_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'adaptive_drill_score': result.adaptiveScore,
      'skill_fusion_coverage': result.skillFusionCoverage,
      'smart_pack_alignment': result.smartPackAlignment,
      'persona_sync_score': result.personaSync,
      'content_consistency_index': result.contentConsistencyIndex,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
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
