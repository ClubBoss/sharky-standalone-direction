class PersonaV4VisualIdentitySync {
  const PersonaV4VisualIdentitySync({
    this.radius,
    this.elevation,
    this.spacing,
    this.v4RadiusWeight,
    this.v4ElevationWeight,
    this.v4SpacingWeight,
  });

  final double? radius;
  final double? elevation;
  final double? spacing;
  final double? v4RadiusWeight;
  final double? v4ElevationWeight;
  final double? v4SpacingWeight;

  Map<String, double>? asTripleOrNull() {
    final map = <String, double>{};
    if (radius != null) map['radius'] = radius!;
    if (elevation != null) map['elevation'] = elevation!;
    if (spacing != null) map['spacing'] = spacing!;
    return map.isEmpty ? null : map;
  }

  Map<String, double>? asReadOnlyWeightsOrNull() {
    final map = <String, double>{};
    if (v4RadiusWeight != null) map['radiusWeight'] = v4RadiusWeight!;
    if (v4ElevationWeight != null) map['elevationWeight'] = v4ElevationWeight!;
    if (v4SpacingWeight != null) map['spacingWeight'] = v4SpacingWeight!;
    return map.isEmpty ? null : map;
  }
}
