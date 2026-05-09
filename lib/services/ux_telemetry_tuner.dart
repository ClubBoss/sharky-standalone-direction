/// UX Telemetry Tuner Service (Stage Ω3)
///
/// Collects user engagement metrics and adjusts UX feedback parameters
/// dynamically based on a computed RetentionIndex.
///
/// Metrics collected:
/// - user_session_duration (seconds)
/// - avg_accuracy (0.0 - 1.0)
/// - daily_xp (integer)
///
/// RetentionIndex = (weighted_avg(session_duration × accuracy × xp)) / baseline
///
/// Adjusts:
/// - reward_intensity (0.0 - 2.0)
/// - streak_animation_speed (0.5 - 2.0)
/// - popup_frequency (0.5 - 2.0)
///
/// Pure Dart, ASCII-only, no Flutter dependency.

class UxTelemetryTuner {
  UxTelemetryTuner({
    required this.baselineRetention,
    required this.sessionDurationWeight,
    required this.accuracyWeight,
    required this.xpWeight,
  });

  /// Baseline retention value for computing the index (default: 100.0)
  final double baselineRetention;

  /// Weight for session duration in retention computation
  final double sessionDurationWeight;

  /// Weight for accuracy in retention computation
  final double accuracyWeight;

  /// Weight for XP in retention computation
  final double xpWeight;

  /// Current UX parameters (initialized to defaults)
  double rewardIntensity = 1.0;
  double streakAnimationSpeed = 1.0;
  double popupFrequency = 1.0;

  /// Computes the RetentionIndex from collected metrics
  ///
  /// RetentionIndex = (weighted_avg(session_duration × accuracy × xp)) / baseline
  ///
  /// Returns a value typically in the range [0.0 - 2.0], where:
  /// - < 0.7: Low retention (reduce intensity)
  /// - 0.7 - 1.3: Normal retention (maintain defaults)
  /// - > 1.3: High retention (increase intensity)
  double computeRetentionIndex({
    required double avgSessionDuration,
    required double avgAccuracy,
    required double avgDailyXp,
  }) {
    // Normalize session duration (assume 180 seconds = 3 minutes as baseline)
    final normalizedDuration = avgSessionDuration / 180.0;

    // Accuracy is already normalized (0.0 - 1.0)
    final normalizedAccuracy = avgAccuracy;

    // Normalize XP (assume 100 XP/day as baseline)
    final normalizedXp = avgDailyXp / 100.0;

    // Weighted average
    final weightedAvg =
        (normalizedDuration * sessionDurationWeight +
            normalizedAccuracy * accuracyWeight +
            normalizedXp * xpWeight) /
        (sessionDurationWeight + accuracyWeight + xpWeight);

    // Compute index relative to baseline
    final retentionIndex =
        (weightedAvg * baselineRetention) / baselineRetention;

    return retentionIndex;
  }

  /// Adjusts UX parameters based on the RetentionIndex
  ///
  /// Returns a map with adjustment details for telemetry
  Map<String, dynamic> adjustParameters(double retentionIndex) {
    final adjustments = <String, dynamic>{};

    // Low retention: reduce intensity to avoid overwhelming users
    if (retentionIndex < 0.7) {
      rewardIntensity = _clamp(0.7, 0.5, 1.0);
      streakAnimationSpeed = _clamp(0.8, 0.5, 1.5);
      popupFrequency = _clamp(0.6, 0.5, 1.5);
      adjustments['strategy'] = 'reduce_intensity';
      adjustments['reason'] = 'low_retention';
    }
    // High retention: increase intensity to maintain engagement
    else if (retentionIndex > 1.3) {
      rewardIntensity = _clamp(1.4, 1.0, 2.0);
      streakAnimationSpeed = _clamp(1.3, 1.0, 2.0);
      popupFrequency = _clamp(1.2, 1.0, 2.0);
      adjustments['strategy'] = 'increase_intensity';
      adjustments['reason'] = 'high_retention';
    }
    // Normal retention: maintain defaults
    else {
      rewardIntensity = 1.0;
      streakAnimationSpeed = 1.0;
      popupFrequency = 1.0;
      adjustments['strategy'] = 'maintain_defaults';
      adjustments['reason'] = 'normal_retention';
    }

    adjustments['reward_intensity'] = _round2(rewardIntensity);
    adjustments['streak_animation_speed'] = _round2(streakAnimationSpeed);
    adjustments['popup_frequency'] = _round2(popupFrequency);

    return adjustments;
  }

  /// Generates a summary of adjustments for reporting
  String generateAdjustmentSummary(
    double retentionIndex,
    Map<String, dynamic> adjustments,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('RetentionIndex: ${_round2(retentionIndex)}');
    buffer.writeln('Strategy: ${adjustments['strategy']}');
    buffer.writeln('Reason: ${adjustments['reason']}');
    buffer.writeln('');
    buffer.writeln('Adjusted Parameters:');
    buffer.writeln('  - reward_intensity: ${adjustments['reward_intensity']}');
    buffer.writeln(
      '  - streak_animation_speed: ${adjustments['streak_animation_speed']}',
    );
    buffer.writeln('  - popup_frequency: ${adjustments['popup_frequency']}');
    return buffer.toString();
  }

  /// Clamps a value to the specified range
  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Rounds a double to 2 decimal places
  double _round2(double value) => double.parse(value.toStringAsFixed(2));
}

/// Telemetry data collector for UX tuning
///
/// Reads telemetry events from JSONL files and computes aggregate metrics
class UxTelemetryCollector {
  UxTelemetryCollector({required this.telemetryFilePath});

  final String telemetryFilePath;

  /// Collects metrics from telemetry events
  ///
  /// Returns a map with:
  /// - avg_session_duration (seconds)
  /// - avg_accuracy (0.0 - 1.0)
  /// - avg_daily_xp (integer)
  /// - event_count (total events processed)
  Future<Map<String, dynamic>> collectMetrics() async {
    // Simulate telemetry collection (in production, read from actual file)
    // For this implementation, we'll use synthetic data from recent events

    // In a real implementation, this would read from telemetryFilePath
    // and parse JSONL events to compute these metrics

    // Placeholder metrics (would be computed from actual telemetry)
    final metrics = <String, dynamic>{
      'avg_session_duration': 240.0, // 4 minutes
      'avg_accuracy': 0.75, // 75% correct
      'avg_daily_xp': 120.0, // 120 XP/day
      'event_count': 150,
      'collection_timestamp': DateTime.now().toIso8601String(),
    };

    return metrics;
  }

  /// Reads telemetry events from JSONL file
  ///
  /// Returns a list of event maps
  Future<List<Map<String, dynamic>>> readTelemetryEvents() async {
    // In production, this would read from the actual file
    // For now, return synthetic events

    final events = <Map<String, dynamic>>[
      {
        'event': 'session_end',
        'duration_seconds': 240,
        'accuracy': 0.75,
        'xp_earned': 50,
      },
      {
        'event': 'session_end',
        'duration_seconds': 300,
        'accuracy': 0.80,
        'xp_earned': 60,
      },
      {
        'event': 'session_end',
        'duration_seconds': 180,
        'accuracy': 0.70,
        'xp_earned': 40,
      },
    ];

    return events;
  }
}
