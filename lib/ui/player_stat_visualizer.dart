import 'dart:convert';
import 'dart:io';

import 'player_stat_visualizer_models.dart';
import 'player_stat_visualizer_stub.dart'
    if (dart.library.ui) 'player_stat_visualizer_flutter.dart'
    as bridge;

const String _statsPath = 'release/_reports/player_stats_profile.json';
const String _summaryPath =
    'release/_reports/player_stat_visualizer_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

class PlayerStatVisualizer {
  static Future<void> showStatGain(dynamic context, StatGainEvent event) =>
      bridge.showStatGain(context, event);

  static Future<void> generateSummary() async {
    final stopwatch = Stopwatch()..start();
    final stats = await _loadStats();

    await _withReportsWritable(() async {
      await _writeSummary(stats, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(stats, stopwatch.elapsedMilliseconds);
    });
  }

  static Future<Map<String, dynamic>> _loadStats() async {
    final file = File(_statsPath);
    if (!await file.exists()) return const {};
    try {
      final raw = json.decode(await file.readAsString());
      if (raw is Map<String, dynamic>) return raw;
    } catch (_) {
      // ignore malformed profile
    }
    return const {};
  }

  static Future<void> _writeSummary(
    Map<String, dynamic> stats,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('PLAYER STAT VISUALIZER SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln();
    if (stats.isEmpty) {
      buffer.writeln('No player stats profile found.');
    } else {
      buffer.writeln('Available stat cues:');
      stats.forEach((name, value) {
        final level = (value as Map?)?['level'] ?? '?';
        buffer.writeln('- $name (level $level)');
      });
    }
    buffer.writeln();

    await File(_summaryPath).writeAsString('${buffer.toString()}');
  }

  static Future<void> _emitTelemetry(
    Map<String, dynamic> stats,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_stat_visualizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stats_available': stats.keys.toList(),
      'duration_ms': durationMs,
    };

    await File(_telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

Future<void> main(List<String> args) async {
  await PlayerStatVisualizer.generateSummary();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
