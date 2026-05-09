class CoachingMultiStageRecommendationsV1 {
  const CoachingMultiStageRecommendationsV1();

  Map<String, Object> buildRecommendations({
    required Map<String, Object> style,
    required Map<String, Object> directives,
    required Map<String, Object> contextFilters,
    required Map<String, Object> aggregatedSignals,
    required Map<String, Object> dynamics,
    required Map<String, Object> finalCoachingPackage,
  }) {
    final filters =
        contextFilters['filters'] as Map<String, Object>? ??
        const <String, Object>{};
    final pressureFilter = (filters['pressure_filter'] ?? 'off').toString();
    final tone = (style['tone'] ?? 'neutral').toString();
    final engagementDelta =
        (aggregatedSignals['dynamics']
            as Map<String, Object>?)?['engagement_delta'] ??
        0;
    final engagementDeltaInt = (engagementDelta is num)
        ? engagementDelta.toInt()
        : 0;
    final momentum = (dynamics['momentum'] ?? 'stable').toString();

    final immediateAdvice = _immediateAdvice(pressureFilter, tone);
    final midAdvice = engagementDeltaInt < 0
        ? 'restore engagement with focused pacing'
        : 'maintain balanced pacing';
    final longAdvice =
        momentum.startsWith('-') || momentum == 'falling' || momentum == '-1'
        ? 'rebuild momentum via low-risk sequences'
        : 'sustain momentum and refine patterns';

    final stages = <Map<String, Object>>[
      _stage('immediate', immediateAdvice, <String>[
        'pressure_filter:$pressureFilter',
        'tone:$tone',
      ]),
      _stage('mid', midAdvice, <String>[
        'engagement_delta:$engagementDeltaInt',
      ]),
      _stage('long', longAdvice, <String>['momentum:$momentum']),
    ];

    return Map<String, Object>.unmodifiable(<String, Object>{
      'stages': List<Map<String, Object>>.unmodifiable(stages),
    });
  }

  Map<String, Object> _stage(
    String stage,
    String advice,
    List<String> drivers,
  ) {
    drivers.sort();
    return Map<String, Object>.unmodifiable(<String, Object>{
      'stage': stage,
      'advice': advice,
      'drivers': List<String>.unmodifiable(drivers),
    });
  }

  String _immediateAdvice(String pressureFilter, String tone) {
    if (pressureFilter == 'strong') {
      return 'stabilize decisions, reduce tempo';
    }
    if (tone == 'firm') {
      return 'apply structured discipline';
    }
    return 'follow core heuristic';
  }
}
