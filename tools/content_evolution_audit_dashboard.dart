import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/content_evolution_audit_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/content_evolution_audit_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/content_evolution_audit_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final dashboard = ContentEvolutionAuditDashboard();
  final ok = await dashboard.run();
  if (!ok) exitCode = 2;
}

class ContentEvolutionAuditDashboard {
  final ContentEvolutionAuditService _service =
      const ContentEvolutionAuditService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing content evolution inputs.');
      return false;
    }

    if (!_allPass(result)) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    if (!_timestampsAligned(result)) {
      stderr.writeln('Timestamps span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final index =
        ((result.personaEvolution.score * 0.4) +
                (result.contentSync.score * 0.35) +
                (result.retentionGrowth.score * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      result.personaEvolution.score,
      result.contentSync.score,
      result.retentionGrowth.score,
      index,
      pass,
    );
    final json = _buildJson(
      result.personaEvolution.score,
      result.contentSync.score,
      result.retentionGrowth.score,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        result.personaEvolution.score,
        result.contentSync.score,
        result.retentionGrowth.score,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Content Evolution Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPass(ContentEvolutionAuditResult result) =>
      result.personaEvolution.verdict == 'PASS' &&
      result.contentSync.verdict == 'PASS' &&
      result.retentionGrowth.verdict == 'PASS';

  bool _timestampsAligned(ContentEvolutionAuditResult result) {
    final timestamps = <DateTime>[
      if (result.personaEvolution.timestamp != null)
        result.personaEvolution.timestamp!,
      if (result.contentSync.timestamp != null) result.contentSync.timestamp!,
      if (result.retentionGrowth.timestamp != null)
        result.retentionGrowth.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double persona,
    double content,
    double retention,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONTENT EVOLUTION AUDIT SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Persona evolution: ${pct(persona)}')
      ..writeln('Content sync: ${pct(content)}')
      ..writeln('Retention growth: ${pct(retention)}')
      ..writeln('Content Evolution Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double persona,
    double content,
    double retention,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'persona_evolution_score': persona,
    'content_sync_score': content,
    'retention_growth_score': retention,
    'content_evolution_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double persona,
    double content,
    double retention,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'content_evolution_audit_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'persona_evolution_score': persona,
      'content_sync_score': content,
      'retention_growth_score': retention,
      'content_evolution_index': index,
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
