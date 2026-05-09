// Persona V1 — stable panel surface (Φ-42 freeze)
import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../../engine/animation_orchestrator_context.dart';
import '../design/design_typography.dart';
import '../motion/motion_primitives.dart';
import '../persona/sharky_persona_state.dart';

class SharkyPersonaPanel extends StatelessWidget {
  final String message;
  final AnimationOrchestratorContext? orchestrator;
  final SharkyReaction reaction;
  final SharkyPersonaState? state;

  const SharkyPersonaPanel({
    required this.message,
    this.orchestrator,
    this.reaction = SharkyReaction.idle,
    this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = orchestrator?.timelineValue ?? 0.0;
    final pulse = (t % 1.0).clamp(0.0, 1.0);
    final pair = MotionPrimitives.fadeScale(
      t: pulse,
      minScale: 1.0,
      maxScale: 1.02,
      minOpacity: 0.9,
      maxOpacity: 1.0,
    );
    final scale = pair['scale']!;
    final opacity = pair['opacity']!;
    final displayReaction = state?.reaction ?? reaction;
    final displayMessage = state?.message ?? message;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Align(
      alignment: Alignment.bottomRight,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.all(VisualThemeV3.spacingM),
            padding: const EdgeInsets.all(VisualThemeV3.spacingM),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
              boxShadow: [
                VisualThemeV3.shadowMedium,
                BoxShadow(
                  color: VisualThemeV3.accent.withValues(alpha: 0.15),
                  blurRadius: VisualThemeV3.glowIntensity,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${displayReaction.name}]',
                  style: TextStyle(
                    fontSize: DesignTypography.caption,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: VisualThemeV3.spacingS),
                Text(
                  displayMessage,
                  style: TextStyle(
                    fontSize: DesignTypography.body,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
