import 'dart:collection';

const Map<String, Object> _kV4FinalCoherencePlaceholder = <String, Object>{
  'ok': true,
  'conflicts': <String>[],
  'drivers': <String>[],
};
const Map<String, Object> _kV4ReadinessPlaceholder = <String, Object>{
  'ok': true,
  'conflicts': <String>[],
  'drivers': <String>[],
};

class MarketingAnalyticsPolishV1 {
  MarketingAnalyticsPolishV1() : _lastSurface = const <String, Object>{};

  Map<String, Object> _lastSurface;

  Map<String, Object> computeAnalyticsSurface({
    required Map<String, Object?> telemetryBundle,
    required Map<String, Object?> funnelRetentionQABundle,
    required Map<String, Object?> personaFusionBundle,
    required Map<String, Object?> coachingFinalBundle,
    Map<String, Object?> coachingSurfaceBundle = const <String, Object?>{},
    Map<String, Object?> coachingDirectivesBundle = const <String, Object?>{},
    Map<String, Object?> personaSignalsBundle = const <String, Object?>{},
    Map<String, Object?> readinessSurfaceBundle = const <String, Object?>{},
    Map<String, Object?> readinessAggregateBundle = const <String, Object?>{},
    Map<String, Object?> finalCoherenceSurface = const <String, Object?>{},
    Map<String, Object?> cohesionReleaseSurface = const <String, Object?>{},
    Map<String, Object?> matSnapshotConsistency = const <String, Object?>{},
    Map<String, Object?> finalVisualPolish = const <String, Object?>{},
    Map<String, Object?> rpgFusionBundle = const <String, Object?>{},
    Map<String, Object?> rpgSnapshotBundle = const <String, Object?>{},
    Map<String, Object?> xpRewardSurfaceBundle = const <String, Object?>{},
  }) {
    final missing = <String>[];
    final warnings = <String>[];
    final drivers = <String>[];
    void addMissing(String key) => missing.add(key);
    void addWarning(String key) => warnings.add(key);
    int _score(bool ok) => ok ? 100 : 0;
    int _clamp(int v) => v.clamp(0, 100);
    int _clampFunnel(num? v) => (v ?? 0).clamp(0, 100).toInt();

    final funnelOk = funnelRetentionQABundle['funnel_surface_ok'] == true;
    final retentionOk = funnelRetentionQABundle['retention_surface_ok'] == true;
    if (!funnelOk) addWarning('funnel_surface');
    if (!retentionOk) addWarning('retention_surface');

    final telemetryRequired = ['funnel', 'engagement', 'persona_influence'];
    for (final key in telemetryRequired) {
      if (!telemetryBundle.containsKey(key)) addMissing('telemetry:$key');
    }

    if (personaFusionBundle.isEmpty) addMissing('persona_fusion');
    if (coachingFinalBundle.isEmpty) addMissing('coaching_final');

    drivers.add('telemetry:${telemetryBundle.keys.length}');
    drivers.add('funnel:${funnelRetentionQABundle.keys.length}');
    drivers.add('persona:${personaFusionBundle.keys.length}');
    drivers.add('coaching:${coachingFinalBundle.keys.length}');
    drivers.sort();

    var score = 100 - missing.length * 10 - warnings.length * 5;
    score = _clamp(score);

    final funnelAlignmentScore = _clamp(
      ((funnelOk ? 1 : 0) + (retentionOk ? 1 : 0)) * 50,
    );
    final retentionPressureScore = _clamp(100 - warnings.length * 10);
    final personaAlignmentScore = _score(personaFusionBundle.isNotEmpty);
    final rpgAlignmentScore = _score(telemetryBundle.isNotEmpty);
    final xpRewardAlignmentScore = _clamp(
      (telemetryBundle.isNotEmpty && coachingFinalBundle.isNotEmpty) ? 100 : 50,
    );
    final funnelRetentionConsistencyScore = _clampFunnel(
      funnelRetentionQABundle['funnel_retention_alignment_score'] as num?,
    );
    final personaCoachingMissing = <String>[];
    if (coachingSurfaceBundle.isEmpty) {
      personaCoachingMissing.add('coaching_surface');
    }
    if (coachingDirectivesBundle.isEmpty) {
      personaCoachingMissing.add('coaching_directives');
    }
    if (personaSignalsBundle.isEmpty) {
      personaCoachingMissing.add('persona_signals');
    }
    if (readinessSurfaceBundle.isEmpty) {
      personaCoachingMissing.add('readiness_surface');
    }
    final personaCoachingAlignmentScore = _clamp(
      100 - personaCoachingMissing.length * 15,
    );
    final rpgFusionOk = rpgFusionBundle.isNotEmpty;
    final rpgSnapshotOk = rpgSnapshotBundle.isNotEmpty;
    final xpRewardOk = xpRewardSurfaceBundle.isNotEmpty;
    final readinessOk =
        readinessAggregateBundle.isNotEmpty &&
        readinessSurfaceBundle.isNotEmpty;
    final coherenceSurfaceOk = finalCoherenceSurface['ok'] == true;
    final cohesionReleaseOk = cohesionReleaseSurface['ok'] == true;
    final matConsistencyOk = matSnapshotConsistency['ok'] == true;
    final finalVisualPolishOk = finalVisualPolish['ok'] == true;
    final finalCoherenceScore = _clamp(
      (score +
              funnelAlignmentScore +
              personaAlignmentScore +
              rpgAlignmentScore +
              xpRewardAlignmentScore +
              funnelRetentionConsistencyScore +
              personaCoachingAlignmentScore +
              (coherenceSurfaceOk ? 100 : 50) +
              (cohesionReleaseOk ? 100 : 50) +
              (matConsistencyOk ? 100 : 50) +
              (finalVisualPolishOk ? 100 : 50)) ~/
          11,
    );

    final conflictFlags = <String>[];
    if (missing.isNotEmpty) conflictFlags.add('missing');
    if (warnings.isNotEmpty) conflictFlags.add('warnings');
    if (score < 50) conflictFlags.add('low_score');
    conflictFlags.sort();
    final crossFunnelFlags = <String>[
      if (funnelRetentionConsistencyScore < 50) 'funnel_retention_low',
      ...conflictFlags,
    ]..sort();

    final personaCoachingConflictFlags = <String>[
      ...personaCoachingMissing,
      if (personaCoachingAlignmentScore < 50) 'persona_coaching_low',
    ]..sort();

    final finalPersonaMarketingConflicts = <String>[
      if (!rpgFusionOk) 'rpg_fusion',
      if (!rpgSnapshotOk) 'rpg_snapshot',
      if (!xpRewardOk) 'xp_reward_surface',
      if (!readinessOk) 'readiness',
      if (!coherenceSurfaceOk) 'final_coherence_surface',
      if (!cohesionReleaseOk) 'cohesion_release_surface',
      if (!matConsistencyOk) 'mat_snapshot_consistency',
      if (!finalVisualPolishOk) 'final_visual_polish',
      ...personaCoachingConflictFlags,
    ]..sort();

    final marketingDrivers = <String>[
      ...drivers,
      ...missing.map((m) => 'missing:$m'),
      ...warnings.map((w) => 'warning:$w'),
    ]..sort();
    final personaCoachingDrivers = <String>[
      'coaching_surface:${coachingSurfaceBundle.length}',
      'coaching_directives:${coachingDirectivesBundle.length}',
      'persona_signals:${personaSignalsBundle.length}',
      'readiness_surface:${readinessSurfaceBundle.length}',
      'readiness_aggregate:${readinessAggregateBundle.length}',
      'final_coherence:${finalCoherenceSurface.length}',
      'cohesion_release:${cohesionReleaseSurface.length}',
      'mat_consistency:${matSnapshotConsistency.length}',
      'final_polish:${finalVisualPolish.length}',
      'rpg_fusion:${rpgFusionBundle.length}',
      'rpg_snapshot:${rpgSnapshotBundle.length}',
      'xp_reward_surface:${xpRewardSurfaceBundle.length}',
    ]..sort();
    final finalMarketingAlignmentOk =
        missing.isEmpty &&
        conflictFlags.isEmpty &&
        personaCoachingConflictFlags.isEmpty;
    final finalMarketingCrossDomainConflicts = <String>[
      if (!finalMarketingAlignmentOk) 'alignment_low',
      ...finalPersonaMarketingConflicts,
    ]..sort();
    final finalMarketingCrossDomainDrivers = <String>[
      ...marketingDrivers,
      ...personaCoachingDrivers,
      ...finalPersonaMarketingConflicts,
    ]..sort();
    final finalMarketingCrossDomainOk =
        finalMarketingCrossDomainConflicts.isEmpty;
    final snapshot = buildFinalSnapshot(
      marketingScore: score,
      personaMarketingScore: _clamp(
        (finalCoherenceScore + personaCoachingAlignmentScore) ~/ 2,
      ),
      funnelScore: funnelAlignmentScore,
      crossDomainScore: finalCoherenceScore,
      conflicts: [...conflictFlags, ...finalPersonaMarketingConflicts],
      drivers: [...marketingDrivers, ...personaCoachingDrivers],
    );
    final finalExport = buildFinalMarketingExport(
      alignmentScore: score,
      personaAlignmentScore: _clamp(
        (finalCoherenceScore + personaCoachingAlignmentScore) ~/ 2,
      ),
      funnelAlignmentScore: funnelAlignmentScore,
      crossDomainAlignmentScore: finalCoherenceScore,
      conflicts: [
        ...conflictFlags,
        ...finalPersonaMarketingConflicts,
        ...finalMarketingCrossDomainConflicts,
      ],
      drivers: [
        ...marketingDrivers,
        ...personaCoachingDrivers,
        ...finalMarketingCrossDomainDrivers,
      ],
      snapshot: snapshot,
    );

    final surface = UnmodifiableMapView<String, Object>({
      'analytics_ok': missing.isEmpty,
      'marketing_score': score,
      'missing_keys': List<String>.unmodifiable(missing),
      'warnings': List<String>.unmodifiable(warnings),
      'drivers': List<String>.unmodifiable(drivers),
      'final_coherence_score': finalCoherenceScore,
      'funnel_alignment_score': funnelAlignmentScore,
      'retention_pressure_score': retentionPressureScore,
      'persona_alignment_score': personaAlignmentScore,
      'rpg_alignment_score': rpgAlignmentScore,
      'xp_reward_alignment_score': xpRewardAlignmentScore,
      'marketing_conflict_flags': List<String>.unmodifiable(conflictFlags),
      'marketing_drivers': List<String>.unmodifiable(marketingDrivers),
      'funnel_retention_consistency_ok': funnelRetentionConsistencyScore >= 50,
      'cross_funnel_marketing_flags': List<String>.unmodifiable(
        crossFunnelFlags,
      ),
      'persona_coaching_alignment_score': personaCoachingAlignmentScore,
      'persona_coaching_conflict_flags': List<String>.unmodifiable(
        personaCoachingConflictFlags,
      ),
      'persona_coaching_drivers': List<String>.unmodifiable(
        personaCoachingDrivers,
      ),
      'final_marketing_alignment_ok': finalMarketingAlignmentOk,
      'final_persona_marketing_coherence_score': _clamp(
        (finalCoherenceScore + personaCoachingAlignmentScore) ~/ 2,
      ),
      'final_persona_marketing_conflict_flags': List<String>.unmodifiable(
        finalPersonaMarketingConflicts,
      ),
      'final_persona_marketing_drivers': List<String>.unmodifiable(
        personaCoachingDrivers,
      ),
      'final_persona_marketing_ok': finalPersonaMarketingConflicts.isEmpty,
      'final_marketing_cross_domain_ok': finalMarketingCrossDomainOk,
      'final_marketing_cross_domain_conflicts': List<String>.unmodifiable(
        finalMarketingCrossDomainConflicts,
      ),
      'final_marketing_cross_domain_drivers': List<String>.unmodifiable(
        finalMarketingCrossDomainDrivers,
      ),
      'final_marketing_snapshot_v1': snapshot,
      'final_marketing_export_v1': finalExport,
      'final_marketing_consolidated_v1': buildFinalConsolidatedLayer(
        marketingSurface: surfacePlaceholder(
          score: score,
          finalCoherenceScore: finalCoherenceScore,
          funnelAlignmentScore: funnelAlignmentScore,
          personaAlignmentScore: personaAlignmentScore,
          rpgAlignmentScore: rpgAlignmentScore,
          xpAlignmentScore: xpRewardAlignmentScore,
        ),
        personaFusion: personaFusionBundle,
        coachingFinal: coachingFinalBundle,
        coachingSurface: coachingSurfaceBundle,
        coachingDirectives: coachingDirectivesBundle,
        personaSignals: personaSignalsBundle,
        rpgFusion: rpgFusionBundle,
        xpRewardSurfaces: xpRewardSurfaceBundle,
        v4ReadinessSurface: readinessSurfaceBundle,
      ),
    });
    _lastSurface = surface;
    return surface;
  }

  Map<String, Object> surfacePlaceholder({
    required int score,
    required int finalCoherenceScore,
    required int funnelAlignmentScore,
    required int personaAlignmentScore,
    required int rpgAlignmentScore,
    required int xpAlignmentScore,
  }) {
    return {
      'marketing_score': score,
      'final_coherence_score': finalCoherenceScore,
      'funnel_alignment_score': funnelAlignmentScore,
      'persona_alignment_score': personaAlignmentScore,
      'rpg_alignment_score': rpgAlignmentScore,
      'xp_reward_alignment_score': xpAlignmentScore,
    };
  }

  Map<String, Object> buildFinalConsolidatedLayer({
    required Map<String, Object> marketingSurface,
    required Map<String, Object?> personaFusion,
    required Map<String, Object?> coachingFinal,
    required Map<String, Object?> coachingSurface,
    required Map<String, Object?> coachingDirectives,
    required Map<String, Object?> personaSignals,
    required Map<String, Object?> rpgFusion,
    required Map<String, Object?> xpRewardSurfaces,
    required Map<String, Object?> v4ReadinessSurface,
  }) {
    int _clamp(int v) => v.clamp(0, 100);
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'final_ok': false,
      'alignment_score': 0,
      'domains': <String, Object>{},
      'conflicts': <String>[],
      'drivers': <String>['final_marketing_consolidation_safe_fallback'],
    };

    final inputs = [
      marketingSurface,
      personaFusion,
      coachingFinal,
      coachingSurface,
      coachingDirectives,
      personaSignals,
      rpgFusion,
      xpRewardSurfaces,
      v4ReadinessSurface,
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;

    final conflicts = <String>[];
    final drivers = <String>[
      'persona:${personaFusion.length}',
      'coaching:${coachingFinal.length}',
      'rpg:${rpgFusion.length}',
      'xp_reward:${xpRewardSurfaces.length}',
    ];

    if (personaFusion.isEmpty || coachingFinal.isEmpty) {
      conflicts.add('persona_coaching_missing');
    }
    if (xpRewardSurfaces.isEmpty || rpgFusion.isEmpty) {
      conflicts.add('xp_rpg_missing');
    }
    if (v4ReadinessSurface.isEmpty) {
      conflicts.add('readiness_missing');
    }

    final score = _clamp(
      ((marketingSurface['marketing_score'] as num? ?? 0).toInt() +
              (marketingSurface['final_coherence_score'] as num? ?? 0).toInt() +
              (marketingSurface['funnel_alignment_score'] as num? ?? 0)
                  .toInt() +
              (marketingSurface['persona_alignment_score'] as num? ?? 0)
                  .toInt()) ~/
          4,
    );
    conflicts.sort();
    drivers.sort();
    final ok = conflicts.isEmpty && score >= 70;

    final domains = <String, Object>{
      'marketing': marketingSurface,
      'persona': personaFusion,
      'coaching': coachingFinal,
      'coaching_surface': coachingSurface,
      'coaching_directives': coachingDirectives,
      'persona_signals': personaSignals,
      'rpg': rpgFusion,
      'xp_reward': xpRewardSurfaces,
      'readiness': v4ReadinessSurface,
    };

    return {
      'final_ok': ok,
      'alignment_score': score,
      'domains': Map<String, Object>.unmodifiable(domains),
      'conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(drivers),
    };
  }

  Map<String, Object> buildFinalMarketingExport({
    required int alignmentScore,
    required int personaAlignmentScore,
    required int funnelAlignmentScore,
    required int crossDomainAlignmentScore,
    required List<String> conflicts,
    required List<String> drivers,
    required Map<String, Object> snapshot,
  }) {
    return UnmodifiableMapView<String, Object>({
      'alignment_score': alignmentScore,
      'persona_alignment_score': personaAlignmentScore,
      'funnel_alignment_score': funnelAlignmentScore,
      'cross_domain_alignment_score': crossDomainAlignmentScore,
      'conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    });
  }

  Map<String, Object> buildFinalSnapshot({
    required int marketingScore,
    required int personaMarketingScore,
    required int funnelScore,
    required int crossDomainScore,
    List<String> conflicts = const <String>[],
    List<String> drivers = const <String>[],
  }) {
    int _clamp(int v) => v.clamp(0, 100);
    final safeConflicts = List<String>.from(conflicts)..sort();
    final safeDrivers = List<String>.from(drivers)..sort();
    return UnmodifiableMapView<String, Object>({
      'marketing_alignment_score': _clamp(marketingScore),
      'persona_marketing_alignment_score': _clamp(personaMarketingScore),
      'funnel_alignment_score': _clamp(funnelScore),
      'cross_domain_alignment_score': _clamp(crossDomainScore),
      'conflicts': List<String>.unmodifiable(safeConflicts),
      'drivers': List<String>.unmodifiable(safeDrivers),
    });
  }

  Map<String, Object> exportAnalyticsSurfaceV1() =>
      UnmodifiableMapView<String, Object>(_lastSurface);

  static Map<String, Object> buildFinalMarketingQA({
    required Map<String, Object> marketingSurface,
    required Map<String, Object> personaFusion,
    required Map<String, Object> coachingFinal,
    required Map<String, Object> coachingSurface,
    required Map<String, Object> coachingDirectives,
    required Map<String, Object> personaSignals,
    required Map<String, Object> rpgFusion,
    required Map<String, Object> xpRewardSurface,
    required Map<String, Object> readinessSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    bool _asciiMap(Map<dynamic, dynamic> m) {
      for (final entry in m.entries) {
        final k = entry.key.toString();
        if (!_isAscii(k)) return false;
        final v = entry.value;
        if (v is String && !_isAscii(v)) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'final_marketing_qa_ok': false,
      'marketing_qa_score': 0,
      'marketing_qa_conflicts': <String>[],
      'marketing_qa_drivers': <String>['final_marketing_qa_safe_fallback'],
      'final_marketing_snapshot': <String, Object>{},
    };

    final inputs = [
      marketingSurface,
      personaFusion,
      coachingFinal,
      coachingSurface,
      coachingDirectives,
      personaSignals,
      rpgFusion,
      xpRewardSurface,
      readinessSurface,
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;
    if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
      return fallback;
    }

    int _clamp(int v) => v.clamp(0, 100);

    final conflicts = <String>[];
    final drivers = <String>[];

    final personaOk = personaFusion.isNotEmpty && personaSignals.isNotEmpty;
    final coachingOk =
        coachingFinal.isNotEmpty &&
        coachingSurface.isNotEmpty &&
        coachingDirectives.isNotEmpty;
    final rpgOk = rpgFusion.isNotEmpty;
    final xpOk = xpRewardSurface.isNotEmpty;
    final readinessOk = readinessSurface.isNotEmpty;
    final funnelScore =
        (marketingSurface['funnel_alignment_score'] as num?)?.toInt() ?? 0;

    if (!personaOk) conflicts.add('persona_missing');
    if (!coachingOk) conflicts.add('coaching_missing');
    if (!rpgOk) conflicts.add('rpg_missing');
    if (!xpOk) conflicts.add('xp_reward_missing');
    if (!readinessOk) conflicts.add('readiness_missing');
    if (funnelScore < 50) conflicts.add('funnel_low');

    drivers.addAll(<String>[
      'persona:${personaFusion.length}',
      'coaching:${coachingFinal.length}',
      'rpg:${rpgFusion.length}',
      'xp:${xpRewardSurface.length}',
      'readiness:${readinessSurface.length}',
    ]);

    final marketingScore =
        (marketingSurface['marketing_score'] as num?)?.toInt() ?? 0;
    final personaScore = personaOk ? 100 : 0;
    final coachingScore = coachingOk ? 100 : 0;
    final rpgScore = rpgOk ? 100 : 0;
    final xpScore = xpOk ? 100 : 0;
    final readinessScore = readinessOk ? 100 : 0;

    final marketingQaScore = _clamp(
      (marketingScore +
              personaScore +
              coachingScore +
              rpgScore +
              xpScore +
              readinessScore +
              funnelScore) ~/
          7,
    );

    conflicts.sort();
    drivers.sort();
    final ok = conflicts.isEmpty && marketingQaScore >= 70;

    final snapshotEntries = <String, Object>{
      'marketing_score': _clamp(marketingScore),
      'persona_score': personaScore,
      'coaching_score': coachingScore,
      'rpg_score': rpgScore,
      'xp_score': xpScore,
      'readiness_score': readinessScore,
      'funnel_score': _clamp(funnelScore),
    };
    final snapshot = Map<String, Object>.unmodifiable(snapshotEntries);

    return Map<String, Object>.unmodifiable(<String, Object>{
      'final_marketing_qa_ok': ok,
      'marketing_qa_score': marketingQaScore,
      'marketing_qa_conflicts': List<String>.unmodifiable(conflicts),
      'marketing_qa_drivers': List<String>.unmodifiable(drivers),
      'final_marketing_snapshot': snapshot,
    });
  }

  static Map<String, Object> buildFinalMarketingReadinessV1({
    required Map<String, Object> marketingSurface,
    required Map<String, Object> marketingSnapshot,
    required Map<String, Object> funnelRetentionBundle,
    required Map<String, Object> personaSignals,
    required Map<String, Object> coachingFinal,
    required Map<String, Object> coachingSurface,
    required Map<String, Object> xpRewardSurface,
    required Map<String, Object> rpgSurface,
    required Map<String, Object> v4ReadinessSurface,
    required Map<String, Object> finalRegressionPlatformSnapshot,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    bool _asciiMap(Map<dynamic, dynamic> m) {
      for (final entry in m.entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) return false;
        final v = entry.value;
        if (v is String && !_isAscii(v)) return false;
      }
      return true;
    }

    List<String> _asciiList(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s)) out.add(s);
      }
      out.sort();
      return out;
    }

    const fallback = <String, Object>{
      'final_marketing_readiness_ok': false,
      'alignment_score': 0,
      'cross_domain_conflicts': <String>[],
      'drivers': <String>['final_marketing_readiness_safe_fallback'],
      'snapshot': <String, Object>{},
    };

    final inputs = [
      marketingSurface,
      marketingSnapshot,
      funnelRetentionBundle,
      personaSignals,
      coachingFinal,
      coachingSurface,
      xpRewardSurface,
      rpgSurface,
      v4ReadinessSurface,
      finalRegressionPlatformSnapshot,
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;
    if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
      return fallback;
    }

    int _clamp(int v) => v.clamp(0, 100);

    final missingSections = <String>[];
    void requireSection(String name, Map<dynamic, dynamic> m) {
      if (m.isEmpty) missingSections.add(name);
    }

    requireSection('marketing_surface', marketingSurface);
    requireSection('marketing_snapshot', marketingSnapshot);
    requireSection('funnel_retention', funnelRetentionBundle);
    requireSection('persona_signals', personaSignals);
    requireSection('coaching_final', coachingFinal);
    requireSection('coaching_surface', coachingSurface);
    requireSection('xp_reward_surface', xpRewardSurface);
    requireSection('rpg_surface', rpgSurface);
    requireSection('v4_readiness_surface', v4ReadinessSurface);
    requireSection(
      'final_regression_platform',
      finalRegressionPlatformSnapshot,
    );

    final conflicts = <String>[
      ..._asciiList(marketingSurface['marketing_conflict_flags']),
      ..._asciiList(finalRegressionPlatformSnapshot['conflict_flags']),
    ]..sort();

    final score = _clamp(
      100 -
          (missingSections.length * 5) -
          (_asciiList(marketingSurface['marketing_conflict_flags']).length * 2),
    );

    final drivers = <String>[
      ..._asciiList(marketingSurface['marketing_drivers']),
      ..._asciiList(finalRegressionPlatformSnapshot['drivers']),
      ...missingSections.map((e) => 'missing:$e'),
    ]..sort();

    bool _boolOk(Object? v) => v == true;
    final ok =
        missingSections.isEmpty &&
        conflicts.isEmpty &&
        _boolOk(marketingSurface['analytics_ok']) &&
        _boolOk(v4ReadinessSurface['ok']) &&
        _boolOk(
          finalRegressionPlatformSnapshot['final_regression_platform_ok'],
        );

    Map<String, Object> _orderMap(Map<String, Object?> input) {
      final entries =
          input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      final ordered = <String, Object>{};
      for (final entry in entries) {
        final value = entry.value;
        if (value is Map) {
          ordered[entry.key] = _orderMap(value.cast<String, Object?>());
        } else if (value is Iterable) {
          final list = value.map<Object>((v) {
            if (v is Map) return _orderMap(v.cast<String, Object?>());
            if (v is num) return v.toDouble().clamp(0, 100);
            if (v is String && !_isAscii(v)) return '';
            return v as Object? ?? '';
          }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
          ordered[entry.key] = list;
        } else if (value is num) {
          ordered[entry.key] = value.toDouble().clamp(0, 100);
        } else if (value is String) {
          ordered[entry.key] = _isAscii(value) ? value : '';
        } else {
          ordered[entry.key] = value ?? '';
        }
      }
      return ordered;
    }

    final snapshot = _orderMap(<String, Object>{
      'marketing_surface': marketingSurface,
      'marketing_snapshot': marketingSnapshot,
      'funnel_retention_bundle': funnelRetentionBundle,
      'persona_signals': personaSignals,
      'coaching_final': coachingFinal,
      'coaching_surface': coachingSurface,
      'xp_reward_surface': xpRewardSurface,
      'rpg_surface': rpgSurface,
      'v4_readiness_surface': v4ReadinessSurface,
      'final_regression_platform_snapshot': finalRegressionPlatformSnapshot,
    });

    return Map<String, Object>.unmodifiable(<String, Object>{
      'final_marketing_readiness_ok': ok,
      'alignment_score': score,
      'cross_domain_conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    });
  }

  static Map<String, Object> buildFinalMarketingOnboardingCoherenceV1({
    required Map<String, Object> finalMarketingOnboarding,
    required Map<String, Object> finalMarketingReadiness,
    required Map<String, Object> funnelRetention,
    required Map<String, Object> onboardingSurface,
    required Map<String, Object> personaSignals,
    required Map<String, Object> coachingFinal,
    required Map<String, Object> coachingSurface,
    required Map<String, Object> coachingDirectives,
    required Map<String, Object> xpRewardSurface,
    required Map<String, Object> rpgSurface,
    required Map<String, Object> smartPackSurface,
    required Map<String, Object> v4ReadinessSurface,
    required Map<String, Object> coherenceFinalSweep,
    required Map<String, Object> regressionPlatformSnapshot,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    bool _asciiMap(Map<dynamic, dynamic> m) {
      for (final entry in m.entries) {
        final k = entry.key.toString();
        if (!_isAscii(k)) return false;
        final v = entry.value;
        if (v is String && !_isAscii(v)) return false;
      }
      return true;
    }

    List<String> _asciiList(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s)) out.add(s);
      }
      out.sort();
      return out;
    }

    const fallback = <String, Object>{
      'final_marketing_onboarding_coherence_ok': false,
      'alignment_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['final_marketing_onboarding_coherence_safe_fallback'],
      'snapshot': <String, Object>{},
    };

    final inputs = [
      finalMarketingOnboarding,
      finalMarketingReadiness,
      funnelRetention,
      onboardingSurface,
      personaSignals,
      coachingFinal,
      coachingSurface,
      coachingDirectives,
      xpRewardSurface,
      rpgSurface,
      smartPackSurface,
      v4ReadinessSurface,
      coherenceFinalSweep,
      regressionPlatformSnapshot,
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;
    if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
      return fallback;
    }

    int _clamp(int v) => v.clamp(0, 100);

    final missing = <String>[];
    void requireSection(String name, Map<dynamic, dynamic> m) {
      if (m.isEmpty) missing.add(name);
    }

    requireSection('final_marketing_onboarding', finalMarketingOnboarding);
    requireSection('final_marketing_readiness', finalMarketingReadiness);
    requireSection('funnel_retention', funnelRetention);
    requireSection('onboarding_surface', onboardingSurface);
    requireSection('persona_signals', personaSignals);
    requireSection('coaching_final', coachingFinal);
    requireSection('coaching_surface', coachingSurface);
    requireSection('coaching_directives', coachingDirectives);
    requireSection('xp_reward_surface', xpRewardSurface);
    requireSection('rpg_surface', rpgSurface);
    requireSection('smart_pack_surface', smartPackSurface);
    requireSection('v4_readiness_surface', v4ReadinessSurface);
    requireSection('coherence_final_sweep', coherenceFinalSweep);
    requireSection('regression_platform_snapshot', regressionPlatformSnapshot);

    final conflictFlags = <String>[
      ..._asciiList(finalMarketingOnboarding['conflict_flags']),
      ..._asciiList(finalMarketingReadiness['cross_domain_conflicts']),
      ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ]..sort();

    final alignmentScore = _clamp(
      100 - (missing.length * 5) - (conflictFlags.length * 3),
    );

    final drivers = <String>[
      ..._asciiList(finalMarketingOnboarding['drivers']),
      ..._asciiList(finalMarketingReadiness['drivers']),
      ..._asciiList(regressionPlatformSnapshot['drivers']),
      ...missing.map((e) => 'missing:$e'),
    ]..sort();

    bool _ok(Object? v) => v == true;
    final ok =
        missing.isEmpty &&
        conflictFlags.isEmpty &&
        _ok(finalMarketingOnboarding['final_marketing_onboarding_ok']) &&
        _ok(finalMarketingReadiness['final_marketing_readiness_ok']) &&
        _ok(v4ReadinessSurface['ok']) &&
        _ok(regressionPlatformSnapshot['final_regression_platform_ok']);

    Map<String, Object> _orderMap(Map<String, Object?> input) {
      final entries =
          input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      final ordered = <String, Object>{};
      for (final entry in entries) {
        final value = entry.value;
        if (value is Map) {
          ordered[entry.key] = _orderMap(value.cast<String, Object?>());
        } else if (value is Iterable) {
          final list = value.map<Object>((v) {
            if (v is Map) return _orderMap(v.cast<String, Object?>());
            if (v is num) return v.toDouble().clamp(0, 100);
            if (v is String && !_isAscii(v)) return '';
            return v as Object? ?? '';
          }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
          ordered[entry.key] = list;
        } else if (value is num) {
          ordered[entry.key] = value.toDouble().clamp(0, 100);
        } else if (value is String) {
          ordered[entry.key] = _isAscii(value) ? value : '';
        } else {
          ordered[entry.key] = value ?? '';
        }
      }
      return ordered;
    }

    final snapshot = _orderMap(<String, Object>{
      'final_marketing_onboarding': finalMarketingOnboarding,
      'final_marketing_readiness': finalMarketingReadiness,
      'funnel_retention': funnelRetention,
      'onboarding_surface': onboardingSurface,
      'persona_signals': personaSignals,
      'coaching_final': coachingFinal,
      'coaching_surface': coachingSurface,
      'coaching_directives': coachingDirectives,
      'xp_reward_surface': xpRewardSurface,
      'rpg_surface': rpgSurface,
      'smart_pack_surface': smartPackSurface,
      'v4_readiness_surface': v4ReadinessSurface,
      'coherence_final_sweep': coherenceFinalSweep,
      'regression_platform_snapshot': regressionPlatformSnapshot,
    });

    return Map<String, Object>.unmodifiable(<String, Object>{
      'final_marketing_onboarding_coherence_ok': ok,
      'alignment_score': alignmentScore,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    });
  }

  static Map<String, Object> buildFinalMarketingOnboardingV1({
    required Map<String, Object> finalMarketingReadiness,
    required Map<String, Object> onboardingSurface,
    required Map<String, Object> funnelRetentionBundle,
    required Map<String, Object> personaSignals,
    required Map<String, Object> coachingFinal,
    required Map<String, Object> coachingSurface,
    required Map<String, Object> xpRewardSurface,
    required Map<String, Object> rpgSurface,
    required Map<String, Object> v4ReadinessSurface,
    required Map<String, Object> regressionPlatformSnapshot,
    required Map<String, Object> smartPackSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    bool _asciiMap(Map<dynamic, dynamic> m) {
      for (final entry in m.entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) return false;
        final v = entry.value;
        if (v is String && !_isAscii(v)) return false;
      }
      return true;
    }

    List<String> _asciiList(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s)) out.add(s);
      }
      out.sort();
      return out;
    }

    const fallback = <String, Object>{
      'final_marketing_onboarding_ok': false,
      'alignment_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['final_marketing_onboarding_safe_fallback'],
      'snapshot': <String, Object>{},
    };

    final inputs = [
      finalMarketingReadiness,
      onboardingSurface,
      funnelRetentionBundle,
      personaSignals,
      coachingFinal,
      coachingSurface,
      xpRewardSurface,
      rpgSurface,
      v4ReadinessSurface,
      regressionPlatformSnapshot,
      smartPackSurface,
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;
    if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
      return fallback;
    }

    int _clamp(int v) => v.clamp(0, 100);

    final missing = <String>[];
    void requireSection(String name, Map<dynamic, dynamic> m) {
      if (m.isEmpty) missing.add(name);
    }

    requireSection('final_marketing_readiness', finalMarketingReadiness);
    requireSection('onboarding_surface', onboardingSurface);
    requireSection('funnel_retention', funnelRetentionBundle);
    requireSection('persona_signals', personaSignals);
    requireSection('coaching_final', coachingFinal);
    requireSection('coaching_surface', coachingSurface);
    requireSection('xp_reward_surface', xpRewardSurface);
    requireSection('rpg_surface', rpgSurface);
    requireSection('v4_readiness_surface', v4ReadinessSurface);
    requireSection('regression_platform_snapshot', regressionPlatformSnapshot);
    requireSection('smart_pack_surface', smartPackSurface);

    final conflictFlags = <String>[
      ..._asciiList(finalMarketingReadiness['cross_domain_conflicts']),
      ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ]..sort();

    final alignmentScore = _clamp(
      100 - (missing.length * 5) - (conflictFlags.length * 3),
    );

    final drivers = <String>[
      ..._asciiList(finalMarketingReadiness['drivers']),
      ..._asciiList(regressionPlatformSnapshot['drivers']),
      ...missing.map((e) => 'missing:$e'),
    ]..sort();

    bool _ok(Object? v) => v == true;
    final ok =
        missing.isEmpty &&
        conflictFlags.isEmpty &&
        _ok(finalMarketingReadiness['final_marketing_readiness_ok']) &&
        _ok(v4ReadinessSurface['ok']) &&
        _ok(regressionPlatformSnapshot['final_regression_platform_ok']);

    Map<String, Object> _orderMap(Map<String, Object?> input) {
      final entries =
          input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      final ordered = <String, Object>{};
      for (final entry in entries) {
        final value = entry.value;
        if (value is Map) {
          ordered[entry.key] = _orderMap(value.cast<String, Object?>());
        } else if (value is Iterable) {
          final list = value.map<Object>((v) {
            if (v is Map) return _orderMap(v.cast<String, Object?>());
            if (v is num) return v.toDouble().clamp(0, 100);
            if (v is String && !_isAscii(v)) return '';
            return v as Object? ?? '';
          }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
          ordered[entry.key] = list;
        } else if (value is num) {
          ordered[entry.key] = value.toDouble().clamp(0, 100);
        } else if (value is String) {
          ordered[entry.key] = _isAscii(value) ? value : '';
        } else {
          ordered[entry.key] = value ?? '';
        }
      }
      return ordered;
    }

    final snapshot = _orderMap(<String, Object>{
      'final_marketing_readiness': finalMarketingReadiness,
      'onboarding_surface': onboardingSurface,
      'funnel_retention_bundle': funnelRetentionBundle,
      'persona_signals': personaSignals,
      'coaching_final': coachingFinal,
      'coaching_surface': coachingSurface,
      'xp_reward_surface': xpRewardSurface,
      'rpg_surface': rpgSurface,
      'v4_readiness_surface': v4ReadinessSurface,
      'regression_platform_snapshot': regressionPlatformSnapshot,
      'smart_pack_surface': smartPackSurface,
    });

    return Map<String, Object>.unmodifiable(<String, Object>{
      'final_marketing_onboarding_ok': ok,
      'alignment_score': alignmentScore,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    });
  }
}

Map<String, Object> buildFinalMarketingOnboardingSyncV1({
  required Map<String, Object> marketingReadiness,
  required Map<String, Object> marketingOnboarding,
  required Map<String, Object> marketingCoherence,
  required Map<String, Object> v4Readiness,
  required Map<String, Object> v4Coherence,
  required Map<String, Object> regressionPlatform,
  required Map<String, Object> releaseAssemblyHarmonization,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardFinal,
  required Map<String, Object> rpgStability,
  required Map<String, Object> personaSignals,
  required Map<String, Object> coachingFinal,
}) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  bool _asciiMap(Map<dynamic, dynamic> m) {
    for (final entry in m.entries) {
      final key = entry.key.toString();
      if (!_isAscii(key)) return false;
      final v = entry.value;
      if (v is String && !_isAscii(v)) return false;
    }
    return true;
  }

  List<String> _asciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

  const fallback = <String, Object>{
    'marketing_onboarding_sync': <String, Object>{},
    'sync_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_marketing_onboarding_sync_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    marketingReadiness,
    marketingOnboarding,
    marketingCoherence,
    v4Readiness,
    v4Coherence,
    regressionPlatform,
    releaseAssemblyHarmonization,
    smartPackSurface,
    xpRewardFinal,
    rpgStability,
    personaSignals,
    coachingFinal,
  ];
  if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString())))) {
    return fallback;
  }
  if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
    return fallback;
  }

  int _clamp(int v) => v.clamp(0, 100);

  final conflictFlags = <String>[
    ..._asciiList(marketingReadiness['cross_domain_conflicts']),
    ..._asciiList(marketingOnboarding['conflict_flags']),
    ..._asciiList(marketingCoherence['conflict_flags']),
    ..._asciiList(v4Readiness['conflicts']),
    ..._asciiList(v4Coherence['conflicts']),
    ..._asciiList(regressionPlatform['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(marketingReadiness['drivers']),
    ..._asciiList(marketingOnboarding['drivers']),
    ..._asciiList(marketingCoherence['drivers']),
    ..._asciiList(regressionPlatform['drivers']),
    ..._asciiList(releaseAssemblyHarmonization['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(marketingReadiness['final_marketing_readiness_ok']) &&
      _ok(marketingOnboarding['final_marketing_onboarding_ok']) &&
      _ok(marketingCoherence['final_marketing_onboarding_coherence_ok']) &&
      _ok(v4Readiness['ok']) &&
      _ok(v4Coherence['ok']) &&
      _ok(regressionPlatform['final_regression_platform_ok']);

  Map<String, Object> _orderMap(Map<String, Object?> input) {
    final entries =
        input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final ordered = <String, Object>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value is Map) {
        ordered[entry.key] = _orderMap(value.cast<String, Object?>());
      } else if (value is Iterable) {
        final list = value.map<Object>((v) {
          if (v is Map) return _orderMap(v.cast<String, Object?>());
          if (v is num) return v.toDouble().clamp(0, 100);
          if (v is String && !_isAscii(v)) return '';
          return v as Object? ?? '';
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is num) {
        ordered[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else {
        ordered[entry.key] = value ?? '';
      }
    }
    return ordered;
  }

  final snapshot = _orderMap(<String, Object>{
    'marketing_readiness': marketingReadiness,
    'marketing_onboarding': marketingOnboarding,
    'marketing_coherence': marketingCoherence,
    'v4_readiness': v4Readiness,
    'v4_coherence': v4Coherence,
    'regression_platform': regressionPlatform,
    'release_assembly_harmonization': releaseAssemblyHarmonization,
    'smart_pack_surface': smartPackSurface,
    'xp_reward_final': xpRewardFinal,
    'rpg_stability': rpgStability,
    'persona_signals': personaSignals,
    'coaching_final': coachingFinal,
  });

  return <String, Object>{
    'marketing_onboarding_sync': ok,
    'sync_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalMarketingOnboardingCoherenceV2({
  required Map<String, Object> marketingOnboardingSync,
  required Map<String, Object> marketingReadiness,
  required Map<String, Object> marketingOnboarding,
  required Map<String, Object> marketingCoherence,
  required Map<String, Object> v4Readiness,
  required Map<String, Object> v4FinalCoherence,
  required Map<String, Object> releaseAssembly,
  required Map<String, Object> releaseAssemblyStability,
  required Map<String, Object> releaseAssemblyHarmonization,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardFinalSurface,
  required Map<String, Object> rpgStabilitySnapshot,
  required Map<String, Object> personaSignals,
  required Map<String, Object> coachingFinal,
  required Map<String, Object> coachingSurface,
}) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  bool _asciiMap(Map<dynamic, dynamic> m) {
    for (final entry in m.entries) {
      final k = entry.key.toString();
      if (!_isAscii(k)) return false;
      final v = entry.value;
      if (v is String && !_isAscii(v)) return false;
    }
    return true;
  }

  List<String> _asciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

  const fallback = <String, Object>{
    'marketing_onboarding_coherence_v2': false,
    'coherence_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_marketing_onboarding_coherence_v2_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    marketingOnboardingSync,
    marketingReadiness,
    marketingOnboarding,
    marketingCoherence,
    v4Readiness,
    v4FinalCoherence,
    releaseAssembly,
    releaseAssemblyStability,
    releaseAssemblyHarmonization,
    regressionPlatformSnapshot,
    smartPackSurface,
    xpRewardFinalSurface,
    rpgStabilitySnapshot,
    personaSignals,
    coachingFinal,
    coachingSurface,
  ];
  if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString())))) {
    return fallback;
  }
  if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
    return fallback;
  }

  int _clamp(int v) => v.clamp(0, 100);

  final conflictFlags = <String>[
    ..._asciiList(marketingOnboardingSync['conflict_flags']),
    ..._asciiList(marketingReadiness['cross_domain_conflicts']),
    ..._asciiList(marketingCoherence['conflict_flags']),
    ..._asciiList(v4Readiness['conflicts']),
    ..._asciiList(v4FinalCoherence['conflicts']),
    ..._asciiList(releaseAssembly['conflict_flags']),
    ..._asciiList(releaseAssemblyHarmonization['conflict_flags']),
    ..._asciiList(releaseAssemblyStability['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(marketingOnboardingSync['drivers']),
    ..._asciiList(marketingReadiness['drivers']),
    ..._asciiList(marketingCoherence['drivers']),
    ..._asciiList(releaseAssembly['drivers']),
    ..._asciiList(releaseAssemblyHarmonization['drivers']),
    ..._asciiList(releaseAssemblyStability['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(marketingOnboardingSync['marketing_onboarding_sync']) &&
      _ok(marketingReadiness['final_marketing_readiness_ok']) &&
      _ok(marketingOnboarding['final_marketing_onboarding_ok']) &&
      _ok(marketingCoherence['final_marketing_onboarding_coherence_ok']) &&
      _ok(v4Readiness['ok']) &&
      _ok(v4FinalCoherence['ok']) &&
      _ok(releaseAssembly['release_assembly_ok']) &&
      _ok(releaseAssemblyHarmonization['release_assembly_harmonization']) &&
      _ok(releaseAssemblyStability['release_assembly_stability']) &&
      _ok(regressionPlatformSnapshot['final_regression_platform_ok']);

  Map<String, Object> _orderMap(Map<String, Object?> input) {
    final entries =
        input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final ordered = <String, Object>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value is Map) {
        ordered[entry.key] = _orderMap(value.cast<String, Object?>());
      } else if (value is Iterable) {
        final list = value.map<Object>((v) {
          if (v is Map) return _orderMap(v.cast<String, Object?>());
          if (v is num) return v.toDouble().clamp(0, 100);
          if (v is String && !_isAscii(v)) return '';
          return v as Object? ?? '';
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is num) {
        ordered[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else {
        ordered[entry.key] = value ?? '';
      }
    }
    return ordered;
  }

  final snapshot = _orderMap(<String, Object>{
    'marketing_onboarding_sync': marketingOnboardingSync,
    'marketing_readiness': marketingReadiness,
    'marketing_onboarding': marketingOnboarding,
    'marketing_coherence': marketingCoherence,
    'v4_readiness': v4Readiness,
    'v4_final_coherence': v4FinalCoherence,
    'release_assembly': releaseAssembly,
    'release_assembly_stability': releaseAssemblyStability,
    'release_assembly_harmonization': releaseAssemblyHarmonization,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'smart_pack_surface': smartPackSurface,
    'xp_reward_final_surface': xpRewardFinalSurface,
    'rpg_stability_snapshot': rpgStabilitySnapshot,
    'persona_signals': personaSignals,
    'coaching_final': coachingFinal,
    'coaching_surface': coachingSurface,
  });

  return <String, Object>{
    'marketing_onboarding_coherence_v2': ok,
    'coherence_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalMarketingOnboardingSealV1({
  required Map<String, Object> marketingOnboardingCoherenceV2,
  required Map<String, Object> marketingOnboardingSync,
  required Map<String, Object> marketingOnboarding,
  required Map<String, Object> marketingReadiness,
  required Map<String, Object> marketingCoherence,
  required Map<String, Object> finalMarketingReadiness,
  required Map<String, Object> finalMarketingOnboarding,
  required Map<String, Object> finalMarketingOnboardingCoherence,
  required Map<String, Object> finalMarketingOnboardingSync,
  required Map<String, Object> finalMarketingOnboardingCoherenceV2,
  required Map<String, Object> v4FinalCoherence,
  required Map<String, Object> v4Readiness,
  required Map<String, Object> releaseAssembly,
  required Map<String, Object> releaseAssemblyStability,
  required Map<String, Object> releaseAssemblyHarmonization,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardFinalSurface,
  required Map<String, Object> rpgStabilitySnapshot,
  required Map<String, Object> personaSignals,
  required Map<String, Object> coachingFinal,
  required Map<String, Object> coachingSurface,
}) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  bool _asciiMap(Map<dynamic, dynamic> m) {
    for (final entry in m.entries) {
      final k = entry.key.toString();
      if (!_isAscii(k)) return false;
      final v = entry.value;
      if (v is String && !_isAscii(v)) return false;
    }
    return true;
  }

  List<String> _asciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

  const fallback = <String, Object>{
    'marketing_onboarding_seal_v1': false,
    'seal_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_marketing_onboarding_seal_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    marketingOnboardingCoherenceV2,
    marketingOnboardingSync,
    marketingOnboarding,
    marketingReadiness,
    marketingCoherence,
    finalMarketingReadiness,
    finalMarketingOnboarding,
    finalMarketingOnboardingCoherence,
    finalMarketingOnboardingSync,
    finalMarketingOnboardingCoherenceV2,
    v4FinalCoherence,
    v4Readiness,
    releaseAssembly,
    releaseAssemblyStability,
    releaseAssemblyHarmonization,
    regressionPlatformSnapshot,
    smartPackSurface,
    xpRewardFinalSurface,
    rpgStabilitySnapshot,
    personaSignals,
    coachingFinal,
    coachingSurface,
  ];
  if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString())))) {
    return fallback;
  }
  if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
    return fallback;
  }

  int _clamp(int v) => v.clamp(0, 100);

  final conflictFlags = <String>[
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(marketingOnboardingSync['conflict_flags']),
    ..._asciiList(marketingOnboarding['conflict_flags']),
    ..._asciiList(marketingReadiness['cross_domain_conflicts']),
    ..._asciiList(marketingCoherence['conflict_flags']),
    ..._asciiList(finalMarketingReadiness['cross_domain_conflicts']),
    ..._asciiList(finalMarketingOnboarding['conflict_flags']),
    ..._asciiList(finalMarketingOnboardingCoherence['conflict_flags']),
    ..._asciiList(finalMarketingOnboardingSync['conflict_flags']),
    ..._asciiList(finalMarketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(v4FinalCoherence['conflicts']),
    ..._asciiList(v4Readiness['conflicts']),
    ..._asciiList(releaseAssembly['conflict_flags']),
    ..._asciiList(releaseAssemblyHarmonization['conflict_flags']),
    ..._asciiList(releaseAssemblyStability['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(marketingOnboardingSync['drivers']),
    ..._asciiList(marketingOnboarding['drivers']),
    ..._asciiList(marketingReadiness['drivers']),
    ..._asciiList(marketingCoherence['drivers']),
    ..._asciiList(finalMarketingReadiness['drivers']),
    ..._asciiList(finalMarketingOnboarding['drivers']),
    ..._asciiList(finalMarketingOnboardingCoherence['drivers']),
    ..._asciiList(finalMarketingOnboardingSync['drivers']),
    ..._asciiList(finalMarketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(releaseAssembly['drivers']),
    ..._asciiList(releaseAssemblyHarmonization['drivers']),
    ..._asciiList(releaseAssemblyStability['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(
        marketingOnboardingCoherenceV2['marketing_onboarding_coherence_v2'],
      ) &&
      _ok(marketingOnboardingSync['marketing_onboarding_sync']) &&
      _ok(marketingOnboarding['final_marketing_onboarding_ok']) &&
      _ok(marketingReadiness['final_marketing_readiness_ok']) &&
      _ok(marketingCoherence['final_marketing_onboarding_coherence_ok']) &&
      _ok(finalMarketingReadiness['final_marketing_readiness_ok']) &&
      _ok(finalMarketingOnboarding['final_marketing_onboarding_ok']) &&
      _ok(
        finalMarketingOnboardingCoherence['final_marketing_onboarding_coherence_ok'],
      ) &&
      _ok(finalMarketingOnboardingSync['marketing_onboarding_sync']) &&
      _ok(
        finalMarketingOnboardingCoherenceV2['marketing_onboarding_coherence_v2'],
      ) &&
      _ok(v4FinalCoherence['ok']) &&
      _ok(v4Readiness['ok']) &&
      _ok(releaseAssembly['release_assembly_ok']) &&
      _ok(releaseAssemblyHarmonization['release_assembly_harmonization']) &&
      _ok(releaseAssemblyStability['release_assembly_stability']) &&
      _ok(regressionPlatformSnapshot['final_regression_platform_ok']);

  Map<String, Object> _orderMap(Map<String, Object?> input) {
    final entries =
        input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final ordered = <String, Object>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value is Map) {
        ordered[entry.key] = _orderMap(value.cast<String, Object?>());
      } else if (value is Iterable) {
        final list = value.map<Object>((v) {
          if (v is Map) return _orderMap(v.cast<String, Object?>());
          if (v is num) return v.toDouble().clamp(0, 100);
          if (v is String && !_isAscii(v)) return '';
          return v as Object? ?? '';
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is num) {
        ordered[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else {
        ordered[entry.key] = value ?? '';
      }
    }
    return ordered;
  }

  final snapshot = _orderMap(<String, Object>{
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'marketing_onboarding_sync': marketingOnboardingSync,
    'marketing_onboarding': marketingOnboarding,
    'marketing_readiness': marketingReadiness,
    'marketing_coherence': marketingCoherence,
    'final_marketing_readiness': finalMarketingReadiness,
    'final_marketing_onboarding': finalMarketingOnboarding,
    'final_marketing_onboarding_coherence': finalMarketingOnboardingCoherence,
    'final_marketing_onboarding_sync': finalMarketingOnboardingSync,
    'final_marketing_onboarding_coherence_v2':
        finalMarketingOnboardingCoherenceV2,
    'v4_final_coherence': v4FinalCoherence,
    'v4_readiness': v4Readiness,
    'release_assembly': releaseAssembly,
    'release_assembly_stability': releaseAssemblyStability,
    'release_assembly_harmonization': releaseAssemblyHarmonization,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'smart_pack_surface': smartPackSurface,
    'xp_reward_final_surface': xpRewardFinalSurface,
    'rpg_stability_snapshot': rpgStabilitySnapshot,
    'persona_signals': personaSignals,
    'coaching_final': coachingFinal,
    'coaching_surface': coachingSurface,
  });

  return <String, Object>{
    'marketing_onboarding_seal_v1': ok,
    'seal_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalMarketingOnboardingReleaseBridgeV1({
  required Map<String, Object> marketingOnboardingSealV1,
  required Map<String, Object> marketingOnboardingCoherenceV2,
  required Map<String, Object> finalMarketingOnboardingSync,
  required Map<String, Object> finalMarketingOnboardingCoherence,
  required Map<String, Object> finalMarketingReadiness,
  required Map<String, Object> finalMarketingOnboarding,
  required Map<String, Object> funnelRetentionSurface,
  required Map<String, Object> v4CohesionFinalSweep,
  required Map<String, Object> v4TokenFinalVerification,
  required Map<String, Object> personaV4MatFinalQA,
  required Map<String, Object> finalV4Polish,
  required Map<String, Object> v4VisualCohesionIntegrator,
  required Map<String, Object> finalReleaseAssembly,
  required Map<String, Object> finalReleaseAssemblyStability,
  required Map<String, Object> finalReleaseAssemblyHarmonization,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> xpRewardFinalSurface,
  required Map<String, Object> rpgStabilitySnapshot,
  required Map<String, Object> personaSignals,
  required Map<String, Object> coachingFinal,
  required Map<String, Object> smartPackSurface,
}) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  bool _asciiMap(Map<dynamic, dynamic> m) {
    for (final entry in m.entries) {
      final k = entry.key.toString();
      if (!_isAscii(k)) return false;
      final v = entry.value;
      if (v is String && !_isAscii(v)) return false;
    }
    return true;
  }

  List<String> _asciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

  const fallback = <String, Object>{
    'marketing_onboarding_release_bridge_v1': false,
    'bridge_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>[
      'final_marketing_onboarding_release_bridge_safe_fallback',
    ],
    'snapshot': <String, Object>{},
  };

  final Map<String, Object> v4FinalCoherence = _kV4FinalCoherencePlaceholder;
  final Map<String, Object> v4Readiness = _kV4ReadinessPlaceholder;

  final inputs = [
    marketingOnboardingSealV1,
    marketingOnboardingCoherenceV2,
    finalMarketingOnboardingSync,
    finalMarketingOnboardingCoherence,
    finalMarketingReadiness,
    finalMarketingOnboarding,
    funnelRetentionSurface,
    v4CohesionFinalSweep,
    v4TokenFinalVerification,
    personaV4MatFinalQA,
    finalV4Polish,
    v4VisualCohesionIntegrator,
    finalReleaseAssembly,
    finalReleaseAssemblyStability,
    finalReleaseAssemblyHarmonization,
    regressionPlatformSnapshot,
    xpRewardFinalSurface,
    rpgStabilitySnapshot,
    personaSignals,
    coachingFinal,
    smartPackSurface,
  ];
  if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString())))) {
    return fallback;
  }
  if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
    return fallback;
  }

  int _clamp(int v) => v.clamp(0, 100);

  final conflictFlags = <String>[
    ..._asciiList(marketingOnboardingSealV1['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(finalMarketingOnboardingSync['conflict_flags']),
    ..._asciiList(finalMarketingOnboardingCoherence['conflict_flags']),
    ..._asciiList(finalMarketingReadiness['cross_domain_conflicts']),
    ..._asciiList(finalMarketingOnboarding['conflict_flags']),
    ..._asciiList(funnelRetentionSurface['conflict_flags'] ?? const []),
    ..._asciiList(v4CohesionFinalSweep['conflict_flags'] ?? const []),
    ..._asciiList(v4TokenFinalVerification['conflict_flags'] ?? const []),
    ..._asciiList(personaV4MatFinalQA['conflict_flags'] ?? const []),
    ..._asciiList(finalV4Polish['conflict_flags'] ?? const []),
    ..._asciiList(v4VisualCohesionIntegrator['conflict_flags'] ?? const []),
    ..._asciiList(finalReleaseAssembly['conflict_flags'] ?? const []),
    ..._asciiList(finalReleaseAssemblyStability['conflict_flags'] ?? const []),
    ..._asciiList(
      finalReleaseAssemblyHarmonization['conflict_flags'] ?? const [],
    ),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(marketingOnboardingSealV1['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(finalMarketingOnboardingSync['drivers']),
    ..._asciiList(finalMarketingOnboardingCoherence['drivers']),
    ..._asciiList(finalMarketingReadiness['drivers']),
    ..._asciiList(finalMarketingOnboarding['drivers']),
    ..._asciiList(funnelRetentionSurface['drivers'] ?? const []),
    ..._asciiList(v4VisualCohesionIntegrator['drivers'] ?? const []),
    ..._asciiList(finalReleaseAssembly['drivers'] ?? const []),
    ..._asciiList(finalReleaseAssemblyStability['drivers'] ?? const []),
    ..._asciiList(finalReleaseAssemblyHarmonization['drivers'] ?? const []),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(marketingOnboardingSealV1['marketing_onboarding_seal_v1']) &&
      _ok(
        marketingOnboardingCoherenceV2['marketing_onboarding_coherence_v2'],
      ) &&
      _ok(finalMarketingOnboardingSync['marketing_onboarding_sync']) &&
      _ok(
        finalMarketingOnboardingCoherence['final_marketing_onboarding_coherence_ok'],
      ) &&
      _ok(finalMarketingReadiness['final_marketing_readiness_ok']) &&
      _ok(finalMarketingOnboarding['final_marketing_onboarding_ok']) &&
      _ok(v4FinalCoherence['ok']) &&
      _ok(v4Readiness['ok']) &&
      _ok(finalReleaseAssembly['release_assembly_ok']) &&
      _ok(finalReleaseAssemblyStability['release_assembly_stability']) &&
      _ok(
        finalReleaseAssemblyHarmonization['release_assembly_harmonization'],
      ) &&
      _ok(regressionPlatformSnapshot['final_regression_platform_ok']);

  Map<String, Object> _orderMap(Map<String, Object?> input) {
    final entries =
        input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final ordered = <String, Object>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value is Map) {
        ordered[entry.key] = _orderMap(value.cast<String, Object?>());
      } else if (value is Iterable) {
        final list = value.map<Object>((v) {
          if (v is Map) return _orderMap(v.cast<String, Object?>());
          if (v is num) return v.toDouble().clamp(0, 100);
          if (v is String && !_isAscii(v)) return '';
          return v as Object? ?? '';
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is num) {
        ordered[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else {
        ordered[entry.key] = value ?? '';
      }
    }
    return ordered;
  }

  final snapshot = _orderMap(<String, Object>{
    'marketing_onboarding_seal_v1': marketingOnboardingSealV1,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'final_marketing_onboarding_sync': finalMarketingOnboardingSync,
    'final_marketing_onboarding_coherence': finalMarketingOnboardingCoherence,
    'final_marketing_readiness': finalMarketingReadiness,
    'final_marketing_onboarding': finalMarketingOnboarding,
    'funnel_retention_surface': funnelRetentionSurface,
    'v4_cohesion_final_sweep': v4CohesionFinalSweep,
    'v4_token_final_verification': v4TokenFinalVerification,
    'persona_v4_mat_final': personaV4MatFinalQA,
    'final_v4_polish': finalV4Polish,
    'v4_visual_cohesion_integrator': v4VisualCohesionIntegrator,
    'final_release_assembly': finalReleaseAssembly,
    'final_release_assembly_stability': finalReleaseAssemblyStability,
    'final_release_assembly_harmonization': finalReleaseAssemblyHarmonization,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'xp_reward_final_surface': xpRewardFinalSurface,
    'rpg_stability_snapshot': rpgStabilitySnapshot,
    'persona_signals': personaSignals,
    'coaching_final': coachingFinal,
    'smart_pack_surface': smartPackSurface,
  });

  return <String, Object>{
    'marketing_onboarding_release_bridge_v1': ok,
    'bridge_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}
