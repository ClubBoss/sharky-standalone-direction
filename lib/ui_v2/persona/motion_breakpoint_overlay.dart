import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class MotionBreakpointOverlay extends StatelessWidget {
  const MotionBreakpointOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: VisualThemeV3.spacingM,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: true,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: VisualThemeV3.spacingS,
              horizontal: VisualThemeV3.spacingM,
            ),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'BREAKPOINT TRIGGERED',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
