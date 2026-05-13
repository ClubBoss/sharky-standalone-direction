class CoachingFinalClosureV1 {
  const CoachingFinalClosureV1();

  Map<String, Object> buildClosure({
    required Map<String, Object> surface,
    required Map<String, Object> multiStage,
    required Map<String, Object> style,
    required Map<String, Object> directives,
    required Map<String, Object> contextFilters,
    required Map<String, Object> finalCoaching,
    required Map<String, Object> signals,
    required Map<String, Object> dynamics,
    required Map<String, Object> consistency,
  }) {
    final bundle = <String, Object>{
      'timing': const <String, Object>{
        'generated_at': 'coaching_closure_v1_fixed',
      },
      'final_surface': surface,
      'multi_stage': multiStage,
      'style': style,
      'directives': directives,
      'context_filters': contextFilters,
      'final_coaching': finalCoaching,
      'signals': signals,
      'dynamics': dynamics,
      'consistency': consistency,
      'summary': 'coaching_closure_v1_ready',
    };
    final ok = consistency['ok'] == true;
    if (!ok) {
      bundle['has_issues'] = true;
    }
    return Map<String, Object>.unmodifiable(bundle);
  }
}
