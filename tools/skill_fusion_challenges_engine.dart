import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/skill_fusion_challenges_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/skill_fusion_challenges_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/skill_fusion_challenges_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _minCoverage = 0.7;
const double _minAverageEv = 1.09;

Future<void> main(List<String> args) async {
  final engine = SkillFusionChallengesEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SkillFusionChallengesEngine {
  final SkillFusionChallengesService _service = SkillFusionChallengesService();

  Future<bool> run() async {
    final result = await _service.generateChallenges();
    final pass =
        result.coverageRatio >= _minCoverage &&
        result.averageEv >= _minAverageEv;

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
        'Skill fusion challenges failed: coverage '
        '${(result.coverageRatio * 100).toStringAsFixed(2)}%, '
        'average EV ${result.averageEv.toStringAsFixed(4)}',
      );
    }

    return pass;
  }

  String _buildTextSummary(SkillFusionResult result, bool pass) {
    final buffer = StringBuffer()
      ..writeln('SKILL FUSION CHALLENGES SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Cluster coverage: ${(result.coverageRatio * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Average EV uplift: ${result.averageEv.toStringAsFixed(4)}')
      ..writeln(
        'Thresholds: coverage >= ${(_minCoverage * 100).toStringAsFixed(0)}%, '
        'EV >= ${_minAverageEv.toStringAsFixed(2)}',
      )
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    if (result.challenges.isEmpty) {
      buffer.writeln('No fusion challenges generated.');
    } else {
      buffer.writeln('Top challenges:');
      for (final challenge in result.challenges.take(20)) {
        buffer.writeln(
          '  - ${challenge.localizedTitle} | skills=${challenge.skills.join(', ')} '
          '| EV=${challenge.evScore.toStringAsFixed(4)} '
          '| difficulty=${challenge.difficultyMix.toStringAsFixed(2)}',
        );
      }
      if (result.challenges.length > 20) {
        buffer.writeln('  ... +${result.challenges.length - 20} more');
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(SkillFusionResult result, bool pass) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'coverage_ratio': result.coverageRatio,
      'average_ev': result.averageEv,
      'challenges': result.challenges
          .map(
            (challenge) => {
              'title': challenge.localizedTitle,
              'skills': challenge.skills,
              'ev_score': challenge.evScore,
              'difficulty_mix': challenge.difficultyMix,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(SkillFusionResult result, bool pass) async {
    final payload = <String, Object?>{
      'event': 'skill_fusion_challenges_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'coverage_ratio': result.coverageRatio,
      'average_ev': result.averageEv,
      'challenge_count': result.challenges.length,
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
