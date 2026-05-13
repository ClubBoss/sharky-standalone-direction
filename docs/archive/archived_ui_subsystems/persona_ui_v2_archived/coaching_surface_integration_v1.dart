class CoachingSurfaceIntegrationV1 {
  const CoachingSurfaceIntegrationV1();

  Map<String, Object> buildSurfaceBundle({
    required Map<String, Object> multiStage,
    required Map<String, Object> style,
    required Map<String, Object> directives,
    required Map<String, Object> contextFilters,
  }) {
    final stages = multiStage['stages'] as List<Object>? ?? const <Object>[];
    final stage0 = _stageAdvice(stages, 0);
    final stage1 = _stageAdvice(stages, 1);
    final stage2 = _stageAdvice(stages, 2);

    final filters =
        contextFilters['filters'] as Map<String, Object>? ??
        const <String, Object>{};
    final pressureFilter = (filters['pressure_filter'] ?? 'off').toString();

    final surfaceTitle = pressureFilter == 'strong'
        ? 'High-Pressure Coaching'
        : 'Coaching Guidance';

    final drivers = <String>{};
    for (final stage in stages) {
      if (stage is Map<String, Object>) {
        final d = stage['drivers'] as List<Object>? ?? const <Object>[];
        drivers.addAll(d.map((e) => e.toString()));
      }
    }
    if (style['tone'] != null) drivers.add('tone:${style['tone']}');
    drivers.addAll(filters.entries.map((e) => '${e.key}:${e.value}'));
    drivers.addAll(
      (directives['meta'] as Map<String, Object>? ?? const <String, Object>{})
          .entries
          .map((e) => 'meta_${e.key}:${e.value}'),
    );

    final sortedDrivers = drivers.toList()..sort();

    return Map<String, Object>.unmodifiable(<String, Object>{
      'surface_title': surfaceTitle,
      'immediate_tip': stage0,
      'mid_tip': stage1,
      'long_tip': stage2,
      'drivers': List<String>.unmodifiable(sortedDrivers),
    });
  }

  String _stageAdvice(List<Object> stages, int index) {
    if (index >= stages.length) return '';
    final stage = stages[index];
    if (stage is Map<String, Object>) {
      return stage['advice']?.toString() ?? '';
    }
    return '';
  }
}
