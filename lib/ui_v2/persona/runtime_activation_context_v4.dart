import 'persona_activation_final_bundle_v4.dart';
import 'persona_activation_diagnostic_consistency_map_v4.dart';

class RuntimeActivationContextV4 {
  const RuntimeActivationContextV4({
    this.finalActivationState,
    this.activationConfidence,
    this.activationTier,
    this.diagnosticSurfaceMap,
    this.diagnosticConsistencyMap,
    this.kernelSurface,
    this.kernelCohesion,
    this.kernelMesh,
  });

  final String? finalActivationState;
  final double? activationConfidence;
  final String? activationTier;
  final Map<String, Object?>? diagnosticSurfaceMap;
  final Map<String, Object?>? diagnosticConsistencyMap;
  final Map<String, Object?>? kernelSurface;
  final Map<String, Object?>? kernelCohesion;
  final Map<String, Object?>? kernelMesh;

  factory RuntimeActivationContextV4.fromBundles({
    required PersonaActivationFinalBundleV4 bundle,
    required PersonaActivationDiagnosticConsistencyMapV4 consistency,
  }) {
    return RuntimeActivationContextV4(
      finalActivationState: bundle.finalActivationState,
      activationConfidence: bundle.confidenceScore,
      activationTier: bundle.stagedTier,
      diagnosticSurfaceMap: bundle.asReadOnlyMap(),
      diagnosticConsistencyMap: consistency.asReadOnlyMap(),
      kernelSurface: bundle.surfaceTriple,
      kernelCohesion: bundle.cohesionWeights,
      kernelMesh: consistency.meshDescriptor,
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (finalActivationState != null) {
      map['finalActivationState'] = finalActivationState;
    }
    if (activationConfidence != null) {
      map['activationConfidence'] = activationConfidence;
    }
    if (activationTier != null) {
      map['activationTier'] = activationTier;
    }
    if (diagnosticSurfaceMap != null) {
      map['diagnosticSurfaceMap'] = diagnosticSurfaceMap;
    }
    if (diagnosticConsistencyMap != null) {
      map['diagnosticConsistencyMap'] = diagnosticConsistencyMap;
    }
    if (kernelSurface != null) {
      map['kernelSurface'] = kernelSurface;
    }
    if (kernelCohesion != null) {
      map['kernelCohesion'] = kernelCohesion;
    }
    if (kernelMesh != null) {
      map['kernelMesh'] = kernelMesh;
    }
    return map.isEmpty ? null : map;
  }
}
