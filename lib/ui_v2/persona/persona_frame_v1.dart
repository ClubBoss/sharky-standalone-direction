class PersonaFrameV1 {
  const PersonaFrameV1({
    this.surfaceRadius,
    this.surfaceElevation,
    this.surfaceSpacing,
    this.v4RadiusWeight,
    this.v4ElevationWeight,
    this.v4SpacingWeight,
  });

  final double? surfaceRadius;
  final double? surfaceElevation;
  final double? surfaceSpacing;
  final double? v4RadiusWeight;
  final double? v4ElevationWeight;
  final double? v4SpacingWeight;

  Map<String, double> asReadOnlyMap() {
    final map = <String, double>{};
    if (surfaceRadius != null) map['surfaceRadius'] = surfaceRadius!;
    if (surfaceElevation != null) map['surfaceElevation'] = surfaceElevation!;
    if (surfaceSpacing != null) map['surfaceSpacing'] = surfaceSpacing!;
    if (v4RadiusWeight != null) map['v4RadiusWeight'] = v4RadiusWeight!;
    if (v4ElevationWeight != null)
      map['v4ElevationWeight'] = v4ElevationWeight!;
    if (v4SpacingWeight != null) map['v4SpacingWeight'] = v4SpacingWeight!;
    return map;
  }
}
