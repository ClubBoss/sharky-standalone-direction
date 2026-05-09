import 'package:flutter/material.dart';

import '../theme/theme_v2.dart';
import 'v4_token_registry.dart';
import 'visual_cohesion_tokens_v3.dart';
import 'v4_visual_qa_snapshot_v1.dart';
import 'v4_visual_qa_cohesion_bridge_v1.dart';

class V4ThemeDataBuilder {
  bool _runtimeActive = false;

  bool get isRuntimeV4Enabled => _runtimeActive;
  bool get isV4RuntimeReady => _runtimeActive;
  bool get runtimeV4IntegrationIsStable => _runtimeActive;
  ThemeData build(ThemeData base, bool isActive, V4TokenRegistry tokens) {
    _runtimeActive = isActive;
    if (!isActive) return base;
    final registry = <String, Object>{
      'scale_body': tokens.v4FontScaleBody,
      'scale_title': tokens.v4FontScaleTitle,
      'font_body': tokens.v4FontWeightBody,
      'font_title': tokens.v4FontWeightTitle,
      'letter_spacing_body': tokens.v4LetterSpacingDelta,
      'letter_spacing_title': tokens.v4LetterSpacingDelta,
    };
    double _registryDouble(String key, double fallback) {
      final value = registry[key];
      if (value is num) return value.toDouble();
      return fallback;
    }

    int _registryInt(String key, int fallback) {
      final value = registry[key];
      if (value is num) return value.toInt();
      return fallback;
    }

    final scaleBody = _registryDouble('scale_body', tokens.v4FontScaleBody);
    final scaleTitle = _registryDouble('scale_title', tokens.v4FontScaleTitle);
    final weightBody = _registryInt('font_body', tokens.v4FontWeightBody);
    final weightTitle = _registryInt('font_title', tokens.v4FontWeightTitle);
    final letterSpacingBody = _registryDouble(
      'letter_spacing_body',
      tokens.v4LetterSpacingDelta,
    );
    final letterSpacingTitle = _registryDouble(
      'letter_spacing_title',
      tokens.v4LetterSpacingDelta,
    );
    final scheme = base.colorScheme;
    final tintedSurface = tokens.v4FinalSurfaceColor;
    final overlayOpacity = (tokens.v4FinalShadow * 0.02).clamp(0.0, 1.0);
    final motionTint = _blend(tintedSurface, tokens.v4MotionAlpha);
    final shadowShift = _shiftColor(
      tokens.v4FinalAccentColor,
      tokens.v4MotionShift,
    );
    final overlayColor = scheme.surfaceContainerHighest.withAlpha(
      (tokens.v4MotionOverlay * 255).round().clamp(0, 255),
    );
    final themeText = base.textTheme.copyWith(
      bodySmall: _adjustV4TextStyle(
        base.textTheme.bodySmall,
        scale: scaleBody,
        weightDelta: weightBody,
        letterSpacingDelta: letterSpacingBody,
        fontSizeOverride: tokens.v4FontSizeBody,
        letterSpacingOverride: tokens.v4LetterSpacingBody,
      ),
      bodyMedium: _adjustV4TextStyle(
        base.textTheme.bodyMedium,
        scale: scaleBody,
        weightDelta: weightBody,
        letterSpacingDelta: letterSpacingBody,
        fontSizeOverride: tokens.v4FontSizeBody,
        letterSpacingOverride: tokens.v4LetterSpacingBody,
      ),
      bodyLarge: _adjustV4TextStyle(
        base.textTheme.bodyLarge,
        scale: scaleBody,
        weightDelta: weightBody,
        letterSpacingDelta: letterSpacingBody,
        fontSizeOverride: tokens.v4FontSizeBody,
        letterSpacingOverride: tokens.v4LetterSpacingBody,
      ),
      titleSmall: _adjustV4TextStyle(
        base.textTheme.titleSmall,
        scale: scaleTitle,
        weightDelta: weightTitle,
        letterSpacingDelta: letterSpacingTitle,
        fontSizeOverride: tokens.v4FontSizeTitle,
        letterSpacingOverride: tokens.v4LetterSpacingTitle,
      ),
      titleMedium: _adjustV4TextStyle(
        base.textTheme.titleMedium,
        scale: scaleTitle,
        weightDelta: weightTitle,
        letterSpacingDelta: letterSpacingTitle,
        fontSizeOverride: tokens.v4FontSizeTitle,
        letterSpacingOverride: tokens.v4LetterSpacingTitle,
      ),
      titleLarge: _adjustV4TextStyle(
        base.textTheme.titleLarge,
        scale: scaleTitle,
        weightDelta: weightTitle,
        letterSpacingDelta: letterSpacingTitle,
        fontSizeOverride: tokens.v4FontSizeTitle,
        letterSpacingOverride: tokens.v4LetterSpacingTitle,
      ),
    );
    final baseFilledStyle =
        (base.filledButtonTheme.style ??
                FilledButton.styleFrom(backgroundColor: tintedSurface))
            .copyWith(backgroundColor: WidgetStatePropertyAll(tintedSurface));
    final cohesionPreview = componentCohesionPreview;
    final radiusBase =
        (cohesionPreview['radiusBase'] as num?)?.toDouble() ?? tokens.v4RadiusM;
    final spacingSm =
        (cohesionPreview['spacingSm'] as num?)?.toDouble() ?? tokens.v4SpacingS;
    final spacingMd =
        (cohesionPreview['spacingMd'] as num?)?.toDouble() ?? tokens.v4SpacingM;
    final elevationLow =
        (cohesionPreview['elevationLow'] as num?)?.toDouble() ??
        tokens.v4FinalShadow;
    final shadowSoftList =
        (cohesionPreview['shadowSoft'] as List<BoxShadow>?) ??
        VisualCohesionTokensV3.shadowSoft;
    final shadowBaseColor = shadowSoftList.isNotEmpty
        ? shadowSoftList.first.color
        : shadowShift;
    final shadowColor = shadowBaseColor.withOpacity(
      tokens.v4ShadowOpacity.clamp(0.0, 1.0),
    );
    final appliedShadowList = shadowSoftList.isNotEmpty
        ? shadowSoftList
              .map(
                (shadow) => shadow.copyWith(
                  color: shadowColor,
                  blurRadius: tokens.v4ShadowBlur,
                ),
              )
              .toList(growable: false)
        : <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: tokens.v4ShadowBlur,
              offset: const Offset(0, 2),
            ),
          ];
    final cohesiveButtonStyle = ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusBase)),
      ),
      elevation: WidgetStateProperty.all(elevationLow),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
      ),
      shadowColor: WidgetStateProperty.all(shadowColor),
    );
    ButtonStyle mergeCohesion(ButtonStyle style) {
      return style.copyWith(
        shape: cohesiveButtonStyle.shape,
        elevation: cohesiveButtonStyle.elevation,
        padding: cohesiveButtonStyle.padding,
        shadowColor: cohesiveButtonStyle.shadowColor,
      );
    }

    final v4SegmentedButtonTheme = base.segmentedButtonTheme.copyWith(
      style: mergeCohesion(
        base.segmentedButtonTheme.style ??
            ElevatedButton.styleFrom(backgroundColor: tintedSurface),
      ),
    );
    final v4ElevatedButtonTheme = ElevatedButtonThemeData(
      style: mergeCohesion(
        base.elevatedButtonTheme.style ??
            ElevatedButton.styleFrom(backgroundColor: tintedSurface),
      ),
    );
    final v4OutlinedButtonTheme = OutlinedButtonThemeData(
      style: mergeCohesion(
        base.outlinedButtonTheme.style ??
            OutlinedButton.styleFrom(backgroundColor: tintedSurface),
      ),
    );
    final v4TextButtonTheme = TextButtonThemeData(
      style: mergeCohesion(
        base.textButtonTheme.style ??
            TextButton.styleFrom(backgroundColor: tintedSurface),
      ),
    );
    final buttonStyle = mergeCohesion(
      baseFilledStyle,
    ).copyWith(elevation: cohesiveButtonStyle.elevation);
    final v4CardTheme = base.cardTheme.copyWith(
      color: tintedSurface,
      elevation: elevationLow,
      surfaceTintColor: tintedSurface,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      margin: EdgeInsets.all(tokens.v4SpacingM),
      clipBehavior: Clip.antiAlias,
    );
    final v4ChipTheme = base.chipTheme.copyWith(
      backgroundColor: tintedSurface,
      elevation: elevationLow,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      labelPadding: EdgeInsets.all(spacingSm),
      padding: EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
      labelStyle: _adjustV4TextStyle(
        base.chipTheme.labelStyle ?? base.textTheme.bodyMedium,
        scale: scaleBody,
        weightDelta: weightBody,
        letterSpacingDelta: letterSpacingBody,
        fontSizeOverride: tokens.v4FontSizeBody,
        letterSpacingOverride: tokens.v4LetterSpacingBody,
      ),
    );
    final iconColor = _scaleColor(scheme.onSurface, tokens.v4IconTone);
    final v4IconTheme = base.iconTheme.copyWith(
      size: tokens.v4IconSizeM,
      opacity: tokens.v4IconOpacity,
    );
    final v4FloatingActionButtonTheme = base.floatingActionButtonTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      focusElevation: elevationLow,
      hoverElevation: elevationLow,
      highlightElevation: elevationLow,
      extendedPadding: EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
    );
    final v4PopupMenuTheme = base.popupMenuTheme.copyWith(
      color: tintedSurface,
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      shadowColor: shadowColor,
    );
    final v4DialogTheme = base.dialogTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      insetPadding: EdgeInsets.all(spacingMd),
      shadowColor: shadowColor,
      clipBehavior: Clip.antiAlias,
    );
    final v4DividerTheme = base.dividerTheme.copyWith(
      color: tintedSurface,
      thickness: 1.5,
    );
    OutlineInputBorder _radiusInputBorder(InputBorder? border) {
      if (border is OutlineInputBorder) {
        return border.copyWith(borderRadius: BorderRadius.circular(radiusBase));
      }
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      );
    }

    final v4ListTileTheme = base.listTileTheme.copyWith(
      iconColor: iconColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
      titleTextStyle: _adjustV4TextStyle(
        base.listTileTheme.titleTextStyle ?? base.textTheme.bodyLarge,
        scale: scaleBody,
        weightDelta: weightBody,
        letterSpacingDelta: letterSpacingBody,
        fontSizeOverride: tokens.v4FontSizeBody,
        letterSpacingOverride: tokens.v4LetterSpacingBody,
      ),
    );
    final v4CheckboxTheme = base.checkboxTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
    );
    final iconBaseline =
        base.navigationRailTheme.unselectedIconTheme ?? base.iconTheme;
    final selectedIconBaseline =
        base.navigationRailTheme.selectedIconTheme ?? iconBaseline;
    final navigationRailLabelStyle = _adjustV4TextStyle(
      base.navigationRailTheme.unselectedLabelTextStyle ??
          base.navigationRailTheme.selectedLabelTextStyle ??
          base.textTheme.bodyLarge,
      scale: scaleBody,
      weightDelta: weightBody,
      letterSpacingDelta: letterSpacingBody,
      fontSizeOverride: tokens.v4FontSizeBody,
      letterSpacingOverride: tokens.v4LetterSpacingBody,
    );
    final v4NavigationRailTheme = base.navigationRailTheme.copyWith(
      unselectedIconTheme: iconBaseline.copyWith(
        size: (iconBaseline.size ?? 24.0) * 1.01,
        color: iconColor,
      ),
      selectedIconTheme: selectedIconBaseline.copyWith(
        size: (selectedIconBaseline.size ?? 24.0) * 1.06,
        color: scheme.primary,
      ),
      unselectedLabelTextStyle: navigationRailLabelStyle,
      selectedLabelTextStyle: navigationRailLabelStyle,
      backgroundColor: tintedSurface,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
    );
    final tooltipShadow = appliedShadowList
        .map(
          (shadow) => shadow.copyWith(
            blurRadius: shadow.blurRadius + elevationLow * 0.05,
          ),
        )
        .toList(growable: false);
    final v4TooltipTheme = base.tooltipTheme.copyWith(
      decoration: BoxDecoration(
        color: tintedSurface,
        borderRadius: BorderRadius.circular(radiusBase),
        boxShadow: tooltipShadow,
      ),
      padding:
          base.tooltipTheme.padding ??
          EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm),
      margin: EdgeInsets.all(spacingMd),
      textStyle: _adjustV4TextStyle(
        base.tooltipTheme.textStyle ?? base.textTheme.bodySmall,
        scale: scaleBody,
        weightDelta: weightBody,
        letterSpacingDelta: letterSpacingBody,
        fontSizeOverride: tokens.v4FontSizeBody,
        letterSpacingOverride: tokens.v4LetterSpacingBody,
      ),
    );
    final v4SnackBarTheme = base.snackBarTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      behavior: base.snackBarTheme.behavior ?? SnackBarBehavior.floating,
      backgroundColor: base.snackBarTheme.backgroundColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
    );
    final indicatorColor = base.tabBarTheme.indicatorColor ?? scheme.primary;
    final v4TabBarTheme = base.tabBarTheme.copyWith(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusBase),
        color: indicatorColor,
        boxShadow: tooltipShadow,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
    );
    final v4SliderTheme = base.sliderTheme.copyWith(
      trackHeight: spacingSm,
      overlayShape: RoundSliderOverlayShape(overlayRadius: radiusBase),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: radiusBase),
      trackShape: RoundedRectSliderTrackShape(),
    );
    final sheetConstraints = BoxConstraints(
      minWidth: spacingMd,
      minHeight: spacingSm,
    );
    final v4BottomSheetTheme = base.bottomSheetTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      shadowColor: shadowColor,
      clipBehavior: Clip.antiAlias,
      constraints: sheetConstraints,
    );
    final v4MenuBarTheme = MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(tintedSurface),
        elevation: WidgetStateProperty.all(tokens.v4ElevLow),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.v4RadiusBase),
          ),
        ),
      ),
    );
    final v4MenuButtonTheme = MenuButtonThemeData(
      style: mergeCohesion(
        (base.menuButtonTheme.style ?? ButtonStyle()).copyWith(
          backgroundColor: WidgetStateProperty.all(tintedSurface),
          elevation: WidgetStateProperty.all(tokens.v4ElevLow),
        ),
      ),
    );
    final v4AppBarTheme = base.appBarTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      shadowColor: shadowColor,
      titleSpacing: spacingMd,
    );
    final v4NavigationBarTheme = base.bottomNavigationBarTheme.copyWith(
      elevation: elevationLow,
    );
    final brand = base.extension<BrandTheme>() ?? const BrandTheme();
    final v4Brand = brand.copyWith(
      radius: tokens.v4RadiusBase,
      elevationLow: tokens.v4ElevLow,
      elevationMed: tokens.v4ElevMed,
      spacingSmall: tokens.v4SpacingSmall,
      spacingMedium: tokens.v4SpacingMedium,
      spacingLarge: tokens.v4SpacingLarge,
      primaryBrand: _adjustNeutral(
        brand.primaryBrand,
        tokens.v4SurfaceNeutralHigh,
      ),
      accentSuccess: _adjustRoleTone(
        brand.accentSuccess,
        tokens.v4RoleAccentTone,
      ),
      textPrimary: _adjustNeutral(
        brand.textPrimary,
        tokens.v4SurfaceNeutralLow,
      ),
      textSecondary: _adjustNeutral(
        brand.textSecondary,
        tokens.v4SurfaceNeutralLow,
      ),
    );
    final otherExtensions = base.extensions.entries
        .where((entry) => entry.value is! BrandTheme)
        .map((entry) => entry.value)
        .toList(growable: false);
    return base.copyWith(
      colorScheme: scheme.copyWith(
        surface: tintedSurface,
        surfaceTint: motionTint,
        surfaceContainerHighest: overlayColor,
      ),
      textTheme: themeText,
      shadowColor: shadowShift.withAlpha(
        (overlayOpacity * 255).round().clamp(0, 255),
      ),
      cardTheme: v4CardTheme,
      chipTheme: v4ChipTheme,
      segmentedButtonTheme: v4SegmentedButtonTheme,
      elevatedButtonTheme: v4ElevatedButtonTheme,
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: v4OutlinedButtonTheme,
      textButtonTheme: v4TextButtonTheme,
      checkboxTheme: v4CheckboxTheme,
      floatingActionButtonTheme: v4FloatingActionButtonTheme,
      iconTheme: v4IconTheme.copyWith(color: iconColor),
      popupMenuTheme: v4PopupMenuTheme,
      dividerTheme: v4DividerTheme,
      dialogTheme: v4DialogTheme,
      listTileTheme: v4ListTileTheme,
      tooltipTheme: v4TooltipTheme,
      navigationRailTheme: v4NavigationRailTheme,
      menuBarTheme: v4MenuBarTheme,
      menuButtonTheme: v4MenuButtonTheme,
      appBarTheme: v4AppBarTheme,
      snackBarTheme: v4SnackBarTheme,
      bottomSheetTheme: v4BottomSheetTheme,
      tabBarTheme: v4TabBarTheme,
      sliderTheme: v4SliderTheme,
      bottomNavigationBarTheme: v4NavigationBarTheme,
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: _radiusInputBorder(base.inputDecorationTheme.border),
        enabledBorder: _radiusInputBorder(
          base.inputDecorationTheme.enabledBorder,
        ),
        focusedBorder: _radiusInputBorder(
          base.inputDecorationTheme.focusedBorder,
        ),
        errorBorder: _radiusInputBorder(base.inputDecorationTheme.errorBorder),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
      extensions: [v4Brand, ...otherExtensions],
    );
  }

  VisualCohesionTokensV3 get visualCohesionTokensV3 =>
      const VisualCohesionTokensV3();

  Map<String, Object> _adoptVisualCohesionTokensV3() {
    return {
      'radiusS': VisualCohesionTokensV3.radiusS,
      'radiusM': VisualCohesionTokensV3.radiusM,
      'radiusL': VisualCohesionTokensV3.radiusL,
      'spacingS': VisualCohesionTokensV3.spacingS,
      'spacingM': VisualCohesionTokensV3.spacingM,
      'spacingL': VisualCohesionTokensV3.spacingL,
      'elevationS': VisualCohesionTokensV3.elevationS,
      'elevationM': VisualCohesionTokensV3.elevationM,
      'elevationL': VisualCohesionTokensV3.elevationL,
      'shadowSoft': VisualCohesionTokensV3.shadowSoft,
      'shadowStrong': VisualCohesionTokensV3.shadowStrong,
    };
  }

  Map<String, Object> get visualCohesionPreview =>
      _adoptVisualCohesionTokensV3();

  Map<String, Object> _passiveComponentCohesionSync() {
    return {
      'radiusBase': VisualCohesionTokensV3.radiusM,
      'spacingSm': VisualCohesionTokensV3.spacingS,
      'spacingMd': VisualCohesionTokensV3.spacingM,
      'spacingLg': VisualCohesionTokensV3.spacingL,
      'elevationLow': VisualCohesionTokensV3.elevationS,
      'elevationMid': VisualCohesionTokensV3.elevationM,
      'elevationHigh': VisualCohesionTokensV3.elevationL,
      'shadowSoft': VisualCohesionTokensV3.shadowSoft,
      'shadowStrong': VisualCohesionTokensV3.shadowStrong,
    };
  }

  Map<String, Object> get componentCohesionPreview =>
      _passiveComponentCohesionSync();

  Map<String, double> exportPersonaCohesionSeed() {
    final preview = componentCohesionPreview;
    return {
      'radiusBase':
          (preview['radiusBase'] as num?)?.toDouble() ??
          VisualCohesionTokensV3.radiusM,
      'elevationLow':
          (preview['elevationLow'] as num?)?.toDouble() ??
          VisualCohesionTokensV3.elevationS,
      'spacingSm':
          (preview['spacingSm'] as num?)?.toDouble() ??
          VisualCohesionTokensV3.spacingS,
      'spacingMd':
          (preview['spacingMd'] as num?)?.toDouble() ??
          VisualCohesionTokensV3.spacingM,
    };
  }

  ThemeData resolveV4Theme(
    BuildContext context,
    bool isActive,
    V4TokenRegistry tokens,
  ) {
    return build(Theme.of(context), isActive, tokens);
  }

  Map<String, String> exportSnapshot(ThemeData data) {
    return {
      'surface': data.colorScheme.surface.toString(),
      'surfaceTint': data.colorScheme.surfaceTint.toString(),
      'shadowColor': data.shadowColor.toString(),
      'elevCard': data.cardTheme.elevation?.toString() ?? '',
      'elevChip': data.chipTheme.elevation?.toString() ?? '',
      'iconColor': data.iconTheme.color?.toString() ?? '',
    };
  }

  Map<String, Object> exportVisualQASnapshotV1() =>
      V4VisualQASnapshotV1.build();

  Map<String, Object> exportVisualQACohesionBridgeV1({
    required Map<String, Object> snapshot,
    required Map<String, Object> activationRelay,
    required Map<String, Object> activationMasterBundle,
  }) => V4VisualQACohesionBridgeV1.build(
    snapshot: snapshot,
    activationRelay: activationRelay,
    activationMasterBundle: activationMasterBundle,
  );

  Color _blend(Color base, double tint) {
    final alpha = ((base.a / 255.0 * tint).clamp(0.0, 1.0) * 255).round();
    return Color.alphaBlend(base.withAlpha(alpha), base);
  }

  Color _scaleColor(Color base, double factor) {
    int clampChannel(double value) {
      final scaled = (value * factor).round();
      if (scaled < 0) return 0;
      if (scaled > 255) return 255;
      return scaled;
    }

    final alpha = (base.a * 255).round().clamp(0, 255);
    return Color.fromARGB(
      alpha,
      clampChannel(base.r),
      clampChannel(base.g),
      clampChannel(base.b),
    );
  }

  Color _shiftColor(Color base, double shift) {
    final hsl = HSLColor.fromColor(base);
    final shifted = hsl.withLightness(
      (hsl.lightness + shift * 0.02).clamp(0.0, 1.0),
    );
    return shifted.toColor();
  }

  TextStyle? _adjustV4TextStyle(
    TextStyle? style, {
    required double scale,
    required int weightDelta,
    required double letterSpacingDelta,
    double? fontSizeOverride,
    double? letterSpacingOverride,
  }) {
    if (style == null) return null;
    final fontSize =
        fontSizeOverride ??
        (style.fontSize != null ? style.fontSize! * scale : style.fontSize);
    final weight = _adjustWeight(style.fontWeight, weightDelta);
    final letterSpacing =
        letterSpacingOverride ??
        ((style.letterSpacing ?? 0.0) + letterSpacingDelta);
    return style.copyWith(
      fontSize: fontSize,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  FontWeight _adjustWeight(FontWeight? base, int delta) {
    if (delta == 0) return base ?? FontWeight.normal;
    final target = delta > 0 ? FontWeight.w900 : FontWeight.w100;
    final ratio = (delta.abs() / 3.0).clamp(0.0, 1.0);
    return FontWeight.lerp(base ?? FontWeight.normal, target, ratio) ??
        (base ?? FontWeight.normal);
  }

  Color _adjustNeutral(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _adjustRoleTone(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hueShift = (factor - 1.0) * 8.0;
    final hue = (hsl.hue + hueShift + 360.0) % 360.0;
    final saturation = (hsl.saturation * factor).clamp(0.0, 1.0);
    final lightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    return hsl
        .withHue(hue)
        .withSaturation(saturation)
        .withLightness(lightness)
        .toColor();
  }

  ThemeData buildMaterialAppSurfaceTheme(ThemeData base) {
    return base.copyWith(
      dividerColor: base.dividerColor,
      splashFactory: base.splashFactory,
    );
  }

  ThemeData mergeMaterialAppSurface(ThemeData base) {
    return isRuntimeV4Enabled ? buildMaterialAppSurfaceTheme(base) : base;
  }

  ThemeData buildMaterialTransitionTheme(ThemeData base) {
    return base.copyWith(
      splashFactory: base.splashFactory,
      highlightColor: base.highlightColor,
      hoverColor: base.hoverColor,
      focusColor: base.focusColor,
    );
  }

  ThemeData mergeMaterialTransitions(ThemeData base) {
    return isRuntimeV4Enabled ? buildMaterialTransitionTheme(base) : base;
  }

  ThemeData buildScaffoldAppBarSurfaceTheme(ThemeData base) {
    return base.copyWith(
      scaffoldBackgroundColor: base.scaffoldBackgroundColor,
      appBarTheme: base.appBarTheme.copyWith(
        surfaceTintColor: Colors.transparent,
        shadowColor: base.shadowColor,
      ),
    );
  }

  ThemeData mergeScaffoldAppBarSurface(ThemeData base) {
    return isRuntimeV4Enabled ? buildScaffoldAppBarSurfaceTheme(base) : base;
  }

  ThemeData buildNavigationSurfacesTheme(ThemeData base) {
    final cohesionPreview = componentCohesionPreview;
    final elevationLow =
        (cohesionPreview['elevationLow'] as num?)?.toDouble() ??
        VisualCohesionTokensV3.elevationS;
    final navigationBarTheme = base.navigationBarTheme.copyWith(
      elevation: elevationLow,
    );
    final navigationRailTheme = base.navigationRailTheme.copyWith(
      elevation: elevationLow,
    );
    return base.copyWith(
      navigationBarTheme: navigationBarTheme,
      navigationRailTheme: navigationRailTheme,
    );
  }

  ThemeData mergeNavigationSurfaces(ThemeData base) {
    return isRuntimeV4Enabled ? buildNavigationSurfacesTheme(base) : base;
  }

  ThemeData buildBottomSheetDrawerSurfaceTheme(ThemeData base) {
    final cohesionPreview = componentCohesionPreview;
    final radiusBase =
        (cohesionPreview['radiusBase'] as num?)?.toDouble() ??
        VisualCohesionTokensV3.radiusM;
    final elevationLow =
        (cohesionPreview['elevationLow'] as num?)?.toDouble() ??
        VisualCohesionTokensV3.elevationS;
    final shadowColor =
        (cohesionPreview['shadowSoft'] as List<BoxShadow>?)
            ?.firstWhere(
              (shadow) => shadow.blurRadius >= 0,
              orElse: () => BoxShadow(color: base.shadowColor),
            )
            .color ??
        base.shadowColor;
    final bottomSheetTheme = base.bottomSheetTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      shadowColor: shadowColor,
    );
    final drawerTheme = base.drawerTheme.copyWith(
      elevation: elevationLow,
      scrimColor: base.drawerTheme.scrimColor,
    );
    return base.copyWith(
      bottomSheetTheme: bottomSheetTheme,
      drawerTheme: drawerTheme,
    );
  }

  ThemeData mergeBottomSheetDrawerSurface(ThemeData base) {
    return isRuntimeV4Enabled ? buildBottomSheetDrawerSurfaceTheme(base) : base;
  }

  ThemeData buildDialogPopupSurfaceTheme(ThemeData base) {
    final cohesionPreview = componentCohesionPreview;
    final radiusBase =
        (cohesionPreview['radiusBase'] as num?)?.toDouble() ??
        VisualCohesionTokensV3.radiusM;
    final elevationLow =
        (cohesionPreview['elevationLow'] as num?)?.toDouble() ??
        VisualCohesionTokensV3.elevationS;
    final shadowColor =
        (cohesionPreview['shadowSoft'] as List<BoxShadow>?)
            ?.firstWhere(
              (shadow) => shadow.blurRadius >= 0,
              orElse: () => BoxShadow(color: base.shadowColor),
            )
            .color ??
        base.shadowColor;
    final dialogTheme = base.dialogTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      shadowColor: shadowColor,
    );
    final popupMenuTheme = base.popupMenuTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusBase),
      ),
      elevation: elevationLow,
      color: base.popupMenuTheme.color,
    );
    return base.copyWith(
      dialogTheme: dialogTheme,
      popupMenuTheme: popupMenuTheme,
    );
  }

  ThemeData mergeDialogPopupSurface(ThemeData base) {
    return isRuntimeV4Enabled ? buildDialogPopupSurfaceTheme(base) : base;
  }

  ThemeData buildGlobalRuntimeCohesionTheme(ThemeData base) {
    final cohesionPreview = componentCohesionPreview;
    final shadowColor =
        (cohesionPreview['shadowSoft'] as List<BoxShadow>?)
            ?.firstWhere(
              (shadow) => shadow.blurRadius >= 0,
              orElse: () => BoxShadow(color: base.shadowColor),
            )
            .color ??
        base.shadowColor;
    return base.copyWith(
      dividerColor: base.dividerColor,
      shadowColor: shadowColor,
      splashFactory: base.splashFactory,
    );
  }

  ThemeData mergeGlobalRuntimeCohesion(ThemeData base) {
    return isRuntimeV4Enabled ? buildGlobalRuntimeCohesionTheme(base) : base;
  }

  ThemeData buildMaterialAppV4Theme(ThemeData base) {
    var theme = base;
    theme = mergeMaterialAppSurface(theme);
    theme = mergeMaterialTransitions(theme);
    theme = mergeScaffoldAppBarSurface(theme);
    theme = mergeNavigationSurfaces(theme);
    theme = mergeBottomSheetDrawerSurface(theme);
    theme = mergeDialogPopupSurface(theme);
    theme = mergeGlobalRuntimeCohesion(theme);
    return theme;
  }
}
