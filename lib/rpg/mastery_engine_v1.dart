import 'dart:collection';
import 'dart:math';

class MasteryEngineV1 {
  const MasteryEngineV1();

  static const List<int> _xpThresholds = <int>[
    0,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
    1100,
    1200,
    1300,
    1400,
    1500,
    1600,
    1700,
    1800,
    1900,
    2000,
    2100,
    2200,
    2300,
    2400,
    2500,
    2600,
    2700,
    2800,
    2900,
    3000,
    3100,
    3200,
    3300,
    3400,
    3500,
    3600,
    3700,
    3800,
    3900,
    4000,
    4100,
    4200,
    4300,
    4400,
    4500,
    4600,
    4700,
    4800,
    4900,
  ];

  int computeLevel(int xp) {
    if (xp <= 0) return 1;
    for (var i = _xpThresholds.length - 1; i >= 0; i--) {
      if (xp >= _xpThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  double computeSoftProgress(int xp) {
    final level = computeLevel(xp);
    if (level >= _xpThresholds.length) return 1.0;
    final currentFloor = _xpThresholds[level - 1].toDouble();
    final nextFloor = _xpThresholds[level].toDouble();
    final progress =
        (xp.toDouble() - currentFloor) / (nextFloor - currentFloor);
    return progress.clamp(0.0, 1.0);
  }

  Map<String, Object> exportMasteryState(
    int xp,
    Map<String, Object?> personaSignals,
  ) {
    final level = computeLevel(xp);
    final maxLevel = _xpThresholds.length;
    final nextXp = level >= maxLevel
        ? _xpThresholds.last
        : _xpThresholds[level];
    final xpToNext = max(0, nextXp - xp);
    final softProgress = computeSoftProgress(xp);
    final drivers = Map<String, Object>.fromEntries(
      personaSignals.entries.map(
        (e) => MapEntry(e.key.toString(), e.value ?? ''),
      ),
    );

    return UnmodifiableMapView<String, Object>({
      'level': level,
      'xp': xp,
      'xp_to_next': xpToNext,
      'soft_progress': softProgress,
      'traits': const <String>[],
      'drivers': UnmodifiableMapView<String, Object>(drivers),
    });
  }
}
