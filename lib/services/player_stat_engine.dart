import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _profilePath = 'release/_reports/personalization_profile.json';
const String _statsPath = 'release/_reports/player_stats_profile.json';
const String _summaryPath = 'release/_reports/player_stats_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _skillSummaryPath =
    'release/_reports/skill_progression_summary.txt';
const String _telemetryOut = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final engine = PlayerStatEngine();
  await engine.run();
}

class PlayerStatEngine {
  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final profile = await _PersonalizationProfile.load(_profilePath);
    final existingStats = await _PlayerStatsProfile.load(_statsPath);
    final topicMetrics = Map<String, _TopicMetrics>.from(
      await _collectTopicMetrics(),
    );
    if (topicMetrics.isEmpty) {
      profile.topicBias.forEach((topic, weight) {
        topicMetrics[topic] = _TopicMetrics(
          accuracy: profile.accuracy * weight.clamp(0.5, 1.0),
          speedMs: 4000,
          sessions: 1,
        );
      });
    }
    final skillEta = await _loadSkillEta();

    final updates = <String, _StatUpdate>{};
    for (final entry in _baseStats.entries) {
      final topic = entry.key;
      final statName = entry.value;
      final metrics = topicMetrics[topic] ?? _TopicMetrics.zero();
      final current = existingStats.stats[statName];
      final updated = _updateStat(statName, metrics, current, skillEta[topic]);
      updates[statName] = updated;
    }

    final updatedProfile = existingStats.copyWith(updates);

    await _withReportsWritable(() async {
      await updatedProfile.save(_statsPath);
      await _writeSummary(updatedProfile, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(updatedProfile, stopwatch.elapsedMilliseconds);
    });

    stdout.writeln('player_stat_engine: stats=${updates.length}');
  }

  Future<Map<String, _TopicMetrics>> _collectTopicMetrics() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return const {};
    final metrics = <String, _TopicMetricsBuilder>{};
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      dynamic payload;
      try {
        payload = json.decode(line);
      } catch (_) {
        continue;
      }
      if (payload is! Map<String, dynamic>) continue;
      final topic = payload['topic']?.toString();
      if (topic == null) continue;
      final accuracy = _toDouble(payload['accuracy']);
      final speed = _toDouble(payload['speed_ms']);
      if (accuracy == null && speed == null) continue;
      final builder = metrics.putIfAbsent(
        topic,
        () => _TopicMetricsBuilder(topic),
      );
      if (accuracy != null) builder.addAccuracy(accuracy);
      if (speed != null) builder.addSpeed(speed);
    }
    return metrics.map((key, value) => MapEntry(key, value.build()));
  }

  Future<Map<String, double>> _loadSkillEta() async {
    final file = File(_skillSummaryPath);
    if (!await file.exists()) return const {};
    final eta = <String, double>{};
    final lines = await file.readAsLines();
    for (final line in lines) {
      final match = RegExp(r'- (\w+):.*eta=([0-9.]+|∞)').firstMatch(line);
      if (match != null) {
        final topic = match.group(1)!.toLowerCase();
        final etaValue = match.group(2)!;
        if (etaValue == '∞') continue;
        eta[topic] = double.tryParse(etaValue) ?? double.infinity;
      }
    }
    return eta;
  }

  _StatUpdate _updateStat(
    String statName,
    _TopicMetrics metrics,
    _PlayerStat? current,
    double? eta,
  ) {
    final normalizedAccuracy = metrics.accuracy ?? 0.7;
    final speedFactor = metrics.speedMs == null
        ? 1.0
        : (4000 / max(1000, metrics.speedMs!)).clamp(0.5, 1.5);
    final sessionBonus = metrics.sessions.toDouble();
    final etaBoost = eta == null || eta.isInfinite ? 1.0 : (1 / (eta + 1));

    final xpDelta =
        ((normalizedAccuracy * 100) * 0.5) +
        (speedFactor * 10) +
        sessionBonus * 2 +
        etaBoost * 20;

    final previousXp = current?.xp ?? 0;
    final newXp = previousXp + xpDelta;
    final level = (newXp / 150).floor() + 1;
    final progress = ((newXp % 150) / 150).clamp(0.0, 1.0);
    final rank = _rankFor(level);

    return _StatUpdate(
      stat: statName,
      xp: newXp,
      level: level,
      progress: progress,
      rank: rank,
    );
  }

  Future<void> _writeSummary(
    _PlayerStatsProfile profile,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('PLAYER STATS SUMMARY')
      ..writeln('====================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln()
      ..writeln('Stats:');
    for (final entry in profile.stats.entries) {
      buffer.writeln(
        '- ${entry.key}: lvl ${entry.value.level} '
        'xp ${entry.value.xp.toStringAsFixed(1)} '
        'progress ${(entry.value.progress * 100).toStringAsFixed(1)}% '
        'rank ${entry.value.rank}',
      );
    }
    buffer.writeln();

    await File(_summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry(
    _PlayerStatsProfile profile,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_stats_updated',
      'timestamp': DateTime.now().toIso8601String(),
      'stats': profile.stats.map((key, value) => MapEntry(key, value.toJson())),
      'duration_ms': durationMs,
    };
    await File(_telemetryOut).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _PlayerStatsProfile {
  const _PlayerStatsProfile(this.stats);

  factory _PlayerStatsProfile.empty() => const _PlayerStatsProfile({});

  static Future<_PlayerStatsProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) return _PlayerStatsProfile.empty();
    try {
      final raw = json.decode(await file.readAsString());
      if (raw is! Map<String, dynamic>) return _PlayerStatsProfile.empty();
      final stats = raw.map(
        (key, value) => MapEntry(key, _PlayerStat.fromJson(value)),
      );
      return _PlayerStatsProfile(stats);
    } catch (_) {
      return _PlayerStatsProfile.empty();
    }
  }

  final Map<String, _PlayerStat> stats;

  _PlayerStatsProfile copyWith(Map<String, _StatUpdate> updates) {
    final updated = Map<String, _PlayerStat>.from(stats);
    for (final entry in updates.entries) {
      updated[entry.key] = entry.value.toStat();
    }
    return _PlayerStatsProfile(updated);
  }

  Future<void> save(String path) async {
    final file = File(path);
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(stats.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }
}

class _PlayerStat {
  const _PlayerStat({
    required this.level,
    required this.xp,
    required this.progress,
    required this.rank,
  });

  factory _PlayerStat.fromJson(Map<String, dynamic> json) => _PlayerStat(
    level: json['level'] as int? ?? 1,
    xp: (json['xp'] as num?)?.toDouble() ?? 0,
    progress: (json['progress_0_1'] as num?)?.toDouble() ?? 0,
    rank: json['rank']?.toString() ?? 'Novice',
  );

  final int level;
  final double xp;
  final double progress;
  final String rank;

  Map<String, Object?> toJson() => {
    'level': level,
    'xp': double.parse(xp.toStringAsFixed(2)),
    'progress_0_1': double.parse(progress.toStringAsFixed(3)),
    'rank': rank,
  };
}

class _StatUpdate {
  const _StatUpdate({
    required this.stat,
    required this.level,
    required this.xp,
    required this.progress,
    required this.rank,
  });

  final String stat;
  final int level;
  final double xp;
  final double progress;
  final String rank;

  _PlayerStat toStat() =>
      _PlayerStat(level: level, xp: xp, progress: progress, rank: rank);
}

class _PersonalizationProfile {
  const _PersonalizationProfile({
    required this.accuracy,
    required this.topicBias,
  });

  static Future<_PersonalizationProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _PersonalizationProfile(accuracy: 0.7, topicBias: {});
    }
    try {
      final raw = json.decode(await file.readAsString());
      if (raw is! Map<String, dynamic>) {
        return const _PersonalizationProfile(accuracy: 0.7, topicBias: {});
      }
      final fingerprint =
          raw['fingerprint'] as Map<String, dynamic>? ?? const {};
      final topicBias =
          fingerprint['topic_bias'] as Map<String, dynamic>? ?? const {};
      return _PersonalizationProfile(
        accuracy: (fingerprint['accuracy'] as num?)?.toDouble() ?? 0.7,
        topicBias: topicBias.map(
          (key, value) =>
              MapEntry(key.toString(), (value as num?)?.toDouble() ?? 0),
        ),
      );
    } catch (_) {
      return const _PersonalizationProfile(accuracy: 0.7, topicBias: {});
    }
  }

  final double accuracy;
  final Map<String, double> topicBias;
}

class _TopicMetrics {
  const _TopicMetrics({
    required this.accuracy,
    required this.speedMs,
    required this.sessions,
  });

  factory _TopicMetrics.zero() =>
      const _TopicMetrics(accuracy: null, speedMs: null, sessions: 0);

  final double? accuracy;
  final double? speedMs;
  final int sessions;
}

class _TopicMetricsBuilder {
  _TopicMetricsBuilder(this.topic);

  final String topic;
  final List<double> _accuracy = <double>[];
  final List<double> _speed = <double>[];

  void addAccuracy(double value) => _accuracy.add(value);

  void addSpeed(double value) => _speed.add(value);

  _TopicMetrics build() {
    final accuracy = _accuracy.isEmpty
        ? null
        : _accuracy.reduce((a, b) => a + b) / _accuracy.length;
    final speed = _speed.isEmpty
        ? null
        : _speed.reduce((a, b) => a + b) / _speed.length;
    return _TopicMetrics(
      accuracy: accuracy,
      speedMs: speed,
      sessions: _accuracy.length,
    );
  }
}

String _rankFor(int level) {
  if (level >= 20) return 'Legend';
  if (level >= 15) return 'Strategist';
  if (level >= 10) return 'ICM Adept';
  if (level >= 6) return 'Preflop Grinder';
  if (level >= 3) return 'Rising Talent';
  return 'Novice';
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

const Map<String, String> _baseStats = <String, String>{
  'preflop': 'preflop_mastery',
  '3bet': 'three_bet_mastery',
  'bluff': 'bluff_control',
  'discipline': 'discipline',
};

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
