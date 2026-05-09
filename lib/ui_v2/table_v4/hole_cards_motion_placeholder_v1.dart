/// Passive placeholder for hole cards motion micro-layer.
class HoleCardsMotionPlaceholderV1 {
  const HoleCardsMotionPlaceholderV1({
    required this.cardA,
    required this.cardB,
    required this.liftFactor,
    required this.v4RuntimeBundle,
  });

  final Object cardA;
  final Object cardB;
  final double liftFactor;
  final Object v4RuntimeBundle;

  Map<String, Object> asReadOnlyMap() {
    final dynamic bundle = v4RuntimeBundle;
    final dynamic qaMap = bundle is Map ? bundle['qa'] : null;
    final bool ready = qaMap is Map && qaMap['consistent'] == true;
    return <String, Object>{
      'lift_a': liftFactor,
      'lift_b': liftFactor,
      'ready': ready,
    };
  }
}
