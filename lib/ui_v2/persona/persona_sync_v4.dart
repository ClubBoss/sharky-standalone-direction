class PersonaSyncV4 {
  const PersonaSyncV4({
    this.v4SurfaceRadius,
    this.v4SurfaceElevation,
    this.v4SurfaceSpacing,
    this.v4RadiusWeight,
    this.v4ElevationWeight,
    this.v4SpacingWeight,
    this.meshDescriptor,
    this.meshVector,
    this.meshFusion,
    this.meshConsistency,
    this.emotion,
  });

  final double? v4SurfaceRadius;
  final double? v4SurfaceElevation;
  final double? v4SurfaceSpacing;
  final double? v4RadiusWeight;
  final double? v4ElevationWeight;
  final double? v4SpacingWeight;
  final Map<String, Object?>? meshDescriptor;
  final Map<String, Object?>? meshVector;
  final Map<String, Object?>? meshFusion;
  final Map<String, Object?>? meshConsistency;
  final Map<String, Object?>? emotion;

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (v4SurfaceRadius != null) map['surfaceRadius'] = v4SurfaceRadius;
    if (v4SurfaceElevation != null)
      map['surfaceElevation'] = v4SurfaceElevation;
    if (v4SurfaceSpacing != null) map['surfaceSpacing'] = v4SurfaceSpacing;
    if (v4RadiusWeight != null) map['radiusWeight'] = v4RadiusWeight;
    if (v4ElevationWeight != null) map['elevationWeight'] = v4ElevationWeight;
    if (v4SpacingWeight != null) map['spacingWeight'] = v4SpacingWeight;
    if (meshDescriptor != null) map['meshDescriptor'] = meshDescriptor;
    if (meshVector != null) map['meshVector'] = meshVector;
    if (meshFusion != null) map['meshFusion'] = meshFusion;
    if (meshConsistency != null) map['meshConsistency'] = meshConsistency;
    if (emotion != null) map['emotion'] = emotion;
    return map.isEmpty ? null : map;
  }
}
