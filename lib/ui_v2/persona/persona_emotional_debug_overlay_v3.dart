import 'package:flutter/widgets.dart';

import 'persona_emotional_fusion_v3.dart';
import 'persona_renderer_v3.dart';

class PersonaEmotionalDebugOverlayV3 extends StatelessWidget {
  const PersonaEmotionalDebugOverlayV3({
    Key? key,
    this.themeCues,
    this.lastFusionSnapshot,
    this.v4Style,
  }) : super(key: key);

  final PersonaEmotionalThemeCues? themeCues;
  final Object? lastFusionSnapshot;
  final PersonaRendererV3V4Style? v4Style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style;
    final labelStyle = v4Style?.labelStyle ?? baseStyle;
    final backgroundColor = v4Style?.tint;
    return Container(
      color: backgroundColor,
      child: DefaultTextStyle(
        style: labelStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emotion Debug'),
            Text('ThemeCues: $themeCues'),
            Text('FusionSnapshot: $lastFusionSnapshot'),
            if (v4Style != null) ...[
              Text(
                'V4 Radius: ${v4Style!.v4SurfaceRadius?.toStringAsFixed(2) ?? 'null'}',
              ),
              Text(
                'V4 Elevation: ${v4Style!.v4SurfaceElevation?.toStringAsFixed(2) ?? 'null'}',
              ),
              Text(
                'V4 Spacing: ${v4Style!.v4SurfaceSpacing?.toStringAsFixed(2) ?? 'null'}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
