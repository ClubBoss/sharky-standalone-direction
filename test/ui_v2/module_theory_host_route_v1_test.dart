import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/core_starting_hands_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  testWidgets('module theory host route uses table-first host when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  moduleTheoryHostRouteV1(
                    moduleId: coreStartingHandsModuleId,
                    moduleTitle: 'Core Starting Hands',
                  ),
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.byType(CoreStartingHandsScreen), findsOneWidget);
  });

  testWidgets('module theory host route falls back to theory session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  moduleTheoryHostRouteV1(
                    moduleId: 'non_table_first_module',
                    moduleTitle: 'Fallback Theory',
                  ),
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(TheorySessionScreen), findsOneWidget);
  });
}
