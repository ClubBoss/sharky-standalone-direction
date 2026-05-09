import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _openPractice(WidgetTester tester, String moduleId) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TheorySessionScreen(moduleId: moduleId, moduleTitle: moduleId),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.byKey(const Key('theory_start_practice_cta')));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('table-native runner is used for World1 modules with packs', (
    tester,
  ) async {
    await _openPractice(tester, kWorld1CanonicalModuleOrder.first);
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await _openPractice(tester, kWorld1CanonicalModuleOrder[1]);
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await _openPractice(tester, kWorld1CanonicalModuleOrder[2]);
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await _openPractice(tester, 'w2.s02');
    expect(find.byType(SessionDrillPlayerV1Screen), findsOneWidget);
    expect(find.byKey(const Key('table_practice_runner')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await _openPractice(tester, 'non_world1_module');
    expect(find.byType(DrillRunnerScreen), findsOneWidget);
    expect(find.byKey(const Key('table_practice_runner')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
