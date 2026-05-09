import 'persona_activation_outcome_resolver_v4.dart';

class PersonaActivationConfidenceV4 {
  const PersonaActivationConfidenceV4({
    this.finalActivationState,
    this.isConsistentActivation,
    this.readinessSurfaceOk,
    this.readinessCohesionOk,
    this.readinessMeshOk,
    this.confidenceScore,
    this.rationale,
    this.kernelSurfaceTriple,
    this.kernelCohesionWeights,
    this.kernelMeshDescriptor,
    this.kernelMeshVector,
    this.kernelMeshFusion,
    this.kernelMeshConsistency,
  });

  final String? finalActivationState;
  final bool? isConsistentActivation;
  final bool? readinessSurfaceOk;
  final bool? readinessCohesionOk;
  final bool? readinessMeshOk;
  final double? confidenceScore;
  final String? rationale;
  final Map<String, Object?>? kernelSurfaceTriple;
  final Map<String, Object?>? kernelCohesionWeights;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;

  factory PersonaActivationConfidenceV4.fromOutcome(
    PersonaActivationOutcomeResolverV4 outcome,
  ) {
    final confidence = outcome.finalActivationState == 'active'
        ? 1.0
        : outcome.finalActivationState == 'partial'
        ? 0.5
        : 0.0;
    final reason = outcome.finalActivationState == 'active'
        ? 'active_ok'
        : outcome.finalActivationState == 'partial'
        ? 'partial_limited'
        : 'blocked_missing';
    return PersonaActivationConfidenceV4(
      finalActivationState: outcome.finalActivationState,
      isConsistentActivation: outcome.isConsistentActivation,
      readinessSurfaceOk: outcome.readinessSurfaceOk,
      readinessCohesionOk: outcome.readinessCohesionOk,
      readinessMeshOk: outcome.readinessMeshOk,
      confidenceScore: confidence,
      rationale: reason,
      kernelSurfaceTriple: outcome.kernelSurfaceTriple,
      kernelCohesionWeights: outcome.kernelCohesionWeights,
      kernelMeshDescriptor: outcome.kernelMeshDescriptor,
      kernelMeshVector: outcome.kernelMeshVector,
      kernelMeshFusion: outcome.kernelMeshFusion,
      kernelMeshConsistency: outcome.kernelMeshConsistency,
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalActivationState != null) {
      map['finalActivationState'] = finalActivationState;
    }
    if (isConsistentActivation != null) {
      map['isConsistentActivation'] = isConsistentActivation;
    }
    if (readinessSurfaceOk != null) {
      map['readinessSurfaceOk'] = readinessSurfaceOk;
    }
    if (readinessCohesionOk != null) {
      map['readinessCohesionOk'] = readinessCohesionOk;
    }
    if (readinessMeshOk != null) {
      map['readinessMeshOk'] = readinessMeshOk;
    }
    if (confidenceScore != null) {
      map['confidenceScore'] = confidenceScore;
    }
    if (rationale != null) {
      map['rationale'] = rationale;
    }
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
