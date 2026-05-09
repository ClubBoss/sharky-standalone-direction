class VisualCohesionKernelConfigV4 {
  const VisualCohesionKernelConfigV4({
    this.defaultColorChecks = false,
    this.defaultShapeChecks = false,
    this.defaultMotionChecks = false,
  });

  final bool defaultColorChecks;
  final bool defaultShapeChecks;
  final bool defaultMotionChecks;

  Map<String, bool> exportFlags() {
    // TODO Phase-6: config serialization
    return {
      'color': defaultColorChecks,
      'shape': defaultShapeChecks,
      'motion': defaultMotionChecks,
    };
  }
}
