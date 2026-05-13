class AIPersonalizationSynthesisV4 {
  AIPersonalizationSynthesisV4({required this.seed, required this.vector});

  final Map<String, Object?> seed;
  final Map<String, Object?> vector;
  double get _seedScore => _weightedAverage(seed, 'seed');
  double get _vectorScore => _weightedAverage(vector, 'vector');
  double get _totalScore => 0.6 * _seedScore + 0.4 * _vectorScore;

  static const _seedWeights = [0.4, 0.3, 0.2, 0.1];
  double _weightedAverage(Map<String, Object?> source, String prefix) {
    double total = 0.0;
    for (var i = 0; i < _seedWeights.length; i++) {
      final key = '${prefix}Field${i + 1}';
      final value = source[key];
      total += _toDouble(value) * _seedWeights[i];
    }
    return total;
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return 0.0;
  }

  double get finalSeedLogic => _seedScore * 0.85;
  double get finalVectorLogic => _vectorScore * 0.90;
  double get finalPairLogic => (finalSeedLogic + finalVectorLogic) / 2;
  double get finalTierBLogic => (finalPairLogic * 0.75) + (_totalScore * 0.25);

  Map<String, Object?> asReadOnlyMap() => {
    'seed': seed,
    'vector': vector,
    'synthSeedScore': _seedScore,
    'synthVectorScore': _vectorScore,
    'synthTotalScore': _totalScore,
    'finalSeedLogic': finalSeedLogic,
    'finalVectorLogic': finalVectorLogic,
    'finalPairLogic': finalPairLogic,
    'finalTierBLogic': finalTierBLogic,
  };
}
