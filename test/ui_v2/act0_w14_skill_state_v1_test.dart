import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('You explains the unstarted W1-W4 skill map', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    final skills = find.byKey(const Key('act0_w14_skills'));
    expect(skills, findsOneWidget);
    await tester.ensureVisible(skills);
    await tester.tap(skills);
    await tester.pumpAndSettle();
    expect(find.text('Not started'), findsNWidgets(6));
    expect(find.text('Table sense'), findsOneWidget);
    expect(find.text('Position play'), findsOneWidget);
    expect(find.text('No lesson answers recorded yet.'), findsNWidgets(6));
  });
}
