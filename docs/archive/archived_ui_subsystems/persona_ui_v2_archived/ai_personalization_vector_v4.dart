class AIPersonalizationVectorV4 {
  const AIPersonalizationVectorV4({
    this.aggressiveness,
    this.passiveness,
    this.exploitability,
    this.precision,
    this.stability,
    this.adaptation,
  });

  final double? aggressiveness;
  final double? passiveness;
  final double? exploitability;
  final double? precision;
  final double? stability;
  final double? adaptation;

  Map<String, Object?> asReadOnlyMap() => {
    'aggressiveness': aggressiveness,
    'passiveness': passiveness,
    'exploitability': exploitability,
    'precision': precision,
    'stability': stability,
    'adaptation': adaptation,
  };
}
