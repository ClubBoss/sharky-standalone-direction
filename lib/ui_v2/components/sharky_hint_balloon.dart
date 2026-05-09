import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../motion/motion_primitives.dart';
import '../theme/v4_token_registry.dart';

class SharkyHintBalloon extends StatelessWidget {
  final String text;
  final String? messageOverride;

  const SharkyHintBalloon({
    required this.text,
    this.messageOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    final t = messageOverride != null ? 1.0 : 0.85;
    final pair = MotionPrimitives.fadeScale(
      t: t,
      minScale: 0.98,
      maxScale: 1.0,
      minOpacity: 0.0,
      maxOpacity: 1.0,
    );
    final targetScale = pair['scale']!;
    final targetOpacity = pair['opacity']!;
    final harmonyPadding = tokens.v4SpacingS * targetScale;

    return Align(
      alignment: Alignment.bottomRight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        opacity: targetOpacity,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          scale: targetScale,
          child: Container(
            decoration: DesignContainers.card,
            padding: EdgeInsets.all(harmonyPadding),
            margin: EdgeInsets.only(
              right: tokens.v4SpacingM,
              bottom: tokens.v4SpacingL,
            ),
            child: Text(
              messageOverride ?? text,
              style: TextStyle(
                fontSize: DesignTypography.body,
                fontWeight: FontWeight.w500,
                color: Color(DesignColors.accentStrong),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
