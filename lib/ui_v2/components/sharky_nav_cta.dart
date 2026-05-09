import 'package:flutter/material.dart';

import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../motion/motion_primitives.dart';
import '../theme/v4_token_registry.dart';

class SharkyNavCta extends StatelessWidget {
  final String nav;

  const SharkyNavCta({required this.nav, super.key});

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    final pair = MotionPrimitives.fadeScale(t: 0.85);
    final harmonyPadding = tokens.v4SpacingS * pair['scale']!;
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: tokens.v4SpacingM,
          horizontal: tokens.v4SpacingM,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: 0.92,
          child: Container(
            decoration: BoxDecoration(
              color: Color(DesignColors.surfaceElevated),
              border: Border.all(color: Color(DesignColors.borderSubtle)),
              borderRadius: BorderRadius.all(Radius.circular(tokens.v4RadiusM)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(tokens.v4ShadowOpacity),
                  blurRadius: tokens.v4ShadowBlur,
                  offset: Offset(0, tokens.v4ShadowOffset),
                ),
              ],
            ),
            padding: EdgeInsets.all(harmonyPadding),
            child: Text(
              'Recommended: $nav',
              style: TextStyle(
                fontSize: DesignTypography.body,
                fontWeight: FontWeight.w500,
                color: Color(DesignColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
