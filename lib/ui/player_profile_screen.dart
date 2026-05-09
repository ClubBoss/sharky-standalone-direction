import 'dart:convert';
import 'dart:io';

import 'player_profile_models.dart';
import 'player_profile_screen_stub.dart'
    if (dart.library.ui) 'player_profile_screen_flutter.dart'
    as bridge;

const String _statsPath = 'release/_reports/player_stats_profile.json';
const String _traitsPath = 'release/_reports/player_traits_profile.json';
const String _summaryPath = 'release/_reports/player_profile_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

class PlayerProfileScreen {
  static Future<PlayerProfileData> loadProfile() async {
    final stats = await _loadStats();
    final traits = await _loadTraits();
    return PlayerProfileData(
      stats: stats,
      traits: traits,
      generatedAt: DateTime.now().toIso8601String(),
      showTutorial: stats.isNotEmpty,
    );
  }

  static Future<void> generateSummary() async {
    final stopwatch = Stopwatch()..start();
    final stats = await _loadStats();
    final traits = await _loadTraits();

    await _withReportsWritable(() async {
      await _writeSummary(
        stats: stats,
        traits: traits,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        stats: stats,
        traits: traits,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });
  }

  static dynamic buildScreen(PlayerProfileData data) =>
      bridge.buildPlayerProfileScreen(data);

  static Future<void> showTutorial(dynamic context, PlayerProfileData data) =>
      bridge.showPlayerProfileTutorial(context, data);

  static Future<List<PlayerStatProfile>> _loadStats() async {
    final file = File(_statsPath);
    if (!await file.exists()) return const [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded.entries.map((entry) {
          final map = entry.value as Map<String, dynamic>? ?? const {};
          return PlayerStatProfile(
            id: entry.key,
            displayName: _humanize(entry.key),
            level: (map['level'] as num?)?.toInt() ?? 0,
            xp: (map['xp'] as num?)?.toDouble() ?? 0,
            progress: (map['progress_0_1'] as num?)?.toDouble() ?? 0,
            rank: map['rank']?.toString() ?? 'Unranked',
          );
        }).toList()..sort((a, b) => b.progress.compareTo(a.progress));
      }
    } catch (_) {
      // ignore malformed stats
    }
    return const [];
  }

  static Future<List<PlayerTraitProfile>> _loadTraits() async {
    final file = File(_traitsPath);
    if (!await file.exists()) return const [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final traits = decoded['traits'];
        if (traits is List) {
          return traits.whereType<Map>().map((raw) {
            final map = raw.cast<String, Object?>();
            return PlayerTraitProfile(
              name: map['name']?.toString() ?? 'Unknown',
              description: map['description']?.toString() ?? '',
              rarity: map['rarity']?.toString() ?? 'Common',
              bonus: map['bonus']?.toString() ?? '',
              color: map['color']?.toString() ?? '#FFFFFF',
              temporary: map['temporary'] == true,
            );
          }).toList();
        }
      }
    } catch (_) {
      // ignore malformed traits
    }
    return const [];
  }
}

Future<void> main(List<String> args) async {
  await PlayerProfileScreen.generateSummary();
}

Future<void> _writeSummary({
  required List<PlayerStatProfile> stats,
  required List<PlayerTraitProfile> traits,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE SUMMARY')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Stats tracked: ${stats.length}')
    ..writeln('Traits active: ${traits.length}')
    ..writeln();

  if (stats.isEmpty) {
    buffer.writeln('No player_stats_profile.json available.');
  } else {
    buffer.writeln('Top mastery bars:');
    for (final stat in stats.take(5)) {
      buffer.writeln(
        '- ${stat.displayName}: '
        'level ${stat.level} (${(stat.progress * 100).toStringAsFixed(1)}%) '
        'rank ${stat.rank}',
      );
    }
    buffer.writeln();
  }

  if (traits.isEmpty) {
    buffer.writeln('No player traits found.');
  } else {
    buffer.writeln('Active traits:');
    for (final trait in traits) {
      buffer.writeln('- ${trait.name} (${trait.rarity}) → ${trait.bonus}');
    }
    buffer.writeln();
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required List<PlayerStatProfile> stats,
  required List<PlayerTraitProfile> traits,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'player_profile_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'stat_count': stats.length,
    'trait_count': traits.length,
    'top_stats': stats.take(3).map((s) => s.id).toList(),
    'duration_ms': durationMs,
  };

  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

String _humanize(String value) {
  final words = value.split(RegExp(r'[_\-]+'));
  return words
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
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
