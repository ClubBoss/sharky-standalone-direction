import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../../services/personalization_context.dart';
import 'clip_frame_spec.dart';
import 'persona_fusion_frame.dart';

const double _baseGlowFactor = 0.22;
const double _fusionRippleFactor = 0.35;
const double _beatRippleFactor = 0.12;
const double _maxGlowAlpha = 0.38;
const double _shadowBaseFactor = 0.18;
const double _beatShadowGain = 0.06;
const double _beatGlowGain = 0.10;
const double _glowAlphaMargin = 0.01;
const double _shadowAlphaMargin = 0.01;

class PersonaClipParams {
  const PersonaClipParams({
    this.clipFrame,
    this.fusionFrame,
    this.beat = 0.0,
    this.tone,
    this.controller,
    this.meta,
  });

  final ClipFrameSpec? clipFrame;
  final PersonaFusionFrame? fusionFrame;
  final double beat;
  final Color? tone;
  final Object? controller;
  final Object? meta;
}

class PersonaClipSurface extends StatelessWidget {
  const PersonaClipSurface({
    required this.params,
    this.adaptiveIntensity,
    super.key,
  });

  final PersonaClipParams params;
  final double? adaptiveIntensity;

  double _cohesionIntensity(double baseIntensity, double beat) {
    final value = baseIntensity * (0.6 + 0.4 * beat);
    return math.min(value, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final hasFusion = params.fusionFrame != null;
    if (!hasFusion && params.clipFrame == null) {
      return const SizedBox.shrink();
    }

    const baseRadius = 48.0;
    final scale = params.fusionFrame?.scale ?? params.clipFrame?.scale ?? 1.0;
    final opacity =
        (params.fusionFrame?.opacity ?? params.clipFrame?.opacity ?? 1.0).clamp(
          0.0,
          1.0,
        );
    final yLift = params.fusionFrame?.yLift ?? params.clipFrame?.yLift ?? 0.0;
    final beat = params.beat;
    final cohesion = hasFusion
        ? _cohesionIntensity(params.fusionFrame!.intensity, beat)
        : -1;
    final rippleRadius = hasFusion
        ? baseRadius * (1 + cohesion * _fusionRippleFactor)
        : baseRadius *
              (1 + scale * _fusionRippleFactor + beat * _beatRippleFactor);
    final glowRaw = hasFusion
        ? (cohesion * _baseGlowFactor)
        : (opacity * (_baseGlowFactor + beat * _beatGlowGain));
    final glowOpacity = glowRaw.clamp(0.0, _maxGlowAlpha - _glowAlphaMargin);
    // ignore: unused_local_variable
    final modifiers = adaptiveIntensity != null
        ? VisualThemeV3.getModifiers(
            VisualThemeV3.deriveFrom(const PersonalizationContext()),
          )
        : null;
    final shadowRaw = hasFusion
        ? (cohesion * _shadowBaseFactor)
        : (opacity * (_shadowBaseFactor + beat * _beatShadowGain));
    final shadowOpacity = shadowRaw.clamp(0.0, 0.3 - _shadowAlphaMargin);
    // TODO(Φ-AI): connect adaptiveIntensity to modifiers.scaleIntensity later.
    // TODO(Φ-AI): apply adaptive intensity scaling here later.
    final glowColor = VisualThemeV3.accent.withValues(alpha: glowOpacity);
    final shadowColor = VisualThemeV3.accentSecondary.withValues(
      alpha: shadowOpacity,
    );
    final offset = Offset(0, yLift);
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(VisualThemeV3.spacingM),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.90),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              boxShadow: const [VisualThemeV3.shadowLight],
            ),
            child: Transform.translate(
              offset: offset,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: baseRadius,
                    height: baseRadius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [glowColor, const Color(0x00000000)],
                        stops: const [0.0, 1.0],
                        radius: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: rippleRadius / 2,
                          spreadRadius: 0,
                          offset: Offset(0, yLift * 1.2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (params.tone != null)
                          Container(
                            width: baseRadius,
                            height: baseRadius,
                            decoration: BoxDecoration(
                              color: params.tone!.withValues(
                                alpha:
                                    (0.08 *
                                            (params.fusionFrame?.opacity ??
                                                params.clipFrame?.opacity ??
                                                1.0))
                                        .clamp(0.0, 0.08),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Container(
                          width: baseRadius * 0.6 * (1 + beat * 0.08),
                          height: baseRadius * 0.6 * (1 + beat * 0.08),
                          decoration: BoxDecoration(
                            color: VisualThemeV3.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
