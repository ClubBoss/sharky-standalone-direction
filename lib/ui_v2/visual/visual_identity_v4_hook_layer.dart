import 'visual_identity_v4_binder.dart';
import 'visual_identity_v4_kernel.dart';
import 'visual_identity_v4_tokens.dart';

class VisualIdentityV4HookLayer {
  const VisualIdentityV4HookLayer({
    required this.kernel,
    required this.tokens,
    required this.binder,
  });

  final VisualIdentityV4Kernel kernel;
  final VisualIdentityV4Tokens tokens;
  final VisualIdentityV4Binder binder;

  Map<String, String> exportHook() {
    // TODO Phase-7: hook layer logic
    return {'kernel': 'linked', 'tokens': 'linked', 'binder': 'linked'};
  }
}
