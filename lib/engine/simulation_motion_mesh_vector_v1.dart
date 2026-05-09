class MotionMeshVectorV1 {
  const MotionMeshVectorV1({
    this.meshX,
    this.meshY,
    this.meshZ,
    this.meshDrift,
    this.meshSpring,
    this.meshDamp,
  });

  final double? meshX;
  final double? meshY;
  final double? meshZ;
  final double? meshDrift;
  final double? meshSpring;
  final double? meshDamp;

  Map<String, double>? asReadOnlyMap() {
    final map = <String, double>{};
    if (meshX != null) map['meshX'] = meshX!;
    if (meshY != null) map['meshY'] = meshY!;
    if (meshZ != null) map['meshZ'] = meshZ!;
    if (meshDrift != null) map['meshDrift'] = meshDrift!;
    if (meshSpring != null) map['meshSpring'] = meshSpring!;
    if (meshDamp != null) map['meshDamp'] = meshDamp!;
    return map.isEmpty ? null : map;
  }
}
