import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../theme/v4_token_registry.dart';

class XpProgressBar extends StatelessWidget {
  final double progress;

  const XpProgressBar({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    final p = progress.clamp(0.0, 1.0);
    return Container(
      decoration: DesignContainers.card,
      padding: EdgeInsets.all(tokens.v4SpacingS),
      child: LinearProgressIndicator(
        value: p,
        backgroundColor: Color(DesignColors.surfaceLight),
        color: Color(DesignColors.accent),
      ),
    );
  }
}
