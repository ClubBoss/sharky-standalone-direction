import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const String _profilePath = 'release/_reports/personalization_profile.json';
const String _contentRoot = 'content';
const String _previewRoot = 'content_adaptive_preview';
const String _summaryPath = 'release/_reports/adaptive_recap_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final profile = await PersonalizationProfile.load(_profilePath);
  final files = await _discoverRecapFiles(profile.topTopic);

  final results = <_RecapResult>[];
  for (final file in files) {
    final result = await _generateAdaptiveRecap(file, profile);
    if (result != null) results.add(result);
  }

  final verdict = results.isEmpty ? 'WARN' : 'PASS';

  await _withReportsWritable(() async {
    await _writeSummary(
      profile: profile,
      results: results,
      durationMs: stopwatch.elapsedMilliseconds,
      verdict: verdict,
    );
    await _appendTelemetry(
      modules: results.length,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_recap_generator: modules=${results.length} verdict=$verdict',
  );
}

Future<List<String>> _discoverRecapFiles(String topic) async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];

  final files = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('recap.md')) continue;
    final content = await entity.readAsString();
    if (_topicMatch(content, topic)) {
      files.add(entity.path);
    }
  }
  return files;
}

bool _topicMatch(String content, String topic) {
  if (topic == 'general') return true;
  final lower = content.toLowerCase();
  return lower.contains(topic.toLowerCase());
}

Future<_RecapResult?> _generateAdaptiveRecap(
  String sourcePath,
  PersonalizationProfile profile,
) async {
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) return null;
  final original = await sourceFile.readAsLines();

  final intro = _buildIntro(profile);
  final outro = _buildOutro(profile);
  final body = _adjustBody(original, profile);

  final adaptiveLines = [
    '# Adaptive Recap – ${profile.topTopic}',
    '',
    ...intro,
    '',
    ...body,
    '',
    ...outro,
    '',
    '_Generated at ${DateTime.now().toIso8601String()}_',
  ];

  final relative = p
      .relative(sourcePath, from: _contentRoot)
      .replaceAll('\\', '/');
  final previewPath = p.join(_previewRoot, relative);
  await Directory(p.dirname(previewPath)).create(recursive: true);
  await File(previewPath).writeAsString('${adaptiveLines.join('\n')}\n');

  return _RecapResult(relativePath: relative, length: adaptiveLines.length);
}

List<String> _buildIntro(PersonalizationProfile profile) {
  if (profile.accuracy >= 0.8) {
    return [
      'Great work maintaining a strong accuracy rate.',
      'We will reinforce key edges in ${profile.topTopic} while nudging '
          'toward tougher patterns.',
    ];
  }
  if (profile.accuracy < 0.6) {
    return [
      'Let’s slow down and focus on clarity in ${profile.topTopic}.',
      'Below you will find additional examples and reminders targeting '
          'the most common leaks.',
    ];
  }
  return [
    'Steady progress in ${profile.topTopic}.',
    'Use this recap to solidify fundamentals and keep your tempo consistent.',
  ];
}

List<String> _buildOutro(PersonalizationProfile profile) {
  if (profile.speedMs <= 3500 && profile.accuracy >= 0.8) {
    return [
      'Wrap-up: keep pushing your decision speed; you are outperforming '
          'the baseline.',
      'Next session will introduce higher-pressure spots to sustain growth.',
    ];
  }
  if (profile.accuracy < 0.6) {
    return [
      'Wrap-up: pause after each example and replay the reasoning.',
      'Revisit the micro drills flagged in this recap before continuing.',
    ];
  }
  return [
    'Wrap-up: maintain a consistent pace and review this recap before '
        'your next loop.',
    'Stay focused on structured practice to lift both accuracy and speed.',
  ];
}

List<String> _adjustBody(
  List<String> original,
  PersonalizationProfile profile,
) {
  if (profile.accuracy >= 0.8) {
    return [
      ...original.take(40),
      '',
      '### Challenge Boost',
      '- Apply these ideas against stronger opponents.',
      '- Mix in reverse-lines to stay unpredictable.',
    ];
  }
  if (profile.accuracy < 0.6) {
    return [
      ...original.take(25),
      '',
      '### Reinforcement Examples',
      '- Walk through each step slowly, writing down your reasoning.',
      '- Compare outcomes vs. baseline heuristics.',
    ];
  }
  return [
    ...original.take(35),
    '',
    '### Focus Points',
    '- Keep betting lines tight and purposeful.',
    '- Use this recap to double-check your heuristics.',
  ];
}

Future<void> _writeSummary({
  required PersonalizationProfile profile,
  required List<_RecapResult> results,
  required int durationMs,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE RECAP SUMMARY')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Profile → accuracy: ${profile.accuracy.toStringAsFixed(2)}  '
      'speed_ms: ${profile.speedMs.toStringAsFixed(0)}  '
      'topic: ${profile.topTopic}',
    )
    ..writeln('Recaps generated: ${results.length}   Duration: ${durationMs}ms')
    ..writeln('Verdict: $verdict')
    ..writeln();

  for (final result in results) {
    buffer.writeln('File ${result.relativePath} → ${result.length} lines');
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int modules,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_recap_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': modules,
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
      final topics =
          topicBias.entries
              .map(
                (entry) => MapEntry(entry.key, (entry.value as num).toDouble()),
              )
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final topic = topics.isNotEmpty ? topics.first.key : 'general';
      return PersonalizationProfile(
        accuracy: (fingerprint['accuracy'] as num?)?.toDouble() ?? 0.7,
        speedMs: (fingerprint['speed_ms'] as num?)?.toDouble() ?? 4000,
        topTopic: topic,
      );
    } catch (_) {
      return PersonalizationProfile.empty();
    }
  }

  final double accuracy;
  final double speedMs;
  final String topTopic;
}

class _RecapResult {
  const _RecapResult({required this.relativePath, required this.length});

  final String relativePath;
  final int length;
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
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'adaptive_recap_generator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
