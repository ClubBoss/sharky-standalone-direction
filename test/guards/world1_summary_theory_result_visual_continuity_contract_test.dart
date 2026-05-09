import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('world1 flow keeps summary/theory continuity surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ModuleSummaryScreen(
          moduleData: <String, dynamic>{
            'id': kWorld1CanonicalModuleOrder.first,
            'title': 'Welcome to Poker',
            'description': 'Intro module',
            'tier': 'Free',
            'isAvailable': true,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModuleSummaryScreen), findsOneWidget);
    expect(find.byKey(const Key('table_first_summary_shell')), findsOneWidget);
    expect(
      find.byKey(const Key('module_summary_next_action_strip')),
      findsNothing,
    );

    final startTheoryFinder = find.byKey(
      const Key('module_summary_start_theory_cta'),
    );
    await tester.ensureVisible(startTheoryFinder);
    final startTheoryButton = tester.widget<ElevatedButton>(startTheoryFinder);
    startTheoryButton.onPressed?.call();
    await tester.pumpAndSettle();

    expect(find.byType(TheorySessionScreen), findsOneWidget);
    expect(find.byKey(const Key('table_first_theory_shell')), findsOneWidget);
    expect(find.byKey(const Key('table_first_theory_overlay')), findsOneWidget);
    expect(find.byKey(const Key('theory_next_action_strip')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
