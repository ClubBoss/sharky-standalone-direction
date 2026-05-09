class PersonaVisualContainerV3 {
  const PersonaVisualContainerV3({
    this.v4SurfaceRadius,
    this.v4SurfaceElevation,
    this.v4SurfaceSpacing,
    this.v4RadiusWeight,
    this.v4ElevationWeight,
    this.v4SpacingWeight,
  });

  final double? v4SurfaceRadius;
  final double? v4SurfaceElevation;
  final double? v4SurfaceSpacing;
  final double? v4RadiusWeight;
  final double? v4ElevationWeight;
  final double? v4SpacingWeight;

  Map<String, double>? asReadOnlyV4VisualState() {
    final map = <String, double>{};
    if (v4SurfaceRadius != null) map['radius'] = v4SurfaceRadius!;
    if (v4SurfaceElevation != null) map['elevation'] = v4SurfaceElevation!;
    if (v4SurfaceSpacing != null) map['spacing'] = v4SurfaceSpacing!;
    if (v4RadiusWeight != null) map['radiusWeight'] = v4RadiusWeight!;
    if (v4ElevationWeight != null) map['elevationWeight'] = v4ElevationWeight!;
    if (v4SpacingWeight != null) map['spacingWeight'] = v4SpacingWeight!;
    return map.isEmpty ? null : map;
  }
}
