import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('module summary starts theory without throwing', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(
        home: ModuleSummaryScreen(
          moduleData: <String, dynamic>{
            'id': 'intro_welcome',
            'title': 'Welcome to Poker',
            'description': 'Why poker is a game of skill.',
            'tier': 'Free',
          },
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('START THEORY'));
    await tester.pumpAndSettle();

    expect(find.byType(TheorySessionScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
