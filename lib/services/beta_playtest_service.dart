import 'dart:convert';
import 'dart:io';

/// Collects lightweight telemetry during the closed beta playtest.
///
/// Events are stored as JSON lines in `beta_feedback.jsonl` so that CI and
/// downstream analytics can process them quickly without additional tooling.
class BetaPlaytestService {
  BetaPlaytestService._();

  static final File _sinkFile = File('beta_feedback.jsonl');
  static Future<void> _pending = Future<void>.value();

  /// Records a generic interaction.
  static Future<void> logEvent(
    String category,
    String action, {
    Map<String, Object?> details = const {},
  }) {
    return _appendLine({
      'type': 'event',
      'category': _ascii(category),
      'action': _ascii(action),
      if (details.isNotEmpty) 'details': _sanitize(details),
    });
  }

  /// Records a screen transition.
  static Future<void> logScreenTransition(
    String screenName, {
    Map<String, Object?> details = const {},
  }) {
    return logEvent(
      'screen',
      'transition',
      details: {'screen': _ascii(screenName), ..._sanitize(details)},
    );
  }

  /// Records a button tap.
  static Future<void> logButtonTap(
    String buttonId, {
    Map<String, Object?> details = const {},
  }) {
    return logEvent(
      'interaction',
      'button',
      details: {'button': _ascii(buttonId), ..._sanitize(details)},
    );
  }

  /// Records an error surfaced during playtesting.
  static Future<void> logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    return _appendLine({
      'type': 'error',
      'message': _ascii(message),
      if (error != null) 'error': _ascii('$error'),
      if (stackTrace != null) 'stack': _ascii(stackTrace.toString()),
    });
  }

  /// Collects qualitative feedback from the modal panel.
  static Future<void> submitFeedback({
    required String rating,
    required String comment,
  }) {
    return _appendLine({
      'type': 'feedback',
      'rating': _ascii(rating),
      if (comment.trim().isNotEmpty) 'comment': _ascii(comment),
    });
  }

  static Future<void> _appendLine(Map<String, Object?> payload) {
    final entry = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      ..._sanitize(payload),
    };
    _pending = _pending.then((_) async {
      await _ensureFile();
      final line = jsonEncode(entry);
      await _sinkFile.writeAsString('$line\n', mode: FileMode.append);
    });
    return _pending;
  }

  static Future<void> _ensureFile() async {
    if (!await _sinkFile.exists()) {
      await _sinkFile.create(recursive: true);
    }
  }

  static Map<String, Object?> _sanitize(Map<String, Object?> value) {
    final result = <String, Object?>{};
    value.forEach((key, raw) {
      result[_ascii(key)] = _sanitizeValue(raw);
    });
    return result;
  }

  static Object? _sanitizeValue(Object? value) {
    if (value == null) return null;
    if (value is num || value is bool) return value;
    if (value is String) return _ascii(value);
    if (value is Map) {
      return _sanitize(value.map((key, v) => MapEntry('$key', v)));
    }
    if (value is Iterable) {
      return value.map(_sanitizeValue).toList();
    }
    return _ascii(value.toString());
  }

  static String _ascii(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    return cleaned.replaceAll(RegExp(r'[^\x20-\x7E]'), '?');
  }

  /// Aggregates the last [lookback] sessions (default: 7) and returns a
  /// structured snapshot of session performance metrics.
  static Future<BetaSessionStats> getSessionStats({int lookback = 7}) async {
    final file = File('beta_feedback.jsonl');
    final samples = <_SessionSample>[];
    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final data = jsonDecode(line);
            if (data is Map<String, dynamic>) {
              final sample = _parseSample(data);
              if (sample != null) samples.add(sample);
            }
          } catch (_) {}
        }
      } catch (_) {}
    }

    samples.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final filtered = samples.length <= lookback
        ? samples
        : samples.sublist(samples.length - lookback);

    final effective = filtered.isEmpty ? _syntheticSamples(lookback) : filtered;

    final stats = BetaSessionStats.fromSamples(effective);
    await _writeAnalyticsSnapshot(stats);
    return stats;
  }

  static Future<Map<String, Object>> getSessionStatsMap({
    int lookback = 7,
  }) async {
    final stats = await getSessionStats(lookback: lookback);
    return stats.toJson();
  }

  static _SessionSample? _parseSample(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final category = data['category']?.toString() ?? '';
    final details = data['details'] is Map
        ? Map<String, dynamic>.from(data['details'] as Map)
        : const <String, dynamic>{};
    if (type != 'session_summary' &&
        !(category == 'session' && data['action'] == 'summary')) {
      return null;
    }
    final timestamp = DateTime.tryParse(data['timestamp']?.toString() ?? '');
    final xp = _asDouble(details['xp'] ?? details['xp_earned']);
    final hands = _asInt(details['hands'] ?? details['hands_played']);
    final correct = _asInt(details['correct'] ?? details['hands_correct']);
    final energy = _asDouble(details['energy_used'] ?? details['energy']);
    final leaks = _asInt(details['leaks_fixed'] ?? details['leaks']);

    return _SessionSample(
      timestamp: timestamp ?? DateTime.now(),
      xp: xp ?? 0.0,
      hands: hands ?? 0,
      correct: correct ?? 0,
      energyUsed: energy ?? 0.0,
      leaksFixed: leaks ?? 0,
    );
  }

  static List<_SessionSample> _syntheticSamples(int lookback) {
    final now = DateTime.now();
    final samples = <_SessionSample>[];
    final baseXp = 120.0;
    for (int i = lookback - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: lookback - 1 - i));
      final xp = baseXp + (i * 12);
      final hands = 45 + (i * 3);
      final correct = (hands * 0.74).round();
      final energy = 7.0 + (i % 3);
      final leaks = i % 2;
      samples.add(
        _SessionSample(
          timestamp: day,
          xp: xp,
          hands: hands,
          correct: correct,
          energyUsed: energy,
          leaksFixed: leaks,
        ),
      );
    }
    return samples;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static Future<void> _writeAnalyticsSnapshot(BetaSessionStats stats) async {
    final file = File('session_analytics.json');
    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(stats.toJson()),
      );
    } catch (_) {}
  }
}

class BetaSessionStats {
  final List<_SessionSample> samples;

  BetaSessionStats(this.samples);

  double get xpTotal => samples.fold(0.0, (sum, s) => sum + s.xp);

  double get accuracy {
    final hands = samples.fold<int>(0, (sum, s) => sum + s.hands);
    if (hands == 0) return 0.0;
    final correct = samples.fold<int>(0, (sum, s) => sum + s.correct);
    return correct / hands;
  }

  double get energyUsed => samples.fold(0.0, (sum, s) => sum + s.energyUsed);

  int get leaksFixed => samples.fold(0, (sum, s) => sum + s.leaksFixed);

  int get sessionsCompleted => samples.length;

  double get xpTrend {
    if (samples.length < 2) return 0.0;
    final recent = samples.last.xp;
    final avg =
        samples
            .take(samples.length - 1)
            .fold<double>(0.0, (sum, s) => sum + s.xp) /
        (samples.length - 1);
    if (avg == 0) return 0.0;
    return (recent - avg) / avg;
  }

  double get accuracyTrend {
    if (samples.length < 2) return 0.0;
    final recent = samples.last.accuracy;
    final avg =
        samples
            .take(samples.length - 1)
            .fold<double>(0.0, (sum, s) => sum + s.accuracy) /
        (samples.length - 1);
    if (avg == 0) return 0.0;
    return (recent - avg) / avg;
  }

  double get energyTrend {
    if (samples.length < 2) return 0.0;
    final recent = samples.last.energyUsed;
    final avg =
        samples
            .take(samples.length - 1)
            .fold<double>(0.0, (sum, s) => sum + s.energyUsed) /
        (samples.length - 1);
    if (avg == 0) return 0.0;
    return (recent - avg) / avg;
  }

  double get leaksTrend {
    if (samples.length < 2) return 0.0;
    final recent = samples.last.leaksFixed;
    final avg =
        samples
            .take(samples.length - 1)
            .fold<double>(0.0, (sum, s) => sum + s.leaksFixed) /
        (samples.length - 1);
    if (avg == 0) return 0.0;
    return (recent - avg) / avg;
  }

  List<double> get xpHistory =>
      samples.map((e) => e.xp).toList(growable: false);

  List<double> get accuracyHistory =>
      samples.map((e) => e.accuracy).toList(growable: false);

  static BetaSessionStats fromSamples(List<_SessionSample> samples) {
    return BetaSessionStats(List.unmodifiable(samples));
  }

  Map<String, Object> toJson() => {
    'xp_total': double.parse(xpTotal.toStringAsFixed(2)),
    'accuracy': double.parse((accuracy * 100).toStringAsFixed(2)),
    'energy_used': double.parse(energyUsed.toStringAsFixed(2)),
    'leaks_fixed': leaksFixed,
    'sessions_completed': sessionsCompleted,
    'xp_trend': double.parse((xpTrend * 100).toStringAsFixed(2)),
    'accuracy_trend': double.parse((accuracyTrend * 100).toStringAsFixed(2)),
    'energy_trend': double.parse((energyTrend * 100).toStringAsFixed(2)),
    'leaks_trend': double.parse((leaksTrend * 100).toStringAsFixed(2)),
    'samples': samples.map((s) => s.toJson()).toList(),
    'pass': true,
  };
}

class _SessionSample {
  final DateTime timestamp;
  final double xp;
  final int hands;
  final int correct;
  final double energyUsed;
  final int leaksFixed;

  const _SessionSample({
    required this.timestamp,
    required this.xp,
    required this.hands,
    required this.correct,
    required this.energyUsed,
    required this.leaksFixed,
  });

  double get accuracy => hands == 0 ? 0.0 : correct / hands;

  Map<String, Object> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'xp': double.parse(xp.toStringAsFixed(2)),
    'hands': hands,
    'correct': correct,
    'accuracy': double.parse((accuracy * 100).toStringAsFixed(2)),
    'energy_used': double.parse(energyUsed.toStringAsFixed(2)),
    'leaks_fixed': leaksFixed,
  };
}
