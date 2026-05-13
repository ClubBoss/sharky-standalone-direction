import 'persona_activation_supervisor_v4.dart';

class PersonaActivationConsistencyResolverV4 {
  const PersonaActivationConsistencyResolverV4({
    this.readinessSurfaceOk,
    this.readinessCohesionOk,
    this.readinessMeshOk,
    this.allowSurface,
    this.allowCohesion,
    this.allowMesh,
    this.allowFullActivation,
    this.isConsistentActivation,
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
  final bool? isConsistentActivation;
  final Map<String, double>? kernelSurfaceTriple;
  final Map<String, double>? kernelCohesionWeights;
  final Map<String, Object?>? kernelMeshDescriptor;
  final Map<String, Object?>? kernelMeshVector;
  final Map<String, Object?>? kernelMeshFusion;
  final Map<String, Object?>? kernelMeshConsistency;

  factory PersonaActivationConsistencyResolverV4.fromSupervisor(
    PersonaActivationSupervisorV4 supervisor,
  ) {
    final consistent =
        supervisor.allowFullActivation == true &&
        supervisor.readinessSurfaceOk == true &&
        supervisor.readinessCohesionOk == true &&
        supervisor.readinessMeshOk == true;
    return PersonaActivationConsistencyResolverV4(
      readinessSurfaceOk: supervisor.readinessSurfaceOk,
      readinessCohesionOk: supervisor.readinessCohesionOk,
      readinessMeshOk: supervisor.readinessMeshOk,
      allowSurface: supervisor.allowSurface,
      allowCohesion: supervisor.allowCohesion,
      allowMesh: supervisor.allowMesh,
      allowFullActivation: supervisor.allowFullActivation,
      isConsistentActivation: consistent,
      kernelSurfaceTriple: supervisor.kernelSurfaceTriple,
      kernelCohesionWeights: supervisor.kernelCohesionWeights,
      kernelMeshDescriptor: supervisor.kernelMeshDescriptor,
      kernelMeshVector: supervisor.kernelMeshVector,
      kernelMeshFusion: supervisor.kernelMeshFusion,
      kernelMeshConsistency: supervisor.kernelMeshConsistency,
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
    if (isConsistentActivation != null) {
      map['isConsistentActivation'] = isConsistentActivation;
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
