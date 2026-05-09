import 'pre_activation_persona_audit_v4.dart';

class PreActivationPersonaCheckMatrixV4 {
  const PreActivationPersonaCheckMatrixV4({
    this.readinessSurfaceOk,
    this.readinessCohesionOk,
    this.readinessMeshOk,
    this.readinessFullOk,
  });

  final bool? readinessSurfaceOk;
  final bool? readinessCohesionOk;
  final bool? readinessMeshOk;
  final bool? readinessFullOk;

  factory PreActivationPersonaCheckMatrixV4.fromAudit(
    PreActivationPersonaAuditV4 audit,
  ) {
    final surfaces =
        audit.surfaceRadius != null &&
        audit.surfaceElevation != null &&
        audit.surfaceSpacing != null;
    final cohesion =
        audit.radiusWeight != null &&
        audit.elevationWeight != null &&
        audit.spacingWeight != null;
    final mesh =
        audit.meshDescriptor != null &&
        audit.meshVector != null &&
        audit.meshFusion != null &&
        audit.meshConsistency != null;
    final full = surfaces && cohesion && mesh;
    return PreActivationPersonaCheckMatrixV4(
      readinessSurfaceOk: surfaces,
      readinessCohesionOk: cohesion,
      readinessMeshOk: mesh,
      readinessFullOk: full,
    );
  }

  Map<String, bool?>? asReadOnlyMap() {
    final map = <String, bool?>{};
    if (readinessSurfaceOk != null) {
      map['readinessSurfaceOk'] = readinessSurfaceOk;
    }
    if (readinessCohesionOk != null) {
      map['readinessCohesionOk'] = readinessCohesionOk;
    }
    if (readinessMeshOk != null) map['readinessMeshOk'] = readinessMeshOk;
    if (readinessFullOk != null) map['readinessFullOk'] = readinessFullOk;
    return map.isEmpty ? null : map;
  }
}
