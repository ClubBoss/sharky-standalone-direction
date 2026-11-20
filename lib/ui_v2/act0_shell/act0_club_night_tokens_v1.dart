import 'dart:ui' show FontFeature;

import 'package:flutter/widgets.dart';

/// Club Night: the one visual system for every Act0 screen around the table.
///
/// Approved by the owner on 2026-11-20 (canvas
/// https://claude.ai/artifact/5Lq5BKjKKHXcBoJ8rLc8yt). Every screen is the
/// same evening club room: the wall colour of the table scene, one brass
/// action per screen, green only for "correct", coral only for a mistake,
/// the system font on the iOS type scale, no shadows, gradients or photos
/// behind text.
///
/// This is the single source for colour, type, spacing, radius and motion.
/// The table scene, its geometry and its seat labels are not styled here.
class Act0ClubNightTokensV1 {
  const Act0ClubNightTokensV1._();

  // Colour. Contrast against [wall] is noted where text uses the colour.
  static const Color wall = Color(0xFF0E1311);
  static const Color surface = Color(0xFF161D1A);
  static const Color raised = Color(0xFF1F2925);
  static const Color track = Color(0xFF2A3430);
  static const Color scrim = Color(0x9E050807);

  /// Brass hairline, 10 % for cards and 14 % for controls.
  static const Color hairline = Color(0x1AE8D6AA);
  static const Color hairlineStrong = Color(0x24E8D6AA);
  static const Color hairlineRing = Color(0x4DE8D6AA);

  static const Color text = Color(0xFFF4EFE4); // 16.4:1
  static const Color text2 = Color(0xFFB8B2A3); // 8.9:1
  static const Color caption = Color(0xFF9C9789); // 6.4:1, 5.1:1 on raised

  static const Color brass = Color(0xFFD8B46A); // 9.5:1
  static const Color onBrass = Color(0xFF1A1508); // 9.2:1 on brass
  static const Color brassSoft = Color(0x29D8B46A);
  static const Color brassEdge = Color(0x47D8B46A);

  static const Color correct = Color(0xFF4FC891); // 8.9:1
  static const Color correctSoft = Color(0x1A4FC891);
  static const Color mistake = Color(0xFFFF8A73); // 8.2:1
  static const Color mistakeSoft = Color(0x1FFF8A73);
  static const Color mistakeEdge = Color(0x8CFF8A73);

  // Spacing on a 4 pt grid.
  static const double screenGutter = 20;
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;
  static const double cardPadding = 20;

  // Radius.
  static const double radiusControl = 16;
  static const double radiusGroup = 16;
  static const double radiusCard = 20;
  static const double radiusSheet = 28;

  // Size.
  static const double controlHeight = 56;
  static const double minTouch = 44;
  static const double ringSmall = 56;
  static const double ringLarge = 120;
  static const double maxTextScale = 1.3;

  // Motion: one spring-like curve for everything.
  static const Duration motion = Duration(milliseconds: 350);
  static const Curve motionCurve = Curves.easeOutCubic;
  static const double pressedScale = 0.97;

  // Type: the platform system font (SF Pro on iOS) on the iOS scale.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle figure = TextStyle(
    color: text,
    fontSize: 34,
    height: 41 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    fontFeatures: tabular,
  );
  static const TextStyle title = TextStyle(
    color: text,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const TextStyle question = TextStyle(
    color: text,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle headline = TextStyle(
    color: text,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    color: text,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle secondary = TextStyle(
    color: text2,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle captionStyle = TextStyle(
    color: caption,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle sectionLabel = TextStyle(
    color: caption,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  static const TextStyle button = TextStyle(
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle link = TextStyle(
    color: brass,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle tag = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle tab = TextStyle(
    fontSize: 11,
    height: 13 / 11,
    fontWeight: FontWeight.w600,
  );

  static const BorderSide cardBorder = BorderSide(color: hairline);
  static const BorderSide controlBorder = BorderSide(color: hairlineStrong);
}
