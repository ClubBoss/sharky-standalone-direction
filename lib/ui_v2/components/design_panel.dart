import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../theme/v4_token_registry.dart';

class DesignPanel extends StatelessWidget {
  final Widget child;

  const DesignPanel({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    return Container(
      decoration: DesignContainers.panel,
      padding: EdgeInsets.all(tokens.v4SpacingM),
      child: child,
    );
  }
}
