class AnimationTuningEntry {
  const AnimationTuningEntry({
    required this.haloAmplitude,
    required this.glowPulseSpeed,
    required this.cardLift,
    required this.chipWobble,
    required this.ready,
  });

  final double haloAmplitude;
  final double glowPulseSpeed;
  final double cardLift;
  final double chipWobble;
  final bool ready;
}

class AnimationTuningV1 {
  const AnimationTuningV1();

  static AnimationTuningEntry build({
    required double scale,
    required double intensity,
  }) {
    final double safeScale = scale.isFinite && scale >= 0 ? scale : 0.0;
    final double safeIntensity = intensity.isFinite
        ? intensity.clamp(0.0, 1.0)
        : 0.0;
    final double halo = (safeIntensity * 0.6).clamp(0.0, 1.0);
    final double glow = (0.2 + safeIntensity * 0.5).clamp(0.0, 1.0);
    final double lift = safeScale * 2.0;
    final double wobble = safeScale * (safeIntensity * 1.2);
    return AnimationTuningEntry(
      haloAmplitude: halo,
      glowPulseSpeed: glow,
      cardLift: lift,
      chipWobble: wobble,
      ready: true,
    );
  }
}
