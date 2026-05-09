import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const String _profilePath = 'release/_reports/personalization_profile.json';
const String _contentRoot = 'content';
const String _previewRoot = 'content_adaptive_preview';
const String _summaryPath = 'release/_reports/adaptive_quiz_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const double _adjustRatio = 0.10;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final profile = await PersonalizationProfile.load(_profilePath);
  final promote = profile.accuracy >= 0.8;
  final demote = profile.accuracy < 0.6;

  final quizFiles = await _discoverQuizFiles(profile.topTopic);
  final results = <_QuizResult>[];

  for (final file in quizFiles) {
    final result = await _rebalanceQuiz(file, promote: promote, demote: demote);
    if (result != null) {
      results.add(result);
    }
  }

  final totalPromotions = results.fold<int>(0, (sum, r) => sum + r.promotions);
  final totalDemotions = results.fold<int>(0, (sum, r) => sum + r.demotions);
  final verdict = results.isEmpty
      ? 'WARN'
      : (promote && totalPromotions == 0) || (demote && totalDemotions == 0)
      ? 'WARN'
      : 'PASS';

  await _withReportsWritable(() async {
    await _writeSummary(
      profile: profile,
      results: results,
      durationMs: stopwatch.elapsedMilliseconds,
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
    'adaptive_quiz_composer: modules=${results.length} '
    'promotions=$totalPromotions demotions=$totalDemotions verdict=$verdict',
  );
}

Future<List<String>> _discoverQuizFiles(String topic) async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];

  final files = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('quiz.jsonl')) continue;
    if (await _matchesTopic(entity.path, topic)) {
      files.add(entity.path);
    }
  }
  return files;
}

Future<bool> _matchesTopic(String path, String topic) async {
  final file = File(path);
  if (!await file.exists()) return false;
  final lines = await file.readAsLines();
  for (final line in lines.take(25)) {
    if (line.trim().isEmpty) continue;
    dynamic jsonLine;
    try {
      jsonLine = json.decode(line);
    } catch (_) {
      continue;
    }
    if (jsonLine is Map<String, dynamic>) {
      final tags = jsonLine['tags'];
      if (_topicMatch(tags, topic)) return true;
    }
  }
  return false;
}

bool _topicMatch(dynamic tags, String topic) {
  final lowerTopic = topic.toLowerCase();
  if (tags is List) {
    for (final tag in tags) {
      if (tag.toString().toLowerCase().contains(lowerTopic)) {
        return true;
      }
    }
  } else if (tags is String) {
    if (tags.toLowerCase().contains(lowerTopic)) return true;
  }
  return false;
}

Future<_QuizResult?> _rebalanceQuiz(
  String sourcePath, {
  required bool promote,
  required bool demote,
}) async {
  final lines = await File(sourcePath).readAsLines();
  if (lines.isEmpty) return null;

  final questions = <_QuizQuestion>[];
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic data;
    try {
      data = json.decode(line);
    } catch (_) {
      continue;
    }
    if (data is Map<String, dynamic>) {
      questions.add(_QuizQuestion(data));
    }
  }
  if (questions.isEmpty) return null;

  var promotions = 0;
  var demotions = 0;

  if (promote) {
    final medium = questions.where((q) => q.difficulty == 'medium').toList();
    final count = _targetCount(medium.length);
    for (var i = 0; i < count && i < medium.length; i++) {
      medium[i].updateDifficulty('hard');
      promotions++;
    }
  }

  if (demote) {
    final hard = questions.where((q) => q.difficulty == 'hard').toList();
    final count = _targetCount(hard.length);
    for (var i = 0; i < count && i < hard.length; i++) {
      hard[i].updateDifficulty('medium');
      demotions++;
    }
  }

  final relative = p
      .relative(sourcePath, from: _contentRoot)
      .replaceAll('\\', '/');
  final previewPath = p.join(_previewRoot, relative);
  await Directory(p.dirname(previewPath)).create(recursive: true);
  final sink = File(previewPath).openWrite();
  for (final question in questions) {
    sink.writeln(jsonEncode(question.data));
  }
  await sink.close();

  return _QuizResult(
    relativePath: relative,
    total: questions.length,
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
  required PersonalizationProfile profile,
  required List<_QuizResult> results,
  required int durationMs,
  required String verdict,
}) async {
  final totalFiles = results.length;
  final promotions = results.fold<int>(0, (sum, r) => sum + r.promotions);
  final demotions = results.fold<int>(0, (sum, r) => sum + r.demotions);
  final index = totalFiles == 0
      ? 0.0
      : (promotions + demotions) / (totalFiles * 2).clamp(1, double.infinity);

  final buffer = StringBuffer()
    ..writeln('ADAPTIVE QUIZ SUMMARY')
    ..writeln('======================')
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
    ..writeln(
      'Quiz cohesion index: ${(index * 100).toStringAsFixed(1)}% ($verdict)',
    )
    ..writeln();

  for (final result in results) {
    buffer.writeln(
      'File ${result.relativePath} → '
      '${result.promotions} promotions / ${result.demotions} demotions '
      '(${result.total} questions)',
    );
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
    'event': 'adaptive_quiz_completed',
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
    required this.topTopic,
  });

  factory PersonalizationProfile.empty() =>
      PersonalizationProfile(accuracy: 0.7, speedMs: 4000, topTopic: 'general');

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
      final topicBias =
          fingerprint['topic_bias'] as Map<String, dynamic>? ?? const {};
      final sortedTopics =
          topicBias.entries
              .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final topTopic = sortedTopics.isNotEmpty
          ? sortedTopics.first.key
          : 'general';
      return PersonalizationProfile(
        accuracy: (fingerprint['accuracy'] as num?)?.toDouble() ?? 0.7,
        speedMs: (fingerprint['speed_ms'] as num?)?.toDouble() ?? 4000,
        topTopic: topTopic,
      );
    } catch (_) {
      return PersonalizationProfile.empty();
    }
  }

  final double accuracy;
  final double speedMs;
  final String topTopic;
}

class _QuizQuestion {
  _QuizQuestion(this.data) : difficulty = _extractDifficulty(data);

  final Map<String, dynamic> data;
  String difficulty;

  void updateDifficulty(String newValue) {
    difficulty = newValue;
    data['difficulty'] = newValue;
  }
}

class _QuizResult {
  const _QuizResult({
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
      if (value.contains('difficulty_high')) return 'hard';
      if (value.contains('difficulty_medium')) return 'medium';
      if (value.contains('difficulty_low')) return 'low';
    }
  } else if (tags is String) {
    final value = tags.toLowerCase();
    if (value.contains('difficulty_high')) return 'hard';
    if (value.contains('difficulty_medium')) return 'medium';
    if (value.contains('difficulty_low')) return 'low';
  }
  return 'medium';
}

bool _validDifficulty(String? value) =>
    value == 'low' || value == 'medium' || value == 'high' || value == 'hard';

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
      'adaptive_quiz_composer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
