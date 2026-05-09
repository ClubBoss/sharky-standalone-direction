class CoachingConsistencyReportV1 {
  const CoachingConsistencyReportV1();

  Map<String, Object> buildReport({
    required Map<String, Object> multiStage,
    required Map<String, Object> style,
    required Map<String, Object> directives,
    required Map<String, Object> contextFilters,
    required Map<String, Object> finalCoaching,
    required Map<String, Object> aggregatedSignals,
    required Map<String, Object> dynamics,
    required Map<String, Object> tierA,
    required Map<String, Object> esm,
  }) {
    final issues = <String>{};

    final stages = multiStage['stages'] as List<Object>? ?? const <Object>[];
    final immediate = stages.isNotEmpty && stages.first is Map<String, Object>
        ? (stages.first as Map<String, Object>)
        : const <String, Object>{};
    final immediateAdvice = immediate['advice']?.toString() ?? '';
    if (immediateAdvice.isEmpty) {
      issues.add('missing_immediate_advice');
    }

    final styleValue = style['style']?.toString() ?? '';
    if (styleValue.isEmpty) {
      issues.add('missing_style');
    }

    final directivesCore =
        directives['advice_core'] as Map<String, Object>? ??
        const <String, Object>{};
    if (directivesCore.isEmpty) {
      issues.add('missing_directives');
    }

    final filters =
        contextFilters['filters'] as Map<String, Object>? ??
        const <String, Object>{};
    final pressureFilter = filters['pressure_filter']?.toString() ?? 'off';
    final finalSignals =
        finalCoaching['signals'] as Map<String, Object>? ??
        const <String, Object>{};
    final finalPressure = finalSignals['pressure']?.toString() ?? 'low';
    if (pressureFilter == 'strong' && finalPressure == 'low') {
      issues.add('pressure_mismatch');
    }

    final aggCoreState =
        aggregatedSignals['core_state']?.toString() ??
        (aggregatedSignals['state_core'] as Map<String, Object>? ??
                const <String, Object>{})['core_state']
            ?.toString() ??
        '';
    final dynState = dynamics['stable_primary_state']?.toString() ?? '';
    if (aggCoreState.isNotEmpty &&
        dynState.isNotEmpty &&
        aggCoreState != dynState) {
      issues.add('state_mismatch');
    }

    final sortedIssues = issues.toList()..sort();
    final ok = sortedIssues.isEmpty;

    final checks = <String, bool>{
      'immediate_advice_present': immediateAdvice.isNotEmpty,
      'style_present': styleValue.isNotEmpty,
      'directives_present': directivesCore.isNotEmpty,
      'pressure_consistent':
          !(pressureFilter == 'strong' && finalPressure == 'low'),
      'state_consistent':
          !(aggCoreState.isNotEmpty &&
              dynState.isNotEmpty &&
              aggCoreState != dynState),
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'issues': List<String>.unmodifiable(sortedIssues),
      'checks': Map<String, bool>.unmodifiable(checks),
    });
  }
}
