import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/profile_persistence_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/profile_persistence_summary.txt';
const String _summaryJsonPath = '$_reportsDir/profile_persistence_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _profileId = 'default';

Future<void> main(List<String> args) async {
  final dashboard = ProfilePersistenceDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ProfilePersistenceDashboard {
  final ProfilePersistenceService _service = ProfilePersistenceService();

  Future<bool> run() async {
    final saved = await _service.saveProfile(_profileId);
    final loaded = await _service.loadProfile(_profileId);
    final verified = await _service.verifyIntegrity(_profileId);
    await _service.syncWithRemote(_profileId);

    if (saved == null || loaded == null || !verified) {
      stderr.writeln(
        'Profile persistence verification failed (save or load missing).',
      );
      return false;
    }

    final summaryText = _buildTextSummary(saved, verified);
    final summaryJson = _buildJsonSummary(saved, verified);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(saved, verified);
    });

    return true;
  }

  String _buildTextSummary(PlayerProfileSnapshot snapshot, bool verified) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PROFILE PERSISTENCE SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Profile ID: ${snapshot.id}')
      ..writeln('Saved at: ${snapshot.savedAt}')
      ..writeln('XP total: ${snapshot.xpTotal.toStringAsFixed(2)}')
      ..writeln('Mastery count: ${snapshot.mastery.length}')
      ..writeln('Trait count: ${snapshot.traits.length}')
      ..writeln('UX resonance: ${pct(snapshot.uxResonance)}')
      ..writeln('Verification: ${verified ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    PlayerProfileSnapshot snapshot,
    bool verified,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'profile_id': snapshot.id,
      'saved_at': snapshot.savedAt,
      'xp_total': snapshot.xpTotal,
      'mastery_count': snapshot.mastery.length,
      'trait_count': snapshot.traits.length,
      'ux_resonance': snapshot.uxResonance,
      'verified': verified,
    };
  }

  Future<void> _appendTelemetry(
    PlayerProfileSnapshot snapshot,
    bool verified,
  ) async {
    final payload = <String, Object?>{
      'event': 'profile_persistence_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'profile_id': snapshot.id,
      'xp_total': snapshot.xpTotal,
      'mastery_count': snapshot.mastery.length,
      'trait_count': snapshot.traits.length,
      'ux_resonance': snapshot.uxResonance,
      'verified': verified,
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
