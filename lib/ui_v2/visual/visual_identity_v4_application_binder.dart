import 'visual_identity_v4_application_kernel.dart';
import 'visual_identity_v4_surface_map.dart';
import 'visual_identity_v4_tokens.dart';

class VisualIdentityV4ApplicationBinder {
  const VisualIdentityV4ApplicationBinder({
    required this.map,
    required this.kernel,
    required this.tokens,
  });

  final VisualIdentityV4SurfaceMap map;
  final VisualIdentityV4ApplicationKernel kernel;
  final VisualIdentityV4Tokens tokens;

  Map<String, Object> bind() {
    // TODO Phase-8: application binder logic
    return {
      'map': map.exportMap(),
      'kernel': kernel.exportApplication(),
      'tokens': tokens.exportTokens(),
    };
  }
}
