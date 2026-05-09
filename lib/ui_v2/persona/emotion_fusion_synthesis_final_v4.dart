class EmotionFusionSynthesisFinalV4 {
  EmotionFusionSynthesisFinalV4({required this.merged})
    : finalState = _deriveState(merged);

  final Map<String, Object?> merged;
  final String finalState;

  static String _deriveState(Map<String, Object?> merged) {
    final delta = merged['delta'];
    if (delta is Map<String, Object?>) {
      if (delta.values.any((value) => value == true)) {
        return 'fusion_warn';
      }
    }
    return 'fusion_ok';
  }

  Map<String, Object?> asReadOnlyMap() => {
    'merged': merged,
    'finalState': finalState,
  };
}
