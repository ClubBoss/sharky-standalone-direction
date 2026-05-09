import 'dart:math';
import 'dart:ui' as ui;

class ActionButtonsLayoutV1 {
  const ActionButtonsLayoutV1();

  static List<ui.Offset> computeButtonPositions({
    required int buttonCount,
    required double tableRadius,
    required double scale,
  }) {
    final int safeCount = buttonCount < 1 ? 1 : buttonCount;
    final double safeRadius =
        (tableRadius.isFinite ? tableRadius : 0.0) * scale;
    final double baseAngle = 180.0 / (safeCount + 1);
    final List<ui.Offset> positions = <ui.Offset>[];
    for (int index = 0; index < safeCount; index++) {
      final double angleDegrees = -90 + baseAngle * (index + 1);
      final double radians = angleDegrees * (3.141592653589793 / 180.0);
      final double x = safeRadius * 0.9 * cos(radians);
      final double y = safeRadius * 0.2 * sin(radians);
      positions.add(ui.Offset(x, y));
    }
    return List<ui.Offset>.unmodifiable(positions);
  }
}
