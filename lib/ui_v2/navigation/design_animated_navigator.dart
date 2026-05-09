import 'package:flutter/material.dart';

import '../../engine/animation_orchestrator_context.dart';
import '../motion/motion_primitives.dart';

class DesignAnimatedNavigator {
  static Route build({
    required Widget screen,
    required AnimationOrchestratorContext orchestrator,
  }) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        final pair = MotionPrimitives.fadeScale(
          t: orchestrator.timelineValue % 1.0,
        );
        final scale = pair['scale']!;
        final opacity = pair['opacity']!;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}
