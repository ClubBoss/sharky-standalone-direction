import 'persona_sync_v4.dart';

class PreActivationPersonaAuditV4 {
  const PreActivationPersonaAuditV4({
    this.surfaceRadius,
    this.surfaceElevation,
    this.surfaceSpacing,
    this.radiusWeight,
    this.elevationWeight,
    this.spacingWeight,
    this.meshDescriptor,
    this.meshVector,
    this.meshFusion,
    this.meshConsistency,
  });

  final double? surfaceRadius;
  final double? surfaceElevation;
  final double? surfaceSpacing;
  final double? radiusWeight;
  final double? elevationWeight;
  final double? spacingWeight;
  final Map<String, Object?>? meshDescriptor;
  final Map<String, Object?>? meshVector;
  final Map<String, Object?>? meshFusion;
  final Map<String, Object?>? meshConsistency;

  factory PreActivationPersonaAuditV4.fromSync(PersonaSyncV4 sync) {
    return PreActivationPersonaAuditV4(
      surfaceRadius: sync.v4SurfaceRadius,
      surfaceElevation: sync.v4SurfaceElevation,
      surfaceSpacing: sync.v4SurfaceSpacing,
      radiusWeight: sync.v4RadiusWeight,
      elevationWeight: sync.v4ElevationWeight,
      spacingWeight: sync.v4SpacingWeight,
      meshDescriptor: sync.meshDescriptor,
      meshVector: sync.meshVector,
      meshFusion: sync.meshFusion,
      meshConsistency: sync.meshConsistency,
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (surfaceRadius != null) map['surfaceRadius'] = surfaceRadius;
    if (surfaceElevation != null) map['surfaceElevation'] = surfaceElevation;
    if (surfaceSpacing != null) map['surfaceSpacing'] = surfaceSpacing;
    if (radiusWeight != null) map['radiusWeight'] = radiusWeight;
    if (elevationWeight != null) map['elevationWeight'] = elevationWeight;
    if (spacingWeight != null) map['spacingWeight'] = spacingWeight;
    if (meshDescriptor != null) map['meshDescriptor'] = meshDescriptor;
    if (meshVector != null) map['meshVector'] = meshVector;
    if (meshFusion != null) map['meshFusion'] = meshFusion;
    if (meshConsistency != null) map['meshConsistency'] = meshConsistency;
    return map.isEmpty ? null : map;
  }
}
