import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/skill_consolidation_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/skill_consolidation_summary.txt';
const String _summaryJsonPath = '$_reportsDir/skill_consolidation_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = SkillConsolidationEngineDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SkillConsolidationEngineDashboard {
  final SkillConsolidationEngineService _service =
      const SkillConsolidationEngineService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing skill consolidation inputs.');
      return false;
    }

    if (!_allPassed(result)) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    if (!_timestampsAligned(result)) {
      stderr.writeln('Inputs span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final mastery = result.masteryTransfer.score;
    final learning = result.learningTransfer.score;
    final reinforcement = result.reinforcementSynthesizer.score;
    final index = ((mastery * 0.4) + (learning * 0.35) + (reinforcement * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(mastery, learning, reinforcement, index, pass);
    final json = _buildJson(mastery, learning, reinforcement, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(mastery, learning, reinforcement, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Skill Consolidation Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(SkillConsolidationEngineResult result) =>
      result.masteryTransfer.verdict == 'PASS' &&
      result.learningTransfer.verdict == 'PASS' &&
      result.reinforcementSynthesizer.verdict == 'PASS';

  bool _timestampsAligned(SkillConsolidationEngineResult result) {
    final timestamps = <DateTime>[
      if (result.masteryTransfer.timestamp != null)
        result.masteryTransfer.timestamp!,
      if (result.learningTransfer.timestamp != null)
        result.learningTransfer.timestamp!,
      if (result.reinforcementSynthesizer.timestamp != null)
        result.reinforcementSynthesizer.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double mastery,
    double learning,
    double reinforcement,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SKILL CONSOLIDATION SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Mastery transfer: ${pct(mastery)}')
      ..writeln('Learning transfer: ${pct(learning)}')
      ..writeln('Reinforcement synthesis: ${pct(reinforcement)}')
      ..writeln('Skill Consolidation Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double mastery,
    double learning,
    double reinforcement,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'mastery_transfer_score': mastery,
    'learning_transfer_score': learning,
    'reinforcement_score': reinforcement,
    'skill_consolidation_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double mastery,
    double learning,
    double reinforcement,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'skill_consolidation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'mastery_transfer_score': mastery,
      'learning_transfer_score': learning,
      'reinforcement_score': reinforcement,
      'skill_consolidation_index': index,
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
