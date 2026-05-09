import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_drill_expansion_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/adaptive_drill_expansion_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_drill_expansion_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _minAverageEv = 1.09;

Future<void> main(List<String> args) async {
  final engine = AdaptiveDrillExpansionEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveDrillExpansionEngine {
  final AdaptiveDrillExpansionService _service =
      AdaptiveDrillExpansionService();

  Future<bool> run() async {
    final result = await _service.expand();
    final pass = result.averageEv >= _minAverageEv;

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
        'Adaptive drill expansion average EV '
        '${result.averageEv.toStringAsFixed(4)} below 1.09 threshold.',
      );
    }

    return pass;
  }

  String _buildTextSummary(AdaptiveDrillExpansionResult result, bool pass) {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE DRILL EXPANSION SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Average EV multiplier: ${result.averageEv.toStringAsFixed(4)}')
      ..writeln('Threshold: ${_minAverageEv.toStringAsFixed(2)}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    if (result.topics.isEmpty) {
      buffer.writeln('No topics detected in semantic summary.');
    } else {
      buffer.writeln('Topic metrics:');
      for (final topic in result.topics.take(20)) {
        buffer.writeln(
          '  - ${topic.name}: EV=${topic.evScore.toStringAsFixed(4)} '
          '(base=${topic.baseEv.toStringAsFixed(4)}, '
          'res=${topic.resonanceWeight.toStringAsFixed(3)}, '
          'adapt=${topic.adaptationWeight.toStringAsFixed(3)}) '
          '${topic.reinforce ? '[reinforce]' : ''}',
        );
      }
      if (result.topics.length > 20) {
        buffer.writeln('  ... +${result.topics.length - 20} topics');
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AdaptiveDrillExpansionResult result,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'average_ev': result.averageEv,
      'threshold': _minAverageEv,
      'topics': result.topics
          .map(
            (topic) => {
              'name': topic.name,
              'base_ev': topic.baseEv,
              'resonance_weight': topic.resonanceWeight,
              'adaptation_weight': topic.adaptationWeight,
              'ev_score': topic.evScore,
              'reinforce': topic.reinforce,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    AdaptiveDrillExpansionResult result,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_drill_expansion_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'average_ev': result.averageEv,
      'threshold': _minAverageEv,
      'topic_count': result.topics.length,
      'reinforcement_count': result.topics
          .where((topic) => topic.reinforce)
          .length,
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
