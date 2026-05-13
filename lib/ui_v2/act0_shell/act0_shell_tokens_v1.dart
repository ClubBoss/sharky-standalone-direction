import 'package:flutter/material.dart';

class Act0ShellTokensV1 {
  const Act0ShellTokensV1._();

  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF171B24);
  static const Color surface2 = Color(0xFF1D2430);
  static const Color surface3 = Color(0xFF252B36);
  static const Color border = Color(0xFF2B323E);
  static const Color text = Color(0xFFF3F6FA);
  static const Color textMuted = Color(0xFFA0A7B5);
  static const Color textDim = Color(0xFF667085);
  static const Color primary = Color(0xFF2FC77D);
  static const Color primaryDark = Color(0xFF0F2C20);
  static const Color onPrimary = Color(0xFF082015);
  static const Color gold = Color(0xFFF7B83E);
  static const Color info = Color(0xFF4EA3F8);
  static const Color danger = Color(0xFFE94F55);
  static const Color felt = Color(0xFF10261F);
  static const Color feltDark = Color(0xFF070C0F);
  static const Color feltLine = Color(0xFF1D5C42);
  static const Color placementReportSurface = Color(0xFF15202C);
  static const Color placementCoachSurface = Color(0xFF171A21);
  static const Color learnPathTaskSurface = Color(0xFF161C29);
  static const Color shadowSoft = Color(0x66000000);
  static const Color shadowSoftStrong = Color(0x77000000);
  static const Color runnerSharkBlue = Color(0xFF22A7E8);
  static const Color runnerSharkBlueDark = Color(0xFF06457B);
  static const Color runnerSharkGradientStart = Color(0xFF27C7F2);
  static const Color runnerSharkGradientEnd = Color(0xFF0878C9);
  static const Color runnerSharkHighlight = Color(0xFFE9FCFF);
  static const Color runnerSharkEye = Color(0xFF07111F);
  static const Color runnerPanelSurface = Color(0xFF1C2330);
  static const Color runnerTagBlue = Color(0xFF385B94);
  static const Color runnerGlass = Color(0xFF212936);
  static const Color runnerHintWarm = Color(0xFF241600);
  static const Color runnerSheetWarmStart = Color(0xFFFFFBF5);
  static const Color runnerSheetWarmEnd = Color(0xFFF4EFE6);
  static const Color runnerSheetNeutralStart = Color(0xFFFFFEFB);
  static const Color runnerSheetNeutralEnd = Color(0xFFF3EEE5);
  static const Color runnerAnswerDanger = Color(0xFFB3132B);
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
            color: primary.withOpacity(0.22),
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
      border: Border.all(color: primary.withOpacity(0.32)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          primary.withOpacity(0.24),
          surface,
          info.withOpacity(0.10),
        ],
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: primary.withOpacity(0.22),
          blurRadius: 36,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static BoxDecoration tableRimDecoration() {
    return BoxDecoration(
      color: const Color(0xFF050807),
      borderRadius: BorderRadius.circular(tableOuterRadius),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0xAA000000),
          blurRadius: 44,
          offset: Offset(0, 24),
        ),
        BoxShadow(color: Color(0xFF05090A), blurRadius: 0, spreadRadius: 6),
        BoxShadow(color: Color(0x554F3B18), blurRadius: 0, spreadRadius: 8),
      ],
    );
  }

  static BoxDecoration feltDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(tableInnerRadius),
      border: Border.all(color: feltLine.withOpacity(0.46), width: 1.2),
      gradient: const RadialGradient(
        radius: 0.96,
        colors: <Color>[Color(0xFF153C2D), Color(0xFF0D1E1C), feltDark],
        stops: <double>[0, 0.58, 1],
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
}
