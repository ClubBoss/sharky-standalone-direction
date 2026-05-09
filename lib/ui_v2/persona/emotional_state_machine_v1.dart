class EmotionalStateMachineV1 {
  const EmotionalStateMachineV1();

  Map<String, Object> computeFromSignals(Map<String, Object?> signals) {
    final sanitized = <String, Object?>{
      'tierAEmotionBundle':
          signals['tierAEmotionBundle'] ?? const <String, Object?>{},
      'recentCorrectnessTrend': signals['recentCorrectnessTrend'] ?? 0.0,
      'interactionTempo': signals['interactionTempo'] ?? 'idle',
      'frictionSignals': signals['frictionSignals'] ?? 0.0,
      'hintUsage': signals['hintUsage'] ?? 0.0,
      'v4Active': signals['v4Active'] == true,
    };
    return compute(sanitized);
  }

  Map<String, Object> compute(Map<String, Object?> signals) {
    final tierA =
        signals['tierAEmotionBundle'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final passive =
        tierA['passive'] as Map<String, Object?>? ?? const <String, Object?>{};
    final passiveState = (passive['passiveEmotionState'] ?? 'calm')
        .toString()
        .toLowerCase();

    final correctness = _asDouble(
      signals['recentCorrectnessTrend'] ?? 0.0,
    ).clamp(-1.0, 1.0);
    final tempo = (signals['interactionTempo'] ?? 'idle')
        .toString()
        .toLowerCase();
    final friction = _asDouble(
      signals['frictionSignals'] ?? 0.0,
    ).clamp(0.0, 1.0);
    final hints = _asDouble(signals['hintUsage'] ?? 0.0).clamp(0.0, 1.0);
    final v4Active = signals['v4Active'] == true;

    final momentumScore =
        correctness * 0.6 +
        (tempo == 'fast' ? 0.2 : 0.0) +
        (passiveState == 'focus' ? 0.1 : 0.0);
    final struggleScore =
        (-correctness) * 0.6 +
        friction * 0.3 +
        hints * 0.1 +
        (passiveState == 'tension' ? 0.1 : 0.0);
    final steadyScore = 0.5 - (momentumScore + struggleScore) * 0.1;

    String primary = 'steady';
    if (momentumScore >= struggleScore && momentumScore >= steadyScore) {
      primary = 'momentum';
    } else if (struggleScore >= momentumScore && struggleScore >= steadyScore) {
      primary = 'struggle';
    }

    final focusShift = tempo == 'slow' || hints > 0.4 || passiveState == 'calm';
    final tiltRisk =
        friction > 0.6 || correctness < -0.4 || passiveState == 'tension';

    final baseConfidence = ((correctness + 1.0) * 50).clamp(0.0, 100.0);
    final adjusted =
        (baseConfidence -
                friction * 20 -
                hints * 10 +
                (primary == 'momentum' ? 5 : 0) +
                (v4Active ? 2 : 0))
            .clamp(0.0, 100.0)
            .toInt();

    final secondary = <String, Object>{
      'focus_shift': focusShift,
      'tilt_risk': tiltRisk,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'primary_state': primary,
      'secondary_modifiers': Map<String, Object>.unmodifiable(secondary),
      'confidence': adjusted,
      'summary':
          'primary:$primary focus_shift:$focusShift tilt_risk:$tiltRisk conf:$adjusted',
    });
  }

  Map<String, Object> exportESMBundle(Map<String, Object?> signals) =>
      compute(signals);

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
