import 'visual_identity_v4_application_binder.dart';
import 'visual_identity_v4_application_kernel.dart';
import 'visual_identity_v4_surface_map.dart';
import 'visual_identity_v4_tokens.dart';

class VisualIdentityV4PreRolloutValidator {
  Map<String, String> validate({
    required VisualIdentityV4SurfaceMap? map,
    required VisualIdentityV4ApplicationKernel? kernel,
    required VisualIdentityV4ApplicationBinder? binder,
    required VisualIdentityV4Tokens? tokens,
  }) {
    return {
      'map': map == null ? 'missing' : 'present',
      'kernel': kernel == null ? 'missing' : 'present',
      'binder': binder == null ? 'missing' : 'present',
      'tokens': tokens == null ? 'missing' : 'present',
      'status': 'stub',
    };
  }
}
