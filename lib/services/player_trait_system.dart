import 'dart:convert';
import 'dart:io';

const String _statsPath = 'release/_reports/player_stats_profile.json';
const String _traitsProfilePath = 'release/_reports/player_traits_profile.json';
const String _summaryPath = 'release/_reports/player_traits_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final system = PlayerTraitSystem();
  await system.run();
}

class PlayerTraitSystem {
  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final statsProfile = await _PlayerStatsProfile.load(_statsPath);
    final traits = _evaluateTraits(statsProfile.stats);

    await _withReportsWritable(() async {
      await _writeProfile(traits);
      await _writeSummary(traits, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(traits, stopwatch.elapsedMilliseconds);
    });

    stdout.writeln('player_trait_system: traits=${traits.length}');
  }

  List<_Trait> _evaluateTraits(Map<String, _PlayerStat> stats) {
    final traits = <_Trait>[];
    for (final definition in _traitDefinitions) {
      final trait = definition.evaluate(stats);
      if (trait != null) {
        traits.add(trait);
      }
    }
    if (traits.isEmpty) {
      traits.add(
        _Trait(
          name: 'Momentum Spark',
          description: 'Small XP boost when momentum builds.',
          rarity: 'Common',
          bonus: '+3% XP on any stat above 40% progress.',
          colorHex: '#00B894',
          temporary: true,
        ),
      );
    }
    return traits;
  }

  Future<void> _writeProfile(List<_Trait> traits) async {
    final payload = {
      'generated_at': DateTime.now().toIso8601String(),
      'traits': traits.map((trait) => trait.toJson()).toList(),
    };
    await File(
      _traitsProfilePath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }

  Future<void> _writeSummary(List<_Trait> traits, int durationMs) async {
    final buffer = StringBuffer()
      ..writeln('PLAYER TRAITS SUMMARY')
      ..writeln('=====================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Traits unlocked: ${traits.length}')
      ..writeln();
    for (final trait in traits) {
      buffer
        ..writeln('- ${trait.name} [${trait.rarity}]')
        ..writeln('  ${trait.description}')
        ..writeln('  Bonus: ${trait.bonus}')
        ..writeln('  State: ${trait.temporary ? 'Temporary' : 'Permanent'}')
        ..writeln();
    }

    await File(_summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry(List<_Trait> traits, int durationMs) async {
    final payload = <String, Object?>{
      'event': 'player_traits_updated',
      'timestamp': DateTime.now().toIso8601String(),
      'traits': traits.map((trait) => trait.toJson()).toList(),
      'duration_ms': durationMs,
    };

    await File(_telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _TraitDefinition {
  const _TraitDefinition({
    required this.name,
    required this.description,
    required this.rarity,
    required this.bonus,
    required this.colorHex,
    required this.evaluateCondition,
  });

  final String name;
  final String description;
  final String rarity;
  final String bonus;
  final String colorHex;
  final _Trait? Function(Map<String, _PlayerStat>) evaluateCondition;

  _Trait? evaluate(Map<String, _PlayerStat> stats) {
    final trait = evaluateCondition(stats);
    if (trait == null) return null;
    return trait.copyWith(
      name: name,
      description: description,
      rarity: rarity,
      bonus: bonus,
      colorHex: colorHex,
    );
  }
}

final List<_TraitDefinition> _traitDefinitions = <_TraitDefinition>[
  _TraitDefinition(
    name: 'ICM Surge',
    description: 'Synergy between preflop mastery and discipline.',
    rarity: 'Epic',
    bonus: '+8% XP on ICM & discipline drills',
    colorHex: '#9C27B0',
    evaluateCondition: (stats) {
      final preflop = stats['preflop_mastery'];
      final discipline = stats['discipline'];
      if (preflop == null || discipline == null) return null;
      final progressBoost = (preflop.progress + discipline.progress) / 2;
      if (preflop.level >= 8 && discipline.level >= 8 && progressBoost >= 0.5) {
        final temporary = progressBoost < 0.9;
        return _Trait(temporary: temporary);
      }
      return null;
    },
  ),
  _TraitDefinition(
    name: 'Balanced Mind',
    description: 'Multiple stats are simultaneously progressing.',
    rarity: 'Rare',
    bonus: '+5% XP across all balanced stats',
    colorHex: '#4CAF50',
    evaluateCondition: (stats) {
      final progressing = stats.values.where((stat) => stat.progress >= 0.6);
      if (progressing.length >= 2) {
        return const _Trait(temporary: true);
      }
      return null;
    },
  ),
  _TraitDefinition(
    name: 'Edge Awakening',
    description: 'A stat hit master tier and unlocked a permanent aura.',
    rarity: 'Legendary',
    bonus: '+10% XP on the highest mastery stat',
    colorHex: '#F5C542',
    evaluateCondition: (stats) {
      final best = stats.values.fold<_PlayerStat?>(
        null,
        (previous, current) =>
            (previous == null || current.level > previous.level)
            ? current
            : previous,
      );
      if (best != null && best.level >= 15) {
        return const _Trait(temporary: false);
      }
      return null;
    },
  ),
  _TraitDefinition(
    name: 'Tempo Flux',
    description: 'Fast playstyle detected, granting bonus streaks.',
    rarity: 'Rare',
    bonus: 'Chance to trigger double XP burst on quick clears',
    colorHex: '#03A9F4',
    evaluateCondition: (stats) {
      final avgProgress = stats.values.isEmpty
          ? 0
          : stats.values.map((stat) => stat.progress).reduce((a, b) => a + b) /
                stats.values.length;
      if (avgProgress >= 0.5) {
        return const _Trait(temporary: true);
      }
      return null;
    },
  ),
];

class _PlayerStatsProfile {
  const _PlayerStatsProfile(this.stats);

  static Future<_PlayerStatsProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Player stats profile missing at $path');
    }
    final raw = json.decode(await file.readAsString());
    if (raw is! Map<String, dynamic>) {
      throw StateError('Invalid stats profile format at $path');
    }
    final stats = raw.map(
      (key, value) => MapEntry(key, _PlayerStat.fromJson(value)),
    );
    return _PlayerStatsProfile(stats);
  }

  final Map<String, _PlayerStat> stats;
}

class _PlayerStat {
  const _PlayerStat({
    required this.level,
    required this.xp,
    required this.progress,
  });

  factory _PlayerStat.fromJson(Map<String, dynamic> json) => _PlayerStat(
    level: json['level'] as int? ?? 1,
    xp: (json['xp'] as num?)?.toDouble() ?? 0,
    progress: (json['progress_0_1'] as num?)?.toDouble() ?? 0,
  );

  final int level;
  final double xp;
  final double progress;
}

class _Trait {
  const _Trait({
    this.name = '',
    this.description = '',
    this.rarity = 'Common',
    this.bonus = '',
    this.colorHex = '#FFFFFF',
    required this.temporary,
  });

  final String name;
  final String description;
  final String rarity;
  final String bonus;
  final String colorHex;
  final bool temporary;

  _Trait copyWith({
    String? name,
    String? description,
    String? rarity,
    String? bonus,
    String? colorHex,
  }) => _Trait(
    name: name ?? this.name,
    description: description ?? this.description,
    rarity: rarity ?? this.rarity,
    bonus: bonus ?? this.bonus,
    colorHex: colorHex ?? this.colorHex,
    temporary: temporary,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'description': description,
    'rarity': rarity,
    'bonus': bonus,
    'color': colorHex,
    'temporary': temporary,
  };
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
