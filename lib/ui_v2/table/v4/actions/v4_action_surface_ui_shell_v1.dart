import 'package:flutter/widgets.dart';

class V4ActionSurfaceUIShellV1 extends StatelessWidget {
  const V4ActionSurfaceUIShellV1({
    super.key,
    required this.integrationFinalizerSnapshot,
  });

  final Object integrationFinalizerSnapshot;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Map<String, String> asReadOnlyMap() => {
    'ui_shell_ok': 'true',
    'finalizer': integrationFinalizerSnapshot.toString(),
  };
}
