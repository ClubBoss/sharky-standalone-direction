import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final service = AiFeedbackLoopService();
  await service.applyFeedback();
}

class AiFeedbackLoopService {
  AiFeedbackLoopService({
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.profilePath = 'release/_reports/personalization_profile.json',
    this.decayFactor = 0.95,
  });

  final String telemetryPath;
  final String profilePath;
  final double decayFactor;

  Future<void> applyFeedback() async {
    final profile = await _loadProfile();
    final newSessions = await _loadNewSessions(profile.lastProcessed);

    if (newSessions.samples.isEmpty) {
      stdout.writeln(
        'ai_feedback_loop_service: no new telemetry events to ingest.',
      );
      return;
    }

    final avgAccuracy = newSessions
        .average((sample) => sample.accuracy)
        .clamp(0.0, 1.0);
    final avgSpeed = newSessions.average((sample) => sample.speedMs);

    final accuracyDelta = avgAccuracy - profile.baselineAccuracy;
    final speedDelta = profile.baselineSpeedMs > 0
        ? (profile.baselineSpeedMs - avgSpeed) / profile.baselineSpeedMs
        : 0.0;

    final adjustment = _computeAdjustment(accuracyDelta, speedDelta);
    final xpAdjustment = adjustment / 2;

    final updatedDifficulty = _clamp(
      profile.difficultyBias * decayFactor + adjustment,
      -0.15,
      0.15,
    );
    final updatedXpMultiplier = _clamp(
      (profile.xpMultiplier * decayFactor) + (1 + xpAdjustment),
      0.85,
      1.15,
    );

    final updatedProfile = profile.copyWith(
      difficultyBias: updatedDifficulty,
      xpMultiplier: updatedXpMultiplier,
      lastProcessed: newSessions.latestTimestamp ?? profile.lastProcessed,
      historyEntry: _HistoryEntry(
        timestamp: DateTime.now().toIso8601String(),
        accuracyDelta: accuracyDelta,
        speedDelta: speedDelta,
        difficultyBias: updatedDifficulty,
        xpMultiplier: updatedXpMultiplier,
      ),
    );

    await _persistProfile(updatedProfile);
    await _emitTelemetry(updatedProfile, accuracyDelta, speedDelta);
  }

  Future<_Profile> _loadProfile() async {
    final file = File(profilePath);
    if (!await file.exists()) {
      return _Profile.initial();
    }
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        return _Profile.fromJson(data);
      }
      return _Profile.initial();
    } catch (_) {
      return _Profile.initial();
    }
  }

  Future<_SessionBatch> _loadNewSessions(DateTime? lastProcessed) async {
    final file = File(telemetryPath);
    if (!await file.exists()) return const _SessionBatch([], null);
    final lines = await file.readAsLines();
    final targetEvents = <String>{
      'session_end',
      'review_checkpoint_started',
      'recap_opened',
    };
    final samples = <_SessionSample>[];
    DateTime? latest;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      dynamic payload;
      try {
        payload = json.decode(line);
      } catch (_) {
        continue;
      }
      if (payload is! Map<String, dynamic>) continue;
      final event = payload['event']?.toString();
      if (event == null || !targetEvents.contains(event)) continue;
      final timestampStr = payload['timestamp']?.toString();
      if (timestampStr == null) continue;
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) continue;
      if (lastProcessed != null && !timestamp.isAfter(lastProcessed)) {
        continue;
      }
      final sample = _SessionSample.fromEvent(payload);
      if (sample == null) continue;
      samples.add(sample);
      if (latest == null || timestamp.isAfter(latest)) {
        latest = timestamp;
      }
    }
    return _SessionBatch(samples, latest);
  }

  double _computeAdjustment(double accuracyDelta, double speedDelta) {
    if (accuracyDelta > 0 && speedDelta > 0) {
      final magnitude = _clamp(
        (accuracyDelta.abs() * 0.6) + (speedDelta.abs() * 0.4),
        0.05,
        0.15,
      );
      return magnitude;
    }

    final dropMagnitude = max(
      accuracyDelta < 0 ? accuracyDelta.abs() : 0.0,
      speedDelta < 0 ? speedDelta.abs() : 0.0,
    );
    final magnitude = _clamp(dropMagnitude, 0.05, 0.15);
    return -magnitude;
  }

  Future<void> _persistProfile(_Profile profile) async {
    await _withReportsWritable(() async {
      final encoder = const JsonEncoder.withIndent('  ');
      await File(
        profilePath,
      ).writeAsString('${encoder.convert(profile.toJson())}\n');
    });
  }

  Future<void> _emitTelemetry(
    _Profile profile,
    double accuracyDelta,
    double speedDelta,
  ) async {
    final payload = <String, Object?>{
      'event': 'ai_feedback_applied',
      'timestamp': DateTime.now().toIso8601String(),
      'accuracy_delta': _round(accuracyDelta),
      'speed_delta': _round(speedDelta),
      'xp_multiplier': _round(profile.xpMultiplier),
      'difficulty_bias': _round(profile.difficultyBias),
    };
    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _Profile {
  const _Profile({
    required this.baselineAccuracy,
    required this.baselineSpeedMs,
    required this.difficultyBias,
    required this.xpMultiplier,
    required this.lastProcessed,
    required this.history,
    required this.rawData,
  });

  factory _Profile.initial() => _Profile(
    baselineAccuracy: 0.7,
    baselineSpeedMs: 4000,
    difficultyBias: 0.0,
    xpMultiplier: 1.0,
    lastProcessed: null,
    history: const [],
    rawData: const {},
  );

  factory _Profile.fromJson(Map<String, dynamic> jsonData) {
    final fingerprint =
        jsonData['fingerprint'] as Map<String, dynamic>? ?? const {};
    final adjustments =
        jsonData['adjustments'] as Map<String, dynamic>? ?? const {};
    final historyList = jsonData['history'] as List<dynamic>? ?? const [];
    return _Profile(
      baselineAccuracy:
          _asDouble(fingerprint['accuracy'])?.clamp(0.0, 1.0) ?? 0.7,
      baselineSpeedMs: _asDouble(fingerprint['speed_ms']) ?? 4000,
      difficultyBias: _asDouble(adjustments['difficulty_bias']) ?? 0.0,
      xpMultiplier: _asDouble(adjustments['xp_multiplier']) ?? 1.0,
      lastProcessed: _parseTimestamp(adjustments['last_processed']),
      history: historyList
          .whereType<Map<String, dynamic>>()
          .map(_HistoryEntry.fromJson)
          .toList(),
      rawData: jsonData,
    );
  }

  final double baselineAccuracy;
  final double baselineSpeedMs;
  final double difficultyBias;
  final double xpMultiplier;
  final DateTime? lastProcessed;
  final List<_HistoryEntry> history;
  final Map<String, dynamic> rawData;

  _Profile copyWith({
    double? difficultyBias,
    double? xpMultiplier,
    DateTime? lastProcessed,
    _HistoryEntry? historyEntry,
  }) {
    final updatedHistory = List<_HistoryEntry>.from(history);
    if (historyEntry != null) {
      updatedHistory.add(historyEntry);
      if (updatedHistory.length > 50) {
        updatedHistory.removeAt(0);
      }
    }
    return _Profile(
      baselineAccuracy: baselineAccuracy,
      baselineSpeedMs: baselineSpeedMs,
      difficultyBias: difficultyBias ?? this.difficultyBias,
      xpMultiplier: xpMultiplier ?? this.xpMultiplier,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      history: updatedHistory,
      rawData: rawData,
    );
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>.from(rawData);
    data['adjustments'] = {
      'difficulty_bias': _round(difficultyBias),
      'xp_multiplier': _round(xpMultiplier),
      'last_processed': lastProcessed?.toIso8601String(),
    };
    data['history'] = history.map((entry) => entry.toJson()).toList();
    return data;
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.timestamp,
    required this.accuracyDelta,
    required this.speedDelta,
    required this.difficultyBias,
    required this.xpMultiplier,
  });

  factory _HistoryEntry.fromJson(Map<String, dynamic> json) => _HistoryEntry(
    timestamp: json['timestamp']?.toString() ?? '',
    accuracyDelta: _asDouble(json['accuracy_delta']) ?? 0,
    speedDelta: _asDouble(json['speed_delta']) ?? 0,
    difficultyBias: _asDouble(json['difficulty_bias']) ?? 0,
    xpMultiplier: _asDouble(json['xp_multiplier']) ?? 1,
  );

  final String timestamp;
  final double accuracyDelta;
  final double speedDelta;
  final double difficultyBias;
  final double xpMultiplier;

  Map<String, Object?> toJson() => {
    'timestamp': timestamp,
    'accuracy_delta': _round(accuracyDelta),
    'speed_delta': _round(speedDelta),
    'difficulty_bias': _round(difficultyBias),
    'xp_multiplier': _round(xpMultiplier),
  };
}

class _SessionSample {
  const _SessionSample({
    required this.accuracy,
    required this.speedMs,
    required this.topic,
  });

  final double accuracy;
  final double speedMs;
  final String topic;

  static _SessionSample? fromEvent(Map<String, dynamic> event) {
    final accuracy = _deriveAccuracy(event);
    final speed = _deriveSpeed(event);
    final topic = _deriveTopic(event);
    return _SessionSample(accuracy: accuracy, speedMs: speed, topic: topic);
  }
}

class _SessionBatch {
  const _SessionBatch(this.samples, this.latestTimestamp);

  final List<_SessionSample> samples;
  final DateTime? latestTimestamp;

  double average(double Function(_SessionSample) accessor) {
    if (samples.isEmpty) return 0;
    final total = samples.fold<double>(
      0,
      (sum, sample) => sum + accessor(sample),
    );
    return total / samples.length;
  }
}

double _deriveAccuracy(Map<String, dynamic> event) {
  final candidates = [event['accuracy'], event['score'], event['correct_pct']];
  for (final candidate in candidates) {
    final value = _asDouble(candidate);
    if (value != null) {
      final normalized = value > 1 ? value / 100 : value;
      return normalized.clamp(0.0, 1.0).toDouble();
    }
  }
  return 0.7;
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
  return 4000;
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

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

double _round(double value) => double.parse(value.toStringAsFixed(3));

double _clamp(double value, double minValue, double maxValue) =>
    value.clamp(minValue, maxValue).toDouble();

DateTime? _parseTimestamp(dynamic value) =>
    value is String ? DateTime.tryParse(value) : null;

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
      'ai_feedback_loop_service: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}
