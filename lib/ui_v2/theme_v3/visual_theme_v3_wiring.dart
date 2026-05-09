import 'theme_binder_v3.dart';
import 'motion_binder_v3.dart';
import 'visual_style_orchestrator_v3.dart';

class VisualThemeV3Wiring {
  VisualThemeV3Wiring();

  final ThemeBinderV3 themeBinder = ThemeBinderV3();
  final MotionBinderV3 motionBinder = MotionBinderV3();
  final VisualStyleOrchestratorV3 orchestrator = VisualStyleOrchestratorV3();

  void initialize() {}
  void bindTheme() {}
  void bindMotion() {}
  void syncAll() {}
}
