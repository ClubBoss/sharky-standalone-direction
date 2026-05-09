import '../../engine/simulation_motion_kernel.dart';
import 'persona_activation_gate_v4.dart';
import 'pre_activation_persona_check_matrix_v4.dart';

class PersonaActivationSupervisorV4 {
  const PersonaActivationSupervisorV4({
    this.readinessSurfaceOk,
    this.readinessCohesionOk,
    this.readinessMeshOk,
    this.allowSurface,
    this.allowCohesion,
    this.allowMesh,
    this.allowFullActivation,
    this.kernelSurfaceTriple,
    this.kernelCohesionWeights,
    this.kernelMeshDescriptor,
    this.kernelMeshVector,
    this.kernelMeshFusion,
    this.kernelMeshConsistency,
  });

  final bool? readinessSurfaceOk;
  final bool? readinessCohesionOk;
  final bool? readinessMeshOk;
  final bool? allowSurface;
  final bool? allowCohesion;
  final bool? allowMesh;
  final bool? allowFullActivation;
  final Map<String, double>? kernelSurfaceTriple;
  final Map<String, double>? kernelCohesionWeights;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;

  factory PersonaActivationSupervisorV4.fromGateAndKernel(
    PersonaActivationGateV4 gate,
    PreActivationPersonaCheckMatrixV4 matrix,
    SimulationMotionKernel kernel,
  ) {
    return PersonaActivationSupervisorV4(
      readinessSurfaceOk: matrix.readinessSurfaceOk,
      readinessCohesionOk: matrix.readinessCohesionOk,
      readinessMeshOk: matrix.readinessMeshOk,
      allowSurface: gate.allowSurface,
      allowCohesion: gate.allowCohesion,
      allowMesh: gate.allowMesh,
      allowFullActivation: gate.allowFullActivation,
      kernelSurfaceTriple: kernel.v4SurfaceSyncTripleOrNull,
      kernelCohesionWeights: kernel.v4CohesionWeightsOrNull,
      kernelMeshDescriptor: kernel.motionMeshDescriptorOrNull?.asReadOnlyMap(),
      kernelMeshVector: kernel.motionMeshVectorOrNull?.asReadOnlyMap(),
      kernelMeshFusion: kernel.motionMeshFusionOrNull?.asReadOnlyMap(),
      kernelMeshConsistency: kernel.motionMeshConsistencyOrNull
          ?.asReadOnlyMap(),
    );
  }

  Map<String, Object?>? asReadOnlyMap() {
    final map = <String, Object?>{};
    if (readinessSurfaceOk != null) {
      map['readinessSurfaceOk'] = readinessSurfaceOk;
    }
    if (readinessCohesionOk != null) {
      map['readinessCohesionOk'] = readinessCohesionOk;
    }
    if (readinessMeshOk != null) map['readinessMeshOk'] = readinessMeshOk;
    if (allowSurface != null) map['allowSurface'] = allowSurface;
    if (allowCohesion != null) map['allowCohesion'] = allowCohesion;
    if (allowMesh != null) map['allowMesh'] = allowMesh;
    if (allowFullActivation != null) {
      map['allowFullActivation'] = allowFullActivation;
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
