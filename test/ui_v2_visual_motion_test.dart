import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_motion_v1.dart';

void main() {
  testWidgets('UiMotionV1 interactiveScale honors the active flag', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: UiMotionV1.interactiveScale(
          active: true,
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );

    final animatedScale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(animatedScale.scale, 1.06);
    expect(animatedScale.duration, UiMotionV1.fast);

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AnimatedScale), findsOneWidget);
  });

  test('UiMotionV1 constants remain stable', () {
    expect(UiMotionV1.fast, const Duration(milliseconds: 160));
    expect(UiMotionV1.normal, const Duration(milliseconds: 240));
    expect(UiMotionV1.standardCurve, Curves.easeInOut);
    expect(UiMotionV1.gentleCurve, Curves.easeOut);
  });
}
