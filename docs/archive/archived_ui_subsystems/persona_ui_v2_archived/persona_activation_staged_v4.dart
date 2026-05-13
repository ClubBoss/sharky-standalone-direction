import 'persona_activation_confidence_v4.dart';

class PersonaActivationStagedV4 {
  const PersonaActivationStagedV4({
    this.finalActivationState,
    this.confidenceScore,
    this.rationale,
    this.stagedTier,
    this.kernelSurfaceTriple,
    this.kernelCohesionWeights,
    this.kernelMeshDescriptor,
    this.kernelMeshVector,
    this.kernelMeshFusion,
    this.kernelMeshConsistency,
  });

  final String? finalActivationState;
  final double? confidenceScore;
  final String? rationale;
  final String? stagedTier;
  final Map<String, Object?>? kernelSurfaceTriple;
  final Map<String, Object?>? kernelCohesionWeights;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;

  factory PersonaActivationStagedV4.fromConfidence(
    PersonaActivationConfidenceV4 confidence,
  ) {
    final tier =
        confidence.finalActivationState == 'active' &&
            confidence.confidenceScore == 1.0
        ? 'tier2_ready'
        : confidence.finalActivationState == 'partial' ||
              confidence.confidenceScore == 0.5
        ? 'tier1_soft'
        : 'tier0_blocked';
    return PersonaActivationStagedV4(
      finalActivationState: confidence.finalActivationState,
      confidenceScore: confidence.confidenceScore,
      rationale: confidence.rationale,
      stagedTier: tier,
      kernelSurfaceTriple: confidence.kernelSurfaceTriple,
      kernelCohesionWeights: confidence.kernelCohesionWeights,
      kernelMeshDescriptor: confidence.kernelMeshDescriptor,
      kernelMeshVector: confidence.kernelMeshVector,
      kernelMeshFusion: confidence.kernelMeshFusion,
      kernelMeshConsistency: confidence.kernelMeshConsistency,
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalActivationState != null) {
      map['finalActivationState'] = finalActivationState;
    }
    if (confidenceScore != null) {
      map['confidenceScore'] = confidenceScore;
    }
    if (rationale != null) {
      map['rationale'] = rationale;
    }
    if (stagedTier != null) map['stagedTier'] = stagedTier;
    if (kernelSurfaceTriple != null) {
      map['kernelSurfaceTriple'] = kernelSurfaceTriple;
    }
    if (kernelCohesionWeights != null) {
      map['kernelCohesionWeights'] = kernelCohesionWeights;
    }
    if (kernelMeshDescriptor != null) {
      map['kernelMeshDescriptor'] = kernelMeshDescriptor;
    }
    if (kernelMeshVector != null) {
      map['kernelMeshVector'] = kernelMeshVector;
    }
    if (kernelMeshFusion != null) {
      map['kernelMeshFusion'] = kernelMeshFusion;
    }
    if (kernelMeshConsistency != null) {
      map['kernelMeshConsistency'] = kernelMeshConsistency;
    }
    return map.isEmpty ? null : map;
  }
}
