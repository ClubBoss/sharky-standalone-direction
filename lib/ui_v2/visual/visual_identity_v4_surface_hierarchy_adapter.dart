import 'visual_identity_v4_surface_map.dart';
import 'visual_identity_v4_tokens.dart';

class VisualIdentityV4SurfaceHierarchyAdapter {
  const VisualIdentityV4SurfaceHierarchyAdapter({
    required this.map,
    required this.tokens,
  });

  final VisualIdentityV4SurfaceMap map;
  final VisualIdentityV4Tokens tokens;

  Map<String, Object> exportHierarchy() {
    // TODO Phase-9: surface hierarchy logic
    return {
      'map': map.exportMap(),
      'tokens': tokens.exportTokens(),
      'status': 'pending',
    };
  }
}
