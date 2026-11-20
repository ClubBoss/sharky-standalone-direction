import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';

/// Shared reading-surface paint only. Never consumed by the physical table,
/// decision stage, grading, or persisted learner state.
class Act0AcademyReadingStyleV1 {
  const Act0AcademyReadingStyleV1._();

  static const text = Act0AcademyDesignTokensV1.ink;
  static const textMuted = Act0AcademyDesignTokensV1.inkMuted;
  static const textDim = textMuted;
  static const primary = Act0AcademyDesignTokensV1.focus;
  static const actionBlue = primary;
  static const actionCyan = primary;
  static const currentLearningState = primary;
  static const repairAttention = Act0AcademyDesignTokensV1.needsReviewFg;
  static const gold = repairAttention;
  static const info = primary;
  static const danger = Color(0xFF8B392F);
  static const correct = Act0AcademyDesignTokensV1.correctFg;
  static const surface = Act0AcademyDesignTokensV1.cardSurface;
  static const surface2 = Act0AcademyDesignTokensV1.pageSurface;
  static const surface3 = Color(0xFFEBECE3);
  static const border = Act0AcademyDesignTokensV1.rule;
  static const onPrimary = Act0AcademyDesignTokensV1.onPrimaryAction;

  static const body = Act0AcademyDesignTokensV1.body;
  static const muted = Act0AcademyDesignTokensV1.supporting;
  static const sentenceSupport = TextStyle(
    color: textMuted,
    fontSize: 12,
    height: 1.32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const label = TextStyle(
    color: textMuted,
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
  static const screenTitle = Act0AcademyDesignTokensV1.lessonHeading;
  static const sectionTitle = Act0AcademyDesignTokensV1.sectionHeading;
  static const cardTitle = TextStyle(
    color: text,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );

  static BoxDecoration surfaceDecoration({
    Color? borderColor,
    bool glow = false,
    Color? color,
  }) => Act0AcademyDesignTokensV1.cardDecoration(
    borderColor: borderColor,
    color: color,
  );
  static BoxDecoration heroDecoration() =>
      Act0AcademyDesignTokensV1.cardDecoration(
        color: surface3,
        borderColor: border,
      );
  static BoxDecoration premiumActionSurfaceDecoration({
    double borderOpacity = 0.28,
    double glowOpacity = 0.18,
    bool compact = false,
  }) => Act0AcademyDesignTokensV1.cardDecoration(
    borderColor: primary.withValues(alpha: 0.4),
  );
  static ButtonStyle primaryButtonStyle({double height = 52}) =>
      Act0AcademyDesignTokensV1.primaryButtonStyle().copyWith(
        minimumSize: WidgetStatePropertyAll(
          Size(double.infinity, height < 52 ? 52 : height),
        ),
      );
  static ButtonStyle premiumActionButtonStyle({double height = 52}) =>
      primaryButtonStyle(height: height);
  static ButtonStyle quietButtonStyle({double height = 48}) =>
      Act0AcademyDesignTokensV1.secondaryButtonStyle().copyWith(
        minimumSize: WidgetStatePropertyAll(
          Size(double.infinity, height < 48 ? 48 : height),
        ),
      );
  static ButtonStyle tonalButtonStyle({
    required Color tone,
    double height = 48,
    bool fullWidth = false,
  }) => Act0AcademyDesignTokensV1.secondaryButtonStyle().copyWith(
    foregroundColor: WidgetStatePropertyAll(tone),
    minimumSize: WidgetStatePropertyAll(
      Size(fullWidth ? double.infinity : 0, height < 48 ? 48 : height),
    ),
  );
}
