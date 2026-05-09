import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const String _profilePath = 'release/_reports/personalization_profile.json';
const String _contentRoot = 'content';
const String _outputMirror = 'content_adaptive_preview';
const String _summaryPath = 'release/_reports/content_evolution_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const List<String> _metadataFiles = ['labels.txt', 'paths.txt'];

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final profile = await _readProfile();
  final topicKey = profile.topicBias.entries.isNotEmpty
      ? profile.topicBias.entries.first.key
      : 'general';
  final difficultyTag = _difficultyTag(profile.difficultyBias);

  final modules = await _scanModules(topicKey);
  final processed = <_ModuleResult>[];

  for (final module in modules) {
    final result = await _processModule(
      module,
      topicKey: topicKey,
      difficultyTag: difficultyTag,
    );
    if (result != null) {
      processed.add(result);
    }
  }

  await _withReportsWritable(() async {
    await _writeSummary(
      profile: profile,
      topicKey: topicKey,
      difficultyTag: difficultyTag,
      results: processed,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _appendTelemetry(
      modules: processed.length,
      difficultyTag: difficultyTag,
      topicKey: topicKey,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'content_evolution_refactor: modules=${processed.length} '
    'topic=$topicKey difficulty=$difficultyTag',
  );
}

Future<PersonalizationProfile> _readProfile() async {
  final file = File(_profilePath);
  if (!await file.exists()) return PersonalizationProfile.empty();
  try {
    final data = json.decode(await file.readAsString());
    if (data is Map<String, dynamic>) {
      return PersonalizationProfile.fromJson(data);
    }
  } catch (_) {
    // fall through to empty profile
  }
  return PersonalizationProfile.empty();
}

Future<List<_ModuleInfo>> _scanModules(String topicKey) async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];
  final modules = <_ModuleInfo>[];

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is Directory && entity.path.endsWith('v1')) {
      final metadata = await _readMetadata(entity.path);
      final tags = metadata['tags'] ?? '';

      final topicMatch = tags.toLowerCase().contains(topicKey.toLowerCase());
      final difficultyMatch = tags.contains('difficulty:');

      if (topicMatch || difficultyMatch) {
        modules.add(_ModuleInfo(path: entity.path, tags: tags));
      }
    }
  }
  return modules;
}

Future<_ModuleResult?> _processModule(
  _ModuleInfo module, {
  required String topicKey,
  required String difficultyTag,
}) async {
  final relativePath = p
      .relative(module.path, from: _contentRoot)
      .replaceAll('\\', '/');
  final outputDir = Directory(p.join(_outputMirror, relativePath));
  await outputDir.create(recursive: true);

  var updatedFiles = 0;
  for (final fileName in _metadataFiles) {
    final sourceFile = File(p.join(module.path, fileName));
    if (!await sourceFile.exists()) continue;
    final content = await sourceFile.readAsLines();
    final adaptedContent = List<String>.from(content)
      ..add('difficulty_adapted: $difficultyTag')
      ..add('recommended_for: $topicKey');
    final targetFile = File(p.join(outputDir.path, fileName));
    await targetFile.writeAsString('${adaptedContent.join('\n')}\n');
    updatedFiles++;
  }

  await File(p.join(outputDir.path, 'meta.json')).writeAsString(
    jsonEncode({
      'source': module.path,
      'difficulty_adapted': difficultyTag,
      'recommended_for': topicKey,
      'generated_at': DateTime.now().toIso8601String(),
    }),
  );

  return _ModuleResult(
    modulePath: module.path,
    relativePath: relativePath,
    updatedFiles: updatedFiles,
  );
}

Future<Map<String, String>> _readMetadata(String modulePath) async {
  final metadata = <String, String>{};
  for (final fileName in _metadataFiles) {
    final file = File(p.join(modulePath, fileName));
    if (!await file.exists()) continue;
    final lines = await file.readAsLines();
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        metadata[parts.first.trim().toLowerCase()] = parts
            .sublist(1)
            .join(':')
            .trim();
      }
    }
  }
  return metadata;
}

Future<void> _writeSummary({
  required PersonalizationProfile profile,
  required String topicKey,
  required String difficultyTag,
  required List<_ModuleResult> results,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('CONTENT EVOLUTION SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Topic bias key: $topicKey')
    ..writeln('Difficulty adaptation: $difficultyTag')
    ..writeln('Modules mirrored: ${results.length}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln();

  for (final result in results) {
    buffer.writeln(
      '${result.relativePath} → mirror files updated: ${result.updatedFiles}',
    );
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int modules,
  required String difficultyTag,
  required String topicKey,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'content_evolution_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': modules,
    'difficulty': difficultyTag,
    'topic': topicKey,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _difficultyTag(double bias) {
  if (bias >= 0.1) return 'high';
  if (bias <= -0.1) return 'low';
  return 'medium';
}

class PersonalizationProfile {
  const PersonalizationProfile({
    required this.topicBias,
    required this.difficultyBias,
  });

  factory PersonalizationProfile.empty() =>
      const PersonalizationProfile(topicBias: {}, difficultyBias: 0);

  factory PersonalizationProfile.fromJson(Map<String, dynamic> json) {
    final fingerprint =
        json['fingerprint'] as Map<String, dynamic>? ?? const {};
    final topicBias =
        fingerprint['topic_bias'] as Map<String, dynamic>? ?? const {};
    final adjustments =
        json['adjustments'] as Map<String, dynamic>? ?? const {};
    return PersonalizationProfile(
      topicBias: topicBias.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      difficultyBias: (adjustments['difficulty_bias'] as num?)?.toDouble() ?? 0,
    );
  }

  final Map<String, double> topicBias;
  final double difficultyBias;
}

class _ModuleInfo {
  const _ModuleInfo({required this.path, required this.tags});

  final String path;
  final String tags;
}

class _ModuleResult {
  const _ModuleResult({
    required this.modulePath,
    required this.relativePath,
    required this.updatedFiles,
  });

  final String modulePath;
  final String relativePath;
  final int updatedFiles;
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
      'content_evolution_refactor: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
