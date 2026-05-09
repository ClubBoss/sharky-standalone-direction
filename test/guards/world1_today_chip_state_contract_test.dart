import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

Future<void> _completeIntroWelcomePack(WidgetTester tester) async {
  const steps = <String>['btn', 'sb', 'bb'];
  for (final seatId in steps) {
    await tester.tap(find.byKey(Key('microtask_seat_$seatId')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('today chip state toggles from ready to completed in session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    debugHasWorld1MicroTaskPackOverride = (_) => true;
    addTearDown(() {
      debugHasWorld1MicroTaskPackOverride = null;
    });
    await pumpToMap(tester, prefs: prefs);
    for (var i = 0; i < 40; i++) {
      if (find
          .byKey(const Key('world1_today_chip_state'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('world1_today_chip_state')), findsOneWidget);
    expect(find.text('Daily Ready'), findsOneWidget);

    final entry = find.byKey(
      const Key('world1_foundations_entry_world1_act0_table_literacy'),
    );
    expect(entry, findsOneWidget);
    await tester.ensureVisible(entry);
    await tester.tap(entry, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

    await _completeIntroWelcomePack(tester);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 300));

    expect(findMap(), findsWidgets);
    expect(find.byKey(const Key('world1_today_chip_state')), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
