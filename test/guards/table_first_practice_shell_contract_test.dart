import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('table-first shell appears for world1 module practice', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrillRunnerScreen(moduleId: kWorld1CanonicalModuleOrder.first),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.byKey(const Key('table_first_practice_shell')), findsOneWidget);
    expect(find.byKey(const Key('table_first_step_header')), findsOneWidget);
    expect(
      find.byKey(const Key('table_first_practice_stepper')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('table_first_overlay_card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('table-first shell is not used for non-world1 module', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DrillRunnerScreen(moduleId: 'non_world1_module')),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('table_first_practice_shell')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('table-first shell interaction path stays non-throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DrillRunnerScreen(moduleId: kWorld1CanonicalModuleOrder.first),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    final option0 = find.byKey(const ValueKey<String>('drill_option_0'));
    if (option0.evaluate().isNotEmpty) {
      await tester.tap(option0.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
    }

    expect(tester.takeException(), isNull);
  });
}
