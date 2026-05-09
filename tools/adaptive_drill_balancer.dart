import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const String _profilePath = 'release/_reports/personalization_profile.json';
const String _contentRoot = 'content';
const String _previewRoot = 'content_adaptive_preview';
const String _summaryPath =
    'release/_reports/adaptive_drill_balance_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const double _adjustRatio = 0.075; // target ~7.5%

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final profile = await PersonalizationProfile.load(_profilePath);
  final promote = profile.shouldPromote();
  final demote = profile.shouldDemote();

  if (!promote && !demote) {
    stdout.writeln(
      'adaptive_drill_balancer: profile within target band; no changes applied.',
    );
    await _withReportsWritable(() async {
      await _writeSummary(
        durationMs: stopwatch.elapsedMilliseconds,
        profile: profile,
        results: const [],
        verdict: 'PASS',
      );
      await _appendTelemetry(
        durationMs: stopwatch.elapsedMilliseconds,
        modules: 0,
        promotions: 0,
        demotions: 0,
        verdict: 'PASS',
      );
    });
    return;
  }

  final files = await _discoverDrillFiles();
  final results = <_BalanceResult>[];

  for (final file in files) {
    final result = await _rebalanceFile(file, promote: promote, demote: demote);
    if (result != null) {
      results.add(result);
    }
  }

  final totalPromotions = results.fold<int>(0, (sum, r) => sum + r.promotions);
  final totalDemotions = results.fold<int>(0, (sum, r) => sum + r.demotions);

  final verdict = results.isEmpty
      ? 'WARN'
      : (demote && totalDemotions == 0 || promote && totalPromotions == 0)
      ? 'WARN'
      : 'PASS';

  await _withReportsWritable(() async {
    await _writeSummary(
      durationMs: stopwatch.elapsedMilliseconds,
      profile: profile,
      results: results,
      verdict: verdict,
    );
    await _appendTelemetry(
      durationMs: stopwatch.elapsedMilliseconds,
      modules: results.length,
      promotions: totalPromotions,
      demotions: totalDemotions,
      verdict: verdict,
    );
  });

  stdout.writeln(
    'adaptive_drill_balancer: modules=${results.length} '
    'promotions=$totalPromotions demotions=$totalDemotions verdict=$verdict',
  );
}

Future<List<String>> _discoverDrillFiles() async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];

  final files = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.jsonl')) continue;
    final name = p.basename(entity.path);
    if (name == 'drills.jsonl' || name == 'demos.jsonl') {
      files.add(entity.path);
    }
  }
  return files;
}

Future<_BalanceResult?> _rebalanceFile(
  String sourcePath, {
  required bool promote,
  required bool demote,
}) async {
  final lines = await File(sourcePath).readAsLines();
  if (lines.isEmpty) return null;

  final drills = <_Drill>[];
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic jsonLine;
    try {
      jsonLine = json.decode(line);
    } catch (_) {
      continue;
    }
    if (jsonLine is Map<String, dynamic>) {
      drills.add(_Drill(jsonLine));
    }
  }
  if (drills.isEmpty) return null;

  var promotions = 0;
  var demotions = 0;

  if (promote) {
    final medium = drills
        .where((drill) => drill.difficulty == 'medium')
        .toList();
    final promoteCount = _targetCount(medium.length);
    for (var i = 0; i < promoteCount && i < medium.length; i++) {
      medium[i].updateDifficulty('high');
      promotions++;
    }
  }

  if (demote) {
    final high = drills.where((drill) => drill.difficulty == 'high').toList();
    final demoteCount = _targetCount(high.length);
    for (var i = 0; i < demoteCount && i < high.length; i++) {
      high[i].updateDifficulty('medium');
      demotions++;
    }
  }

  final relative = p
      .relative(sourcePath, from: _contentRoot)
      .replaceAll('\\', '/');
  final previewPath = p.join(_previewRoot, relative);
  await Directory(p.dirname(previewPath)).create(recursive: true);

  final sink = File(previewPath).openWrite();
  for (final drill in drills) {
    sink.writeln(jsonEncode(drill.data));
  }
  await sink.close();

  return _BalanceResult(
    relativePath: relative,
    total: drills.length,
    promotions: promotions,
    demotions: demotions,
  );
}

int _targetCount(int population) {
  if (population == 0) return 0;
  final count = (population * _adjustRatio).round();
  if (count <= 0) return 1;
  if (count > population) return population;
  return count;
}

Future<void> _writeSummary({
  required int durationMs,
  required PersonalizationProfile profile,
  required List<_BalanceResult> results,
  required String verdict,
}) async {
  final totalFiles = results.length;
  final promotions = results.fold<int>(0, (sum, r) => sum + r.promotions);
  final demotions = results.fold<int>(0, (sum, r) => sum + r.demotions);
  final index = totalFiles == 0
      ? 0.0
      : promotions + demotions > 0
      ? 1.0
      : 0.5;

  final buffer = StringBuffer()
    ..writeln('ADAPTIVE DRILL BALANCE SUMMARY')
    ..writeln('==============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Profile → accuracy: ${profile.accuracy.toStringAsFixed(2)}, '
      'speed_ms: ${profile.speedMs.toStringAsFixed(0)}, '
      'topic_bias: ${profile.topTopic}',
    )
    ..writeln(
      'Files processed: $totalFiles   Promotions: $promotions   '
      'Demotions: $demotions   Duration: ${durationMs}ms',
    )
    ..writeln('Design index: ${(index * 100).toStringAsFixed(1)}% ($verdict)')
    ..writeln();

  for (final result in results) {
    final detail =
        'File ${result.relativePath} → '
        '${result.promotions} promotions, ${result.demotions} demotions, '
        '${result.total} drills';
    buffer.writeln(detail);
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int durationMs,
  required int modules,
  required int promotions,
  required int demotions,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_drill_balance_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': modules,
    'promotions': promotions,
    'demotions': demotions,
    'verdict': verdict,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class PersonalizationProfile {
  PersonalizationProfile({
    required this.accuracy,
    required this.speedMs,
    required this.speedBaseline,
    required this.topTopic,
  });

  factory PersonalizationProfile.empty() => PersonalizationProfile(
    accuracy: 0.7,
    speedMs: 4000,
    speedBaseline: 4000,
    topTopic: 'general',
  );

  static Future<PersonalizationProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) return PersonalizationProfile.empty();
    try {
      final raw = json.decode(await file.readAsString());
      if (raw is! Map<String, dynamic>) {
        return PersonalizationProfile.empty();
      }
      final fingerprint =
          raw['fingerprint'] as Map<String, dynamic>? ?? const {};
      final adjustments =
          raw['adjustments'] as Map<String, dynamic>? ?? const {};
      final topicBias =
          fingerprint['topic_bias'] as Map<String, dynamic>? ?? const {};
      final sortedTopics =
          topicBias.entries
              .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final topic = sortedTopics.isNotEmpty
          ? sortedTopics.first.key
          : 'general';

      return PersonalizationProfile(
        accuracy: (fingerprint['accuracy'] as num?)?.toDouble() ?? 0.7,
        speedMs: (fingerprint['speed_ms'] as num?)?.toDouble() ?? 4000,
        speedBaseline:
            (adjustments['baseline_speed_ms'] as num?)?.toDouble() ?? 4000,
        topTopic: topic,
      );
    } catch (_) {
      return PersonalizationProfile.empty();
    }
  }

  final double accuracy;
  final double speedMs;
  final double speedBaseline;
  final String topTopic;

  bool shouldPromote() => accuracy >= 0.8 && speedMs <= speedBaseline;

  bool shouldDemote() => accuracy < 0.6 || speedMs > speedBaseline;
}

class _Drill {
  _Drill(this.data) : difficulty = _extractDifficulty(data);

  final Map<String, dynamic> data;
  String difficulty;

  void updateDifficulty(String newValue) {
    difficulty = newValue;
    data['difficulty'] = newValue;
  }
}

class _BalanceResult {
  const _BalanceResult({
    required this.relativePath,
    required this.total,
    required this.promotions,
    required this.demotions,
  });

  final String relativePath;
  final int total;
  final int promotions;
  final int demotions;
}

String _extractDifficulty(Map<String, dynamic> data) {
  final direct = data['difficulty']?.toString().toLowerCase();
  if (_validDifficulty(direct)) return direct!;

  final tags = data['tags'];
  if (tags is List) {
    for (final tag in tags) {
      final value = tag.toString().toLowerCase();
      if (value.contains('difficulty_high')) return 'high';
      if (value.contains('difficulty_medium')) return 'medium';
      if (value.contains('difficulty_low')) return 'low';
    }
  } else if (tags is String) {
    final value = tags.toLowerCase();
    if (value.contains('difficulty_high')) return 'high';
    if (value.contains('difficulty_medium')) return 'medium';
    if (value.contains('difficulty_low')) return 'low';
  }
  return 'medium';
}

bool _validDifficulty(String? value) =>
    value == 'low' || value == 'medium' || value == 'high';

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
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'adaptive_drill_balancer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
