class EmotionPreflightMergedV4 {
  EmotionPreflightMergedV4({
    required this.preflight,
    required this.consistency,
    required this.delta,
  });

  final Map<String, Object?> preflight;
  final Map<String, Object?> consistency;
  final Map<String, Object?> delta;

  Map<String, Object?> asReadOnlyMap() => {
    'preflight': preflight,
    'consistency': consistency,
    'delta': delta,
  };
}
