import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  void setDesktopViewport(WidgetTester tester) {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets('next module CTA is visible when canonical next is available', (
    tester,
  ) async {
    setDesktopViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionResultScreen(
          correctCount: 3,
          totalCount: 5,
          moduleId: kWorld1CanonicalModuleOrder.first,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_result_next_module_cta')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('next module CTA is hidden when canonical next is unavailable', (
    tester,
  ) async {
    setDesktopViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionResultScreen(
          correctCount: 4,
          totalCount: 5,
          moduleId: kWorld1CanonicalModuleOrder.last,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_result_next_module_cta')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
