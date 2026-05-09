import 'dart:math' as math;

class GlowHaloEntry {
  const GlowHaloEntry({
    required this.seatIndex,
    required this.radius,
    required this.intensity,
    required this.angle,
  });

  final int seatIndex;
  final double radius;
  final double intensity;
  final double angle;
}

class GlowHaloSpecV1 {
  const GlowHaloSpecV1();

  static List<GlowHaloEntry> buildGlowSpec({
    required int seatCount,
    required int activeSeatIndex,
    required double tableRadius,
    required double scale,
  }) {
    final int safeCount = seatCount < 1 ? 1 : seatCount;
    final int safeActive = (activeSeatIndex < 0 || activeSeatIndex >= safeCount)
        ? -1
        : activeSeatIndex;
    final double safeRadius =
        (tableRadius.isFinite ? tableRadius : 0.0) * scale;
    final double baseRadius = safeRadius * 1.1;
    const double intensityOther = 0.5;
    final List<GlowHaloEntry> entries = <GlowHaloEntry>[];
    final double step = 2 * math.pi / safeCount;
    for (int index = 0; index < safeCount; index++) {
      final double amplitude = safeActive == index ? 1.0 : intensityOther;
      entries.add(
        GlowHaloEntry(
          seatIndex: index,
          radius: baseRadius,
          intensity: amplitude.clamp(0.0, 1.0),
          angle: (-math.pi / 2) + (step * index),
        ),
      );
    }
    return List<GlowHaloEntry>.unmodifiable(entries);
  }
}
