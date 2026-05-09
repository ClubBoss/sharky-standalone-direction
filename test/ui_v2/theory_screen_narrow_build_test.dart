import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('theory session builds on narrow width without exception', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(640, 900)),
        child: MaterialApp(
          home: TheorySessionScreen(
            moduleId: 'intro_welcome',
            moduleTitle: 'Welcome to Poker',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Welcome to Poker'), findsWidgets);
    expect(find.byKey(const Key('theory_bridge_surface_v1')), findsOneWidget);
    expect(find.byKey(const Key('theory_start_practice_cta')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
