import 'package:flutter/material.dart';

class Act0VisualCanonV1 {
  Act0VisualCanonV1._();

  static const Color deepNavy = Color(0xFF081220);
  static const Color appBlack = Color(0xFF050B12);
  static const Color navySurface = Color(0xFF101A2B);
  static const Color navySurfaceSoft = Color(0xFF0D1726);
  static const Color bluePrimary = Color(0xFF1598FF);
  static const Color blueDeep = Color(0xFF0A64D8);
  static const Color cyanAccent = Color(0xFF25E6F2);
  static const Color goldAccent = Color(0xFFFFC84D);
  static const Color greenTable = Color(0xFF16C784);
  static const Color redDanger = Color(0xFFFF5A5A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB7C4D6);
  static const Color textTertiary = Color(0xFF7F91A8);
  static const Color textDisabled = Color(0xFF4E5D70);

  static BoxDecoration primaryCtaDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[cyanAccent, bluePrimary],
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: bluePrimary.withOpacity(0.34),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: cyanAccent.withOpacity(0.18),
          blurRadius: 30,
          offset: Offset.zero,
        ),
      ],
    );
  }
}

class Act0VisualMetricsV1 {
  Act0VisualMetricsV1._();

  static const double screenPaddingCompact = 16;
  static const double screenPaddingLarge = 20;
  static const double screenPaddingTablet = 24;
  static const double sectionGap = 16;
  static const double cardGap = 12;
  static const double innerGap = 10;
  static const double primaryRadius = 26;
  static const double secondaryRadius = 20;
  static const double chipRadius = 999;
  static const double primaryCtaHeight = 60;
  static const double secondaryCtaHeight = 46;
  static const double compactHeroMinHeight = 245;
  static const double compactHeroMaxHeight = 330;
}

class Act0TableFeltCanonV1 {
  Act0TableFeltCanonV1._();

  static const Color feltEdge = Color(0xFF041E1A);
  static const Color feltOuter = Color(0xFF063827);
  static const Color feltMid = Color(0xFF07583C);
  static const Color feltInner = Color(0xFF08704D);
  static const Color feltSoftLift = Color(0xFF0B8A5D);
  static const Color railOuter = Color(0xFF050D18);
  static const Color railMid = Color(0xFF0A1A2A);
  static const Color railInner = Color(0xFF10283A);
  static const Color railLine = Color(0xFF1A4960);
}

class Act0ShellTokensV1 {
  const Act0ShellTokensV1._();

  // Deep Ocean Gold v1.1 token guardrails:
  // - Felt stays green and gameplay-owned.
  // - Cyan is a focus/coach accent, not a general surface fill.
  // - Gold is reserved for mastery, reward, and milestone emphasis.
  // - Filled primary actions must keep safe contrast with their foreground.
  static const Color background = Act0VisualCanonV1.deepNavy;
  static const Color surface = Act0VisualCanonV1.navySurface;
  static const Color surface2 = Act0VisualCanonV1.navySurfaceSoft;
  static const Color surface3 = Act0VisualCanonV1.navySurface;
  static const Color border = Color(0xFF1F2E43);
  static const Color text = Act0VisualCanonV1.textPrimary;
  static const Color textMuted = Act0VisualCanonV1.textSecondary;
  static const Color textDim = Act0VisualCanonV1.textTertiary;
  static const Color primary = Act0VisualCanonV1.bluePrimary;
  static const Color primaryDark = Act0VisualCanonV1.deepNavy;
  static const Color onPrimary = Act0VisualCanonV1.textPrimary;
  static const Color actionBlue = Act0VisualCanonV1.bluePrimary;
  static const Color actionCyan = Act0VisualCanonV1.cyanAccent;
  static const Color actionNavy = Act0VisualCanonV1.navySurface;
  static const Color actionDeep = Act0VisualCanonV1.deepNavy;
  static const Color gold = Act0VisualCanonV1.goldAccent;
  static const Color info = Act0VisualCanonV1.cyanAccent;
  static const Color danger = Act0VisualCanonV1.redDanger;
  static const Color felt = Act0TableFeltCanonV1.feltMid;
  static const Color feltDark = Act0TableFeltCanonV1.feltEdge;
  static const Color feltLine = Act0TableFeltCanonV1.railLine;
  static const Color feltHighlight = Act0TableFeltCanonV1.feltInner;
  static const Color placementReportSurface = Act0VisualCanonV1.deepNavy;
  static const Color placementCoachSurface = Act0VisualCanonV1.navySurface;
  static const Color learnPathTaskSurface = Act0VisualCanonV1.navySurface;
  static const Color shadowSoft = Color(0x66000000);
  static const Color shadowSoftStrong = Color(0x77000000);
  static const Color runnerSharkBlue = Color(0xFF18C7E8);
  static const Color runnerSharkBlueDark = Color(0xFF06457B);
  static const Color runnerSharkGradientStart = Color(0xFF18C7E8);
  static const Color runnerSharkGradientEnd = Color(0xFF0EA5C6);
  static const Color runnerSharkHighlight = Color(0xFFE9FCFF);
  static const Color runnerSharkEye = Color(0xFF07111F);
  static const Color runnerPanelSurface = Color(0xFF0B1119);
  static const Color runnerTagBlue = Color(0xFF385B94);
  static const Color runnerGlass = Color(0xFF101724);
  static const Color runnerHintWarm = Color(0xFF241600);
  static const Color runnerSheetWarmStart = Color(0xFFFFFBF5);
  static const Color runnerSheetWarmEnd = Color(0xFFF4EFE6);
  static const Color runnerSheetNeutralStart = Color(0xFFFFFEFB);
  static const Color runnerSheetNeutralEnd = Color(0xFFF3EEE5);
  static const Color runnerAnswerDanger = Color(0xFFC93B3B);
  static const Color runnerAnswerText = Color(0xFF0B1324);

  static const double pageX = 16;
  static const double runnerPageX = 14;
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 20;
  static const double radiusSm = 10;
  static const double radiusBase = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusCard = 18;
  static const double radiusPanel = 20;
  static const double radiusXl = 22;
  static const double radiusXs = 8;
  static const double radius3xs = 6;
  static const double radius2xs = 4;
  static const double radiusXxl = 26;
  static const double radiusOverlay = 24;
  static const double radiusPill = radiusBase;
  static const double topBarHeight = 54;
  static const double bottomNavHeight = 66;
  static const double runnerActionDockMinHeight = 68;
  static const double brandTile = 32;
  static const double primaryCtaHeight = 52;
  static const double compactCtaHeight = 44;
  static const double progressHeight = 6;
  static const double refinedInstructionSlotHeight = 77;
  static const double iconTile = 44;
  static const double pathIcon = 48;
  static const double moduleIcon = 40;
  static const double seatMinWidth = 84;
  static const double compactSeatMinWidth = 72;
  static const double tableMaxWidth = 420;
  static const double runnerTableMaxWidth = 326;
  static const double handTableMaxWidth = 336;
  static const double tableAspect = 0.78;
  static const double handTableAspect = 0.75;
  static const double centerInfoWidth = 206;
  static const double tableOuterRadius = 142;
  static const double tableInnerRadius = 134;
  static const double heroCardWidth = 35;
  static const double heroCardHeight = 49;
  static const double boardCardWidth = 31;
  static const double boardCardHeight = 43;

  static const TextStyle screenTitle = TextStyle(
    color: text,
    fontSize: 24,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: text,
    fontSize: 17,
    height: 1.15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cardTitle = TextStyle(
    color: text,
    fontSize: 15,
    height: 1.18,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle body = TextStyle(
    color: text,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle muted = TextStyle(
    color: textMuted,
    fontSize: 12,
    height: 1.32,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle label = TextStyle(
    color: textMuted,
    fontSize: 10,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
  );

  static const TextStyle cta = TextStyle(
    color: onPrimary,
    fontSize: 14,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static BoxDecoration surfaceDecoration({
    Color? borderColor,
    bool glow = false,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(color: borderColor ?? border.withOpacity(0.86)),
      boxShadow: <BoxShadow>[
        const BoxShadow(
          color: Color(0x66000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
        if (glow)
          BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
      ],
    );
  }

  static BoxDecoration glassDecoration({bool top = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[surface2.withOpacity(0.92), surface.withOpacity(0.94)],
      ),
      border: Border(
        top: top
            ? BorderSide(color: border.withOpacity(0.85))
            : BorderSide.none,
        bottom: top
            ? BorderSide.none
            : BorderSide(color: border.withOpacity(0.85)),
      ),
    );
  }

  static BoxDecoration heroDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radiusXl),
      border: Border.all(color: primary.withOpacity(0.18)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          primary.withOpacity(0.06),
          surface,
          info.withOpacity(0.02),
        ],
      ),
      boxShadow: <BoxShadow>[
        const BoxShadow(
          color: Color(0x55000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: primary.withOpacity(0.06),
          blurRadius: 36,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static BoxDecoration tableRimDecoration() {
    return BoxDecoration(
      color: Act0TableFeltCanonV1.railOuter,
      borderRadius: BorderRadius.circular(tableOuterRadius),
      border: Border.all(color: Act0TableFeltCanonV1.railLine, width: 1.5),
      boxShadow: const <BoxShadow>[
        // Outer drop shadow
        BoxShadow(
          color: Color(0xD8000000),
          blurRadius: 50,
          offset: Offset(0, 30),
        ),
        // Faux 3D bevel / rim lip
        BoxShadow(
          color: Act0TableFeltCanonV1.railLine,
          blurRadius: 5,
          spreadRadius: 0,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Act0TableFeltCanonV1.railOuter,
          blurRadius: 12,
          spreadRadius: 5,
          offset: Offset(0, 6),
        ),
      ],
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Act0TableFeltCanonV1.railInner,
          Act0TableFeltCanonV1.railMid,
          Act0TableFeltCanonV1.railOuter,
        ],
        stops: [0, 0.48, 1],
      ),
    );
  }

  static BoxDecoration feltDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(tableInnerRadius),
      border: Border.all(color: feltLine, width: 2),
      gradient: RadialGradient(
        center: const Alignment(0, -0.12),
        radius: 1.08,
        colors: const <Color>[
          Act0TableFeltCanonV1.feltInner,
          Act0TableFeltCanonV1.feltMid,
          Act0TableFeltCanonV1.feltOuter,
          Act0TableFeltCanonV1.feltEdge,
        ],
        stops: const <double>[0, 0.44, 0.76, 1],
      ),
    );
  }

  static ButtonStyle primaryButtonStyle({double height = primaryCtaHeight}) {
    return FilledButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      minimumSize: Size(double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      textStyle: cta,
      elevation: 0,
    );
  }

  static BoxDecoration premiumActionSurfaceDecoration({
    double borderOpacity = 0.28,
    double glowOpacity = 0.18,
    bool compact = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(compact ? radiusLg : radiusXl),
      border: Border.all(color: actionCyan.withOpacity(borderOpacity)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          actionBlue.withOpacity(compact ? 0.20 : 0.24),
          actionCyan.withOpacity(compact ? 0.10 : 0.13),
          actionNavy.withOpacity(compact ? 0.96 : 0.98),
          actionDeep.withOpacity(0.99),
        ],
        stops: const <double>[0, 0.24, 0.7, 1],
      ),
      boxShadow: <BoxShadow>[
        const BoxShadow(
          color: Color(0x55000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: actionBlue.withOpacity(glowOpacity),
          blurRadius: compact ? 22 : 34,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static ButtonStyle premiumActionButtonStyle({
    double height = primaryCtaHeight,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: actionBlue,
      foregroundColor: onPrimary,
      minimumSize: Size(double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
        side: BorderSide(color: actionCyan.withOpacity(0.42)),
      ),
      textStyle: cta,
      elevation: 0,
      shadowColor: actionBlue.withOpacity(0.26),
    );
  }

  static ButtonStyle quietButtonStyle({double height = compactCtaHeight}) {
    return OutlinedButton.styleFrom(
      foregroundColor: text,
      minimumSize: Size(double.infinity, height),
      side: BorderSide(color: border.withOpacity(0.9)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
    );
  }

  static ButtonStyle tonalButtonStyle({
    required Color tone,
    double height = compactCtaHeight,
    bool fullWidth = false,
  }) {
    return FilledButton.styleFrom(
      minimumSize: Size(fullWidth ? double.infinity : 0, height),
      backgroundColor: tone.withOpacity(0.12),
      foregroundColor: tone,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      textStyle: body.copyWith(color: tone, fontWeight: FontWeight.w800),
      elevation: 0,
    );
  }

  static bool isTabletWidth(BuildContext context) {
    final media = MediaQuery.of(context);
    return media.size.shortestSide >= 700;
  }

  static double pageHorizontalPaddingFor(BuildContext context) {
    return isTabletWidth(context) ? 24 : pageX;
  }

  static double contentMaxWidthFor(
    BuildContext context, {
    double phone = 560,
    double tablet = 980,
  }) {
    return isTabletWidth(context) ? tablet : phone;
  }

  static double narrowContentMaxWidthFor(
    BuildContext context, {
    double phone = 560,
    double tablet = 860,
  }) {
    return isTabletWidth(context) ? tablet : phone;
  }

  static Widget centeredContent(
    BuildContext context, {
    required Widget child,
    double phoneMaxWidth = 560,
    double tabletMaxWidth = 980,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: contentMaxWidthFor(
            context,
            phone: phoneMaxWidth,
            tablet: tabletMaxWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}
