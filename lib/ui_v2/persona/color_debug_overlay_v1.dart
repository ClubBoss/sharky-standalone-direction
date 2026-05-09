import 'package:flutter/widgets.dart';

import 'color_cue_model_v1.dart';

class ColorDebugOverlayV1 extends StatelessWidget {
  const ColorDebugOverlayV1({
    Key? key,
    this.cue,
    this.compositeStrength,
    this.overlayColor,
  }) : super(key: key);

  final ColorCueModelV1? cue;
  final double? compositeStrength;
  final Color? overlayColor;

  String _hexColor(Color? color) {
    if (color == null) return 'none';
    return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hue = cue?.hueShift?.toStringAsFixed(2) ?? 'n/a';
    final sat = cue?.saturationBoost?.toStringAsFixed(2) ?? 'n/a';
    final ctr = cue?.contrastBoost?.toStringAsFixed(2) ?? 'n/a';
    final cmp = compositeStrength?.toStringAsFixed(2) ?? 'n/a';
    final col = _hexColor(overlayColor);

    return Positioned(
      top: 0,
      left: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('hue: $hue'),
          Text('sat: $sat'),
          Text('ctr: $ctr'),
          Text('cmp: $cmp'),
          Text('col: $col'),
        ],
      ),
    );
  }
}
