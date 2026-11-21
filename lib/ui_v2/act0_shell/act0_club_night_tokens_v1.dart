import 'dart:ui' show FontFeature;

import 'package:flutter/widgets.dart';

/// Shared visual tokens for the V6 design comparison.
///
/// Draft C uses an opaque ink-blue base, silver-blue secondary text and
/// sea-glass accents for controls. Red and green still encode feedback.
class Act0ClubNightTokensV1 {
  const Act0ClubNightTokensV1._();

  // Colour. Contrast against [wall] is noted where text uses the colour.
  static const Color wall = Color(0xFF0B1624);
  static const Color surface = Color(0xFF11243A);
  static const Color raised = Color(0xFF192E45);
  static const Color track = Color(0xFF2C445D);
  static const Color scrim = Color(0xAA08111C);

  /// Blue-gray outlines for cards, controls and emphasis.
  static const Color hairline = Color(0x20BCD9F0);
  static const Color hairlineStrong = Color(0x38BCD9F0);
  static const Color hairlineRing = Color(0x55BCD9F0);

  static const Color text = Color(0xFFF2F6FA);
  static const Color text2 = Color(0xFFC1D0E1);
  static const Color caption = Color(0xFFA0B5C9);

  static const Color brass = Color(0xFF75E3DC);
  static const Color onBrass = Color(0xFF081E28);
  static const Color brassSoft = Color(0x2675E3DC);
  static const Color brassEdge = Color(0x6475E3DC);

  static const Color correct = Color(0xFF6FDCAB);
  static const Color correctSoft = Color(0x206FDCAB);
  static const Color mistake = Color(0xFFFFA99A);
  static const Color mistakeSoft = Color(0x24FFA99A);
  static const Color mistakeEdge = Color(0x75FFA99A);

  // Spacing on a 4 pt grid.
  static const double screenGutter = 20;
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;
  static const double cardPadding = 20;

  // Radius.
  static const double radiusControl = 14;
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
    fontSize: 34,
    height: 41 / 34,
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
