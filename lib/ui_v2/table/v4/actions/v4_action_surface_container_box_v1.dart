import 'package:flutter/widgets.dart';

class V4ActionSurfaceContainerBoxV1 extends StatelessWidget {
  const V4ActionSurfaceContainerBoxV1({
    super.key,
    required this.uiShellSnapshotWidget,
  });

  final Widget? uiShellSnapshotWidget;

  @override
  Widget build(BuildContext context) =>
      uiShellSnapshotWidget ?? const SizedBox.shrink();

  Map<String, String> asReadOnlyMap() => {
    'container_box_ok': 'true',
    'ui_shell': (uiShellSnapshotWidget ?? '').toString(),
  };
}
