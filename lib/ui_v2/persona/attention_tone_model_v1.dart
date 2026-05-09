class AttentionToneModelV1 {
  const AttentionToneModelV1();

  String computeAttentionLevel(Map<String, Object?> signals) {
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

    final base = (correctness + 1.0) / 2.0; // 0..1
    final tempoBoost = tempo == 'fast'
        ? 0.15
        : tempo == 'steady'
        ? 0.05
        : -0.05;
    final frictionPenalty = friction * 0.3;
    final hintPenalty = hints * 0.1;

    final score = (base + tempoBoost - frictionPenalty - hintPenalty).clamp(
      0.0,
      1.0,
    );
    if (score >= 0.66) return 'high';
    if (score >= 0.33) return 'medium';
    return 'low';
  }

  String computeTone(Map<String, Object?> signals) {
    final attention = computeAttentionLevel(signals);
    final correctness = _asDouble(
      signals['recentCorrectnessTrend'] ?? 0.0,
    ).clamp(-1.0, 1.0);
    final v4Active = signals['v4Active'] == true;
    if (attention == 'high' && correctness >= 0.2) {
      return 'directive';
    }
    if (correctness < -0.2 || attention == 'low') {
      return 'encouraging';
    }
    return v4Active ? 'directive' : 'neutral';
  }

  Map<String, Object> exportBundleFromSignals(Map<String, Object?> signals) {
    final attention = computeAttentionLevel(signals);
    final tone = computeTone(signals);
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
    final drivers = <String, Object>{
      'correctness': correctness,
      'tempo': tempo,
      'friction': friction,
      'hints': hints,
    };
    return exportBundle(attention: attention, tone: tone, drivers: drivers);
  }

  Map<String, Object> exportBundle({
    required String attention,
    required String tone,
    required Map<String, Object> drivers,
  }) {
    return Map<String, Object>.unmodifiable(<String, Object>{
      'attention_level': attention,
      'tone': tone,
      'drivers': Map<String, Object>.unmodifiable(drivers),
    });
  }

  Map<String, Object> computeStableBundle(
    Map<String, Object> currentBundle,
    Map<String, Object> previousStableBundle,
  ) {
    final currentAttention = (currentBundle['attention_level'] ?? 'medium')
        .toString();
    final currentTone = (currentBundle['tone'] ?? 'neutral').toString();
    final previousAttention =
        (previousStableBundle['attention_level'] ?? currentAttention)
            .toString();
    final previousTone = (previousStableBundle['tone'] ?? currentTone)
        .toString();

    final currentAttentionScore = _attentionScore(currentAttention);
    final previousAttentionScore = _attentionScore(previousAttention);
    final attentionDelta = (currentAttentionScore - previousAttentionScore)
        .abs();
    final stableAttention = attentionDelta < 0.25
        ? previousAttention
        : currentAttention;

    final currentToneScore = _toneScore(currentTone);
    final previousToneScore = _toneScore(previousTone);
    final toneDelta = (currentToneScore - previousToneScore).abs();
    final stableTone = toneDelta < 0.2 ? previousTone : currentTone;

    final stable = <String, Object>{
      'attention_level': stableAttention,
      'tone': stableTone,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'attention_level': currentAttention,
      'tone': currentTone,
      'drivers': currentBundle['drivers'] ?? const <String, Object>{},
      'stable': Map<String, Object>.unmodifiable(stable),
    });
  }

  Map<String, Object> exportAttentionToneBundleV1Full(
    Map<String, Object> rawBundle,
    Map<String, Object> stableBundle,
  ) {
    final rawAttention = (rawBundle['attention_level'] ?? 'medium').toString();
    final stableAttention =
        (stableBundle['stable'] as Map<String, Object>? ?? const {})
            .cast<String, Object?>()['attention_level']
            ?.toString() ??
        rawAttention;
    final rawTone = (rawBundle['tone'] ?? 'neutral').toString();
    final stableTone =
        (stableBundle['stable'] as Map<String, Object>? ?? const {})
            .cast<String, Object?>()['tone']
            ?.toString() ??
        rawTone;

    final deltaAttention =
        (_attentionScore(rawAttention) - _attentionScore(stableAttention))
            .abs();
    final deltaTone = (_toneScore(rawTone) - _toneScore(stableTone)).abs();
    final isConsistent =
        stableAttention == rawAttention && stableTone == rawTone;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'attention': Map<String, Object>.unmodifiable(rawBundle),
      'attention_stable': Map<String, Object>.unmodifiable(stableBundle),
      'tone_level': rawTone,
      'tone_stable': stableTone,
      'integration': Map<String, Object>.unmodifiable(<String, Object>{
        'is_consistent': isConsistent,
        'delta_attention': double.parse(deltaAttention.toStringAsFixed(2)),
        'delta_tone': double.parse(deltaTone.toStringAsFixed(2)),
      }),
    });
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
