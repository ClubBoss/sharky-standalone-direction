import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('theory next-action strip remains stable on narrow width', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: TheorySessionScreen(
          moduleId: kWorld1CanonicalModuleOrder.first,
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('theory_next_action_strip')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
