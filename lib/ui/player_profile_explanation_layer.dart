import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localization_core.dart';

import 'player_profile_explanation_layer_stub.dart'
    if (dart.library.ui) 'player_profile_explanation_layer_flutter.dart'
    as bridge;

const String _statsProfilePath = 'release/_reports/player_stats_profile.json';
const String _traitsProfilePath = 'release/_reports/player_traits_profile.json';
const String _summaryPath =
    'release/_reports/player_profile_explanation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const List<String> _requiredLocalizationKeys = [
  'player_profile_mastery_title',
  'player_profile_traits_section',
  'player_profile_rank_label',
  'player_profile_progress_label',
  'player_profile_level_label',
  'player_profile_xp_label',
  'player_profile_tutorial_title',
  'player_profile_tutorial_body',
  'player_profile_close',
];

Future<void> main(List<String> args) async {
  final generator = PlayerProfileExplanationCli();
  final ok = await generator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PlayerProfileExplanationCli {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final result = await PlayerProfileExplanationLayer.loadWithDiagnostics();
    final data = result.data;

    await _withReportsWritable(() async {
      await _writeSummary(result, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(result, stopwatch.elapsedMilliseconds);
    });

    final hasProfiles = data.stats.isNotEmpty || data.traits.isNotEmpty;
    final hasMissingProfiles = result.statsMissing || result.traitsMissing;
    final hasLocalizationIssues = result.missingLocalizationKeys.isNotEmpty;
    return hasProfiles && !hasMissingProfiles && !hasLocalizationIssues;
  }

  Future<void> _writeSummary(
    PlayerProfileExplanationLoadResult result,
    int durationMs,
  ) async {
    final data = result.data;
    final buffer = StringBuffer()
      ..writeln('PLAYER PROFILE EXPLANATION SUMMARY')
      ..writeln('==================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Stats with overlays: ${data.stats.length}')
      ..writeln('Traits with tooltips: ${data.traits.length}');

    if (result.statsMissing || result.traitsMissing) {
      buffer
        ..writeln()
        ..writeln('Profile warnings:');
      if (result.statsMissing) {
        buffer.writeln('-- Missing stats profile file: $_statsProfilePath');
      }
      if (result.traitsMissing) {
        buffer.writeln('-- Missing traits profile file: $_traitsProfilePath');
      }
    }

    if (result.missingLocalizationKeys.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Localization warnings:');
      result.missingLocalizationKeys.forEach((lang, keys) {
        buffer.writeln('-- $lang missing: ${keys.join(', ')}');
      });
    }

    buffer.writeln();

    if (data.stats.isEmpty) {
      buffer.writeln('No stat explanations available.');
    } else {
      buffer.writeln('Stat explanations:');
      for (final stat in data.stats) {
        buffer.writeln(
          '- ${stat.name}: level ${stat.level} | rank ${stat.rank} | XP ${stat.xp.toStringAsFixed(1)}',
        );
      }
      buffer.writeln();
    }

    if (data.traits.isEmpty) {
      buffer.writeln('No active traits.');
    } else {
      buffer.writeln('Trait explanations:');
      for (final trait in data.traits) {
        buffer.writeln(
          '- ${trait.name} (${trait.rarity}) → ${trait.description}',
        );
      }
    }

    await File(_summaryPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry(
    PlayerProfileExplanationLoadResult result,
    int durationMs,
  ) async {
    final data = result.data;
    final payload = <String, Object?>{
      'event': 'player_profile_explanation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stats': data.stats.length,
      'traits': data.traits.length,
      'duration_ms': durationMs,
      'stats_profile_missing': result.statsMissing,
      'traits_profile_missing': result.traitsMissing,
      'missing_localization_keys': result.missingLocalizationKeys,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class PlayerProfileExplanationLayer {
  static Future<void> showExplanationLayer(
    dynamic context,
    PlayerProfileExplanationData data,
  ) => bridge.showExplanationLayer(context, data);

  static Future<void> showTutorialOverlay(dynamic context) =>
      bridge.showTutorialOverlay(context);

  static Future<PlayerProfileExplanationData> loadData() async {
    final result = await loadWithDiagnostics();
    return result.data;
  }

  static Future<PlayerProfileExplanationLoadResult>
  loadWithDiagnostics() async {
    final statsResult = await _loadStats();
    final traitsResult = await _loadTraits();
    final missingLocalizationKeys = await _checkLocalizationKeys();
    return PlayerProfileExplanationLoadResult(
      data: PlayerProfileExplanationData(
        stats: statsResult.items,
        traits: traitsResult.items,
      ),
      statsMissing: statsResult.missingFile,
      traitsMissing: traitsResult.missingFile,
      missingLocalizationKeys: missingLocalizationKeys,
    );
  }

  static Future<_ProfileLoadResult<StatExplanation>> _loadStats() async {
    final file = File(_statsProfilePath);
    var missingFile = false;
    if (!await file.exists()) {
      return const _ProfileLoadResult(items: [], missingFile: true);
    }
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final stats =
            decoded.entries
                .map(
                  (entry) => StatExplanation.fromJson(entry.key, entry.value),
                )
                .toList()
              ..sort((a, b) => b.progress.compareTo(a.progress));
        return _ProfileLoadResult(items: stats, missingFile: false);
      }
    } catch (_) {
      missingFile = true;
    }
    return _ProfileLoadResult(items: const [], missingFile: missingFile);
  }

  static Future<_ProfileLoadResult<TraitExplanation>> _loadTraits() async {
    final file = File(_traitsProfilePath);
    var missingFile = false;
    if (!await file.exists()) {
      return const _ProfileLoadResult(items: [], missingFile: true);
    }
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final list = decoded['traits'];
        if (list is List) {
          final traits = list
              .whereType<Map>()
              .map((entry) => TraitExplanation.fromJson(entry))
              .toList();
          return _ProfileLoadResult(items: traits, missingFile: false);
        }
      }
    } catch (_) {
      missingFile = true;
    }
    return _ProfileLoadResult(items: const [], missingFile: missingFile);
  }

  static Future<Map<String, List<String>>> _checkLocalizationKeys() async {
    final localization = LocalizationCore.instance;
    await localization.load();
    final languages = localization.languages;
    final issues = <String, List<String>>{};
    for (final lang in languages) {
      final missing = <String>[];
      for (final key in _requiredLocalizationKeys) {
        if (!localization.hasKey(lang, key)) {
          missing.add(key);
        }
      }
      if (missing.isNotEmpty) {
        issues[lang] = missing;
      }
    }
    return issues;
  }
}

class PlayerProfileExplanationData {
  const PlayerProfileExplanationData({
    required this.stats,
    required this.traits,
  });

  final List<StatExplanation> stats;
  final List<TraitExplanation> traits;
}

class PlayerProfileExplanationLoadResult {
  const PlayerProfileExplanationLoadResult({
    required this.data,
    required this.statsMissing,
    required this.traitsMissing,
    required this.missingLocalizationKeys,
  });

  final PlayerProfileExplanationData data;
  final bool statsMissing;
  final bool traitsMissing;
  final Map<String, List<String>> missingLocalizationKeys;
}

class _ProfileLoadResult<T> {
  const _ProfileLoadResult({required this.items, required this.missingFile});

  final List<T> items;
  final bool missingFile;
}

class StatExplanation {
  StatExplanation({
    required this.id,
    required this.name,
    required this.level,
    required this.rank,
    required this.progress,
    required this.xp,
  });

  final String id;
  final String name;
  final int level;
  final String rank;
  final double progress;
  final double xp;

  factory StatExplanation.fromJson(String id, Object? value) {
    final map = value is Map ? value.cast<String, Object?>() : const {};
    return StatExplanation(
      id: id,
      name: _humanize(id),
      level: (map['level'] as num?)?.toInt() ?? 0,
      rank: map['rank']?.toString() ?? 'Unranked',
      progress: (map['progress_0_1'] as num?)?.toDouble() ?? 0,
      xp: (map['xp'] as num?)?.toDouble() ?? 0,
    );
  }

  static String _humanize(String value) {
    final parts = value.split(RegExp(r'[_-]+'));
    return parts
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}

class TraitExplanation {
  TraitExplanation({
    required this.name,
    required this.rarity,
    required this.description,
    required this.bonus,
  });

  final String name;
  final String rarity;
  final String description;
  final String bonus;

  factory TraitExplanation.fromJson(Map entry) {
    final map = entry.cast<String, Object?>();
    return TraitExplanation(
      name: map['name']?.toString() ?? 'Unknown',
      rarity: map['rarity']?.toString() ?? 'Common',
      description: map['description']?.toString() ?? '',
      bonus: map['bonus']?.toString() ?? '',
    );
  }
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
