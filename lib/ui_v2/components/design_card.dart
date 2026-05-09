import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../theme/v4_token_registry.dart';

class DesignCard extends StatelessWidget {
  final Widget child;

  const DesignCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    return Container(
      decoration: DesignContainers.card,
      padding: EdgeInsets.symmetric(
        vertical: tokens.v4SpacingM,
        horizontal: tokens.v4SpacingS,
      ),
      child: child,
    );
  }
}
