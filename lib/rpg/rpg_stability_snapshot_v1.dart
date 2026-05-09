import 'dart:collection';

class RpgStabilitySnapshotV1 {
  const RpgStabilitySnapshotV1();

  Map<String, Object> computeSnapshot(
    Map<String, Object?> mastery,
    Map<String, Object?> traits,
  ) {
    final level = mastery['level'] as int? ?? 1;
    final soft = (mastery['soft_progress'] as num?)?.toDouble() ?? 0.0;
    final flattened = <String, double>{};
    traits.forEach((key, value) {
      if (value is num) {
        flattened[key] = value.toDouble();
      } else if (value is Map && value['value'] is num) {
        flattened[key] = (value['value'] as num).toDouble();
      }
    });

    final stableDrivers = <String>[];
    final stableSoft = soft >= -0.05 && soft <= 1.05;
    if (stableSoft) stableDrivers.add('soft_progress:hysteresis_ok');

    final stableLevel = level >= 1;
    if (stableLevel) stableDrivers.add('level:locked');

    var traitsStable = true;
    for (final v in flattened.values) {
      if (v < -1.0 || v > 1.0) {
        traitsStable = false;
        break;
      }
      if (v.abs() > 0.10 && v.abs() < 0.90) {
        traitsStable = traitsStable && true;
      }
    }
    if (traitsStable) stableDrivers.add('traits:within_delta');

    final stableFlag = stableSoft && stableLevel && traitsStable;

    return UnmodifiableMapView<String, Object>({
      'level': level,
      'soft_progress': soft.clamp(0.0, 1.0),
      'traits': UnmodifiableMapView<String, double>(flattened),
      'stable': stableFlag,
      'drivers': List<String>.unmodifiable(stableDrivers),
    });
  }
}
