import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../../services/personalization_context.dart';
import 'sharky_persona_events.dart';
import '../theme/v4_token_registry.dart';

const double _baseGlowFactor = 0.22;
const double _pulseAmplitude = 0.12;
const double _maxOverlayAlpha = 0.48;
const double _alphaSafetyMargin = 0.01;

class SharkyAuraFX extends StatelessWidget {
  const SharkyAuraFX({
    required this.fusion,
    required this.child,
    this.adaptiveIntensity,
    super.key,
  });

  final PersonaFusionState fusion;
  final Widget child;
  final double? adaptiveIntensity;

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    final cohesion = _cohesionIntensity(fusion.intensity, fusion.beat);
    final pulse = _pulseAmplitude * math.sin(fusion.beat * math.pi);
    final overlayRaw = cohesion * _baseGlowFactor + pulse;
    final overlayOpacity = overlayRaw.clamp(
      0.0,
      _maxOverlayAlpha - _alphaSafetyMargin,
    );
    // ignore: unused_local_variable
    final modifiers = adaptiveIntensity != null
        ? VisualThemeV3.getModifiers(
            VisualThemeV3.deriveFrom(const PersonalizationContext()),
          )
        : null;
    // TODO(Φ-AI): apply adaptive intensity scaling here later.
    final overlayColor = _resolveAuraColor(
      fusion,
    ).withValues(alpha: overlayOpacity);
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.90),
        borderRadius: BorderRadius.circular(tokens.v4RadiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(tokens.v4ShadowOpacity),
            blurRadius: tokens.v4ShadowBlur,
            offset: Offset(0, tokens.v4ShadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.all(tokens.v4SpacingM),
      child: Stack(
        children: [
          child,
          if (overlayOpacity > 0)
            Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: overlayColor)),
            ),
        ],
      ),
    );
  }

  Color _resolveAuraColor(PersonaFusionState fusion) {
    if (fusion.signal == SharkyMotionSignalType.none || fusion.intensity <= 0) {
      return VisualThemeV3.card;
    }
    if (fusion.signal == SharkyMotionSignalType.beat) {
      return VisualThemeV3.success;
    }
    final macro = fusion.macro;
    if (macro == PersonaExpression.celebrate ||
        macro == PersonaExpression.attentive) {
      return VisualThemeV3.accent;
    }
    if (macro == PersonaExpression.tilt) {
      return VisualThemeV3.danger;
    }
    return VisualThemeV3.accentSecondary.withValues(alpha: 0.6);
  }

  double _cohesionIntensity(double intensity, double beat) {
    final value = intensity * (0.6 + 0.4 * beat);
    return math.min(value, 0.9);
  }
}
