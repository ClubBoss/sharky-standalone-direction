import 'visual_identity_v4_style_descriptor.dart';
import 'visual_identity_v4_visual_tier.dart';

class VisualIdentityV4DescriptorHydrator {
  const VisualIdentityV4DescriptorHydrator();

  VisualIdentityV4StyleDescriptor hydrate(
    VisualIdentityV4VisualTier visualTier,
  ) {
    return VisualIdentityV4StyleDescriptor(
      visualTier.name,
      radiusHint: 0.0,
      shadowHint: 0.0,
      contrastHint: 0.0,
    );
  }
}
