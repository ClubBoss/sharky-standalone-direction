import 'dart:collection';

class FunnelVisualQAV1 {
  const FunnelVisualQAV1();

  Map<String, Object> computeFunnelVisualQA(
    Map<String, Object?> funnelBundle,
    Map<String, Object?> v4PolishBundle,
  ) {
    final missing = <String>[];
    final warnings = <String>[];
    final drivers = <String>[];
    final funnel =
        funnelBundle['funnel'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final polish = v4PolishBundle.isEmpty
        ? const <String, Object?>{}
        : v4PolishBundle;

    for (final key in ['name', 'stage', 'value']) {
      if (!funnel.containsKey(key)) missing.add('funnel:$key');
    }
    for (final key in ['spacing', 'radius', 'shadow', 'color']) {
      if (!polish.containsKey(key)) missing.add('polish:$key');
    }
    if (funnel['stage'] is num && (funnel['stage'] as num) > 10) {
      warnings.add('funnel:stage_high');
    }
    drivers.add('funnel:${funnel.length}');
    drivers.add('polish:${polish.length}');
    drivers.sort();
    final alignmentScore = _clamp0To100(
      100 - missing.length * 10 - warnings.length * 5,
    );
    final ok = missing.isEmpty;
    return Map<String, Object>.unmodifiable({
      'ok': ok,
      'missing': List<String>.unmodifiable(missing),
      'warnings': List<String>.unmodifiable(warnings),
      'funnel_retention_alignment_score': alignmentScore,
      'funnel_conflict_flags': List<String>.unmodifiable(
        [...missing, ...warnings]..sort(),
      ),
      'retention_drivers': List<String>.unmodifiable(drivers),
    });
  }

  Map<String, Object> computeRetentionVisualQA(
    Map<String, Object?> telemetryBundle,
    Map<String, Object?> personaBundle,
  ) {
    final missing = <String>[];
    final warnings = <String>[];
    final drivers = <String>[];
    final engagement =
        telemetryBundle['engagement'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final personaCore =
        personaBundle['core'] as Map<String, Object?>? ??
        const <String, Object?>{};
    if (engagement.isEmpty) missing.add('engagement');
    if (personaCore.isEmpty) missing.add('persona_core');
    for (final key in ['delta_accuracy', 'delta_speed', 'friction']) {
      if (!engagement.containsKey(key)) missing.add('engagement:$key');
    }
    if (personaCore.isNotEmpty && engagement.isNotEmpty) {
      final friction = engagement['friction'];
      if (friction is num && friction > 0.8) {
        warnings.add('friction_high');
      }
    }
    drivers.add('engagement:${engagement.length}');
    drivers.add('persona:${personaCore.length}');
    drivers.sort();
    final pressure = (engagement['friction'] as num?)?.toDouble() ?? 0.0;
    final pressureDelta = _clampNeg100To100(((0.5 - pressure) * 100).round());
    final alignmentScore = _clamp0To100(
      100 - missing.length * 10 - warnings.length * 5,
    );
    final ok = missing.isEmpty;
    return Map<String, Object>.unmodifiable({
      'ok': ok,
      'missing': List<String>.unmodifiable(missing),
      'warnings': List<String>.unmodifiable(warnings),
      'funnel_retention_alignment_score': alignmentScore,
      'retention_pressure_delta': pressureDelta,
      'funnel_conflict_flags': List<String>.unmodifiable(
        [...missing, ...warnings]..sort(),
      ),
      'retention_drivers': List<String>.unmodifiable(drivers),
    });
  }

  Map<String, Object> exportFunnelRetentionQA({
    required Map<String, Object?> funnelBundle,
    required Map<String, Object?> v4PolishBundle,
    required Map<String, Object?> telemetryBundle,
    required Map<String, Object?> personaBundle,
  }) {
    final funnelQA = computeFunnelVisualQA(funnelBundle, v4PolishBundle);
    final retentionQA = computeRetentionVisualQA(
      telemetryBundle,
      personaBundle,
    );
    final missing = <String>{
      ...List<String>.from(funnelQA['missing'] as List),
      ...List<String>.from(retentionQA['missing'] as List),
    }.toList()..sort();
    final warnings = <String>[
      ...List<String>.from(funnelQA['warnings'] as List),
      ...List<String>.from(retentionQA['warnings'] as List),
    ]..sort();
    final alignmentScore = _clamp0To100(
      (((funnelQA['funnel_retention_alignment_score'] as num?)?.toInt() ?? 0) +
              ((retentionQA['funnel_retention_alignment_score'] as num?)
                      ?.toInt() ??
                  0)) ~/
          2,
    );
    final pressureDelta = retentionQA['retention_pressure_delta'] as int? ?? 0;
    final conflictFlags = <String>{
      ...List<String>.from(
        funnelQA['funnel_conflict_flags'] as List? ?? const [],
      ),
      ...List<String>.from(
        retentionQA['funnel_conflict_flags'] as List? ?? const [],
      ),
    }.toList()..sort();
    final retentionDrivers = <String>{
      ...List<String>.from(funnelQA['retention_drivers'] as List? ?? const []),
      ...List<String>.from(
        retentionQA['retention_drivers'] as List? ?? const [],
      ),
    }.toList()..sort();
    return UnmodifiableMapView<String, Object>({
      'funnel_surface_ok': funnelQA['ok'] == true,
      'retention_surface_ok': retentionQA['ok'] == true,
      'missing_keys': List<String>.unmodifiable(missing),
      'warnings': List<String>.unmodifiable(warnings),
      'funnel_retention_alignment_score': alignmentScore,
      'retention_pressure_delta': pressureDelta,
      'funnel_conflict_flags': List<String>.unmodifiable(conflictFlags),
      'retention_drivers': List<String>.unmodifiable(retentionDrivers),
    });
  }

  int _clamp0To100(int v) => v.clamp(0, 100);
  int _clampNeg100To100(int v) => v.clamp(-100, 100);
}
