import 'package:flutter/material.dart';

/// Semantic Act0 paint roles. Editorial and navy values preserve the existing
/// treatments used alongside Club Night during the screen migration.
class Act0SkinTokensV1 {
  const Act0SkinTokensV1._();

  // Colour. Contrast against [background] is noted for the foreground roles.
  static const Color background = Color(0xFF0E1311);
  static const Color surface = Color(0xFF161D1A);
  static const Color raised = Color(0xFF1F2925);
  static const Color track = Color(0xFF2A3430);
  static const Color scrim = Color(0x9E050807);

  /// Brass line, 10 % for cards and 14 % for controls.
  static const Color line = Color(0x1AE8D6AA);
  static const Color lineStrong = Color(0x24E8D6AA);
  static const Color lineRing = Color(0x4DE8D6AA);

  static const Color onSurface = Color(0xFFF4EFE4); // 16.4:1
  static const Color muted = Color(0xFFB8B2A3); // 8.9:1
  static const Color caption = Color(0xFF9C9789); // 6.4:1, 5.1:1 on raised

  static const Color accent = Color(0xFFD8B46A); // 9.5:1
  static const Color onAccent = Color(0xFF1A1508); // 9.2:1 on accent
  static const Color accentSoft = Color(0x29D8B46A);
  static const Color accentEdge = Color(0x47D8B46A);

  static const Color ok = Color(0xFF4FC891); // 8.9:1
  static const Color okSoft = Color(0x1A4FC891);
  static const Color bad = Color(0xFFFF8A73); // 8.2:1
  static const Color badSoft = Color(0x1FFF8A73);
  static const Color badEdge = Color(0x8CFF8A73);

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
    color: onSurface,
    fontSize: 34,
    height: 41 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    fontFeatures: tabular,
  );
  static const TextStyle title = TextStyle(
    color: onSurface,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const TextStyle question = TextStyle(
    color: onSurface,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle headline = TextStyle(
    color: onSurface,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    color: onSurface,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle secondary = TextStyle(
    color: muted,
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
    color: accent,
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

  static const BorderSide cardBorder = BorderSide(color: line);
  static const BorderSide controlBorder = BorderSide(color: lineStrong);

  // Editorial reading surfaces.
  static const Color editorialPageSurface = Color(0xFFF7F5ED);
  static const Color editorialCardSurface = Color(0xFFFFFEF9);
  static const Color editorialInk = Color(0xFF182E32);
  static const Color editorialInkMuted = Color(0xFF536560);
  static const Color editorialFocus = Color(0xFF126761);
  static const Color editorialPrimaryAction = Color(0xFF17393A);
  static const Color editorialOnPrimaryAction = Color(0xFFFFFEF8);
  static const Color editorialNeedsReviewFg = Color(0xFF7F4C13);
  static const Color editorialNeedsReviewBg = Color(0xFFF2E5CD);
  static const Color editorialCorrectFg = Color(0xFF226844);
  static const Color editorialCorrectBg = Color(0xFFE1EEE2);
  // Folio material accents are confined to Academy presentation.
  static const Color editorialFolioBrass = Color(0xFFE4CDA5);
  static const Color editorialFolioEditorial = Color(0xFF7A414D);
  static const Color editorialRule = Color(0xFFCBD1C7);

  static const double editorialGapXs = 8;
  static const double editorialGapSm = 12;
  static const double editorialGapMd = 16;
  static const double editorialGapLg = 20;
  static const double editorialGapXl = 24;

  static const double editorialRadiusCard = 6;
  static const double editorialRadiusCoachFrame = 12;

  // Display/section/lesson sizes follow the approved Editorial Tide rhythm.
  // Georgia is requested from the OS, never copied or fetched. Platforms
  // without it use their installed serif fallback; native fidelity is gated.
  static const String editorialDisplayFont = 'Georgia';
  static const List<String> editorialDisplayFallback = [
    'Times New Roman',
    'Noto Serif',
    'serif',
  ];
  static const TextStyle editorialDisplay = TextStyle(
    fontFamily: editorialDisplayFont,
    fontFamilyFallback: editorialDisplayFallback,
    color: editorialInk,
    fontSize: 38,
    height: 1.12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle editorialSectionHeading = TextStyle(
    fontFamily: editorialDisplayFont,
    fontFamilyFallback: editorialDisplayFallback,
    color: editorialInk,
    fontSize: 24,
    height: 1.14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle editorialLessonHeading = TextStyle(
    fontFamily: editorialDisplayFont,
    fontFamilyFallback: editorialDisplayFallback,
    color: editorialInk,
    fontSize: 30,
    height: 1.16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle editorialBody = TextStyle(
    fontFamily: 'Arial',
    fontFamilyFallback: ['Roboto', 'sans-serif'],
    color: editorialInk,
    fontSize: 14,
    height: 1.6,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle editorialSupporting = TextStyle(
    fontFamily: 'Arial',
    fontFamilyFallback: ['Roboto', 'sans-serif'],
    color: editorialInkMuted,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle editorialLabel = TextStyle(
    fontFamily: 'Arial',
    fontFamilyFallback: ['Roboto', 'sans-serif'],
    color: editorialInkMuted,
    fontSize: 10,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  // Shell motion.
  /// Small settle-in motion (a card/line arriving after a state change).
  static const Duration micro = Duration(milliseconds: 140);

  /// Ordinary transitions/navigation-scale reveals.
  static const Duration standard = Duration(milliseconds: 260);

  /// Chip/table-adjacent or stronger confirmation moments.
  static const Duration emphasis = Duration(milliseconds: 420);

  /// Rare, high-stakes payoff moments only (world/band completion).
  static const Duration milestone = Duration(milliseconds: 900);

  /// Anything appearing.
  static const Curve enter = Curves.easeOutCubic;

  /// Anything leaving/fading out.
  static const Curve exit = Curves.easeIn;

  /// A value/position resolving to its final state.
  static const Curve settle = Curves.easeInOutCubic;

  /// The accented portion of a milestone/confirmation composite.
  static const Curve emphasisCurve = Curves.easeOut;

  // Existing paint roles used alongside Club Night.
  static const warn = accent;
  static const feltCenter = Color(0xFF146B56);
  static const feltMid = Color(0xFF0F5A47);
  static const feltEdge = Color(0xFF0B4A3B);
  static const navySurface = Color(0xFF101A2B);
  static const navyRaised = Color(0xFF0D1726);
  static const navyLine = Color(0xFF1F2E43);
  static const navyAccent = Color(0xFF0A64D8);
  static const navyOnSurface = Color(0xFFFFFFFF);
  static const navyMuted = Color(0xFFB7C4D6);
  static const navyOk = Color(0xFF16C784);
  static const navyWarn = Color(0xFFFFC84D);
  static const navyBad = Color(0xFFFF5A5A);
  static const controlElevation = 0.0;

  static const academyBackground = Color(0xFF020E13);
  static const academyRaised = Color(0xFF071C24);
  static const academyTealDeep = Color(0xFF0B3530);
  static const academyTeal = Color(0xFF177D70);
  static const academyAccent = Color(0xFF23E6D2);
  static const academyAccentSoft = Color(0xFFB9F5E9);
  static const academyOnSurface = Color(0xFFF1FBF8);
  static const academyMuted = Color(0xFFB6C8D5);
  static const academyLine = Color(0xFF23443F);
  static const academyWarn = Color(0xFFF2C46B);

  static const courseProgressTrack = Color(0xFF102A35);
  static const courseProgressFill = academyAccent;
  static const courseProgressHeight = 12.0;
  static const courseProgressRadius = 7.0;

  // Existing Material glyphs. Expose roles so asset choices stay in the skin.
  static const expandIcon = Icons.expand_more;
  static const collapseIcon = Icons.expand_less;
  static const correctIcon = Icons.check_rounded;
  static const mistakeIcon = Icons.close_rounded;

  // Today all four expressions use the same asset with distinct ring roles.
  static const sharkyHintAsset =
      'assets/images/mascot/sharky_neutral_fallback_v1.png';
  static const sharkyMistakeAsset = sharkyHintAsset;
  static const sharkyFixedItAsset = sharkyHintAsset;
  static const sharkyLessonDoneAsset = sharkyHintAsset;

  static const reviewEmptyTitle = TextStyle(
    color: academyOnSurface,
    fontSize: 25,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const reviewEmptyBody = TextStyle(
    color: academyMuted,
    fontSize: 14,
    height: 1.4,
  );
  static const navyStatLabel = TextStyle(
    color: navyMuted,
    fontSize: 10,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
  );
  static const navyStatValue = TextStyle(
    color: navyOnSurface,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );
  static const navyStatSupport = TextStyle(
    color: navyMuted,
    fontSize: 12,
    height: 1.32,
    fontWeight: FontWeight.w600,
  );
  static const navyCompactStatRadius = 14.0;
  static const navyStatRadius = 16.0;
  static const navyStatShadow = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 18,
    offset: Offset(0, 10),
  );

  static Color themeSurface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Duration durationFor(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
