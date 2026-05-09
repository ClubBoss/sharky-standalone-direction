import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/mastery_transfer_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/mastery_transfer_summary.txt';
const String _summaryJsonPath = '$_reportsDir/mastery_transfer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = MasteryTransferEngineDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MasteryTransferEngineDashboard {
  final MasteryTransferEngineService _service =
      const MasteryTransferEngineService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing mastery transfer inputs.');
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

    final learningTransfer = result.learningTransfer.score;
    final retention = result.retentionKnowledge.score;
    final adaptiveDrill = result.adaptiveDrill.score;
    final index =
        ((learningTransfer * 0.4) + (retention * 0.35) + (adaptiveDrill * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      learningTransfer,
      retention,
      adaptiveDrill,
      index,
      pass,
    );
    final json = _buildJson(
      learningTransfer,
      retention,
      adaptiveDrill,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        learningTransfer,
        retention,
        adaptiveDrill,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Mastery Transfer Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(MasteryTransferEngineResult result) =>
      result.learningTransfer.verdict == 'PASS' &&
      result.retentionKnowledge.verdict == 'PASS' &&
      result.adaptiveDrill.verdict == 'PASS';

  bool _timestampsAligned(MasteryTransferEngineResult result) {
    final timestamps = <DateTime>[
      if (result.learningTransfer.timestamp != null)
        result.learningTransfer.timestamp!,
      if (result.retentionKnowledge.timestamp != null)
        result.retentionKnowledge.timestamp!,
      if (result.adaptiveDrill.timestamp != null)
        result.adaptiveDrill.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double learningTransfer,
    double retention,
    double adaptiveDrill,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('MASTERY TRANSFER SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Learning transfer: ${pct(learningTransfer)}')
      ..writeln('Retention knowledge: ${pct(retention)}')
      ..writeln('Adaptive drill: ${pct(adaptiveDrill)}')
      ..writeln('Mastery Transfer Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double learningTransfer,
    double retention,
    double adaptiveDrill,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'learning_transfer_score': learningTransfer,
    'retention_knowledge_score': retention,
    'adaptive_drill_index': adaptiveDrill,
    'mastery_transfer_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double learningTransfer,
    double retention,
    double adaptiveDrill,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'mastery_transfer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'learning_transfer_score': learningTransfer,
      'retention_knowledge_score': retention,
      'adaptive_drill_index': adaptiveDrill,
      'mastery_transfer_index': index,
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
