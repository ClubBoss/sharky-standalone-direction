import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'result whats-next block renders on narrow width without overflow',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 3,
            totalCount: 4,
            moduleId: 'intro_welcome',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_whats_next_block')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_whats_next_title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_whats_next_value')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
