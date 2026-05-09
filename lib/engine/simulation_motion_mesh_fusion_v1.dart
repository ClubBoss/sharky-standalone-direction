class MotionMeshFusionV1 {
  const MotionMeshFusionV1({
    this.fusionStability,
    this.fusionBlendWeight,
    this.fusionDriftScale,
    this.fusionSpringScale,
    this.fusionDampScale,
  });

  final double? fusionStability;
  final double? fusionBlendWeight;
  final double? fusionDriftScale;
  final double? fusionSpringScale;
  final double? fusionDampScale;

  Map<String, double>? asReadOnlyMap() {
    final map = <String, double>{};
    if (fusionStability != null) map['fusionStability'] = fusionStability!;
    if (fusionBlendWeight != null)
      map['fusionBlendWeight'] = fusionBlendWeight!;
    if (fusionDriftScale != null) map['fusionDriftScale'] = fusionDriftScale!;
    if (fusionSpringScale != null)
      map['fusionSpringScale'] = fusionSpringScale!;
    if (fusionDampScale != null) map['fusionDampScale'] = fusionDampScale!;
    return map.isEmpty ? null : map;
  }
}
