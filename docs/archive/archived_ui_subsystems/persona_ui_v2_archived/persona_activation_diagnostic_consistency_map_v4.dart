import 'persona_activation_diagnostic_surface_v4.dart';

class PersonaActivationDiagnosticConsistencyMapV4 {
  const PersonaActivationDiagnosticConsistencyMapV4({
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
    this.isSurfaceConsistent,
    this.isCohesionConsistent,
    this.isMeshConsistent,
    this.isActivationConsistent,
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
  final bool? isSurfaceConsistent;
  final bool? isCohesionConsistent;
  final bool? isMeshConsistent;
  final bool? isActivationConsistent;

  factory PersonaActivationDiagnosticConsistencyMapV4.fromDiagnosticSurface(
    PersonaActivationDiagnosticSurfaceV4 surface,
  ) {
    final surfaceConsistent = surface.surfaceTriple != null;
    final cohesionConsistent = surface.cohesionWeights != null;
    final meshConsistent =
        surface.meshDescriptor != null &&
        surface.meshVector != null &&
        surface.meshFusion != null &&
        surface.meshConsistency != null;
    final activationConsistent =
        surface.finalActivationState != null &&
        surface.confidenceScore != null &&
        surface.activationRationale != null &&
        surface.stagedTier != null;
    return PersonaActivationDiagnosticConsistencyMapV4(
      surfaceTriple: surface.surfaceTriple,
      cohesionWeights: surface.cohesionWeights,
      meshDescriptor: surface.meshDescriptor,
      meshVector: surface.meshVector,
      meshFusion: surface.meshFusion,
      meshConsistency: surface.meshConsistency,
      finalActivationState: surface.finalActivationState,
      confidenceScore: surface.confidenceScore,
      activationRationale: surface.activationRationale,
      stagedTier: surface.stagedTier,
      isSurfaceConsistent: surfaceConsistent,
      isCohesionConsistent: cohesionConsistent,
      isMeshConsistent: meshConsistent,
      isActivationConsistent: activationConsistent,
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
    if (isSurfaceConsistent != null) {
      map['isSurfaceConsistent'] = isSurfaceConsistent;
    }
    if (isCohesionConsistent != null) {
      map['isCohesionConsistent'] = isCohesionConsistent;
    }
    if (isMeshConsistent != null) {
      map['isMeshConsistent'] = isMeshConsistent;
    }
    if (isActivationConsistent != null) {
      map['isActivationConsistent'] = isActivationConsistent;
    }
    return map.isEmpty ? null : map;
  }
}
