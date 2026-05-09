import 'persona_activation_staged_v4.dart';
import 'persona_sync_v4.dart';

class PersonaActivationFinalBundleV4 {
  const PersonaActivationFinalBundleV4({
    this.surfaceTriple,
    this.cohesionWeights,
    this.meshDescriptor,
    this.meshVector,
    this.meshFusion,
    this.meshConsistency,
    this.finalActivationState,
    this.confidenceScore,
    this.activationRationale,
    this.stagedTier,
  });

  final Map<String, Object?>? surfaceTriple;
  final Map<String, Object?>? cohesionWeights;
  final Map<String, Object?>? meshDescriptor;
  final Map<String, Object?>? meshVector;
  final Map<String, Object?>? meshFusion;
  final Map<String, Object?>? meshConsistency;
  final String? finalActivationState;
  final double? confidenceScore;
  final String? activationRationale;
  final String? stagedTier;

  factory PersonaActivationFinalBundleV4.fromStaged(
    PersonaActivationStagedV4 staged,
    PersonaSyncV4 sync,
  ) {
    final surfaceMap = <String, Object?>{};
    final radius = sync.v4SurfaceRadius;
    final elevation = sync.v4SurfaceElevation;
    final spacing = sync.v4SurfaceSpacing;
    if (radius != null) surfaceMap['radius'] = radius;
    if (elevation != null) surfaceMap['elevation'] = elevation;
    if (spacing != null) surfaceMap['spacing'] = spacing;
    final cohesionMap = <String, Object?>{};
    final radiusWeight = sync.v4RadiusWeight;
    final elevationWeight = sync.v4ElevationWeight;
    final spacingWeight = sync.v4SpacingWeight;
    if (radiusWeight != null) cohesionMap['radiusWeight'] = radiusWeight;
    if (elevationWeight != null) {
      cohesionMap['elevationWeight'] = elevationWeight;
    }
    if (spacingWeight != null) {
      cohesionMap['spacingWeight'] = spacingWeight;
    }
    return PersonaActivationFinalBundleV4(
      surfaceTriple: surfaceMap.isEmpty ? null : surfaceMap,
      cohesionWeights: cohesionMap.isEmpty ? null : cohesionMap,
      meshDescriptor: staged.kernelMeshDescriptor,
      meshVector: staged.kernelMeshVector,
      meshFusion: staged.kernelMeshFusion,
      meshConsistency: staged.kernelMeshConsistency,
      finalActivationState: staged.finalActivationState,
      confidenceScore: staged.confidenceScore,
      activationRationale: staged.rationale,
      stagedTier: staged.stagedTier,
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (surfaceTriple != null) map['surfaceTriple'] = surfaceTriple;
    if (cohesionWeights != null) map['cohesionWeights'] = cohesionWeights;
    if (meshDescriptor != null) map['meshDescriptor'] = meshDescriptor;
    if (meshVector != null) map['meshVector'] = meshVector;
    if (meshFusion != null) map['meshFusion'] = meshFusion;
    if (meshConsistency != null) map['meshConsistency'] = meshConsistency;
    if (finalActivationState != null) {
      map['finalActivationState'] = finalActivationState;
    }
    if (confidenceScore != null) map['confidenceScore'] = confidenceScore;
    if (activationRationale != null) {
      map['activationRationale'] = activationRationale;
    }
    if (stagedTier != null) map['stagedTier'] = stagedTier;
    return map.isEmpty ? null : map;
  }
}
