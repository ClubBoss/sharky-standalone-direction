import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _profilePath = 'release/_reports/personalization_profile.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _previewRoot = 'content_adaptive_preview';
const String _summaryPath =
    'release/_reports/adaptive_module_composer_summary.txt';
const String _telemetryOut = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final profile = await _PersonalizationProfile.load(_profilePath);
  final weaknesses = await _findWeakTopics(profile);

  final generated = <_ModuleGeneration>[];
  for (final weak in weaknesses) {
    final module = await _generatePack(weak);
    generated.add(module);
  }

  await _withReportsWritable(() async {
    await _writeSummary(
      profile: profile,
      generated: generated,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(
      generated: generated,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_module_composer: topics=${generated.length} '
    'modules=${generated.fold<int>(0, (sum, item) => sum + item.packFiles.length)}',
  );
}

Future<List<_TopicWeakness>> _findWeakTopics(
  _PersonalizationProfile profile,
) async {
  final telemetryWeaknesses = await _scanTelemetry();
  final merged = <String, _TopicWeakness>{};

  void addWeakness(String topic, double accuracy) {
    final lower = topic.toLowerCase();
    final existing = merged[lower];
    if (existing == null || accuracy < existing.accuracy) {
      merged[lower] = _TopicWeakness(topic: lower, accuracy: accuracy);
    }
  }

  for (final bias in profile.topicBias.entries) {
    if (bias.value < 0.2) {
      addWeakness(bias.key, profile.accuracy);
    }
  }

  for (final weakness in telemetryWeaknesses) {
    if (weakness.accuracy < profile.accuracy) {
      addWeakness(weakness.topic, weakness.accuracy);
    }
  }

  final filtered =
      merged.values.where((weakness) => weakness.accuracy < 0.78).toList()
        ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

  return filtered.take(3).toList();
}

Future<List<_TopicWeakness>> _scanTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final results = <_TopicWeakness>[];
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
    final accuracy = _toDouble(payload['accuracy']);
    if (topic == null || accuracy == null) continue;
    results.add(_TopicWeakness(topic: topic, accuracy: accuracy));
  }
  return results;
}

Future<_ModuleGeneration> _generatePack(_TopicWeakness weakness) async {
  final topicPath = weakness.topic.replaceAll(' ', '_');
  final dir = Directory('$_previewRoot/$topicPath/v1');
  await dir.create(recursive: true);
  final packFile = File(
    '${dir.path}/pack_${DateTime.now().millisecondsSinceEpoch}.json',
  );
  final pack = {
    'topic': weakness.topic,
    'generated_at': DateTime.now().toIso8601String(),
    'targets': {
      'accuracy': 0.85,
      'current_accuracy': double.parse(weakness.accuracy.toStringAsFixed(2)),
    },
    'mirrored': true,
    'drills': [
      {
        'id': 'weak_${weakness.topic}_${Random().nextInt(9999)}',
        'type': 'conceptual_review',
        'difficulty': 'medium',
        'focus': weakness.topic,
      },
    ],
  };
  await packFile.writeAsString('${jsonEncode(pack)}\n');
  return _ModuleGeneration(
    topic: weakness.topic,
    accuracy: weakness.accuracy,
    packFiles: [packFile.path],
  );
}

Future<void> _writeSummary({
  required _PersonalizationProfile profile,
  required List<_ModuleGeneration> generated,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE MODULE COMPOSER SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Base accuracy: ${profile.accuracy.toStringAsFixed(2)}')
    ..writeln('Topics generated: ${generated.length}')
    ..writeln();
  if (generated.isEmpty) {
    buffer.writeln('No weak topics detected; no packs generated.');
  } else {
    buffer.writeln('Generated packs:');
    for (final module in generated) {
      buffer.writeln(
        '- ${module.topic} (accuracy ${module.accuracy.toStringAsFixed(2)})',
      );
      for (final file in module.packFiles) {
        buffer.writeln('  -> $file');
      }
    }
  }
  buffer.writeln();

  await File(_summaryPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry({
  required List<_ModuleGeneration> generated,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_module_composer_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': generated
        .map(
          (module) => {
            'topic': module.topic,
            'accuracy': module.accuracy,
            'packs': module.packFiles.length,
          },
        )
        .toList(),
    'duration_ms': durationMs,
  };

  await File(_telemetryOut).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
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
        accuracy: _toDouble(fingerprint['accuracy']) ?? 0.7,
        topicBias: topicBias.map(
          (key, value) => MapEntry(key.toString(), _toDouble(value) ?? 0),
        ),
      );
    } catch (_) {
      return const _PersonalizationProfile(accuracy: 0.7, topicBias: {});
    }
  }

  final double accuracy;
  final Map<String, double> topicBias;
}

class _TopicWeakness {
  const _TopicWeakness({required this.topic, required this.accuracy});

  final String topic;
  final double accuracy;
}

class _ModuleGeneration {
  const _ModuleGeneration({
    required this.topic,
    required this.accuracy,
    required this.packFiles,
  });

  final String topic;
  final double accuracy;
  final List<String> packFiles;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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
