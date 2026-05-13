class BehavioralDynamicsV1 {
  const BehavioralDynamicsV1();

  Map<String, Object> computeDynamics({
    required Map<String, Object> fusedBehavior,
    required Map<String, Object> esm,
    required Map<String, Object> attentionTone,
  }) {
    final attentionStable =
        ((attentionTone['attention_stable'] as Map<String, Object>?) ??
                const <String, Object>{})['attention_level']
            ?.toString() ??
        'medium';
    final attentionRaw =
        (attentionTone['attention'] as Map<String, Object>?) ??
        const <String, Object>{};
    final attentionRawLevel =
        (attentionRaw['attention_level'] ?? attentionStable).toString();

    final toneStable = (attentionTone['tone_stable'] ?? 'neutral').toString();
    final toneRaw = (attentionTone['tone_level'] ?? toneStable).toString();

    final esmPrimary = (esm['primary_state'] ?? 'steady').toString();
    final pressure = (fusedBehavior['pressure_state'] ?? 'neutral').toString();
    final mood = (fusedBehavior['mood'] ?? esmPrimary).toString();

    final engagementDelta =
        (_attentionScore(attentionStable) - _attentionScore(attentionRawLevel))
            .round();

    final momentum = _computeMomentum(esmPrimary, engagementDelta);
    final tempoShift = _computeTempoShift(mood, pressure);
    final toneTrend = _computeToneTrend(toneRaw, toneStable);
    final stabilityHint = _computeStabilityHint(engagementDelta, toneTrend);

    return Map<String, Object>.unmodifiable(<String, Object>{
      'momentum': momentum,
      'tempo_shift': tempoShift,
      'engagement_delta': engagementDelta,
      'tone_trend': toneTrend,
      'stability_hint': stabilityHint,
      'drivers': Map<String, Object>.unmodifiable(<String, Object>{
        'fused': fusedBehavior,
        'esm': esm,
        'attention_tone': attentionTone,
      }),
    });
  }

  String _computeMomentum(String esmPrimary, int engagementDelta) {
    if (esmPrimary == 'momentum' && engagementDelta >= 0) return 'rising';
    if (esmPrimary == 'struggle' && engagementDelta <= 0) return 'falling';
    return 'stable';
  }

  String _computeTempoShift(String mood, String pressure) {
    if (mood == 'momentum' && pressure == 'neutral') return 'calm->engaged';
    if (mood == 'struggle' && pressure != 'neutral') return 'engaged->strained';
    return 'steady';
  }

  String _computeToneTrend(String toneRaw, String toneStable) {
    if (toneRaw == toneStable) return 'flat';
    if (_toneScore(toneRaw) > _toneScore(toneStable)) return 'up';
    return 'down';
  }

  String _computeStabilityHint(int engagementDelta, String toneTrend) {
    if (engagementDelta == 0 && toneTrend == 'flat') return 'steady';
    if ((engagementDelta).abs() <= 1 && toneTrend != 'down') return 'swing';
    return 'high-variance';
  }

  double _attentionScore(String level) {
    switch (level) {
      case 'high':
        return 1.0;
      case 'medium':
        return 0.5;
      default:
        return 0.0;
    }
  }

  double _toneScore(String tone) {
    switch (tone) {
      case 'directive':
        return 1.0;
      case 'neutral':
        return 0.5;
      default:
        return 0.0;
    }
  }
}
