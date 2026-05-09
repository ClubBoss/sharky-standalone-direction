import 'package:flutter/material.dart';

import 'table_v4_qa_overlay_typography_injector_v1.dart';

/// Lightweight QA overlay showing V4 mega-surface issues.
class TableV4QAOverlayV1 extends StatelessWidget {
  const TableV4QAOverlayV1({
    super.key,
    required this.megaSurfaceMap,
    required this.paletteMap,
    required this.layoutFrameMap,
    required this.accessibilityMap,
    required this.typographyInjectorMap,
    required this.severityLegendMap,
    required this.typographyFineTuneMap,
    required this.typographyCompensationMap,
    required this.typographyResponsiveScalingMap,
  });

  final Map<String, Object?> megaSurfaceMap;
  final Map<String, Object?> paletteMap;
  final Map<String, Object?> layoutFrameMap;
  final Map<String, Object?> accessibilityMap;
  final Map<String, Object?> typographyInjectorMap;
  final Map<String, Object?> severityLegendMap;
  final Map<String, Object?> typographyFineTuneMap;
  final Map<String, Object?> typographyCompensationMap;
  final Map<String, Object?> typographyResponsiveScalingMap;

  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> body =
        megaSurfaceMap['table_v4_visual_qa_megasurface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final List<String> issues = <String>[..._pluckIssues(body, 'all_issues')];
    if (issues.isEmpty) {
      return const SizedBox.shrink();
    }
    final Color backgroundColor =
        (paletteMap['bg_color'] as Color?) ?? Colors.black.withAlpha(180);
    final Color textColor =
        (paletteMap['text_color'] as Color?) ?? Colors.white;
    final Color borderColor =
        (paletteMap['line_color'] as Color?) ?? Colors.white;
    final double alpha = (paletteMap['alpha'] as double?) ?? 0.9;
    final int alphaValue = (alpha.clamp(0.0, 1.0) * 255).round().clamp(0, 255);

    final double paddingPx = _toDouble(layoutFrameMap['padding_px'], 12);
    final String anchor = layoutFrameMap['anchor'] as String? ?? 'top_right';
    final double maxWidth = _toDouble(layoutFrameMap['max_width_px'], 360);
    final double maxHeight = _toDouble(layoutFrameMap['max_height_px'], 600);
    final Alignment alignment = _alignmentForAnchor(anchor);
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(paddingPx),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor.withAlpha(alphaValue),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final String issue in issues)
                    Text(
                      _prefixIssue(issue),
                      style: _applyTypography(_textStyle(textColor)),
                      softWrap: true,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double _toDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  static int _toInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static Alignment _alignmentForAnchor(String anchor) {
    switch (anchor) {
      case 'top_left':
        return Alignment.topLeft;
      case 'top_right':
        return Alignment.topRight;
      case 'bottom_left':
        return Alignment.bottomLeft;
      case 'bottom_right':
        return Alignment.bottomRight;
      default:
        return Alignment.topRight;
    }
  }

  TextStyle _textStyle(Color color) {
    final double minFontSize = _toDouble(
      accessibilityMap['min_font_size_px'],
      11,
    );
    final double scaleFactor = _toDouble(accessibilityMap['scale_factor'], 1.0);
    final int minAlpha =
        (accessibilityMap['min_alpha'] as int?)?.clamp(0, 255) ?? 128;
    final double fontSize = (11 * scaleFactor).clamp(
      minFontSize,
      double.infinity,
    );
    final int colorAlpha = (color.toARGB32() >> 24) & 0xff;
    final int alphaValue = colorAlpha.clamp(minAlpha, 255);
    return TextStyle(
      fontSize: fontSize,
      color: color.withAlpha(alphaValue),
      height: 1.2,
    );
  }

  TextStyle _applyTypography(TextStyle base) {
    final TextStyle injected =
        TableV4QAOverlayTypographyInjectorV1.styleFromQAOverlayMap(
          typographyInjectorMap,
          base,
        );
    final TextStyle fineTuned = _applyFineTune(injected);
    final TextStyle compensated = _applyCompensation(fineTuned);
    return _applyResponsiveScaling(compensated);
  }

  TextStyle _applyFineTune(TextStyle base) {
    final Map<String, Object> body =
        typographyFineTuneMap['typography_finetune_v1']
            as Map<String, Object>? ??
        <String, Object>{};
    final double scaleDelta = _toDouble(body['font_scale_delta'], 0.02);
    final double letterDelta = _toDouble(body['letter_spacing_delta'], 0.1);
    final int weightTweak = _toInt(body['weight_tweak'], 1);
    final int alphaFloor = _toInt(body['alpha_floor'], 160);
    final int alphaCeiling = _toInt(body['alpha_ceiling'], 230);
    final double fontSize =
        (base.fontSize ?? 11.0) * (1.0 + scaleDelta.clamp(0.0, 1.0));
    final double letterSpacing = (base.letterSpacing ?? 0.0) + letterDelta;
    final int alpha =
        ((base.color ?? const Color(0xffffffff)).toARGB32() >> 24 & 0xff).clamp(
          alphaFloor,
          alphaCeiling,
        );
    final int weightValue = (_fontWeightValue(base.fontWeight) + weightTweak)
        .clamp(100, 900);
    final FontWeight weight = FontWeight.values.firstWhere(
      (w) => _fontWeightValue(w) == weightValue,
      orElse: () => base.fontWeight ?? FontWeight.normal,
    );
    return base.copyWith(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      color: (base.color ?? const Color(0xffffffff)).withAlpha(alpha),
    );
  }

  static int _fontWeightValue(FontWeight? weight) {
    final FontWeight resolved = weight ?? FontWeight.normal;
    if (resolved == FontWeight.w100) return 100;
    if (resolved == FontWeight.w200) return 200;
    if (resolved == FontWeight.w300) return 300;
    if (resolved == FontWeight.w400) return 400;
    if (resolved == FontWeight.w500) return 500;
    if (resolved == FontWeight.w600) return 600;
    if (resolved == FontWeight.w700) return 700;
    if (resolved == FontWeight.w800) return 800;
    if (resolved == FontWeight.w900) return 900;
    return 400;
  }

  TextStyle _applyCompensation(TextStyle base) {
    final Map<String, Object> body =
        typographyCompensationMap['typography_compensation_map_v1']
            as Map<String, Object>? ??
        <String, Object>{};
    final int weightBias = _toInt(body['weight_bias'], 0);
    final double scaleBias = _toDouble(body['scale_bias'], 0.01);
    final double letterBias = _toDouble(body['letter_spacing_bias'], 0.05);
    final int alphaBias = _toInt(body['alpha_bias'], 0);
    final double fontSize = (base.fontSize ?? 11.0) * (1.0 + scaleBias);
    final double letterSpacing = (base.letterSpacing ?? 0.0) + letterBias;
    final int alpha =
        ((base.color ?? const Color(0xffffffff)).toARGB32() >> 24 & 0xff).clamp(
          0,
          255,
        );
    final int weightValue = (_fontWeightValue(base.fontWeight) + weightBias)
        .clamp(100, 900);
    final FontWeight weight = FontWeight.values.firstWhere(
      (w) => _fontWeightValue(w) == weightValue,
      orElse: () => base.fontWeight ?? FontWeight.normal,
    );
    return base.copyWith(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      color: (base.color ?? const Color(0xffffffff)).withAlpha(
        (alpha + alphaBias).clamp(0, 255),
      ),
    );
  }

  TextStyle _applyResponsiveScaling(TextStyle base) {
    final Map<String, Object> body =
        typographyResponsiveScalingMap['typography_responsive_scaling_map_v1']
            as Map<String, Object>? ??
        <String, Object>{};
    final double low = _toDouble(body['scale_factor_lowdpi'], 0.98);
    final double normal = _toDouble(body['scale_factor_normdpi'], 1.0);
    final double high = _toDouble(body['scale_factor_hidpi'], 1.02);
    final int alphaLow = _toInt(body['alpha_adjust_lowdpi'], 4);
    final int alphaHigh = _toInt(body['alpha_adjust_hidpi'], -3);
    final double scale = normal;
    final double fontSize = (base.fontSize ?? 11.0) * scale;
    final double letterSpacing = (base.letterSpacing ?? 0.0);
    final int alpha =
        ((base.color ?? const Color(0xffffffff)).toARGB32() >> 24 & 0xff);
    final int alphaAdjust = scale == high
        ? alphaHigh
        : (scale == low ? alphaLow : 0);
    final FontWeight weight = base.fontWeight ?? FontWeight.normal;
    return base.copyWith(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      color: (base.color ?? const Color(0xffffffff)).withAlpha(
        (alpha + alphaAdjust).clamp(0, 255),
      ),
    );
  }

  String _prefixIssue(String issue) {
    final List<String> parts = issue.split(':');
    final String severity = parts.isNotEmpty ? parts.first : 'info';
    final String normalized = severity.toLowerCase();
    final String label = (normalized == 'warning'
        ? 'WARN'
        : normalized.toUpperCase());
    final String rest = parts.length > 1
        ? parts.sublist(1).join(':').trim()
        : issue;
    return '$label: $rest';
  }

  static Iterable<String> _pluckIssues(Map<String, Object?> body, String key) {
    final Object? issues = body[key];
    if (issues is List) {
      final List<String> result = issues.whereType<String>().toList()..sort();
      return result;
    }
    return <String>[];
  }
}
