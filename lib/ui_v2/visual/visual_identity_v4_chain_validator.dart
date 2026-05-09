import 'visual_identity_v4_style_binding.dart';
import 'visual_identity_v4_style_descriptor.dart';
import 'visual_identity_v4_style_skeleton.dart'
    hide VisualIdentityV4StyleDescriptor, VisualIdentityV4VisualTier;
import 'visual_identity_v4_surface_tier.dart';
import 'visual_identity_v4_visual_tier.dart';

class VisualIdentityV4ChainValidator {
  VisualIdentityV4ChainValidator();

  VisualIdentityV4StyleDescriptor? descriptor;
  VisualIdentityV4StyleSkeleton? skeleton;
  VisualIdentityV4VisualTier? visualTier;
  VisualIdentityV4SurfaceTier? surfaceTier;
  VisualIdentityV4RoleResolution? roleResolution;
  VisualIdentityV4StyleBinding? styleBinding;

  Map<String, String> exportStatus() {
    return {
      'descriptor': descriptor == null ? 'missing' : 'ok',
      'skeleton': skeleton == null ? 'missing' : 'ok',
      'visualTier': visualTier == null ? 'missing' : 'ok',
      'surfaceTier': surfaceTier == null ? 'missing' : 'ok',
      'roleResolution': roleResolution == null ? 'missing' : 'ok',
      'styleBinding': styleBinding == null ? 'missing' : 'ok',
    };
  }
}
