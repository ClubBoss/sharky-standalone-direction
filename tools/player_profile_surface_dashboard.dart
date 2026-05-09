import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_surface_engine.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/player_profile_surface_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/player_profile_surface_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = PlayerProfileSurfaceDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PlayerProfileSurfaceDashboard {
  final PlayerProfileSurfaceEngine _engine = const PlayerProfileSurfaceEngine();

  Future<bool> run() async {
    final result = await _engine.evaluate();
    if (result == null) {
      stderr.writeln('Player profile surface inputs missing.');
      return false;
    }

    final index =
        ((result.profileConsistency * 0.4) +
                (result.uxResonance * 0.35) +
                (result.masteryCoherence * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      result.profileConsistency,
      result.uxResonance,
      result.masteryCoherence,
      index,
      pass,
    );
    final json = _buildJson(
      result.profileConsistency,
      result.uxResonance,
      result.masteryCoherence,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        result.profileConsistency,
        result.uxResonance,
        result.masteryCoherence,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Player Profile Surfacing Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  String _buildText(
    double profile,
    double ux,
    double mastery,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PLAYER PROFILE SURFACE SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Profile consistency: ${pct(profile)}')
      ..writeln('UX resonance: ${pct(ux)}')
      ..writeln('Mastery coherence: ${pct(mastery)}')
      ..writeln('Surfacing Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double profile,
    double ux,
    double mastery,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'profile_consistency': profile,
    'ux_resonance': ux,
    'mastery_coherence': mastery,
    'player_profile_surface_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double profile,
    double ux,
    double mastery,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_profile_surface_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'profile_consistency': profile,
      'ux_resonance': ux,
      'mastery_coherence': mastery,
      'player_profile_surface_index': index,
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
