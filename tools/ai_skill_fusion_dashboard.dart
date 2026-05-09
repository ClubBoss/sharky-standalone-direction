import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ai_skill_fusion_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ai_skill_fusion_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ai_skill_fusion_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final dashboard = AiSkillFusionDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiSkillFusionDashboard {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final service = AiSkillFusionService();
    late final AiSkillFusionResult result;
    try {
      result = await service.buildDashboard();
    } on StateError catch (error) {
      stderr.writeln(error.message);
      return false;
    }

    if (result.averageFusion < 70) {
      stderr.writeln(
        'Average fusion index ${result.averageFusion.toStringAsFixed(2)} below 70%.',
      );
      return false;
    }

    final summaryText = _buildTextSummary(
      result,
      stopwatch.elapsedMilliseconds,
    );
    final summaryJson = _buildJsonSummary(
      result,
      stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, stopwatch.elapsedMilliseconds);
    });

    return true;
  }

  String _buildTextSummary(AiSkillFusionResult result, int durationMs) {
    final buffer = StringBuffer()
      ..writeln('AI SKILL FUSION DASHBOARD')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Traits active: ${result.traitCount}')
      ..writeln(
        'Average fusion index: ${result.averageFusion.toStringAsFixed(2)}%',
      )
      ..writeln();
    final sorted = [...result.entries]
      ..sort((a, b) => b.fusionIndex.compareTo(a.fusionIndex));
    for (final entry in sorted) {
      buffer
        ..writeln('- ${entry.stat}')
        ..writeln(
          '  fusion=${entry.fusionIndex.toStringAsFixed(2)}% '
          'progress=${(entry.progress * 100).toStringAsFixed(1)}% '
          'accuracy=${(entry.accuracy * 100).toStringAsFixed(1)}% '
          'uplift=${(entry.uplift * 100).toStringAsFixed(1)}% '
          'traitSynergy=${entry.traitSynergy.toStringAsFixed(2)}',
        )
        ..writeln();
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AiSkillFusionResult result,
    int durationMs,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'duration_ms': durationMs,
      'trait_count': result.traitCount,
      'average_fusion': result.averageFusion,
      'skills': result.entries
          .map(
            (entry) => {
              'stat': entry.stat,
              'fusion_index': entry.fusionIndex,
              'progress': entry.progress,
              'accuracy': entry.accuracy,
              'uplift': entry.uplift,
              'trait_synergy': entry.traitSynergy,
            },
          )
          .toList(),
    };
  }

  Future<void> _appendTelemetry(
    AiSkillFusionResult result,
    int durationMs,
  ) async {
    final payload = {
      'event': 'ai_skill_fusion_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'average_fusion': result.averageFusion,
      'trait_count': result.traitCount,
      'top_skills': result.entries
          .map(
            (entry) => {'stat': entry.stat, 'fusion_index': entry.fusionIndex},
          )
          .toList(),
      'duration_ms': durationMs,
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
