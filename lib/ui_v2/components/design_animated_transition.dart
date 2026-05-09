import 'package:flutter/material.dart';

import '../../engine/animation_orchestrator_context.dart';
import '../motion/motion_primitives.dart';

class DesignAnimatedTransition extends StatelessWidget {
  final Widget child;
  final AnimationOrchestratorContext orchestrator;

  const DesignAnimatedTransition({
    required this.child,
    required this.orchestrator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = orchestrator.timelineValue % 1.0;
    final values = MotionPrimitives.fadeScale(
      t: t,
      minScale: 0.95,
      maxScale: 1.0,
      minOpacity: 0.0,
      maxOpacity: 1.0,
    );
    final opacity = values['opacity']!;
    final scale = values['scale']!;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(scale: scale, child: child),
    );
  }
}
