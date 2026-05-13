class AIPersonalizationPreflightMergedV4 {
  AIPersonalizationPreflightMergedV4({
    required this.synthesis,
    required this.preflight,
    required this.consistency,
    required this.delta,
  });

  final Map<String, Object?> synthesis;
  final Map<String, Object?> preflight;
  final Map<String, Object?> consistency;
  final Map<String, Object?> delta;

  Map<String, Object?> asReadOnlyMap() => {
    'synthesis': synthesis,
    'preflight': preflight,
    'consistency': consistency,
    'delta': delta,
  };
}
