import 'persona_activation_consistency_resolver_v4.dart';

class PersonaActivationOutcomeResolverV4 {
  const PersonaActivationOutcomeResolverV4({
    this.isConsistentActivation,
    this.readinessSurfaceOk,
    this.readinessCohesionOk,
    this.readinessMeshOk,
    this.allowFullActivation,
    this.finalActivationState,
    this.kernelSurfaceTriple,
    this.kernelCohesionWeights,
    this.kernelMeshDescriptor,
    this.kernelMeshVector,
    this.kernelMeshFusion,
    this.kernelMeshConsistency,
  });

  final bool? isConsistentActivation;
  final bool? readinessSurfaceOk;
  final bool? readinessCohesionOk;
  final bool? readinessMeshOk;
  final bool? allowFullActivation;
  final String? finalActivationState;
  final Map<String, double>? kernelSurfaceTriple;
  final Map<String, double>? kernelCohesionWeights;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;

  factory PersonaActivationOutcomeResolverV4.fromConsistency(
    PersonaActivationConsistencyResolverV4 consistency,
  ) {
    final finalState = consistency.isConsistentActivation == true
        ? 'active'
        : (consistency.readinessSurfaceOk == false ||
              consistency.readinessCohesionOk == false ||
              consistency.readinessMeshOk == false)
        ? 'blocked'
        : 'partial';
    return PersonaActivationOutcomeResolverV4(
      isConsistentActivation: consistency.isConsistentActivation,
      readinessSurfaceOk: consistency.readinessSurfaceOk,
      readinessCohesionOk: consistency.readinessCohesionOk,
      readinessMeshOk: consistency.readinessMeshOk,
      allowFullActivation: consistency.allowFullActivation,
      finalActivationState: finalState,
      kernelSurfaceTriple: consistency.kernelSurfaceTriple,
      kernelCohesionWeights: consistency.kernelCohesionWeights,
      kernelMeshDescriptor: consistency.kernelMeshDescriptor,
      kernelMeshVector: consistency.kernelMeshVector,
      kernelMeshFusion: consistency.kernelMeshFusion,
      kernelMeshConsistency: consistency.kernelMeshConsistency,
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (isConsistentActivation != null) {
      map['isConsistentActivation'] = isConsistentActivation;
    }
    if (readinessSurfaceOk != null) {
      map['readinessSurfaceOk'] = readinessSurfaceOk;
    }
    if (readinessCohesionOk != null) {
      map['readinessCohesionOk'] = readinessCohesionOk;
    }
    if (readinessMeshOk != null) map['readinessMeshOk'] = readinessMeshOk;
    if (allowFullActivation != null) {
      map['allowFullActivation'] = allowFullActivation;
    }
    if (finalActivationState != null) {
      map['finalActivationState'] = finalActivationState;
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
