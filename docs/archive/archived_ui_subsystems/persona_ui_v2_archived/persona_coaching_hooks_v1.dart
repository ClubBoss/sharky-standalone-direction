class PersonaCoachingHooksV1 {
  const PersonaCoachingHooksV1();

  Map<String, Object> computeHooks({
    required Map<String, Object> heuristics,
    required Map<String, Object> advice,
    required Map<String, Object> explanation,
    required Map<String, Object> aggregatedSignals,
  }) {
    final heuristicsMap =
        heuristics['heuristics'] as Map<String, Object>? ??
        const <String, Object>{};
    final drivers =
        heuristics['drivers'] as Map<String, Object>? ??
        const <String, Object>{};

    final hookList = <Map<String, String>>[];
    _maybeAddHook(
      hookList,
      id: 'p44:hook:01',
      type: 'pacing',
      hint: (heuristicsMap['pacing_hint'] ?? 'normal').toString(),
      normalValue: 'normal',
      suggestionNormal: 'keep current pacing',
      suggestionAlt: 'slow down decision tempo',
      drivers: drivers,
      agg: aggregatedSignals,
    );
    _maybeAddHook(
      hookList,
      id: 'p44:hook:02',
      type: 'risk',
      hint: (heuristicsMap['risk_hint'] ?? 'normal').toString(),
      normalValue: 'normal',
      suggestionNormal: 'maintain standard risk',
      suggestionAlt: 'avoid marginal bluffs',
      drivers: drivers,
      agg: aggregatedSignals,
    );
    _maybeAddHook(
      hookList,
      id: 'p44:hook:03',
      type: 'focus',
      hint: (heuristicsMap['focus_hint'] ?? 'maintain focus').toString(),
      normalValue: 'maintain focus',
      suggestionNormal: 'keep present focus',
      suggestionAlt: 'increase observation focus',
      drivers: drivers,
      agg: aggregatedSignals,
    );
    _maybeAddHook(
      hookList,
      id: 'p44:hook:04',
      type: 'energy',
      hint: (heuristicsMap['energy_hint'] ?? 'stable energy').toString(),
      normalValue: 'stable energy',
      suggestionNormal: 'sustain energy level',
      suggestionAlt: 'reduce cognitive load',
      drivers: drivers,
      agg: aggregatedSignals,
    );
    _maybeAddHook(
      hookList,
      id: 'p44:hook:05',
      type: 'safety',
      hint: (heuristicsMap['safety_hint'] ?? 'normal safety').toString(),
      normalValue: 'normal safety',
      suggestionNormal: 'maintain standard safety',
      suggestionAlt: 'prefer safety-first lines',
      drivers: drivers,
      agg: aggregatedSignals,
    );

    final summary = 'hooks:${hookList.length} pacing:${hookList.isNotEmpty}';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'hooks': List<Map<String, String>>.unmodifiable(hookList),
      'summary': summary,
    });
  }

  void _maybeAddHook(
    List<Map<String, String>> list, {
    required String id,
    required String type,
    required String hint,
    required String normalValue,
    required String suggestionNormal,
    required String suggestionAlt,
    required Map<String, Object> drivers,
    required Map<String, Object> agg,
  }) {
    if (hint == normalValue) {
      return;
    }
    final driverString = _driverLine(drivers, agg);
    list.add(<String, String>{
      'id': id,
      'type': type,
      'trigger': 'hint:$hint',
      'suggestion': hint == normalValue ? suggestionNormal : suggestionAlt,
      'driver': driverString,
    });
  }

  String _driverLine(Map<String, Object> drivers, Map<String, Object> agg) {
    final aggSummary = agg['summary'] ?? '';
    final driverVals = drivers.values.map((e) => e.toString()).join('|');
    return 'drivers:$driverVals agg:$aggSummary';
  }
}
