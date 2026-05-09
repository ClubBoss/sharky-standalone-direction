import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_xp_reward_engine.dart';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/adaptive_xp_reward_summary.txt';
const String _summaryJsonPath = '$_reportsDir/adaptive_xp_reward_summary.json';

const double _threshold = 1.0;

Future<void> main(List<String> args) async {
  final dashboard = AdaptiveXpRewardDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveXpRewardDashboard {
  Future<bool> run() async {
    final retention = await _readRetentionScore();
    final economy = await _readEconomyScore();
    final reaction = await _readReactionScore();

    if (retention == null || economy == null || reaction == null) {
      stderr.writeln('Missing retention, economy, or reaction metrics.');
      return false;
    }

    final engine = AdaptiveXpRewardEngine(baseMultiplier: 1.0);
    final multiplier = engine.computeMultiplier(
      retentionScore: retention,
      reactionScore: reaction,
      economyScore: economy,
    );
    final verdict = multiplier >= _threshold ? 'PASS' : 'FAIL';

    final summaryText = _buildText(
      retention: retention,
      economy: economy,
      reaction: reaction,
      multiplier: multiplier,
      verdict: verdict,
    );
    final summaryJson = _buildJson(
      retention: retention,
      economy: economy,
      reaction: reaction,
      multiplier: multiplier,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(retention, economy, reaction, multiplier, verdict);
    });

    if (verdict == 'FAIL') {
      stderr.writeln(
        'Adaptive XP multiplier ${multiplier.toStringAsFixed(3)} < 1.0.',
      );
    }
    return verdict == 'PASS';
  }

  Future<double?> _readRetentionScore() async {
    final file = File('$_reportsDir/retention_marketing_loop_v2_summary.json');
    if (!await file.exists()) return null;
    final data = json.decode(await file.readAsString());
    if (data is Map<String, Object?>) {
      return _asDouble(data['retention_score']);
    }
    return null;
  }

  Future<double?> _readEconomyScore() async {
    final file = File('$_reportsDir/engagement_economy_summary.json');
    if (!await file.exists()) return null;
    final data = json.decode(await file.readAsString());
    if (data is Map<String, Object?>) {
      return _asDouble(data['engagement_economy_score']);
    }
    return null;
  }

  Future<double?> _readReactionScore() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    final lines = await file.readAsLines();
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final payload = json.decode(line) as Map<String, Object?>;
        if (payload['event'] == 'persona_reactions_completed') {
          final celebrate = _asDouble(payload['celebrate_count']) ?? 0.0;
          final encourage = _asDouble(payload['encourage_count']) ?? 0.0;
          final thinking = _asDouble(payload['thinking_count']) ?? 0.0;
          final total = celebrate + encourage + thinking;
          if (total == 0) return 0.0;
          final score = (celebrate + (encourage * 0.5)) / total;
          return score.clamp(0.0, 1.0);
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  String _buildText({
    required double retention,
    required double economy,
    required double reaction,
    required double multiplier,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE XP REWARD SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Retention contribution: ${(retention * 100).toStringAsFixed(2)}%',
      )
      ..writeln(
        'Monetization/economy contribution: ${(economy * 100).toStringAsFixed(2)}%',
      )
      ..writeln(
        'Reaction contribution: ${(reaction * 100).toStringAsFixed(2)}%',
      )
      ..writeln('XP multiplier: ${multiplier.toStringAsFixed(4)}x')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson({
    required double retention,
    required double economy,
    required double reaction,
    required double multiplier,
    required String verdict,
  }) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_score': retention,
    'economy_score': economy,
    'reaction_score': reaction,
    'xp_multiplier': multiplier,
    'threshold': _threshold,
    'verdict': verdict,
  };

  Future<void> _appendTelemetry(
    double retention,
    double economy,
    double reaction,
    double multiplier,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_xp_reward_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_score': retention,
      'economy_score': economy,
      'reaction_score': reaction,
      'xp_multiplier': multiplier,
      'verdict': verdict,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
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
