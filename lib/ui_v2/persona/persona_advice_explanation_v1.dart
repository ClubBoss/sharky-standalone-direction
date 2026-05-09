class PersonaAdviceExplanationV1 {
  const PersonaAdviceExplanationV1();

  Map<String, Object> explain(Map<String, Object> advice) {
    final core =
        advice['advice_core'] as Map<String, Object>? ??
        const <String, Object>{};
    final recs =
        advice['recommendations'] as Map<String, Object>? ??
        const <String, Object>{};

    final mood = (core['mood'] ?? 'neutral').toString();
    final pressure = (core['pressure'] ?? 'stable').toString();
    final engagementRaw = (core['engagement'] as num?)?.toInt() ?? 0;
    final engagement = engagementRaw > 0
        ? 'high'
        : engagementRaw < 0
        ? 'low'
        : 'mid';
    final attention = (core['attention'] ?? 'mid').toString();
    final tone = (core['tone'] ?? 'neutral').toString();

    final explanationCore = <String, String>{
      'mood_reason': _moodReason(mood),
      'pressure_reason': _pressureReason(pressure),
      'engagement_reason': _engagementReason(engagement),
      'attention_reason': _attentionReason(attention),
      'tone_reason': _toneReason(tone),
    };

    final recommendationExplanation = <String, String>{
      'pacing': _explainRec('pacing', recs['pacing']),
      'difficulty': _explainRec('difficulty', recs['difficulty']),
      'focus': _explainRec('focus', recs['focus']),
      'next_action': _explainRec('next_action', recs['next_action']),
    };

    final summary =
        'mood:$mood pressure:$pressure engagement:$engagement attention:$attention tone:$tone';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'explanation_core': Map<String, String>.unmodifiable(explanationCore),
      'recommendation_explanation': Map<String, String>.unmodifiable(
        recommendationExplanation,
      ),
      'summary': summary,
    });
  }

  String _moodReason(String mood) {
    switch (mood) {
      case 'momentum':
        return 'Momentum detected; maintain constructive pace.';
      case 'struggle':
        return 'Struggle state; simplify and reset fundamentals.';
      default:
        return 'Neutral mood; continue steady plan.';
    }
  }

  String _pressureReason(String pressure) {
    switch (pressure) {
      case 'rising':
        return 'Pressure rising; shorten blocks and reduce risk.';
      case 'dropping':
        return 'Pressure dropping; you can sustain or press edge.';
      default:
        return 'Pressure stable; keep normal cadence.';
    }
  }

  String _engagementReason(String engagement) {
    switch (engagement) {
      case 'high':
        return 'Engagement high; you can handle more focused reps.';
      case 'low':
        return 'Engagement low; keep sessions short and confidence-first.';
      default:
        return 'Engagement steady; maintain current load.';
    }
  }

  String _attentionReason(String attention) {
    switch (attention) {
      case 'high':
        return 'Attention high; precision tasks are suitable.';
      case 'low':
        return 'Attention low; simplify tasks and pacing.';
      default:
        return 'Attention mid; balanced tasks are fine.';
    }
  }

  String _toneReason(String tone) {
    switch (tone) {
      case 'directive':
      case 'positive':
        return 'Tone supports direct guidance and firm targets.';
      case 'negative':
        return 'Tone signals caution; emphasize stability.';
      default:
        return 'Tone neutral; mix reinforcement and direction evenly.';
    }
  }

  String _explainRec(String key, Object? value) {
    return '$key:$value';
  }
}
