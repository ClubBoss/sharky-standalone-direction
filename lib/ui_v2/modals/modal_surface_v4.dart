import 'package:flutter/material.dart';

import '../app_root.dart';
import '../components/help_info_icon_v4.dart';

class ModalSurfaceV4 extends StatelessWidget {
  const ModalSurfaceV4({
    super.key,
    required this.child,
    required this.isV4Active,
  });

  final Widget child;
  final bool isV4Active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 4,
          right: 4,
          child: HelpInfoIconV4(
            componentId: 'modal_surface_v4',
            binder: appRoot.exportInlineExplanationBinderV4,
            isV4Active: isV4Active,
          ),
        ),
      ],
    );
  }
}
