import 'pre_activation_persona_check_matrix_v4.dart';

class PersonaActivationGateV4 {
  const PersonaActivationGateV4({
    this.allowSurface,
    this.allowCohesion,
    this.allowMesh,
    this.allowFullActivation,
  });

  final bool? allowSurface;
  final bool? allowCohesion;
  final bool? allowMesh;
  final bool? allowFullActivation;

  factory PersonaActivationGateV4.fromMatrix(
    PreActivationPersonaCheckMatrixV4 matrix,
  ) {
    final surface = matrix.readinessSurfaceOk;
    final cohesion = matrix.readinessCohesionOk;
    final mesh = matrix.readinessMeshOk;
    return PersonaActivationGateV4(
      allowSurface: surface,
      allowCohesion: cohesion,
      allowMesh: mesh,
      allowFullActivation: surface == true && cohesion == true && mesh == true,
    );
  }

  Map<String, bool?>? asReadOnlyMap() {
    final map = <String, bool?>{};
    if (allowSurface != null) map['allowSurface'] = allowSurface;
    if (allowCohesion != null) map['allowCohesion'] = allowCohesion;
    if (allowMesh != null) map['allowMesh'] = allowMesh;
    if (allowFullActivation != null) {
      map['allowFullActivation'] = allowFullActivation;
    }
    return map.isEmpty ? null : map;
  }
}
