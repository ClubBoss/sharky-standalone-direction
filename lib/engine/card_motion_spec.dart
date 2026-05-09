import 'dart:ui' show Offset;

typedef CardMotionSequence = List<CardMotionSpec>;

class CardMotionSpec {
  const CardMotionSpec({
    required this.id,
    required this.from,
    required this.to,
    required this.durationMs,
    required this.delayMs,
    this.burstFactor = 1.0,
    this.smoothFactor = 1.0,
    this.bloomFactor = 0.0,
    this.flipFactor = 0.0,
  });

  final String id;
  final Offset from;
  final Offset to;
  final double durationMs;
  final double delayMs;
  final double burstFactor;
  final double smoothFactor;
  final double bloomFactor;
  final double flipFactor;
}
