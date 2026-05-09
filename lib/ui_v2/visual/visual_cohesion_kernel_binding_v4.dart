import 'visual_cohesion_kernel_config_v4.dart';
import 'visual_cohesion_kernel_v4.dart';

class VisualCohesionKernelBindingV4 {
  const VisualCohesionKernelBindingV4({
    required this.kernel,
    required this.config,
  });

  final VisualCohesionKernelV4 kernel;
  final VisualCohesionKernelConfigV4 config;

  Map<String, String> bind() {
    // TODO Phase-6: kernel+config binding logic
    return {
      'color': config.defaultColorChecks ? 'active' : 'inactive',
      'shape': config.defaultShapeChecks ? 'active' : 'inactive',
      'motion': config.defaultMotionChecks ? 'active' : 'inactive',
    };
  }
}
