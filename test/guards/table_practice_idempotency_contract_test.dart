import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _selectAndCheck(
  WidgetTester tester, {
  required String seatId,
}) async {
  await tester.tap(find.byKey(Key('table_practice_seat_$seatId')));
  await tester.pump(const Duration(milliseconds: 90));
  await tester.tap(find.byKey(const Key('table_practice_check_cta')));
  await tester.pump(const Duration(milliseconds: 220));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('table practice completion is idempotent on rapid check taps', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'non_pack_module_for_test',
          moduleTitle: 'Fallback Pack',
          mode: kWorld1RunnerModeTablePractice,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);

    await _selectAndCheck(tester, seatId: 'btn');
    expect(find.text('Step 2 of 3'), findsOneWidget);
    await _selectAndCheck(tester, seatId: 'bb');
    expect(find.text('Step 3 of 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('table_practice_seat_hj')));
    await tester.pump(const Duration(milliseconds: 90));

    final check = find.byKey(const Key('table_practice_check_cta'));
    await tester.tap(check);
    await tester.tap(check, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pumpAndSettle();

    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
