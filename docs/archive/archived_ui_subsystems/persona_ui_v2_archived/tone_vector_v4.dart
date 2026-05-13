class ToneVectorV4 {
  const ToneVectorV4({
    this.softness,
    this.sharpness,
    this.warmth,
    this.neutrality,
  });

  final double? softness;
  final double? sharpness;
  final double? warmth;
  final double? neutrality;

  Map<String, double?> asReadOnlyMap() => {
    'softness': softness,
    'sharpness': sharpness,
    'warmth': warmth,
    'neutrality': neutrality,
  };
}
