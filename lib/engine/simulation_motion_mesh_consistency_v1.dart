class MotionMeshConsistencyV1 {
  const MotionMeshConsistencyV1({
    this.descriptorWeight,
    this.vectorWeight,
    this.fusionWeight,
    this.blendReadiness,
  });

  final double? descriptorWeight;
  final double? vectorWeight;
  final double? fusionWeight;
  final double? blendReadiness;

  Map<String, double>? asReadOnlyMap() {
    final map = <String, double>{};
    if (descriptorWeight != null) {
      map['descriptorWeight'] = descriptorWeight!;
    }
    if (vectorWeight != null) map['vectorWeight'] = vectorWeight!;
    if (fusionWeight != null) map['fusionWeight'] = fusionWeight!;
    if (blendReadiness != null) {
      map['blendReadiness'] = blendReadiness!;
    }
    return map.isEmpty ? null : map;
  }
}
