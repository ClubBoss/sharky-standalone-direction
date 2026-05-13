class MoodVectorV4 {
  const MoodVectorV4({this.calm, this.focus, this.stress, this.confidence});

  final double? calm;
  final double? focus;
  final double? stress;
  final double? confidence;

  Map<String, double?> asReadOnlyMap() {
    return {
      'calm': calm,
      'focus': focus,
      'stress': stress,
      'confidence': confidence,
    };
  }
}
