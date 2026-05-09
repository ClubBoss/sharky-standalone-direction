import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_integration_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/player_profile_integration_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/player_profile_integration_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final dashboard = PlayerProfileIntegrationDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PlayerProfileIntegrationDashboard {
  PlayerProfileIntegrationDashboard({PlayerProfileIntegrationService? service})
    : _service = service ?? PlayerProfileIntegrationService();

  final PlayerProfileIntegrationService _service;

  Future<bool> run() async {
    final result = await _service.computeIntegration();
    if (result == null) {
      stderr.writeln(
        'Missing player profile inputs (surface/mastery/traits/UX resonance).',
      );
      return false;
    }

    final pass = result.integrationIndex >= _threshold;
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
        'Player Profile Integration Index '
        '${result.integrationIndex.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  String _buildTextSummary(PlayerProfileIntegrationResult result, bool pass) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PLAYER PROFILE INTEGRATION SUMMARY')
      ..writeln('==================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Mastery consistency: ${pct(result.masteryConsistency)} '
        '(${result.masterySamples} samples)',
      )
      ..writeln(
        'Trait alignment: ${pct(result.traitAlignment)} '
        '(${result.traitCount} traits)',
      )
      ..writeln('UX resonance: ${pct(result.uxResonance)}')
      ..writeln('Profile stats tracked: ${result.surfaceStatsTracked}')
      ..writeln('Profile traits active: ${result.surfaceTraitsActive}')
      ..writeln(
        'Player Profile Integration Index: '
        '${pct(result.integrationIndex)}',
      )
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    PlayerProfileIntegrationResult result,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'mastery_consistency': result.masteryConsistency,
      'mastery_samples': result.masterySamples,
      'trait_alignment': result.traitAlignment,
      'trait_count': result.traitCount,
      'ux_resonance': result.uxResonance,
      'profile_stats_tracked': result.surfaceStatsTracked,
      'profile_traits_active': result.surfaceTraitsActive,
      'player_profile_integration_index': result.integrationIndex,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    PlayerProfileIntegrationResult result,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_profile_integration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'mastery_consistency': result.masteryConsistency,
      'trait_alignment': result.traitAlignment,
      'ux_resonance': result.uxResonance,
      'player_profile_integration_index': result.integrationIndex,
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
