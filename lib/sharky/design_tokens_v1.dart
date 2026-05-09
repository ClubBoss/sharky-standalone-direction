import 'package:flutter/material.dart';

/// Single source of truth for Sharky Design System Freeze v1 tokens.
abstract class SharkyTokensV1 {
  SharkyTokensV1._();

  // Surfaces.
  static const Color surfaceApp = Color(0xFF020617);
  static const Color surfaceCard = Color(0xFF0B1320);
  static const Color surfaceElevated = Color(0xFF1C2436);
  static const Color surfaceFelt = Color(0xFF030712);

  // Typography colors.
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverted = Color(0xFF0F172A);

  // Brand colors.
  static const Color brandPrimary = Color(0xFF38BDF8);
  static const Color brandGlow = Color(0xFF8DECF7);

  // Semantic indicators.
  static const Color semanticWin = Color(0xFF10B981);
  static const Color semanticLoss = Color(0xFFEF4444);
  static const Color semanticInfo = Color(0xFF3B82F6);

  // Token accents.
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color emerald500 = Color(0xFF10B981);

  // Radius.
  static const double radiusSm = 6.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 24.0;
  static const double radiusFull = 999.0;

  // Elevationally.
  static const List<BoxShadow> elevation0 = <BoxShadow>[];
  static const List<BoxShadow> elevation1 = <BoxShadow>[
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 6),
  ];
  static const List<BoxShadow> elevation2 = <BoxShadow>[
    BoxShadow(color: Color(0x24000000), offset: Offset(0, 6), blurRadius: 12),
  ];
  static const List<BoxShadow> elevation3 = <BoxShadow>[
    BoxShadow(color: Color(0x2D000000), offset: Offset(0, 10), blurRadius: 18),
  ];
  static const List<BoxShadow> elevationGlowAction = <BoxShadow>[
    BoxShadow(color: brandGlow, blurRadius: 32, offset: Offset(0, 12)),
  ];

  // Opacity scale.
  static const double opacityDisabled = 0.32;
  static const double opacityFolded = 0.28;
  static const double opacityWatermark = 0.12;
  static const double opacityBackdrop = 0.7;

  static const List<FontFeature> _tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  // Typography presets.
  static const TextStyle displayLg = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: textPrimary,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle headingMd = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
    color: textPrimary,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle headingSm = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
    color: textPrimary,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textSecondary,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle labelXs = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
    color: textMuted,
    fontFeatures: _tabularFigures,
  );
}
