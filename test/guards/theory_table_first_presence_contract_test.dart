import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('world1 summary leads to theory table-first shell', (
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    final startTheory = find.byKey(
      const Key('module_summary_start_theory_cta'),
    );
    expect(startTheory, findsOneWidget);
    expect(find.byKey(const Key('table_first_summary_shell')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: TheorySessionScreen(
          moduleId: kWorld1CanonicalModuleOrder.first,
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TheorySessionScreen), findsOneWidget);
    expect(find.byKey(const Key('table_first_theory_shell')), findsOneWidget);
    expect(find.byKey(const Key('table_first_theory_overlay')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
