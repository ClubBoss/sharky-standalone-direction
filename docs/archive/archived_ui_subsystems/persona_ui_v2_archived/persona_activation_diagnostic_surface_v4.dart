import 'persona_activation_final_bundle_v4.dart';

class PersonaActivationDiagnosticSurfaceV4 {
  const PersonaActivationDiagnosticSurfaceV4({
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

  factory PersonaActivationDiagnosticSurfaceV4.fromFinalBundle(
    PersonaActivationFinalBundleV4 bundle,
  ) {
    return PersonaActivationDiagnosticSurfaceV4(
      surfaceTriple: bundle.surfaceTriple,
      cohesionWeights: bundle.cohesionWeights,
      meshDescriptor: bundle.meshDescriptor,
      meshVector: bundle.meshVector,
      meshFusion: bundle.meshFusion,
      meshConsistency: bundle.meshConsistency,
      finalActivationState: bundle.finalActivationState,
      confidenceScore: bundle.confidenceScore,
      activationRationale: bundle.activationRationale,
      stagedTier: bundle.stagedTier,
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
