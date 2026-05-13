class PersonaSurfaceV4Descriptor {
  const PersonaSurfaceV4Descriptor({
    this.surfaceRadius,
    this.surfaceElevation,
    this.surfaceSpacing,
  });

  final double? surfaceRadius;
  final double? surfaceElevation;
  final double? surfaceSpacing;

  double get surfaceRadiusOrDefault => surfaceRadius ?? 0.0;
  double get surfaceElevationOrDefault => surfaceElevation ?? 0.0;
  double get surfaceSpacingOrDefault => surfaceSpacing ?? 0.0;

  Map<String, Object> asReadOnlyMap() => {
    'radius': surfaceRadiusOrDefault,
    'elevation': surfaceElevationOrDefault,
    'spacing': surfaceSpacingOrDefault,
  };
}
