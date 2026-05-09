import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import 'global_persona_controller.dart';
import 'persona_fusion_frame.dart';
import 'persona_reaction_state.dart';

class PersonaReactionSurface extends StatelessWidget {
  const PersonaReactionSurface({
    required this.reaction,
    required this.beat,
    this.fusionFrame,
    this.unifiedEvent,
    super.key,
  });

  final PersonaReactionState reaction;
  final double beat;
  final PersonaFusionFrame? fusionFrame;
  final UnifiedPersonaEvent? unifiedEvent;

  @override
  Widget build(BuildContext context) {
    final intensity =
        unifiedEvent?.fusionIntensity ??
        (fusionFrame != null
            ? (fusionFrame!.intensity * (0.6 + 0.4 * beat)).clamp(0.0, 0.9)
            : reaction.intensity);
    final scale = 1 + intensity * 0.12;
    final yLift = -intensity * 4;
    final glowOpacity = (intensity * 0.25).clamp(0.0, 0.45);
    final auraColor = _resolveColor();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = reaction.type.name.toUpperCase();
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Transform.translate(
            offset: Offset(0, yLift),
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(VisualThemeV3.spacingM),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.10),
                  ),
                  boxShadow: const [VisualThemeV3.shadowLight],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: glowOpacity,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              auraColor.withValues(alpha: glowOpacity),
                              auraColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: DesignTypography.body,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveColor() {
    switch (reaction.type) {
      case PersonaReactionType.focus:
      case PersonaReactionType.pulse:
      case PersonaReactionType.celebrate:
        return Color(DesignColors.accentStrong);
      case PersonaReactionType.warn:
        return const Color(0xFFE57373);
      case PersonaReactionType.idle:
        return Color(DesignColors.accentHighlight);
    }
  }
}
