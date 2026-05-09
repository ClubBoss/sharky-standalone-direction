import '../components_v3/panel_v3.dart';
import '../components_v3/surface_container_v3.dart';
import '../theme_v3/theme_v3.dart';
import 'visual_identity_v4_snapshot_qa.dart';

class VisualIdentityV4GlobalSnapshotQA {
  const VisualIdentityV4GlobalSnapshotQA({
    required this.theme,
    required this.panel,
    required this.surfaceContainer,
    required this.snapshotQA,
  });

  final ThemeV3 theme;
  final PanelV3 panel;
  final SurfaceContainerV3 surfaceContainer;
  final VisualIdentityV4SnapshotQA snapshotQA;

  Map<String, Object> snapshot() {
    // TODO Phase-10: global identity snapshot QA
    return {
      'theme_v4_identity': 'pending',
      'panel_v4_identity': 'pending',
      'surface_container_v4_identity': 'pending',
      'local_snapshot': snapshotQA.snapshot(),
      'status': 'pending',
    };
  }
}
