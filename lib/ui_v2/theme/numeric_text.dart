import 'dart:ui' show FontFeature;

import 'package:flutter/widgets.dart';

import 'package:poker_analyzer/ui_v2/theme/tabular_figures.dart';

class NumericText extends StatelessWidget {
  const NumericText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final base = style ?? const TextStyle();
    final combined = <FontFeature>[...kTabularFigures];
    if (base.fontFeatures != null) {
      combined.addAll(base.fontFeatures!);
    }
    final mergedStyle = base.copyWith(fontFeatures: combined);
    return Text(
      text,
      style: mergedStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
