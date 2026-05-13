class EmotionEngineTierA {
  const EmotionEngineTierA();

  Map<String, String> computePassive(Map<String, Object?> signals) {
    final focusScore = _score(signals, 'focus');
    final tensionScore = _score(signals, 'tension');
    final calmScore = _score(signals, 'calm');
    final maxScore = [
      focusScore,
      tensionScore,
      calmScore,
    ].reduce((a, b) => a > b ? a : b);
    String state = 'calm';
    if (maxScore == tensionScore) state = 'tension';
    if (maxScore == focusScore) state = 'focus';
    return {'passiveEmotionState': state};
  }

  Map<String, String> exportPassiveState(Map<String, Object?> signals) =>
      Map<String, String>.unmodifiable(computePassive(signals));

  Map<String, Object> computeActive(Map<String, Object?> signals) {
    final passive = computePassive(signals)['passiveEmotionState'] ?? 'calm';
    final correctness = _score(signals, 'recentCorrectnessDelta');
    final tempoRaw = (signals['interactionTempo'] ?? '').toString();
    final tempo = tempoRaw.toLowerCase();
    final friction = _score(signals, 'frictionSignals');
    final v4Active = signals['v4ActivationState'] == true;

    double engagement = 0.0;
    if (passive == 'focus') engagement += 0.4;
    if (tempo == 'fast') engagement += 0.3;
    engagement += (correctness.clamp(-1.0, 1.0) + 1.0) * 0.1;

    double strain = 0.0;
    if (passive == 'tension') strain += 0.4;
    if (tempo == 'idle') strain -= 0.1;
    strain += friction.clamp(0.0, 1.0) * 0.3;
    if (!v4Active) strain += 0.1;

    final neutral = 1.0 - (engagement + strain).clamp(0.0, 1.0);
    String activeState = 'neutral';
    double confidence = neutral;
    if (engagement >= strain && engagement >= neutral) {
      activeState = 'engaged';
      confidence = engagement.clamp(0.0, 1.0);
    } else if (strain >= engagement && strain >= neutral) {
      activeState = 'strained';
      confidence = strain.clamp(0.0, 1.0);
    }

    final drivers = <String, Object>{
      'passive': passive,
      'correctness': correctness,
      'tempo': tempo,
      'friction': friction,
      'v4_active': v4Active,
    };

    return <String, Object>{
      'active_state': activeState,
      'confidence': confidence,
      'drivers': Map<String, Object>.unmodifiable(drivers),
    };
  }

  Map<String, Object> exportActiveState(Map<String, Object?> signals) =>
      Map<String, Object>.unmodifiable(computeActive(signals));

  Map<String, Object> exportStabilityState(Map<String, Object?> signals) {
    final active = computeActive(signals);
    final current = active['active_state']?.toString() ?? 'neutral';
    final previous = (signals['previousActiveState'] ?? 'neutral').toString();
    final confidence = (active['confidence'] as num?)?.toDouble() ?? 0.0;
    final delta = (_score(signals, 'recentCorrectnessDelta')).abs();
    final smoothedConfidence = _plateauConfidence(confidence, delta);
    final stable = _stableState(previous, current, smoothedConfidence);
    final notes = 'prev:$previous curr:$current conf:$smoothedConfidence';
    return Map<String, Object>.unmodifiable({
      'stable_state': stable,
      'previous': previous,
      'confidence': smoothedConfidence,
      'notes': notes,
    });
  }

  double _plateauConfidence(double confidence, double delta) {
    final noiseReduced = delta < 0.05 ? confidence * 0.8 : confidence;
    if (noiseReduced >= 0.9) return 1.0;
    if (noiseReduced >= 0.7) return 0.75;
    if (noiseReduced >= 0.45) return 0.5;
    if (noiseReduced >= 0.2) return 0.25;
    return 0.25;
  }

  String _stableState(String previous, String current, double confidence) {
    if (previous == current) return current;
    if (confidence >= 0.75) return current;
    return previous;
  }

  Map<String, Object> exportTierAEmotionBundle(Map<String, Object?> signals) {
    final passive = exportPassiveState(signals);
    final active = exportActiveState(signals);
    final stability = exportStabilityState(signals);
    final summary = _summarize(passive, active, stability);
    return Map<String, Object>.unmodifiable({
      'passive': passive,
      'active': active,
      'stability': stability,
      'summary': summary,
    });
  }

  String _summarize(
    Map<String, String> passive,
    Map<String, Object> active,
    Map<String, Object> stability,
  ) {
    final passiveState = passive['passiveEmotionState'] ?? 'calm';
    final activeState = active['active_state']?.toString() ?? 'neutral';
    final stableState = stability['stable_state']?.toString() ?? 'neutral';
    final conf = (stability['confidence'] as num?)?.toDouble() ?? 0.0;
    return 'passive:$passiveState active:$activeState stable:$stableState conf:${conf.toStringAsFixed(2)}';
  }

  double _score(Map<String, Object?> signals, String key) {
    final value = signals[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
