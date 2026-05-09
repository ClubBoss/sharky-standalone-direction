import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Singleton engine that selects adaptive tone presets based on telemetry.
class EmotionAdaptiveEngine {
  EmotionAdaptiveEngine._();

  static final EmotionAdaptiveEngine _instance = EmotionAdaptiveEngine._();
  static const String _metricsPath = 'ux_feedback_metrics.json';
  static const int _maxEvents = 25;

  static double _momentum = 0.0;
  static final List<_RecordedEvent> _recentEvents = [];
  static Map<String, dynamic>? _metricsCache;

  /// Accessor for the shared singleton instance.
  static EmotionAdaptiveEngine get instance => _instance;

  /// Factory to align with existing singleton patterns.
  factory EmotionAdaptiveEngine() => _instance;

  /// Returns one of `calm`, `motivating`, or `energetic` based on the input
  /// sentiment (range -1..1) and consistency (range 0..1).
  String getAdaptiveTone({double sentiment = 0.0, double consistency = 1.0}) {
    final clampedSentiment = sentiment.clamp(-1.0, 1.0);
    final clampedConsistency = consistency.clamp(0.0, 1.0);
    final combined = (clampedSentiment + _momentum.clamp(-0.4, 0.4)).clamp(
      -1.0,
      1.0,
    );

    if (combined <= -0.3 || clampedConsistency < 0.3) {
      return 'calm';
    }
    if (combined >= 0.6 && clampedConsistency >= 0.5) {
      return 'energetic';
    }
    if (combined >= 0.3 || clampedConsistency >= 0.7) {
      return 'motivating';
    }
    return 'calm';
  }

  /// Rewrites a base reaction string inline with the selected tone preset.
  String getAdaptiveReaction(
    String baseText, {
    double sentiment = 0.0,
    double consistency = 1.0,
  }) {
    final tone = getAdaptiveTone(
      sentiment: sentiment,
      consistency: consistency,
    );
    final trimmed = baseText.trim();

    final sentence = _sentenceCase(trimmed);
    switch (tone) {
      case 'calm':
        return 'Smooth focus: $sentence';
      case 'energetic':
        return 'Let\'s crank it up! $sentence';
      case 'motivating':
      default:
        return 'Coach note: $sentence';
    }
  }

  String _sentenceCase(String input) {
    if (input.isEmpty) return input;
    final first = input[0].toUpperCase();
    final rest = input.length > 1 ? input.substring(1) : '';
    return '$first$rest';
  }

  /// Utility to summarize tone balance for monitoring.
  Map<String, int> sampleToneBalance() {
    final tones = <String, int>{'calm': 0, 'motivating': 0, 'energetic': 0};
    for (final sample in _sampleTelemetry) {
      final tone = getAdaptiveTone(
        sentiment: sample.sentiment,
        consistency: sample.consistency,
      );
      tones[tone] = (tones[tone] ?? 0) + 1;
    }
    return tones;
  }

  /// Records a gameplay event to adjust momentum and feedback logs.
  void recordEvent(String event, double delta) {
    final normalized = delta.isNaN ? 0.0 : (delta / 100.0).clamp(-1.0, 1.0);
    _momentum = (_momentum * 0.85) + normalized * 0.15;
    final sample = _RecordedEvent(
      event: event,
      delta: delta,
      timestamp: DateTime.now(),
    );
    _recentEvents.add(sample);
    if (_recentEvents.length > _maxEvents) {
      _recentEvents.removeAt(0);
    }
    unawaited(_persistMetrics(event, delta));
  }

  double get momentum => _momentum;

  static final _sampleTelemetry = List<_TelemetrySample>.unmodifiable([
    const _TelemetrySample(sentiment: -0.7, consistency: 0.6),
    const _TelemetrySample(sentiment: 0.1, consistency: 0.8),
    const _TelemetrySample(sentiment: 0.65, consistency: 0.9),
    const _TelemetrySample(sentiment: -0.1, consistency: 0.2),
    const _TelemetrySample(sentiment: 0.4, consistency: 0.5),
  ]);

  Future<void> _persistMetrics(String event, double delta) async {
    final metrics = await _loadMetrics();
    final events = Map<String, dynamic>.from(
      metrics['events'] as Map? ?? const {},
    );
    events[event] = (events[event] as num? ?? 0) + 1;
    metrics['events'] = events;
    metrics['events_total'] = (metrics['events_total'] as num? ?? 0) + 1;
    metrics['momentum'] = double.parse(_momentum.toStringAsFixed(3));
    metrics['updated_at'] = DateTime.now().toIso8601String();
    metrics['recent'] = _recentEvents.map((e) => e.toJson()).toList();
    metrics['last_event'] = {'name': event, 'delta': delta};
    await File(
      _metricsPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(metrics));
    _metricsCache = metrics;
  }

  Future<Map<String, dynamic>> _loadMetrics() async {
    if (_metricsCache != null) return _metricsCache!;
    final file = File(_metricsPath);
    if (!await file.exists()) {
      _metricsCache = {
        'events_total': 0,
        'events': {},
        'momentum': 0.0,
        'updated_at': DateTime.now().toIso8601String(),
      };
      return _metricsCache!;
    }
    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        _metricsCache = data;
        return data;
      }
    } catch (_) {}
    _metricsCache = {
      'events_total': 0,
      'events': {},
      'momentum': 0.0,
      'updated_at': DateTime.now().toIso8601String(),
    };
    return _metricsCache!;
  }
}

class _TelemetrySample {
  const _TelemetrySample({required this.sentiment, required this.consistency});

  final double sentiment;
  final double consistency;
}

class _RecordedEvent {
  final String event;
  final double delta;
  final DateTime timestamp;

  const _RecordedEvent({
    required this.event,
    required this.delta,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'event': event,
    'delta': delta,
    'timestamp': timestamp.toIso8601String(),
  };
}
