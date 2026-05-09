import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('world1 start practice opens a table-first practice surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TheorySessionScreen(
          moduleId: kWorld1CanonicalModuleOrder.first,
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('theory_start_practice_cta')));
    await tester.pumpAndSettle();

    final tablePractice = find.byKey(const Key('table_practice_runner'));
    final drillShell = find.byKey(const Key('table_first_practice_shell'));

    expect(
      tablePractice.evaluate().isNotEmpty || drillShell.evaluate().isNotEmpty,
      isTrue,
    );
    expect(
      find
              .byType(World1FoundationsMicroTaskRunnerScreen)
              .evaluate()
              .isNotEmpty ||
          find.byType(DrillRunnerScreen).evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
