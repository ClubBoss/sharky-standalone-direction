import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Entry-point for generating AI personalization fingerprints from telemetry.
Future<void> main(List<String> args) async {
  final core = AiPersonalizationCore();
  final fingerprint = await core.generateFingerprint();
  await core.persistFingerprint(fingerprint);
  await core.emitTelemetry(fingerprint);
}

/// Core service responsible for building a per-user learning fingerprint.
class AiPersonalizationCore {
  AiPersonalizationCore({
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.outputPath = 'release/_reports/personalization_profile.json',
    this.maxSessions = 20,
  });

  final String telemetryPath;
  final String outputPath;
  final int maxSessions;

  Future<PersonalizationFingerprint> generateFingerprint() async {
    final aggregator = _MetricsAggregator(maxSessions: maxSessions);
    final file = File(telemetryPath);
    if (!await file.exists()) {
      return PersonalizationFingerprint.empty();
    }

    final lines = await file.readAsLines();
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      final sample = _SessionSample.fromTelemetry(line);
      if (sample == null) continue;
      aggregator.addSample(sample);
    }

    return PersonalizationFingerprint(
      accuracy: aggregator.weightedAverage((sample) => sample.accuracy),
      speedMs: aggregator.weightedAverage((sample) => sample.speedMs),
      topicBias: aggregator.topicBias(),
      xpRate: aggregator.weightedAverage((sample) => sample.xpGain),
    );
  }

  Future<void> persistFingerprint(
    PersonalizationFingerprint fingerprint,
  ) async {
    await _withReportsWritable(() async {
      final payload = <String, Object?>{
        'generated_at': DateTime.now().toIso8601String(),
        'fingerprint': fingerprint.toJson(),
      };
      final encoder = const JsonEncoder.withIndent('  ');
      await File(outputPath).writeAsString('${encoder.convert(payload)}\n');
    });
  }

  Future<void> emitTelemetry(PersonalizationFingerprint fingerprint) async {
    final payload = <String, Object?>{
      'event': 'ai_personalization_generated',
      'timestamp': DateTime.now().toIso8601String(),
      'accuracy': _round(fingerprint.accuracy),
      'speed_ms': _round(fingerprint.speedMs),
      'xp_rate': _round(fingerprint.xpRate),
      'topic_bias': fingerprint.topicBias,
    };
    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class PersonalizationFingerprint {
  const PersonalizationFingerprint({
    required this.accuracy,
    required this.speedMs,
    required this.topicBias,
    required this.xpRate,
  });

  factory PersonalizationFingerprint.empty() =>
      const PersonalizationFingerprint(
        accuracy: 0,
        speedMs: 0,
        topicBias: <String, double>{},
        xpRate: 0,
      );

  final double accuracy;
  final double speedMs;
  final Map<String, double> topicBias;
  final double xpRate;

  Map<String, Object?> toJson() => {
    'accuracy': _round(accuracy),
    'speed_ms': _round(speedMs),
    'topic_bias': topicBias.map(
      (topic, weight) => MapEntry(topic, _round(weight)),
    ),
    'xp_rate': _round(xpRate),
  };
}

class _MetricsAggregator {
  _MetricsAggregator({required this.maxSessions});

  final int maxSessions;
  final List<_SessionSample> _samples = [];

  void addSample(_SessionSample sample) {
    _samples.insert(0, sample);
    if (_samples.length > maxSessions) {
      _samples.removeLast();
    }
  }

  double weightedAverage(double Function(_SessionSample) accessor) {
    if (_samples.isEmpty) return 0;
    var weightedTotal = 0.0;
    var weightSum = 0.0;
    for (var i = 0; i < _samples.length; i++) {
      final weight = pow(0.9, i).toDouble();
      weightedTotal += accessor(_samples[i]) * weight;
      weightSum += weight;
    }
    return weightSum == 0 ? 0 : weightedTotal / weightSum;
  }

  Map<String, double> topicBias() {
    if (_samples.isEmpty) return const <String, double>{};
    final weights = <String, double>{};
    for (var i = 0; i < _samples.length; i++) {
      final weight = pow(0.9, i).toDouble();
      final topic = _samples[i].topic;
      weights[topic] = (weights[topic] ?? 0) + weight;
    }
    final totalWeight = weights.values.fold<double>(0, (a, b) => a + b);
    if (totalWeight == 0) return const {};

    final normalized = weights.map(
      (topic, weight) => MapEntry(topic, weight / totalWeight),
    );

    final sortedEntries = normalized.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(3);
    return {for (final entry in topEntries) entry.key: _round(entry.value)};
  }
}

class _SessionSample {
  const _SessionSample({
    required this.accuracy,
    required this.speedMs,
    required this.topic,
    required this.xpGain,
  });

  final double accuracy;
  final double speedMs;
  final String topic;
  final double xpGain;

  static _SessionSample? fromTelemetry(String line) {
    dynamic data;
    try {
      data = json.decode(line);
    } catch (_) {
      return null;
    }
    if (data is! Map<String, dynamic>) return null;

    final event = data['event']?.toString();
    if (event == null ||
        !const {
          'session_start',
          'loop_progress_completed',
          'recap_opened',
        }.contains(event)) {
      return null;
    }

    final accuracy = _deriveAccuracy(data, event);
    final speedMs = _deriveSpeed(data);
    final topic = _deriveTopic(data);
    final xpGain = _deriveXp(data);

    return _SessionSample(
      accuracy: accuracy,
      speedMs: speedMs,
      topic: topic,
      xpGain: xpGain,
    );
  }
}

double _deriveAccuracy(Map<String, dynamic> event, String name) {
  final accuracyCandidates = [
    event['accuracy'],
    event['score'],
    event['correct_pct'],
  ];
  for (final candidate in accuracyCandidates) {
    final value = _asDouble(candidate);
    if (value != null) {
      final normalized = value > 1 ? value / 100 : value;
      return normalized.clamp(0.0, 1.0).toDouble();
    }
  }

  switch (name) {
    case 'session_start':
      return 0.7;
    case 'loop_progress_completed':
      return 0.75;
    case 'recap_opened':
      return 0.6;
    default:
      return 0.7;
  }
}

double _deriveSpeed(Map<String, dynamic> event) {
  final candidates = [
    event['speed_ms'],
    event['duration_ms'],
    event['latency_ms'],
  ];
  for (final candidate in candidates) {
    final value = _asDouble(candidate);
    if (value != null && value > 0) return value;
  }
  return 4000; // conservative fallback
}

String _deriveTopic(Map<String, dynamic> event) {
  final candidates = [
    event['topic'],
    event['module'],
    event['lesson'],
    event['subject'],
  ];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final topic = candidate.toString().trim();
    if (topic.isNotEmpty) return topic;
  }
  return 'general';
}

double _deriveXp(Map<String, dynamic> event) {
  final candidates = [event['xp_gain'], event['xp'], event['xp_delta']];
  for (final candidate in candidates) {
    final value = _asDouble(candidate);
    if (value != null) return value;
  }
  final streak = _asDouble(event['streak'] ?? event['current_streak']);
  return (streak ?? 0) * 1.0;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

double _round(double value) => double.parse(value.toStringAsFixed(3));

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
      'ai_personalization_core: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}
