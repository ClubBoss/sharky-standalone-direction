import 'package:flutter/widgets.dart'
    show StatelessWidget, Widget, Text, Positioned, Key, BuildContext;

import 'visual_identity_v4_application_binder.dart';
import 'visual_identity_v4_application_kernel.dart';
import 'visual_identity_v4_surface_map.dart';
import 'visual_identity_v4_tokens.dart';

class VisualIdentityV4DebugOverlay2 extends StatelessWidget {
  const VisualIdentityV4DebugOverlay2({
    Key? key,
    this.map,
    this.kernel,
    this.binder,
    this.tokens,
  }) : super(key: key);

  final VisualIdentityV4SurfaceMap? map;
  final VisualIdentityV4ApplicationKernel? kernel;
  final VisualIdentityV4ApplicationBinder? binder;
  final VisualIdentityV4Tokens? tokens;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Text(
        'V4 Identity Debug\n'
        'map: $map\n'
        'kernel: $kernel\n'
        'binder: $binder\n'
        'tokens: $tokens\n',
      ),
    );
  }
}
