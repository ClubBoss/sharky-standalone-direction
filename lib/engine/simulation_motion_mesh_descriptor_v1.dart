class MotionMeshDescriptorV1 {
  const MotionMeshDescriptorV1({
    this.meshStability,
    this.meshResponsiveness,
    this.meshElasticity,
  });

  final double? meshStability;
  final double? meshResponsiveness;
  final double? meshElasticity;

  Map<String, double>? asReadOnlyMap() {
    final map = <String, double>{};
    if (meshStability != null) map['meshStability'] = meshStability!;
    if (meshResponsiveness != null) {
      map['meshResponsiveness'] = meshResponsiveness!;
    }
    if (meshElasticity != null) map['meshElasticity'] = meshElasticity!;
    return map.isEmpty ? null : map;
  }
}
